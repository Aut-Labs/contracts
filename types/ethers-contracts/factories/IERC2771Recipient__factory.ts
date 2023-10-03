/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type {
  IERC2771Recipient,
  IERC2771RecipientInterface,
} from "../IERC2771Recipient";

const _abi = [
  {
    inputs: [
      {
        internalType: "address",
        name: "forwarder",
        type: "address",
      },
    ],
    name: "isTrustedForwarder",
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

export class IERC2771Recipient__factory {
  static readonly abi = _abi;
  static createInterface(): IERC2771RecipientInterface {
    return new utils.Interface(_abi) as IERC2771RecipientInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): IERC2771Recipient {
    return new Contract(address, _abi, signerOrProvider) as IERC2771Recipient;
  }
}
