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
import type { FunctionFragment, Result } from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type {
  TypedEventFilter,
  TypedEvent,
  TypedListener,
  OnEvent,
} from "./common";

export interface IPluginInterface extends utils.Interface {
  functions: {
    "deployer()": FunctionFragment;
    "isActive()": FunctionFragment;
    "moduleId()": FunctionFragment;
    "novaAddress()": FunctionFragment;
    "pluginId()": FunctionFragment;
    "pluginRegistry()": FunctionFragment;
    "setPluginId(uint256)": FunctionFragment;
  };

  getFunction(
    nameOrSignatureOrTopic:
      | "deployer"
      | "isActive"
      | "moduleId"
      | "novaAddress"
      | "pluginId"
      | "pluginRegistry"
      | "setPluginId"
  ): FunctionFragment;

  encodeFunctionData(functionFragment: "deployer", values?: undefined): string;
  encodeFunctionData(functionFragment: "isActive", values?: undefined): string;
  encodeFunctionData(functionFragment: "moduleId", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "novaAddress",
    values?: undefined
  ): string;
  encodeFunctionData(functionFragment: "pluginId", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "pluginRegistry",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "setPluginId",
    values: [BigNumberish]
  ): string;

  decodeFunctionResult(functionFragment: "deployer", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "isActive", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "moduleId", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "novaAddress",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "pluginId", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "pluginRegistry",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "setPluginId",
    data: BytesLike
  ): Result;

  events: {};
}

export interface IPlugin extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: IPluginInterface;

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

    isActive(overrides?: CallOverrides): Promise<[boolean]>;

    moduleId(overrides?: CallOverrides): Promise<[BigNumber]>;

    novaAddress(overrides?: CallOverrides): Promise<[string]>;

    pluginId(overrides?: CallOverrides): Promise<[BigNumber]>;

    pluginRegistry(overrides?: CallOverrides): Promise<[string]>;

    setPluginId(
      tokenId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;
  };

  deployer(overrides?: CallOverrides): Promise<string>;

  isActive(overrides?: CallOverrides): Promise<boolean>;

  moduleId(overrides?: CallOverrides): Promise<BigNumber>;

  novaAddress(overrides?: CallOverrides): Promise<string>;

  pluginId(overrides?: CallOverrides): Promise<BigNumber>;

  pluginRegistry(overrides?: CallOverrides): Promise<string>;

  setPluginId(
    tokenId: BigNumberish,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  callStatic: {
    deployer(overrides?: CallOverrides): Promise<string>;

    isActive(overrides?: CallOverrides): Promise<boolean>;

    moduleId(overrides?: CallOverrides): Promise<BigNumber>;

    novaAddress(overrides?: CallOverrides): Promise<string>;

    pluginId(overrides?: CallOverrides): Promise<BigNumber>;

    pluginRegistry(overrides?: CallOverrides): Promise<string>;

    setPluginId(
      tokenId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<void>;
  };

  filters: {};

  estimateGas: {
    deployer(overrides?: CallOverrides): Promise<BigNumber>;

    isActive(overrides?: CallOverrides): Promise<BigNumber>;

    moduleId(overrides?: CallOverrides): Promise<BigNumber>;

    novaAddress(overrides?: CallOverrides): Promise<BigNumber>;

    pluginId(overrides?: CallOverrides): Promise<BigNumber>;

    pluginRegistry(overrides?: CallOverrides): Promise<BigNumber>;

    setPluginId(
      tokenId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;
  };

  populateTransaction: {
    deployer(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    isActive(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    moduleId(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    novaAddress(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    pluginId(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    pluginRegistry(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    setPluginId(
      tokenId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;
  };
}