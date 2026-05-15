import { Routes, Route } from 'react-router-dom'

export function AppRoutes() {
  return (
    <Routes>
      <Route path="/" element={<div className="p-8 text-center text-xl">Welcome to {{PROJECT_NAME}}</div>} />
    </Routes>
  )
}
