/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import type {
  BaseContract,
  BigNumber,
  BigNumberish,
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

export declare namespace IMoloch {
  export type MemberStruct = {
    delegateKey: string;
    shares: BigNumberish;
    loot: BigNumberish;
    exists: boolean;
    highestIndexYesVote: BigNumberish;
    jailed: BigNumberish;
  };

  export type MemberStructOutput = [
    string,
    BigNumber,
    BigNumber,
    boolean,
    BigNumber,
    BigNumber
  ] & {
    delegateKey: string;
    shares: BigNumber;
    loot: BigNumber;
    exists: boolean;
    highestIndexYesVote: BigNumber;
    jailed: BigNumber;
  };
}

export interface IMolochInterface extends utils.Interface {
  functions: {
    "members(address)": FunctionFragment;
  };

  getFunction(nameOrSignatureOrTopic: "members"): FunctionFragment;

  encodeFunctionData(functionFragment: "members", values: [string]): string;

  decodeFunctionResult(functionFragment: "members", data: BytesLike): Result;

  events: {};
}

export interface IMoloch extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: IMolochInterface;

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
    members(
      member: string,
      overrides?: CallOverrides
    ): Promise<[IMoloch.MemberStructOutput]>;
  };

  members(
    member: string,
    overrides?: CallOverrides
  ): Promise<IMoloch.MemberStructOutput>;

  callStatic: {
    members(
      member: string,
      overrides?: CallOverrides
    ): Promise<IMoloch.MemberStructOutput>;
  };

  filters: {};

  estimateGas: {
    members(member: string, overrides?: CallOverrides): Promise<BigNumber>;
  };

  populateTransaction: {
    members(
      member: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;
  };
}