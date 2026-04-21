# ARTI Universal Birgə Layihə

**Tikinti idarəetmə platforması** — ARTI Təmir-Tikinti İdarəsi üçün hazırlanmış vahid sistem.

İki müstəqil layihənin birləşməsindən yaranıb:
- **ARTI Universal Platform** (Mərhələ 1) — R Shiny əsaslı dashboard və regional mobil tətbiq
- **Claude Modei Təmir-Tikinti** (Mərhələ 2) — Node.js + React full-stack genişlənmə

## Mərhələlər

| Mərhələ | Texnologiya | Status |
|---------|-------------|--------|
| 1 — Dashboard + Regional | R Shiny, PostgreSQL | ✅ İşləyir |
| 2 — Full-stack API + UI | Node.js, React, Docker | 🔧 İnkişafda |

## Qovluq Strukturu

```
ARTI_Universal_Birgə/
├── platform/
│   ├── shiny/app.R              # Dashboard (port 3838)
│   └── regional/app.R           # Regional mobil app (port 3839)
├── backend/                     # Node.js Express API (port 3001)
├── frontend/                    # React + Vite (port 5173)
├── database/
│   ├── construction/            # ARTI Universal SQL sxemləri
│   ├── schemas/                 # Claude Modei SQL sxemləri
│   ├── seeds/                   # Nümunə data
│   ├── migrations/
│   └── backup/
│       └── arti_construction_full.sql  # Tam DB dump (2.1 MB)
├── shared/
│   └── config.yml               # Mərkəzi konfiqurasiya
├── uploads/                     # Fayl yükləmələri
├── docs/                        # Sənədləşdirmə
├── deploy/                      # Docker, Nginx, PM2
├── scripts/
├── config/
├── docker-compose.yml
├── setup.sh                     # macOS avtomatik quraşdırma
├── INSTALL.md                   # Ətraflı quraşdırma təlimatı
└── .env.example
```

## Tələblər

- **PostgreSQL** 14+ (test edilib: 18)
- **R** 4.3+
- **RStudio** (tövsiyə olunur)
- **Node.js** 18+ (Mərhələ 2 üçün)
- **Git**

## Sürətli Başlanğıc (macOS)

```bash
# 1. Reponu klonla
git clone <repo-url> ~/Desktop/ARTI_Universal_Birgə
cd ~/Desktop/ARTI_Universal_Birgə

# 2. Avtomatik quraşdırma
chmod +x setup.sh
./setup.sh

# 3. Dashboard-u aç
# RStudio → platform/shiny/app.R → Run App
```

Ətraflı təlimat üçün bax: [INSTALL.md](INSTALL.md)

## Test Hesabları

| İstifadəçi | Şifrə | Rol |
|-------------|--------|-----|
| `admin` | `admin123` | Administrator |
| `rw_01` ... `rw_10` | `regional123` | Regional İşçi |

## Portlar

| Xidmət | Port | Qeyd |
|--------|------|------|
| PostgreSQL | 5432 | Database |
| Dashboard | 3838 | R Shiny əsas panel |
| Regional App | 3839 | R Shiny mobil tətbiq |
| Backend API | 3001 | Node.js Express (Mərhələ 2) |
| Frontend | 5173 | React + Vite dev server (Mərhələ 2) |

## Texnologiyalar

**Mərhələ 1 (İşləyən):**
R, Shiny, bs4Dash, PostgreSQL, DBI, RPostgres, pool, dplyr, plotly, DT, leaflet, httr2, jsonlite, shinyjs, waiter, shinycssloaders, bcrypt, yaml

**Mərhələ 2 (İnkişafda):**
Node.js, Express, React, Vite, Docker, Nginx, PM2

## Müəllif

**Talıbov Tariyel İsmayıl oğlu**
ARTI Müavin Direktor, Bakı, Azərbaycan
