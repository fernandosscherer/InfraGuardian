#!/usr/bin/env bash
set -Eeuo pipefail

REPO="${INFRAGUARDIAN_REPO:-https://github.com/fernandosscherer/InfraGuardian.git}"
SKILL_NAME="infraguardian"
DEFAULT_REF="main"
ACTION="install"
TARGET="universal"
REF="$DEFAULT_REF"
YES=0
NO_BACKUP=0
SOURCE=""
TMP_DIR=""

INSTALLER_VERSION="1.0.1"
PROJECT_DESC="Auditoria, segurança e manutenção preventiva para servidores Linux"
AUTHOR="Fernando Scherer"
REPOSITORY="https://github.com/fernandosscherer/InfraGuardian"
BOX_WIDTH=76

usage() {
  cat <<'HELP'
InfraGuardian — instalador
Autor: Fernando Scherer
Repo: https://github.com/fernandosscherer/InfraGuardian

Uso: install.sh [install|update|uninstall] [opções]
Opções:
  --target universal|opencode|claude|project|all
  --ref <branch|tag|commit>
  --source <diretório local>
  --yes
  --no-backup
  --help

Destinos:
  universal  ~/.agents/skills/infraguardian
  opencode   ~/.config/opencode/skills/infraguardian
  claude     ~/.claude/skills/infraguardian
  project    ./.agents/skills/infraguardian
  all        Todos os destinos globais

O instalador não usa sudo e não altera configurações do servidor.
HELP
}

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  C_GREEN=$'\033[0;32m'
  C_BOLD=$'\033[1;32m'
  C_DIM=$'\033[2m'
  C_WHITE=$'\033[1;37m'
  C_RESET=$'\033[0m'
else
  C_GREEN="" C_BOLD="" C_DIM="" C_WHITE="" C_RESET=""
fi

log()  { printf '%s[InfraGuardian]%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
warn() { printf '%s[aviso]%s %s\n' "$C_BOLD" "$C_RESET" "$*" >&2; }
die()  { printf '%s[erro]%s %s\n' "$C_BOLD" "$C_RESET" "$*" >&2; exit 1; }

cleanup() {
  if [[ -n "$TMP_DIR" && -d "$TMP_DIR" ]]; then
    rm -rf -- "$TMP_DIR"
  fi
}
trap cleanup EXIT

# Moldura ASCII: largura fixa para evitar desalinhamento entre terminais.
BOX_INNER=72
BOX_BORDER="+$(printf '%*s' "$((BOX_INNER + 2))" '' | tr ' ' '-')+"

box_line() {
  local value="$1"
  printf '| %-*.*s |\n' "$BOX_INNER" "$BOX_INNER" "$value"
}

box_center() {
  local value="$1"
  local length left right
  length=${#value}
  (( length > BOX_INNER )) && value="${value:0:BOX_INNER}" && length=$BOX_INNER
  left=$(( (BOX_INNER - length) / 2 ))
  right=$(( BOX_INNER - length - left ))
  printf '| %*s%s%*s |\n' "$left" '' "$value" "$right" ''
}

banner() {
  printf '\n%s\n' "$C_GREEN$BOX_BORDER$C_RESET"
  printf '%s' "$C_GREEN"
  box_center "INFRAGUARDIAN"
  box_center "LINUX SERVER OPERATIONS & SECURITY"
  printf '%s\n' "$BOX_BORDER"
  box_line "Linux server auditing, security and preventive maintenance"
  box_line "AUDIT  |  MAIL  |  SECURITY  |  MIGRATION  |  PERFORMANCE  |  BACKUP"
  box_line "READ-ONLY BY DEFAULT - Changes require explicit authorization"
  printf '%s%s%s\n\n' "$C_GREEN" "$BOX_BORDER" "$C_RESET"

  printf '  %sAuthor:%s %s%s%s\n' "$C_WHITE" "$C_RESET" "$C_BOLD" "$AUTHOR" "$C_RESET"
  printf '  %sRepository:%s %s\n' "$C_DIM" "$C_RESET" "$REPOSITORY"
  printf '  %sVersion:%s %s\n' "$C_DIM" "$C_RESET" "$INSTALLER_VERSION"
  printf '\n'
  printf '  %sAction:%s %s\n' "$C_DIM" "$C_RESET" "$ACTION"
  printf '  %sTarget:%s %s\n' "$C_DIM" "$C_RESET" "$TARGET"
  printf '  %sRef:%s    %s\n' "$C_DIM" "$C_RESET" "$REF"
  printf '\n%sHOW TO USE%s\n' "$C_BOLD" "$C_RESET"
  printf '  In your AI agent, ask:\n'
  printf '  %sUse InfraGuardian to audit this Linux server.%s\n' "$C_GREEN" "$C_RESET"
  printf '  %sUse InfraGuardian in MAIL mode to check email security.%s\n' "$C_GREEN" "$C_RESET"
  printf '  %sUse InfraGuardian to create a preventive maintenance plan.%s\n\n' "$C_GREEN" "$C_RESET"
}

while (($#)); do
  case "$1" in
    install|update|uninstall) ACTION="$1"; shift ;;
    --target) TARGET="${2:?Informe o target}"; shift 2 ;;
    --ref) REF="${2:?Informe a referência}"; shift 2 ;;
    --source) SOURCE="${2:?Informe o diretório de origem}"; shift 2 ;;
    --yes) YES=1; shift ;;
    --no-backup) NO_BACKUP=1; shift ;;
    --help|-h) usage; exit 0 ;;
    *) die "Opção desconhecida: $1" ;;
  esac
done

case "$TARGET" in
  universal|opencode|claude|project|all) ;;
  *) die "Target inválido: $TARGET" ;;
esac

destinations() {
  case "$TARGET" in
    universal) printf '%s\n' "$HOME/.agents/skills/$SKILL_NAME" ;;
    opencode) printf '%s\n' "$HOME/.config/opencode/skills/$SKILL_NAME" ;;
    claude) printf '%s\n' "$HOME/.claude/skills/$SKILL_NAME" ;;
    project) printf '%s\n' "$PWD/.agents/skills/$SKILL_NAME" ;;
    all)
      printf '%s\n' "$HOME/.agents/skills/$SKILL_NAME"
      printf '%s\n' "$HOME/.config/opencode/skills/$SKILL_NAME"
      printf '%s\n' "$HOME/.claude/skills/$SKILL_NAME"
      ;;
  esac
}

banner

if [[ "$ACTION" == "uninstall" ]]; then
  while IFS= read -r dest; do
    [[ -d "$dest" ]] || { log "Não instalado: $dest"; continue; }
    if (( YES == 0 )); then
      read -r -p "Remover $dest? [y/N] " answer
      [[ "$answer" == [yY] ]] || { log "Ignorado: $dest"; continue; }
    fi
    rm -rf -- "$dest"
    log "Removido: $dest"
  done < <(destinations)
  exit 0
fi

if [[ -n "$SOURCE" ]]; then
  if [[ -d "$SOURCE/infraguardian" ]]; then
    SRC="$SOURCE/infraguardian"
  else
    SRC="$SOURCE"
  fi
  [[ -s "$SRC/SKILL.md" ]] || die "SKILL.md não encontrado em $SRC"
else
  command -v git >/dev/null 2>&1 || die "Git não encontrado. Instale Git ou use --source."
  TMP_DIR="$(mktemp -d)"
  log "Obtendo $REPO (ref: $REF)"
  if ! git clone --quiet --depth 1 --branch "$REF" "$REPO" "$TMP_DIR/repo"; then
    rm -rf -- "$TMP_DIR/repo"
    git clone --quiet "$REPO" "$TMP_DIR/repo" || die "Não foi possível obter o repositório."
    git -C "$TMP_DIR/repo" checkout --quiet "$REF" || die "Referência não encontrada: $REF"
  fi
  SRC="$TMP_DIR/repo/infraguardian"
  [[ -s "$SRC/SKILL.md" ]] || die "Pacote não contém infraguardian/SKILL.md"
fi

while IFS= read -r dest; do
  mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" ]]; then
    if [[ "$ACTION" == "install" && "$YES" == 0 ]]; then
      read -r -p "$dest já existe. Substituir? [y/N] " answer
      [[ "$answer" == [yY] ]] || { log "Ignorado: $dest"; continue; }
    fi
    if (( NO_BACKUP == 0 )); then
      backup="${dest}.backup.$(date +%Y%m%d-%H%M%S)"
      cp -a "$dest" "$backup"
      log "Backup criado: $backup"
    fi
    rm -rf -- "$dest"
  fi
  mkdir -p "$dest"
  cp -a "$SRC/." "$dest/"
  [[ -s "$dest/SKILL.md" ]] || die "Instalação incompleta em $dest"
  log "Instalado em: $dest"
done < <(destinations)

log "Concluído. Reinicie ou recarregue o agente para reconhecer a Skill."
