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

export declare namespace IDAOExpanderData {
  export type DAOExpanssionDataStruct = {
    contractType: BigNumberish;
    daoAddress: string;
  };

  export type DAOExpanssionDataStructOutput = [BigNumber, string] & {
    contractType: BigNumber;
    daoAddress: string;
  };
}

export interface IDAOExpanderInterface extends utils.Interface {
  functions: {
    "addURL(string)": FunctionFragment;
    "canJoin(address,uint256)": FunctionFragment;
    "getAdmins()": FunctionFragment;
    "getAllMembers()": FunctionFragment;
    "getAutIDAddress()": FunctionFragment;
    "getCommitment()": FunctionFragment;
    "getDAOData()": FunctionFragment;
    "getURLs()": FunctionFragment;
    "isAdmin(address)": FunctionFragment;
    "isMember(address)": FunctionFragment;
    "isMemberOfOriginalDAO(address)": FunctionFragment;
    "isURLListed(string)": FunctionFragment;
    "removeURL(string)": FunctionFragment;
    "setCommitment(uint256)": FunctionFragment;
    "setMetadataUri(string)": FunctionFragment;
  };

  getFunction(
    nameOrSignatureOrTopic:
      | "addURL"
      | "canJoin"
      | "getAdmins"
      | "getAllMembers"
      | "getAutIDAddress"
      | "getCommitment"
      | "getDAOData"
      | "getURLs"
      | "isAdmin"
      | "isMember"
      | "isMemberOfOriginalDAO"
      | "isURLListed"
      | "removeURL"
      | "setCommitment"
      | "setMetadataUri"
  ): FunctionFragment;

  encodeFunctionData(functionFragment: "addURL", values: [string]): string;
  encodeFunctionData(
    functionFragment: "canJoin",
    values: [string, BigNumberish]
  ): string;
  encodeFunctionData(functionFragment: "getAdmins", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "getAllMembers",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "getAutIDAddress",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "getCommitment",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "getDAOData",
    values?: undefined
  ): string;
  encodeFunctionData(functionFragment: "getURLs", values?: undefined): string;
  encodeFunctionData(functionFragment: "isAdmin", values: [string]): string;
  encodeFunctionData(functionFragment: "isMember", values: [string]): string;
  encodeFunctionData(
    functionFragment: "isMemberOfOriginalDAO",
    values: [string]
  ): string;
  encodeFunctionData(functionFragment: "isURLListed", values: [string]): string;
  encodeFunctionData(functionFragment: "removeURL", values: [string]): string;
  encodeFunctionData(
    functionFragment: "setCommitment",
    values: [BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "setMetadataUri",
    values: [string]
  ): string;

  decodeFunctionResult(functionFragment: "addURL", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "canJoin", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "getAdmins", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "getAllMembers",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getAutIDAddress",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getCommitment",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "getDAOData", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "getURLs", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "isAdmin", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "isMember", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "isMemberOfOriginalDAO",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "isURLListed",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "removeURL", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "setCommitment",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "setMetadataUri",
    data: BytesLike
  ): Result;

  events: {
    "DiscordServerSet()": EventFragment;
  };

  getEvent(nameOrSignatureOrTopic: "DiscordServerSet"): EventFragment;
}

export interface DiscordServerSetEventObject {}
export type DiscordServerSetEvent = TypedEvent<[], DiscordServerSetEventObject>;

export type DiscordServerSetEventFilter =
  TypedEventFilter<DiscordServerSetEvent>;

export interface IDAOExpander extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: IDAOExpanderInterface;

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
    addURL(
      _url: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    canJoin(
      member: string,
      role: BigNumberish,
      overrides?: CallOverrides
    ): Promise<[boolean]>;

    getAdmins(overrides?: CallOverrides): Promise<[string[]]>;

    getAllMembers(overrides?: CallOverrides): Promise<[string[]]>;

    getAutIDAddress(overrides?: CallOverrides): Promise<[string]>;

    getCommitment(
      overrides?: CallOverrides
    ): Promise<[BigNumber] & { commitment: BigNumber }>;

    getDAOData(
      overrides?: CallOverrides
    ): Promise<
      [IDAOExpanderData.DAOExpanssionDataStructOutput] & {
        data: IDAOExpanderData.DAOExpanssionDataStructOutput;
      }
    >;

    getURLs(overrides?: CallOverrides): Promise<[string[]]>;

    isAdmin(member: string, overrides?: CallOverrides): Promise<[boolean]>;

    isMember(member: string, overrides?: CallOverrides): Promise<[boolean]>;

    isMemberOfOriginalDAO(
      member: string,
      overrides?: CallOverrides
    ): Promise<[boolean]>;

    isURLListed(_url: string, overrides?: CallOverrides): Promise<[boolean]>;

    removeURL(
      _url: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    setCommitment(
      commitment: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    setMetadataUri(
      metadata: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;
  };

  addURL(
    _url: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  canJoin(
    member: string,
    role: BigNumberish,
    overrides?: CallOverrides
  ): Promise<boolean>;

  getAdmins(overrides?: CallOverrides): Promise<string[]>;

  getAllMembers(overrides?: CallOverrides): Promise<string[]>;

  getAutIDAddress(overrides?: CallOverrides): Promise<string>;

  getCommitment(overrides?: CallOverrides): Promise<BigNumber>;

  getDAOData(
    overrides?: CallOverrides
  ): Promise<IDAOExpanderData.DAOExpanssionDataStructOutput>;

  getURLs(overrides?: CallOverrides): Promise<string[]>;

  isAdmin(member: string, overrides?: CallOverrides): Promise<boolean>;

  isMember(member: string, overrides?: CallOverrides): Promise<boolean>;

  isMemberOfOriginalDAO(
    member: string,
    overrides?: CallOverrides
  ): Promise<boolean>;

  isURLListed(_url: string, overrides?: CallOverrides): Promise<boolean>;

  removeURL(
    _url: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  setCommitment(
    commitment: BigNumberish,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  setMetadataUri(
    metadata: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  callStatic: {
    addURL(_url: string, overrides?: CallOverrides): Promise<void>;

    canJoin(
      member: string,
      role: BigNumberish,
      overrides?: CallOverrides
    ): Promise<boolean>;

    getAdmins(overrides?: CallOverrides): Promise<string[]>;

    getAllMembers(overrides?: CallOverrides): Promise<string[]>;

    getAutIDAddress(overrides?: CallOverrides): Promise<string>;

    getCommitment(overrides?: CallOverrides): Promise<BigNumber>;

    getDAOData(
      overrides?: CallOverrides
    ): Promise<IDAOExpanderData.DAOExpanssionDataStructOutput>;

    getURLs(overrides?: CallOverrides): Promise<string[]>;

    isAdmin(member: string, overrides?: CallOverrides): Promise<boolean>;

    isMember(member: string, overrides?: CallOverrides): Promise<boolean>;

    isMemberOfOriginalDAO(
      member: string,
      overrides?: CallOverrides
    ): Promise<boolean>;

    isURLListed(_url: string, overrides?: CallOverrides): Promise<boolean>;

    removeURL(_url: string, overrides?: CallOverrides): Promise<void>;

    setCommitment(
      commitment: BigNumberish,
      overrides?: CallOverrides
    ): Promise<void>;

    setMetadataUri(metadata: string, overrides?: CallOverrides): Promise<void>;
  };

  filters: {
    "DiscordServerSet()"(): DiscordServerSetEventFilter;
    DiscordServerSet(): DiscordServerSetEventFilter;
  };

  estimateGas: {
    addURL(
      _url: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    canJoin(
      member: string,
      role: BigNumberish,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    getAdmins(overrides?: CallOverrides): Promise<BigNumber>;

    getAllMembers(overrides?: CallOverrides): Promise<BigNumber>;

    getAutIDAddress(overrides?: CallOverrides): Promise<BigNumber>;

    getCommitment(overrides?: CallOverrides): Promise<BigNumber>;

    getDAOData(overrides?: CallOverrides): Promise<BigNumber>;

    getURLs(overrides?: CallOverrides): Promise<BigNumber>;

    isAdmin(member: string, overrides?: CallOverrides): Promise<BigNumber>;

    isMember(member: string, overrides?: CallOverrides): Promise<BigNumber>;

    isMemberOfOriginalDAO(
      member: string,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    isURLListed(_url: string, overrides?: CallOverrides): Promise<BigNumber>;

    removeURL(
      _url: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    setCommitment(
      commitment: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    setMetadataUri(
      metadata: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;
  };

  populateTransaction: {
    addURL(
      _url: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    canJoin(
      member: string,
      role: BigNumberish,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    getAdmins(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    getAllMembers(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    getAutIDAddress(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    getCommitment(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    getDAOData(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    getURLs(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    isAdmin(
      member: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    isMember(
      member: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    isMemberOfOriginalDAO(
      member: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    isURLListed(
      _url: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    removeURL(
      _url: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    setCommitment(
      commitment: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    setMetadataUri(
      metadata: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;
  };
}
