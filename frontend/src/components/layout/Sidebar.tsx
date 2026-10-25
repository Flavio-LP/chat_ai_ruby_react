import { Link, useNavigate } from 'react-router-dom'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import { createConversation } from '@/api/conversations'
import { useAuth } from '@/hooks/useAuth'
import type { Conversation } from '@/api/types'

interface SidebarProps {
  conversations: Conversation[]
  activeId: number | null
}

export default function Sidebar({ conversations, activeId }: SidebarProps) {
  const { user, logout } = useAuth()
  const navigate = useNavigate()
  const queryClient = useQueryClient()

  const newConversation = useMutation({
    mutationFn: () => createConversation({ title: 'Nova conversa' }),
    onSuccess: data => {
      queryClient.invalidateQueries({ queryKey: ['conversations'] })
      navigate(`/conversations/${data.conversation.id}`)
    },
  })

  return (
    <aside className="w-64 flex flex-col border-r border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800">
      <div className="p-4 border-b border-gray-200 dark:border-gray-700">
        <h1 className="font-semibold text-gray-900 dark:text-white text-lg">Chat IA</h1>
      </div>

      <div className="p-3">
        <button
          onClick={() => newConversation.mutate()}
          disabled={newConversation.isPending}
          className="w-full text-left text-sm py-2 px-3 rounded-lg bg-blue-600 text-white hover:bg-blue-700 disabled:opacity-50"
        >
          + Nova conversa
        </button>
      </div>

      <nav className="flex-1 overflow-y-auto p-2 space-y-0.5">
        {conversations.map(conv => (
          <Link
            key={conv.id}
            to={`/conversations/${conv.id}`}
            className={`block text-sm px-3 py-2 rounded-lg truncate transition-colors ${
              conv.id === activeId
                ? 'bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300'
                : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700'
            }`}
          >
            {conv.title}
          </Link>
        ))}
      </nav>

      <div className="p-3 border-t border-gray-200 dark:border-gray-700">
        <div className="text-xs text-gray-500 dark:text-gray-400 mb-2 truncate">{user?.email}</div>
        <button
          onClick={logout}
          className="w-full text-sm text-left px-3 py-1.5 rounded-lg text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700"
        >
          Sair
        </button>
      </div>
    </aside>
  )
}
