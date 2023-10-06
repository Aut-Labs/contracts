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

export interface NewMembershipCheckerInterface extends utils.Interface {
  functions: {
    "isMember(address,address)": FunctionFragment;
  };

  getFunction(nameOrSignatureOrTopic: "isMember"): FunctionFragment;

  encodeFunctionData(
    functionFragment: "isMember",
    values: [string, string]
  ): string;

  decodeFunctionResult(functionFragment: "isMember", data: BytesLike): Result;

  events: {};
}

export interface NewMembershipChecker extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: NewMembershipCheckerInterface;

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
    isMember(
      daoAddress: string,
      member: string,
      overrides?: CallOverrides
    ): Promise<[boolean]>;
  };

  isMember(
    daoAddress: string,
    member: string,
    overrides?: CallOverrides
  ): Promise<boolean>;

  callStatic: {
    isMember(
      daoAddress: string,
      member: string,
      overrides?: CallOverrides
    ): Promise<boolean>;
  };

  filters: {};

  estimateGas: {
    isMember(
      daoAddress: string,
      member: string,
      overrides?: CallOverrides
    ): Promise<BigNumber>;
  };

  populateTransaction: {
    isMember(
      daoAddress: string,
      member: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;
  };
}
