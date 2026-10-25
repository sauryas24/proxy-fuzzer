// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {MiniProxy} from "./MiniProxy.sol";

contract S1Proxy is MiniProxy {
    uint64 public legacy;   // slot 0, bytes 0-7, never written
    constructor(address impl) MiniProxy(impl) {}
}

contract S1Logic {
    uint256 public x;       // slot 0, overlaps `legacy` statically
    function setX(uint256 v) external { x = v; }
    function bump() external { x += 1; }
}