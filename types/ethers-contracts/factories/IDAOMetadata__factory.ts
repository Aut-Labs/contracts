/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { IDAOMetadata, IDAOMetadataInterface } from "../IDAOMetadata";

const _abi = [
  {
    inputs: [],
    name: "metadataUrl",
    outputs: [
      {
        internalType: "string",
        name: "uri",
        type: "string",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
] as const;

export class IDAOMetadata__factory {
  static readonly abi = _abi;
  static createInterface(): IDAOMetadataInterface {
    return new utils.Interface(_abi) as IDAOMetadataInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): IDAOMetadata {
    return new Contract(address, _abi, signerOrProvider) as IDAOMetadata;
  }
}
