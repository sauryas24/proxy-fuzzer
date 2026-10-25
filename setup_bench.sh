#!/usr/bin/env bash
set -e
mkdir -p src/bench analysis/bench results

# ---------------- V2: proxy admin vs logic initialized flag ----------------
cat > src/bench/V2.sol <<'EOF'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {MiniProxy} from "./MiniProxy.sol";

contract V2Proxy is MiniProxy {
    address public admin;           // slot 0, bytes 0-19
    constructor(address impl, address admin_) MiniProxy(impl) { admin = admin_; }
    function setAdmin(address a) external {
        require(msg.sender == admin, "not admin");
        admin = a;
    }
}

contract V2Logic {
    bool public initialized;        // slot 0, byte 0  (collides with admin)
    bool public initializing;       // slot 0, byte 1
    uint256 public value;           // slot 1
    function initialize() external {
        require(!initialized, "already initialized");
        initialized = true;
    }
    function setValue(uint256 v) external { value = v; }
}
EOF

# ---------------- V3: owner-gated proxy function vs logic counter ----------------
cat > src/bench/V3.sol <<'EOF'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {MiniProxy} from "./MiniProxy.sol";

contract V3Proxy is MiniProxy {
    address public owner;           // slot 0
    constructor(address impl, address owner_) MiniProxy(impl) { owner = owner_; }
    function transferOwnership(address o) external {
        require(msg.sender == owner, "not owner");
        owner = o;
    }
}

contract V3Logic {
    uint256 public counter;         // slot 0 (collides with owner)
    uint256 public total;           // slot 1
    function increment() external { counter += 1; }
    function addTotal(uint256 v) external { total += v; }
}
EOF

# ---------------- V4: two-step trigger + junk functions ----------------
cat > src/bench/V4.sol <<'EOF'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {MiniProxy} from "./MiniProxy.sol";

contract V4Proxy is MiniProxy {
    uint64 public fee;              // slot 0, bytes 0-7
    constructor(address impl) MiniProxy(impl) {}
    function setFee(uint64 f) external { fee = f; }
}

contract V4Logic {
    uint64 public ledger;           // slot 0, bytes 0-7 (collides with fee)
    bool public armed;              // slot 0, byte 8
    function arm() external { armed = true; }
    function commit(uint64 x) external {
        require(armed, "not armed");
        ledger = x;
    }
    uint256 public j1;  function setJ1(uint256 x) external { j1 = x; }
    uint256 public j2;  function setJ2(uint256 x) external { j2 = x; }
    uint256 public j3;  function setJ3(uint256 x) external { j3 = x; }
    uint256 public j4;  function setJ4(uint256 x) external { j4 = x; }
    uint256 public j5;  function setJ5(uint256 x) external { j5 = x; }
    uint256 public j6;  function setJ6(uint256 x) external { j6 = x; }
    uint256 public j7;  function setJ7(uint256 x) external { j7 = x; }
    uint256 public j8;  function setJ8(uint256 x) external { j8 = x; }
    uint256 public j9;  function setJ9(uint256 x) external { j9 = x; }
    uint256 public j10; function setJ10(uint256 x) external { j10 = x; }
}
EOF

# ---------------- V5: collision in slot 1, padded slot 0 ----------------
cat > src/bench/V5.sol <<'EOF'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {MiniProxy} from "./MiniProxy.sol";

contract V5Proxy is MiniProxy {
    uint256 public totalDeposits;   // slot 0
    address public treasury;        // slot 1, bytes 0-19
    bool public paused;             // slot 1, byte 20
    constructor(address impl) MiniProxy(impl) {}
    function deposit(uint256 amt) external { totalDeposits += amt; }
    function setTreasury(address t) external { treasury = t; }
}

contract V5Logic {
    uint256 private __gap0;         // slot 0: padding, never written
    uint96 public rewardRate;       // slot 1, bytes 0-11 (collides with treasury)
    uint256 public epoch;           // slot 2
    function setRate(uint96 r) external { rewardRate = r; }
    function nextEpoch() external { epoch += 1; }
}
EOF

# ---------------- V6: assembly slot reuse, invisible to layout analysis ----------------
cat > src/bench/V6.sol <<'EOF'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {MiniProxy} from "./MiniProxy.sol";

contract V6Proxy is MiniProxy {
    constructor(address impl, address admin_) MiniProxy(impl) {
        assembly {
            sstore(0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103, admin_)
        }
    }
    function upgradeTo(address impl) external {
        address admin_;
        assembly { admin_ := sload(0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103) }
        require(msg.sender == admin_, "not admin");
        assembly {
            sstore(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc, impl)
        }
    }
}

contract V6Logic {
    uint256 public other;
    // BUG: reuses the proxy's EIP-1967 implementation slot as its own "treasury" slot
    function setTreasury(address t) external {
        assembly {
            sstore(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc, t)
        }
    }
    function setOther(uint256 v) external { other = v; }
}
EOF

# ---------------- S2: clean EIP-1967 proxy ----------------
cat > src/bench/S2.sol <<'EOF'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {MiniProxy} from "./MiniProxy.sol";

contract S2Proxy is MiniProxy {
    constructor(address impl) MiniProxy(impl) {}
}

contract S2Logic {
    uint256 public a;
    uint256 public b;
    uint128 public c;
    uint128 public d;
    function setA(uint256 v) external { a = v; }
    function setB(uint256 v) external { b = v; }
    function setC(uint128 v) external { c = v; }
    function setD(uint128 v) external { d = v; }
}
EOF

# ---------------- S3: shared admin, read-only in the logic ----------------
cat > src/bench/S3.sol <<'EOF'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {MiniProxy} from "./MiniProxy.sol";

contract S3Proxy is MiniProxy {
    address public admin;           // slot 0
    constructor(address impl, address admin_) MiniProxy(impl) { admin = admin_; }
    function setAdmin(address a) external {
        require(msg.sender == admin, "not admin");
        admin = a;
    }
}

contract S3Logic {
    address public admin;           // slot 0, same type and position, only read here
    uint256 public value;           // slot 1
    function setValue(uint256 v) external {
        require(msg.sender == admin, "not admin");
        value = v;
    }
}
EOF

# ---------------- S4: guarded array index (the paper's false-positive example) ----------------
cat > src/bench/S4.sol <<'EOF'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {MiniProxy} from "./MiniProxy.sol";

contract S4Proxy is MiniProxy {
    uint256 public x;               // slot 0
    constructor(address impl) MiniProxy(impl) {}
    function setX(uint256 v) external { x = v; }
}

contract S4Logic {
    uint256[8] public a;            // slots 0-7, overlaps x statically
    function setA(uint256 i, uint256 v) external {
        require(i >= 1 && i < 8, "bad index");   // index 0 is never used
        a[i] = v;
    }
}
EOF

# ---------------- S6: intentionally shared variable (expected false positive) ----------------
cat > src/bench/S6.sol <<'EOF'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {MiniProxy} from "./MiniProxy.sol";

contract S6Proxy is MiniProxy {
    address public admin;           // slot 0
    constructor(address impl, address admin_) MiniProxy(impl) { admin = admin_; }
    function setAdmin(address a) external {
        require(msg.sender == admin, "not admin");
        admin = a;
    }
}

contract S6Logic {
    address public admin;           // slot 0, intentionally the same variable
    uint256 public value;           // slot 1
    function renounceAdmin() external {
        require(msg.sender == admin, "not admin");
        admin = address(0);
    }
    function setValue(uint256 v) external { value = v; }
}
EOF

# ---------------- configs ----------------
mk() { # name proxy logic deploy
cat > analysis/bench/$1.json <<EOF
{
  "proxy": "$2",
  "logic": "$3",
  "imports": ["../src/bench/$4.sol"],
  "deploy": "$5"
}
EOF
}
mk v2 V2Proxy V2Logic V2 "l = address(new V2Logic()); p = address(new V2Proxy(l, address(0xA11CE)));"
mk v3 V3Proxy V3Logic V3 "l = address(new V3Logic()); p = address(new V3Proxy(l, address(0xA11CE)));"
mk v4 V4Proxy V4Logic V4 "l = address(new V4Logic()); p = address(new V4Proxy(l));"
mk v5 V5Proxy V5Logic V5 "l = address(new V5Logic()); p = address(new V5Proxy(l));"
mk v6 V6Proxy V6Logic V6 "l = address(new V6Logic()); p = address(new V6Proxy(l, address(0xA11CE)));"
mk s2 S2Proxy S2Logic S2 "l = address(new S2Logic()); p = address(new S2Proxy(l));"
mk s3 S3Proxy S3Logic S3 "l = address(new S3Logic()); p = address(new S3Proxy(l, address(0xA11CE)));"
mk s4 S4Proxy S4Logic S4 "l = address(new S4Logic()); p = address(new S4Proxy(l));"
mk s6 S6Proxy S6Logic S6 "l = address(new S6Logic()); p = address(new S6Proxy(l, address(0xA11CE)));"

# ---------------- evaluation scripts ----------------
cat > analysis/evaluate.sh <<'EOF'
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
EOF

cat > analysis/run_all.sh <<'EOF'
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
EOF

cat > analysis/summarize.py <<'EOF'
import os, statistics

CAP = 2000
EXPECT = {
    "toy": "vulnerable", "v1": "vulnerable", "v2": "vulnerable", "v3": "vulnerable",
    "v4": "vulnerable", "v5": "vulnerable", "v6": "vulnerable",
    "s1": "safe", "s2": "safe", "s3": "safe", "s4": "safe", "s5": "safe",
    "s6": "safe (intentional sharing)",
}

def load(name, mode):
    p = f"results/{name}_{mode}.txt"
    if not os.path.exists(p):
        return None
    return [int(x) for x in open(p).read().split()]

rows = [["pair", "ground truth", "random found", "random median runs",
         "guided found", "guided median runs"]]
for name, truth in EXPECT.items():
    row = [name, truth]
    for mode in ("random", "guided"):
        xs = load(name, mode)
        if not xs:
            row += ["-", "-"]
            continue
        found = [x for x in xs if x < CAP]
        med = statistics.median(found) if found else "-"
        row += [f"{len(found)}/{len(xs)}", str(med)]
    if row[2] != "-" or row[4] != "-":
        rows.append(row)

lines = ["| " + " | ".join(r) + " |" for r in rows]
lines.insert(1, "|" + "---|" * len(rows[0]))
out = "\n".join(lines)
print(out)
open("results/summary.md", "w").write(out + "\n")
EOF

echo "benchmark files created"