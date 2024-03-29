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

export type PeriodDataStruct = {
  aDiffMembersLP: BigNumberish;
  bMembersLastLP: BigNumberish;
  cAverageRepLP: BigNumberish;
  dAverageCommitmentLP: BigNumberish;
  ePerformanceLP: BigNumberish;
};

export type PeriodDataStructOutput = [
  number,
  number,
  BigNumber,
  BigNumber,
  BigNumber
] & {
  aDiffMembersLP: number;
  bMembersLastLP: number;
  cAverageRepLP: BigNumber;
  dAverageCommitmentLP: BigNumber;
  ePerformanceLP: BigNumber;
};

export type GroupStateStruct = {
  lastPeriod: BigNumberish;
  TCL: BigNumberish;
  TCP: BigNumberish;
  k: BigNumberish;
  penalty: BigNumberish;
  c: BigNumberish;
  p: BigNumberish;
  commitHash: BytesLike;
  lrUpdatesPerPeriod: BigNumberish;
  periodNovaParameters: PeriodDataStruct;
};

export type GroupStateStructOutput = [
  BigNumber,
  BigNumber,
  BigNumber,
  number,
  number,
  number,
  number,
  string,
  BigNumber,
  PeriodDataStructOutput
] & {
  lastPeriod: BigNumber;
  TCL: BigNumber;
  TCP: BigNumber;
  k: number;
  penalty: number;
  c: number;
  p: number;
  commitHash: string;
  lrUpdatesPerPeriod: BigNumber;
  periodNovaParameters: PeriodDataStructOutput;
};

export type IndividualStateStruct = {
  iCL: BigNumberish;
  GC: BigNumberish;
  score: BigNumberish;
  lastUpdatedAt: BigNumberish;
};

export type IndividualStateStructOutput = [
  BigNumber,
  BigNumber,
  BigNumber,
  BigNumber
] & {
  iCL: BigNumber;
  GC: BigNumber;
  score: BigNumber;
  lastUpdatedAt: BigNumber;
};

export interface ILocalReputationInterface extends utils.Interface {
  functions: {
    "bulkPeriodicUpdate(address)": FunctionFragment;
    "calculateLocalReputation(uint256,uint256,uint256,uint256,uint256,uint256,uint256)": FunctionFragment;
    "getAvReputationAndCommitment(address)": FunctionFragment;
    "getGroupState(address)": FunctionFragment;
    "getIndividualState(address,address)": FunctionFragment;
    "getPeriodNovaParameters(address)": FunctionFragment;
    "initialize(address)": FunctionFragment;
    "interaction(bytes,address)": FunctionFragment;
    "periodicGroupStateUpdate(address)": FunctionFragment;
    "setInteractionWeights(address,bytes[],uint16[])": FunctionFragment;
    "setKP(uint16,uint32,uint8,address)": FunctionFragment;
    "updateCommitmentLevels(address)": FunctionFragment;
    "updateIndividualLR(address,address)": FunctionFragment;
  };

  getFunction(
    nameOrSignatureOrTopic:
      | "bulkPeriodicUpdate"
      | "calculateLocalReputation"
      | "getAvReputationAndCommitment"
      | "getGroupState"
      | "getIndividualState"
      | "getPeriodNovaParameters"
      | "initialize"
      | "interaction"
      | "periodicGroupStateUpdate"
      | "setInteractionWeights"
      | "setKP"
      | "updateCommitmentLevels"
      | "updateIndividualLR"
  ): FunctionFragment;

  encodeFunctionData(
    functionFragment: "bulkPeriodicUpdate",
    values: [string]
  ): string;
  encodeFunctionData(
    functionFragment: "calculateLocalReputation",
    values: [
      BigNumberish,
      BigNumberish,
      BigNumberish,
      BigNumberish,
      BigNumberish,
      BigNumberish,
      BigNumberish
    ]
  ): string;
  encodeFunctionData(
    functionFragment: "getAvReputationAndCommitment",
    values: [string]
  ): string;
  encodeFunctionData(
    functionFragment: "getGroupState",
    values: [string]
  ): string;
  encodeFunctionData(
    functionFragment: "getIndividualState",
    values: [string, string]
  ): string;
  encodeFunctionData(
    functionFragment: "getPeriodNovaParameters",
    values: [string]
  ): string;
  encodeFunctionData(functionFragment: "initialize", values: [string]): string;
  encodeFunctionData(
    functionFragment: "interaction",
    values: [BytesLike, string]
  ): string;
  encodeFunctionData(
    functionFragment: "periodicGroupStateUpdate",
    values: [string]
  ): string;
  encodeFunctionData(
    functionFragment: "setInteractionWeights",
    values: [string, BytesLike[], BigNumberish[]]
  ): string;
  encodeFunctionData(
    functionFragment: "setKP",
    values: [BigNumberish, BigNumberish, BigNumberish, string]
  ): string;
  encodeFunctionData(
    functionFragment: "updateCommitmentLevels",
    values: [string]
  ): string;
  encodeFunctionData(
    functionFragment: "updateIndividualLR",
    values: [string, string]
  ): string;

  decodeFunctionResult(
    functionFragment: "bulkPeriodicUpdate",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "calculateLocalReputation",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getAvReputationAndCommitment",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getGroupState",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getIndividualState",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getPeriodNovaParameters",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "initialize", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "interaction",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "periodicGroupStateUpdate",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "setInteractionWeights",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "setKP", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "updateCommitmentLevels",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "updateIndividualLR",
    data: BytesLike
  ): Result;

  events: {
    "EndOfPeriod()": EventFragment;
    "Interaction(uint256,address)": EventFragment;
    "LocalRepInit(address,address)": EventFragment;
    "SetWeightsFor(address,uint256)": EventFragment;
    "UpdatedKP(address)": EventFragment;
  };

  getEvent(nameOrSignatureOrTopic: "EndOfPeriod"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "Interaction"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "LocalRepInit"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "SetWeightsFor"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "UpdatedKP"): EventFragment;
}

export interface EndOfPeriodEventObject {}
export type EndOfPeriodEvent = TypedEvent<[], EndOfPeriodEventObject>;

export type EndOfPeriodEventFilter = TypedEventFilter<EndOfPeriodEvent>;

export interface InteractionEventObject {
  InteractionID: BigNumber;
  agent: string;
}
export type InteractionEvent = TypedEvent<
  [BigNumber, string],
  InteractionEventObject
>;

export type InteractionEventFilter = TypedEventFilter<InteractionEvent>;

export interface LocalRepInitEventObject {
  Nova: string;
  PluginAddr: string;
}
export type LocalRepInitEvent = TypedEvent<
  [string, string],
  LocalRepInitEventObject
>;

export type LocalRepInitEventFilter = TypedEventFilter<LocalRepInitEvent>;

export interface SetWeightsForEventObject {
  plugin: string;
  interactionId: BigNumber;
}
export type SetWeightsForEvent = TypedEvent<
  [string, BigNumber],
  SetWeightsForEventObject
>;

export type SetWeightsForEventFilter = TypedEventFilter<SetWeightsForEvent>;

export interface UpdatedKPEventObject {
  targetGroup: string;
}
export type UpdatedKPEvent = TypedEvent<[string], UpdatedKPEventObject>;

export type UpdatedKPEventFilter = TypedEventFilter<UpdatedKPEvent>;

export interface ILocalReputation extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: ILocalReputationInterface;

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
    bulkPeriodicUpdate(
      group_: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    calculateLocalReputation(
      iGC: BigNumberish,
      iCL: BigNumberish,
      TCL: BigNumberish,
      TCP: BigNumberish,
      k: BigNumberish,
      prevScore: BigNumberish,
      penalty: BigNumberish,
      overrides?: CallOverrides
    ): Promise<[BigNumber] & { score: BigNumber }>;

    getAvReputationAndCommitment(
      nova_: string,
      overrides?: CallOverrides
    ): Promise<
      [BigNumber, BigNumber] & { sumCommit: BigNumber; sumRep: BigNumber }
    >;

    getGroupState(
      nova_: string,
      overrides?: CallOverrides
    ): Promise<[GroupStateStructOutput]>;

    getIndividualState(
      agent_: string,
      nova_: string,
      overrides?: CallOverrides
    ): Promise<[IndividualStateStructOutput]>;

    getPeriodNovaParameters(
      nova_: string,
      overrides?: CallOverrides
    ): Promise<[PeriodDataStructOutput]>;

    initialize(
      dao_: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    interaction(
      msgData: BytesLike,
      agent: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    periodicGroupStateUpdate(
      group_: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    setInteractionWeights(
      plugin_: string,
      datas: BytesLike[],
      points: BigNumberish[],
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    setKP(
      k: BigNumberish,
      p: BigNumberish,
      penalty: BigNumberish,
      target_: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    updateCommitmentLevels(
      nova_: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    updateIndividualLR(
      who_: string,
      group_: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;
  };

  bulkPeriodicUpdate(
    group_: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  calculateLocalReputation(
    iGC: BigNumberish,
    iCL: BigNumberish,
    TCL: BigNumberish,
    TCP: BigNumberish,
    k: BigNumberish,
    prevScore: BigNumberish,
    penalty: BigNumberish,
    overrides?: CallOverrides
  ): Promise<BigNumber>;

  getAvReputationAndCommitment(
    nova_: string,
    overrides?: CallOverrides
  ): Promise<
    [BigNumber, BigNumber] & { sumCommit: BigNumber; sumRep: BigNumber }
  >;

  getGroupState(
    nova_: string,
    overrides?: CallOverrides
  ): Promise<GroupStateStructOutput>;

  getIndividualState(
    agent_: string,
    nova_: string,
    overrides?: CallOverrides
  ): Promise<IndividualStateStructOutput>;

  getPeriodNovaParameters(
    nova_: string,
    overrides?: CallOverrides
  ): Promise<PeriodDataStructOutput>;

  initialize(
    dao_: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  interaction(
    msgData: BytesLike,
    agent: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  periodicGroupStateUpdate(
    group_: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  setInteractionWeights(
    plugin_: string,
    datas: BytesLike[],
    points: BigNumberish[],
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  setKP(
    k: BigNumberish,
    p: BigNumberish,
    penalty: BigNumberish,
    target_: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  updateCommitmentLevels(
    nova_: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  updateIndividualLR(
    who_: string,
    group_: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  callStatic: {
    bulkPeriodicUpdate(
      group_: string,
      overrides?: CallOverrides
    ): Promise<BigNumber[]>;

    calculateLocalReputation(
      iGC: BigNumberish,
      iCL: BigNumberish,
      TCL: BigNumberish,
      TCP: BigNumberish,
      k: BigNumberish,
      prevScore: BigNumberish,
      penalty: BigNumberish,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    getAvReputationAndCommitment(
      nova_: string,
      overrides?: CallOverrides
    ): Promise<
      [BigNumber, BigNumber] & { sumCommit: BigNumber; sumRep: BigNumber }
    >;

    getGroupState(
      nova_: string,
      overrides?: CallOverrides
    ): Promise<GroupStateStructOutput>;

    getIndividualState(
      agent_: string,
      nova_: string,
      overrides?: CallOverrides
    ): Promise<IndividualStateStructOutput>;

    getPeriodNovaParameters(
      nova_: string,
      overrides?: CallOverrides
    ): Promise<PeriodDataStructOutput>;

    initialize(dao_: string, overrides?: CallOverrides): Promise<void>;

    interaction(
      msgData: BytesLike,
      agent: string,
      overrides?: CallOverrides
    ): Promise<void>;

    periodicGroupStateUpdate(
      group_: string,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    setInteractionWeights(
      plugin_: string,
      datas: BytesLike[],
      points: BigNumberish[],
      overrides?: CallOverrides
    ): Promise<void>;

    setKP(
      k: BigNumberish,
      p: BigNumberish,
      penalty: BigNumberish,
      target_: string,
      overrides?: CallOverrides
    ): Promise<void>;

    updateCommitmentLevels(
      nova_: string,
      overrides?: CallOverrides
    ): Promise<BigNumber[]>;

    updateIndividualLR(
      who_: string,
      group_: string,
      overrides?: CallOverrides
    ): Promise<BigNumber>;
  };

  filters: {
    "EndOfPeriod()"(): EndOfPeriodEventFilter;
    EndOfPeriod(): EndOfPeriodEventFilter;

    "Interaction(uint256,address)"(
      InteractionID?: null,
      agent?: null
    ): InteractionEventFilter;
    Interaction(InteractionID?: null, agent?: null): InteractionEventFilter;

    "LocalRepInit(address,address)"(
      Nova?: null,
      PluginAddr?: null
    ): LocalRepInitEventFilter;
    LocalRepInit(Nova?: null, PluginAddr?: null): LocalRepInitEventFilter;

    "SetWeightsFor(address,uint256)"(
      plugin?: null,
      interactionId?: null
    ): SetWeightsForEventFilter;
    SetWeightsFor(
      plugin?: null,
      interactionId?: null
    ): SetWeightsForEventFilter;

    "UpdatedKP(address)"(targetGroup?: null): UpdatedKPEventFilter;
    UpdatedKP(targetGroup?: null): UpdatedKPEventFilter;
  };

  estimateGas: {
    bulkPeriodicUpdate(
      group_: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    calculateLocalReputation(
      iGC: BigNumberish,
      iCL: BigNumberish,
      TCL: BigNumberish,
      TCP: BigNumberish,
      k: BigNumberish,
      prevScore: BigNumberish,
      penalty: BigNumberish,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    getAvReputationAndCommitment(
      nova_: string,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    getGroupState(nova_: string, overrides?: CallOverrides): Promise<BigNumber>;

    getIndividualState(
      agent_: string,
      nova_: string,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    getPeriodNovaParameters(
      nova_: string,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    initialize(
      dao_: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    interaction(
      msgData: BytesLike,
      agent: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    periodicGroupStateUpdate(
      group_: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    setInteractionWeights(
      plugin_: string,
      datas: BytesLike[],
      points: BigNumberish[],
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    setKP(
      k: BigNumberish,
      p: BigNumberish,
      penalty: BigNumberish,
      target_: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    updateCommitmentLevels(
      nova_: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    updateIndividualLR(
      who_: string,
      group_: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;
  };

  populateTransaction: {
    bulkPeriodicUpdate(
      group_: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    calculateLocalReputation(
      iGC: BigNumberish,
      iCL: BigNumberish,
      TCL: BigNumberish,
      TCP: BigNumberish,
      k: BigNumberish,
      prevScore: BigNumberish,
      penalty: BigNumberish,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    getAvReputationAndCommitment(
      nova_: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    getGroupState(
      nova_: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    getIndividualState(
      agent_: string,
      nova_: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    getPeriodNovaParameters(
      nova_: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    initialize(
      dao_: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    interaction(
      msgData: BytesLike,
      agent: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    periodicGroupStateUpdate(
      group_: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    setInteractionWeights(
      plugin_: string,
      datas: BytesLike[],
      points: BigNumberish[],
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    setKP(
      k: BigNumberish,
      p: BigNumberish,
      penalty: BigNumberish,
      target_: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    updateCommitmentLevels(
      nova_: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    updateIndividualLR(
      who_: string,
      group_: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;
  };
}
