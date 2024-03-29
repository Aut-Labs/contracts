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

export interface INovaRegistryInterface extends utils.Interface {
  functions: {
    "autIDAddr()": FunctionFragment;
    "deployNova(uint256,string,uint256)": FunctionFragment;
    "getNovaByDeployer(address)": FunctionFragment;
    "getNovas()": FunctionFragment;
    "pluginRegistry()": FunctionFragment;
  };

  getFunction(
    nameOrSignatureOrTopic:
      | "autIDAddr"
      | "deployNova"
      | "getNovaByDeployer"
      | "getNovas"
      | "pluginRegistry"
  ): FunctionFragment;

  encodeFunctionData(functionFragment: "autIDAddr", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "deployNova",
    values: [BigNumberish, string, BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "getNovaByDeployer",
    values: [string]
  ): string;
  encodeFunctionData(functionFragment: "getNovas", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "pluginRegistry",
    values?: undefined
  ): string;

  decodeFunctionResult(functionFragment: "autIDAddr", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "deployNova", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "getNovaByDeployer",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "getNovas", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "pluginRegistry",
    data: BytesLike
  ): Result;

  events: {};
}

export interface INovaRegistry extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: INovaRegistryInterface;

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
    autIDAddr(overrides?: CallOverrides): Promise<[string]>;

    deployNova(
      market: BigNumberish,
      metadata: string,
      commitment: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    getNovaByDeployer(
      deployer: string,
      overrides?: CallOverrides
    ): Promise<[string[]]>;

    getNovas(overrides?: CallOverrides): Promise<[string[]]>;

    pluginRegistry(overrides?: CallOverrides): Promise<[string]>;
  };

  autIDAddr(overrides?: CallOverrides): Promise<string>;

  deployNova(
    market: BigNumberish,
    metadata: string,
    commitment: BigNumberish,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  getNovaByDeployer(
    deployer: string,
    overrides?: CallOverrides
  ): Promise<string[]>;

  getNovas(overrides?: CallOverrides): Promise<string[]>;

  pluginRegistry(overrides?: CallOverrides): Promise<string>;

  callStatic: {
    autIDAddr(overrides?: CallOverrides): Promise<string>;

    deployNova(
      market: BigNumberish,
      metadata: string,
      commitment: BigNumberish,
      overrides?: CallOverrides
    ): Promise<string>;

    getNovaByDeployer(
      deployer: string,
      overrides?: CallOverrides
    ): Promise<string[]>;

    getNovas(overrides?: CallOverrides): Promise<string[]>;

    pluginRegistry(overrides?: CallOverrides): Promise<string>;
  };

  filters: {};

  estimateGas: {
    autIDAddr(overrides?: CallOverrides): Promise<BigNumber>;

    deployNova(
      market: BigNumberish,
      metadata: string,
      commitment: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    getNovaByDeployer(
      deployer: string,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    getNovas(overrides?: CallOverrides): Promise<BigNumber>;

    pluginRegistry(overrides?: CallOverrides): Promise<BigNumber>;
  };

  populateTransaction: {
    autIDAddr(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    deployNova(
      market: BigNumberish,
      metadata: string,
      commitment: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    getNovaByDeployer(
      deployer: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    getNovas(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    pluginRegistry(overrides?: CallOverrides): Promise<PopulatedTransaction>;
  };
}
