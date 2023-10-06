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
} from "../common";

export interface SWLegacyDAOInterface extends utils.Interface {
  functions: {
    "addMember(address)": FunctionFragment;
    "isMember(address)": FunctionFragment;
  };

  getFunction(
    nameOrSignatureOrTopic: "addMember" | "isMember"
  ): FunctionFragment;

  encodeFunctionData(functionFragment: "addMember", values: [string]): string;
  encodeFunctionData(functionFragment: "isMember", values: [string]): string;

  decodeFunctionResult(functionFragment: "addMember", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "isMember", data: BytesLike): Result;

  events: {};
}

export interface SWLegacyDAO extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: SWLegacyDAOInterface;

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
    addMember(
      member: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    isMember(arg0: string, overrides?: CallOverrides): Promise<[boolean]>;
  };

  addMember(
    member: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  isMember(arg0: string, overrides?: CallOverrides): Promise<boolean>;

  callStatic: {
    addMember(member: string, overrides?: CallOverrides): Promise<void>;

    isMember(arg0: string, overrides?: CallOverrides): Promise<boolean>;
  };

  filters: {};

  estimateGas: {
    addMember(
      member: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    isMember(arg0: string, overrides?: CallOverrides): Promise<BigNumber>;
  };

  populateTransaction: {
    addMember(
      member: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    isMember(
      arg0: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;
  };
}
