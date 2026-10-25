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
