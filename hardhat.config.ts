import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox-viem';
import '@nomicfoundation/hardhat-ethers';
import '@nomicfoundation/hardhat-toolbox';
import '@openzeppelin/hardhat-upgrades';

const config: HardhatUserConfig = {
    solidity: '0.8.20',
    defaultNetwork: 'hardhat'
};

export default config;
