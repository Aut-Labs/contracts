/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { DAOMetadata, DAOMetadataInterface } from "../DAOMetadata";

const _abi = [
  {
    anonymous: false,
    inputs: [],
    name: "MetadataUriUpdated",
    type: "event",
  },
  {
    inputs: [],
    name: "metadataUrl",
    outputs: [
      {
        internalType: "string",
        name: "",
        type: "string",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
] as const;

export class DAOMetadata__factory {
  static readonly abi = _abi;
  static createInterface(): DAOMetadataInterface {
    return new utils.Interface(_abi) as DAOMetadataInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): DAOMetadata {
    return new Contract(address, _abi, signerOrProvider) as DAOMetadata;
  }
}
