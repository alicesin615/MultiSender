import { ethers, upgrades } from 'hardhat';
import { expect } from 'chai';
import { BaseContract, BigNumberish } from 'ethers';
import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import type {
    HardhatEthersSigner,
    SignerWithAddress
} from '@nomicfoundation/hardhat-ethers/signers';
import { MultisenderBaseContract } from '../models/contracts.model';

describe('MultisenderV2', function () {
    let multisenderV1Contract: MultisenderBaseContract;
    let multisenderV2Contract: MultisenderBaseContract;
    // let nonOwnerContractInstance: BaseContract;
    let sender: HardhatEthersSigner;
    let recipients: SignerWithAddress[];
    let remainingBalance: BigNumberish | null | undefined;

    const initialTotalFunds = 1000;

    async function deployFixture() {
        const MultisenderV1Contract = await ethers.getContractFactory(
            'Multisender'
        );

        [sender, ...recipients] = await ethers.getSigners();

        multisenderV1Contract = await upgrades.deployProxy(
            MultisenderV1Contract,
            [sender.address, ethers.parseEther(String(initialTotalFunds))],
            {
                initializer: 'initialize'
            }
        );
        const UPGRADEABLE_PROXY = await multisenderV1Contract.getAddress();
        console.log('Upgradable proxy: ', UPGRADEABLE_PROXY);

        const MultisenderV2Contract = await ethers.getContractFactory(
            'MultisenderV2'
        );
        multisenderV2Contract = await upgrades.upgradeProxy(
            UPGRADEABLE_PROXY,
            MultisenderV2Contract
        );

        console.log(
            'MultisenderV2 owner address:',
            await multisenderV2Contract.getOwner()
        );
        console.log(
            'MultisenderV2 initial balance: ',
            await multisenderV2Contract.getRemainingBalance()
        );

        const MockUSDTContract = await ethers.getContractFactory('MockUSDT');
        const mockUSDTContract = await MockUSDTContract.deploy();

        return {
            multisenderV2Contract,
            mockUSDTContract,
            sender,
            recipients
        };
    }

    it('Should only be accessible by owner', async function () {
        const { multisenderV2Contract, sender } = await loadFixture(
            deployFixture
        );
        expect(await multisenderV2Contract.getOwner()).to.be.equal(
            sender.address
        );
    });
});
