// SPDX-License-Identifier: MIT
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "hardhat/console.sol";

pragma solidity ^0.8.20;

contract Multisender is Initializable {
    address private owner;
    uint256 private remainingBalance;

    function initialize(
        address _owner,
        uint256 _remainingBalance
    ) external initializer {
        owner = _owner;
        remainingBalance = _remainingBalance;
    }

    event MultisendToken(uint256 total, address tokenAddress);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function getRemainingBalance() public view returns (uint256) {
        return remainingBalance;
    }

    function sendEther(address payable receiverAddr, uint256 amount) private {
        (bool sent, ) = receiverAddr.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    function multiSendEther(
        address payable[] memory addresses,
        uint256[] memory amounts
    ) public payable onlyOwner {
        require(
            addresses.length == amounts.length,
            "Recipients' addresses length should match the amounts length"
        );

        uint256 totalAmountToBeSent = 0;
        uint256 totalAmountSent = 0;

        // total amount to be sent to recipients
        for (uint256 i = 0; i < amounts.length; i++) {
            totalAmountToBeSent += amounts[i];
        }
        console.log("Total amount to be sent: %s", totalAmountToBeSent);
        console.log("Available funds: %s", msg.value);
        require(msg.value >= totalAmountToBeSent, "Insufficient funds.");

        for (uint256 i = 0; i < addresses.length; i++) {
            console.log("Sending %s to %s", amounts[i], addresses[i]);
            sendEther(addresses[i], amounts[i]);
            totalAmountSent += amounts[i];
        }
        console.log("Total amount sent: %s", totalAmountSent);

        remainingBalance = msg.value - totalAmountSent;
        console.log("Remaining funds: %s", remainingBalance);
        emit MultisendToken(totalAmountSent, address(0));
    }
}
