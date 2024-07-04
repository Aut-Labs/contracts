/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type {
  ILocalReputation,
  ILocalReputationInterface,
} from "../ILocalReputation";

const _abi = [
  {
    inputs: [],
    name: "ArgLenMismatch",
    type: "error",
  },
  {
    inputs: [],
    name: "MaxK",
    type: "error",
  },
  {
    inputs: [],
    name: "OnlyAdmin",
    type: "error",
  },
  {
    inputs: [],
    name: "OnlyOnce",
    type: "error",
  },
  {
    inputs: [],
    name: "Over100",
    type: "error",
  },
  {
    inputs: [],
    name: "PeriodUnelapsed",
    type: "error",
  },
  {
    inputs: [],
    name: "Unauthorised",
    type: "error",
  },
  {
    inputs: [],
    name: "Uninitialized",
    type: "error",
  },
  {
    inputs: [],
    name: "UninitializedPair",
    type: "error",
  },
  {
    inputs: [],
    name: "ZeroUnallawed",
    type: "error",
  },
  {
    inputs: [],
    name: "ZeroUnallowed",
    type: "error",
  },
  {
    inputs: [],
    name: "k1MaxPointPerInteraction",
    type: "error",
  },
  {
    anonymous: false,
    inputs: [],
    name: "EndOfPeriod",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "uint256",
        name: "InteractionID",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "address",
        name: "agent",
        type: "address",
      },
    ],
    name: "Interaction",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "Hub",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "PluginAddr",
        type: "address",
      },
    ],
    name: "LocalRepInit",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "plugin",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "interactionId",
        type: "uint256",
      },
    ],
    name: "SetWeightsFor",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "targetGroup",
        type: "address",
      },
    ],
    name: "UpdatedKP",
    type: "event",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "group_",
        type: "address",
      },
    ],
    name: "bulkPeriodicUpdate",
    outputs: [
      {
        internalType: "uint256[]",
        name: "localReputationScores",
        type: "uint256[]",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "iGC",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "iCL",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "TCL",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "TCP",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "k",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "prevScore",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "penalty",
        type: "uint256",
      },
    ],
    name: "calculateLocalReputation",
    outputs: [
      {
        internalType: "uint256",
        name: "score",
        type: "uint256",
      },
    ],
    stateMutability: "pure",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "hub_",
        type: "address",
      },
    ],
    name: "getAvReputationAndCommitment",
    outputs: [
      {
        internalType: "uint256",
        name: "sumCommit",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "sumRep",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "hub_",
        type: "address",
      },
    ],
    name: "getGroupState",
    outputs: [
      {
        components: [
          {
            internalType: "uint64",
            name: "lastPeriod",
            type: "uint64",
          },
          {
            internalType: "uint64",
            name: "TCL",
            type: "uint64",
          },
          {
            internalType: "uint64",
            name: "TCP",
            type: "uint64",
          },
          {
            internalType: "uint16",
            name: "k",
            type: "uint16",
          },
          {
            internalType: "uint8",
            name: "penalty",
            type: "uint8",
          },
          {
            internalType: "uint8",
            name: "c",
            type: "uint8",
          },
          {
            internalType: "uint32",
            name: "p",
            type: "uint32",
          },
          {
            internalType: "bytes32",
            name: "commitHash",
            type: "bytes32",
          },
          {
            internalType: "uint256",
            name: "lrUpdatesPerPeriod",
            type: "uint256",
          },
          {
            components: [
              {
                internalType: "int32",
                name: "aDiffMembersLP",
                type: "int32",
              },
              {
                internalType: "int32",
                name: "bMembersLastLP",
                type: "int32",
              },
              {
                internalType: "uint64",
                name: "cAverageRepLP",
                type: "uint64",
              },
              {
                internalType: "uint64",
                name: "dAverageCommitmentLP",
                type: "uint64",
              },
              {
                internalType: "uint64",
                name: "ePerformanceLP",
                type: "uint64",
              },
            ],
            internalType: "struct periodData",
            name: "periodHubParameters",
            type: "tuple",
          },
        ],
        internalType: "struct groupState",
        name: "",
        type: "tuple",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "agent_",
        type: "address",
      },
      {
        internalType: "address",
        name: "hub_",
        type: "address",
      },
    ],
    name: "getIndividualState",
    outputs: [
      {
        components: [
          {
            internalType: "uint64",
            name: "iCL",
            type: "uint64",
          },
          {
            internalType: "uint64",
            name: "GC",
            type: "uint64",
          },
          {
            internalType: "uint256",
            name: "score",
            type: "uint256",
          },
          {
            internalType: "uint256",
            name: "lastUpdatedAt",
            type: "uint256",
          },
        ],
        internalType: "struct individualState",
        name: "",
        type: "tuple",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "hub_",
        type: "address",
      },
    ],
    name: "getPeriodHubParameters",
    outputs: [
      {
        components: [
          {
            internalType: "int32",
            name: "aDiffMembersLP",
            type: "int32",
          },
          {
            internalType: "int32",
            name: "bMembersLastLP",
            type: "int32",
          },
          {
            internalType: "uint64",
            name: "cAverageRepLP",
            type: "uint64",
          },
          {
            internalType: "uint64",
            name: "dAverageCommitmentLP",
            type: "uint64",
          },
          {
            internalType: "uint64",
            name: "ePerformanceLP",
            type: "uint64",
          },
        ],
        internalType: "struct periodData",
        name: "",
        type: "tuple",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "dao_",
        type: "address",
      },
    ],
    name: "initialize",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes",
        name: "msgData",
        type: "bytes",
      },
      {
        internalType: "address",
        name: "agent",
        type: "address",
      },
    ],
    name: "interaction",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "group_",
        type: "address",
      },
    ],
    name: "periodicGroupStateUpdate",
    outputs: [
      {
        internalType: "uint256",
        name: "nextUpdateAt",
        type: "uint256",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "plugin_",
        type: "address",
      },
      {
        internalType: "bytes[]",
        name: "datas",
        type: "bytes[]",
      },
      {
        internalType: "uint16[]",
        name: "points",
        type: "uint16[]",
      },
    ],
    name: "setInteractionWeights",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint16",
        name: "k",
        type: "uint16",
      },
      {
        internalType: "uint32",
        name: "p",
        type: "uint32",
      },
      {
        internalType: "uint8",
        name: "penalty",
        type: "uint8",
      },
      {
        internalType: "address",
        name: "target_",
        type: "address",
      },
    ],
    name: "setKP",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "hub_",
        type: "address",
      },
    ],
    name: "updateCommitmentLevels",
    outputs: [
      {
        internalType: "uint256[]",
        name: "",
        type: "uint256[]",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "who_",
        type: "address",
      },
      {
        internalType: "address",
        name: "group_",
        type: "address",
      },
    ],
    name: "updateIndividualLR",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
] as const;

export class ILocalReputation__factory {
  static readonly abi = _abi;
  static createInterface(): ILocalReputationInterface {
    return new utils.Interface(_abi) as ILocalReputationInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): ILocalReputation {
    return new Contract(address, _abi, signerOrProvider) as ILocalReputation;
  }
}
