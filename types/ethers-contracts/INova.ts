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

export interface INovaInterface extends utils.Interface {
  functions: {
    "activateModule(uint256)": FunctionFragment;
    "activatedModules()": FunctionFragment;
    "addAdmin(address)": FunctionFragment;
    "addAdmins(address[])": FunctionFragment;
    "addURL(string)": FunctionFragment;
    "admins()": FunctionFragment;
    "canJoin(address,uint256)": FunctionFragment;
    "daoAddress()": FunctionFragment;
    "deployer()": FunctionFragment;
    "getAdmins()": FunctionFragment;
    "getAllMembers()": FunctionFragment;
    "getAutIDAddress()": FunctionFragment;
    "getCommitment()": FunctionFragment;
    "getURLs()": FunctionFragment;
    "isActive()": FunctionFragment;
    "isAdmin(address)": FunctionFragment;
    "isMember(address)": FunctionFragment;
    "isModuleActivated(uint256)": FunctionFragment;
    "isOnboarded(address,uint256)": FunctionFragment;
    "isURLListed(string)": FunctionFragment;
    "join(address,uint256)": FunctionFragment;
    "market()": FunctionFragment;
    "memberCount()": FunctionFragment;
    "members()": FunctionFragment;
    "moduleId()": FunctionFragment;
    "onboard(address,uint256)": FunctionFragment;
    "onboardingAddr()": FunctionFragment;
    "pluginRegistry()": FunctionFragment;
    "removeAdmin(address)": FunctionFragment;
    "removeURL(string)": FunctionFragment;
    "setCommitment(uint256)": FunctionFragment;
    "setMetadataUri(string)": FunctionFragment;
    "setOnboardingStrategy(address)": FunctionFragment;
  };

  getFunction(
    nameOrSignatureOrTopic:
      | "activateModule"
      | "activatedModules"
      | "addAdmin"
      | "addAdmins"
      | "addURL"
      | "admins"
      | "canJoin"
      | "daoAddress"
      | "deployer"
      | "getAdmins"
      | "getAllMembers"
      | "getAutIDAddress"
      | "getCommitment"
      | "getURLs"
      | "isActive"
      | "isAdmin"
      | "isMember"
      | "isModuleActivated"
      | "isOnboarded"
      | "isURLListed"
      | "join"
      | "market"
      | "memberCount"
      | "members"
      | "moduleId"
      | "onboard"
      | "onboardingAddr"
      | "pluginRegistry"
      | "removeAdmin"
      | "removeURL"
      | "setCommitment"
      | "setMetadataUri"
      | "setOnboardingStrategy"
  ): FunctionFragment;

  encodeFunctionData(
    functionFragment: "activateModule",
    values: [BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "activatedModules",
    values?: undefined
  ): string;
  encodeFunctionData(functionFragment: "addAdmin", values: [string]): string;
  encodeFunctionData(functionFragment: "addAdmins", values: [string[]]): string;
  encodeFunctionData(functionFragment: "addURL", values: [string]): string;
  encodeFunctionData(functionFragment: "admins", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "canJoin",
    values: [string, BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "daoAddress",
    values?: undefined
  ): string;
  encodeFunctionData(functionFragment: "deployer", values?: undefined): string;
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
  encodeFunctionData(functionFragment: "getURLs", values?: undefined): string;
  encodeFunctionData(functionFragment: "isActive", values?: undefined): string;
  encodeFunctionData(functionFragment: "isAdmin", values: [string]): string;
  encodeFunctionData(functionFragment: "isMember", values: [string]): string;
  encodeFunctionData(
    functionFragment: "isModuleActivated",
    values: [BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "isOnboarded",
    values: [string, BigNumberish]
  ): string;
  encodeFunctionData(functionFragment: "isURLListed", values: [string]): string;
  encodeFunctionData(
    functionFragment: "join",
    values: [string, BigNumberish]
  ): string;
  encodeFunctionData(functionFragment: "market", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "memberCount",
    values?: undefined
  ): string;
  encodeFunctionData(functionFragment: "members", values?: undefined): string;
  encodeFunctionData(functionFragment: "moduleId", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "onboard",
    values: [string, BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "onboardingAddr",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "pluginRegistry",
    values?: undefined
  ): string;
  encodeFunctionData(functionFragment: "removeAdmin", values: [string]): string;
  encodeFunctionData(functionFragment: "removeURL", values: [string]): string;
  encodeFunctionData(
    functionFragment: "setCommitment",
    values: [BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "setMetadataUri",
    values: [string]
  ): string;
  encodeFunctionData(
    functionFragment: "setOnboardingStrategy",
    values: [string]
  ): string;

  decodeFunctionResult(
    functionFragment: "activateModule",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "activatedModules",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "addAdmin", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "addAdmins", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "addURL", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "admins", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "canJoin", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "daoAddress", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "deployer", data: BytesLike): Result;
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
  decodeFunctionResult(functionFragment: "getURLs", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "isActive", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "isAdmin", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "isMember", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "isModuleActivated",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "isOnboarded",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "isURLListed",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "join", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "market", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "memberCount",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "members", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "moduleId", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "onboard", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "onboardingAddr",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "pluginRegistry",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "removeAdmin",
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
  decodeFunctionResult(
    functionFragment: "setOnboardingStrategy",
    data: BytesLike
  ): Result;

  events: {
    "AdminMemberAdded(address)": EventFragment;
    "AdminMemberRemoved(address)": EventFragment;
    "MarketSet()": EventFragment;
    "MetadataUriUpdated()": EventFragment;
    "Onboarded(address,address)": EventFragment;
  };

  getEvent(nameOrSignatureOrTopic: "AdminMemberAdded"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "AdminMemberRemoved"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "MarketSet"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "MetadataUriUpdated"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "Onboarded"): EventFragment;
}

export interface AdminMemberAddedEventObject {
  member: string;
}
export type AdminMemberAddedEvent = TypedEvent<
  [string],
  AdminMemberAddedEventObject
>;

export type AdminMemberAddedEventFilter =
  TypedEventFilter<AdminMemberAddedEvent>;

export interface AdminMemberRemovedEventObject {
  member: string;
}
export type AdminMemberRemovedEvent = TypedEvent<
  [string],
  AdminMemberRemovedEventObject
>;

export type AdminMemberRemovedEventFilter =
  TypedEventFilter<AdminMemberRemovedEvent>;

export interface MarketSetEventObject {}
export type MarketSetEvent = TypedEvent<[], MarketSetEventObject>;

export type MarketSetEventFilter = TypedEventFilter<MarketSetEvent>;

export interface MetadataUriUpdatedEventObject {}
export type MetadataUriUpdatedEvent = TypedEvent<
  [],
  MetadataUriUpdatedEventObject
>;

export type MetadataUriUpdatedEventFilter =
  TypedEventFilter<MetadataUriUpdatedEvent>;

export interface OnboardedEventObject {
  member: string;
  dao: string;
}
export type OnboardedEvent = TypedEvent<[string, string], OnboardedEventObject>;

export type OnboardedEventFilter = TypedEventFilter<OnboardedEvent>;

export interface INova extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: INovaInterface;

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
    activateModule(
      moduleId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    activatedModules(overrides?: CallOverrides): Promise<[BigNumber[]]>;

    addAdmin(
      member: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    addAdmins(
      adminAddr: string[],
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    addURL(
      _url: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    admins(overrides?: CallOverrides): Promise<[string[]]>;

    canJoin(
      member: string,
      role: BigNumberish,
      overrides?: CallOverrides
    ): Promise<[boolean]>;

    daoAddress(overrides?: CallOverrides): Promise<[string]>;

    deployer(overrides?: CallOverrides): Promise<[string]>;

    getAdmins(overrides?: CallOverrides): Promise<[string[]]>;

    getAllMembers(overrides?: CallOverrides): Promise<[string[]]>;

    getAutIDAddress(overrides?: CallOverrides): Promise<[string]>;

    getCommitment(
      overrides?: CallOverrides
    ): Promise<[BigNumber] & { commitment: BigNumber }>;

    getURLs(overrides?: CallOverrides): Promise<[string[]]>;

    isActive(overrides?: CallOverrides): Promise<[boolean]>;

    isAdmin(
      arg0: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    isMember(arg0: string, overrides?: CallOverrides): Promise<[boolean]>;

    isModuleActivated(
      moduleId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<[boolean]>;

    isOnboarded(
      member: string,
      role: BigNumberish,
      overrides?: CallOverrides
    ): Promise<[boolean]>;

    isURLListed(_url: string, overrides?: CallOverrides): Promise<[boolean]>;

    join(
      newMember: string,
      role: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    market(
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    memberCount(overrides?: CallOverrides): Promise<[BigNumber]>;

    members(
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    moduleId(overrides?: CallOverrides): Promise<[BigNumber]>;

    onboard(
      member: string,
      role: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    onboardingAddr(overrides?: CallOverrides): Promise<[string]>;

    pluginRegistry(
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    removeAdmin(
      member: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

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

    setOnboardingStrategy(
      onboardingPlugin: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;
  };

  activateModule(
    moduleId: BigNumberish,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  activatedModules(overrides?: CallOverrides): Promise<BigNumber[]>;

  addAdmin(
    member: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  addAdmins(
    adminAddr: string[],
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  addURL(
    _url: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  admins(overrides?: CallOverrides): Promise<string[]>;

  canJoin(
    member: string,
    role: BigNumberish,
    overrides?: CallOverrides
  ): Promise<boolean>;

  daoAddress(overrides?: CallOverrides): Promise<string>;

  deployer(overrides?: CallOverrides): Promise<string>;

  getAdmins(overrides?: CallOverrides): Promise<string[]>;

  getAllMembers(overrides?: CallOverrides): Promise<string[]>;

  getAutIDAddress(overrides?: CallOverrides): Promise<string>;

  getCommitment(overrides?: CallOverrides): Promise<BigNumber>;

  getURLs(overrides?: CallOverrides): Promise<string[]>;

  isActive(overrides?: CallOverrides): Promise<boolean>;

  isAdmin(
    arg0: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  isMember(arg0: string, overrides?: CallOverrides): Promise<boolean>;

  isModuleActivated(
    moduleId: BigNumberish,
    overrides?: CallOverrides
  ): Promise<boolean>;

  isOnboarded(
    member: string,
    role: BigNumberish,
    overrides?: CallOverrides
  ): Promise<boolean>;

  isURLListed(_url: string, overrides?: CallOverrides): Promise<boolean>;

  join(
    newMember: string,
    role: BigNumberish,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  market(
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  memberCount(overrides?: CallOverrides): Promise<BigNumber>;

  members(
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  moduleId(overrides?: CallOverrides): Promise<BigNumber>;

  onboard(
    member: string,
    role: BigNumberish,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  onboardingAddr(overrides?: CallOverrides): Promise<string>;

  pluginRegistry(
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  removeAdmin(
    member: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

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

  setOnboardingStrategy(
    onboardingPlugin: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  callStatic: {
    activateModule(
      moduleId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<void>;

    activatedModules(overrides?: CallOverrides): Promise<BigNumber[]>;

    addAdmin(member: string, overrides?: CallOverrides): Promise<void>;

    addAdmins(
      adminAddr: string[],
      overrides?: CallOverrides
    ): Promise<string[]>;

    addURL(_url: string, overrides?: CallOverrides): Promise<void>;

    admins(overrides?: CallOverrides): Promise<string[]>;

    canJoin(
      member: string,
      role: BigNumberish,
      overrides?: CallOverrides
    ): Promise<boolean>;

    daoAddress(overrides?: CallOverrides): Promise<string>;

    deployer(overrides?: CallOverrides): Promise<string>;

    getAdmins(overrides?: CallOverrides): Promise<string[]>;

    getAllMembers(overrides?: CallOverrides): Promise<string[]>;

    getAutIDAddress(overrides?: CallOverrides): Promise<string>;

    getCommitment(overrides?: CallOverrides): Promise<BigNumber>;

    getURLs(overrides?: CallOverrides): Promise<string[]>;

    isActive(overrides?: CallOverrides): Promise<boolean>;

    isAdmin(arg0: string, overrides?: CallOverrides): Promise<boolean>;

    isMember(arg0: string, overrides?: CallOverrides): Promise<boolean>;

    isModuleActivated(
      moduleId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<boolean>;

    isOnboarded(
      member: string,
      role: BigNumberish,
      overrides?: CallOverrides
    ): Promise<boolean>;

    isURLListed(_url: string, overrides?: CallOverrides): Promise<boolean>;

    join(
      newMember: string,
      role: BigNumberish,
      overrides?: CallOverrides
    ): Promise<void>;

    market(overrides?: CallOverrides): Promise<BigNumber>;

    memberCount(overrides?: CallOverrides): Promise<BigNumber>;

    members(overrides?: CallOverrides): Promise<string[]>;

    moduleId(overrides?: CallOverrides): Promise<BigNumber>;

    onboard(
      member: string,
      role: BigNumberish,
      overrides?: CallOverrides
    ): Promise<void>;

    onboardingAddr(overrides?: CallOverrides): Promise<string>;

    pluginRegistry(overrides?: CallOverrides): Promise<string>;

    removeAdmin(member: string, overrides?: CallOverrides): Promise<void>;

    removeURL(_url: string, overrides?: CallOverrides): Promise<void>;

    setCommitment(
      commitment: BigNumberish,
      overrides?: CallOverrides
    ): Promise<void>;

    setMetadataUri(metadata: string, overrides?: CallOverrides): Promise<void>;

    setOnboardingStrategy(
      onboardingPlugin: string,
      overrides?: CallOverrides
    ): Promise<void>;
  };

  filters: {
    "AdminMemberAdded(address)"(member?: null): AdminMemberAddedEventFilter;
    AdminMemberAdded(member?: null): AdminMemberAddedEventFilter;

    "AdminMemberRemoved(address)"(member?: null): AdminMemberRemovedEventFilter;
    AdminMemberRemoved(member?: null): AdminMemberRemovedEventFilter;

    "MarketSet()"(): MarketSetEventFilter;
    MarketSet(): MarketSetEventFilter;

    "MetadataUriUpdated()"(): MetadataUriUpdatedEventFilter;
    MetadataUriUpdated(): MetadataUriUpdatedEventFilter;

    "Onboarded(address,address)"(
      member?: null,
      dao?: null
    ): OnboardedEventFilter;
    Onboarded(member?: null, dao?: null): OnboardedEventFilter;
  };

  estimateGas: {
    activateModule(
      moduleId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    activatedModules(overrides?: CallOverrides): Promise<BigNumber>;

    addAdmin(
      member: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    addAdmins(
      adminAddr: string[],
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    addURL(
      _url: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    admins(overrides?: CallOverrides): Promise<BigNumber>;

    canJoin(
      member: string,
      role: BigNumberish,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    daoAddress(overrides?: CallOverrides): Promise<BigNumber>;

    deployer(overrides?: CallOverrides): Promise<BigNumber>;

    getAdmins(overrides?: CallOverrides): Promise<BigNumber>;

    getAllMembers(overrides?: CallOverrides): Promise<BigNumber>;

    getAutIDAddress(overrides?: CallOverrides): Promise<BigNumber>;

    getCommitment(overrides?: CallOverrides): Promise<BigNumber>;

    getURLs(overrides?: CallOverrides): Promise<BigNumber>;

    isActive(overrides?: CallOverrides): Promise<BigNumber>;

    isAdmin(
      arg0: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    isMember(arg0: string, overrides?: CallOverrides): Promise<BigNumber>;

    isModuleActivated(
      moduleId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    isOnboarded(
      member: string,
      role: BigNumberish,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    isURLListed(_url: string, overrides?: CallOverrides): Promise<BigNumber>;

    join(
      newMember: string,
      role: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    market(overrides?: Overrides & { from?: string }): Promise<BigNumber>;

    memberCount(overrides?: CallOverrides): Promise<BigNumber>;

    members(overrides?: Overrides & { from?: string }): Promise<BigNumber>;

    moduleId(overrides?: CallOverrides): Promise<BigNumber>;

    onboard(
      member: string,
      role: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    onboardingAddr(overrides?: CallOverrides): Promise<BigNumber>;

    pluginRegistry(
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    removeAdmin(
      member: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

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

    setOnboardingStrategy(
      onboardingPlugin: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;
  };

  populateTransaction: {
    activateModule(
      moduleId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    activatedModules(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    addAdmin(
      member: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    addAdmins(
      adminAddr: string[],
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    addURL(
      _url: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    admins(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    canJoin(
      member: string,
      role: BigNumberish,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    daoAddress(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    deployer(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    getAdmins(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    getAllMembers(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    getAutIDAddress(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    getCommitment(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    getURLs(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    isActive(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    isAdmin(
      arg0: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    isMember(
      arg0: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    isModuleActivated(
      moduleId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    isOnboarded(
      member: string,
      role: BigNumberish,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    isURLListed(
      _url: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    join(
      newMember: string,
      role: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    market(
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    memberCount(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    members(
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    moduleId(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    onboard(
      member: string,
      role: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    onboardingAddr(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    pluginRegistry(
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    removeAdmin(
      member: string,
      overrides?: Overrides & { from?: string }
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

    setOnboardingStrategy(
      onboardingPlugin: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;
  };
}
