import os
import statistics

try:
    from scipy.stats import mannwhitneyu
except ImportError:
    mannwhitneyu = None

CAP = 2000
ALPHA = 0.05

EXPECT = {
    "toy": "vulnerable", "v1": "vulnerable", "v2": "vulnerable", "v3": "vulnerable",
    "v4": "vulnerable", "v5": "vulnerable", "v6": "vulnerable",
    "s1": "safe", "s2": "safe", "s3": "safe", "s4": "safe", "s5": "safe",
    "s6": "safe (intentional sharing)", "v7": "vulnerable", "v8": "vulnerable", "s7": "safe",
}


def load(name, mode):
    p = f"results/{name}_{mode}.txt"
    if not os.path.exists(p):
        return None
    xs = [int(x) for x in open(p).read().split()]
    return xs or None


def iqr(xs):
    if len(xs) < 2:
        return "-"
    q = statistics.quantiles(xs, n=4, method="inclusive")
    return f"{q[0]:.1f}-{q[2]:.1f}"


def summarize(xs):
    found = [x for x in xs if x < CAP]
    if not found:
        return f"0/{len(xs)}", "-", "-"
    return f"{len(found)}/{len(xs)}", f"{statistics.median(found):.1f}", iqr(found)


def compare(r, g):
    """Mann-Whitney U on runs-to-find, not-found counted as CAP."""
    if mannwhitneyu is None:
        return "-", "scipy missing"
    if all(x >= CAP for x in r) and all(x >= CAP for x in g):
        return "-", "n/a (neither found)"
    if sorted(r) == sorted(g):
        return "1.000", "tie"
    p = mannwhitneyu(r, g, alternative="two-sided").pvalue
    mr, mg = statistics.median(r), statistics.median(g)
    if p >= ALPHA:
        verdict = "no sig. difference"
    else:
        verdict = "guided better" if mg < mr else "random better"
    return f"{p:.4f}", verdict


header = ["pair", "ground truth",
          "random found", "random median", "random IQR",
          "guided found", "guided median", "guided IQR",
          "MWU p", "verdict"]
rows = [header]

for name, truth in EXPECT.items():
    r, g = load(name, "random"), load(name, "guided")
    if r is None and g is None:
        continue
    row = [name, truth]
    row += list(summarize(r)) if r else ["-", "-", "-"]
    row += list(summarize(g)) if g else ["-", "-", "-"]
    if r and g:
        row += list(compare(r, g))
    else:
        row += ["-", "-"]
    rows.append(row)

lines = ["| " + " | ".join(row) + " |" for row in rows]
lines.insert(1, "|" + "---|" * len(header))
out = "\n".join(lines)
print(out)
open("results/summary.md", "w").write(out + "\n")