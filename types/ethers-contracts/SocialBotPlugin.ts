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

export declare namespace SocialBotPlugin {
  export type SocialBotEventStruct = {
    participants: string[];
    distributedPoints: BigNumberish[];
    categoryOrDescription: string;
    when: BigNumberish;
    maxPointsPerUser: BigNumberish;
  };

  export type SocialBotEventStructOutput = [
    string[],
    number[],
    string,
    BigNumber,
    number
  ] & {
    participants: string[];
    distributedPoints: number[];
    categoryOrDescription: string;
    when: BigNumber;
    maxPointsPerUser: number;
  };
}

export interface SocialBotPluginInterface extends utils.Interface {
  functions: {
    "applyEventConsequences(address[],uint16[],uint16,string)": FunctionFragment;
    "changeInUseLocalRep(address)": FunctionFragment;
    "currentReputationAddr()": FunctionFragment;
    "deployer()": FunctionFragment;
    "getAllBotInteractions()": FunctionFragment;
    "indexAtPeriod()": FunctionFragment;
    "isActive()": FunctionFragment;
    "lastReputationAddr()": FunctionFragment;
    "moduleId()": FunctionFragment;
    "hubAddress()": FunctionFragment;
    "owner()": FunctionFragment;
    "pluginId()": FunctionFragment;
    "pluginRegistry()": FunctionFragment;
    "setPluginId(uint256)": FunctionFragment;
  };

  getFunction(
    nameOrSignatureOrTopic:
      | "applyEventConsequences"
      | "changeInUseLocalRep"
      | "currentReputationAddr"
      | "deployer"
      | "getAllBotInteractions"
      | "indexAtPeriod"
      | "isActive"
      | "lastReputationAddr"
      | "moduleId"
      | "hubAddress"
      | "owner"
      | "pluginId"
      | "pluginRegistry"
      | "setPluginId"
  ): FunctionFragment;

  encodeFunctionData(
    functionFragment: "applyEventConsequences",
    values: [string[], BigNumberish[], BigNumberish, string]
  ): string;
  encodeFunctionData(
    functionFragment: "changeInUseLocalRep",
    values: [string]
  ): string;
  encodeFunctionData(
    functionFragment: "currentReputationAddr",
    values?: undefined
  ): string;
  encodeFunctionData(functionFragment: "deployer", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "getAllBotInteractions",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "indexAtPeriod",
    values?: undefined
  ): string;
  encodeFunctionData(functionFragment: "isActive", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "lastReputationAddr",
    values?: undefined
  ): string;
  encodeFunctionData(functionFragment: "moduleId", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "hubAddress",
    values?: undefined
  ): string;
  encodeFunctionData(functionFragment: "owner", values?: undefined): string;
  encodeFunctionData(functionFragment: "pluginId", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "pluginRegistry",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "setPluginId",
    values: [BigNumberish]
  ): string;

  decodeFunctionResult(
    functionFragment: "applyEventConsequences",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "changeInUseLocalRep",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "currentReputationAddr",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "deployer", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "getAllBotInteractions",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "indexAtPeriod",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "isActive", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "lastReputationAddr",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "moduleId", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "hubAddress",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "owner", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "pluginId", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "pluginRegistry",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "setPluginId",
    data: BytesLike
  ): Result;

  events: {
    "LocalRepALogChangedFor(address,address)": EventFragment;
    "SocialEventRegistered(uint256)": EventFragment;
  };

  getEvent(nameOrSignatureOrTopic: "LocalRepALogChangedFor"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "SocialEventRegistered"): EventFragment;
}

export interface LocalRepALogChangedForEventObject {
  hub: string;
  repAlgo: string;
}
export type LocalRepALogChangedForEvent = TypedEvent<
  [string, string],
  LocalRepALogChangedForEventObject
>;

export type LocalRepALogChangedForEventFilter =
  TypedEventFilter<LocalRepALogChangedForEvent>;

export interface SocialEventRegisteredEventObject {
  EventIndex: BigNumber;
}
export type SocialEventRegisteredEvent = TypedEvent<
  [BigNumber],
  SocialEventRegisteredEventObject
>;

export type SocialEventRegisteredEventFilter =
  TypedEventFilter<SocialEventRegisteredEvent>;

export interface SocialBotPlugin extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: SocialBotPluginInterface;

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
    applyEventConsequences(
      participants: string[],
      participationPoints: BigNumberish[],
      maxPossiblePointsPerUser: BigNumberish,
      categoryOrDescription: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    changeInUseLocalRep(
      NewLocalRepAlgo_: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    currentReputationAddr(overrides?: CallOverrides): Promise<[string]>;

    deployer(overrides?: CallOverrides): Promise<[string]>;

    getAllBotInteractions(
      overrides?: CallOverrides
    ): Promise<[SocialBotPlugin.SocialBotEventStructOutput[]]>;

    indexAtPeriod(overrides?: CallOverrides): Promise<[BigNumber]>;

    isActive(overrides?: CallOverrides): Promise<[boolean]>;

    lastReputationAddr(overrides?: CallOverrides): Promise<[string]>;

    moduleId(overrides?: CallOverrides): Promise<[BigNumber]>;

    hubAddress(overrides?: CallOverrides): Promise<[string]>;

    owner(overrides?: CallOverrides): Promise<[string]>;

    pluginId(overrides?: CallOverrides): Promise<[BigNumber]>;

    pluginRegistry(overrides?: CallOverrides): Promise<[string]>;

    setPluginId(
      tokenId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;
  };

  applyEventConsequences(
    participants: string[],
    participationPoints: BigNumberish[],
    maxPossiblePointsPerUser: BigNumberish,
    categoryOrDescription: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  changeInUseLocalRep(
    NewLocalRepAlgo_: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  currentReputationAddr(overrides?: CallOverrides): Promise<string>;

  deployer(overrides?: CallOverrides): Promise<string>;

  getAllBotInteractions(
    overrides?: CallOverrides
  ): Promise<SocialBotPlugin.SocialBotEventStructOutput[]>;

  indexAtPeriod(overrides?: CallOverrides): Promise<BigNumber>;

  isActive(overrides?: CallOverrides): Promise<boolean>;

  lastReputationAddr(overrides?: CallOverrides): Promise<string>;

  moduleId(overrides?: CallOverrides): Promise<BigNumber>;

  hubAddress(overrides?: CallOverrides): Promise<string>;

  owner(overrides?: CallOverrides): Promise<string>;

  pluginId(overrides?: CallOverrides): Promise<BigNumber>;

  pluginRegistry(overrides?: CallOverrides): Promise<string>;

  setPluginId(
    tokenId: BigNumberish,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  callStatic: {
    applyEventConsequences(
      participants: string[],
      participationPoints: BigNumberish[],
      maxPossiblePointsPerUser: BigNumberish,
      categoryOrDescription: string,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    changeInUseLocalRep(
      NewLocalRepAlgo_: string,
      overrides?: CallOverrides
    ): Promise<void>;

    currentReputationAddr(overrides?: CallOverrides): Promise<string>;

    deployer(overrides?: CallOverrides): Promise<string>;

    getAllBotInteractions(
      overrides?: CallOverrides
    ): Promise<SocialBotPlugin.SocialBotEventStructOutput[]>;

    indexAtPeriod(overrides?: CallOverrides): Promise<BigNumber>;

    isActive(overrides?: CallOverrides): Promise<boolean>;

    lastReputationAddr(overrides?: CallOverrides): Promise<string>;

    moduleId(overrides?: CallOverrides): Promise<BigNumber>;

    hubAddress(overrides?: CallOverrides): Promise<string>;

    owner(overrides?: CallOverrides): Promise<string>;

    pluginId(overrides?: CallOverrides): Promise<BigNumber>;

    pluginRegistry(overrides?: CallOverrides): Promise<string>;

    setPluginId(
      tokenId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<void>;
  };

  filters: {
    "LocalRepALogChangedFor(address,address)"(
      hub?: null,
      repAlgo?: null
    ): LocalRepALogChangedForEventFilter;
    LocalRepALogChangedFor(
      hub?: null,
      repAlgo?: null
    ): LocalRepALogChangedForEventFilter;

    "SocialEventRegistered(uint256)"(
      EventIndex?: null
    ): SocialEventRegisteredEventFilter;
    SocialEventRegistered(EventIndex?: null): SocialEventRegisteredEventFilter;
  };

  estimateGas: {
    applyEventConsequences(
      participants: string[],
      participationPoints: BigNumberish[],
      maxPossiblePointsPerUser: BigNumberish,
      categoryOrDescription: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    changeInUseLocalRep(
      NewLocalRepAlgo_: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    currentReputationAddr(overrides?: CallOverrides): Promise<BigNumber>;

    deployer(overrides?: CallOverrides): Promise<BigNumber>;

    getAllBotInteractions(overrides?: CallOverrides): Promise<BigNumber>;

    indexAtPeriod(overrides?: CallOverrides): Promise<BigNumber>;

    isActive(overrides?: CallOverrides): Promise<BigNumber>;

    lastReputationAddr(overrides?: CallOverrides): Promise<BigNumber>;

    moduleId(overrides?: CallOverrides): Promise<BigNumber>;

    hubAddress(overrides?: CallOverrides): Promise<BigNumber>;

    owner(overrides?: CallOverrides): Promise<BigNumber>;

    pluginId(overrides?: CallOverrides): Promise<BigNumber>;

    pluginRegistry(overrides?: CallOverrides): Promise<BigNumber>;

    setPluginId(
      tokenId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;
  };

  populateTransaction: {
    applyEventConsequences(
      participants: string[],
      participationPoints: BigNumberish[],
      maxPossiblePointsPerUser: BigNumberish,
      categoryOrDescription: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    changeInUseLocalRep(
      NewLocalRepAlgo_: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    currentReputationAddr(
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    deployer(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    getAllBotInteractions(
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    indexAtPeriod(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    isActive(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    lastReputationAddr(
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    moduleId(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    hubAddress(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    owner(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    pluginId(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    pluginRegistry(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    setPluginId(
      tokenId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;
  };
}
