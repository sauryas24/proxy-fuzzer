#!/usr/bin/env bash
# usage: [SEEDS=30] bash analysis/run_all.sh
NAMES="toy v1 v2 v3 v4 v5 v6 s1 s2 s3 s4 s6"
if [ -f src/bench/S5.sol ]; then NAMES="$NAMES s5"; fi
for n in $NAMES; do
  if [ "$n" = "toy" ]; then cfg=analysis/config.json; else cfg=analysis/bench/$n.json; fi
  echo "=== $n"
  bash analysis/evaluate.sh "$cfg" "$n"
done
python3 analysis/summarize.py
