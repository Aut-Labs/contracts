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

export interface DAOCommitmentInterface extends utils.Interface {
  functions: {
    "getCommitment()": FunctionFragment;
  };

  getFunction(nameOrSignatureOrTopic: "getCommitment"): FunctionFragment;

  encodeFunctionData(
    functionFragment: "getCommitment",
    values?: undefined
  ): string;

  decodeFunctionResult(
    functionFragment: "getCommitment",
    data: BytesLike
  ): Result;

  events: {
    "CommitmentSet()": EventFragment;
  };

  getEvent(nameOrSignatureOrTopic: "CommitmentSet"): EventFragment;
}

export interface CommitmentSetEventObject {}
export type CommitmentSetEvent = TypedEvent<[], CommitmentSetEventObject>;

export type CommitmentSetEventFilter = TypedEventFilter<CommitmentSetEvent>;

export interface DAOCommitment extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: DAOCommitmentInterface;

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
    getCommitment(overrides?: CallOverrides): Promise<[BigNumber]>;
  };

  getCommitment(overrides?: CallOverrides): Promise<BigNumber>;

  callStatic: {
    getCommitment(overrides?: CallOverrides): Promise<BigNumber>;
  };

  filters: {
    "CommitmentSet()"(): CommitmentSetEventFilter;
    CommitmentSet(): CommitmentSetEventFilter;
  };

  estimateGas: {
    getCommitment(overrides?: CallOverrides): Promise<BigNumber>;
  };

  populateTransaction: {
    getCommitment(overrides?: CallOverrides): Promise<PopulatedTransaction>;
  };
}
