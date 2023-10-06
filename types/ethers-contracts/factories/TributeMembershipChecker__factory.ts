/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import { Signer, utils, Contract, ContractFactory, Overrides } from "ethers";
import type { Provider, TransactionRequest } from "@ethersproject/providers";
import type {
  TributeMembershipChecker,
  TributeMembershipCheckerInterface,
} from "../TributeMembershipChecker";

const _abi = [
  {
    inputs: [
      {
        internalType: "address",
        name: "daoAddress",
        type: "address",
      },
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

const _bytecode =
  "0x608060405234801561001057600080fd5b5061024c806100206000396000f3fe608060405234801561001057600080fd5b506004361061002b5760003560e01c806339ac7a0814610030575b600080fd5b61004361003e366004610193565b610057565b604051901515815260200160405180910390f35b60006001600160a01b0383166100b45760405162461bcd60e51b815260206004820152601760248201527f41757449443a2064616f4164647265737320656d70747900000000000000000060448201526064015b60405180910390fd5b6001600160a01b0382166101005760405162461bcd60e51b815260206004820152601360248201527241757449443a206d656d62657220656d70747960681b60448201526064016100ab565b60405163022b92c360e21b81526001600160a01b038381166004830152600091908516906308ae4b0c90602401602060405180830381865afa15801561014a573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061016e91906101c6565b51119392505050565b80356001600160a01b038116811461018e57600080fd5b919050565b600080604083850312156101a657600080fd5b6101af83610177565b91506101bd60208401610177565b90509250929050565b6000602082840312156101d857600080fd5b6040516020810181811067ffffffffffffffff8211171561020957634e487b7160e01b600052604160045260246000fd5b604052915182525091905056fea2646970667358221220bc7a0a70f7beab168333afca55f94d02c5627bc6c2feeb9bfc6cf57e6c98181e64736f6c63430008130033";

type TributeMembershipCheckerConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: TributeMembershipCheckerConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class TributeMembershipChecker__factory extends ContractFactory {
  constructor(...args: TributeMembershipCheckerConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
  }

  override deploy(
    overrides?: Overrides & { from?: string }
  ): Promise<TributeMembershipChecker> {
    return super.deploy(overrides || {}) as Promise<TributeMembershipChecker>;
  }
  override getDeployTransaction(
    overrides?: Overrides & { from?: string }
  ): TransactionRequest {
    return super.getDeployTransaction(overrides || {});
  }
  override attach(address: string): TributeMembershipChecker {
    return super.attach(address) as TributeMembershipChecker;
  }
  override connect(signer: Signer): TributeMembershipChecker__factory {
    return super.connect(signer) as TributeMembershipChecker__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): TributeMembershipCheckerInterface {
    return new utils.Interface(_abi) as TributeMembershipCheckerInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): TributeMembershipChecker {
    return new Contract(
      address,
      _abi,
      signerOrProvider
    ) as TributeMembershipChecker;
  }
}