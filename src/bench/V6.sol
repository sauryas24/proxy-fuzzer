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
