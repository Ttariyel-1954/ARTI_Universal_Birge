#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# SETUP.SH — Claude Universal Agent layihəsinin ilkin quraşdırma
# İstifadə: bash scripts/setup.sh
# ═══════════════════════════════════════════════════════════════

set -e  # xəta olarsa dayan

echo "🏗️  Claude Universal Agent — ilkin quraşdırma"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ═══ Addım 1: Qovluq strukturunun yoxlanması ═══
echo ""
echo "📂 Addım 1: Qovluq strukturunu yoxlayırıq..."

REQUIRED_DIRS=(
  "backend/src/core"
  "backend/src/domain/construction"
  "backend/src/shared"
  "frontend/src/components"
  "dashboard/modules"
  "database/schemas"
  "ai/prompts"
  "deploy/pm2"
  "docs/lessons"
)

for dir in "${REQUIRED_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    echo "  ✅ $dir"
  else
    echo "  ❌ $dir — çatışmır!"
    exit 1
  fi
done

# ═══ Addım 2: .env faylının yaradılması ═══
echo ""
echo "🔐 Addım 2: .env faylı..."
if [ ! -f ".env" ]; then
  cp .env.example .env
  echo "  ✅ .env yaradıldı (.env.example-dən)"
  echo "  ⚠️  Unutmayın: .env faylına API açarlarınızı əlavə edin!"
else
  echo "  ℹ️  .env artıq mövcuddur — toxunulmadı"
fi

# ═══ Addım 3: Git inisializasiyası ═══
echo ""
echo "📦 Addım 3: Git repozitoriyası..."
if [ ! -d ".git" ]; then
  git init -q
  git branch -M main
  echo "  ✅ Git repozitoriyası yaradıldı"
else
  echo "  ℹ️  Git artıq inisializə olunub"
fi

# ═══ Addım 4: Node.js və PostgreSQL yoxlaması ═══
echo ""
echo "🔍 Addım 4: Ətraf mühit yoxlaması..."

# Node.js
if command -v node &> /dev/null; then
  NODE_VERSION=$(node -v)
  echo "  ✅ Node.js: $NODE_VERSION"
else
  echo "  ❌ Node.js quraşdırılmayıb — brew install node"
fi

# npm
if command -v npm &> /dev/null; then
  NPM_VERSION=$(npm -v)
  echo "  ✅ npm: $NPM_VERSION"
fi

# PostgreSQL
if command -v psql &> /dev/null; then
  PSQL_VERSION=$(psql --version | awk '{print $3}')
  echo "  ✅ PostgreSQL: $PSQL_VERSION"
else
  echo "  ⚠️  PostgreSQL quraşdırılmayıb (Dərs 2-də göstəriləcək)"
fi

# R
if command -v R &> /dev/null; then
  R_VERSION=$(R --version | head -1 | awk '{print $3}')
  echo "  ✅ R: $R_VERSION"
else
  echo "  ⚠️  R quraşdırılmayıb (Dərs 5-də lazım olacaq)"
fi

# ═══ Yekun ═══
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ İlkin quraşdırma tamamlandı!"
echo ""
echo "📖 Növbəti addım:"
echo "   → docs/lessons/Dərs_01_Layihə_Strukturu.html faylını brauzerdə açın"
echo ""
