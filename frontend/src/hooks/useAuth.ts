import { useState, useCallback } from 'react'
import { signIn, signOut, signUp, type SignUpParams, type SignInParams } from '@/api/auth'
import { setToken, clearToken } from '@/api/client'
import type { User } from '@/api/types'

interface AuthState {
  user: User | null
  isAuthenticated: boolean
}

export function useAuth() {
  const [state, setState] = useState<AuthState>(() => {
    const stored = localStorage.getItem('auth_user')
    return stored
      ? { user: JSON.parse(stored) as User, isAuthenticated: true }
      : { user: null, isAuthenticated: false }
  })

  const login = useCallback(async (params: SignInParams) => {
    const response = await signIn(params)
    setToken(response.token)
    localStorage.setItem('auth_user', JSON.stringify(response.user))
    setState({ user: response.user, isAuthenticated: true })
    return response.user
  }, [])

  const register = useCallback(async (params: SignUpParams) => {
    const response = await signUp(params)
    setToken(response.token)
    localStorage.setItem('auth_user', JSON.stringify(response.user))
    setState({ user: response.user, isAuthenticated: true })
    return response.user
  }, [])

  const logout = useCallback(async () => {
    try {
      await signOut()
    } finally {
      clearToken()
      localStorage.removeItem('auth_user')
      setState({ user: null, isAuthenticated: false })
    }
  }, [])

  return { ...state, login, register, logout }
}
