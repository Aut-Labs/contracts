/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import type {
  BaseContract,
  BigNumber,
  BigNumberish,
  BytesLike,
  CallOverrides,
  ContractTransaction,
  Overrides,
  PopulatedTransaction,
  Signer,
  utils,
} from "ethers";
import type {
  FunctionFragment,
  Result,
  EventFragment,
} from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type {
  TypedEventFilter,
  TypedEvent,
  TypedListener,
  OnEvent,
} from "./common";

export interface DAOTypesInterface extends utils.Interface {
  functions: {
    "addNewMembershipChecker(address)": FunctionFragment;
    "getMembershipCheckerAddress(uint256)": FunctionFragment;
    "isMembershipChecker(address)": FunctionFragment;
    "owner()": FunctionFragment;
    "renounceOwnership()": FunctionFragment;
    "transferOwnership(address)": FunctionFragment;
    "typeToMembershipChecker(uint256)": FunctionFragment;
    "typesCount()": FunctionFragment;
  };

  getFunction(
    nameOrSignatureOrTopic:
      | "addNewMembershipChecker"
      | "getMembershipCheckerAddress"
      | "isMembershipChecker"
      | "owner"
      | "renounceOwnership"
      | "transferOwnership"
      | "typeToMembershipChecker"
      | "typesCount"
  ): FunctionFragment;

  encodeFunctionData(
    functionFragment: "addNewMembershipChecker",
    values: [string]
  ): string;
  encodeFunctionData(
    functionFragment: "getMembershipCheckerAddress",
    values: [BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "isMembershipChecker",
    values: [string]
  ): string;
  encodeFunctionData(functionFragment: "owner", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "renounceOwnership",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "transferOwnership",
    values: [string]
  ): string;
  encodeFunctionData(
    functionFragment: "typeToMembershipChecker",
    values: [BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "typesCount",
    values?: undefined
  ): string;

  decodeFunctionResult(
    functionFragment: "addNewMembershipChecker",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getMembershipCheckerAddress",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "isMembershipChecker",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "owner", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "renounceOwnership",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "transferOwnership",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "typeToMembershipChecker",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "typesCount", data: BytesLike): Result;

  events: {
    "DAOTypeAdded(uint256,address)": EventFragment;
    "OwnershipTransferred(address,address)": EventFragment;
  };

  getEvent(nameOrSignatureOrTopic: "DAOTypeAdded"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "OwnershipTransferred"): EventFragment;
}

export interface DAOTypeAddedEventObject {
  daoType: BigNumber;
  membershipCheckerAddress: string;
}
export type DAOTypeAddedEvent = TypedEvent<
  [BigNumber, string],
  DAOTypeAddedEventObject
>;

export type DAOTypeAddedEventFilter = TypedEventFilter<DAOTypeAddedEvent>;

export interface OwnershipTransferredEventObject {
  previousOwner: string;
  newOwner: string;
}
export type OwnershipTransferredEvent = TypedEvent<
  [string, string],
  OwnershipTransferredEventObject
>;

export type OwnershipTransferredEventFilter =
  TypedEventFilter<OwnershipTransferredEvent>;

export interface DAOTypes extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: DAOTypesInterface;

  queryFilter<TEvent extends TypedEvent>(
    event: TypedEventFilter<TEvent>,
    fromBlockOrBlockhash?: string | number | undefined,
    toBlock?: string | number | undefined
  ): Promise<Array<TEvent>>;

  listeners<TEvent extends TypedEvent>(
    eventFilter?: TypedEventFilter<TEvent>
  ): Array<TypedListener<TEvent>>;
  listeners(eventName?: string): Array<Listener>;
  removeAllListeners<TEvent extends TypedEvent>(
    eventFilter: TypedEventFilter<TEvent>
  ): this;
  removeAllListeners(eventName?: string): this;
  off: OnEvent<this>;
  on: OnEvent<this>;
  once: OnEvent<this>;
  removeListener: OnEvent<this>;

  functions: {
    addNewMembershipChecker(
      membershipChecker: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    getMembershipCheckerAddress(
      daoType: BigNumberish,
      overrides?: CallOverrides
    ): Promise<[string]>;

    isMembershipChecker(
      arg0: string,
      overrides?: CallOverrides
    ): Promise<[boolean]>;

    owner(overrides?: CallOverrides): Promise<[string]>;

    renounceOwnership(
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    transferOwnership(
      newOwner: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    typeToMembershipChecker(
      arg0: BigNumberish,
      overrides?: CallOverrides
    ): Promise<[string]>;

    typesCount(overrides?: CallOverrides): Promise<[BigNumber]>;
  };

  addNewMembershipChecker(
    membershipChecker: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  getMembershipCheckerAddress(
    daoType: BigNumberish,
    overrides?: CallOverrides
  ): Promise<string>;

  isMembershipChecker(
    arg0: string,
    overrides?: CallOverrides
  ): Promise<boolean>;

  owner(overrides?: CallOverrides): Promise<string>;

  renounceOwnership(
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  transferOwnership(
    newOwner: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  typeToMembershipChecker(
    arg0: BigNumberish,
    overrides?: CallOverrides
  ): Promise<string>;

  typesCount(overrides?: CallOverrides): Promise<BigNumber>;

  callStatic: {
    addNewMembershipChecker(
      membershipChecker: string,
      overrides?: CallOverrides
    ): Promise<void>;

    getMembershipCheckerAddress(
      daoType: BigNumberish,
      overrides?: CallOverrides
    ): Promise<string>;

    isMembershipChecker(
      arg0: string,
      overrides?: CallOverrides
    ): Promise<boolean>;

    owner(overrides?: CallOverrides): Promise<string>;

    renounceOwnership(overrides?: CallOverrides): Promise<void>;

    transferOwnership(
      newOwner: string,
      overrides?: CallOverrides
    ): Promise<void>;

    typeToMembershipChecker(
      arg0: BigNumberish,
      overrides?: CallOverrides
    ): Promise<string>;

    typesCount(overrides?: CallOverrides): Promise<BigNumber>;
  };

  filters: {
    "DAOTypeAdded(uint256,address)"(
      daoType?: null,
      membershipCheckerAddress?: null
    ): DAOTypeAddedEventFilter;
    DAOTypeAdded(
      daoType?: null,
      membershipCheckerAddress?: null
    ): DAOTypeAddedEventFilter;

    "OwnershipTransferred(address,address)"(
      previousOwner?: string | null,
      newOwner?: string | null
    ): OwnershipTransferredEventFilter;
    OwnershipTransferred(
      previousOwner?: string | null,
      newOwner?: string | null
    ): OwnershipTransferredEventFilter;
  };

  estimateGas: {
    addNewMembershipChecker(
      membershipChecker: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    getMembershipCheckerAddress(
      daoType: BigNumberish,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    isMembershipChecker(
      arg0: string,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    owner(overrides?: CallOverrides): Promise<BigNumber>;

    renounceOwnership(
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    transferOwnership(
      newOwner: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    typeToMembershipChecker(
      arg0: BigNumberish,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    typesCount(overrides?: CallOverrides): Promise<BigNumber>;
  };

  populateTransaction: {
    addNewMembershipChecker(
      membershipChecker: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    getMembershipCheckerAddress(
      daoType: BigNumberish,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    isMembershipChecker(
      arg0: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    owner(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    renounceOwnership(
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    transferOwnership(
      newOwner: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    typeToMembershipChecker(
      arg0: BigNumberish,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    typesCount(overrides?: CallOverrides): Promise<PopulatedTransaction>;
  };
}