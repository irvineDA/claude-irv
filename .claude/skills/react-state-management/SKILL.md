---
name: react-state-management
description: "React state management patterns covering client state (Zustand, Redux Toolkit, Context API) and server state (TanStack Query). Includes selection framework, store design, caching strategy, and optimistic updates."
risk: low
source: local
date_added: "2026-03-27"
---

# React State Management

> State has two fundamentally different shapes: **client state** (UI state you own) and **server state** (remote data you borrow). They have different lifecycles, caching needs, and synchronization requirements. Treat them differently.

---

## 1. Selection Framework

Pick the right tool before writing code.

### Client State

| Complexity | Tool | When |
|---|---|---|
| Single component | `useState` | Local-only, not shared |
| Related values with transitions | `useReducer` | Complex update logic |
| Subtree sharing | Context API | Avoiding prop drilling, low-frequency updates |
| App-wide, complex | **Zustand** | Preferred lightweight store |
| App-wide, enterprise / team conventions | **Redux Toolkit** | Large teams, strong devtools needs, existing Redux |
| Atomic derived state | Jotai | Fine-grained reactive atoms (niche) |

### Server State

| Need | Tool |
|---|---|
| Any data fetched from an API | **TanStack Query** |
| Full-stack mutations with optimistic UI | TanStack Query mutations |
| GraphQL | TanStack Query + graphql-request, or Apollo |
| Streaming / realtime | TanStack Query + subscriptions, or SWR |

**Do not put server data in Zustand/Redux unless you have a specific reason.** `const [data, setData] = useState(null)` + manual fetch management is the pattern TanStack Query replaces entirely.

---

## 2. Context API

Use for: theme, locale, auth session, feature flags — values that change infrequently and are consumed widely.

**Avoid for:** high-frequency state (every keystroke, animation frames) or large objects where a subset of consumers change often. Every context consumer re-renders on every value change.

### Pattern

```tsx
// 1. Create typed context with a safe default
const ThemeContext = createContext<ThemeContextValue | null>(null)

// 2. Custom hook — never export raw context
export function useTheme() {
  const ctx = useContext(ThemeContext)
  if (!ctx) throw new Error('useTheme must be used within ThemeProvider')
  return ctx
}

// 3. Provider wraps the subtree that needs it
export function ThemeProvider({ children }: { children: ReactNode }) {
  const [theme, setTheme] = useState<'light' | 'dark'>('light')
  const value = useMemo(() => ({ theme, setTheme }), [theme])
  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>
}
```

**Memoize the context value** (`useMemo`) when the provider re-renders for reasons unrelated to the context. Without it, all consumers re-render with every parent render.

### Split contexts to reduce re-renders

```tsx
// ❌ One big context — any change rerenders all consumers
const AppContext = createContext({ user, theme, notifications })

// ✅ Separate contexts — each consumer only rerenders for its slice
const UserContext = createContext<User | null>(null)
const ThemeContext = createContext<Theme>('light')
const NotificationContext = createContext<Notification[]>([])
```

---

## 3. Zustand

Lightweight, no boilerplate, no Provider needed. Preferred for most new projects.

### Store creation

```ts
// store/useCounterStore.ts
import { create } from 'zustand'
import { devtools, persist } from 'zustand/middleware'

interface CounterState {
  count: number
  increment: () => void
  decrement: () => void
  reset: () => void
}

export const useCounterStore = create<CounterState>()(
  devtools(
    persist(
      (set) => ({
        count: 0,
        increment: () => set((state) => ({ count: state.count + 1 }), false, 'increment'),
        decrement: () => set((state) => ({ count: state.count - 1 }), false, 'decrement'),
        reset: () => set({ count: 0 }, false, 'reset'),
      }),
      { name: 'counter-storage' } // persists to localStorage
    )
  )
)
```

### Selecting state — avoid over-rendering

```tsx
// ❌ Subscribes to entire store — rerenders on any change
const store = useCounterStore()

// ✅ Subscribe to only what you need
const count = useCounterStore((state) => state.count)
const increment = useCounterStore((state) => state.increment)

// ✅ Multiple values — use shallow equality check
import { useShallow } from 'zustand/react/shallow'
const { count, decrement } = useCounterStore(
  useShallow((state) => ({ count: state.count, decrement: state.decrement }))
)
```

### Slices pattern (large stores)

```ts
// store/slices/cartSlice.ts
export interface CartSlice {
  items: CartItem[]
  addItem: (item: CartItem) => void
  removeItem: (id: string) => void
}

export const createCartSlice = (set: SetState<CartSlice>): CartSlice => ({
  items: [],
  addItem: (item) => set((state) => ({ items: [...state.items, item] })),
  removeItem: (id) => set((state) => ({ items: state.items.filter((i) => i.id !== id) })),
})

// store/index.ts
export const useStore = create<CartSlice & UserSlice>()((...args) => ({
  ...createCartSlice(...args),
  ...createUserSlice(...args),
}))
```

### Accessing store outside React

```ts
// Useful for event handlers, utilities, sagas
const { count, increment } = useCounterStore.getState()
useCounterStore.subscribe((state) => console.log('count changed to', state.count))
```

---

## 4. Redux Toolkit

Use when: large teams with Redux conventions, need time-travel debugging, complex cross-slice logic, or migrating an existing Redux app.

### Slice

```ts
// features/cart/cartSlice.ts
import { createSlice, PayloadAction } from '@reduxjs/toolkit'

const cartSlice = createSlice({
  name: 'cart',
  initialState: { items: [] as CartItem[], status: 'idle' as 'idle' | 'loading' | 'failed' },
  reducers: {
    addItem(state, action: PayloadAction<CartItem>) {
      state.items.push(action.payload) // Immer — direct mutation is safe
    },
    removeItem(state, action: PayloadAction<string>) {
      state.items = state.items.filter((i) => i.id !== action.payload)
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchCart.pending, (state) => { state.status = 'loading' })
      .addCase(fetchCart.fulfilled, (state, action) => {
        state.status = 'idle'
        state.items = action.payload
      })
      .addCase(fetchCart.rejected, (state) => { state.status = 'failed' })
  },
})

export const { addItem, removeItem } = cartSlice.actions
export default cartSlice.reducer
```

### Async thunk

```ts
export const fetchCart = createAsyncThunk('cart/fetch', async (userId: string) => {
  const res = await fetch(`/api/cart/${userId}`)
  if (!res.ok) throw new Error('Failed to fetch cart')
  return res.json() as Promise<CartItem[]>
})
```

### Typed hooks (set once, use everywhere)

```ts
// store/hooks.ts
import { TypedUseSelectorHook, useDispatch, useSelector } from 'react-redux'
import type { RootState, AppDispatch } from './store'

export const useAppDispatch = () => useDispatch<AppDispatch>()
export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector
```

### Selectors

```ts
// Memoized selector with reselect
import { createSelector } from '@reduxjs/toolkit'

export const selectCartItems = (state: RootState) => state.cart.items
export const selectCartTotal = createSelector(selectCartItems, (items) =>
  items.reduce((sum, item) => sum + item.price * item.quantity, 0)
)
```

---

## 5. TanStack Query (Server State)

Handles caching, background refetching, loading/error states, deduplication, and pagination — replacing all manual `useEffect`+`useState` data fetching.

### Setup

```tsx
// main.tsx
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5, // 5 minutes
      gcTime: 1000 * 60 * 10,   // 10 minutes
      retry: 1,
    },
  },
})

<QueryClientProvider client={queryClient}>
  <App />
</QueryClientProvider>
```

### Query keys

Treat query keys like a dependency array — they uniquely identify a query and determine when to refetch:

```ts
// Consistent key factory per feature
export const userKeys = {
  all: ['users'] as const,
  lists: () => [...userKeys.all, 'list'] as const,
  list: (filters: UserFilters) => [...userKeys.lists(), filters] as const,
  details: () => [...userKeys.all, 'detail'] as const,
  detail: (id: string) => [...userKeys.details(), id] as const,
}
```

### Basic query

```tsx
function UserProfile({ userId }: { userId: string }) {
  const { data, isPending, isError, error } = useQuery({
    queryKey: userKeys.detail(userId),
    queryFn: () => fetchUser(userId),
    enabled: !!userId,           // don't run until userId exists
    staleTime: 1000 * 60 * 10,  // override global default per query
  })

  if (isPending) return <Skeleton />
  if (isError) return <ErrorMessage error={error} />
  return <div>{data.name}</div>
}
```

### Mutations

```tsx
function UpdateUserForm({ user }: { user: User }) {
  const queryClient = useQueryClient()
  const mutation = useMutation({
    mutationFn: (updates: Partial<User>) => updateUser(user.id, updates),
    onSuccess: (updatedUser) => {
      // Update cache directly — no refetch needed
      queryClient.setQueryData(userKeys.detail(user.id), updatedUser)
      // Invalidate related list queries
      queryClient.invalidateQueries({ queryKey: userKeys.lists() })
    },
    onError: (error) => {
      toast.error(`Update failed: ${error.message}`)
    },
  })

  return (
    <button
      onClick={() => mutation.mutate({ name: 'New Name' })}
      disabled={mutation.isPending}
    >
      {mutation.isPending ? 'Saving...' : 'Save'}
    </button>
  )
}
```

### Optimistic updates

```tsx
const mutation = useMutation({
  mutationFn: toggleTodo,
  onMutate: async (todoId) => {
    // Cancel outgoing refetches to avoid overwriting optimistic update
    await queryClient.cancelQueries({ queryKey: todoKeys.all })

    // Snapshot current value for rollback
    const previous = queryClient.getQueryData(todoKeys.list())

    // Optimistically update
    queryClient.setQueryData(todoKeys.list(), (old: Todo[]) =>
      old.map((t) => (t.id === todoId ? { ...t, done: !t.done } : t))
    )

    return { previous } // returned as context
  },
  onError: (_err, _todoId, context) => {
    // Rollback on failure
    queryClient.setQueryData(todoKeys.list(), context?.previous)
  },
  onSettled: () => {
    // Always refetch after error or success to sync with server
    queryClient.invalidateQueries({ queryKey: todoKeys.all })
  },
})
```

### Infinite / paginated queries

```tsx
const { data, fetchNextPage, hasNextPage, isFetchingNextPage } = useInfiniteQuery({
  queryKey: ['posts', filters],
  queryFn: ({ pageParam }) => fetchPosts({ page: pageParam, ...filters }),
  initialPageParam: 1,
  getNextPageParam: (lastPage) => lastPage.nextPage ?? undefined,
})

// data.pages is an array of page results
const posts = data?.pages.flatMap((page) => page.items) ?? []
```

### Prefetching

```tsx
// Prefetch on hover — data is warm when the user navigates
function UserLink({ userId }: { userId: string }) {
  const queryClient = useQueryClient()
  return (
    <a
      onMouseEnter={() =>
        queryClient.prefetchQuery({
          queryKey: userKeys.detail(userId),
          queryFn: () => fetchUser(userId),
        })
      }
      href={`/users/${userId}`}
    >
      View Profile
    </a>
  )
}
```

### Next.js / SSR integration

```tsx
// Server component — prefetch for hydration
import { dehydrate, HydrationBoundary, QueryClient } from '@tanstack/react-query'

export default async function Page() {
  const queryClient = new QueryClient()
  await queryClient.prefetchQuery({
    queryKey: userKeys.list({}),
    queryFn: fetchUsers,
  })
  return (
    <HydrationBoundary state={dehydrate(queryClient)}>
      <UserList />
    </HydrationBoundary>
  )
}
```

---

## 6. Anti-Patterns

| ❌ Avoid | ✅ Do instead |
|---|---|
| `useEffect` + `useState` for data fetching | TanStack Query `useQuery` |
| Storing server responses in Zustand/Redux | Let TanStack Query own server state |
| Single massive context with all app state | Split by domain / update frequency |
| Selecting entire Zustand store | Select specific slices with equality check |
| Calling `queryClient.invalidateQueries` after every mutation | Use `onSuccess` to set data directly when response is available |
| `queryKey: ['users']` for different filters | Include all variables in the key: `['users', filters]` |
| Skipping `enabled` guard | Always gate queries on required params being present |

---

> **Rule of thumb:** If it comes from an API, TanStack Query owns it. If the user created it (form state, UI toggles, selected tab), client state owns it. They almost never overlap.
