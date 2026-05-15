export interface ApiResponse<T> {
  data: T
  message?: string
  status: string
}

export interface PaginatedResponse<T> {
  data: T[]
  total: number
  page: number
  limit: number
}
