/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import { Signer, utils, Contract, ContractFactory, Overrides } from "ethers";
import type { Provider, TransactionRequest } from "@ethersproject/providers";
import type {
  NewMembershipChecker,
  NewMembershipCheckerInterface,
} from "../NewMembershipChecker";

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
  "0x608060405234801561001057600080fd5b5061018e806100206000396000f3fe608060405234801561001057600080fd5b506004361061002b5760003560e01c806339ac7a0814610030575b600080fd5b61004361003e366004610125565b610057565b604051901515815260200160405180910390f35b60006001600160a01b0383166100b45760405162461bcd60e51b815260206004820152601760248201527f41757449443a2064616f4164647265737320656d70747900000000000000000060448201526064015b60405180910390fd5b6001600160a01b0382166101005760405162461bcd60e51b815260206004820152601360248201527241757449443a206d656d62657220656d70747960681b60448201526064016100ab565b50600092915050565b80356001600160a01b038116811461012057600080fd5b919050565b6000806040838503121561013857600080fd5b61014183610109565b915061014f60208401610109565b9050925092905056fea2646970667358221220fe37c071fc556e2cce537e31ac91f861c66d610f8d3613715ab59c6a3b62cb4a64736f6c63430008130033";

type NewMembershipCheckerConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: NewMembershipCheckerConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class NewMembershipChecker__factory extends ContractFactory {
  constructor(...args: NewMembershipCheckerConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
  }

  override deploy(
    overrides?: Overrides & { from?: string }
  ): Promise<NewMembershipChecker> {
    return super.deploy(overrides || {}) as Promise<NewMembershipChecker>;
  }
  override getDeployTransaction(
    overrides?: Overrides & { from?: string }
  ): TransactionRequest {
    return super.getDeployTransaction(overrides || {});
  }
  override attach(address: string): NewMembershipChecker {
    return super.attach(address) as NewMembershipChecker;
  }
  override connect(signer: Signer): NewMembershipChecker__factory {
    return super.connect(signer) as NewMembershipChecker__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): NewMembershipCheckerInterface {
    return new utils.Interface(_abi) as NewMembershipCheckerInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): NewMembershipChecker {
    return new Contract(
      address,
      _abi,
      signerOrProvider
    ) as NewMembershipChecker;
  }
}