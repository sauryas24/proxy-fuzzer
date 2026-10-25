// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {MiniProxy} from "./MiniProxy.sol";

contract V5Proxy is MiniProxy {
    uint256 public totalDeposits;   // slot 0
    address public treasury;        // slot 1, bytes 0-19
    bool public paused;             // slot 1, byte 20
    constructor(address impl) MiniProxy(impl) {}
    function deposit(uint256 amt) external { totalDeposits += amt; }
    function setTreasury(address t) external { treasury = t; }
}

contract V5Logic {
    uint256 private __gap0;         // slot 0: padding, never written
    uint96 public rewardRate;       // slot 1, bytes 0-11 (collides with treasury)
    uint256 public epoch;           // slot 2
    function setRate(uint96 r) external { rewardRate = r; }
    function nextEpoch() external { epoch += 1; }
}
