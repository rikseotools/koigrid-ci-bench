#!/usr/bin/env bash
# Medición de velocidad de un runner de CI con una carga pública y fija: la suite de Hono (TypeScript + vitest).
# La misma orden corre en un ubuntu-latest de GitHub y en una VM de koigrid; se comparan los tiempos de CPU
# (tsc y vitest). La instalación se mide aparte porque depende de la red, no del procesador.
# Uso: bash bench.sh [repeticiones]   → una línea JSON por medida en la salida estándar.
set -euo pipefail
REPS="${1:-3}"
HONO_REF="v4.7.0"
BUN_VERSION="1.2.2"
W="$(mktemp -d)"
trap 'rm -rf "$W"' EXIT
cpu="$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/^ *//')"
info() { printf '{"medida":"%s","segundos":%s,"vcpu":%s,"ram_mb":%s,"cpu":"%s","rep":%s}\n' "$1" "$2" "$(nproc)" "$(awk '/MemTotal/{print int($2/1024)}' /proc/meminfo)" "$cpu" "$3"; }
cronometra() { local t0 t1; t0=$(date +%s.%N); "$@" >/dev/null 2>&1; t1=$(date +%s.%N); awk -v a="$t0" -v b="$t1" 'BEGIN{printf "%.2f", b-a}'; }
if ! command -v bun >/dev/null; then curl -fsSL https://bun.sh/install | bash -s "bun-v$BUN_VERSION" >/dev/null 2>&1; export PATH="$HOME/.bun/bin:$PATH"; fi
git clone -q --depth 1 --branch "$HONO_REF" https://github.com/honojs/hono.git "$W/hono"
cd "$W/hono"
info instalacion "$(cronometra bun install --frozen-lockfile)" 0
for i in $(seq 1 "$REPS"); do
  info tsc "$(cronometra npx tsc --noEmit)" "$i"
  info vitest "$(cronometra npx vitest --run)" "$i"
done
