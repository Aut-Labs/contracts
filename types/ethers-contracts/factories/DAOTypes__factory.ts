/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import { Signer, utils, Contract, ContractFactory, Overrides } from "ethers";
import type { Provider, TransactionRequest } from "@ethersproject/providers";
import type { DAOTypes, DAOTypesInterface } from "../DAOTypes";

const _abi = [
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "uint256",
        name: "daoType",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "address",
        name: "membershipCheckerAddress",
        type: "address",
      },
    ],
    name: "DAOTypeAdded",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "previousOwner",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "newOwner",
        type: "address",
      },
    ],
    name: "OwnershipTransferred",
    type: "event",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "membershipChecker",
        type: "address",
      },
    ],
    name: "addNewMembershipChecker",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "daoType",
        type: "uint256",
      },
    ],
    name: "getMembershipCheckerAddress",
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
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    name: "isMembershipChecker",
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
    name: "owner",
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
    inputs: [],
    name: "renounceOwnership",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "newOwner",
        type: "address",
      },
    ],
    name: "transferOwnership",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    name: "typeToMembershipChecker",
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
    inputs: [],
    name: "typesCount",
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
] as const;

const _bytecode =
  "0x608060405234801561001057600080fd5b5061001a3361001f565b61006f565b600080546001600160a01b038381166001600160a01b0319831681178455604051919092169283917f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e09190a35050565b6104de8061007e6000396000f3fe608060405234801561001057600080fd5b50600436106100885760003560e01c8063715018a61161005b578063715018a6146101315780638da5cb5b14610139578063979a607e1461014a578063f2fde38b1461017357600080fd5b80634e12c7ce1461008d5780634e862492146100a25780634edf6fe0146100da5780636251191f146100f0575b600080fd5b6100a061009b36600461045f565b610186565b005b6100c56100b036600461045f565b60036020526000908152604090205460ff1681565b60405190151581526020015b60405180910390f35b6100e2610318565b6040519081526020016100d1565b6101196100fe36600461048f565b6002602052600090815260409020546001600160a01b031681565b6040516001600160a01b0390911681526020016100d1565b6100a0610328565b6000546001600160a01b0316610119565b61011961015836600461048f565b6000908152600260205260409020546001600160a01b031690565b6100a061018136600461045f565b61033c565b61018e6103b5565b6001600160a01b0381166102055760405162461bcd60e51b815260206004820152603360248201527f4d656d62657273686970436865636b657220636f6e74726163742061646472656044820152721cdcc81b5d5cdd081899481c1c9bdd9a591959606a1b60648201526084015b60405180910390fd5b6001600160a01b03811660009081526003602052604090205460ff161561026e5760405162461bcd60e51b815260206004820152601f60248201527f4d656d62657273686970436865636b657220616c72656164792061646465640060448201526064016101fc565b61027c600180546001019055565b806002600061028a60015490565b81526020808201929092526040908101600090812080546001600160a01b0319166001600160a01b03958616179055928416835260039091529020805460ff19166001908117909155547fdccc0bef10080086bbc26f7f9f19b40614526b4af7554e79f4b67440f6393f1190604080519182526001600160a01b03841660208301520160405180910390a150565b600061032360015490565b905090565b6103306103b5565b61033a600061040f565b565b6103446103b5565b6001600160a01b0381166103a95760405162461bcd60e51b815260206004820152602660248201527f4f776e61626c653a206e6577206f776e657220697320746865207a65726f206160448201526564647265737360d01b60648201526084016101fc565b6103b28161040f565b50565b6000546001600160a01b0316331461033a5760405162461bcd60e51b815260206004820181905260248201527f4f776e61626c653a2063616c6c6572206973206e6f7420746865206f776e657260448201526064016101fc565b600080546001600160a01b038381166001600160a01b0319831681178455604051919092169283917f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e09190a35050565b60006020828403121561047157600080fd5b81356001600160a01b038116811461048857600080fd5b9392505050565b6000602082840312156104a157600080fd5b503591905056fea2646970667358221220576788553ff319825f1cfd8791ffebc1bb728d4d41154ce80e7125976a25e9c364736f6c63430008130033";

type DAOTypesConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: DAOTypesConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class DAOTypes__factory extends ContractFactory {
  constructor(...args: DAOTypesConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
  }

  override deploy(
    overrides?: Overrides & { from?: string }
  ): Promise<DAOTypes> {
    return super.deploy(overrides || {}) as Promise<DAOTypes>;
  }
  override getDeployTransaction(
    overrides?: Overrides & { from?: string }
  ): TransactionRequest {
    return super.getDeployTransaction(overrides || {});
  }
  override attach(address: string): DAOTypes {
    return super.attach(address) as DAOTypes;
  }
  override connect(signer: Signer): DAOTypes__factory {
    return super.connect(signer) as DAOTypes__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): DAOTypesInterface {
    return new utils.Interface(_abi) as DAOTypesInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): DAOTypes {
    return new Contract(address, _abi, signerOrProvider) as DAOTypes;
  }
}
