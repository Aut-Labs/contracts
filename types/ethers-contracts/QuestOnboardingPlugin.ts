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

export interface QuestOnboardingPluginInterface extends utils.Interface {
  functions: {
    "deployer()": FunctionFragment;
    "getQuestsPluginAddress()": FunctionFragment;
    "isActive()": FunctionFragment;
    "isOnboarded(address,uint256)": FunctionFragment;
    "moduleId()": FunctionFragment;
    "novaAddress()": FunctionFragment;
    "onboard(address,uint256)": FunctionFragment;
    "owner()": FunctionFragment;
    "pluginId()": FunctionFragment;
    "pluginRegistry()": FunctionFragment;
    "questsPlugin()": FunctionFragment;
    "setActive(bool)": FunctionFragment;
    "setPluginId(uint256)": FunctionFragment;
  };

  getFunction(
    nameOrSignatureOrTopic:
      | "deployer"
      | "getQuestsPluginAddress"
      | "isActive"
      | "isOnboarded"
      | "moduleId"
      | "novaAddress"
      | "onboard"
      | "owner"
      | "pluginId"
      | "pluginRegistry"
      | "questsPlugin"
      | "setActive"
      | "setPluginId"
  ): FunctionFragment;

  encodeFunctionData(functionFragment: "deployer", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "getQuestsPluginAddress",
    values?: undefined
  ): string;
  encodeFunctionData(functionFragment: "isActive", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "isOnboarded",
    values: [string, BigNumberish]
  ): string;
  encodeFunctionData(functionFragment: "moduleId", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "novaAddress",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "onboard",
    values: [string, BigNumberish]
  ): string;
  encodeFunctionData(functionFragment: "owner", values?: undefined): string;
  encodeFunctionData(functionFragment: "pluginId", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "pluginRegistry",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "questsPlugin",
    values?: undefined
  ): string;
  encodeFunctionData(functionFragment: "setActive", values: [boolean]): string;
  encodeFunctionData(
    functionFragment: "setPluginId",
    values: [BigNumberish]
  ): string;

  decodeFunctionResult(functionFragment: "deployer", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "getQuestsPluginAddress",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "isActive", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "isOnboarded",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "moduleId", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "novaAddress",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "onboard", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "owner", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "pluginId", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "pluginRegistry",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "questsPlugin",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "setActive", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "setPluginId",
    data: BytesLike
  ): Result;

  events: {
    "Onboarded(address,address)": EventFragment;
  };

  getEvent(nameOrSignatureOrTopic: "Onboarded"): EventFragment;
}

export interface OnboardedEventObject {
  member: string;
  dao: string;
}
export type OnboardedEvent = TypedEvent<[string, string], OnboardedEventObject>;

export type OnboardedEventFilter = TypedEventFilter<OnboardedEvent>;

export interface QuestOnboardingPlugin extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: QuestOnboardingPluginInterface;

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
    deployer(overrides?: CallOverrides): Promise<[string]>;

    getQuestsPluginAddress(overrides?: CallOverrides): Promise<[string]>;

    isActive(overrides?: CallOverrides): Promise<[boolean]>;

    isOnboarded(
      member: string,
      role: BigNumberish,
      overrides?: CallOverrides
    ): Promise<[boolean]>;

    moduleId(overrides?: CallOverrides): Promise<[BigNumber]>;

    novaAddress(overrides?: CallOverrides): Promise<[string]>;

    onboard(
      member: string,
      role: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    owner(overrides?: CallOverrides): Promise<[string]>;

    pluginId(overrides?: CallOverrides): Promise<[BigNumber]>;

    pluginRegistry(overrides?: CallOverrides): Promise<[string]>;

    questsPlugin(overrides?: CallOverrides): Promise<[string]>;

    setActive(
      active: boolean,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    setPluginId(
      tokenId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;
  };

  deployer(overrides?: CallOverrides): Promise<string>;

  getQuestsPluginAddress(overrides?: CallOverrides): Promise<string>;

  isActive(overrides?: CallOverrides): Promise<boolean>;

  isOnboarded(
    member: string,
    role: BigNumberish,
    overrides?: CallOverrides
  ): Promise<boolean>;

  moduleId(overrides?: CallOverrides): Promise<BigNumber>;

  novaAddress(overrides?: CallOverrides): Promise<string>;

  onboard(
    member: string,
    role: BigNumberish,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  owner(overrides?: CallOverrides): Promise<string>;

  pluginId(overrides?: CallOverrides): Promise<BigNumber>;

  pluginRegistry(overrides?: CallOverrides): Promise<string>;

  questsPlugin(overrides?: CallOverrides): Promise<string>;

  setActive(
    active: boolean,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  setPluginId(
    tokenId: BigNumberish,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  callStatic: {
    deployer(overrides?: CallOverrides): Promise<string>;

    getQuestsPluginAddress(overrides?: CallOverrides): Promise<string>;

    isActive(overrides?: CallOverrides): Promise<boolean>;

    isOnboarded(
      member: string,
      role: BigNumberish,
      overrides?: CallOverrides
    ): Promise<boolean>;

    moduleId(overrides?: CallOverrides): Promise<BigNumber>;

    novaAddress(overrides?: CallOverrides): Promise<string>;

    onboard(
      member: string,
      role: BigNumberish,
      overrides?: CallOverrides
    ): Promise<void>;

    owner(overrides?: CallOverrides): Promise<string>;

    pluginId(overrides?: CallOverrides): Promise<BigNumber>;

    pluginRegistry(overrides?: CallOverrides): Promise<string>;

    questsPlugin(overrides?: CallOverrides): Promise<string>;

    setActive(active: boolean, overrides?: CallOverrides): Promise<void>;

    setPluginId(
      tokenId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<void>;
  };

  filters: {
    "Onboarded(address,address)"(
      member?: null,
      dao?: null
    ): OnboardedEventFilter;
    Onboarded(member?: null, dao?: null): OnboardedEventFilter;
  };

  estimateGas: {
    deployer(overrides?: CallOverrides): Promise<BigNumber>;

    getQuestsPluginAddress(overrides?: CallOverrides): Promise<BigNumber>;

    isActive(overrides?: CallOverrides): Promise<BigNumber>;

    isOnboarded(
      member: string,
      role: BigNumberish,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    moduleId(overrides?: CallOverrides): Promise<BigNumber>;

    novaAddress(overrides?: CallOverrides): Promise<BigNumber>;

    onboard(
      member: string,
      role: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    owner(overrides?: CallOverrides): Promise<BigNumber>;

    pluginId(overrides?: CallOverrides): Promise<BigNumber>;

    pluginRegistry(overrides?: CallOverrides): Promise<BigNumber>;

    questsPlugin(overrides?: CallOverrides): Promise<BigNumber>;

    setActive(
      active: boolean,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    setPluginId(
      tokenId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;
  };

  populateTransaction: {
    deployer(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    getQuestsPluginAddress(
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    isActive(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    isOnboarded(
      member: string,
      role: BigNumberish,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    moduleId(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    novaAddress(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    onboard(
      member: string,
      role: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    owner(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    pluginId(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    pluginRegistry(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    questsPlugin(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    setActive(
      active: boolean,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    setPluginId(
      tokenId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;
  };
}
