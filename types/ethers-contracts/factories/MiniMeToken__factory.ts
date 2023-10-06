/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import {
  Signer,
  utils,
  Contract,
  ContractFactory,
  PayableOverrides,
  BigNumberish,
} from "ethers";
import type { Provider, TransactionRequest } from "@ethersproject/providers";
import type { MiniMeToken, MiniMeTokenInterface } from "../MiniMeToken";

const _abi = [
  {
    inputs: [
      {
        internalType: "string",
        name: "name",
        type: "string",
      },
      {
        internalType: "string",
        name: "symbol",
        type: "string",
      },
      {
        internalType: "address",
        name: "initialAccount",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "totalSupply",
        type: "uint256",
      },
    ],
    stateMutability: "payable",
    type: "constructor",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "owner",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "spender",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "value",
        type: "uint256",
      },
    ],
    name: "Approval",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "from",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "to",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "value",
        type: "uint256",
      },
    ],
    name: "Transfer",
    type: "event",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "owner",
        type: "address",
      },
      {
        internalType: "address",
        name: "spender",
        type: "address",
      },
    ],
    name: "allowance",
    outputs: [
      {
        internalType: "uint256",
        name: "",
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
        name: "spender",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "approve",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "account",
        type: "address",
      },
    ],
    name: "balanceOf",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "decimals",
    outputs: [
      {
        internalType: "uint8",
        name: "",
        type: "uint8",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "spender",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "subtractedValue",
        type: "uint256",
      },
    ],
    name: "decreaseAllowance",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "spender",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "addedValue",
        type: "uint256",
      },
    ],
    name: "increaseAllowance",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "name",
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
  {
    inputs: [],
    name: "symbol",
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
  {
    inputs: [],
    name: "totalSupply",
    outputs: [
      {
        internalType: "uint256",
        name: "",
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
        name: "to",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "transfer",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "from",
        type: "address",
      },
      {
        internalType: "address",
        name: "to",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "transferFrom",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "from",
        type: "address",
      },
      {
        internalType: "address",
        name: "to",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "value",
        type: "uint256",
      },
    ],
    name: "transferInternal",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
] as const;

const _bytecode =
  "0x608060405260405162000ceb38038062000ceb83398101604081905262000026916200021e565b83838383838360036200003a83826200033f565b5060046200004982826200033f565b5050506200005e82826200006c60201b60201c565b505050505050505062000433565b6001600160a01b038216620000c75760405162461bcd60e51b815260206004820152601f60248201527f45524332303a206d696e7420746f20746865207a65726f206164647265737300604482015260640160405180910390fd5b8060026000828254620000db91906200040b565b90915550506001600160a01b038216600090815260208190526040812080548392906200010a9084906200040b565b90915550506040518181526001600160a01b038316906000907fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef9060200160405180910390a35050565b505050565b634e487b7160e01b600052604160045260246000fd5b600082601f8301126200018157600080fd5b81516001600160401b03808211156200019e576200019e62000159565b604051601f8301601f19908116603f01168101908282118183101715620001c957620001c962000159565b81604052838152602092508683858801011115620001e657600080fd5b600091505b838210156200020a5785820183015181830184015290820190620001eb565b600093810190920192909252949350505050565b600080600080608085870312156200023557600080fd5b84516001600160401b03808211156200024d57600080fd5b6200025b888389016200016f565b955060208701519150808211156200027257600080fd5b5062000281878288016200016f565b604087015190945090506001600160a01b0381168114620002a157600080fd5b6060959095015193969295505050565b600181811c90821680620002c657607f821691505b602082108103620002e757634e487b7160e01b600052602260045260246000fd5b50919050565b601f8211156200015457600081815260208120601f850160051c81016020861015620003165750805b601f850160051c820191505b81811015620003375782815560010162000322565b505050505050565b81516001600160401b038111156200035b576200035b62000159565b62000373816200036c8454620002b1565b84620002ed565b602080601f831160018114620003ab5760008415620003925750858301515b600019600386901b1c1916600185901b17855562000337565b600085815260208120601f198616915b82811015620003dc57888601518255948401946001909101908401620003bb565b5085821015620003fb5787850151600019600388901b60f8161c191681555b5050505050600190811b01905550565b808201808211156200042d57634e487b7160e01b600052601160045260246000fd5b92915050565b6108a880620004436000396000f3fe608060405234801561001057600080fd5b50600436106100b45760003560e01c80633950935111610071578063395093511461014357806370a082311461015657806395d89b411461017f578063a457c2d714610187578063a9059cbb1461019a578063dd62ed3e146101ad57600080fd5b806306fdde03146100b9578063095ea7b3146100d757806318160ddd146100fa578063222f5be01461010c57806323b872dd14610121578063313ce56714610134575b600080fd5b6100c16101c0565b6040516100ce91906106f2565b60405180910390f35b6100ea6100e536600461075c565b610252565b60405190151581526020016100ce565b6002545b6040519081526020016100ce565b61011f61011a366004610786565b61026c565b005b6100ea61012f366004610786565b61027c565b604051601281526020016100ce565b6100ea61015136600461075c565b6102a0565b6100fe6101643660046107c2565b6001600160a01b031660009081526020819052604090205490565b6100c16102c2565b6100ea61019536600461075c565b6102d1565b6100ea6101a836600461075c565b610351565b6100fe6101bb3660046107e4565b61035f565b6060600380546101cf90610817565b80601f01602080910402602001604051908101604052809291908181526020018280546101fb90610817565b80156102485780601f1061021d57610100808354040283529160200191610248565b820191906000526020600020905b81548152906001019060200180831161022b57829003601f168201915b5050505050905090565b60003361026081858561038a565b60019150505b92915050565b6102778383836104ae565b505050565b60003361028a85828561067e565b6102958585856104ae565b506001949350505050565b6000336102608185856102b3838361035f565b6102bd9190610851565b61038a565b6060600480546101cf90610817565b600033816102df828661035f565b9050838110156103445760405162461bcd60e51b815260206004820152602560248201527f45524332303a2064656372656173656420616c6c6f77616e63652062656c6f77604482015264207a65726f60d81b60648201526084015b60405180910390fd5b610295828686840361038a565b6000336102608185856104ae565b6001600160a01b03918216600090815260016020908152604080832093909416825291909152205490565b6001600160a01b0383166103ec5760405162461bcd60e51b8152602060048201526024808201527f45524332303a20617070726f76652066726f6d20746865207a65726f206164646044820152637265737360e01b606482015260840161033b565b6001600160a01b03821661044d5760405162461bcd60e51b815260206004820152602260248201527f45524332303a20617070726f766520746f20746865207a65726f206164647265604482015261737360f01b606482015260840161033b565b6001600160a01b0383811660008181526001602090815260408083209487168084529482529182902085905590518481527f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925910160405180910390a3505050565b6001600160a01b0383166105125760405162461bcd60e51b815260206004820152602560248201527f45524332303a207472616e736665722066726f6d20746865207a65726f206164604482015264647265737360d81b606482015260840161033b565b6001600160a01b0382166105745760405162461bcd60e51b815260206004820152602360248201527f45524332303a207472616e7366657220746f20746865207a65726f206164647260448201526265737360e81b606482015260840161033b565b6001600160a01b038316600090815260208190526040902054818110156105ec5760405162461bcd60e51b815260206004820152602660248201527f45524332303a207472616e7366657220616d6f756e7420657863656564732062604482015265616c616e636560d01b606482015260840161033b565b6001600160a01b03808516600090815260208190526040808220858503905591851681529081208054849290610623908490610851565b92505081905550826001600160a01b0316846001600160a01b03167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef8460405161066f91815260200190565b60405180910390a35b50505050565b600061068a848461035f565b9050600019811461067857818110156106e55760405162461bcd60e51b815260206004820152601d60248201527f45524332303a20696e73756666696369656e7420616c6c6f77616e6365000000604482015260640161033b565b610678848484840361038a565b600060208083528351808285015260005b8181101561071f57858101830151858201604001528201610703565b506000604082860101526040601f19601f8301168501019250505092915050565b80356001600160a01b038116811461075757600080fd5b919050565b6000806040838503121561076f57600080fd5b61077883610740565b946020939093013593505050565b60008060006060848603121561079b57600080fd5b6107a484610740565b92506107b260208501610740565b9150604084013590509250925092565b6000602082840312156107d457600080fd5b6107dd82610740565b9392505050565b600080604083850312156107f757600080fd5b61080083610740565b915061080e60208401610740565b90509250929050565b600181811c9082168061082b57607f821691505b60208210810361084b57634e487b7160e01b600052602260045260246000fd5b50919050565b8082018082111561026657634e487b7160e01b600052601160045260246000fdfea2646970667358221220bb3ee10b73d24fc317a7b3ad072b0d88352fca92dd492ee1ba25a0cf6b60c51164736f6c63430008130033";

type MiniMeTokenConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: MiniMeTokenConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class MiniMeToken__factory extends ContractFactory {
  constructor(...args: MiniMeTokenConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
  }

  override deploy(
    name: string,
    symbol: string,
    initialAccount: string,
    totalSupply: BigNumberish,
    overrides?: PayableOverrides & { from?: string }
  ): Promise<MiniMeToken> {
    return super.deploy(
      name,
      symbol,
      initialAccount,
      totalSupply,
      overrides || {}
    ) as Promise<MiniMeToken>;
  }
  override getDeployTransaction(
    name: string,
    symbol: string,
    initialAccount: string,
    totalSupply: BigNumberish,
    overrides?: PayableOverrides & { from?: string }
  ): TransactionRequest {
    return super.getDeployTransaction(
      name,
      symbol,
      initialAccount,
      totalSupply,
      overrides || {}
    );
  }
  override attach(address: string): MiniMeToken {
    return super.attach(address) as MiniMeToken;
  }
  override connect(signer: Signer): MiniMeToken__factory {
    return super.connect(signer) as MiniMeToken__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): MiniMeTokenInterface {
    return new utils.Interface(_abi) as MiniMeTokenInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): MiniMeToken {
    return new Contract(address, _abi, signerOrProvider) as MiniMeToken;
  }
}
