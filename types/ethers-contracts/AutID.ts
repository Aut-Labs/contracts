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

export declare namespace IAutID {
  export type DAOMemberStruct = {
    daoExpanderAddress: string;
    role: BigNumberish;
    commitment: BigNumberish;
    isActive: boolean;
  };

  export type DAOMemberStructOutput = [
    string,
    BigNumber,
    BigNumber,
    boolean
  ] & {
    daoExpanderAddress: string;
    role: BigNumber;
    commitment: BigNumber;
    isActive: boolean;
  };
}

export interface AutIDInterface extends utils.Interface {
  functions: {
    "addDiscordIDToAutID(string)": FunctionFragment;
    "approve(address,uint256)": FunctionFragment;
    "autIDToDiscordID(uint256)": FunctionFragment;
    "autIDUsername(string)": FunctionFragment;
    "balanceOf(address)": FunctionFragment;
    "discordIDToAddress(string)": FunctionFragment;
    "editCommitment(address,uint256)": FunctionFragment;
    "getAllActiveMembers(address)": FunctionFragment;
    "getApproved(uint256)": FunctionFragment;
    "getAutIDByOwner(address)": FunctionFragment;
    "getAutIDHolderByUsername(string)": FunctionFragment;
    "getCommitmentsOfFor(address[],address)": FunctionFragment;
    "getHolderDAOs(address)": FunctionFragment;
    "getMembershipData(address,address)": FunctionFragment;
    "getNextTokenID()": FunctionFragment;
    "getTotalCommitment(address)": FunctionFragment;
    "getTrustedForwarder()": FunctionFragment;
    "initialize(address)": FunctionFragment;
    "isApprovedForAll(address,address)": FunctionFragment;
    "isTrustedForwarder(address)": FunctionFragment;
    "joinDAO(uint256,uint256,address)": FunctionFragment;
    "mint(string,string,uint256,uint256,address)": FunctionFragment;
    "name()": FunctionFragment;
    "ownerOf(uint256)": FunctionFragment;
    "safeTransferFrom(address,address,uint256)": FunctionFragment;
    "safeTransferFrom(address,address,uint256,bytes)": FunctionFragment;
    "setApprovalForAll(address,bool)": FunctionFragment;
    "setMetadataUri(string)": FunctionFragment;
    "supportsInterface(bytes4)": FunctionFragment;
    "symbol()": FunctionFragment;
    "tokenURI(uint256)": FunctionFragment;
    "transferFrom(address,address,uint256)": FunctionFragment;
    "withdraw(address)": FunctionFragment;
  };

  getFunction(
    nameOrSignatureOrTopic:
      | "addDiscordIDToAutID"
      | "approve"
      | "autIDToDiscordID"
      | "autIDUsername"
      | "balanceOf"
      | "discordIDToAddress"
      | "editCommitment"
      | "getAllActiveMembers"
      | "getApproved"
      | "getAutIDByOwner"
      | "getAutIDHolderByUsername"
      | "getCommitmentsOfFor"
      | "getHolderDAOs"
      | "getMembershipData"
      | "getNextTokenID"
      | "getTotalCommitment"
      | "getTrustedForwarder"
      | "initialize"
      | "isApprovedForAll"
      | "isTrustedForwarder"
      | "joinDAO"
      | "mint"
      | "name"
      | "ownerOf"
      | "safeTransferFrom(address,address,uint256)"
      | "safeTransferFrom(address,address,uint256,bytes)"
      | "setApprovalForAll"
      | "setMetadataUri"
      | "supportsInterface"
      | "symbol"
      | "tokenURI"
      | "transferFrom"
      | "withdraw"
  ): FunctionFragment;

  encodeFunctionData(
    functionFragment: "addDiscordIDToAutID",
    values: [string]
  ): string;
  encodeFunctionData(
    functionFragment: "approve",
    values: [string, BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "autIDToDiscordID",
    values: [BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "autIDUsername",
    values: [string]
  ): string;
  encodeFunctionData(functionFragment: "balanceOf", values: [string]): string;
  encodeFunctionData(
    functionFragment: "discordIDToAddress",
    values: [string]
  ): string;
  encodeFunctionData(
    functionFragment: "editCommitment",
    values: [string, BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "getAllActiveMembers",
    values: [string]
  ): string;
  encodeFunctionData(
    functionFragment: "getApproved",
    values: [BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "getAutIDByOwner",
    values: [string]
  ): string;
  encodeFunctionData(
    functionFragment: "getAutIDHolderByUsername",
    values: [string]
  ): string;
  encodeFunctionData(
    functionFragment: "getCommitmentsOfFor",
    values: [string[], string]
  ): string;
  encodeFunctionData(
    functionFragment: "getHolderDAOs",
    values: [string]
  ): string;
  encodeFunctionData(
    functionFragment: "getMembershipData",
    values: [string, string]
  ): string;
  encodeFunctionData(
    functionFragment: "getNextTokenID",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "getTotalCommitment",
    values: [string]
  ): string;
  encodeFunctionData(
    functionFragment: "getTrustedForwarder",
    values?: undefined
  ): string;
  encodeFunctionData(functionFragment: "initialize", values: [string]): string;
  encodeFunctionData(
    functionFragment: "isApprovedForAll",
    values: [string, string]
  ): string;
  encodeFunctionData(
    functionFragment: "isTrustedForwarder",
    values: [string]
  ): string;
  encodeFunctionData(
    functionFragment: "joinDAO",
    values: [BigNumberish, BigNumberish, string]
  ): string;
  encodeFunctionData(
    functionFragment: "mint",
    values: [string, string, BigNumberish, BigNumberish, string]
  ): string;
  encodeFunctionData(functionFragment: "name", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "ownerOf",
    values: [BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "safeTransferFrom(address,address,uint256)",
    values: [string, string, BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "safeTransferFrom(address,address,uint256,bytes)",
    values: [string, string, BigNumberish, BytesLike]
  ): string;
  encodeFunctionData(
    functionFragment: "setApprovalForAll",
    values: [string, boolean]
  ): string;
  encodeFunctionData(
    functionFragment: "setMetadataUri",
    values: [string]
  ): string;
  encodeFunctionData(
    functionFragment: "supportsInterface",
    values: [BytesLike]
  ): string;
  encodeFunctionData(functionFragment: "symbol", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "tokenURI",
    values: [BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "transferFrom",
    values: [string, string, BigNumberish]
  ): string;
  encodeFunctionData(functionFragment: "withdraw", values: [string]): string;

  decodeFunctionResult(
    functionFragment: "addDiscordIDToAutID",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "approve", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "autIDToDiscordID",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "autIDUsername",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "balanceOf", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "discordIDToAddress",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "editCommitment",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getAllActiveMembers",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getApproved",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getAutIDByOwner",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getAutIDHolderByUsername",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getCommitmentsOfFor",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getHolderDAOs",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getMembershipData",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getNextTokenID",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getTotalCommitment",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getTrustedForwarder",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "initialize", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "isApprovedForAll",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "isTrustedForwarder",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "joinDAO", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "mint", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "name", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "ownerOf", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "safeTransferFrom(address,address,uint256)",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "safeTransferFrom(address,address,uint256,bytes)",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "setApprovalForAll",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "setMetadataUri",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "supportsInterface",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "symbol", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "tokenURI", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "transferFrom",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "withdraw", data: BytesLike): Result;

  events: {
    "Approval(address,address,uint256)": EventFragment;
    "ApprovalForAll(address,address,bool)": EventFragment;
    "AutIDCreated(address,uint256)": EventFragment;
    "CommitmentUpdated(address,address,uint256)": EventFragment;
    "DAOJoined(address,address)": EventFragment;
    "DAOWithdrown(address,address)": EventFragment;
    "DiscordIDConnectedToAutID()": EventFragment;
    "Initialized(uint8)": EventFragment;
    "MetadataUriSet(uint256,string)": EventFragment;
    "Transfer(address,address,uint256)": EventFragment;
  };

  getEvent(nameOrSignatureOrTopic: "Approval"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "ApprovalForAll"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "AutIDCreated"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "CommitmentUpdated"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "DAOJoined"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "DAOWithdrown"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "DiscordIDConnectedToAutID"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "Initialized"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "MetadataUriSet"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "Transfer"): EventFragment;
}

export interface ApprovalEventObject {
  owner: string;
  approved: string;
  tokenId: BigNumber;
}
export type ApprovalEvent = TypedEvent<
  [string, string, BigNumber],
  ApprovalEventObject
>;

export type ApprovalEventFilter = TypedEventFilter<ApprovalEvent>;

export interface ApprovalForAllEventObject {
  owner: string;
  operator: string;
  approved: boolean;
}
export type ApprovalForAllEvent = TypedEvent<
  [string, string, boolean],
  ApprovalForAllEventObject
>;

export type ApprovalForAllEventFilter = TypedEventFilter<ApprovalForAllEvent>;

export interface AutIDCreatedEventObject {
  owner: string;
  tokenID: BigNumber;
}
export type AutIDCreatedEvent = TypedEvent<
  [string, BigNumber],
  AutIDCreatedEventObject
>;

export type AutIDCreatedEventFilter = TypedEventFilter<AutIDCreatedEvent>;

export interface CommitmentUpdatedEventObject {
  daoExpanderAddress: string;
  member: string;
  newCommitment: BigNumber;
}
export type CommitmentUpdatedEvent = TypedEvent<
  [string, string, BigNumber],
  CommitmentUpdatedEventObject
>;

export type CommitmentUpdatedEventFilter =
  TypedEventFilter<CommitmentUpdatedEvent>;

export interface DAOJoinedEventObject {
  daoExpanderAddress: string;
  member: string;
}
export type DAOJoinedEvent = TypedEvent<[string, string], DAOJoinedEventObject>;

export type DAOJoinedEventFilter = TypedEventFilter<DAOJoinedEvent>;

export interface DAOWithdrownEventObject {
  daoExpanderAddress: string;
  member: string;
}
export type DAOWithdrownEvent = TypedEvent<
  [string, string],
  DAOWithdrownEventObject
>;

export type DAOWithdrownEventFilter = TypedEventFilter<DAOWithdrownEvent>;

export interface DiscordIDConnectedToAutIDEventObject {}
export type DiscordIDConnectedToAutIDEvent = TypedEvent<
  [],
  DiscordIDConnectedToAutIDEventObject
>;

export type DiscordIDConnectedToAutIDEventFilter =
  TypedEventFilter<DiscordIDConnectedToAutIDEvent>;

export interface InitializedEventObject {
  version: number;
}
export type InitializedEvent = TypedEvent<[number], InitializedEventObject>;

export type InitializedEventFilter = TypedEventFilter<InitializedEvent>;

export interface MetadataUriSetEventObject {
  tokenId: BigNumber;
  metadataUri: string;
}
export type MetadataUriSetEvent = TypedEvent<
  [BigNumber, string],
  MetadataUriSetEventObject
>;

export type MetadataUriSetEventFilter = TypedEventFilter<MetadataUriSetEvent>;

export interface TransferEventObject {
  from: string;
  to: string;
  tokenId: BigNumber;
}
export type TransferEvent = TypedEvent<
  [string, string, BigNumber],
  TransferEventObject
>;

export type TransferEventFilter = TypedEventFilter<TransferEvent>;

export interface AutID extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: AutIDInterface;

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
    addDiscordIDToAutID(
      discordID: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    approve(
      to: string,
      tokenId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    autIDToDiscordID(
      arg0: BigNumberish,
      overrides?: CallOverrides
    ): Promise<[string]>;

    autIDUsername(arg0: string, overrides?: CallOverrides): Promise<[string]>;

    balanceOf(owner: string, overrides?: CallOverrides): Promise<[BigNumber]>;

    discordIDToAddress(
      arg0: string,
      overrides?: CallOverrides
    ): Promise<[string]>;

    editCommitment(
      daoAddress: string,
      newCommitment: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    getAllActiveMembers(
      nova_: string,
      overrides?: CallOverrides
    ): Promise<[string[]] & { members: string[] }>;

    getApproved(
      tokenId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<[string]>;

    getAutIDByOwner(
      autIDOwner: string,
      overrides?: CallOverrides
    ): Promise<[BigNumber]>;

    getAutIDHolderByUsername(
      username: string,
      overrides?: CallOverrides
    ): Promise<[string]>;

    getCommitmentsOfFor(
      agents: string[],
      dao_: string,
      overrides?: CallOverrides
    ): Promise<[BigNumber[]] & { commitments: BigNumber[] }>;

    getHolderDAOs(
      autIDHolder: string,
      overrides?: CallOverrides
    ): Promise<[string[]] & { daos: string[] }>;

    getMembershipData(
      autIDHolder: string,
      daoAddress: string,
      overrides?: CallOverrides
    ): Promise<[IAutID.DAOMemberStructOutput]>;

    getNextTokenID(overrides?: CallOverrides): Promise<[BigNumber]>;

    getTotalCommitment(
      autIDHolder: string,
      overrides?: CallOverrides
    ): Promise<[BigNumber]>;

    getTrustedForwarder(
      overrides?: CallOverrides
    ): Promise<[string] & { forwarder: string }>;

    initialize(
      trustedForwarder: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    isApprovedForAll(
      owner: string,
      operator: string,
      overrides?: CallOverrides
    ): Promise<[boolean]>;

    isTrustedForwarder(
      forwarder: string,
      overrides?: CallOverrides
    ): Promise<[boolean]>;

    joinDAO(
      role: BigNumberish,
      commitment: BigNumberish,
      daoAddress: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    mint(
      username: string,
      url: string,
      role: BigNumberish,
      commitment: BigNumberish,
      daoAddress: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    name(overrides?: CallOverrides): Promise<[string]>;

    ownerOf(
      tokenId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<[string]>;

    "safeTransferFrom(address,address,uint256)"(
      from: string,
      to: string,
      tokenId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    "safeTransferFrom(address,address,uint256,bytes)"(
      from: string,
      to: string,
      tokenId: BigNumberish,
      data: BytesLike,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    setApprovalForAll(
      operator: string,
      approved: boolean,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    setMetadataUri(
      metadataUri: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    supportsInterface(
      interfaceId: BytesLike,
      overrides?: CallOverrides
    ): Promise<[boolean]>;

    symbol(overrides?: CallOverrides): Promise<[string]>;

    tokenURI(
      tokenId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<[string]>;

    transferFrom(
      from: string,
      to: string,
      tokenId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    withdraw(
      daoAddress: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;
  };

  addDiscordIDToAutID(
    discordID: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  approve(
    to: string,
    tokenId: BigNumberish,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  autIDToDiscordID(
    arg0: BigNumberish,
    overrides?: CallOverrides
  ): Promise<string>;

  autIDUsername(arg0: string, overrides?: CallOverrides): Promise<string>;

  balanceOf(owner: string, overrides?: CallOverrides): Promise<BigNumber>;

  discordIDToAddress(arg0: string, overrides?: CallOverrides): Promise<string>;

  editCommitment(
    daoAddress: string,
    newCommitment: BigNumberish,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  getAllActiveMembers(
    nova_: string,
    overrides?: CallOverrides
  ): Promise<string[]>;

  getApproved(
    tokenId: BigNumberish,
    overrides?: CallOverrides
  ): Promise<string>;

  getAutIDByOwner(
    autIDOwner: string,
    overrides?: CallOverrides
  ): Promise<BigNumber>;

  getAutIDHolderByUsername(
    username: string,
    overrides?: CallOverrides
  ): Promise<string>;

  getCommitmentsOfFor(
    agents: string[],
    dao_: string,
    overrides?: CallOverrides
  ): Promise<BigNumber[]>;

  getHolderDAOs(
    autIDHolder: string,
    overrides?: CallOverrides
  ): Promise<string[]>;

  getMembershipData(
    autIDHolder: string,
    daoAddress: string,
    overrides?: CallOverrides
  ): Promise<IAutID.DAOMemberStructOutput>;

  getNextTokenID(overrides?: CallOverrides): Promise<BigNumber>;

  getTotalCommitment(
    autIDHolder: string,
    overrides?: CallOverrides
  ): Promise<BigNumber>;

  getTrustedForwarder(overrides?: CallOverrides): Promise<string>;

  initialize(
    trustedForwarder: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  isApprovedForAll(
    owner: string,
    operator: string,
    overrides?: CallOverrides
  ): Promise<boolean>;

  isTrustedForwarder(
    forwarder: string,
    overrides?: CallOverrides
  ): Promise<boolean>;

  joinDAO(
    role: BigNumberish,
    commitment: BigNumberish,
    daoAddress: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  mint(
    username: string,
    url: string,
    role: BigNumberish,
    commitment: BigNumberish,
    daoAddress: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  name(overrides?: CallOverrides): Promise<string>;

  ownerOf(tokenId: BigNumberish, overrides?: CallOverrides): Promise<string>;

  "safeTransferFrom(address,address,uint256)"(
    from: string,
    to: string,
    tokenId: BigNumberish,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  "safeTransferFrom(address,address,uint256,bytes)"(
    from: string,
    to: string,
    tokenId: BigNumberish,
    data: BytesLike,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  setApprovalForAll(
    operator: string,
    approved: boolean,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  setMetadataUri(
    metadataUri: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  supportsInterface(
    interfaceId: BytesLike,
    overrides?: CallOverrides
  ): Promise<boolean>;

  symbol(overrides?: CallOverrides): Promise<string>;

  tokenURI(tokenId: BigNumberish, overrides?: CallOverrides): Promise<string>;

  transferFrom(
    from: string,
    to: string,
    tokenId: BigNumberish,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  withdraw(
    daoAddress: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  callStatic: {
    addDiscordIDToAutID(
      discordID: string,
      overrides?: CallOverrides
    ): Promise<void>;

    approve(
      to: string,
      tokenId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<void>;

    autIDToDiscordID(
      arg0: BigNumberish,
      overrides?: CallOverrides
    ): Promise<string>;

    autIDUsername(arg0: string, overrides?: CallOverrides): Promise<string>;

    balanceOf(owner: string, overrides?: CallOverrides): Promise<BigNumber>;

    discordIDToAddress(
      arg0: string,
      overrides?: CallOverrides
    ): Promise<string>;

    editCommitment(
      daoAddress: string,
      newCommitment: BigNumberish,
      overrides?: CallOverrides
    ): Promise<void>;

    getAllActiveMembers(
      nova_: string,
      overrides?: CallOverrides
    ): Promise<string[]>;

    getApproved(
      tokenId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<string>;

    getAutIDByOwner(
      autIDOwner: string,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    getAutIDHolderByUsername(
      username: string,
      overrides?: CallOverrides
    ): Promise<string>;

    getCommitmentsOfFor(
      agents: string[],
      dao_: string,
      overrides?: CallOverrides
    ): Promise<BigNumber[]>;

    getHolderDAOs(
      autIDHolder: string,
      overrides?: CallOverrides
    ): Promise<string[]>;

    getMembershipData(
      autIDHolder: string,
      daoAddress: string,
      overrides?: CallOverrides
    ): Promise<IAutID.DAOMemberStructOutput>;

    getNextTokenID(overrides?: CallOverrides): Promise<BigNumber>;

    getTotalCommitment(
      autIDHolder: string,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    getTrustedForwarder(overrides?: CallOverrides): Promise<string>;

    initialize(
      trustedForwarder: string,
      overrides?: CallOverrides
    ): Promise<void>;

    isApprovedForAll(
      owner: string,
      operator: string,
      overrides?: CallOverrides
    ): Promise<boolean>;

    isTrustedForwarder(
      forwarder: string,
      overrides?: CallOverrides
    ): Promise<boolean>;

    joinDAO(
      role: BigNumberish,
      commitment: BigNumberish,
      daoAddress: string,
      overrides?: CallOverrides
    ): Promise<void>;

    mint(
      username: string,
      url: string,
      role: BigNumberish,
      commitment: BigNumberish,
      daoAddress: string,
      overrides?: CallOverrides
    ): Promise<void>;

    name(overrides?: CallOverrides): Promise<string>;

    ownerOf(tokenId: BigNumberish, overrides?: CallOverrides): Promise<string>;

    "safeTransferFrom(address,address,uint256)"(
      from: string,
      to: string,
      tokenId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<void>;

    "safeTransferFrom(address,address,uint256,bytes)"(
      from: string,
      to: string,
      tokenId: BigNumberish,
      data: BytesLike,
      overrides?: CallOverrides
    ): Promise<void>;

    setApprovalForAll(
      operator: string,
      approved: boolean,
      overrides?: CallOverrides
    ): Promise<void>;

    setMetadataUri(
      metadataUri: string,
      overrides?: CallOverrides
    ): Promise<void>;

    supportsInterface(
      interfaceId: BytesLike,
      overrides?: CallOverrides
    ): Promise<boolean>;

    symbol(overrides?: CallOverrides): Promise<string>;

    tokenURI(tokenId: BigNumberish, overrides?: CallOverrides): Promise<string>;

    transferFrom(
      from: string,
      to: string,
      tokenId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<void>;

    withdraw(daoAddress: string, overrides?: CallOverrides): Promise<void>;
  };

  filters: {
    "Approval(address,address,uint256)"(
      owner?: string | null,
      approved?: string | null,
      tokenId?: BigNumberish | null
    ): ApprovalEventFilter;
    Approval(
      owner?: string | null,
      approved?: string | null,
      tokenId?: BigNumberish | null
    ): ApprovalEventFilter;

    "ApprovalForAll(address,address,bool)"(
      owner?: string | null,
      operator?: string | null,
      approved?: null
    ): ApprovalForAllEventFilter;
    ApprovalForAll(
      owner?: string | null,
      operator?: string | null,
      approved?: null
    ): ApprovalForAllEventFilter;

    "AutIDCreated(address,uint256)"(
      owner?: null,
      tokenID?: null
    ): AutIDCreatedEventFilter;
    AutIDCreated(owner?: null, tokenID?: null): AutIDCreatedEventFilter;

    "CommitmentUpdated(address,address,uint256)"(
      daoExpanderAddress?: null,
      member?: null,
      newCommitment?: null
    ): CommitmentUpdatedEventFilter;
    CommitmentUpdated(
      daoExpanderAddress?: null,
      member?: null,
      newCommitment?: null
    ): CommitmentUpdatedEventFilter;

    "DAOJoined(address,address)"(
      daoExpanderAddress?: null,
      member?: null
    ): DAOJoinedEventFilter;
    DAOJoined(daoExpanderAddress?: null, member?: null): DAOJoinedEventFilter;

    "DAOWithdrown(address,address)"(
      daoExpanderAddress?: null,
      member?: null
    ): DAOWithdrownEventFilter;
    DAOWithdrown(
      daoExpanderAddress?: null,
      member?: null
    ): DAOWithdrownEventFilter;

    "DiscordIDConnectedToAutID()"(): DiscordIDConnectedToAutIDEventFilter;
    DiscordIDConnectedToAutID(): DiscordIDConnectedToAutIDEventFilter;

    "Initialized(uint8)"(version?: null): InitializedEventFilter;
    Initialized(version?: null): InitializedEventFilter;

    "MetadataUriSet(uint256,string)"(
      tokenId?: null,
      metadataUri?: null
    ): MetadataUriSetEventFilter;
    MetadataUriSet(
      tokenId?: null,
      metadataUri?: null
    ): MetadataUriSetEventFilter;

    "Transfer(address,address,uint256)"(
      from?: string | null,
      to?: string | null,
      tokenId?: BigNumberish | null
    ): TransferEventFilter;
    Transfer(
      from?: string | null,
      to?: string | null,
      tokenId?: BigNumberish | null
    ): TransferEventFilter;
  };

  estimateGas: {
    addDiscordIDToAutID(
      discordID: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    approve(
      to: string,
      tokenId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    autIDToDiscordID(
      arg0: BigNumberish,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    autIDUsername(arg0: string, overrides?: CallOverrides): Promise<BigNumber>;

    balanceOf(owner: string, overrides?: CallOverrides): Promise<BigNumber>;

    discordIDToAddress(
      arg0: string,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    editCommitment(
      daoAddress: string,
      newCommitment: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    getAllActiveMembers(
      nova_: string,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    getApproved(
      tokenId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    getAutIDByOwner(
      autIDOwner: string,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    getAutIDHolderByUsername(
      username: string,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    getCommitmentsOfFor(
      agents: string[],
      dao_: string,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    getHolderDAOs(
      autIDHolder: string,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    getMembershipData(
      autIDHolder: string,
      daoAddress: string,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    getNextTokenID(overrides?: CallOverrides): Promise<BigNumber>;

    getTotalCommitment(
      autIDHolder: string,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    getTrustedForwarder(overrides?: CallOverrides): Promise<BigNumber>;

    initialize(
      trustedForwarder: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    isApprovedForAll(
      owner: string,
      operator: string,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    isTrustedForwarder(
      forwarder: string,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    joinDAO(
      role: BigNumberish,
      commitment: BigNumberish,
      daoAddress: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    mint(
      username: string,
      url: string,
      role: BigNumberish,
      commitment: BigNumberish,
      daoAddress: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    name(overrides?: CallOverrides): Promise<BigNumber>;

    ownerOf(
      tokenId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    "safeTransferFrom(address,address,uint256)"(
      from: string,
      to: string,
      tokenId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    "safeTransferFrom(address,address,uint256,bytes)"(
      from: string,
      to: string,
      tokenId: BigNumberish,
      data: BytesLike,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    setApprovalForAll(
      operator: string,
      approved: boolean,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    setMetadataUri(
      metadataUri: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    supportsInterface(
      interfaceId: BytesLike,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    symbol(overrides?: CallOverrides): Promise<BigNumber>;

    tokenURI(
      tokenId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    transferFrom(
      from: string,
      to: string,
      tokenId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    withdraw(
      daoAddress: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;
  };

  populateTransaction: {
    addDiscordIDToAutID(
      discordID: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    approve(
      to: string,
      tokenId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    autIDToDiscordID(
      arg0: BigNumberish,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    autIDUsername(
      arg0: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    balanceOf(
      owner: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    discordIDToAddress(
      arg0: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    editCommitment(
      daoAddress: string,
      newCommitment: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    getAllActiveMembers(
      nova_: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    getApproved(
      tokenId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    getAutIDByOwner(
      autIDOwner: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    getAutIDHolderByUsername(
      username: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    getCommitmentsOfFor(
      agents: string[],
      dao_: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    getHolderDAOs(
      autIDHolder: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    getMembershipData(
      autIDHolder: string,
      daoAddress: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    getNextTokenID(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    getTotalCommitment(
      autIDHolder: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    getTrustedForwarder(
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    initialize(
      trustedForwarder: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    isApprovedForAll(
      owner: string,
      operator: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    isTrustedForwarder(
      forwarder: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    joinDAO(
      role: BigNumberish,
      commitment: BigNumberish,
      daoAddress: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    mint(
      username: string,
      url: string,
      role: BigNumberish,
      commitment: BigNumberish,
      daoAddress: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    name(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    ownerOf(
      tokenId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    "safeTransferFrom(address,address,uint256)"(
      from: string,
      to: string,
      tokenId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    "safeTransferFrom(address,address,uint256,bytes)"(
      from: string,
      to: string,
      tokenId: BigNumberish,
      data: BytesLike,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    setApprovalForAll(
      operator: string,
      approved: boolean,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    setMetadataUri(
      metadataUri: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    supportsInterface(
      interfaceId: BytesLike,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    symbol(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    tokenURI(
      tokenId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    transferFrom(
      from: string,
      to: string,
      tokenId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    withdraw(
      daoAddress: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;
  };
}
