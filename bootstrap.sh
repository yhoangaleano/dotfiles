#!/usr/bin/env bash
# Bootstrap para macOS — reproduce el entorno de desarrollo en cualquier Mac limpio.
# Idempotente: podés correrlo múltiples veces sin efectos secundarios.
#
# USO:
#   chmod +x bootstrap.sh && ./bootstrap.sh
#   GOOGLE_CLOUD_PROJECT="mi-proyecto" ./bootstrap.sh   # saltar el prompt

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS_DIR="$DOTFILES_DIR/configs"

# ── colores ────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ok()   { echo -e "${GREEN}[✓]${NC} $1"; }
info() { echo -e "${YELLOW}[+]${NC} $1"; }
err()  { echo -e "${RED}[!]${NC} $1"; }

echo ""
echo "  Mac Dev Bootstrap"
echo "  ================="
echo ""

# ── 0. Configuración interactiva ───────────────────────────────────────────────
echo "  Antes de empezar, necesitamos algunos datos."
echo "  (Podés dejar vacío con Enter y configurarlo manualmente después)"
echo ""

if [[ -z "${GOOGLE_CLOUD_PROJECT:-}" ]]; then
  read -r -p "  Google Cloud Project ID (Enter para saltar): " GOOGLE_CLOUD_PROJECT
fi

read -r -p "  Tu nombre completo para git (ej: Juan Pérez): " GIT_NAME
read -r -p "  Tu email personal para git (ej: juan@gmail.com): " GIT_EMAIL

echo ""
read -r -p "  ¿Configurar una cuenta de trabajo? [s/N]: " SETUP_WORK
if [[ "$SETUP_WORK" =~ ^[Ss]$ ]]; then
  read -r -p "  Nombre de la carpeta de trabajo en ~/projects/ (ej: miempresa): " WORK_FOLDER
  read -r -p "  Email del trabajo (ej: juan@miempresa.com): " WORK_EMAIL
fi

echo ""

# ── 1. Homebrew ────────────────────────────────────────────────────────────────
install_homebrew() {
  if command -v brew &>/dev/null; then
    ok "Homebrew ya instalado"
    return
  fi
  info "Instalando Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Apple Silicon: agregar brew al PATH para el resto del script
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  ok "Homebrew instalado"
}

# ── 2. Taps personalizados ─────────────────────────────────────────────────────
add_taps() {
  local taps=(
    "anomalyco/tap"
  )
  for tap in "${taps[@]}"; do
    if brew tap | grep -q "^${tap}$"; then
      ok "Tap $tap ya agregado"
    else
      info "Agregando tap $tap..."
      brew tap "$tap"
    fi
  done
}

# ── 3. Fórmulas Homebrew ───────────────────────────────────────────────────────
install_formulas() {
  local formulas=(
    # Shell
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    starship
    fzf
    atuin
    zoxide

    # Runtime manager
    mise

    # Flutter
    fvm

    # AI / dev tools
    gemini-cli
    opencode            # tap: anomalyco/tap

    # Modern CLI (reemplazan cat/ls/grep/find/sed)
    bat
    eza
    ripgrep
    fd
    sd

    # Git
    lazygit
    git-delta

    # Yazi — gestor de archivos + dependencias para previews
    yazi
    ffmpegthumbnailer
    unar
    jq
    poppler
    imagemagick

    # Utilidades
    mole
  )

  info "Instalando fórmulas..."
  for formula in "${formulas[@]}"; do
    [[ "$formula" == \#* ]] && continue
    if brew list --formula "$formula" &>/dev/null 2>&1; then
      ok "$formula"
    else
      info "  brew install $formula"
      brew install "$formula" || err "Falló: $formula"
    fi
  done
}

# ── 4. Casks Homebrew ──────────────────────────────────────────────────────────
install_casks() {
  local casks=(
    google-chrome
    brave-browser
    google-drive
    dbeaver-community
    visual-studio-code
    intellij-idea-ce
    android-studio
    docker-desktop
    iterm2
    handy
    spotify
    bruno
    font-jetbrains-mono-nerd-font
  )

  info "Instalando casks..."
  for cask in "${casks[@]}"; do
    [[ "$cask" == \#* ]] && continue
    if brew list --cask "$cask" &>/dev/null 2>&1; then
      ok "$cask"
    else
      info "  brew install --cask $cask"
      brew install --cask --adopt "$cask" || err "Falló cask: $cask"
    fi
  done
}

# ── 5. Permisos zsh (evita warning "insecure directories" de compinit) ────────
fix_zsh_permissions() {
  chmod go-w '/opt/homebrew/share' 2>/dev/null || true
  chmod -R go-w '/opt/homebrew/share/zsh' 2>/dev/null || true
  ok "Permisos zsh corregidos"
}

# ── 6. Gentle AI (engram + gentle-ai + gga) ───────────────────────────────────
install_gentle_ai() {
  if command -v gentle-ai &>/dev/null; then
    ok "gentle-ai ya instalado"
    return
  fi
  info "Instalando gentle-ai (engram, gga incluidos)..."
  curl -fsSL https://raw.githubusercontent.com/Gentleman-Programming/gentle-ai/main/scripts/install.sh | bash \
    || err "No se pudo instalar gentle-ai"
}

# ── 7. Claude Code (CLI) ───────────────────────────────────────────────────────
install_claude_code() {
  if command -v claude &>/dev/null; then
    ok "Claude Code ya instalado ($(claude --version 2>/dev/null || echo 'versión desconocida'))"
    return
  fi
  info "Instalando Claude Code..."
  curl -fsSL https://claude.ai/install.sh | bash \
    || err "No se pudo instalar Claude Code"
}

# ── 7b. Pi Coding Agent (CLI) ──────────────────────────────────────────────────
install_pi_coding_agent() {
  if command -v pi &>/dev/null; then
    ok "Pi Coding Agent ya instalado"
    return
  fi
  info "Instalando Pi Coding Agent..."
  curl -fsSL https://pi.dev/install.sh | sh \
    || err "No se pudo instalar Pi Coding Agent"
}

# ── 7c. Refrescar caché de fuentes (post-cask) ────────────────────────────────
# Las fuentes instaladas por Homebrew a veces no quedan registradas en la base
# de datos de macOS. Limpiamos la caché de usuario para forzar el re-escaneo.
# Si aun así no aparecen, el README → Troubleshooting → Fuentes tiene el fix
# completo (sudo + reinicio).
refresh_font_cache() {
  if command -v atsutil &>/dev/null; then
    atsutil databases -removeUser 2>/dev/null || true
    ok "Caché de fuentes de usuario refrescada"
  fi
}

# ── 8. ~/.zshrc ────────────────────────────────────────────────────────────────
setup_zshrc() {
  local zshrc_source="$CONFIGS_DIR/zshrc"
  local zshrc_target="$HOME/.zshrc"

  if [[ ! -f "$zshrc_source" ]]; then
    err "No se encontró $zshrc_source — saltando .zshrc"
    return
  fi

  if [[ -f "$zshrc_target" ]]; then
    if diff -q "$zshrc_source" "$zshrc_target" &>/dev/null; then
      ok ".zshrc ya está actualizado"
      return
    fi
    cp "$zshrc_target" "$zshrc_target.backup.$(date +%Y%m%d%H%M%S)"
    info ".zshrc anterior guardado como backup"
  fi

  cp "$zshrc_source" "$zshrc_target"

  if [[ -n "${GOOGLE_CLOUD_PROJECT:-}" ]]; then
    if grep -q 'GOOGLE_CLOUD_PROJECT=' "$zshrc_target"; then
      sed -i '' "s|export GOOGLE_CLOUD_PROJECT=.*|export GOOGLE_CLOUD_PROJECT=\"${GOOGLE_CLOUD_PROJECT}\"|" "$zshrc_target"
    else
      echo "" >> "$zshrc_target"
      echo "export GOOGLE_CLOUD_PROJECT=\"${GOOGLE_CLOUD_PROJECT}\"" >> "$zshrc_target"
    fi
  fi

  ok ".zshrc configurado"
}

# ── 9. mise — config + runtimes ───────────────────────────────────────────────
setup_mise() {
  local mise_config_dir="$HOME/.config/mise"
  local mise_source="$CONFIGS_DIR/mise.toml"

  mkdir -p "$mise_config_dir"

  if [[ -f "$mise_source" ]]; then
    cp "$mise_source" "$mise_config_dir/config.toml"
    ok "mise config copiado"
  else
    err "No se encontró $mise_source"
  fi

  if ! command -v mise &>/dev/null; then
    err "mise no está disponible — instalá Homebrew primero"
    return
  fi

  info "Instalando runtimes via mise (puede tardar)..."
  mise install || err "Algunos runtimes de mise fallaron"
  ok "mise runtimes instalados"
  info "Node global instalado. Proyectos con .mise.toml usan su propia versión — corré 'mise trust' la primera vez que clonés uno."
}

# ── 10. Flutter via fvm ────────────────────────────────────────────────────────
setup_flutter() {
  if ! command -v fvm &>/dev/null; then
    err "fvm no encontrado — saltando Flutter"
    return
  fi

  if fvm list 2>/dev/null | grep -q "stable"; then
    ok "Flutter stable ya instalado"
  else
    info "Instalando Flutter stable (puede tardar varios minutos)..."
    fvm install stable
  fi

  fvm global stable
  ok "Flutter stable configurado como global"
}

# ── 11. Android SDK — aceptar licencias ───────────────────────────────────────
accept_android_licenses() {
  local sdk_dir="$HOME/Library/Android/sdk"
  local licenses_dir="$sdk_dir/licenses"

  if [[ ! -d "$sdk_dir" ]]; then
    info "Android SDK no encontrado en $sdk_dir — saltando licencias."
    info "Abrí Android Studio, completá el setup wizard y volvé a correr el script."
    return
  fi

  mkdir -p "$licenses_dir"

  cat > "$licenses_dir/android-sdk-license" << 'EOF'

8933bad161af4178b1185d1a37fbf41ea5269c55
d56f5187479451eabf01fb78af6dfcb131a6481e
24333f8a63b6825ea9c5514f83c2829b004d1fee
EOF

  cat > "$licenses_dir/android-sdk-preview-license" << 'EOF'

84831b9409646a918e30573bab4c9c91346d8abd
EOF

  cat > "$licenses_dir/android-googletv-license" << 'EOF'

601085b94cd77f0b54ff86406957099ebe79c4d6
EOF

  cat > "$licenses_dir/android-sdk-arm-dbt-license" << 'EOF'

859f317696f67ef3d7f30a50a5560e7834b43903
EOF

  cat > "$licenses_dir/google-gdk-license" << 'EOF'

33b6a2b64607f11b759f320ef9dff4ae5c47d97a
EOF

  cat > "$licenses_dir/mips-android-sysimage-license" << 'EOF'

e9acab5b5fbb560a72cfaecce8946896ff6aab9d
EOF

  cat > "$licenses_dir/android-googlexr-license" << 'EOF'

6d543f5b2e8b63e7d42e4e4e13d3dbc6a0c6e9c6
EOF

  ok "Licencias Android SDK aceptadas"
}

# ── 12. SSH ────────────────────────────────────────────────────────────────────
setup_ssh() {
  echo ""
  read -r -p "  ¿Configurar SSH ahora? [s/N]: " SETUP_SSH
  [[ ! "$SETUP_SSH" =~ ^[Ss]$ ]] && return

  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"

  local ssh_config="$HOME/.ssh/config"
  local entry_count=0
  local has_entries=false

  if [[ -f "$ssh_config" ]]; then
    cp "$ssh_config" "${ssh_config}.backup.$(date +%Y%m%d%H%M%S)"
    info "~/.ssh/config anterior guardado como backup"
    > "$ssh_config"
  fi

  echo ""
  echo "  Configurá tus cuentas SSH una por una."
  echo ""

  while true; do
    ((entry_count++)) || true
    read -r -p "  Cuenta $entry_count — Servicio [github/bitbucket/gitlab]: " service
    [[ -z "$service" ]] && break
    has_entries=true

    read -r -p "    Alias (Enter para hostname directo, ej: personal / trabajo): " alias_name
    read -r -p "    Email asociado: " ssh_email

    case "$service" in
      github)    hostname="github.com" ;;
      bitbucket) hostname="bitbucket.org" ;;
      gitlab)    hostname="gitlab.com" ;;
      *)         hostname="$service" ;;
    esac

    if [[ -n "$alias_name" ]]; then
      host_entry="${hostname}-${alias_name}"
      key_name="id_ed25519_${service}_${alias_name}"
    else
      host_entry="$hostname"
      key_name="id_ed25519_${service}"
    fi

    key_path="$HOME/.ssh/$key_name"

    if [[ -f "$key_path" ]]; then
      ok "  Clave $key_name ya existe — reutilizando"
    else
      info "  Generando clave SSH: $key_name"
      ssh-keygen -t ed25519 -C "$ssh_email" -f "$key_path"
    fi

    cat >> "$ssh_config" << EOF

# ${service} — ${alias_name:-principal}
Host $host_entry
  HostName $hostname
  User git
  IdentityFile $key_path
  IdentitiesOnly yes
  AddKeysToAgent yes
  UseKeychain yes
EOF

    ok "  Cuenta $host_entry configurada"
    echo ""

    read -r -p "  ¿Configurás otra cuenta SSH? [s/N]: " more
    echo ""
    [[ ! "$more" =~ ^[Ss]$ ]] && break
  done

  [[ "$has_entries" == false ]] && return

  ssh-add --apple-use-keychain "$HOME/.ssh"/id_ed25519_* 2>/dev/null || true

  echo ""
  echo "  ─────────────────────────────────────────────────────────"
  echo "  Claves públicas — copiá cada una y agregala a su servicio"
  echo "  ─────────────────────────────────────────────────────────"
  for pubkey_file in "$HOME/.ssh"/id_ed25519_*.pub; do
    [[ -f "$pubkey_file" ]] || continue
    echo ""
    echo "  $(basename "$pubkey_file" .pub):"
    echo "  $(cat "$pubkey_file")"
  done
  echo ""

  ok "SSH configurado"
}

# ── 13. Git ────────────────────────────────────────────────────────────────────
setup_git() {
  if [[ ! -f "$CONFIGS_DIR/gitconfig" ]]; then
    err "No se encontró $CONFIGS_DIR/gitconfig — saltando git"
    return
  fi

  cp "$CONFIGS_DIR/gitconfig" "$HOME/.gitconfig"

  # Inyectar nombre y email si se proporcionaron
  if [[ -n "${GIT_NAME:-}" ]]; then
    sed -i '' "s|TU_NOMBRE|${GIT_NAME}|" "$HOME/.gitconfig"
  fi
  if [[ -n "${GIT_EMAIL:-}" ]]; then
    sed -i '' "s|TU_EMAIL_PERSONAL|${GIT_EMAIL}|" "$HOME/.gitconfig"
  fi

  # Configurar cuenta de trabajo si se solicitó
  if [[ "$SETUP_WORK" =~ ^[Ss]$ && -n "${WORK_FOLDER:-}" && -n "${WORK_EMAIL:-}" ]]; then
    # Descomentar y rellenar el bloque includeIf en .gitconfig
    sed -i '' \
      "s|# \[includeIf \"gitdir:~/projects/EMPRESA/\"\]|\[includeIf \"gitdir:~/projects/${WORK_FOLDER}/\"\]|" \
      "$HOME/.gitconfig"
    sed -i '' \
      "s|# 	path = ~/.gitconfig-empresa|	path = ~/.gitconfig-${WORK_FOLDER}|" \
      "$HOME/.gitconfig"

    # Crear el archivo override de trabajo
    cat > "$HOME/.gitconfig-${WORK_FOLDER}" << EOF
[user]
	email = ${WORK_EMAIL}
EOF
    ok ".gitconfig-${WORK_FOLDER} creado"
  fi

  ok ".gitconfig configurado"
}

# ── 14. Lazygit ────────────────────────────────────────────────────────────────
setup_lazygit() {
  local lazygit_dir="$HOME/Library/Application Support/lazygit"
  local lazygit_source="$CONFIGS_DIR/lazygit-config.yml"

  mkdir -p "$lazygit_dir"

  if [[ -f "$lazygit_source" ]]; then
    cp "$lazygit_source" "$lazygit_dir/config.yml"
    ok "lazygit config configurado"
  else
    err "No se encontró $lazygit_source — saltando lazygit"
  fi
}

# ── 15. Starship ───────────────────────────────────────────────────────────────
setup_starship() {
  local starship_dir="$HOME/.config"
  local starship_source="$CONFIGS_DIR/starship.toml"

  mkdir -p "$starship_dir"

  if [[ ! -f "$starship_source" ]]; then
    err "No se encontró $starship_source — saltando starship"
    return
  fi

  if [[ -f "$starship_dir/starship.toml" ]]; then
    if diff -q "$starship_source" "$starship_dir/starship.toml" &>/dev/null; then
      ok "starship.toml ya está actualizado"
      return
    fi
    cp "$starship_dir/starship.toml" "$starship_dir/starship.toml.backup.$(date +%Y%m%d%H%M%S)"
    info "starship.toml anterior guardado como backup"
  fi

  cp "$starship_source" "$starship_dir/starship.toml"
  ok "starship.toml configurado"
}

# ── 16. Configs de herramientas ────────────────────────────────────────────────
setup_tool_configs() {
  # atuin
  local atuin_dir="$HOME/.config/atuin"
  mkdir -p "$atuin_dir"
  if [[ -f "$CONFIGS_DIR/atuin.toml" ]]; then
    cp "$CONFIGS_DIR/atuin.toml" "$atuin_dir/config.toml"
    ok "atuin config copiado"
  fi

}

# ── Main ───────────────────────────────────────────────────────────────────────
main() {
  install_homebrew
  add_taps
  install_formulas
  fix_zsh_permissions
  install_casks
  refresh_font_cache
  install_gentle_ai
  install_claude_code
  install_pi_coding_agent
  setup_zshrc
  setup_mise
  setup_flutter
  accept_android_licenses
  setup_tool_configs
  setup_ssh
  setup_git
  setup_lazygit
  setup_starship

  echo ""
  echo "  ================================"
  ok "Bootstrap completo."
  echo ""
  echo "  Pasos manuales pendientes:"
  echo "    1. Reiniciá la terminal"
  echo "    2. Configurá la fuente JetBrainsMono Nerd Font:"
  echo "       • iTerm2: Cmd+, → Profiles → Text → Font"
  echo "       • Terminal.app: Cmd+, → Perfiles → Texto → Cambiar fuente"
  echo "       Si la fuente NO aparece en el selector, corré:"
  echo "         sudo atsutil databases -remove   (te pide tu password)"
  echo "       y reiniciá la Mac. Detalle completo: README → Troubleshooting → Fuentes"
  if [[ -z "${GIT_NAME:-}" || -z "${GIT_EMAIL:-}" ]]; then
  echo "    3. Configurá tu identidad de git (no la ingresaste al inicio):"
  echo "       git config --global user.name 'Tu Nombre'"
  echo "       git config --global user.email 'tu@email.com'"
  else
  echo "    3. Verificá tu identidad de git: git config user.name && git config user.email"
  fi
  echo "    4. Pegá tus claves públicas SSH en cada plataforma (ver README → Git → SSH)"
  echo "    5. Abrí Docker Desktop al menos una vez para inicializar el daemon"
  echo "    6. Abrí Android Studio y completá el setup wizard"
  echo "    7. Corré 'flutter doctor --android-licenses' y luego 'flutter doctor'"
  echo "    8. iTerm2 → Settings → Profiles → Keys: Left Option = Normal, Right Option = Esc+ (para Alt+C de fzf)"
  echo ""
}

main "$@"
