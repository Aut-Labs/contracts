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

export declare namespace TasksModule {
  export type TaskStruct = {
    createdOn: BigNumberish;
    creator: string;
    role: BigNumberish;
    metadata: string;
    startDate: BigNumberish;
    endDate: BigNumberish;
  };

  export type TaskStructOutput = [
    BigNumber,
    string,
    BigNumber,
    string,
    BigNumber,
    BigNumber
  ] & {
    createdOn: BigNumber;
    creator: string;
    role: BigNumber;
    metadata: string;
    startDate: BigNumber;
    endDate: BigNumber;
  };
}

export interface OffchainVerifiedTaskPluginInterface extends utils.Interface {
  functions: {
    "_offchainVerifierAddress()": FunctionFragment;
    "create(uint256,string,uint256,uint256)": FunctionFragment;
    "createBy(address,uint256,string,uint256,uint256)": FunctionFragment;
    "deployer()": FunctionFragment;
    "editTask(uint256,uint256,string,uint256,uint256)": FunctionFragment;
    "finalize(uint256)": FunctionFragment;
    "finalizeFor(uint256,address)": FunctionFragment;
    "getById(uint256)": FunctionFragment;
    "getCompletionTime(uint256,address)": FunctionFragment;
    "getStatusPerSubmitter(uint256,address)": FunctionFragment;
    "hasCompletedTheTask(address,uint256)": FunctionFragment;
    "idCounter()": FunctionFragment;
    "isActive()": FunctionFragment;
    "moduleId()": FunctionFragment;
    "novaAddress()": FunctionFragment;
    "owner()": FunctionFragment;
    "pluginId()": FunctionFragment;
    "pluginRegistry()": FunctionFragment;
    "setOffchainVerifierAddress(address)": FunctionFragment;
    "setPluginId(uint256)": FunctionFragment;
    "submit(uint256,string)": FunctionFragment;
    "take(uint256)": FunctionFragment;
    "tasks(uint256)": FunctionFragment;
  };

  getFunction(
    nameOrSignatureOrTopic:
      | "_offchainVerifierAddress"
      | "create"
      | "createBy"
      | "deployer"
      | "editTask"
      | "finalize"
      | "finalizeFor"
      | "getById"
      | "getCompletionTime"
      | "getStatusPerSubmitter"
      | "hasCompletedTheTask"
      | "idCounter"
      | "isActive"
      | "moduleId"
      | "novaAddress"
      | "owner"
      | "pluginId"
      | "pluginRegistry"
      | "setOffchainVerifierAddress"
      | "setPluginId"
      | "submit"
      | "take"
      | "tasks"
  ): FunctionFragment;

  encodeFunctionData(
    functionFragment: "_offchainVerifierAddress",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "create",
    values: [BigNumberish, string, BigNumberish, BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "createBy",
    values: [string, BigNumberish, string, BigNumberish, BigNumberish]
  ): string;
  encodeFunctionData(functionFragment: "deployer", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "editTask",
    values: [BigNumberish, BigNumberish, string, BigNumberish, BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "finalize",
    values: [BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "finalizeFor",
    values: [BigNumberish, string]
  ): string;
  encodeFunctionData(
    functionFragment: "getById",
    values: [BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "getCompletionTime",
    values: [BigNumberish, string]
  ): string;
  encodeFunctionData(
    functionFragment: "getStatusPerSubmitter",
    values: [BigNumberish, string]
  ): string;
  encodeFunctionData(
    functionFragment: "hasCompletedTheTask",
    values: [string, BigNumberish]
  ): string;
  encodeFunctionData(functionFragment: "idCounter", values?: undefined): string;
  encodeFunctionData(functionFragment: "isActive", values?: undefined): string;
  encodeFunctionData(functionFragment: "moduleId", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "novaAddress",
    values?: undefined
  ): string;
  encodeFunctionData(functionFragment: "owner", values?: undefined): string;
  encodeFunctionData(functionFragment: "pluginId", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "pluginRegistry",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "setOffchainVerifierAddress",
    values: [string]
  ): string;
  encodeFunctionData(
    functionFragment: "setPluginId",
    values: [BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "submit",
    values: [BigNumberish, string]
  ): string;
  encodeFunctionData(functionFragment: "take", values: [BigNumberish]): string;
  encodeFunctionData(functionFragment: "tasks", values: [BigNumberish]): string;

  decodeFunctionResult(
    functionFragment: "_offchainVerifierAddress",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "create", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "createBy", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "deployer", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "editTask", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "finalize", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "finalizeFor",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "getById", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "getCompletionTime",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getStatusPerSubmitter",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "hasCompletedTheTask",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "idCounter", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "isActive", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "moduleId", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "novaAddress",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "owner", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "pluginId", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "pluginRegistry",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "setOffchainVerifierAddress",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "setPluginId",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "submit", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "take", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "tasks", data: BytesLike): Result;

  events: {
    "TaskCreated(uint256,string)": EventFragment;
    "TaskEdited(uint256,string)": EventFragment;
    "TaskFinalized(uint256,address)": EventFragment;
    "TaskSubmitted(uint256,uint256)": EventFragment;
    "TaskTaken(uint256,address)": EventFragment;
  };

  getEvent(nameOrSignatureOrTopic: "TaskCreated"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "TaskEdited"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "TaskFinalized"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "TaskSubmitted"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "TaskTaken"): EventFragment;
}

export interface TaskCreatedEventObject {
  taskID: BigNumber;
  uri: string;
}
export type TaskCreatedEvent = TypedEvent<
  [BigNumber, string],
  TaskCreatedEventObject
>;

export type TaskCreatedEventFilter = TypedEventFilter<TaskCreatedEvent>;

export interface TaskEditedEventObject {
  taskID: BigNumber;
  uri: string;
}
export type TaskEditedEvent = TypedEvent<
  [BigNumber, string],
  TaskEditedEventObject
>;

export type TaskEditedEventFilter = TypedEventFilter<TaskEditedEvent>;

export interface TaskFinalizedEventObject {
  taskID: BigNumber;
  taker: string;
}
export type TaskFinalizedEvent = TypedEvent<
  [BigNumber, string],
  TaskFinalizedEventObject
>;

export type TaskFinalizedEventFilter = TypedEventFilter<TaskFinalizedEvent>;

export interface TaskSubmittedEventObject {
  taskID: BigNumber;
  submissionId: BigNumber;
}
export type TaskSubmittedEvent = TypedEvent<
  [BigNumber, BigNumber],
  TaskSubmittedEventObject
>;

export type TaskSubmittedEventFilter = TypedEventFilter<TaskSubmittedEvent>;

export interface TaskTakenEventObject {
  taskID: BigNumber;
  taker: string;
}
export type TaskTakenEvent = TypedEvent<
  [BigNumber, string],
  TaskTakenEventObject
>;

export type TaskTakenEventFilter = TypedEventFilter<TaskTakenEvent>;

export interface OffchainVerifiedTaskPlugin extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: OffchainVerifiedTaskPluginInterface;

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
    _offchainVerifierAddress(overrides?: CallOverrides): Promise<[string]>;

    create(
      role: BigNumberish,
      uri: string,
      startDate: BigNumberish,
      endDate: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    createBy(
      creator: string,
      role: BigNumberish,
      uri: string,
      startDate: BigNumberish,
      endDate: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    deployer(overrides?: CallOverrides): Promise<[string]>;

    editTask(
      taskId: BigNumberish,
      role: BigNumberish,
      uri: string,
      startDate: BigNumberish,
      endDate: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    finalize(
      taskId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    finalizeFor(
      taskId: BigNumberish,
      submitter: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    getById(
      taskId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<[TasksModule.TaskStructOutput]>;

    getCompletionTime(
      taskId: BigNumberish,
      user: string,
      overrides?: CallOverrides
    ): Promise<[BigNumber]>;

    getStatusPerSubmitter(
      taskId: BigNumberish,
      submitter: string,
      overrides?: CallOverrides
    ): Promise<[number]>;

    hasCompletedTheTask(
      user: string,
      taskId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<[boolean]>;

    idCounter(
      overrides?: CallOverrides
    ): Promise<[BigNumber] & { _value: BigNumber }>;

    isActive(overrides?: CallOverrides): Promise<[boolean]>;

    moduleId(overrides?: CallOverrides): Promise<[BigNumber]>;

    novaAddress(overrides?: CallOverrides): Promise<[string]>;

    owner(overrides?: CallOverrides): Promise<[string]>;

    pluginId(overrides?: CallOverrides): Promise<[BigNumber]>;

    pluginRegistry(overrides?: CallOverrides): Promise<[string]>;

    setOffchainVerifierAddress(
      offchainVerifierAddress: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    setPluginId(
      tokenId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    submit(
      taskId: BigNumberish,
      submitionUrl: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    take(
      taskId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    tasks(
      arg0: BigNumberish,
      overrides?: CallOverrides
    ): Promise<
      [BigNumber, string, BigNumber, string, BigNumber, BigNumber] & {
        createdOn: BigNumber;
        creator: string;
        role: BigNumber;
        metadata: string;
        startDate: BigNumber;
        endDate: BigNumber;
      }
    >;
  };

  _offchainVerifierAddress(overrides?: CallOverrides): Promise<string>;

  create(
    role: BigNumberish,
    uri: string,
    startDate: BigNumberish,
    endDate: BigNumberish,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  createBy(
    creator: string,
    role: BigNumberish,
    uri: string,
    startDate: BigNumberish,
    endDate: BigNumberish,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  deployer(overrides?: CallOverrides): Promise<string>;

  editTask(
    taskId: BigNumberish,
    role: BigNumberish,
    uri: string,
    startDate: BigNumberish,
    endDate: BigNumberish,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  finalize(
    taskId: BigNumberish,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  finalizeFor(
    taskId: BigNumberish,
    submitter: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  getById(
    taskId: BigNumberish,
    overrides?: CallOverrides
  ): Promise<TasksModule.TaskStructOutput>;

  getCompletionTime(
    taskId: BigNumberish,
    user: string,
    overrides?: CallOverrides
  ): Promise<BigNumber>;

  getStatusPerSubmitter(
    taskId: BigNumberish,
    submitter: string,
    overrides?: CallOverrides
  ): Promise<number>;

  hasCompletedTheTask(
    user: string,
    taskId: BigNumberish,
    overrides?: CallOverrides
  ): Promise<boolean>;

  idCounter(overrides?: CallOverrides): Promise<BigNumber>;

  isActive(overrides?: CallOverrides): Promise<boolean>;

  moduleId(overrides?: CallOverrides): Promise<BigNumber>;

  novaAddress(overrides?: CallOverrides): Promise<string>;

  owner(overrides?: CallOverrides): Promise<string>;

  pluginId(overrides?: CallOverrides): Promise<BigNumber>;

  pluginRegistry(overrides?: CallOverrides): Promise<string>;

  setOffchainVerifierAddress(
    offchainVerifierAddress: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  setPluginId(
    tokenId: BigNumberish,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  submit(
    taskId: BigNumberish,
    submitionUrl: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  take(
    taskId: BigNumberish,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  tasks(
    arg0: BigNumberish,
    overrides?: CallOverrides
  ): Promise<
    [BigNumber, string, BigNumber, string, BigNumber, BigNumber] & {
      createdOn: BigNumber;
      creator: string;
      role: BigNumber;
      metadata: string;
      startDate: BigNumber;
      endDate: BigNumber;
    }
  >;

  callStatic: {
    _offchainVerifierAddress(overrides?: CallOverrides): Promise<string>;

    create(
      role: BigNumberish,
      uri: string,
      startDate: BigNumberish,
      endDate: BigNumberish,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    createBy(
      creator: string,
      role: BigNumberish,
      uri: string,
      startDate: BigNumberish,
      endDate: BigNumberish,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    deployer(overrides?: CallOverrides): Promise<string>;

    editTask(
      taskId: BigNumberish,
      role: BigNumberish,
      uri: string,
      startDate: BigNumberish,
      endDate: BigNumberish,
      overrides?: CallOverrides
    ): Promise<void>;

    finalize(taskId: BigNumberish, overrides?: CallOverrides): Promise<void>;

    finalizeFor(
      taskId: BigNumberish,
      submitter: string,
      overrides?: CallOverrides
    ): Promise<void>;

    getById(
      taskId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<TasksModule.TaskStructOutput>;

    getCompletionTime(
      taskId: BigNumberish,
      user: string,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    getStatusPerSubmitter(
      taskId: BigNumberish,
      submitter: string,
      overrides?: CallOverrides
    ): Promise<number>;

    hasCompletedTheTask(
      user: string,
      taskId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<boolean>;

    idCounter(overrides?: CallOverrides): Promise<BigNumber>;

    isActive(overrides?: CallOverrides): Promise<boolean>;

    moduleId(overrides?: CallOverrides): Promise<BigNumber>;

    novaAddress(overrides?: CallOverrides): Promise<string>;

    owner(overrides?: CallOverrides): Promise<string>;

    pluginId(overrides?: CallOverrides): Promise<BigNumber>;

    pluginRegistry(overrides?: CallOverrides): Promise<string>;

    setOffchainVerifierAddress(
      offchainVerifierAddress: string,
      overrides?: CallOverrides
    ): Promise<void>;

    setPluginId(
      tokenId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<void>;

    submit(
      taskId: BigNumberish,
      submitionUrl: string,
      overrides?: CallOverrides
    ): Promise<void>;

    take(taskId: BigNumberish, overrides?: CallOverrides): Promise<void>;

    tasks(
      arg0: BigNumberish,
      overrides?: CallOverrides
    ): Promise<
      [BigNumber, string, BigNumber, string, BigNumber, BigNumber] & {
        createdOn: BigNumber;
        creator: string;
        role: BigNumber;
        metadata: string;
        startDate: BigNumber;
        endDate: BigNumber;
      }
    >;
  };

  filters: {
    "TaskCreated(uint256,string)"(
      taskID?: null,
      uri?: null
    ): TaskCreatedEventFilter;
    TaskCreated(taskID?: null, uri?: null): TaskCreatedEventFilter;

    "TaskEdited(uint256,string)"(
      taskID?: null,
      uri?: null
    ): TaskEditedEventFilter;
    TaskEdited(taskID?: null, uri?: null): TaskEditedEventFilter;

    "TaskFinalized(uint256,address)"(
      taskID?: null,
      taker?: null
    ): TaskFinalizedEventFilter;
    TaskFinalized(taskID?: null, taker?: null): TaskFinalizedEventFilter;

    "TaskSubmitted(uint256,uint256)"(
      taskID?: null,
      submissionId?: null
    ): TaskSubmittedEventFilter;
    TaskSubmitted(taskID?: null, submissionId?: null): TaskSubmittedEventFilter;

    "TaskTaken(uint256,address)"(
      taskID?: null,
      taker?: null
    ): TaskTakenEventFilter;
    TaskTaken(taskID?: null, taker?: null): TaskTakenEventFilter;
  };

  estimateGas: {
    _offchainVerifierAddress(overrides?: CallOverrides): Promise<BigNumber>;

    create(
      role: BigNumberish,
      uri: string,
      startDate: BigNumberish,
      endDate: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    createBy(
      creator: string,
      role: BigNumberish,
      uri: string,
      startDate: BigNumberish,
      endDate: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    deployer(overrides?: CallOverrides): Promise<BigNumber>;

    editTask(
      taskId: BigNumberish,
      role: BigNumberish,
      uri: string,
      startDate: BigNumberish,
      endDate: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    finalize(
      taskId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    finalizeFor(
      taskId: BigNumberish,
      submitter: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    getById(
      taskId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    getCompletionTime(
      taskId: BigNumberish,
      user: string,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    getStatusPerSubmitter(
      taskId: BigNumberish,
      submitter: string,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    hasCompletedTheTask(
      user: string,
      taskId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    idCounter(overrides?: CallOverrides): Promise<BigNumber>;

    isActive(overrides?: CallOverrides): Promise<BigNumber>;

    moduleId(overrides?: CallOverrides): Promise<BigNumber>;

    novaAddress(overrides?: CallOverrides): Promise<BigNumber>;

    owner(overrides?: CallOverrides): Promise<BigNumber>;

    pluginId(overrides?: CallOverrides): Promise<BigNumber>;

    pluginRegistry(overrides?: CallOverrides): Promise<BigNumber>;

    setOffchainVerifierAddress(
      offchainVerifierAddress: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    setPluginId(
      tokenId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    submit(
      taskId: BigNumberish,
      submitionUrl: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    take(
      taskId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    tasks(arg0: BigNumberish, overrides?: CallOverrides): Promise<BigNumber>;
  };

  populateTransaction: {
    _offchainVerifierAddress(
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    create(
      role: BigNumberish,
      uri: string,
      startDate: BigNumberish,
      endDate: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    createBy(
      creator: string,
      role: BigNumberish,
      uri: string,
      startDate: BigNumberish,
      endDate: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    deployer(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    editTask(
      taskId: BigNumberish,
      role: BigNumberish,
      uri: string,
      startDate: BigNumberish,
      endDate: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    finalize(
      taskId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    finalizeFor(
      taskId: BigNumberish,
      submitter: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    getById(
      taskId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    getCompletionTime(
      taskId: BigNumberish,
      user: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    getStatusPerSubmitter(
      taskId: BigNumberish,
      submitter: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    hasCompletedTheTask(
      user: string,
      taskId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    idCounter(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    isActive(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    moduleId(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    novaAddress(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    owner(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    pluginId(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    pluginRegistry(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    setOffchainVerifierAddress(
      offchainVerifierAddress: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    setPluginId(
      tokenId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    submit(
      taskId: BigNumberish,
      submitionUrl: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    take(
      taskId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    tasks(
      arg0: BigNumberish,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;
  };
}
