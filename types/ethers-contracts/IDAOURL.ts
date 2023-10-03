/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import type {
  BaseContract,
  BigNumber,
  BytesLike,
  CallOverrides,
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

export interface IDAOURLInterface extends utils.Interface {
  functions: {
    "getURLs()": FunctionFragment;
    "isURLListed(string)": FunctionFragment;
  };

  getFunction(
    nameOrSignatureOrTopic: "getURLs" | "isURLListed"
  ): FunctionFragment;

  encodeFunctionData(functionFragment: "getURLs", values?: undefined): string;
  encodeFunctionData(functionFragment: "isURLListed", values: [string]): string;

  decodeFunctionResult(functionFragment: "getURLs", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "isURLListed",
    data: BytesLike
  ): Result;

  events: {};
}

export interface IDAOURL extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: IDAOURLInterface;

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
    getURLs(overrides?: CallOverrides): Promise<[string[]]>;

    isURLListed(_url: string, overrides?: CallOverrides): Promise<[boolean]>;
  };

  getURLs(overrides?: CallOverrides): Promise<string[]>;

  isURLListed(_url: string, overrides?: CallOverrides): Promise<boolean>;

  callStatic: {
    getURLs(overrides?: CallOverrides): Promise<string[]>;

    isURLListed(_url: string, overrides?: CallOverrides): Promise<boolean>;
  };

  filters: {};

  estimateGas: {
    getURLs(overrides?: CallOverrides): Promise<BigNumber>;

    isURLListed(_url: string, overrides?: CallOverrides): Promise<BigNumber>;
  };

  populateTransaction: {
    getURLs(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    isURLListed(
      _url: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;
  };
}
