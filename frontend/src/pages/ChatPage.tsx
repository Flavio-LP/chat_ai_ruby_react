import { useState, useCallback } from 'react'
import { useParams } from 'react-router-dom'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { listConversations, listMessages, sendMessage } from '@/api/conversations'
import { useConversationStream } from '@/hooks/useConversationStream'
import type { Message } from '@/api/types'
import Sidebar from '@/components/layout/Sidebar'
import MessageList from '@/components/chat/MessageList'
import MessageInput from '@/components/chat/MessageInput'

export default function ChatPage() {
  const { id } = useParams<{ id?: string }>()
  const conversationId = id ? parseInt(id, 10) : null
  const queryClient = useQueryClient()
  const [streamingMessages, setStreamingMessages] = useState<Record<number, string>>({})

  const { data: conversations } = useQuery({
    queryKey: ['conversations'],
    queryFn: () => listConversations(),
  })

  const { data: messagesData } = useQuery({
    queryKey: ['messages', conversationId],
    queryFn: () => listMessages(conversationId!),
    enabled: !!conversationId,
  })

  const handleDelta = useCallback((messageId: number, delta: string) => {
    setStreamingMessages(prev => ({
      ...prev,
      [messageId]: (prev[messageId] ?? '') + delta,
    }))
  }, [])

  const handleDone = useCallback(
    (messageId: number) => {
      setStreamingMessages(prev => {
        const next = { ...prev }
        delete next[messageId]
        return next
      })
      queryClient.invalidateQueries({ queryKey: ['messages', conversationId] })
    },
    [conversationId, queryClient]
  )

  const handleFailed = useCallback(
    (messageId: number, _error: string) => {
      setStreamingMessages(prev => {
        const next = { ...prev }
        delete next[messageId]
        return next
      })
      queryClient.invalidateQueries({ queryKey: ['messages', conversationId] })
    },
    [conversationId, queryClient]
  )

  useConversationStream({
    conversationId,
    onDelta: handleDelta,
    onDone: handleDone,
    onFailed: handleFailed,
  })

  const messages: Message[] = messagesData?.messages ?? []
  const displayMessages = messages.map(msg =>
    streamingMessages[msg.id] !== undefined
      ? { ...msg, content: streamingMessages[msg.id], status: 'streaming' as const }
      : msg
  )

  async function handleSend(content: string) {
    if (!conversationId) return
    await sendMessage(conversationId, content)
    queryClient.invalidateQueries({ queryKey: ['messages', conversationId] })
  }

  return (
    <div className="flex h-screen bg-white dark:bg-gray-900">
      <Sidebar conversations={conversations?.conversations ?? []} activeId={conversationId} />
      <main className="flex flex-col flex-1 min-w-0">
        {conversationId ? (
          <>
            <MessageList messages={displayMessages} />
            <MessageInput onSend={handleSend} disabled={!conversationId} />
          </>
        ) : (
          <div className="flex-1 flex items-center justify-center text-gray-400">
            <p>Selecione ou crie uma conversa para começar.</p>
          </div>
        )}
      </main>
    </div>
  )
}
