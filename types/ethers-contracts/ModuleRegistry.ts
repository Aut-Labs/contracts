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

export declare namespace IModuleRegistry {
  export type ModuleDefinitionStruct = {
    metadataURI: string;
    id: BigNumberish;
  };

  export type ModuleDefinitionStructOutput = [string, BigNumber] & {
    metadataURI: string;
    id: BigNumber;
  };
}

export interface ModuleRegistryInterface extends utils.Interface {
  functions: {
    "addModuleDefinition(string)": FunctionFragment;
    "getAllModules()": FunctionFragment;
    "getModuleById(uint256)": FunctionFragment;
    "modules(uint256)": FunctionFragment;
    "owner()": FunctionFragment;
    "renounceOwnership()": FunctionFragment;
    "transferOwnership(address)": FunctionFragment;
    "updateMetadataURI(uint256,string)": FunctionFragment;
  };

  getFunction(
    nameOrSignatureOrTopic:
      | "addModuleDefinition"
      | "getAllModules"
      | "getModuleById"
      | "modules"
      | "owner"
      | "renounceOwnership"
      | "transferOwnership"
      | "updateMetadataURI"
  ): FunctionFragment;

  encodeFunctionData(
    functionFragment: "addModuleDefinition",
    values: [string]
  ): string;
  encodeFunctionData(
    functionFragment: "getAllModules",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "getModuleById",
    values: [BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "modules",
    values: [BigNumberish]
  ): string;
  encodeFunctionData(functionFragment: "owner", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "renounceOwnership",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "transferOwnership",
    values: [string]
  ): string;
  encodeFunctionData(
    functionFragment: "updateMetadataURI",
    values: [BigNumberish, string]
  ): string;

  decodeFunctionResult(
    functionFragment: "addModuleDefinition",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getAllModules",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getModuleById",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "modules", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "owner", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "renounceOwnership",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "transferOwnership",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "updateMetadataURI",
    data: BytesLike
  ): Result;

  events: {
    "ModuleDefinitionAdded(uint256)": EventFragment;
    "OwnershipTransferred(address,address)": EventFragment;
  };

  getEvent(nameOrSignatureOrTopic: "ModuleDefinitionAdded"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "OwnershipTransferred"): EventFragment;
}

export interface ModuleDefinitionAddedEventObject {
  id: BigNumber;
}
export type ModuleDefinitionAddedEvent = TypedEvent<
  [BigNumber],
  ModuleDefinitionAddedEventObject
>;

export type ModuleDefinitionAddedEventFilter =
  TypedEventFilter<ModuleDefinitionAddedEvent>;

export interface OwnershipTransferredEventObject {
  previousOwner: string;
  newOwner: string;
}
export type OwnershipTransferredEvent = TypedEvent<
  [string, string],
  OwnershipTransferredEventObject
>;

export type OwnershipTransferredEventFilter =
  TypedEventFilter<OwnershipTransferredEvent>;

export interface ModuleRegistry extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: ModuleRegistryInterface;

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
    addModuleDefinition(
      metadataURI: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    getAllModules(
      overrides?: CallOverrides
    ): Promise<[IModuleRegistry.ModuleDefinitionStructOutput[]]>;

    getModuleById(
      moduleId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<[IModuleRegistry.ModuleDefinitionStructOutput]>;

    modules(
      arg0: BigNumberish,
      overrides?: CallOverrides
    ): Promise<[string, BigNumber] & { metadataURI: string; id: BigNumber }>;

    owner(overrides?: CallOverrides): Promise<[string]>;

    renounceOwnership(
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    transferOwnership(
      newOwner: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    updateMetadataURI(
      moduleId: BigNumberish,
      uri: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;
  };

  addModuleDefinition(
    metadataURI: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  getAllModules(
    overrides?: CallOverrides
  ): Promise<IModuleRegistry.ModuleDefinitionStructOutput[]>;

  getModuleById(
    moduleId: BigNumberish,
    overrides?: CallOverrides
  ): Promise<IModuleRegistry.ModuleDefinitionStructOutput>;

  modules(
    arg0: BigNumberish,
    overrides?: CallOverrides
  ): Promise<[string, BigNumber] & { metadataURI: string; id: BigNumber }>;

  owner(overrides?: CallOverrides): Promise<string>;

  renounceOwnership(
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  transferOwnership(
    newOwner: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  updateMetadataURI(
    moduleId: BigNumberish,
    uri: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  callStatic: {
    addModuleDefinition(
      metadataURI: string,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    getAllModules(
      overrides?: CallOverrides
    ): Promise<IModuleRegistry.ModuleDefinitionStructOutput[]>;

    getModuleById(
      moduleId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<IModuleRegistry.ModuleDefinitionStructOutput>;

    modules(
      arg0: BigNumberish,
      overrides?: CallOverrides
    ): Promise<[string, BigNumber] & { metadataURI: string; id: BigNumber }>;

    owner(overrides?: CallOverrides): Promise<string>;

    renounceOwnership(overrides?: CallOverrides): Promise<void>;

    transferOwnership(
      newOwner: string,
      overrides?: CallOverrides
    ): Promise<void>;

    updateMetadataURI(
      moduleId: BigNumberish,
      uri: string,
      overrides?: CallOverrides
    ): Promise<void>;
  };

  filters: {
    "ModuleDefinitionAdded(uint256)"(
      id?: null
    ): ModuleDefinitionAddedEventFilter;
    ModuleDefinitionAdded(id?: null): ModuleDefinitionAddedEventFilter;

    "OwnershipTransferred(address,address)"(
      previousOwner?: string | null,
      newOwner?: string | null
    ): OwnershipTransferredEventFilter;
    OwnershipTransferred(
      previousOwner?: string | null,
      newOwner?: string | null
    ): OwnershipTransferredEventFilter;
  };

  estimateGas: {
    addModuleDefinition(
      metadataURI: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    getAllModules(overrides?: CallOverrides): Promise<BigNumber>;

    getModuleById(
      moduleId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    modules(arg0: BigNumberish, overrides?: CallOverrides): Promise<BigNumber>;

    owner(overrides?: CallOverrides): Promise<BigNumber>;

    renounceOwnership(
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    transferOwnership(
      newOwner: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    updateMetadataURI(
      moduleId: BigNumberish,
      uri: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;
  };

  populateTransaction: {
    addModuleDefinition(
      metadataURI: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    getAllModules(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    getModuleById(
      moduleId: BigNumberish,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    modules(
      arg0: BigNumberish,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    owner(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    renounceOwnership(
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    transferOwnership(
      newOwner: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    updateMetadataURI(
      moduleId: BigNumberish,
      uri: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;
  };
}
