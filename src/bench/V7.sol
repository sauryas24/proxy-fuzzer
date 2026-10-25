// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {MiniProxy} from "./MiniProxy.sol";

contract V7Proxy is MiniProxy {
    uint64 public fee;              // slot 0, bytes 0-7
    constructor(address impl) MiniProxy(impl) {}
    function setFee(uint64 f) external { fee = f; }
}
contract V7Logic {
    uint64 public ledger;           // slot 0, bytes 0-7 (collides with fee)
    function setLedger(uint64 x) external { ledger = x; }
    uint256 public j1; function setJ1(uint256 x) external { j1 = x; }
    uint256 public j2; function setJ2(uint256 x) external { j2 = x; }
    uint256 public j3; function setJ3(uint256 x) external { j3 = x; }
    uint256 public j4; function setJ4(uint256 x) external { j4 = x; }
    uint256 public j5; function setJ5(uint256 x) external { j5 = x; }
    uint256 public j6; function setJ6(uint256 x) external { j6 = x; }
    uint256 public j7; function setJ7(uint256 x) external { j7 = x; }
    uint256 public j8; function setJ8(uint256 x) external { j8 = x; }
    uint256 public j9; function setJ9(uint256 x) external { j9 = x; }
    uint256 public j10; function setJ10(uint256 x) external { j10 = x; }
    uint256 public j11; function setJ11(uint256 x) external { j11 = x; }
    uint256 public j12; function setJ12(uint256 x) external { j12 = x; }
    uint256 public j13; function setJ13(uint256 x) external { j13 = x; }
    uint256 public j14; function setJ14(uint256 x) external { j14 = x; }
    uint256 public j15; function setJ15(uint256 x) external { j15 = x; }
    uint256 public j16; function setJ16(uint256 x) external { j16 = x; }
    uint256 public j17; function setJ17(uint256 x) external { j17 = x; }
    uint256 public j18; function setJ18(uint256 x) external { j18 = x; }
    uint256 public j19; function setJ19(uint256 x) external { j19 = x; }
    uint256 public j20; function setJ20(uint256 x) external { j20 = x; }
    uint256 public j21; function setJ21(uint256 x) external { j21 = x; }
    uint256 public j22; function setJ22(uint256 x) external { j22 = x; }
    uint256 public j23; function setJ23(uint256 x) external { j23 = x; }
    uint256 public j24; function setJ24(uint256 x) external { j24 = x; }
    uint256 public j25; function setJ25(uint256 x) external { j25 = x; }
    uint256 public j26; function setJ26(uint256 x) external { j26 = x; }
    uint256 public j27; function setJ27(uint256 x) external { j27 = x; }
    uint256 public j28; function setJ28(uint256 x) external { j28 = x; }
}
