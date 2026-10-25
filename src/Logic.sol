// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Initializable {
    bool internal initialized;   // slot 0, byte 0  <-- collides with Proxy.fees
}

contract Logic is Initializable {
    uint256[256] private __gap;  // slots 1-256
    address public admin;        // slot 257

    uint256 public v1;
    function set1(uint256 x) external { v1 = x; }
    uint256 public v2;
    function set2(uint256 x) external { v2 = x; }
    uint256 public v3;
    function set3(uint256 x) external { v3 = x; }
    uint256 public v4;
    function set4(uint256 x) external { v4 = x; }
    uint256 public v5;
    function set5(uint256 x) external { v5 = x; }
    uint256 public v6;
    function set6(uint256 x) external { v6 = x; }
    uint256 public v7;
    function set7(uint256 x) external { v7 = x; }
    uint256 public v8;
    function set8(uint256 x) external { v8 = x; }
    uint256 public v9;
    function set9(uint256 x) external { v9 = x; }
    uint256 public v10;
    function set10(uint256 x) external { v10 = x; }
    uint256 public v11;
    function set11(uint256 x) external { v11 = x; }
    uint256 public v12;
    function set12(uint256 x) external { v12 = x; }
    uint256 public v13;
    function set13(uint256 x) external { v13 = x; }
    uint256 public v14;
    function set14(uint256 x) external { v14 = x; }
    uint256 public v15;
    function set15(uint256 x) external { v15 = x; }
    uint256 public v16;
    function set16(uint256 x) external { v16 = x; }
    uint256 public v17;
    function set17(uint256 x) external { v17 = x; }
    uint256 public v18;
    function set18(uint256 x) external { v18 = x; }
    uint256 public v19;
    function set19(uint256 x) external { v19 = x; }
    uint256 public v20;
    function set20(uint256 x) external { v20 = x; }
    function initialize() external {
        require(!initialized, "already initialized");
        initialized = true;
        admin = msg.sender;
    }

    function withdraw() external {
        require(msg.sender == admin, "not admin");
        payable(admin).transfer(address(this).balance);
    }
}