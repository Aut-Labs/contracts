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

export interface IDAOMetadataInterface extends utils.Interface {
  functions: {
    "metadataUrl()": FunctionFragment;
  };

  getFunction(nameOrSignatureOrTopic: "metadataUrl"): FunctionFragment;

  encodeFunctionData(
    functionFragment: "metadataUrl",
    values?: undefined
  ): string;

  decodeFunctionResult(
    functionFragment: "metadataUrl",
    data: BytesLike
  ): Result;

  events: {};
}

export interface IDAOMetadata extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: IDAOMetadataInterface;

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
    metadataUrl(overrides?: CallOverrides): Promise<[string] & { uri: string }>;
  };

  metadataUrl(overrides?: CallOverrides): Promise<string>;

  callStatic: {
    metadataUrl(overrides?: CallOverrides): Promise<string>;
  };

  filters: {};

  estimateGas: {
    metadataUrl(overrides?: CallOverrides): Promise<BigNumber>;
  };

  populateTransaction: {
    metadataUrl(overrides?: CallOverrides): Promise<PopulatedTransaction>;
  };
}
