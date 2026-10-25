import json
import subprocess
import sys


def get_layout(contract):
    """Return a list of variables with absolute byte ranges [start, end)."""
    out = subprocess.run(
        ["forge", "inspect", contract, "storage-layout", "--json"],
        capture_output=True, text=True, check=True,
    ).stdout
    data = json.loads(out)
    types = data.get("types") or {}
    variables = []
    for v in data["storage"]:
        start = int(v["slot"]) * 32 + v["offset"]
        size = int(types[v["type"]]["numberOfBytes"])
        variables.append({
            "name": v["label"],
            "declared_in": v["contract"].split(":")[-1],
            "type": types[v["type"]]["label"],
            "slot": int(v["slot"]),
            "offset": v["offset"],
            "start": start,
            "end": start + size,
        })
    return variables


def find_overlaps(proxy_vars, logic_vars):
    overlaps = []
    for p in proxy_vars:
        for l in logic_vars:
            lo = max(p["start"], l["start"])
            hi = min(p["end"], l["end"])
            if lo < hi:  # the byte ranges intersect
                overlaps.append((p, l, lo, hi))
    return overlaps


def describe(v):
    return f'{v["declared_in"]}.{v["name"]} ({v["type"]}, slot {v["slot"]}, offset {v["offset"]})'


if __name__ == "__main__":
    proxy_name, logic_name = sys.argv[1], sys.argv[2]
    proxy_vars = get_layout(proxy_name)
    logic_vars = get_layout(logic_name)

    found = find_overlaps(proxy_vars, logic_vars)
    if not found:
        print("No overlapping storage ranges.")
    for p, l, lo, hi in found:
        print(f"OVERLAP bytes {lo}-{hi - 1}:")
        print(f"   proxy: {describe(p)}")
        print(f"   logic: {describe(l)}")