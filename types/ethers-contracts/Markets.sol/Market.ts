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
} from "../common";

export declare namespace IMarket {
  export type MarketModelStruct = { id: BigNumberish; metadata: string };

  export type MarketModelStructOutput = [BigNumber, string] & {
    id: BigNumber;
    metadata: string;
  };
}

export interface MarketInterface extends utils.Interface {
  functions: {
    "addMarket(string)": FunctionFragment;
    "getMarket(uint256)": FunctionFragment;
    "getMarket()": FunctionFragment;
    "owner()": FunctionFragment;
    "renounceOwnership()": FunctionFragment;
    "transferOwnership(address)": FunctionFragment;
  };

  getFunction(
    nameOrSignatureOrTopic:
      | "addMarket"
      | "getMarket(uint256)"
      | "getMarket()"
      | "owner"
      | "renounceOwnership"
      | "transferOwnership"
  ): FunctionFragment;

  encodeFunctionData(functionFragment: "addMarket", values: [string]): string;
  encodeFunctionData(
    functionFragment: "getMarket(uint256)",
    values: [BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "getMarket()",
    values?: undefined
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

  decodeFunctionResult(functionFragment: "addMarket", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "getMarket(uint256)",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getMarket()",
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

  events: {
    "AddedMarket(uint256,string)": EventFragment;
    "OwnershipTransferred(address,address)": EventFragment;
  };

  getEvent(nameOrSignatureOrTopic: "AddedMarket"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "OwnershipTransferred"): EventFragment;
}

export interface AddedMarketEventObject {
  id: BigNumber;
  market: string;
}
export type AddedMarketEvent = TypedEvent<
  [BigNumber, string],
  AddedMarketEventObject
>;

export type AddedMarketEventFilter = TypedEventFilter<AddedMarketEvent>;

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

export interface Market extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: MarketInterface;

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
    addMarket(
      marketName: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    "getMarket(uint256)"(
      _marketId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<[IMarket.MarketModelStructOutput]>;

    "getMarket()"(overrides?: CallOverrides): Promise<[string]>;

    owner(overrides?: CallOverrides): Promise<[string]>;

    renounceOwnership(
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    transferOwnership(
      newOwner: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;
  };

  addMarket(
    marketName: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  "getMarket(uint256)"(
    _marketId: BigNumberish,
    overrides?: CallOverrides
  ): Promise<IMarket.MarketModelStructOutput>;

  "getMarket()"(overrides?: CallOverrides): Promise<string>;

  owner(overrides?: CallOverrides): Promise<string>;

  renounceOwnership(
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  transferOwnership(
    newOwner: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  callStatic: {
    addMarket(marketName: string, overrides?: CallOverrides): Promise<void>;

    "getMarket(uint256)"(
      _marketId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<IMarket.MarketModelStructOutput>;

    "getMarket()"(overrides?: CallOverrides): Promise<string>;

    owner(overrides?: CallOverrides): Promise<string>;

    renounceOwnership(overrides?: CallOverrides): Promise<void>;

    transferOwnership(
      newOwner: string,
      overrides?: CallOverrides
    ): Promise<void>;
  };

  filters: {
    "AddedMarket(uint256,string)"(
      id?: null,
      market?: null
    ): AddedMarketEventFilter;
    AddedMarket(id?: null, market?: null): AddedMarketEventFilter;

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
    addMarket(
      marketName: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    "getMarket(uint256)"(
      _marketId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    "getMarket()"(overrides?: CallOverrides): Promise<BigNumber>;

    owner(overrides?: CallOverrides): Promise<BigNumber>;

    renounceOwnership(
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    transferOwnership(
      newOwner: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;
  };

  populateTransaction: {
    addMarket(
      marketName: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    "getMarket(uint256)"(
      _marketId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    "getMarket()"(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    owner(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    renounceOwnership(
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    transferOwnership(
      newOwner: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;
  };
}
