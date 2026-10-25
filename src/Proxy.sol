// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Proxy {
    uint64[3] public fees;            // slot 0 (three uint64s packed together)
    address[3] public feeRecipients;  // slots 1-3
    address public logic;             // slot 4

    enum FeeType { Penalty, Transaction, Sales }

    constructor(address _logic) {
        logic = _logic;
    }

    // Deprecated function the developer forgot to remove
    function updateFee(FeeType t, uint64 percent) external {
        fees[uint256(t)] = percent;
    }

    // Forward every unknown call to the logic contract
    fallback() external payable {
        address impl = logic;
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable {}
}