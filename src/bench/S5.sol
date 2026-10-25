// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract S5Logic is Initializable, OwnableUpgradeable {
    uint256 public value;
    uint256 public counter;
    function initialize(address owner_) external initializer { __Ownable_init(owner_); }
    function setValue(uint256 v) external onlyOwner { value = v; }
    function bump() external { counter += 1; }
}