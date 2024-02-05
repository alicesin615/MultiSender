// SPDX-License-Identifier: MIT
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "hardhat/console.sol";

pragma solidity ^0.8.20;

contract Multisender is Initializable {
    address private owner;
    uint256 private remainingBalance;

    using SafeERC20 for IERC20;

    event MultisendToken(uint256 total, address tokenAddress);

    function initialize(
        address _owner,
        uint256 _remainingBalance
    ) external initializer {
        owner = _owner;
        remainingBalance = _remainingBalance;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function getRemainingBalance() external view onlyOwner returns (uint256) {
        return remainingBalance;
    }

    function setRemainingBalance(uint256 _remainingBalance) private onlyOwner {
        console.log("Remaining funds: %s", _remainingBalance);
        remainingBalance = _remainingBalance;
    }

    function checkEnoughFunds(
        uint totalAmountToBeSent
    ) private view returns (bool) {
        bool hasEnoughFunds = remainingBalance >= totalAmountToBeSent;
        require(hasEnoughFunds, "Insufficient funds");
        return hasEnoughFunds;
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
        console.log("Available funds: %s", remainingBalance);

        require(remainingBalance >= totalAmountToBeSent, "Insufficient funds.");

        for (uint256 i = 0; i < addresses.length; i++) {
            console.log("Sending %s to %s", amounts[i], addresses[i]);
            sendEther(addresses[i], amounts[i]);
            totalAmountSent += amounts[i];
        }
        console.log("Total amount sent: %s", totalAmountSent);

        remainingBalance = remainingBalance - totalAmountSent;
        setRemainingBalance(remainingBalance);
        emit MultisendToken(totalAmountSent, address(0));
    }

    function multiSendFixedAmountERC20Token(
        address payable[] memory addresses,
        uint256 amount,
        address erc20Token
    ) public payable onlyOwner {
        uint256 totalAmountToBeSent = addresses.length * amount;
        uint256 totalAmountSent = 0;

        require(checkEnoughFunds(totalAmountToBeSent), "Insufficient funds.");

        IERC20 token = IERC20(erc20Token);

        for (uint256 i = 0; i < addresses.length; i++) {
            console.log("Sending %s to %s", amount, addresses[i]);
            token.transferFrom(msg.sender, addresses[i], amount);
            totalAmountSent += amount;
        }
        emit MultisendToken(totalAmountSent, address(0));

        console.log("Total amount sent: %s", totalAmountSent);
        remainingBalance = remainingBalance - totalAmountSent;
        setRemainingBalance(remainingBalance);
    }
}
