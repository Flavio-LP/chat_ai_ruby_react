export interface User {
  id: number
  name: string
  email: string
  created_at: string
}

export interface AuthResponse {
  user: User
  token: string
}

export interface Conversation {
  id: number
  title: string
  system_prompt_content: string | null
  summary: string | null
  total_input_tokens: number
  total_output_tokens: number
  total_cost_usd: string
  model_id: number | null
  message_count: number
  created_at: string
  updated_at: string
}

export interface Message {
  id: number
  role: 'user' | 'assistant' | 'system'
  content: string
  status: 'pending' | 'streaming' | 'completed' | 'failed'
  llm_model_provider_id: string | null
  input_tokens: number | null
  output_tokens: number | null
  cost_usd: string | null
  created_at: string
}

export interface SystemPrompt {
  id: number
  name: string
  content: string
  is_default: boolean
  created_at: string
  updated_at: string
}

export interface LlmModel {
  id: number
  provider_id: string
  name: string
  display_name: string | null
  input_price_per_million_tokens: string | null
  output_price_per_million_tokens: string | null
  context_window: number | null
  active: boolean
}

export interface Pagination {
  count: number
  page: number
  items: number
  pages: number
  last: number
  next: number | null
  prev: number | null
}

export interface PaginatedResponse<T> {
  data: T[]
  pagination: Pagination
}

export interface ApiError {
  error?: string
  errors?: string[]
}

// Cable event types
export interface CableEvent {
  type: 'streaming_start' | 'delta' | 'done' | 'failed' | 'document_ready'
  message_id: number
  delta?: string
  error?: string
  document_id?: number
}
