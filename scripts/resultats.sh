#!/bin/bash
# Affiche les tableaux 9, 10, 11 (miss rates en %)

get_stat() { grep "^$2" "$1/stats.txt" 2>/dev/null | awk '{print $2}'; }
percent() { awk -v m=$1 -v a=$2 'BEGIN {if(a>0) printf "%.2f",m/a*100; else print "0.00"}'; }

PROGS=("normale" "pointer" "tempo" "unrol")
CONFIGS=("C1" "C2")

echo "TABLEAU 9 - Instruction Cache Miss Rate (%)"
printf "%-10s %10s %10s\n" "Programme" "C1" "C2"
for p in "${PROGS[@]}"; do
    printf "%-10s" "$p"
    for c in "${CONFIGS[@]}"; do
        d="m5out_${p}_${c}"
        m=$(get_stat "$d" "system.cpu.icache.overallMisses::total")
        a=$(get_stat "$d" "system.cpu.icache.overallAccesses::total")
        printf " %9s%%" "$(percent ${m:-0} ${a:-1})"
    done
    echo
done

echo ""
echo "TABLEAU 10 - Data Cache Miss Rate (%)"
printf "%-10s %10s %10s\n" "Programme" "C1" "C2"
for p in "${PROGS[@]}"; do
    printf "%-10s" "$p"
    for c in "${CONFIGS[@]}"; do
        d="m5out_${p}_${c}"
        m=$(get_stat "$d" "system.cpu.dcache.overallMisses::total")
        a=$(get_stat "$d" "system.cpu.dcache.overallAccesses::total")
        printf " %9s%%" "$(percent ${m:-0} ${a:-1})"
    done
    echo
done

echo ""
echo "TABLEAU 11 - L2 Cache Miss Rate (%)"
printf "%-10s %10s %10s\n" "Programme" "C1" "C2"
for p in "${PROGS[@]}"; do
    printf "%-10s" "$p"
    for c in "${CONFIGS[@]}"; do
        d="m5out_${p}_${c}"
        m=$(get_stat "$d" "system.l2cache.overallMisses::total")
        a=$(get_stat "$d" "system.l2cache.overallAccesses::total")
        printf " %9s%%" "$(percent ${m:-0} ${a:-1})"
    done
    echo
done
