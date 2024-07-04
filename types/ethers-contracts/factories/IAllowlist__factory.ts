/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { IAllowlist, IAllowlistInterface } from "../IAllowlist";

const _abi = [
  {
    inputs: [],
    name: "AlreadyDeployedAHub",
    type: "error",
  },
  {
    inputs: [],
    name: "AlreadyPlusOne",
    type: "error",
  },
  {
    inputs: [],
    name: "Unallowed",
    type: "error",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "who",
        type: "address",
      },
    ],
    name: "AddedToAllowList",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "who",
        type: "address",
      },
    ],
    name: "RemovedFromAllowList",
    type: "event",
  },
  {
    inputs: [
      {
        internalType: "address[]",
        name: "addrsToAdd_",
        type: "address[]",
      },
    ],
    name: "addBatchToAllowlist",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "owner_",
        type: "address",
      },
    ],
    name: "addOwner",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "addrToAdd_",
        type: "address",
      },
    ],
    name: "addToAllowlist",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "subject",
        type: "address",
      },
    ],
    name: "canAllowList",
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
    inputs: [
      {
        internalType: "address",
        name: "subject",
        type: "address",
      },
    ],
    name: "isAllowListed",
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
    inputs: [
      {
        internalType: "address",
        name: "_addr",
        type: "address",
      },
    ],
    name: "isAllowed",
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
    inputs: [
      {
        internalType: "address",
        name: "subject",
        type: "address",
      },
    ],
    name: "isAllowedOwner",
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
    inputs: [
      {
        internalType: "address",
        name: "subject",
        type: "address",
      },
    ],
    name: "isOwner",
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
    inputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    name: "plusOne",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address[]",
        name: "_addrs",
        type: "address[]",
      },
    ],
    name: "removeBatchFromAllowlist",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "addrToAdd_",
        type: "address",
      },
    ],
    name: "removeFromAllowlist",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
] as const;

export class IAllowlist__factory {
  static readonly abi = _abi;
  static createInterface(): IAllowlistInterface {
    return new utils.Interface(_abi) as IAllowlistInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): IAllowlist {
    return new Contract(address, _abi, signerOrProvider) as IAllowlist;
  }
}
