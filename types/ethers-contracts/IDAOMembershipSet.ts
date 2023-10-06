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
} from "./common";

export interface IDAOMembershipSetInterface extends utils.Interface {
  functions: {
    "join(address,uint256)": FunctionFragment;
  };

  getFunction(nameOrSignatureOrTopic: "join"): FunctionFragment;

  encodeFunctionData(
    functionFragment: "join",
    values: [string, BigNumberish]
  ): string;

  decodeFunctionResult(functionFragment: "join", data: BytesLike): Result;

  events: {
    "MemberAdded()": EventFragment;
  };

  getEvent(nameOrSignatureOrTopic: "MemberAdded"): EventFragment;
}

export interface MemberAddedEventObject {}
export type MemberAddedEvent = TypedEvent<[], MemberAddedEventObject>;

export type MemberAddedEventFilter = TypedEventFilter<MemberAddedEvent>;

export interface IDAOMembershipSet extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: IDAOMembershipSetInterface;

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
    join(
      newMember: string,
      role: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;
  };

  join(
    newMember: string,
    role: BigNumberish,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  callStatic: {
    join(
      newMember: string,
      role: BigNumberish,
      overrides?: CallOverrides
    ): Promise<void>;
  };

  filters: {
    "MemberAdded()"(): MemberAddedEventFilter;
    MemberAdded(): MemberAddedEventFilter;
  };

  estimateGas: {
    join(
      newMember: string,
      role: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;
  };

  populateTransaction: {
    join(
      newMember: string,
      role: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;
  };
}