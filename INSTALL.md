# ARTI Universal Birgə — Quraşdırma Təlimatı

Bu sənəd layihənin sıfırdan quraşdırılması üçün addım-addım təlimatdır.

---

## 1. Əməliyyat Sisteminə Görə Paket Meneceri

### macOS
```bash
# Homebrew qur (yoxdursa)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Windows
```powershell
# Chocolatey qur (PowerShell Administrator)
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

### Linux (Ubuntu/Debian)
```bash
sudo apt update && sudo apt upgrade -y
```

---

## 2. PostgreSQL Quraşdırma

### macOS
```bash
brew install postgresql@18
brew services start postgresql@18

# İstifadəçi yarat (əgər yoxdursa)
createuser -s $(whoami)
```

### Windows
```powershell
choco install postgresql --version=18.0
# Quraşdırma zamanı superuser şifrəsi təyin edin
# pgAdmin avtomatik quraşdırılacaq
```

### Linux
```bash
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql

# İstifadəçi yarat
sudo -u postgres createuser -s $(whoami)
```

---

## 3. R və RStudio Quraşdırma

### macOS
```bash
brew install r
brew install --cask rstudio
```

### Windows
```powershell
choco install r.project
choco install r.studio
```

### Linux
```bash
sudo apt install r-base r-base-dev
# RStudio: https://posit.co/download/rstudio-desktop/ saytından .deb yükləyin
sudo dpkg -i rstudio-*.deb
sudo apt --fix-broken install
```

---

## 4. Layihəni Yüklə

```bash
git clone <repo-url> ~/Desktop/ARTI_Universal_Birgə
cd ~/Desktop/ARTI_Universal_Birgə
```

---

## 5. Database Yaratmaq və Bərpa Etmək

```bash
# Database yarat
createdb arti_construction

# Dump-dan bərpa et
psql arti_construction < database/backup/arti_construction_full.sql

# Yoxla
psql arti_construction -c "SELECT COUNT(*) FROM audit.users;"
```

Windows-da (pgAdmin və ya psql):
```cmd
createdb -U postgres arti_construction
psql -U postgres arti_construction < database\backup\arti_construction_full.sql
```

---

## 6. R Paketlərini Quraşdır

RStudio-nu açın və Console-da icra edin:

```r
required_packages <- c(
  "shiny", "bs4Dash", "DBI", "RPostgres", "pool",
  "dplyr", "plotly", "DT", "leaflet", "httr2",
  "jsonlite", "shinyjs", "waiter", "shinycssloaders",
  "digest", "bcrypt", "yaml"
)

missing <- required_packages[!required_packages %in% installed.packages()[,"Package"]]
if (length(missing) > 0) {
  install.packages(missing)
  cat("Quraşdırıldı:", paste(missing, collapse = ", "), "\n")
} else {
  cat("Bütün paketlər artıq quraşdırılıb.\n")
}
```

---

## 7. config.yml Konfiqurasiyası

`shared/config.yml` faylını yoxlayın. Database bağlantı məlumatlarını öz mühitinizə uyğunlaşdırın:

```yaml
database:
  mode: smart
  localhost:
    host: localhost
    port: 5432
    dbname: arti_construction
    user: sizin_istifadeci_adiniz    # dəyişdirin
    password: ""
```

---

## 8. Dashboard-u İşə Salma

1. RStudio açın
2. `platform/shiny/app.R` faylını açın
3. Sağ üst küncdə **Run App** düyməsinə basın
4. Brauzer açılacaq: `http://localhost:3838`

Və ya terminal ilə:
```bash
Rscript -e 'shiny::runApp("platform/shiny/app.R", port=3838, host="0.0.0.0")'
```

---

## 9. Regional App-ı İşə Salma

Dashboard işləyərkən, yeni terminal pəncərəsində:

```bash
Rscript -e 'shiny::runApp("platform/regional/app.R", port=3839, host="0.0.0.0")'
```

Və ya RStudio-da ikinci sessiya açıb `platform/regional/app.R` → Run App.

---

## 10. Problemlərin Həlli (Troubleshooting)

### Port məşğuldur
```bash
# Hansı proses portu istifadə edir
lsof -i :3838
# Prosesi dayandır
kill -9 <PID>
```

### PostgreSQL işləmir
```bash
# macOS
brew services restart postgresql@18

# Linux
sudo systemctl restart postgresql

# Status yoxla
pg_isready
```

### R paketi quraşdırıla bilmir

**macOS-da bcrypt problemi:**
```bash
brew install openssl
```
Sonra R-də:
```r
Sys.setenv(PKG_CONFIG_PATH = "/usr/local/opt/openssl/lib/pkgconfig")
install.packages("bcrypt")
```

**Linux-da:**
```bash
sudo apt install libpq-dev libssl-dev libcurl4-openssl-dev
```

### Database bağlantı xətası
```bash
# PostgreSQL işləyir?
pg_isready

# İstifadəçi mövcuddur?
psql -c "\du"

# Database mövcuddur?
psql -l | grep arti_construction
```

### "config.yml tapılmadı" xətası
Working directory-nin düzgün olduğundan əmin olun:
```bash
cd ~/Desktop/ARTI_Universal_Birgə
```
RStudio-da: Session → Set Working Directory → To Project Directory

---

## Əlaqə

Problem yaşayırsınızsa, GitHub Issues bölməsindən bildirin.
