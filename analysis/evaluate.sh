#!/usr/bin/env bash
# usage: [SEEDS=30] bash analysis/evaluate.sh <config.json> <name>
CFG=$1; NAME=$2; SEEDS=${SEEDS:-30}
mkdir -p results
python3 analysis/generate.py "$CFG" || exit 1
for t in random guided; do
  : > results/${NAME}_$t.txt
  for s in $(seq 1 $SEEDS); do
    rm -rf cache/fuzz
    FOUNDRY_FUZZ_RUNS=2000 forge test --match-contract GeneratedTest \
      --match-test testFuzz_${t}_sequence --fuzz-seed $s 2>&1 \
      | grep -o 'runs: [0-9]*' | head -1 | grep -o '[0-9]*' >> results/${NAME}_$t.txt
  done
done
python3 - "$NAME" <<'PY'
import statistics, sys
name = sys.argv[1]
for t in ("random", "guided"):
    xs = [int(x) for x in open(f"results/{name}_{t}.txt").read().split()]
    found = [x for x in xs if x < 2000]
    med = statistics.median(found) if found else "-"
    print(f"{name:5s} {t:7s} n={len(xs)} found={len(found)} median_runs_when_found={med}")
PY
