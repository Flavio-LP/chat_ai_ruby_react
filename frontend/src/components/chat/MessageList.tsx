import { useEffect, useRef } from 'react'
import ReactMarkdown from 'react-markdown'
import remarkGfm from 'remark-gfm'
import type { Message } from '@/api/types'

interface MessageListProps {
  messages: Message[]
}

export default function MessageList({ messages }: MessageListProps) {
  const bottomRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [messages])

  return (
    <div className="flex-1 overflow-y-auto p-4 space-y-4">
      {messages.map(msg => (
        <MessageBubble key={msg.id} message={msg} />
      ))}
      {messages.length === 0 && (
        <div className="text-center text-gray-400 text-sm mt-16">
          Envie uma mensagem para começar.
        </div>
      )}
      <div ref={bottomRef} />
    </div>
  )
}

function MessageBubble({ message }: { message: Message }) {
  const isUser = message.role === 'user'

  return (
    <div className={`flex ${isUser ? 'justify-end' : 'justify-start'}`}>
      <div
        className={`max-w-[80%] rounded-2xl px-4 py-2.5 text-sm ${
          isUser
            ? 'bg-blue-600 text-white'
            : 'bg-gray-100 dark:bg-gray-700 text-gray-900 dark:text-gray-100'
        }`}
      >
        {isUser ? (
          <p className="whitespace-pre-wrap">{message.content}</p>
        ) : (
          <ReactMarkdown
            remarkPlugins={[remarkGfm]}
            components={{
              code: ({ children, className }) => {
                const isBlock = className?.startsWith('language-')
                return isBlock ? (
                  <pre className="bg-black/10 dark:bg-white/10 rounded p-2 overflow-x-auto my-2">
                    <code>{children}</code>
                  </pre>
                ) : (
                  <code className="bg-black/10 dark:bg-white/10 rounded px-1">{children}</code>
                )
              },
            }}
          >
            {message.content}
          </ReactMarkdown>
        )}
        {message.status === 'streaming' && (
          <span className="inline-block w-1.5 h-4 bg-current ml-0.5 animate-pulse" />
        )}
      </div>
    </div>
  )
}
