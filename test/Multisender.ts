import { ethers, upgrades } from 'hardhat';
import { expect } from 'chai';
import { BaseContract, BigNumberish, ContractInterface } from 'ethers';
import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import type {
    HardhatEthersSigner,
    SignerWithAddress
} from '@nomicfoundation/hardhat-ethers/signers';

describe('Multisender', function () {
    let multisenderContract: BaseContract &
        Omit<ContractInterface, keyof BaseContract>;
    let sender: HardhatEthersSigner;
    let recipients: SignerWithAddress[];
    let remainingBalance: BigNumberish | null | undefined;

    const initialTotalFunds = process.env.INITIAL_TOTAL_FUNDS || '0';

    async function deployFixture() {
        const MultisenderContract = await ethers.getContractFactory(
            'Multisender'
        );
        [sender, ...recipients] = await ethers.getSigners();
        multisenderContract = await upgrades.deployProxy(
            MultisenderContract,
            [sender.address, ethers.parseEther(initialTotalFunds)],
            {
                initializer: 'initialize'
            }
        );

        console.log(
            'Multisender deployed to:',
            await multisenderContract.getAddress()
        );
        console.log('Sender: ', sender.address);
        return {
            multisenderContract,
            sender,
            recipients
        };
    }

    it("Should only be accessible by the contract's owner", async function () {
        const { multisenderContract, sender } = await loadFixture(
            deployFixture
        );
        expect(await multisenderContract.getOwner()).to.be.equal(
            sender.address
        );
    });

    it('Should multisend ether to addresses respectively', async function () {
        const { sender, recipients, multisenderContract } = await loadFixture(
            deployFixture
        );

        const addresses: string[] = [
            recipients[0].address,
            recipients[1].address,
            recipients[2].address,
            recipients[3].address,
            recipients[4].address
        ];

        const initialBalances = [
            await ethers.provider.getBalance(addresses[0]),
            await ethers.provider.getBalance(addresses[1]),
            await ethers.provider.getBalance(addresses[2]),
            await ethers.provider.getBalance(addresses[3]),
            await ethers.provider.getBalance(addresses[4])
        ];

        const amounts = [
            ethers.parseEther('10'),
            ethers.parseEther('20'),
            ethers.parseEther('30'),
            ethers.parseEther('40'),
            ethers.parseEther('50')
        ];

        remainingBalance = await multisenderContract.getRemainingBalance();

        await multisenderContract.multiSendEther(addresses, amounts, {
            value: remainingBalance
        });

        const diffInAddr1Balance =
            (await ethers.provider.getBalance(addresses[0])) -
            initialBalances[0];
        const diffInAddr2Balance =
            (await ethers.provider.getBalance(addresses[1])) -
            initialBalances[0];
        const diffInAddr3Balance =
            (await ethers.provider.getBalance(addresses[2])) -
            initialBalances[0];
        const diffInAddr4Balance =
            (await ethers.provider.getBalance(addresses[3])) -
            initialBalances[0];
        const diffInAddr5Balance =
            (await ethers.provider.getBalance(addresses[4])) -
            initialBalances[0];

        expect(diffInAddr1Balance).to.equal(amounts[0]);
        expect(diffInAddr2Balance).to.equal(amounts[1]);
        expect(diffInAddr3Balance).to.equal(amounts[2]);
        expect(diffInAddr4Balance).to.equal(amounts[3]);
        expect(diffInAddr5Balance).to.equal(amounts[4]);
    });
});
