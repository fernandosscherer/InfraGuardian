#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test -s "$ROOT/SKILL.md"
grep -q '^name: infraguardian$' "$ROOT/SKILL.md"
grep -q 'READ-ONLY' "$ROOT/SKILL.md"
echo "OK: InfraGuardian SKILL.md presente e validado."
