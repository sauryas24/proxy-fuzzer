N = 28  # junk setters

def junk(n):
    return "\n".join(
        f"    uint256 public j{i}; function setJ{i}(uint256 x) external {{ j{i} = x; }}"
        for i in range(1, n + 1))

HEAD = '// SPDX-License-Identifier: MIT\npragma solidity ^0.8.20;\nimport {MiniProxy} from "./MiniProxy.sol";\n'

v7 = HEAD + f'''
contract V7Proxy is MiniProxy {{
    uint64 public fee;              // slot 0, bytes 0-7
    constructor(address impl) MiniProxy(impl) {{}}
    function setFee(uint64 f) external {{ fee = f; }}
}}
contract V7Logic {{
    uint64 public ledger;           // slot 0, bytes 0-7 (collides with fee)
    function setLedger(uint64 x) external {{ ledger = x; }}
{junk(N)}
}}
'''

v8 = HEAD + f'''
contract V8Proxy is MiniProxy {{
    uint64 public fee;              // slot 0, bytes 0-7
    constructor(address impl) MiniProxy(impl) {{}}
    function setFee(uint64 f) external {{ fee = f; }}
}}
contract V8Logic {{
    uint64 public ledger;           // slot 0, bytes 0-7 (collides with fee)
    bool public armed;              // slot 0, byte 8
    function arm() external {{ armed = true; }}
    function commit(uint64 x) external {{
        require(armed, "not armed");
        ledger = x;
    }}
{junk(N)}
}}
'''

s7 = HEAD + f'''
contract S7Proxy is MiniProxy {{
    constructor(address impl) MiniProxy(impl) {{}}
}}
contract S7Logic {{
    uint64 public ledger;
    function setLedger(uint64 x) external {{ ledger = x; }}
{junk(N)}
}}
'''

import json
for name, src in (("V7", v7), ("V8", v8), ("S7", s7)):
    open(f"src/bench/{name}.sol", "w").write(src)
    json.dump({
        "proxy": f"{name}Proxy", "logic": f"{name}Logic",
        "imports": [f"../src/bench/{name}.sol"],
        "deploy": f"l = address(new {name}Logic()); p = address(new {name}Proxy(l));",
    }, open(f"analysis/bench/{name.lower()}.json", "w"), indent=2)
print("wrote V7, V8, S7")