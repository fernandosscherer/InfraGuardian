#!/usr/bin/env bash
set -euo pipefail
GREEN='\033[0;32m'; CYAN='\033[0;36m'; RESET='\033[0m'
printf "${GREEN}"
cat <<'BANNER'
 _____        __           _____                     _
|_   _|      / _|         / ____|                   | |
  | |  _ __ | |_ _ __ __ _| |  __ _   _  __ _ _ __ __| |
  | | | '_ \|  _| '__/ _` | | |_ | | | |/ _` | '__/ _` |
 _| |_| | | | | | | | (_| | |__| | |_| | (_| | | | (_| |
|_____|_| |_|_| |_|  \__,_|\_____|\__,_|\__,_|_|  \__,_|
BANNER
printf "${RESET}${CYAN}Linux Infrastructure Intelligence${RESET}\n"
printf "Autor: Fernando Scherer | github.com/fernandosscherer/InfraGuardian\n"
printf "READ-ONLY por padrão | cPanel/WHM é opcional\n\n"
