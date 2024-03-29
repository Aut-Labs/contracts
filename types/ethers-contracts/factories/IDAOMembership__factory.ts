/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type {
  IDAOMembership,
  IDAOMembershipInterface,
} from "../IDAOMembership";

const _abi = [
  {
    inputs: [
      {
        internalType: "address",
        name: "member",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "role",
        type: "uint256",
      },
    ],
    name: "canJoin",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "getAllMembers",
    outputs: [
      {
        internalType: "address[]",
        name: "",
        type: "address[]",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "member",
        type: "address",
      },
    ],
    name: "isMember",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
] as const;

export class IDAOMembership__factory {
  static readonly abi = _abi;
  static createInterface(): IDAOMembershipInterface {
    return new utils.Interface(_abi) as IDAOMembershipInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): IDAOMembership {
    return new Contract(address, _abi, signerOrProvider) as IDAOMembership;
  }
}
