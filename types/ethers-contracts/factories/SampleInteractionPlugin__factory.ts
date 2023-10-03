/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import { Signer, utils, Contract, ContractFactory, Overrides } from "ethers";
import type { Provider, TransactionRequest } from "@ethersproject/providers";
import type {
  SampleInteractionPlugin,
  SampleInteractionPluginInterface,
} from "../SampleInteractionPlugin";

const _abi = [
  {
    inputs: [
      {
        internalType: "address",
        name: "dao_",
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
    inputs: [
      {
        internalType: "string",
        name: "x",
        type: "string",
      },
    ],
    name: "incrementNumber",
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
    name: "incrementNumberPlusOne",
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
    name: "number",
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
  "0x608060405234801561001057600080fd5b5060405161092638038061092683398101604081905261002f91610238565b8081600081600160006101000a8154816001600160a01b0302191690836001600160a01b03160217905550816001600160a01b03166341dcea916040518163ffffffff1660e01b8152600401602060405180830381865afa158015610098573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906100bc9190610238565b600480546001600160a01b0392831661010002610100600160a81b0319909116178155600080546001600160a01b03191633178155600393909355604080516341dcea9160e01b8152905192861694506341dcea919381830193602093909283900301908290875af1158015610136573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061015a9190610238565b6001600160a01b031663f0b7832a6040518163ffffffff1660e01b8152600401602060405180830381865afa158015610197573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906101bb9190610238565b600580546001600160a01b0319166001600160a01b0392831690811790915560405163189acdbd60e31b815291831660048301529063c4d66de890602401600060405180830381600087803b15801561021357600080fd5b505af1158015610227573d6000803e3d6000fd5b505060016008555061026892505050565b60006020828403121561024a57600080fd5b81516001600160a01b038116811461026157600080fd5b9392505050565b6106af806102776000396000f3fe608060405234801561001057600080fd5b50600436106100ea5760003560e01c806386d113c01161008c578063a1308f2711610066578063a1308f27146101b9578063a3c9eb43146101c2578063ab440d65146101d5578063d5f39488146101e857600080fd5b806386d113c01461018f57806389f12ed9146101a05780638da5cb5b146101b157600080fd5b806341dcea91116100c857806341dcea911461013d5780634b749e9b1461016d57806366bea03e1461017e5780638381f58a1461018657600080fd5b806302a4dca0146100ef57806322f3e2d4146101045780632fe7e44114610126575b600080fd5b6101026100fd3660046104d8565b6101f9565b005b6004546101119060ff1681565b60405190151581526020015b60405180910390f35b61012f60025481565b60405190815260200161011d565b6004546101559061010090046001600160a01b031681565b6040516001600160a01b03909116815260200161011d565b6005546001600160a01b0316610155565b61012f610258565b61012f60085481565b6007546001600160a01b0316610155565b6001546001600160a01b0316610155565b6101556102de565b61012f60035481565b61012f6101d0366004610507565b610359565b6101026101e33660046105d0565b6103e1565b6000546001600160a01b0316610155565b60045461010090046001600160a01b031633146102535760405162461bcd60e51b81526020600482015260146024820152734f6e6c7920706c7567696e20726567697374727960601b604482015260640160405180910390fd5b600255565b6000600854600161026991906105f4565b600881905590506005546001600160a01b0316633ad3b04160003661028b3390565b6040518463ffffffff1660e01b81526004016102a99392919061061b565b600060405180830381600087803b1580156102c357600080fd5b505af11580156102d7573d6000803e3d6000fd5b5050505090565b6004805460405163235883e360e01b815230928101929092526000916101009091046001600160a01b03169063235883e390602401602060405180830381865afa158015610330573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610354919061065c565b905090565b6000600854600161036a91906105f4565b600881905590506005546001600160a01b0316633ad3b04160003661038c3390565b6040518463ffffffff1660e01b81526004016103aa9392919061061b565b600060405180830381600087803b1580156103c457600080fd5b505af11580156103d8573d6000803e3d6000fd5b50505050919050565b6006546001600160a01b0316336001600160a01b03161461041557604051630e8cc36b60e21b815260040160405180910390fd5b600580546001600160a01b0319166001600160a01b038316179055604080516389f12ed960e01b815290517f3ef34c117b493311a9ea61dff2d101d6bdc33062c190cb30ffbb908b09a2b4949130916389f12ed9916004808201926020929091908290030181865afa15801561048f573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906104b3919061065c565b604080516001600160a01b03928316815291841660208301520160405180910390a150565b6000602082840312156104ea57600080fd5b5035919050565b634e487b7160e01b600052604160045260246000fd5b60006020828403121561051957600080fd5b813567ffffffffffffffff8082111561053157600080fd5b818401915084601f83011261054557600080fd5b813581811115610557576105576104f1565b604051601f8201601f19908116603f0116810190838211818310171561057f5761057f6104f1565b8160405282815287602084870101111561059857600080fd5b826020860160208301376000928101602001929092525095945050505050565b6001600160a01b03811681146105cd57600080fd5b50565b6000602082840312156105e257600080fd5b81356105ed816105b8565b9392505050565b8082018082111561061557634e487b7160e01b600052601160045260246000fd5b92915050565b6040815282604082015282846060830137600060608483018101919091526001600160a01b03929092166020820152601f909201601f191690910101919050565b60006020828403121561066e57600080fd5b81516105ed816105b856fea2646970667358221220522cdfcfa0a93d14150c74828977d5c384f86573942f5a3d3e0c2066b7bcb79764736f6c63430008130033";

type SampleInteractionPluginConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: SampleInteractionPluginConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class SampleInteractionPlugin__factory extends ContractFactory {
  constructor(...args: SampleInteractionPluginConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
  }

  override deploy(
    dao_: string,
    overrides?: Overrides & { from?: string }
  ): Promise<SampleInteractionPlugin> {
    return super.deploy(
      dao_,
      overrides || {}
    ) as Promise<SampleInteractionPlugin>;
  }
  override getDeployTransaction(
    dao_: string,
    overrides?: Overrides & { from?: string }
  ): TransactionRequest {
    return super.getDeployTransaction(dao_, overrides || {});
  }
  override attach(address: string): SampleInteractionPlugin {
    return super.attach(address) as SampleInteractionPlugin;
  }
  override connect(signer: Signer): SampleInteractionPlugin__factory {
    return super.connect(signer) as SampleInteractionPlugin__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): SampleInteractionPluginInterface {
    return new utils.Interface(_abi) as SampleInteractionPluginInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): SampleInteractionPlugin {
    return new Contract(
      address,
      _abi,
      signerOrProvider
    ) as SampleInteractionPlugin;
  }
}
