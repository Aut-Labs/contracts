/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { IDAOURLSet, IDAOURLSetInterface } from "../IDAOURLSet";

const _abi = [
  {
    inputs: [
      {
        internalType: "string",
        name: "_url",
        type: "string",
      },
    ],
    name: "addURL",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "string",
        name: "_url",
        type: "string",
      },
    ],
    name: "removeURL",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
] as const;

export class IDAOURLSet__factory {
  static readonly abi = _abi;
  static createInterface(): IDAOURLSetInterface {
    return new utils.Interface(_abi) as IDAOURLSetInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): IDAOURLSet {
    return new Contract(address, _abi, signerOrProvider) as IDAOURLSet;
  }
}
