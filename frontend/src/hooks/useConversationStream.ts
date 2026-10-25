import { useEffect, useRef, useCallback } from 'react'
import { createConsumer } from '@rails/actioncable'
import type { CableEvent } from '@/api/types'

interface UseConversationStreamOptions {
  conversationId: number | null
  onDelta: (messageId: number, delta: string) => void
  onDone: (messageId: number) => void
  onFailed: (messageId: number, error: string) => void
}

export function useConversationStream({
  conversationId,
  onDelta,
  onDone,
  onFailed,
}: UseConversationStreamOptions) {
  const consumerRef = useRef<ReturnType<typeof createConsumer> | null>(null)
  const subscriptionRef = useRef<{ unsubscribe: () => void } | null>(null)

  const handleReceived = useCallback(
    (data: CableEvent) => {
      switch (data.type) {
        case 'delta':
          if (data.delta) onDelta(data.message_id, data.delta)
          break
        case 'done':
          onDone(data.message_id)
          break
        case 'failed':
          onFailed(data.message_id, data.error ?? 'Erro desconhecido')
          break
      }
    },
    [onDelta, onDone, onFailed]
  )

  useEffect(() => {
    if (!conversationId) return

    const token = localStorage.getItem('auth_token')
    const cableUrl = `${window.location.protocol === 'https:' ? 'wss' : 'ws'}://${window.location.host}/cable?token=${token}`

    consumerRef.current = createConsumer(cableUrl)

    subscriptionRef.current = consumerRef.current.subscriptions.create(
      { channel: 'ConversationChannel', conversation_id: conversationId },
      { received: handleReceived }
    )

    return () => {
      subscriptionRef.current?.unsubscribe()
      consumerRef.current?.disconnect()
    }
  }, [conversationId, handleReceived])
}
