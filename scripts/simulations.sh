#!/bin/bash
# Simule les 8 cas : 4 programmes × 2 configs

PROGS=("normale.riscv" "pointer.riscv" "tempo.riscv" "unrol.riscv")
NAMES=("normale" "pointer" "tempo" "unrol")
CONFIGS=("C1" "C2")
GEM5="/root/gem5/build/RISCV/gem5.opt"

echo "Lancement des 8 simulations..."

for i in "${!PROGS[@]}"; do
    for cfg in "${CONFIGS[@]}"; do
        out="m5out_${NAMES[$i]}_${cfg}"
        echo "→ ${NAMES[$i]} - $cfg"
        rm -rf "$out"
        $GEM5 --outdir="$out" --redirect-stdout --redirect-stderr \
              se_A7.py --cmd "exo3/${PROGS[$i]}" --cacheconfig "$cfg"
        [ -f "$out/stats.txt" ] && echo "  ok" || echo "  ERREUR"
    done
done

echo "Résultats: $(ls m5out_*/stats.txt 2>/dev/null | wc -l)/8"
