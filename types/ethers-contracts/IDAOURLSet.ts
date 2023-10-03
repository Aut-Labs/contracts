/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import type {
  BaseContract,
  BigNumber,
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

export interface IDAOURLSetInterface extends utils.Interface {
  functions: {
    "addURL(string)": FunctionFragment;
    "removeURL(string)": FunctionFragment;
  };

  getFunction(nameOrSignatureOrTopic: "addURL" | "removeURL"): FunctionFragment;

  encodeFunctionData(functionFragment: "addURL", values: [string]): string;
  encodeFunctionData(functionFragment: "removeURL", values: [string]): string;

  decodeFunctionResult(functionFragment: "addURL", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "removeURL", data: BytesLike): Result;

  events: {};
}

export interface IDAOURLSet extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: IDAOURLSetInterface;

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

    removeURL(
      _url: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;
  };

  addURL(
    _url: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  removeURL(
    _url: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  callStatic: {
    addURL(_url: string, overrides?: CallOverrides): Promise<void>;

    removeURL(_url: string, overrides?: CallOverrides): Promise<void>;
  };

  filters: {};

  estimateGas: {
    addURL(
      _url: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    removeURL(
      _url: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;
  };

  populateTransaction: {
    addURL(
      _url: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    removeURL(
      _url: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;
  };
}
