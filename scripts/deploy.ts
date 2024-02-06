import { ethers, upgrades } from 'hardhat';

const initialTotalFunds = process.env.INITIAL_TOTAL_FUNDS || '0';
async function main() {
    const MultisenderContract = await ethers.getContractFactory('Multisender');
    console.log('Deploying Multisender contract...');

    const [sender, ...recipients] = await ethers.getSigners();

    const multisenderContract = await upgrades.deployProxy(
        MultisenderContract,
        [sender.address, ethers.parseEther(initialTotalFunds)],
        {
            initializer: 'initialize'
        }
    );
    await multisenderContract.deployed();
    console.log(
        'Multisender contract deployed to:',
        multisenderContract.address
    );
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
