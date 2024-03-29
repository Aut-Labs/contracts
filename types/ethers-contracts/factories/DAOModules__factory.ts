/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { DAOModules, DAOModulesInterface } from "../DAOModules";

const _abi = [
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "uint256",
        name: "moduleId",
        type: "uint256",
      },
    ],
    name: "ModuleActivated",
    type: "event",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "moduleId",
        type: "uint256",
      },
    ],
    name: "activateModule",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "moduleId",
        type: "uint256",
      },
    ],
    name: "isModuleActivated",
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
    name: "pluginRegistry",
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
] as const;

export class DAOModules__factory {
  static readonly abi = _abi;
  static createInterface(): DAOModulesInterface {
    return new utils.Interface(_abi) as DAOModulesInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): DAOModules {
    return new Contract(address, _abi, signerOrProvider) as DAOModules;
  }
}
