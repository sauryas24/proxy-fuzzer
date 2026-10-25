// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {MiniProxy} from "./MiniProxy.sol";

contract V1Proxy is MiniProxy {
    uint128 public a;   // slot 0, bytes 0-15
    uint128 public b;   // slot 0, bytes 16-31
    constructor(address impl) MiniProxy(impl) {}
    function setA(uint128 x) external { a = x; }
    function setB(uint128 x) external { b = x; }
}

contract V1Logic {
    uint256 public x;   // slot 0, overlaps a and b
    uint256 public y;   // slot 1, no overlap
    function setX(uint256 v) external { x = v; }
    function setY(uint256 v) external { y = v; }
}