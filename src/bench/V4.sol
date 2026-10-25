// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {MiniProxy} from "./MiniProxy.sol";

contract V4Proxy is MiniProxy {
    uint64 public fee;              // slot 0, bytes 0-7
    constructor(address impl) MiniProxy(impl) {}
    function setFee(uint64 f) external { fee = f; }
}

contract V4Logic {
    uint64 public ledger;           // slot 0, bytes 0-7 (collides with fee)
    bool public armed;              // slot 0, byte 8
    function arm() external { armed = true; }
    function commit(uint64 x) external {
        require(armed, "not armed");
        ledger = x;
    }
    uint256 public j1;  function setJ1(uint256 x) external { j1 = x; }
    uint256 public j2;  function setJ2(uint256 x) external { j2 = x; }
    uint256 public j3;  function setJ3(uint256 x) external { j3 = x; }
    uint256 public j4;  function setJ4(uint256 x) external { j4 = x; }
    uint256 public j5;  function setJ5(uint256 x) external { j5 = x; }
    uint256 public j6;  function setJ6(uint256 x) external { j6 = x; }
    uint256 public j7;  function setJ7(uint256 x) external { j7 = x; }
    uint256 public j8;  function setJ8(uint256 x) external { j8 = x; }
    uint256 public j9;  function setJ9(uint256 x) external { j9 = x; }
    uint256 public j10; function setJ10(uint256 x) external { j10 = x; }
}
