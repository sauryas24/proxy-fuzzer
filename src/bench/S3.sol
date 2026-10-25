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
