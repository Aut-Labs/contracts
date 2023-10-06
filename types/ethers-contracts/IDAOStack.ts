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

export interface IDAOStackInterface extends utils.Interface {
  functions: {
    "nativeReputation()": FunctionFragment;
    "nativeToken()": FunctionFragment;
  };

  getFunction(
    nameOrSignatureOrTopic: "nativeReputation" | "nativeToken"
  ): FunctionFragment;

  encodeFunctionData(
    functionFragment: "nativeReputation",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "nativeToken",
    values?: undefined
  ): string;

  decodeFunctionResult(
    functionFragment: "nativeReputation",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "nativeToken",
    data: BytesLike
  ): Result;

  events: {};
}

export interface IDAOStack extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: IDAOStackInterface;

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
    nativeReputation(overrides?: CallOverrides): Promise<[string]>;

    nativeToken(overrides?: CallOverrides): Promise<[string]>;
  };

  nativeReputation(overrides?: CallOverrides): Promise<string>;

  nativeToken(overrides?: CallOverrides): Promise<string>;

  callStatic: {
    nativeReputation(overrides?: CallOverrides): Promise<string>;

    nativeToken(overrides?: CallOverrides): Promise<string>;
  };

  filters: {};

  estimateGas: {
    nativeReputation(overrides?: CallOverrides): Promise<BigNumber>;

    nativeToken(overrides?: CallOverrides): Promise<BigNumber>;
  };

  populateTransaction: {
    nativeReputation(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    nativeToken(overrides?: CallOverrides): Promise<PopulatedTransaction>;
  };
}
