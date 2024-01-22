// SPDX-License-Identifier: MIT
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

pragma solidity ^0.8.20;

contract Multisender is Initializable {
    address private owner;

    function initialize(address _owner) external initializer {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }
}
