/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import { Signer, utils, Contract, ContractFactory, Overrides } from "ethers";
import type { Provider, TransactionRequest } from "@ethersproject/providers";
import type {
  SocialQuizPlugin,
  SocialQuizPluginInterface,
} from "../SocialQuizPlugin";

const _abi = [
  {
    inputs: [
      {
        internalType: "address",
        name: "nova_",
        type: "address",
      },
    ],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    inputs: [],
    name: "AuthorityExpected",
    type: "error",
  },
  {
    inputs: [],
    name: "FunctionNotImplemented",
    type: "error",
  },
  {
    inputs: [],
    name: "LenMismatch",
    type: "error",
  },
  {
    inputs: [],
    name: "NotAdmin",
    type: "error",
  },
  {
    inputs: [],
    name: "NotBot",
    type: "error",
  },
  {
    inputs: [],
    name: "OverMaxPoints",
    type: "error",
  },
  {
    inputs: [],
    name: "Unauthorised",
    type: "error",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "nova",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "repAlgo",
        type: "address",
      },
    ],
    name: "LocalRepALogChangedFor",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "uint256",
        name: "EventIndex",
        type: "uint256",
      },
    ],
    name: "SocialEventRegistered",
    type: "event",
  },
  {
    inputs: [
      {
        internalType: "address[]",
        name: "participants",
        type: "address[]",
      },
      {
        internalType: "uint16[]",
        name: "participationPoints",
        type: "uint16[]",
      },
      {
        internalType: "uint16",
        name: "maxPossiblePointsPerUser",
        type: "uint16",
      },
      {
        internalType: "string",
        name: "categoryOrDescription",
        type: "string",
      },
    ],
    name: "applyEventConsequences",
    outputs: [
      {
        internalType: "uint256",
        name: "indexId",
        type: "uint256",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "NewLocalRepAlgo_",
        type: "address",
      },
    ],
    name: "changeInUseLocalRep",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "currentReputationAddr",
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
    name: "deployer",
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
    name: "getAllBotInteractions",
    outputs: [
      {
        components: [
          {
            internalType: "address[]",
            name: "participants",
            type: "address[]",
          },
          {
            internalType: "uint16[]",
            name: "distributedPoints",
            type: "uint16[]",
          },
          {
            internalType: "string",
            name: "categoryOrDescription",
            type: "string",
          },
          {
            internalType: "uint256",
            name: "when",
            type: "uint256",
          },
          {
            internalType: "uint16",
            name: "maxPointsPerUser",
            type: "uint16",
          },
        ],
        internalType: "struct SocialBotPlugin.SocialBotEvent[]",
        name: "",
        type: "tuple[]",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "indexAtPeriod",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "isActive",
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
    inputs: [],
    name: "lastReputationAddr",
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
    name: "moduleId",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "novaAddress",
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
    name: "pluginId",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "pluginRegistry",
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
        name: "tokenId",
        type: "uint256",
      },
    ],
    name: "setPluginId",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
] as const;

const _bytecode =
  "0x60806040523480156200001157600080fd5b50604051620015b5380380620015b5833981016040819052620000349162000382565b808081600081600160006101000a8154816001600160a01b0302191690836001600160a01b03160217905550816001600160a01b03166341dcea916040518163ffffffff1660e01b8152600401602060405180830381865afa1580156200009f573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190620000c5919062000382565b600480546001600160a01b0392831661010002610100600160a81b0319909116178155600080546001600160a01b03191633178155600393909355604080516341dcea9160e01b8152905192861694506341dcea919381830193602093909283900301908290875af115801562000140573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019062000166919062000382565b6001600160a01b031663f0b7832a6040518163ffffffff1660e01b8152600401602060405180830381865afa158015620001a4573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190620001ca919062000382565b600580546001600160a01b0319166001600160a01b0392831690811790915560405163189acdbd60e31b815291831660048301529063c4d66de890602401600060405180830381600087803b1580156200022357600080fd5b505af115801562000238573d6000803e3d6000fd5b5050505050806001600160a01b03166341dcea916040518163ffffffff1660e01b81526004016020604051808303816000875af11580156200027e573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190620002a4919062000382565b6001600160a01b031663f0b7832a6040518163ffffffff1660e01b8152600401602060405180830381865afa158015620002e2573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019062000308919062000382565b600580546001600160a01b0319166001600160a01b0392831690811790915560405163189acdbd60e31b815291831660048301529063c4d66de890602401600060405180830381600087803b1580156200036157600080fd5b505af115801562000376573d6000803e3d6000fd5b505050505050620003b4565b6000602082840312156200039557600080fd5b81516001600160a01b0381168114620003ad57600080fd5b9392505050565b6111f180620003c46000396000f3fe608060405234801561001057600080fd5b50600436106100ea5760003560e01c806386d113c01161008c578063a1308f2711610066578063a1308f27146101d0578063ab440d65146101d9578063bc763530146101ec578063d5f39488146101f557600080fd5b806386d113c0146101a657806389f12ed9146101b75780638da5cb5b146101c857600080fd5b806341dcea91116100c857806341dcea911461013d5780634a6360241461016d5780634acdb309146101825780634b749e9b1461019557600080fd5b806302a4dca0146100ef57806322f3e2d4146101045780632fe7e44114610126575b600080fd5b6101026100fd366004610b26565b610206565b005b6004546101119060ff1681565b60405190151581526020015b60405180910390f35b61012f60025481565b60405190815260200161011d565b6004546101559061010090046001600160a01b031681565b6040516001600160a01b03909116815260200161011d565b610175610265565b60405161011d9190610bc4565b61012f610190366004610e2b565b610456565b6005546001600160a01b0316610155565b6007546001600160a01b0316610155565b6001546001600160a01b0316610155565b61015561089a565b61012f60035481565b6101026101e7366004610f22565b610915565b61012f60085481565b6000546001600160a01b0316610155565b60045461010090046001600160a01b031633146102605760405162461bcd60e51b81526020600482015260146024820152734f6e6c7920706c7567696e20726567697374727960601b604482015260640160405180910390fd5b600255565b60606009805480602002602001604051908101604052809291908181526020016000905b8282101561044d57838290600052602060002090600502016040518060a00160405290816000820180548060200260200160405190810160405280929190818152602001828054801561030557602002820191906000526020600020905b81546001600160a01b031681526001909101906020018083116102e7575b505050505081526020016001820180548060200260200160405190810160405280929190818152602001828054801561038557602002820191906000526020600020906000905b82829054906101000a900461ffff1661ffff168152602001906002019060208260010104928301926001038202915080841161034c5790505b5050505050815260200160028201805461039e90610f46565b80601f01602080910402602001604051908101604052809291908181526020018280546103ca90610f46565b80156104175780601f106103ec57610100808354040283529160200191610417565b820191906000526020600020905b8154815290600101906020018083116103fa57829003601f168201915b5050509183525050600382015460208083019190915260049092015461ffff166040909101529082526001929092019101610289565b50505050905090565b600061046a6001546001600160a01b031690565b604051630935e01b60e21b81523360048201526001600160a01b0391909116906324d7806c906024016020604051808303816000875af11580156104b2573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906104d69190610f80565b6104f357604051637bfa4b9f60e01b815260040160405180910390fd5b835185511461051557604051638b140a8160e01b815260040160405180910390fd5b8451811015610635576103e884828151811061053357610533610fa2565b602002602001015161ffff16111561055e57604051636172d1a360e11b815260040160405180910390fd5b60055484516001600160a01b0390911690633ad3b0419086908490811061058757610587610fa2565b60200260200101516040516020016105b2919060f09190911b6001600160f01b031916815260020190565b6040516020818303038152906040528784815181106105d3576105d3610fa2565b60200260200101516040518363ffffffff1660e01b81526004016105f8929190610fb8565b600060405180830381600087803b15801561061257600080fd5b505af1158015610626573d6000803e3d6000fd5b50505050806001019050610515565b61066b6040518060a0016040528060608152602001606081526020016060815260200160008152602001600061ffff1681525090565b85815260208082018690526040820184905242606083015261ffff8516608083015286516009805460018101825560009190915283518051929550849360059092027f6e1540171b6c0c960b71a7020d9f60077f6af931a8bbf590da0223dacf75c7af01926106dd9284920190610a0c565b5060208281015180516106f69260018501920190610a71565b506040820151600282019061070b9082611031565b50606082015160038201556080909101516004909101805461ffff191661ffff9092169190911790556040805160018082528183019092526000916020808301908036833750506040805160018082528183019092529293506000929150602082015b606081526020019060019003908161076e5790505060408051602081018790523091810191909152909150606001604051602081830303815290604052816000815181106107be576107be610fa2565b602002602001018190525085826000815181106107dd576107dd610fa2565b61ffff90921660209283029190910190910152600554604051631b799aa760e11b81526001600160a01b03909116906336f3354e90610824903090859087906004016110f1565b600060405180830381600087803b15801561083e57600080fd5b505af1158015610852573d6000803e3d6000fd5b505050507f3571ec98a213372bdd3f1c7ae5f37ac6d39c03aba40b50bcac0e3b5e2293560c8460405161088791815260200190565b60405180910390a1505050949350505050565b6004805460405163235883e360e01b815230928101929092526000916101009091046001600160a01b03169063235883e390602401602060405180830381865afa1580156108ec573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610910919061119e565b905090565b6006546001600160a01b0316336001600160a01b03161461094957604051630e8cc36b60e21b815260040160405180910390fd5b600580546001600160a01b0319166001600160a01b038316179055604080516389f12ed960e01b815290517f3ef34c117b493311a9ea61dff2d101d6bdc33062c190cb30ffbb908b09a2b4949130916389f12ed9916004808201926020929091908290030181865afa1580156109c3573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906109e7919061119e565b604080516001600160a01b03928316815291841660208301520160405180910390a150565b828054828255906000526020600020908101928215610a61579160200282015b82811115610a6157825182546001600160a01b0319166001600160a01b03909116178255602090920191600190910190610a2c565b50610a6d929150610b11565b5090565b82805482825590600052602060002090600f01601090048101928215610a615791602002820160005b83821115610ada57835183826101000a81548161ffff021916908361ffff1602179055509260200192600201602081600101049283019260010302610a9a565b8015610b085782816101000a81549061ffff0219169055600201602081600101049283019260010302610ada565b5050610a6d9291505b5b80821115610a6d5760008155600101610b12565b600060208284031215610b3857600080fd5b5035919050565b600081518084526020808501945080840160005b83811015610b7357815161ffff1687529582019590820190600101610b53565b509495945050505050565b6000815180845260005b81811015610ba457602081850181015186830182015201610b88565b506000602082860101526020601f19601f83011685010191505092915050565b60006020808301818452808551808352604092508286019150828160051b8701018488016000805b84811015610ca057898403603f190186528251805160a0808752815190870181905260c08701918b019085905b80821015610c425782516001600160a01b03168452928c0192918c019160019190910190610c19565b505050898201518682038b880152610c5a8282610b3f565b915050888201518682038a880152610c728282610b7e565b6060848101519089015260809384015161ffff16939097019290925250509487019491870191600101610bec565b50919998505050505050505050565b634e487b7160e01b600052604160045260246000fd5b604051601f8201601f1916810167ffffffffffffffff81118282101715610cee57610cee610caf565b604052919050565b600067ffffffffffffffff821115610d1057610d10610caf565b5060051b60200190565b6001600160a01b0381168114610d2f57600080fd5b50565b803561ffff81168114610d4457600080fd5b919050565b600082601f830112610d5a57600080fd5b81356020610d6f610d6a83610cf6565b610cc5565b82815260059290921b84018101918181019086841115610d8e57600080fd5b8286015b84811015610db057610da381610d32565b8352918301918301610d92565b509695505050505050565b600082601f830112610dcc57600080fd5b813567ffffffffffffffff811115610de657610de6610caf565b610df9601f8201601f1916602001610cc5565b818152846020838601011115610e0e57600080fd5b816020850160208301376000918101602001919091529392505050565b60008060008060808587031215610e4157600080fd5b843567ffffffffffffffff80821115610e5957600080fd5b818701915087601f830112610e6d57600080fd5b81356020610e7d610d6a83610cf6565b82815260059290921b8401810191818101908b841115610e9c57600080fd5b948201945b83861015610ec3578535610eb481610d1a565b82529482019490820190610ea1565b98505088013592505080821115610ed957600080fd5b610ee588838901610d49565b9450610ef360408801610d32565b93506060870135915080821115610f0957600080fd5b50610f1687828801610dbb565b91505092959194509250565b600060208284031215610f3457600080fd5b8135610f3f81610d1a565b9392505050565b600181811c90821680610f5a57607f821691505b602082108103610f7a57634e487b7160e01b600052602260045260246000fd5b50919050565b600060208284031215610f9257600080fd5b81518015158114610f3f57600080fd5b634e487b7160e01b600052603260045260246000fd5b604081526000610fcb6040830185610b7e565b905060018060a01b03831660208301529392505050565b601f82111561102c57600081815260208120601f850160051c810160208610156110095750805b601f850160051c820191505b8181101561102857828155600101611015565b5050505b505050565b815167ffffffffffffffff81111561104b5761104b610caf565b61105f816110598454610f46565b84610fe2565b602080601f831160018114611094576000841561107c5750858301515b600019600386901b1c1916600185901b178555611028565b600085815260208120601f198616915b828110156110c3578886015182559484019460019091019084016110a4565b50858210156110e15787850151600019600388901b60f8161c191681555b5050505050600190811b01905550565b60006060820160018060a01b0386168352602060608185015281865180845260808601915060808160051b870101935082880160005b8281101561115557607f19888703018452611143868351610b7e565b95509284019290840190600101611127565b50505050838203604085015284518083528186019282019060005b8181101561119057845161ffff1683529383019391830191600101611170565b509098975050505050505050565b6000602082840312156111b057600080fd5b8151610f3f81610d1a56fea2646970667358221220159d31c8f6eaa6e0707fe61b5b2b64bf5eead5d5e347764691b46e296595403c64736f6c63430008130033";

type SocialQuizPluginConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: SocialQuizPluginConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class SocialQuizPlugin__factory extends ContractFactory {
  constructor(...args: SocialQuizPluginConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
  }

  override deploy(
    nova_: string,
    overrides?: Overrides & { from?: string }
  ): Promise<SocialQuizPlugin> {
    return super.deploy(nova_, overrides || {}) as Promise<SocialQuizPlugin>;
  }
  override getDeployTransaction(
    nova_: string,
    overrides?: Overrides & { from?: string }
  ): TransactionRequest {
    return super.getDeployTransaction(nova_, overrides || {});
  }
  override attach(address: string): SocialQuizPlugin {
    return super.attach(address) as SocialQuizPlugin;
  }
  override connect(signer: Signer): SocialQuizPlugin__factory {
    return super.connect(signer) as SocialQuizPlugin__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): SocialQuizPluginInterface {
    return new utils.Interface(_abi) as SocialQuizPluginInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): SocialQuizPlugin {
    return new Contract(address, _abi, signerOrProvider) as SocialQuizPlugin;
  }
}