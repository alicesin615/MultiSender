import { ethers, upgrades } from 'hardhat';
import { expect } from 'chai';
import { BaseContract, ContractInterface } from 'ethers';
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

    async function deployFixture() {
        const MultisenderContract = await ethers.getContractFactory(
            'Multisender'
        );
        [sender, ...recipients] = await ethers.getSigners();
        multisenderContract = await upgrades.deployProxy(
            MultisenderContract,
            [sender.address],
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
});
