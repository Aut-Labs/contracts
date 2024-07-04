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

export interface SampleInteractionPluginInterface extends utils.Interface {
  functions: {
    "changeInUseLocalRep(address)": FunctionFragment;
    "currentReputationAddr()": FunctionFragment;
    "deployer()": FunctionFragment;
    "incrementNumber(string)": FunctionFragment;
    "incrementNumberPlusOne()": FunctionFragment;
    "isActive()": FunctionFragment;
    "lastReputationAddr()": FunctionFragment;
    "moduleId()": FunctionFragment;
    "hubAddress()": FunctionFragment;
    "number()": FunctionFragment;
    "owner()": FunctionFragment;
    "pluginId()": FunctionFragment;
    "pluginRegistry()": FunctionFragment;
    "setPluginId(uint256)": FunctionFragment;
  };

  getFunction(
    nameOrSignatureOrTopic:
      | "changeInUseLocalRep"
      | "currentReputationAddr"
      | "deployer"
      | "incrementNumber"
      | "incrementNumberPlusOne"
      | "isActive"
      | "lastReputationAddr"
      | "moduleId"
      | "hubAddress"
      | "number"
      | "owner"
      | "pluginId"
      | "pluginRegistry"
      | "setPluginId"
  ): FunctionFragment;

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
    functionFragment: "incrementNumber",
    values: [string]
  ): string;
  encodeFunctionData(
    functionFragment: "incrementNumberPlusOne",
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
  encodeFunctionData(functionFragment: "number", values?: undefined): string;
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
    functionFragment: "changeInUseLocalRep",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "currentReputationAddr",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "deployer", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "incrementNumber",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "incrementNumberPlusOne",
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
  decodeFunctionResult(functionFragment: "number", data: BytesLike): Result;
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
  };

  getEvent(nameOrSignatureOrTopic: "LocalRepALogChangedFor"): EventFragment;
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

export interface SampleInteractionPlugin extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: SampleInteractionPluginInterface;

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
    changeInUseLocalRep(
      NewLocalRepAlgo_: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    currentReputationAddr(overrides?: CallOverrides): Promise<[string]>;

    deployer(overrides?: CallOverrides): Promise<[string]>;

    incrementNumber(
      x: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    incrementNumberPlusOne(
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    isActive(overrides?: CallOverrides): Promise<[boolean]>;

    lastReputationAddr(overrides?: CallOverrides): Promise<[string]>;

    moduleId(overrides?: CallOverrides): Promise<[BigNumber]>;

    hubAddress(overrides?: CallOverrides): Promise<[string]>;

    number(overrides?: CallOverrides): Promise<[BigNumber]>;

    owner(overrides?: CallOverrides): Promise<[string]>;

    pluginId(overrides?: CallOverrides): Promise<[BigNumber]>;

    pluginRegistry(overrides?: CallOverrides): Promise<[string]>;

    setPluginId(
      tokenId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;
  };

  changeInUseLocalRep(
    NewLocalRepAlgo_: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  currentReputationAddr(overrides?: CallOverrides): Promise<string>;

  deployer(overrides?: CallOverrides): Promise<string>;

  incrementNumber(
    x: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  incrementNumberPlusOne(
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  isActive(overrides?: CallOverrides): Promise<boolean>;

  lastReputationAddr(overrides?: CallOverrides): Promise<string>;

  moduleId(overrides?: CallOverrides): Promise<BigNumber>;

  hubAddress(overrides?: CallOverrides): Promise<string>;

  number(overrides?: CallOverrides): Promise<BigNumber>;

  owner(overrides?: CallOverrides): Promise<string>;

  pluginId(overrides?: CallOverrides): Promise<BigNumber>;

  pluginRegistry(overrides?: CallOverrides): Promise<string>;

  setPluginId(
    tokenId: BigNumberish,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  callStatic: {
    changeInUseLocalRep(
      NewLocalRepAlgo_: string,
      overrides?: CallOverrides
    ): Promise<void>;

    currentReputationAddr(overrides?: CallOverrides): Promise<string>;

    deployer(overrides?: CallOverrides): Promise<string>;

    incrementNumber(x: string, overrides?: CallOverrides): Promise<BigNumber>;

    incrementNumberPlusOne(overrides?: CallOverrides): Promise<BigNumber>;

    isActive(overrides?: CallOverrides): Promise<boolean>;

    lastReputationAddr(overrides?: CallOverrides): Promise<string>;

    moduleId(overrides?: CallOverrides): Promise<BigNumber>;

    hubAddress(overrides?: CallOverrides): Promise<string>;

    number(overrides?: CallOverrides): Promise<BigNumber>;

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
  };

  estimateGas: {
    changeInUseLocalRep(
      NewLocalRepAlgo_: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    currentReputationAddr(overrides?: CallOverrides): Promise<BigNumber>;

    deployer(overrides?: CallOverrides): Promise<BigNumber>;

    incrementNumber(
      x: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    incrementNumberPlusOne(
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    isActive(overrides?: CallOverrides): Promise<BigNumber>;

    lastReputationAddr(overrides?: CallOverrides): Promise<BigNumber>;

    moduleId(overrides?: CallOverrides): Promise<BigNumber>;

    hubAddress(overrides?: CallOverrides): Promise<BigNumber>;

    number(overrides?: CallOverrides): Promise<BigNumber>;

    owner(overrides?: CallOverrides): Promise<BigNumber>;

    pluginId(overrides?: CallOverrides): Promise<BigNumber>;

    pluginRegistry(overrides?: CallOverrides): Promise<BigNumber>;

    setPluginId(
      tokenId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;
  };

  populateTransaction: {
    changeInUseLocalRep(
      NewLocalRepAlgo_: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    currentReputationAddr(
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    deployer(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    incrementNumber(
      x: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    incrementNumberPlusOne(
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    isActive(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    lastReputationAddr(
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    moduleId(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    hubAddress(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    number(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    owner(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    pluginId(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    pluginRegistry(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    setPluginId(
      tokenId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;
  };
}
