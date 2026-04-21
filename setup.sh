#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# ARTI Universal Birgə — macOS Avtomatik Quraşdırma
# Müəllif: Talıbov Tariyel İsmayıl oğlu, ARTI
# ═══════════════════════════════════════════════════════════════
set -e

# Rənglər
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info()    { echo -e "${BLUE}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warn()    { echo -e "${YELLOW}⚠️  $1${NC}"; }
fail()    { echo -e "${RED}❌ $1${NC}"; exit 1; }

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  ARTI Universal Birgə — Quraşdırma Skripti (macOS)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

# ═══ 1. OS yoxlama ═══
info "Əməliyyat sistemi yoxlanılır..."
if [[ "$(uname)" != "Darwin" ]]; then
  fail "Bu skript yalnız macOS üçündür. Linux/Windows üçün INSTALL.md-ə baxın."
fi
success "macOS aşkarlandı: $(sw_vers -productVersion)"

# ═══ Layihə qovluğu ═══
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
info "Layihə qovluğu: $SCRIPT_DIR"

# ═══ 2. Homebrew ═══
info "Homebrew yoxlanılır..."
if command -v brew &>/dev/null; then
  success "Homebrew mövcuddur: $(brew --version | head -1)"
else
  warn "Homebrew tapılmadı. Quraşdırılır..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  success "Homebrew quraşdırıldı"
fi

# ═══ 3. PostgreSQL ═══
info "PostgreSQL yoxlanılır..."
if command -v psql &>/dev/null; then
  PG_VERSION=$(psql --version | head -1)
  success "PostgreSQL mövcuddur: $PG_VERSION"
else
  warn "PostgreSQL tapılmadı. Quraşdırılır..."
  brew install postgresql@18
  success "PostgreSQL quraşdırıldı"
fi

# PostgreSQL xidmətini başlat
info "PostgreSQL xidməti yoxlanılır..."
if pg_isready -q 2>/dev/null; then
  success "PostgreSQL işləyir"
else
  warn "PostgreSQL işləmir. Başladılır..."
  brew services start postgresql@18 2>/dev/null || brew services start postgresql 2>/dev/null || true
  sleep 2
  if pg_isready -q 2>/dev/null; then
    success "PostgreSQL başladıldı"
  else
    warn "PostgreSQL başlada bilmədi — əl ilə yoxlayın: brew services start postgresql@18"
  fi
fi

# ═══ 4. Database istifadəçisi ═══
info "Database istifadəçisi yoxlanılır..."
CURRENT_USER=$(whoami)
if psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$CURRENT_USER'" postgres 2>/dev/null | grep -q 1; then
  success "Database istifadəçisi mövcuddur: $CURRENT_USER"
else
  warn "Database istifadəçisi yaradılır: $CURRENT_USER"
  createuser -s "$CURRENT_USER" 2>/dev/null || true
  success "Database istifadəçisi yaradıldı"
fi

# ═══ 5. R ═══
info "R yoxlanılır..."
if command -v Rscript &>/dev/null; then
  R_VERSION=$(Rscript --version 2>&1 | head -1)
  success "R mövcuddur: $R_VERSION"
else
  warn "R tapılmadı. Quraşdırılır..."
  brew install r
  success "R quraşdırıldı"
fi

# ═══ 6. RStudio ═══
info "RStudio yoxlanılır..."
if [ -d "/Applications/RStudio.app" ]; then
  success "RStudio mövcuddur"
else
  warn "RStudio tapılmadı. Quraşdırılır..."
  brew install --cask rstudio
  success "RStudio quraşdırıldı"
fi

# ═══ 7. Database yaratma ═══
info "Database yoxlanılır..."
if psql -lqt 2>/dev/null | cut -d \| -f 1 | grep -qw arti_construction; then
  success "arti_construction database mövcuddur"
else
  warn "arti_construction database yaradılır..."
  createdb arti_construction
  success "Database yaradıldı"
fi

# ═══ 8. Dump-dan bərpa ═══
DUMP_FILE="$SCRIPT_DIR/database/backup/arti_construction_full.sql"
if [ -f "$DUMP_FILE" ]; then
  # Yoxla: əgər cədvəllər artıq mövcuddursa, bərpa etmə
  TABLE_COUNT=$(psql -tAc "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema NOT IN ('pg_catalog','information_schema')" arti_construction 2>/dev/null || echo "0")
  if [ "$TABLE_COUNT" -gt 5 ] 2>/dev/null; then
    success "Database artıq doldurulub ($TABLE_COUNT cədvəl)"
  else
    info "Database dump-dan bərpa edilir..."
    psql arti_construction < "$DUMP_FILE" 2>/dev/null
    success "Database bərpa edildi"
  fi
else
  warn "Dump faylı tapılmadı: $DUMP_FILE"
fi

# ═══ 9. R paketləri ═══
info "R paketləri yoxlanılır..."
Rscript -e '
required <- c("shiny","bs4Dash","DBI","RPostgres","pool","dplyr",
              "plotly","DT","leaflet","httr2","jsonlite","shinyjs",
              "waiter","shinycssloaders","digest","bcrypt","yaml")
missing <- required[!required %in% installed.packages()[,"Package"]]
if (length(missing) > 0) {
  cat("Quraşdırılır:", paste(missing, collapse=", "), "\n")
  install.packages(missing, repos="https://cloud.r-project.org", quiet=TRUE)
  still_missing <- missing[!missing %in% installed.packages()[,"Package"]]
  if (length(still_missing) > 0) {
    cat("XƏTA: quraşdırıla bilmədi:", paste(still_missing, collapse=", "), "\n")
    quit(status=1)
  }
}
cat("OK\n")
' && success "Bütün R paketləri quraşdırılıb" || warn "Bəzi R paketləri quraşdırıla bilmədi — əl ilə yoxlayın"

# ═══ 10. config.yml ═══
CONFIG_FILE="$SCRIPT_DIR/shared/config.yml"
if [ -f "$CONFIG_FILE" ]; then
  success "config.yml mövcuddur"
else
  warn "config.yml yaradılır..."
  mkdir -p "$SCRIPT_DIR/shared"
  cat > "$CONFIG_FILE" << 'YAML'
database:
  mode: smart
  localhost:
    host: localhost
    port: 5432
    dbname: arti_construction
    user: royatalibova
    password: ""
  pool_min: 2
  pool_max: 10
  connect_timeout_sec: 5

app:
  title: "ARTI Universal Platform"
  currency: AZN
  timezone: Asia/Baku

uploads:
  directory: "~/Desktop/ARTI_Universal_Birgə/uploads"
  max_file_size_mb: 5
  allowed_types:
    - image/jpeg
    - image/png
    - application/pdf
  allowed_extensions:
    - jpg
    - jpeg
    - png
    - pdf
YAML
  success "config.yml yaradıldı"
fi

# ═══ 11. Uploads qovluqları ═══
info "Uploads qovluqları yoxlanılır..."
for sub in inspections complaints daily_reports material_movements thumbnails; do
  mkdir -p "$SCRIPT_DIR/uploads/$sub"
done
success "Uploads qovluqları hazırdır"

# ═══ 12. .env.example ═══
ENV_EXAMPLE="$SCRIPT_DIR/.env.example"
if [ ! -f "$ENV_EXAMPLE" ]; then
  cat > "$ENV_EXAMPLE" << 'EOF'
# ARTI Universal Birgə — Mühit Dəyişənləri
# Bu faylı shared/.env olaraq kopyalayın və dəyərləri doldurun

# Claude AI API
ANTHROPIC_API_KEY=sk-ant-...
ANTHROPIC_MODEL=claude-sonnet-4-5

# Database (config.yml-dan da oxunur)
DB_HOST=localhost
DB_PORT=5432
DB_NAME=arti_construction
DB_USER=royatalibova
DB_PASSWORD=
EOF
  success ".env.example yaradıldı"
else
  success ".env.example mövcuddur"
fi

# ═══ 13. Yekun statistika ═══
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Yekun Statistika${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"

if pg_isready -q 2>/dev/null; then
  USERS=$(psql -tAc "SELECT COUNT(*) FROM audit.users" arti_construction 2>/dev/null || echo "?")
  PROJECTS=$(psql -tAc "SELECT COUNT(*) FROM construction.projects" arti_construction 2>/dev/null || echo "?")
  MATERIALS=$(psql -tAc "SELECT COUNT(*) FROM inventory.materials" arti_construction 2>/dev/null || echo "?")
  echo -e "  İstifadəçilər:  ${GREEN}$USERS${NC}"
  echo -e "  Layihələr:      ${GREEN}$PROJECTS${NC}"
  echo -e "  Materiallar:    ${GREEN}$MATERIALS${NC}"
else
  warn "PostgreSQL işləmir — statistika göstərilə bilmir"
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Quraşdırma tamamlandı!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "Növbəti addımlar:"
echo "  1. RStudio açın"
echo "  2. platform/shiny/app.R faylını açın"
echo "  3. Run App düyməsinə basın"
echo "  4. Brauzer: http://localhost:3838"
echo ""
echo "  Giriş: admin / admin123"
echo ""
