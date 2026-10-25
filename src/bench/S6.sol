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
