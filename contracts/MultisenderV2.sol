// SPDX-License-Identifier: MIT
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "hardhat/console.sol";

pragma solidity ^0.8.20;

contract MultisenderV2 is Initializable, ReentrancyGuardUpgradeable {
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

    function checkEnoughFunds(
        uint totalAmountToBeSent
    ) private view returns (bool) {
        bool hasEnoughFunds = remainingBalance >= totalAmountToBeSent;
        require(
            hasEnoughFunds,
            "Insufficient funds. Please deposit more funds to proceed."
        );
        return hasEnoughFunds;
    }

    function sendEther(address payable receiverAddr, uint256 amount) private {
        (bool sent, ) = receiverAddr.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    /// @dev This function is used to bulk send Ether to multiple addresses with reentrancy guard enabled
    /// @param addresses The list of addresses to send Ether to
    /// @param amounts The list of amounts to send
    function multiSendEther(
        address payable[] memory addresses,
        uint256[] memory amounts
    ) public payable nonReentrant onlyOwner {
        require(
            addresses.length == amounts.length,
            "Recipients' addresses length should match the amounts length."
        );

        uint256 totalAmountToBeSent = 0;

        for (uint256 i = 0; i < amounts.length; i++) {
            totalAmountToBeSent += amounts[i];
        }

        console.log("Current available funds: %s", remainingBalance);
        console.log("Total amount to be sent: %s", totalAmountToBeSent);

        checkEnoughFunds(totalAmountToBeSent);

        for (uint256 i = 0; i < addresses.length; i++) {
            console.log("Sending %s to %s", amounts[i], addresses[i]);
            remainingBalance -= amounts[i];
            sendEther(addresses[i], amounts[i]);
        }

        emit MultisendToken(remainingBalance, address(0));
    }

    function multiSendFixedAmountERC20Token(
        address payable[] memory addresses,
        uint256 amount,
        address erc20Token
    ) public payable onlyOwner {
        uint256 totalAmountToBeSent = addresses.length * amount;
        uint256 totalAmountSent = 0;
        console.log("Initial balance: %s", remainingBalance);
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
        console.log("Final balance: %s", remainingBalance);
    }
}
