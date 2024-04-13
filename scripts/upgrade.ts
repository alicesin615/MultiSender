import { ethers, upgrades } from 'hardhat';

const UPGRADEABLE_PROXY = '0xEf4c9f5a2e77aD937bEB59E676e77ae57719cae2';

async function main() {
    const MultisenderV2Contract = await ethers.getContractFactory(
        'MultisenderV2'
    );
    console.log('Upgrading V1 Multisender Contract...');
    let upgrade = await upgrades.upgradeProxy(
        UPGRADEABLE_PROXY,
        MultisenderV2Contract
    );
    console.log('V1 Upgraded to V2');
    console.log(
        'V2 Implementation Contract Deployed To:',
        await upgrade.getAddress()
    );
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
