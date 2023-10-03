/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import { Signer, utils, Contract, ContractFactory, Overrides } from "ethers";
import type { Provider, TransactionRequest } from "@ethersproject/providers";
import type { TestingDAO, TestingDAOInterface } from "../TestingDAO";

const _abi = [
  {
    inputs: [
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
  "0x608060405234801561001057600080fd5b50610117806100206000396000f3fe6080604052348015600f57600080fd5b506004361060285760003560e01c8063a230c52414602d575b600080fd5b603c603836600460b3565b6050565b604051901515815260200160405180910390f35b60006001600160a01b03821660ab5760405162461bcd60e51b815260206004820152601960248201527f5a65726f2061646472657373206e6f742061206d656d62657200000000000000604482015260640160405180910390fd5b506001919050565b60006020828403121560c457600080fd5b81356001600160a01b038116811460da57600080fd5b939250505056fea26469706673582212208abc7783ed227f7ba483fb4913314215421667b60e5010cc1df107853be58f0564736f6c63430008130033";

type TestingDAOConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: TestingDAOConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class TestingDAO__factory extends ContractFactory {
  constructor(...args: TestingDAOConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
  }

  override deploy(
    overrides?: Overrides & { from?: string }
  ): Promise<TestingDAO> {
    return super.deploy(overrides || {}) as Promise<TestingDAO>;
  }
  override getDeployTransaction(
    overrides?: Overrides & { from?: string }
  ): TransactionRequest {
    return super.getDeployTransaction(overrides || {});
  }
  override attach(address: string): TestingDAO {
    return super.attach(address) as TestingDAO;
  }
  override connect(signer: Signer): TestingDAO__factory {
    return super.connect(signer) as TestingDAO__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): TestingDAOInterface {
    return new utils.Interface(_abi) as TestingDAOInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): TestingDAO {
    return new Contract(address, _abi, signerOrProvider) as TestingDAO;
  }
}
