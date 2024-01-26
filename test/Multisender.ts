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

    async function deployFixture() {
        const MultisenderContract = await ethers.getContractFactory(
            'Multisender'
        );
        [sender, ...recipients] = await ethers.getSigners();
        multisenderContract = await upgrades.deployProxy(
            MultisenderContract,
            [sender.address, ethers.parseEther('1000')],
            {
                initializer: 'initialize'
            }
        );

        console.log(
            'Multisender deployed to:',
            await multisenderContract.getAddress()
        );
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

        const balanceAddr1 = await (
            await ethers.getSigner(addresses[0])
        ).provider.getBalance(addresses[0]);

        expect(
            /* @ts-ignore */
            await balanceAddr1.to.equal(amounts[0])
        );
    });
});
