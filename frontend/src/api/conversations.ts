import { api } from './client'
import type { Conversation, Message, Pagination } from './types'

interface ConversationsResponse {
  conversations: Conversation[]
  pagination: Pagination
}

interface ConversationResponse {
  conversation: Conversation
}

interface MessagesResponse {
  messages: Message[]
  pagination: Pagination
}

interface CreateMessageResponse {
  user_message: Message
  assistant_message: Message
}

export function listConversations(page = 1): Promise<ConversationsResponse> {
  return api.get<ConversationsResponse>(`/conversations?page=${page}`)
}

export function getConversation(id: number): Promise<ConversationResponse> {
  return api.get<ConversationResponse>(`/conversations/${id}`)
}

export function createConversation(params: {
  title: string
  system_prompt_id?: number
  llm_model_id?: number
}): Promise<ConversationResponse> {
  return api.post<ConversationResponse>('/conversations', { conversation: params })
}

export function updateConversation(
  id: number,
  params: { title?: string }
): Promise<ConversationResponse> {
  return api.patch<ConversationResponse>(`/conversations/${id}`, { conversation: params })
}

export function deleteConversation(id: number): Promise<void> {
  return api.delete<void>(`/conversations/${id}`)
}

export function listMessages(conversationId: number, page = 1): Promise<MessagesResponse> {
  return api.get<MessagesResponse>(`/conversations/${conversationId}/messages?page=${page}`)
}

export function sendMessage(
  conversationId: number,
  content: string
): Promise<CreateMessageResponse> {
  return api.post<CreateMessageResponse>(`/conversations/${conversationId}/messages`, {
    message: { content },
  })
}
