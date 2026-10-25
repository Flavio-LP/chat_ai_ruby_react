import { useState, type FormEvent, type KeyboardEvent } from 'react'

interface MessageInputProps {
  onSend: (content: string) => Promise<void>
  disabled?: boolean
}

export default function MessageInput({ onSend, disabled }: MessageInputProps) {
  const [content, setContent] = useState('')
  const [sending, setSending] = useState(false)

  async function handleSubmit(e: FormEvent) {
    e.preventDefault()
    if (!content.trim() || sending) return
    const text = content.trim()
    setContent('')
    setSending(true)
    try {
      await onSend(text)
    } finally {
      setSending(false)
    }
  }

  function handleKeyDown(e: KeyboardEvent<HTMLTextAreaElement>) {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      void handleSubmit(e as unknown as FormEvent)
    }
  }

  return (
    <form
      onSubmit={handleSubmit}
      className="p-4 border-t border-gray-200 dark:border-gray-700 flex gap-2"
    >
      <textarea
        value={content}
        onChange={e => setContent(e.target.value)}
        onKeyDown={handleKeyDown}
        placeholder="Mensagem... (Enter para enviar, Shift+Enter para nova linha)"
        disabled={disabled || sending}
        rows={1}
        className="flex-1 resize-none border border-gray-300 dark:border-gray-600 rounded-xl px-4 py-2.5 text-sm bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-50 max-h-32 overflow-y-auto"
        style={{ minHeight: '42px' }}
      />
      <button
        type="submit"
        disabled={!content.trim() || disabled || sending}
        className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-sm font-medium disabled:opacity-50 shrink-0"
      >
        Enviar
      </button>
    </form>
  )
}
