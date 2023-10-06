/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import { Signer, utils, Contract, ContractFactory, Overrides } from "ethers";
import type { Provider, TransactionRequest } from "@ethersproject/providers";
import type {
  ModuleRegistry,
  ModuleRegistryInterface,
} from "../ModuleRegistry";

const _abi = [
  {
    inputs: [
      {
        internalType: "address",
        name: "allList",
        type: "address",
      },
    ],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "uint256",
        name: "id",
        type: "uint256",
      },
    ],
    name: "ModuleDefinitionAdded",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "previousOwner",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "newOwner",
        type: "address",
      },
    ],
    name: "OwnershipTransferred",
    type: "event",
  },
  {
    inputs: [
      {
        internalType: "string",
        name: "metadataURI",
        type: "string",
      },
    ],
    name: "addModuleDefinition",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "getAllModules",
    outputs: [
      {
        components: [
          {
            internalType: "string",
            name: "metadataURI",
            type: "string",
          },
          {
            internalType: "uint256",
            name: "id",
            type: "uint256",
          },
        ],
        internalType: "struct IModuleRegistry.ModuleDefinition[]",
        name: "",
        type: "tuple[]",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "getAllowListAddress",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "moduleId",
        type: "uint256",
      },
    ],
    name: "getModuleById",
    outputs: [
      {
        components: [
          {
            internalType: "string",
            name: "metadataURI",
            type: "string",
          },
          {
            internalType: "uint256",
            name: "id",
            type: "uint256",
          },
        ],
        internalType: "struct IModuleRegistry.ModuleDefinition",
        name: "",
        type: "tuple",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "subject",
        type: "address",
      },
    ],
    name: "isProtocolMaintaier",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    name: "modules",
    outputs: [
      {
        internalType: "string",
        name: "metadataURI",
        type: "string",
      },
      {
        internalType: "uint256",
        name: "id",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "owner",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "renounceOwnership",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "newOwner",
        type: "address",
      },
    ],
    name: "transferOwnership",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "moduleId",
        type: "uint256",
      },
      {
        internalType: "string",
        name: "uri",
        type: "string",
      },
    ],
    name: "updateMetadataURI",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
] as const;

const _bytecode =
  "0x60806040523480156200001157600080fd5b50604051620010db380380620010db833981016040819052620000349162000268565b6200003f3362000218565b6200004a3362000218565b600280546001600160a01b0319166001600160a01b038316178155604080516080810182526004918101918252636e6f6e6560e01b60608201529081526000602082018190526001805480820182559152815191927fb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf6910201908190620000d290826200033f565b50602082015181600101555050600160405180604001604052806040518060800160405280604281526020016200109960429139815260016020918201819052835490810184556000938452922081519192600202019081906200013790826200033f565b506020820151816001015550506001604051806040016040528060405180608001604052806042815260200162001057604291398152600260209182018190528354600181018555600094855291909320825192939190910201908190620001a090826200033f565b506020820151816001015550506001604051806040016040528060405180608001604052806042815260200162001015604291398152600360209182015282546001810184556000938452922081519192600202019081906200020490826200033f565b50602082015181600101555050506200040b565b600080546001600160a01b038381166001600160a01b0319831681178455604051919092169283917f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e09190a35050565b6000602082840312156200027b57600080fd5b81516001600160a01b03811681146200029357600080fd5b9392505050565b634e487b7160e01b600052604160045260246000fd5b600181811c90821680620002c557607f821691505b602082108103620002e657634e487b7160e01b600052602260045260246000fd5b50919050565b601f8211156200033a57600081815260208120601f850160051c81016020861015620003155750805b601f850160051c820191505b81811015620003365782815560010162000321565b5050505b505050565b81516001600160401b038111156200035b576200035b6200029a565b62000373816200036c8454620002b0565b84620002ec565b602080601f831160018114620003ab5760008415620003925750858301515b600019600386901b1c1916600185901b17855562000336565b600085815260208120601f198616915b82811015620003dc57888601518255948401946001909101908401620003bb565b5085821015620003fb5787850151600019600388901b60f8161c191681555b5050505050600190811b01905550565b610bfa806200041b6000396000f3fe608060405234801561001057600080fd5b506004361061009e5760003560e01c80638fe86b3f116100665780638fe86b3f14610139578063adcee6e31461014c578063c13981371461016f578063d36ac27c14610184578063f2fde38b1461019557600080fd5b8063664bff0d146100a3578063715018a6146100c9578063720ed642146100d357806381b2248a146100f35780638da5cb5b14610114575b600080fd5b6100b66100b136600461078f565b6101a8565b6040519081526020015b60405180910390f35b6100d16102a4565b005b6100e66100e13660046107d1565b6102b8565b6040516100c09190610859565b6101066101013660046107d1565b61039c565b6040516100c0929190610873565b6000546001600160a01b03165b6040516001600160a01b0390911681526020016100c0565b6100d1610147366004610895565b610458565b61015f61015a3660046108e1565b610499565b60405190151581526020016100c0565b610177610528565b6040516100c0919061090a565b6002546001600160a01b0316610121565b6100d16101a33660046108e1565b610623565b60006101b261069c565b816101f25760405162461bcd60e51b815260206004820152600b60248201526a696e76616c69642075726960a81b60448201526064015b60405180910390fd5b600180546040805160606020601f8801819004028201810183529181018681529293929091829190889088908190850183828082843760009201829052509385525050506020918201859052835460018101855593815220815191926002020190819061025f9082610a0b565b506020918201516001909101556040518281527f74e253944c73b5e634175a60d5ef4a7af301f3b0148e2dd3527edfd0329108f6910160405180910390a19392505050565b6102ac61069c565b6102b660006106f6565b565b604080518082019091526060815260006020820152600182815481106102e0576102e0610acb565b906000526020600020906002020160405180604001604052908160008201805461030990610982565b80601f016020809104026020016040519081016040528092919081815260200182805461033590610982565b80156103825780601f1061035757610100808354040283529160200191610382565b820191906000526020600020905b81548152906001019060200180831161036557829003601f168201915b505050505081526020016001820154815250509050919050565b600181815481106103ac57600080fd5b90600052602060002090600202016000915090508060000180546103cf90610982565b80601f01602080910402602001604051908101604052809291908181526020018280546103fb90610982565b80156104485780601f1061041d57610100808354040283529160200191610448565b820191906000526020600020905b81548152906001019060200180831161042b57829003601f168201915b5050505050908060010154905082565b61046061069c565b81816001858154811061047557610475610acb565b90600052602060002090600202016000019182610493929190610ae1565b50505050565b6002546000906001600160a01b03166104b457506000919050565b60025460405163974b152160e01b81526001600160a01b0384811660048301529091169063974b152190602401602060405180830381865afa1580156104fe573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906105229190610ba2565b92915050565b60606001805480602002602001604051908101604052809291908181526020016000905b8282101561061a578382906000526020600020906002020160405180604001604052908160008201805461057f90610982565b80601f01602080910402602001604051908101604052809291908181526020018280546105ab90610982565b80156105f85780601f106105cd576101008083540402835291602001916105f8565b820191906000526020600020905b8154815290600101906020018083116105db57829003601f168201915b505050505081526020016001820154815250508152602001906001019061054c565b50505050905090565b61062b61069c565b6001600160a01b0381166106905760405162461bcd60e51b815260206004820152602660248201527f4f776e61626c653a206e6577206f776e657220697320746865207a65726f206160448201526564647265737360d01b60648201526084016101e9565b610699816106f6565b50565b6000546001600160a01b031633146102b65760405162461bcd60e51b815260206004820181905260248201527f4f776e61626c653a2063616c6c6572206973206e6f7420746865206f776e657260448201526064016101e9565b600080546001600160a01b038381166001600160a01b0319831681178455604051919092169283917f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e09190a35050565b60008083601f84011261075857600080fd5b50813567ffffffffffffffff81111561077057600080fd5b60208301915083602082850101111561078857600080fd5b9250929050565b600080602083850312156107a257600080fd5b823567ffffffffffffffff8111156107b957600080fd5b6107c585828601610746565b90969095509350505050565b6000602082840312156107e357600080fd5b5035919050565b6000815180845260005b81811015610810576020818501810151868301820152016107f4565b506000602082860101526020601f19601f83011685010191505092915050565b600081516040845261084560408501826107ea565b602093840151949093019390935250919050565b60208152600061086c6020830184610830565b9392505050565b60408152600061088660408301856107ea565b90508260208301529392505050565b6000806000604084860312156108aa57600080fd5b83359250602084013567ffffffffffffffff8111156108c857600080fd5b6108d486828701610746565b9497909650939450505050565b6000602082840312156108f357600080fd5b81356001600160a01b038116811461086c57600080fd5b6000602080830181845280855180835260408601915060408160051b870101925083870160005b8281101561095f57603f1988860301845261094d858351610830565b94509285019290850190600101610931565b5092979650505050505050565b634e487b7160e01b600052604160045260246000fd5b600181811c9082168061099657607f821691505b6020821081036109b657634e487b7160e01b600052602260045260246000fd5b50919050565b601f821115610a0657600081815260208120601f850160051c810160208610156109e35750805b601f850160051c820191505b81811015610a02578281556001016109ef565b5050505b505050565b815167ffffffffffffffff811115610a2557610a2561096c565b610a3981610a338454610982565b846109bc565b602080601f831160018114610a6e5760008415610a565750858301515b600019600386901b1c1916600185901b178555610a02565b600085815260208120601f198616915b82811015610a9d57888601518255948401946001909101908401610a7e565b5085821015610abb5787850151600019600388901b60f8161c191681555b5050505050600190811b01905550565b634e487b7160e01b600052603260045260246000fd5b67ffffffffffffffff831115610af957610af961096c565b610b0d83610b078354610982565b836109bc565b6000601f841160018114610b415760008515610b295750838201355b600019600387901b1c1916600186901b178355610b9b565b600083815260209020601f19861690835b82811015610b725786850135825560209485019460019092019101610b52565b5086821015610b8f5760001960f88860031b161c19848701351681555b505060018560011b0183555b5050505050565b600060208284031215610bb457600080fd5b8151801515811461086c57600080fdfea264697066735822122004aeb620ef0111e727721d2185c632766408074f22a59d506e2f4a59dc26cb0164736f6c63430008130033697066733a2f2f6261666b726569656737647770687334353534673732366b616c7635657a3232686435356b33626b73657061367272766f6e366766346d75706579697066733a2f2f6261666b7265696878637a366579746d66366c6d356f7971656536376a756a78657075637a6c34326c77326f726c6673773679647335676d343669697066733a2f2f6261666b72656961327369346e68716a6478673534337a377070356b63687678346175776d37676e353477667466613276796b666b6a6334707065";

type ModuleRegistryConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: ModuleRegistryConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class ModuleRegistry__factory extends ContractFactory {
  constructor(...args: ModuleRegistryConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
  }

  override deploy(
    allList: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ModuleRegistry> {
    return super.deploy(allList, overrides || {}) as Promise<ModuleRegistry>;
  }
  override getDeployTransaction(
    allList: string,
    overrides?: Overrides & { from?: string }
  ): TransactionRequest {
    return super.getDeployTransaction(allList, overrides || {});
  }
  override attach(address: string): ModuleRegistry {
    return super.attach(address) as ModuleRegistry;
  }
  override connect(signer: Signer): ModuleRegistry__factory {
    return super.connect(signer) as ModuleRegistry__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): ModuleRegistryInterface {
    return new utils.Interface(_abi) as ModuleRegistryInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): ModuleRegistry {
    return new Contract(address, _abi, signerOrProvider) as ModuleRegistry;
  }
}
