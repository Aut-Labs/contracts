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

export interface IDAOMembershipInterface extends utils.Interface {
  functions: {
    "canJoin(address,uint256)": FunctionFragment;
    "getAllMembers()": FunctionFragment;
    "isMember(address)": FunctionFragment;
  };

  getFunction(
    nameOrSignatureOrTopic: "canJoin" | "getAllMembers" | "isMember"
  ): FunctionFragment;

  encodeFunctionData(
    functionFragment: "canJoin",
    values: [string, BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "getAllMembers",
    values?: undefined
  ): string;
  encodeFunctionData(functionFragment: "isMember", values: [string]): string;

  decodeFunctionResult(functionFragment: "canJoin", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "getAllMembers",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "isMember", data: BytesLike): Result;

  events: {};
}

export interface IDAOMembership extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: IDAOMembershipInterface;

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
    canJoin(
      member: string,
      role: BigNumberish,
      overrides?: CallOverrides
    ): Promise<[boolean]>;

    getAllMembers(overrides?: CallOverrides): Promise<[string[]]>;

    isMember(member: string, overrides?: CallOverrides): Promise<[boolean]>;
  };

  canJoin(
    member: string,
    role: BigNumberish,
    overrides?: CallOverrides
  ): Promise<boolean>;

  getAllMembers(overrides?: CallOverrides): Promise<string[]>;

  isMember(member: string, overrides?: CallOverrides): Promise<boolean>;

  callStatic: {
    canJoin(
      member: string,
      role: BigNumberish,
      overrides?: CallOverrides
    ): Promise<boolean>;

    getAllMembers(overrides?: CallOverrides): Promise<string[]>;

    isMember(member: string, overrides?: CallOverrides): Promise<boolean>;
  };

  filters: {};

  estimateGas: {
    canJoin(
      member: string,
      role: BigNumberish,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    getAllMembers(overrides?: CallOverrides): Promise<BigNumber>;

    isMember(member: string, overrides?: CallOverrides): Promise<BigNumber>;
  };

  populateTransaction: {
    canJoin(
      member: string,
      role: BigNumberish,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    getAllMembers(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    isMember(
      member: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;
  };
}