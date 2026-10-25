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
