# 🏛️ MEMARLIQ SƏNƏDI

## Üç qatlı memarlıq

```
┌─────────────────────────────────────────────────────┐
│  📱 PRESENTATION LAYER (Təqdimat qatı)              │
│  React + Vite (5173) | R Shiny (3838)               │
└─────────────────────────────────────────────────────┘
                         ↓ REST API
┌─────────────────────────────────────────────────────┐
│  ⚙️ BUSINESS LOGIC LAYER (Biznes məntiq qatı)       │
│  Node.js + Express (3001)                           │
│  ┌─ CORE (dəyişməz)                                 │
│  ├─ DOMAIN (dəyişən: construction, pharmacy, ...)   │
│  └─ SHARED (ortaq: AI, files, notifications)        │
└─────────────────────────────────────────────────────┘
                         ↓ SQL
┌─────────────────────────────────────────────────────┐
│  💾 DATA LAYER (Məlumat qatı)                       │
│  PostgreSQL 17 (5432) | File Storage | Redis*       │
└─────────────────────────────────────────────────────┘
```

## Domen-dəyişən prinsipi

```javascript
// backend/src/server.js
const domain = process.env.DOMAIN || 'construction';
require(`./domain/${domain}/routes`)(app);
```

Domen dəyişmək üçün sadəcə `.env` faylında:
```
DOMAIN=pharmacy  # və ya logistics, education, retail
```

## Core / Domain / Shared ayrımı

### Core (heç vaxt dəyişmir)
- Autentifikasiya (JWT)
- Rol-əsaslı icazə (RBAC)
- Loglama və auditing
- Baza bağlantısı
- API gateway
- Health-check

### Domain (sahəyə görə dəyişir)
TTİS (construction) üçün:
- Layihələr (projects)
- Smetalar (budgets)
- Müqavilələr (contracts)
- Briqadalar (teams)
- Materiallar (materials)
- Avadanlıq (equipment)
- Tərəddadlar (tasks)
- Monitorinq (monitoring)
- Hesabatlar (reports)

### Shared (az-az dəyişir)
- Claude AI SDK wrapper
- Fayl yükləmə / endirmə
- Email / SMS / webhook
- PDF eksport
- Cədvəl komponenti
- Axtarış/filter

## Məlumat axını nümunəsi

**Ssenari:** İstifadəçi smetaya Claude AI-dan təhlil istəyir.

1. React → `POST /api/v1/budgets/:id/analyze`
2. Express middleware: JWT auth → rate limit → logging
3. `domain/construction/controllers/budgetController.js`:
   - Smeta məlumatını DB-dən oxu
   - `shared/ai/claude.js` → sistem promptu + məlumat göndər
   - Cavab al və formatla
4. DB-də təhlil qeydini saxla (analiz tarixçəsi)
5. React → təhlili göstər

## İstinadlar

- [Dərs 01: Layihə Strukturu](../docs/lessons/Dərs_01_Layihə_Strukturu.html)
- [Dərs 02: PostgreSQL](../docs/lessons/Dərs_02_PostgreSQL.html) *(növbəti)*
