/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { INovaFactory, INovaFactoryInterface } from "../INovaFactory";

const _abi = [
  {
    inputs: [
      {
        internalType: "address",
        name: "deployer",
        type: "address",
      },
      {
        internalType: "address",
        name: "autIDAddr",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "market",
        type: "uint256",
      },
      {
        internalType: "string",
        name: "metadata",
        type: "string",
      },
      {
        internalType: "uint256",
        name: "commitment",
        type: "uint256",
      },
      {
        internalType: "address",
        name: "pluginRegistry",
        type: "address",
      },
    ],
    name: "deployNova",
    outputs: [
      {
        internalType: "address",
        name: "_nova",
        type: "address",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
] as const;

export class INovaFactory__factory {
  static readonly abi = _abi;
  static createInterface(): INovaFactoryInterface {
    return new utils.Interface(_abi) as INovaFactoryInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): INovaFactory {
    return new Contract(address, _abi, signerOrProvider) as INovaFactory;
  }
}
