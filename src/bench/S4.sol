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
