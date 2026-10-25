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
