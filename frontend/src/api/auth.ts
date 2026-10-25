import { api } from './client'
import type { AuthResponse } from './types'

export interface SignUpParams {
  name: string
  email: string
  password: string
  password_confirmation: string
}

export interface SignInParams {
  email: string
  password: string
}

export function signUp(params: SignUpParams): Promise<AuthResponse> {
  return api.post<AuthResponse>('/auth/sign_up', { user: params })
}

export function signIn(params: SignInParams): Promise<AuthResponse> {
  return api.post<AuthResponse>('/auth/sign_in', { user: params })
}

export function signOut(): Promise<void> {
  return api.delete<void>('/auth/sign_out')
}
