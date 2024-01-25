// SPDX-License-Identifier: MIT
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "hardhat/console.sol";

pragma solidity ^0.8.20;

contract Multisender is Initializable {
    address private owner;

    function initialize(address _owner) external initializer {
        owner = _owner;
    }

    event MultisendToken(uint256 total, address tokenAddress);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    function getOwner() public view returns (address) {
        return owner;
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
            addresses.length != amounts.length,
            "Receipients' addresses length should match the amounts length"
        );

        uint256 totalAmountToBeSent = 0;
        uint256 totalAmountSent = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            totalAmountToBeSent += amounts[i];
        }
        console.log("Total amount to be sent: %s", totalAmountToBeSent);
        console.log("Available funds: %s", msg.value);
        require(msg.value >= totalAmountToBeSent, "Insufficient funds.");

        for (uint256 i = 0; i < addresses.length; i++) {
            sendEther(addresses[i], amounts[i]);
            totalAmountSent += amounts[i];
        }
        emit MultisendToken(totalAmountSent, address(0));
    }
}
