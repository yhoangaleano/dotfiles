# Mac Dev Environment

Entorno de desarrollo para macOS (Apple Silicon). El script `bootstrap.sh` instala y configura todo automáticamente.

> **¿Podés borrar este repo después de clonarlo?**
> Sí. El script copia los archivos a su destino final — nada depende de que la carpeta `~/dotfiles` siga existiendo.

---

## Requisitos previos

- macOS en Apple Silicon (M1/M2/M3/M4)
- Xcode Command Line Tools:
  ```bash
  xcode-select --install
  ```

---

## Instalación automática

```bash
git clone git@github.com:TU_USUARIO/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x bootstrap.sh
./bootstrap.sh
```

Si ya sabés el proyecto de Google Cloud, pasalo para saltarte el prompt interactivo:

```bash
GOOGLE_CLOUD_PROJECT="mi-proyecto" ./bootstrap.sh
```

El script es **idempotente** — podés correrlo múltiples veces sin efectos secundarios.

Cuando termine, seguí los **pasos manuales** de la sección siguiente.

---

## Personalización

El script pide estos datos al inicio y los aplica automáticamente. Si lo hacés manual, estos son los valores que tenés que reemplazar:

| Placeholder | Dónde aparece | Qué poner |
|---|---|---|
| `TU_NOMBRE` | `configs/gitconfig` | Tu nombre completo |
| `TU_EMAIL_PERSONAL` | `configs/gitconfig` | Tu email personal |
| `GOOGLE_CLOUD_PROJECT` | `~/.zshrc` | El ID de tu proyecto en GCP |

Para reemplazarlos a mano después de copiar los archivos:

```bash
# Identidad de git
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"

# Google Cloud (editá ~/.zshrc y cambiá la línea)
export GOOGLE_CLOUD_PROJECT="tu-proyecto-id"
```

Para configurar una cuenta de trabajo (opcional), ver la sección **Git → Múltiples cuentas**.

---

## Pasos manuales (siempre necesarios)

Estos pasos no se pueden automatizar — hacelos después de correr el script.

### 1. Reiniciá la terminal

Cerrá y abrí una terminal nueva para que los cambios en `.zshrc` tomen efecto.

### 2. Configurá la fuente en tu terminal

Para que los íconos del prompt se vean correctamente, configurá `JetBrainsMono Nerd Font` en la terminal que uses:

**iTerm2** (recomendado):
1. `Cmd + ,` → Profiles → seleccioná tu perfil
2. Pestaña **Text** → Font → cambiá a `JetBrainsMono Nerd Font`
3. En **Keys** → configurá **Left Option** como `Normal` y **Right Option** como `Esc+` (Meta) — así `⌥ izquierdo` sigue dando `@` y `⌥ derecho` activa los atajos de shell

**Terminal.app**:
1. `Cmd + ,` → Perfiles → seleccioná tu perfil activo
2. Click en **Cambiar...** junto a la fuente → buscá `JetBrainsMono Nerd Font` → Regular

### 3. Verificá tu identidad de git

El script la configura automáticamente si la ingresaste en los prompts iniciales. Solo necesitás correr esto si la dejaste vacía:

```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.personal.com"
```

### 4. Generá tus claves SSH

Ver la sección **Git → SSH** más abajo.

### 5. Docker Desktop

Abrí Docker Desktop al menos una vez para que inicialice el daemon. Sin este paso, los comandos `docker` y `docker compose` no van a funcionar aunque estén instalados.

### 6. Android Studio

Abrí Android Studio y completá el setup wizard para que descargue el SDK. Luego volvé a correr `./bootstrap.sh` para que acepte las licencias automáticamente.

---

## Instalación manual (sin el script)

Si preferís hacer todo a mano, estos son los pasos en orden.

### 1. Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### 2. Tap de terceros

```bash
brew tap anomalyco/tap
```

### 3. Herramientas CLI

```bash
# Shell
brew install zsh-autosuggestions zsh-syntax-highlighting zsh-completions starship fzf atuin zoxide

# Runtime manager
brew install mise fvm

# Terminal moderna
brew install bat eza ripgrep fd sd

# Gestor de archivos
brew install yazi ffmpegthumbnailer unar jq poppler imagemagick

# Git
brew install lazygit git-delta

# AI
brew install gemini-cli opencode

# Utilidades
brew install mole
```

### 4. Apps

```bash
brew install --cask google-chrome brave-browser google-drive
brew install --cask dbeaver-community visual-studio-code intellij-idea-ce
brew install --cask android-studio docker-desktop iterm2
brew install --cask handy spotify bruno
brew install --cask font-jetbrains-mono-nerd-font
```

### 5. Gentle AI (engram + gga + gentle-ai)

```bash
curl -fsSL https://raw.githubusercontent.com/Gentleman-Programming/gentle-ai/main/scripts/install.sh | bash
```

### 6. Claude Code

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

### 6b. Pi Coding Agent

```bash
curl -fsSL https://pi.dev/install.sh | sh
```

### 7. Apps sin brew (instalar manualmente)

| App | Descarga |
|---|---|
| Claude (desktop) | [claude.ai](https://claude.ai) |
| Google Gemini | [gemini.google.com](https://gemini.google.com) |

### 8. Copiar configuraciones

```bash
# Shell
cp configs/zshrc ~/.zshrc

# Starship
mkdir -p ~/.config
cp configs/starship.toml ~/.config/starship.toml

# Git
cp configs/gitconfig ~/.gitconfig

# mise
mkdir -p ~/.config/mise
cp configs/mise.toml ~/.config/mise/config.toml

# atuin
mkdir -p ~/.config/atuin
cp configs/atuin.toml ~/.config/atuin/config.toml

# lazygit
mkdir -p ~/Library/Application\ Support/lazygit
cp configs/lazygit-config.yml ~/Library/Application\ Support/lazygit/config.yml
```

### 9. Runtimes

```bash
mise install        # instala Node, Go, Java y Python
fvm install stable
fvm global stable
```

Cuando clonés un proyecto que tiene su propio `.mise.toml` (para usar una versión de Node distinta a la global):

```bash
cd tu-proyecto
mise trust          # autorizar el .mise.toml del proyecto
mise install        # instalar la versión que pide el proyecto
mise current node   # verificar que tomó la correcta
```

### 10. SSH e identidad de git

Ver la sección **Git → SSH** y **Git → Identidad** más abajo.

### 11. Reiniciá la terminal

---

## Qué se instala

### Shell

| Herramienta | Para qué sirve |
|---|---|
| `starship` | Prompt con contexto de git, runtimes y tiempo de ejecución |
| `zsh-autosuggestions` | Sugerencias inline basadas en historial |
| `zsh-syntax-highlighting` | Colorea comandos válidos/inválidos mientras escribís |
| `zsh-completions` | Tab-completion para docker, git, mise y otras herramientas |
| `fzf` | Fuzzy finder — `Ctrl+T` archivos, `Alt+C` carpetas |
| `atuin` | Historial inteligente con búsqueda — `Ctrl+R` |
| `zoxide` | `cd` inteligente — `z nombre` en lugar de rutas completas |

### Terminal moderna

Estos comandos reemplazan sus equivalentes del sistema con versiones más potentes:

| Comando | Reemplaza | Para qué sirve |
|---|---|---|
| `bat` → `cat` | `cat` | Muestra archivos con syntax highlighting y números de línea |
| `eza` → `ls` / `ll` / `tree` | `ls` | Lista archivos con íconos, colores y modo árbol |
| `rg` | `grep` | Busca texto — rápido, respeta `.gitignore` |
| `fd` | `find` | Busca archivos por nombre con sintaxis simple |
| `sd` | `sed` | Busca y reemplaza con regex moderna |

### Gestor de archivos

| Herramienta | Para qué sirve |
|---|---|
| `yazi` | Gestor de archivos en terminal — 3 columnas, previews de imágenes/PDFs/videos |

Usá `y` (no `yazi`) para que al salir con `q` la terminal quede en el directorio que estabas navegando.

Atajos principales:

| Acción | Tecla |
|---|---|
| Navegar | flechas o `hjkl` |
| Abrir archivo / entrar carpeta | `Enter` o `l` |
| Volver a carpeta padre | `h` |
| Salir y quedarse en el directorio | `q` |
| Buscar en la carpeta actual | `f` |
| Copiar archivo | `y` → `p` |
| Eliminar | `d` |

### Git

| Herramienta | Para qué sirve |
|---|---|
| `lazygit` | TUI completa para git — staging, commits, branches, rebase interactivo |
| `delta` | Diffs con syntax highlighting, integrado en git y lazygit |

### Runtimes (via mise)

| Runtime | Versión global |
|---|---|
| Node.js | 24 (fallback — los proyectos pueden pisar esto con `.mise.toml`) |
| Go | 1.26 |
| Java | 21 |
| Python | 3.12 |

La versión global es el fallback cuando no estás en ningún proyecto. Si un proyecto necesita una versión distinta, agrega un `.mise.toml` local y corré `mise trust` + `mise install` dentro de él.

### Flutter

Instalado via `fvm` (Flutter Version Manager). La versión `stable` queda como global.

### AI

| Herramienta | Instalación | Para qué sirve |
|---|---|---|
| `claude` (Claude Code) | curl | Agente de AI en el terminal |
| `gemini-cli` | brew | CLI para Google Gemini |
| `opencode` | brew (anomalyco/tap) | Agente de AI en el terminal |
| `pi` (Pi Coding Agent) | curl | Harness minimalista de AI para terminal (15+ proveedores) |
| `gentle-ai` | curl | Suite de herramientas de Gentleman Programming |
| `engram` | incluido en gentle-ai | Memoria persistente para agentes de AI |
| `gga` | incluido en gentle-ai | Code review automático con AI antes de cada commit |

### Docker

Docker Desktop se instala como cask e incluye `docker compose` — no requiere instalación separada.

```bash
# Verificar después del primer arranque de Docker Desktop
docker --version
docker compose version
```

> Docker Desktop debe iniciarse al menos una vez manualmente antes de que el daemon esté disponible.

### Apps

| App | Para qué sirve |
|---|---|
| Google Chrome, Brave | Navegadores |
| Google Drive | Almacenamiento |
| DBeaver Community | Cliente de bases de datos |
| Visual Studio Code | Editor |
| IntelliJ IDEA Community | IDE |
| Android Studio | IDE para desarrollo mobile |
| Docker Desktop | Containers y Docker Compose |
| iTerm2 | Terminal con split panes y Option key configurable por separado |
| Handy | Speech to text |
| Spotify | Música |
| Bruno | REST client open-source (alternativa a Postman) |
| Claude (manual) | AI desktop |
| Google Gemini (manual) | AI desktop |

---

## Git

Esta sección cubre todo lo relacionado con git: identidad, SSH, múltiples cuentas y herramientas visuales.

### Identidad

Configurá tu nombre y email global (se usa en todos los repos salvo que haya un override):

```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.personal.com"
```

### Múltiples cuentas

Si tenés repos de trabajo y personales, el `.gitconfig` usa `includeIf` para aplicar un email distinto según la carpeta donde estés:

| Carpeta | Email que usa |
|---|---|
| `~/projects/EMPRESA/` y subcarpetas | `TU_EMAIL_TRABAJO` |
| Cualquier otra carpeta | email personal (global) |

Esto es automático — git lo detecta por directorio. Para verificar qué identidad está activa en un repo:

```bash
git config user.email
```

Para agregar otra empresa, creá un archivo override:

```bash
# ~/.gitconfig-otraempresa
[user]
    email = vos@otraempresa.com
```

Y agregá la regla en `~/.gitconfig`:

```ini
[includeIf "gitdir:~/projects/otraempresa/"]
    path = ~/.gitconfig-otraempresa
```

### SSH

SSH es la forma segura de autenticarte con GitHub, Bitbucket y GitLab sin escribir contraseñas.

> **El bootstrap configura SSH de forma interactiva.** Te pide los servicios y cuentas que querés agregar, genera las claves y muestra las claves públicas al final para que las pegues en cada plataforma. Si preferís hacerlo manual, seguí las instrucciones de abajo.

#### Copiar una clave pública existente

Si ya tenés una clave generada y solo necesitás copiarla al portapapeles:

```bash
pbcopy < ~/.ssh/id_ed25519_github.pub
```

Luego en GitHub: **Settings → SSH and GPG keys → New SSH key**.

#### Configuración simple — una cuenta por servicio

Ideal cuando tenés una sola cuenta por plataforma (un GitHub, un Bitbucket).

**1. Generá las claves:**

```bash
ssh-keygen -t ed25519 -C "tu@email.com" -f ~/.ssh/id_ed25519_github
ssh-keygen -t ed25519 -C "tu@email.com" -f ~/.ssh/id_ed25519_bitbucket
```

**2. Agregá las claves al agente:**

```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_github
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_bitbucket
```

**3. Copiá la clave pública y pegala en la plataforma:**

```bash
pbcopy < ~/.ssh/id_ed25519_github.pub     # → GitHub: Settings → SSH keys
pbcopy < ~/.ssh/id_ed25519_bitbucket.pub  # → Bitbucket: Personal settings → SSH keys
```

**4. Creá `~/.ssh/config`:**

```
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_github
  IdentitiesOnly yes
  AddKeysToAgent yes
  UseKeychain yes

Host bitbucket.org
  HostName bitbucket.org
  User git
  IdentityFile ~/.ssh/id_ed25519_bitbucket
  IdentitiesOnly yes
  AddKeysToAgent yes
  UseKeychain yes
```

**5. Verificá la conexión:**

```bash
ssh -T git@github.com
ssh -T git@bitbucket.org
```

Respuesta esperada: `Hi username! You've successfully authenticated...`

**6. Clonar repos:**

```bash
git clone git@github.com:tu-usuario/repo.git
git clone git@bitbucket.org:tu-org/repo.git
```

---

#### Configuración avanzada — múltiples cuentas en el mismo servicio

Necesario cuando tenés, por ejemplo, dos cuentas de GitHub (personal y trabajo).

La diferencia clave: en lugar de usar `github.com` como `Host`, usás **aliases** (`github.com-personal`, `github.com-trabajo`). SSH sabe qué clave usar según el alias que pongás al clonar.

**1. Generá una clave por cuenta:**

```bash
ssh-keygen -t ed25519 -C "tu@personal.com"  -f ~/.ssh/id_ed25519_github_personal
ssh-keygen -t ed25519 -C "tu@empresa.com"   -f ~/.ssh/id_ed25519_github_trabajo
```

**2. Agregá al agente:**

```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_github_personal
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_github_trabajo
```

**3. Agregá cada clave pública a su cuenta de GitHub:**

```bash
pbcopy < ~/.ssh/id_ed25519_github_personal.pub   # → cuenta personal
pbcopy < ~/.ssh/id_ed25519_github_trabajo.pub    # → cuenta del trabajo
```

**4. Creá `~/.ssh/config` con aliases:**

```
# GitHub — cuenta personal
Host github.com-personal
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_github_personal
  IdentitiesOnly yes
  AddKeysToAgent yes
  UseKeychain yes

# GitHub — cuenta trabajo
Host github.com-trabajo
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_github_trabajo
  IdentitiesOnly yes
  AddKeysToAgent yes
  UseKeychain yes

# Bitbucket — cuenta trabajo
Host bitbucket.org-trabajo
  HostName bitbucket.org
  User git
  IdentityFile ~/.ssh/id_ed25519_github_trabajo
  IdentitiesOnly yes
  AddKeysToAgent yes
  UseKeychain yes
```

**5. Verificá la conexión con cada alias:**

```bash
ssh -T git@github.com-personal
ssh -T git@github.com-trabajo
ssh -T git@bitbucket.org-trabajo
```

**6. Clonar repos usando el alias:**

```bash
# Repo personal
git clone git@github.com-personal:tu-usuario/repo.git

# Repo de trabajo en GitHub
git clone git@github.com-trabajo:tu-empresa/repo.git

# Repo de trabajo en Bitbucket
git clone git@bitbucket.org-trabajo:tu-empresa/repo.git
```

> **Nota:** Con alias, el email correcto en los commits lo maneja el `includeIf` del `.gitconfig` — no el SSH. SSH solo define qué cuenta de plataforma usás; el email del commit es independiente.

### Diffs con delta

`delta` se activa automáticamente al instalar — está configurado en `~/.gitconfig`. Cuando hacés `git diff`, `git show` o `git log -p`, los diffs aparecen con syntax highlighting y números de línea.

### lazygit

TUI completa para git. Abrila dentro de cualquier repo:

```bash
lazygit
```

Atajos principales:

| Acción | Tecla |
|---|---|
| Stagear / destagear archivo | `Space` |
| Stagear todo | `a` |
| Commit | `c` |
| Push | `P` |
| Pull | `p` |
| Nueva branch | `n` |
| Cambiar branch | `Space` en lista de branches |
| Ver diff de un archivo | `Enter` |
| Rebase interactivo | `e` en la lista de commits |
| Salir | `q` |

---

## Cómo usar las herramientas

### Historial — atuin (`Ctrl+R`)

| Acción | Cómo |
|---|---|
| Buscar en historial | `Ctrl+R` |
| Filtrar por directorio actual | `Ctrl+R` → `Ctrl+F` |
| Ejecutar el seleccionado | `Enter` |
| Editar antes de ejecutar | `Tab` |
| Ver estadísticas | `atuin stats` |

### Navegación — zoxide (`z`)

| Acción | Cómo |
|---|---|
| Ir a carpeta visitada antes | `z nombre` |
| Ir con nombre parcial | `z proy` |
| Seleccionar entre varias coincidencias | `zi nombre` |

> La primera vez, navegá las carpetas con `cd` para que zoxide las aprenda.

### Gestor de archivos — yazi (`y`)

Siempre usá `y` en lugar de `yazi` directo — así al salir con `q` la terminal queda en el directorio que estabas navegando.

| Acción | Tecla |
|---|---|
| Navegar | flechas o `h` / `l` |
| Entrar carpeta / abrir archivo | `Enter` o `l` |
| Volver a carpeta padre | `h` |
| Buscar en la carpeta actual | `f` |
| Seleccionar archivo | `Space` |
| Copiar | `y` |
| Cortar | `x` |
| Pegar | `p` |
| Eliminar (papelera) | `d` |
| Eliminar permanente | `D` |
| Crear archivo | `a` (terminar el nombre sin `/`) |
| Crear carpeta | `a` (terminar el nombre con `/`) |
| Renombrar | `r` |
| Mostrar/ocultar ocultos | `.` |
| Salir | `q` |

### Búsqueda — fzf

| Acción | Cómo |
|---|---|
| Buscar archivos | `Ctrl+T` |
| Navegar a carpeta hija | `Alt+C` (en iTerm2: `⌥ derecho + C`) |
| Pasar output de un comando | `comando \| fzf` |

### Prompt — starship

Muestra información automáticamente cuando es relevante:

| Qué muestra | Cuándo |
|---|---|
| Rama git y estado | Dentro de un repo git |
| Versión de Node | En proyectos con `package.json` |
| Versión de Go | En proyectos con `go.mod` |
| Tiempo del último comando | Cuando tardó más de 2 segundos |
| Error del último comando | Cuando falló |

---

## Verificación post-setup

```bash
mise list           # debe mostrar node, go, java, python
mise current node   # debe mostrar 24.x.x (o la versión del proyecto si estás dentro de uno)
mise current python # debe mostrar 3.12.x
docker --version    # requiere que Docker Desktop esté corriendo
docker compose version
fvm list            # debe mostrar stable activo
flutter doctor      # verde (o con warnings conocidos de Android)
starship --version
lazygit --version
bat --version
eza --version
yazi --version
claude --version
```

Lista de chequeo:

- [ ] El prompt muestra íconos (manzanita, rama de git, etc.)
- [ ] `Ctrl+R` abre atuin
- [ ] `z` funciona como `cd` inteligente
- [ ] `cat archivo` muestra syntax highlighting
- [ ] `ls` muestra íconos Nerd Font
- [ ] `lazygit` abre la TUI dentro de un repo
- [ ] `y` abre yazi y al salir con `q` quedás en el directorio navegado
- [ ] `git diff` muestra syntax highlighting con delta
- [ ] `git config user.email` en `~/projects/EMPRESA/` devuelve el email del trabajo
- [ ] `ssh -T git@github.com-personal` responde con tu usuario

---

## Troubleshooting

**`brew: command not found` después de instalar Homebrew**
```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

**`mise: command not found`**
Verificá que `~/.zshrc` tenga `eval "$(mise activate zsh)"` y reiniciá la terminal.

**Los íconos del prompt se ven como cuadraditos**
Configurá la fuente `JetBrainsMono Nerd Font` en Terminal.app o iTerm2 (ver Pasos manuales → paso 2).

**La fuente JetBrainsMono Nerd Font no aparece en el selector de la terminal**

El script instala los `.ttf` en `~/Library/Fonts/`, pero a veces macOS no los registra en su base de datos de fuentes — entonces ni Font Book ni iTerm2/Terminal.app las muestran. Diagnóstico rápido:

```bash
# Si esto devuelve 0, las fuentes están en disco pero NO registradas
system_profiler SPFontsDataType 2>/dev/null | grep -c -i "jetbrains"
```

Si da 0, reconstruí la caché de fuentes:

1. **Borrar la caché de usuario** (sin password):
   ```bash
   atsutil databases -removeUser
   ```
2. **Borrar la caché del sistema** (te pide tu password de macOS):
   ```bash
   sudo atsutil databases -remove
   ```
3. **Reiniciá la Mac.** Al arrancar, `fontd` reconstruye la base desde cero y levanta lo que esté en `~/Library/Fonts/`.
4. Verificá en Font Book buscando `JetBrains` — ahora deberían aparecer.
5. En iTerm2/Terminal.app seleccioná **JetBrainsMono Nerd Font**.

Si después de reiniciar siguen sin aparecer, el archivo `.ttf` puede estar corrupto. Validá con `file ~/Library/Fonts/JetBrainsMonoNerdFont-Regular.ttf` — debe responder `TrueType Font data, …`.

**`Permission denied (publickey)` al hacer git push/pull**
- Verificá que la clave SSH esté en el agente: `ssh-add -l`
- Si está vacío: `ssh-add ~/.ssh/id_ed25519_personal`
- Verificá la conexión: `ssh -T git@github.com-personal`

**Email incorrecto en un commit**
Verificá que el repo esté dentro de `~/projects/EMPRESA/` para el override automático:
```bash
git config user.email
```

**El proyecto usa una versión de Node distinta a la global**
Si un proyecto tiene `.mise.toml` con su propia versión de Node, mise lo ignora hasta que lo autorizás:
```bash
cd tu-proyecto
mise trust          # autorizar el .mise.toml del proyecto (solo la primera vez)
mise install        # instalar la versión declarada
mise current node   # verificar
```

**`gga` no se activa en commits**
`gga` necesita estar habilitado como hook en cada repo. Consultá la documentación de `gentle-ai`.
