import { BaseContract, ContractInterface } from 'ethers';

export type MultisenderBaseContract = BaseContract &
    Omit<ContractInterface, keyof BaseContract>;
