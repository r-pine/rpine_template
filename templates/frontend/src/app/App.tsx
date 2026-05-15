import { BrowserRouter } from 'react-router-dom'
import { Layout } from '@widgets/layout/Layout'
import { AppRoutes } from './routes'

export function App() {
  return (
    <BrowserRouter>
      <Layout>
        <AppRoutes />
      </Layout>
    </BrowserRouter>
  )
}
