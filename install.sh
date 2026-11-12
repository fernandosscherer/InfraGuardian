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

box_line() {
  local value="$1"
  local length padding_left padding_right
  length=${#value}
  (( length > BOX_WIDTH )) && value="${value:0:BOX_WIDTH}" && length=$BOX_WIDTH
  padding_left=$(( (BOX_WIDTH - length) / 2 ))
  padding_right=$(( BOX_WIDTH - length - padding_left ))
  printf '%s║%s %*s%s%s%*s %s║%s\n' \
    "$C_GREEN" "$C_GREEN" "$padding_left" "" "$value" "$C_GREEN" "$padding_right" "" "$C_GREEN" "$C_RESET"
}

box_left_line() {
  printf '%s║%s %-*s %s║%s\n' "$C_GREEN" "$C_GREEN" "$BOX_WIDTH" "$1" "$C_GREEN" "$C_RESET"
}

banner() {
  printf '\n'
  printf '%s╔════════════════════════════════════════════════════════════════════════════════╗%s\n' "$C_GREEN" "$C_RESET"
  box_line "I N F R A G U A R D I A N"
  box_line "LINUX SERVER OPERATIONS & SECURITY"
  printf '%s╠════════════════════════════════════════════════════════════════════════════════╣%s\n' "$C_GREEN" "$C_RESET"
  box_left_line "$PROJECT_DESC"
  box_line "AUDIT • MAIL • SECURITY • MIGRATION • PERFORMANCE • BACKUP"
  box_line "READ-ONLY BY DEFAULT | Mudanças exigem autorização explícita"
  printf '%s╚════════════════════════════════════════════════════════════════════════════════╝%s\n' "$C_GREEN" "$C_RESET"
  printf '\n'
  printf '  %sAUTOR:%s %s\n' "$C_DIM" "$C_RESET" "$AUTHOR"
  printf '  %sREPOSITÓRIO:%s %s\n' "$C_DIM" "$C_RESET" "$REPOSITORY"
  printf '  %sVERSÃO:%s %s\n' "$C_DIM" "$C_RESET" "$INSTALLER_VERSION"
  printf '\n'
  printf '  %sAÇÃO:%s %s   %sDESTINO:%s %s   %sREF:%s %s\n\n' \
    "$C_DIM" "$C_RESET" "$ACTION" "$C_DIM" "$C_RESET" "$TARGET" "$C_DIM" "$C_RESET" "$REF"
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
