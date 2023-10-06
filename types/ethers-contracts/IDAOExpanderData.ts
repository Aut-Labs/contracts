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

export declare namespace IDAOExpanderData {
  export type DAOExpanssionDataStruct = {
    contractType: BigNumberish;
    daoAddress: string;
  };

  export type DAOExpanssionDataStructOutput = [BigNumber, string] & {
    contractType: BigNumber;
    daoAddress: string;
  };
}

export interface IDAOExpanderDataInterface extends utils.Interface {
  functions: {
    "getDAOData()": FunctionFragment;
  };

  getFunction(nameOrSignatureOrTopic: "getDAOData"): FunctionFragment;

  encodeFunctionData(
    functionFragment: "getDAOData",
    values?: undefined
  ): string;

  decodeFunctionResult(functionFragment: "getDAOData", data: BytesLike): Result;

  events: {
    "DiscordServerSet()": EventFragment;
  };

  getEvent(nameOrSignatureOrTopic: "DiscordServerSet"): EventFragment;
}

export interface DiscordServerSetEventObject {}
export type DiscordServerSetEvent = TypedEvent<[], DiscordServerSetEventObject>;

export type DiscordServerSetEventFilter =
  TypedEventFilter<DiscordServerSetEvent>;

export interface IDAOExpanderData extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: IDAOExpanderDataInterface;

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
    getDAOData(
      overrides?: CallOverrides
    ): Promise<
      [IDAOExpanderData.DAOExpanssionDataStructOutput] & {
        data: IDAOExpanderData.DAOExpanssionDataStructOutput;
      }
    >;
  };

  getDAOData(
    overrides?: CallOverrides
  ): Promise<IDAOExpanderData.DAOExpanssionDataStructOutput>;

  callStatic: {
    getDAOData(
      overrides?: CallOverrides
    ): Promise<IDAOExpanderData.DAOExpanssionDataStructOutput>;
  };

  filters: {
    "DiscordServerSet()"(): DiscordServerSetEventFilter;
    DiscordServerSet(): DiscordServerSetEventFilter;
  };

  estimateGas: {
    getDAOData(overrides?: CallOverrides): Promise<BigNumber>;
  };

  populateTransaction: {
    getDAOData(overrides?: CallOverrides): Promise<PopulatedTransaction>;
  };
}