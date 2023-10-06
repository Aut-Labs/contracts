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

export interface OpenTaskWithRepInterface extends utils.Interface {
  functions: {
    "changeInUseLocalRep(address)": FunctionFragment;
    "create(uint256,string,uint256,uint256)": FunctionFragment;
    "createBy(address,uint256,string,uint256,uint256)": FunctionFragment;
    "currentReputationAddr()": FunctionFragment;
    "daoMembersOnly()": FunctionFragment;
    "deployer()": FunctionFragment;
    "editTask(uint256,uint256,string,uint256,uint256)": FunctionFragment;
    "finalize(uint256)": FunctionFragment;
    "finalizeFor(uint256,address)": FunctionFragment;
    "getById(uint256)": FunctionFragment;
    "getCompletionTime(uint256,address)": FunctionFragment;
    "getStatusPerSubmitter(uint256,address)": FunctionFragment;
    "getSubmissionIdPerTaskAndUser(uint256,address)": FunctionFragment;
    "getSubmissionIdsPerTask(uint256)": FunctionFragment;
    "hasCompletedTheTask(address,uint256)": FunctionFragment;
    "idCounter()": FunctionFragment;
    "isActive()": FunctionFragment;
    "lastReputationAddr()": FunctionFragment;
    "moduleId()": FunctionFragment;
    "novaAddress()": FunctionFragment;
    "owner()": FunctionFragment;
    "pluginId()": FunctionFragment;
    "pluginRegistry()": FunctionFragment;
    "setPluginId(uint256)": FunctionFragment;
    "submissionIds()": FunctionFragment;
    "submissions(uint256)": FunctionFragment;
    "submit(uint256,string)": FunctionFragment;
    "take(uint256)": FunctionFragment;
    "taskSubmissions(uint256,uint256)": FunctionFragment;
    "tasks(uint256)": FunctionFragment;
  };

  getFunction(
    nameOrSignatureOrTopic:
      | "changeInUseLocalRep"
      | "create"
      | "createBy"
      | "currentReputationAddr"
      | "daoMembersOnly"
      | "deployer"
      | "editTask"
      | "finalize"
      | "finalizeFor"
      | "getById"
      | "getCompletionTime"
      | "getStatusPerSubmitter"
      | "getSubmissionIdPerTaskAndUser"
      | "getSubmissionIdsPerTask"
      | "hasCompletedTheTask"
      | "idCounter"
      | "isActive"
      | "lastReputationAddr"
      | "moduleId"
      | "novaAddress"
      | "owner"
      | "pluginId"
      | "pluginRegistry"
      | "setPluginId"
      | "submissionIds"
      | "submissions"
      | "submit"
      | "take"
      | "taskSubmissions"
      | "tasks"
  ): FunctionFragment;

  encodeFunctionData(
    functionFragment: "changeInUseLocalRep",
    values: [string]
  ): string;
  encodeFunctionData(
    functionFragment: "create",
    values: [BigNumberish, string, BigNumberish, BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "createBy",
    values: [string, BigNumberish, string, BigNumberish, BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "currentReputationAddr",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "daoMembersOnly",
    values?: undefined
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
    functionFragment: "getSubmissionIdPerTaskAndUser",
    values: [BigNumberish, string]
  ): string;
  encodeFunctionData(
    functionFragment: "getSubmissionIdsPerTask",
    values: [BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "hasCompletedTheTask",
    values: [string, BigNumberish]
  ): string;
  encodeFunctionData(functionFragment: "idCounter", values?: undefined): string;
  encodeFunctionData(functionFragment: "isActive", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "lastReputationAddr",
    values?: undefined
  ): string;
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
    functionFragment: "setPluginId",
    values: [BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "submissionIds",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "submissions",
    values: [BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "submit",
    values: [BigNumberish, string]
  ): string;
  encodeFunctionData(functionFragment: "take", values: [BigNumberish]): string;
  encodeFunctionData(
    functionFragment: "taskSubmissions",
    values: [BigNumberish, BigNumberish]
  ): string;
  encodeFunctionData(functionFragment: "tasks", values: [BigNumberish]): string;

  decodeFunctionResult(
    functionFragment: "changeInUseLocalRep",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "create", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "createBy", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "currentReputationAddr",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "daoMembersOnly",
    data: BytesLike
  ): Result;
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
    functionFragment: "getSubmissionIdPerTaskAndUser",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getSubmissionIdsPerTask",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "hasCompletedTheTask",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "idCounter", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "isActive", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "lastReputationAddr",
    data: BytesLike
  ): Result;
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
    functionFragment: "setPluginId",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "submissionIds",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "submissions",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "submit", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "take", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "taskSubmissions",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "tasks", data: BytesLike): Result;

  events: {
    "LocalRepALogChangedFor(address,address)": EventFragment;
    "TaskCreated(uint256,string)": EventFragment;
    "TaskEdited(uint256,string)": EventFragment;
    "TaskFinalized(uint256,address)": EventFragment;
    "TaskSubmitted(uint256,uint256)": EventFragment;
    "TaskTaken(uint256,address)": EventFragment;
  };

  getEvent(nameOrSignatureOrTopic: "LocalRepALogChangedFor"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "TaskCreated"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "TaskEdited"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "TaskFinalized"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "TaskSubmitted"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "TaskTaken"): EventFragment;
}

export interface LocalRepALogChangedForEventObject {
  nova: string;
  repAlgo: string;
}
export type LocalRepALogChangedForEvent = TypedEvent<
  [string, string],
  LocalRepALogChangedForEventObject
>;

export type LocalRepALogChangedForEventFilter =
  TypedEventFilter<LocalRepALogChangedForEvent>;

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

export interface OpenTaskWithRep extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: OpenTaskWithRepInterface;

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
    changeInUseLocalRep(
      NewLocalRepAlgo_: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

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

    currentReputationAddr(overrides?: CallOverrides): Promise<[string]>;

    daoMembersOnly(overrides?: CallOverrides): Promise<[boolean]>;

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

    getSubmissionIdPerTaskAndUser(
      taskId: BigNumberish,
      submitter: string,
      overrides?: CallOverrides
    ): Promise<[BigNumber]>;

    getSubmissionIdsPerTask(
      taskId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<[BigNumber[]]>;

    hasCompletedTheTask(
      user: string,
      taskId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<[boolean]>;

    idCounter(
      overrides?: CallOverrides
    ): Promise<[BigNumber] & { _value: BigNumber }>;

    isActive(overrides?: CallOverrides): Promise<[boolean]>;

    lastReputationAddr(overrides?: CallOverrides): Promise<[string]>;

    moduleId(overrides?: CallOverrides): Promise<[BigNumber]>;

    novaAddress(overrides?: CallOverrides): Promise<[string]>;

    owner(overrides?: CallOverrides): Promise<[string]>;

    pluginId(overrides?: CallOverrides): Promise<[BigNumber]>;

    pluginRegistry(overrides?: CallOverrides): Promise<[string]>;

    setPluginId(
      tokenId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    submissionIds(
      overrides?: CallOverrides
    ): Promise<[BigNumber] & { _value: BigNumber }>;

    submissions(
      arg0: BigNumberish,
      overrides?: CallOverrides
    ): Promise<
      [string, string, BigNumber, number] & {
        submitter: string;
        submissionMetadata: string;
        completionTime: BigNumber;
        status: number;
      }
    >;

    submit(
      taskId: BigNumberish,
      submitionUrl: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    take(
      taskId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    taskSubmissions(
      arg0: BigNumberish,
      arg1: BigNumberish,
      overrides?: CallOverrides
    ): Promise<[BigNumber]>;

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

  changeInUseLocalRep(
    NewLocalRepAlgo_: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

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

  currentReputationAddr(overrides?: CallOverrides): Promise<string>;

  daoMembersOnly(overrides?: CallOverrides): Promise<boolean>;

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

  getSubmissionIdPerTaskAndUser(
    taskId: BigNumberish,
    submitter: string,
    overrides?: CallOverrides
  ): Promise<BigNumber>;

  getSubmissionIdsPerTask(
    taskId: BigNumberish,
    overrides?: CallOverrides
  ): Promise<BigNumber[]>;

  hasCompletedTheTask(
    user: string,
    taskId: BigNumberish,
    overrides?: CallOverrides
  ): Promise<boolean>;

  idCounter(overrides?: CallOverrides): Promise<BigNumber>;

  isActive(overrides?: CallOverrides): Promise<boolean>;

  lastReputationAddr(overrides?: CallOverrides): Promise<string>;

  moduleId(overrides?: CallOverrides): Promise<BigNumber>;

  novaAddress(overrides?: CallOverrides): Promise<string>;

  owner(overrides?: CallOverrides): Promise<string>;

  pluginId(overrides?: CallOverrides): Promise<BigNumber>;

  pluginRegistry(overrides?: CallOverrides): Promise<string>;

  setPluginId(
    tokenId: BigNumberish,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  submissionIds(overrides?: CallOverrides): Promise<BigNumber>;

  submissions(
    arg0: BigNumberish,
    overrides?: CallOverrides
  ): Promise<
    [string, string, BigNumber, number] & {
      submitter: string;
      submissionMetadata: string;
      completionTime: BigNumber;
      status: number;
    }
  >;

  submit(
    taskId: BigNumberish,
    submitionUrl: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  take(
    taskId: BigNumberish,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  taskSubmissions(
    arg0: BigNumberish,
    arg1: BigNumberish,
    overrides?: CallOverrides
  ): Promise<BigNumber>;

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
    changeInUseLocalRep(
      NewLocalRepAlgo_: string,
      overrides?: CallOverrides
    ): Promise<void>;

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

    currentReputationAddr(overrides?: CallOverrides): Promise<string>;

    daoMembersOnly(overrides?: CallOverrides): Promise<boolean>;

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

    getSubmissionIdPerTaskAndUser(
      taskId: BigNumberish,
      submitter: string,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    getSubmissionIdsPerTask(
      taskId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<BigNumber[]>;

    hasCompletedTheTask(
      user: string,
      taskId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<boolean>;

    idCounter(overrides?: CallOverrides): Promise<BigNumber>;

    isActive(overrides?: CallOverrides): Promise<boolean>;

    lastReputationAddr(overrides?: CallOverrides): Promise<string>;

    moduleId(overrides?: CallOverrides): Promise<BigNumber>;

    novaAddress(overrides?: CallOverrides): Promise<string>;

    owner(overrides?: CallOverrides): Promise<string>;

    pluginId(overrides?: CallOverrides): Promise<BigNumber>;

    pluginRegistry(overrides?: CallOverrides): Promise<string>;

    setPluginId(
      tokenId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<void>;

    submissionIds(overrides?: CallOverrides): Promise<BigNumber>;

    submissions(
      arg0: BigNumberish,
      overrides?: CallOverrides
    ): Promise<
      [string, string, BigNumber, number] & {
        submitter: string;
        submissionMetadata: string;
        completionTime: BigNumber;
        status: number;
      }
    >;

    submit(
      taskId: BigNumberish,
      submitionUrl: string,
      overrides?: CallOverrides
    ): Promise<void>;

    take(taskId: BigNumberish, overrides?: CallOverrides): Promise<void>;

    taskSubmissions(
      arg0: BigNumberish,
      arg1: BigNumberish,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

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
    "LocalRepALogChangedFor(address,address)"(
      nova?: null,
      repAlgo?: null
    ): LocalRepALogChangedForEventFilter;
    LocalRepALogChangedFor(
      nova?: null,
      repAlgo?: null
    ): LocalRepALogChangedForEventFilter;

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
    changeInUseLocalRep(
      NewLocalRepAlgo_: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

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

    currentReputationAddr(overrides?: CallOverrides): Promise<BigNumber>;

    daoMembersOnly(overrides?: CallOverrides): Promise<BigNumber>;

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

    getSubmissionIdPerTaskAndUser(
      taskId: BigNumberish,
      submitter: string,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    getSubmissionIdsPerTask(
      taskId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    hasCompletedTheTask(
      user: string,
      taskId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    idCounter(overrides?: CallOverrides): Promise<BigNumber>;

    isActive(overrides?: CallOverrides): Promise<BigNumber>;

    lastReputationAddr(overrides?: CallOverrides): Promise<BigNumber>;

    moduleId(overrides?: CallOverrides): Promise<BigNumber>;

    novaAddress(overrides?: CallOverrides): Promise<BigNumber>;

    owner(overrides?: CallOverrides): Promise<BigNumber>;

    pluginId(overrides?: CallOverrides): Promise<BigNumber>;

    pluginRegistry(overrides?: CallOverrides): Promise<BigNumber>;

    setPluginId(
      tokenId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    submissionIds(overrides?: CallOverrides): Promise<BigNumber>;

    submissions(
      arg0: BigNumberish,
      overrides?: CallOverrides
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

    taskSubmissions(
      arg0: BigNumberish,
      arg1: BigNumberish,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    tasks(arg0: BigNumberish, overrides?: CallOverrides): Promise<BigNumber>;
  };

  populateTransaction: {
    changeInUseLocalRep(
      NewLocalRepAlgo_: string,
      overrides?: Overrides & { from?: string }
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

    currentReputationAddr(
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    daoMembersOnly(overrides?: CallOverrides): Promise<PopulatedTransaction>;

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

    getSubmissionIdPerTaskAndUser(
      taskId: BigNumberish,
      submitter: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    getSubmissionIdsPerTask(
      taskId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    hasCompletedTheTask(
      user: string,
      taskId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    idCounter(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    isActive(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    lastReputationAddr(
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    moduleId(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    novaAddress(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    owner(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    pluginId(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    pluginRegistry(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    setPluginId(
      tokenId: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    submissionIds(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    submissions(
      arg0: BigNumberish,
      overrides?: CallOverrides
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

    taskSubmissions(
      arg0: BigNumberish,
      arg1: BigNumberish,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    tasks(
      arg0: BigNumberish,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;
  };
}