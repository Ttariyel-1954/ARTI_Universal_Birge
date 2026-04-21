# CLAUDE CODE TƏLİMATI — ARTI_Universal_Birgə layihəsini tamamla

Sən Claude Code-san və mənə bu layihənin qalan hissələrini tamamlamaqda kömək edirsən. Mən Tariyel müəllimiəm — ARTI Deputy Director, Bakıda işləyirəm, Intel Mac istifadə edirəm, `royatalibova` istifadəçi adım, PostgreSQL 18 lokal qurulub.

## KONTEKST

`~/Desktop/ARTI_Universal_Birgə/` qovluğuna **iki ayrı layihə** birləşdirilib:

1. **ARTI_Universal_Platform** (R Shiny — işləyən sistem)
   - Dashboard + Regional mobile app
   - PostgreSQL database (arti_construction)
   - 43 audit qeyd, real test edilmiş
   - GitHub: `Ttariyel-1954/ARTI_Universal_Projekt`

2. **Claude_Modei_Təmir_tikinti** (Node.js + React — gələcək genişlənmə)
   - Backend: Express.js REST API
   - Frontend: React + Vite
   - Docker-compose skeleti

## HAZIRKI VƏZİYYƏT

```
~/Desktop/ARTI_Universal_Birgə/          (3.8 MB — təmiz, node_modules-siz)
├── platform/
│   ├── shiny/app.R                       (~1900 sətir — dashboard)
│   └── regional/app.R                    (~2500 sətir — mobile)
├── backend/ (38 fayl, ~172 KB — Node.js, package.json var)
├── frontend/ (42 fayl, ~364 KB — React, package.json var)
├── database/
│   ├── construction/ (13 SQL fayl — ARTI_Universal schemas)
│   ├── schemas/ (6 SQL — Claude_Modei)
│   ├── seeds/ (2 SQL — sample data)
│   ├── migrations/
│   └── backup/
│       └── arti_construction_full.sql   (2.1 MB — tam dump)
├── dashboard/ (Claude_Modei Shiny — boş)
├── ai/ (Claude prompts — boş)
├── deploy/ (Docker, Nginx, PM2 skeleti — boş)
├── docs/
│   ├── ARTI_Istifade_Telimati.html      (69 KB — 14 fəsil)
│   ├── ARCHITECTURE.md
│   └── claude_modei/ (dərslər)
├── shared/
│   └── config.yml                        (ARTI_Universal_Platform yolu ilə!)
├── uploads/ (boş alt qovluqlarla)
├── scripts/
├── config/
├── docker-compose.yml
├── .env.example
```

## SENİN TAPŞIRIQLARIN

Aşağıdakı 7 mərhələni ardıcıl yerinə yetir. Hər mərhələnin sonunda status bildir (✅ OK / ⚠️ problem).

### MƏRHƏLƏ 1: R kod yollarını dinamik et

**Problem:** `platform/shiny/app.R` və `platform/regional/app.R` hazırda köhnə hardcoded yollar istifadə edir:

```r
CONFIG_PATH <- path.expand("~/Desktop/ARTI_Universal_Platform/shared/config.yml")
env_path <- path.expand("~/Desktop/ARTI_Universal_Platform/shared/.env")
ARCHIVE_DIR <- path.expand("~/Desktop/ARTI_Universal_Platform/docs/Sorğu_nəticələri")
shiny::addResourcePath("uploads", path.expand("~/Desktop/ARTI_Universal_Platform/uploads"))
```

**Həll:** `ARTI_Universal_Platform` → `ARTI_Universal_Birgə` əvəz et, həm də **daha yaxşı**: dinamik root axtarışı istifadə et ki, qovluq adı dəyişsə də işləsin.

Aşağıdakı kodu hər iki app.R-in başında, `suppressPackageStartupMessages` blokundan **SONRA**, hər hansı CONFIG_PATH təyinindən **ƏVVƏL** yerləşdir:

```r
# ═══ Dinamik kök qovluq (hansı adla qovluqda olsa da işləyir) ═══
# shiny/app.R və regional/app.R → platform/shiny/ və platform/regional/ içərisində
# Kök: iki yuxarı qovluq

find_project_root <- function() {
  # Hazırki app.R-in yerləşdiyi qovluq
  script_dir <- tryCatch({
    if (!is.null(sys.frames()[[1]]$ofile)) {
      dirname(normalizePath(sys.frames()[[1]]$ofile))
    } else if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
      dirname(rstudioapi::getSourceEditorContext()$path)
    } else {
      getwd()
    }
  }, error = function(e) getwd())
  
  # platform/shiny/ və platform/regional/-dan iki səviyyə yuxarı
  # Kök qovluqda shared/config.yml olmalıdır
  candidate <- normalizePath(file.path(script_dir, "..", ".."), mustWork = FALSE)
  if (file.exists(file.path(candidate, "shared", "config.yml"))) {
    return(candidate)
  }
  
  # Fallback: getwd()-dən yuxarı axtar
  current <- getwd()
  for (i in 1:5) {
    if (file.exists(file.path(current, "shared", "config.yml"))) {
      return(normalizePath(current))
    }
    current <- dirname(current)
  }
  
  # Son fallback
  return(path.expand("~/Desktop/ARTI_Universal_Birgə"))
}

PROJECT_ROOT <- find_project_root()
message("📂 Project root: ", PROJECT_ROOT)
```

**Sonra** bütün hardcoded yolları belə əvəz et:

```r
# KÖHNƏ:
CONFIG_PATH <- path.expand("~/Desktop/ARTI_Universal_Platform/shared/config.yml")
# YENİ:
CONFIG_PATH <- file.path(PROJECT_ROOT, "shared", "config.yml")

# KÖHNƏ:
env_path <- path.expand("~/Desktop/ARTI_Universal_Platform/shared/.env")
# YENİ:
env_path <- file.path(PROJECT_ROOT, "shared", ".env")

# KÖHNƏ:
shiny::addResourcePath("uploads", path.expand("~/Desktop/ARTI_Universal_Platform/uploads"))
# YENİ:
shiny::addResourcePath("uploads", file.path(PROJECT_ROOT, "uploads"))

# KÖHNƏ:
ARCHIVE_DIR <- path.expand("~/Desktop/ARTI_Universal_Platform/docs/Sorğu_nəticələri")
# YENİ:
ARCHIVE_DIR <- file.path(PROJECT_ROOT, "docs", "Sorğu_nəticələri")
```

**Hər dəyişiklikdən sonra:**
1. Backup yarat: `cp app.R app.R.before_paths_$(date +%s)`
2. Syntax yoxla: `Rscript -e 'parse(file="app.R")'`
3. ✅ OK görməsəm, geri qayıt

### MƏRHƏLƏ 2: shared/config.yml-i yenilə

Hazırki config.yml-da uploads yolu:
```yaml
uploads:
  directory: "~/Desktop/ARTI_Universal_Platform/uploads"
```

Dəyişdir:
```yaml
uploads:
  directory: "~/Desktop/ARTI_Universal_Birgə/uploads"
```

Həmçinin istifadəçi adı `royatalibova` olduğundan əmin ol.

### MƏRHƏLƏ 3: README.md yarat

`~/Desktop/ARTI_Universal_Birgə/README.md` yarat (yoxdursa və ya mövcud 748 bayt stub-dırsa). Azərbaycan dilində, professional, Markdown formatda. İçərik:

- Layihə haqqında (2 layihənin birləşməsi)
- Mərhələlər (Mərhələ 1: R Shiny, Mərhələ 2: Full-stack)
- Qovluq strukturu
- Tələblər və sürətli başlanğıc
- Test hesabları (admin/admin123, rw_01…rw_10/regional123)
- Portlar cədvəli (5432, 3838, 3839, 3001, 5173)
- Texnologiyalar

### MƏRHƏLƏ 4: INSTALL.md yarat

Tam quraşdırma təlimatı (Mac + Windows + Linux üçün) Azərbaycan dilində:

1. Homebrew/Chocolatey/apt
2. PostgreSQL quraşdırma
3. R + RStudio
4. Git clone
5. Database yaratmaq və dump-dan bərpa (database/backup/arti_construction_full.sql)
6. R paketləri (shiny, bs4Dash, DBI, RPostgres, pool, dplyr, plotly, DT, leaflet, httr2, jsonlite, shinyjs, waiter, shinycssloaders, digest, bcrypt, yaml)
7. config.yml konfiqurasiyası
8. Dashboard işə salma (RStudio → platform/shiny/app.R → Run App)
9. Regional arxa planda
10. Troubleshooting (port məşğul, PostgreSQL işləmir, R paket qura bilmir)

### MƏRHƏLƏ 5: setup.sh yarat (macOS üçün avtomatik)

Bash script yarat ki, bütün quraşdırmanı avtomatik etsin:
1. OS yoxlama (yalnız macOS)
2. Homebrew yoxla/qur
3. PostgreSQL yoxla/qur (`brew install postgresql@18`, `brew services start`)
4. `createuser -s $(whoami)` (əgər yoxdursa)
5. R yoxla/qur
6. RStudio yoxla/qur
7. Database yarat (`createdb arti_construction`)
8. Dump-dan bərpa et (`psql arti_construction < database/backup/arti_construction_full.sql`)
9. R paketləri qur
10. config.yml yarat (əgər yoxdursa)
11. uploads/ alt qovluqları yarat
12. .env.example əlavə et
13. Yekun statistika (user sayı, project sayı, material sayı)
14. İstifadəçiyə növbəti addımları göstər

Set `set -e`, rəngli çıxış (GREEN/RED/YELLOW/BLUE), hər addımda ✅/⚠️ status göstər.

### MƏRHƏLƏ 6: Test və yoxlama

**6.1 Syntax testləri:**
```bash
cd ~/Desktop/ARTI_Universal_Birgə
Rscript -e 'parse(file="platform/shiny/app.R"); cat("✅ shiny/app.R OK\n")'
Rscript -e 'parse(file="platform/regional/app.R"); cat("✅ regional/app.R OK\n")'
bash -n setup.sh && echo "✅ setup.sh OK"
```

**6.2 R paket yoxlaması:**
```bash
Rscript -e 'required <- c("shiny","bs4Dash","DBI","RPostgres","pool","dplyr","plotly","DT","leaflet","httr2","jsonlite","shinyjs","waiter","shinycssloaders","digest","bcrypt","yaml"); missing <- required[!required %in% installed.packages()[,"Package"]]; if(length(missing)==0) cat("✅ Bütün R paketləri\n") else cat("❌ Çatışmır:", paste(missing, collapse=", "), "\n")'
```

**6.3 Dashboard canlı test (ehtiyatlı — RStudio istifadəçi açıq olmalıdır):**
Dashboard-u əllə açmaq lazımdır (RStudio-da), ona görə bu mərhələdə yalnız **syntax və config yoxlaması**. Konkret istifadəçi testini mənə saxla.

**6.4 Database yoxla:**
```bash
psql arti_construction -c "SELECT 
  (SELECT COUNT(*) FROM audit.users) AS users,
  (SELECT COUNT(*) FROM construction.projects) AS projects,
  (SELECT COUNT(*) FROM inventory.materials) AS materials,
  (SELECT COUNT(*) FROM audit.query_log) AS audit_log;"
```

### MƏRHƏLƏ 7: GitHub push (isteğe bağlı — məndən soruş)

`~/Desktop/ARTI_Universal_Birgə` yeni repo olacaqmı, yoxsa mövcud `ARTI_Universal_Projekt`-i əvəz edəcək?

**Məndən soruş** və cavabımı gözlə. Mənim cavabıma görə:

**A — Yeni repo:** GitHub-da yeni repo yaradılacaq (mən əl ilə edim). Sən yalnız lokal git init et:
```bash
cd ~/Desktop/ARTI_Universal_Birgə
git init
git add .
git commit -m "feat: initial commit - birgə layihə (R Shiny + Node.js + React)"
```
Sonra mənə göstər, mən remote əlavə edib push edəcəyəm.

**B — Mövcud repo-nu əvəz et:** Köhnə ARTI_Universal_Projekt-ı force push ilə yenilə.

## VACİB QAYDALAR

### Hər dəyişiklikdən əvvəl:
- ✅ **Backup yarat**: `cp file.R file.R.before_taskname_$(date +%s)`
- ✅ **Syntax yoxla**: Hər R faylını `Rscript -e 'parse(file="...")'` ilə

### Hər Python/sed əməliyyatından sonra:
- ✅ Nəticəni `grep` ilə təsdiqlə
- ✅ Fayl sayı/ölçüsü loglu göstər

### Xəta halında:
- ❌ Dərhal dayan
- ❌ Backup-dan geri qayıt
- ❌ Mənə məlumat ver (hansı xəta, hansı sətir)

### İstifadə olunan tonal:
- Azərbaycan dili (intefeys, izah, xəta mesajları)
- "Tariyel müəllim" xitabı
- 🟢 TERMINAL və 🔵 NÜMUNƏ KOD markerləri
- Hər addım sonunda ✅/❌ status
- Əvvəl plan, sonra icra

### İstifadə olunmayan şeylər:
- ❌ `rm -rf` risksiz xaricdə
- ❌ `sudo` (çalışan user adi hüquqları ilə hər şey etməlidir)
- ❌ Köhnə `ARTI_Universal_Platform` qovluğuna toxunma — o, yaltaq orijinal olaraq qalsın
- ❌ Claude_Modei_Təmir_tikinti qovluğuna toxunma — o da orijinal qalsın

## YEKUN RAPORT

Bütün 6 (və ya 7) mərhələ bitdikdən sonra mənə belə yekun rapor ver:

```
═══════════════════════════════════════════
ARTI_Universal_Birgə — Yekun Rapor
═══════════════════════════════════════════

Mərhələ 1 (Path düzəltmələri):     ✅/❌
Mərhələ 2 (config.yml):             ✅/❌
Mərhələ 3 (README.md):              ✅/❌
Mərhələ 4 (INSTALL.md):             ✅/❌
Mərhələ 5 (setup.sh):               ✅/❌
Mərhələ 6 (Test):                   ✅/❌
Mərhələ 7 (GitHub):                 ⏸ (sənin cavabını gözləyirəm)

Yaradılan fayllar:
  - README.md (X KB)
  - INSTALL.md (Y KB)
  - setup.sh (Z KB)
  - .gitignore (W KB)

Dəyişdirilmiş fayllar:
  - platform/shiny/app.R (path fixes)
  - platform/regional/app.R (path fixes)
  - shared/config.yml (uploads path)

Yoxlama nəticələri:
  - R syntax: ✅
  - Bash syntax: ✅
  - R paketləri: ✅ hamısı quraşdırılıb
  - Database: X users, Y projects, Z materials

Növbəti addımlar (sənin üçün):
  1. RStudio → platform/shiny/app.R → Run App
  2. Dashboard test et
  3. Regional app arxa planda işə sal
  4. GitHub repo qərarı ver (A/B)
```

## BAŞLAYIN

Plan aydındırsa, **birinci mərhələdən başla**. Hər mərhələnin əvvəlində qısa plan göstər, sonra icra et, sonra nəticəni ver. Sonunda növbəti mərhələyə keçmək üçün məndən razılıq istə (`Davam edim?` sualı).

Uğurlar! 🚀🇦🇿
