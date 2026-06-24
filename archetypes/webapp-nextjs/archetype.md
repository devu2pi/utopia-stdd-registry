---
name: webapp-nextjs
description: >
  Arquetipo estándar para aplicaciones web con Next.js 14+, Supabase, Tailwind y TypeScript.
  Usar como base para SPA, SSR, o aplicaciones fullstack con backend integrado.
version: v1
skills:
  - openspec/v1
  - tdd-extension/v1
  - architecture/v1
  - stack/v1
  - code-review/v1
---

# Arquetipo: webapp-nextjs

Aplicación web moderna con Next.js App Router, Supabase y TypeScript.

## Cuándo usar este arquetipo

- Aplicación web con UI interactiva
- Necesita auth, base de datos, storage
- Equipo pequeño-mediano (1–8 devs)
- Time-to-market prioritario sobre infraestructura custom

## Estructura del proyecto

```
proyecto/
├── src/
│   ├── app/                    ← App Router (layouts, pages, loading, error)
│   │   ├── (auth)/             ← route group para páginas de auth
│   │   ├── (dashboard)/        ← route group para app autenticada
│   │   └── api/                ← API routes (webhooks, integraciones externas)
│   ├── components/
│   │   ├── ui/                 ← shadcn/ui components
│   │   └── features/           ← componentes de dominio
│   ├── lib/
│   │   ├── actions/            ← server actions
│   │   ├── queries/            ← data fetching functions
│   │   ├── supabase/           ← clients (server, client, middleware)
│   │   └── utils/              ← helpers puros
│   ├── hooks/                  ← custom React hooks
│   └── types/                  ← TypeScript types
├── tests/
│   ├── unit/                   ← Vitest
│   └── e2e/                    ← Playwright
├── openspec/                   ← workflow SDD
│   ├── project.md
│   ├── specs/
│   └── changes/
├── .agent/
│   └── config.yaml             ← registry config
├── .env.example
├── next.config.ts
├── tailwind.config.ts
└── tsconfig.json
```

## Setup inicial

```bash
# 1. Instalar OpenSpec
npx @fission-ai/openspec@latest init --tools claude

# 2. Instalar dependencias base
npm install
npm install @supabase/supabase-js @supabase/ssr
npm install zustand @tanstack/react-query
npm install react-hook-form zod @hookform/resolvers
npm install -D vitest @vitejs/plugin-react playwright

# 3. Setup Supabase
npx supabase init

# 4. Poblar openspec/project.md con contexto del proyecto
```

## Variables de entorno requeridas

```bash
# .env.example
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=     # solo server-side

# Opcionales según proyecto
RESEND_API_KEY=
MERCADOPAGO_ACCESS_TOKEN=
ANTHROPIC_API_KEY=
```

## Scripts npm base

```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "typecheck": "tsc --noEmit",
    "lint": "eslint . --ext .ts,.tsx",
    "test:unit": "vitest run",
    "test:unit:watch": "vitest",
    "test:e2e": "playwright test",
    "test:coverage": "vitest run --coverage"
  }
}
```

---

## Placeholder — otros arquetipos disponibles

- `api-fastapi` → API REST Python con FastAPI + PostgreSQL
- `fullstack` → Next.js + FastAPI separados con shared types
- `[ ] mobile-expo` → pendiente de definición
- `[ ] data-pipeline` → pendiente de definición
