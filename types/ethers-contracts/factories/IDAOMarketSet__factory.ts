/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { IDAOMarketSet, IDAOMarketSetInterface } from "../IDAOMarketSet";

const _abi = [
  {
    inputs: [
      {
        internalType: "uint256",
        name: "market",
        type: "uint256",
      },
    ],
    name: "setMarket",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
] as const;

export class IDAOMarketSet__factory {
  static readonly abi = _abi;
  static createInterface(): IDAOMarketSetInterface {
    return new utils.Interface(_abi) as IDAOMarketSetInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): IDAOMarketSet {
    return new Contract(address, _abi, signerOrProvider) as IDAOMarketSet;
  }
}
