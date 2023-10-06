/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type {
  IAragonApp,
  IAragonAppInterface,
} from "../../IAragon.sol/IAragonApp";

const _abi = [
  {
    inputs: [],
    name: "token",
    outputs: [
      {
        internalType: "contract IMiniMeToken",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
] as const;

export class IAragonApp__factory {
  static readonly abi = _abi;
  static createInterface(): IAragonAppInterface {
    return new utils.Interface(_abi) as IAragonAppInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): IAragonApp {
    return new Contract(address, _abi, signerOrProvider) as IAragonApp;
  }
}