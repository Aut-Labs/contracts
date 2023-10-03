/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import { Signer, utils, Contract, ContractFactory, Overrides } from "ethers";
import type { Provider, TransactionRequest } from "@ethersproject/providers";
import type { NovaFactory, NovaFactoryInterface } from "../NovaFactory";

const _abi = [
  {
    inputs: [
      {
        internalType: "address",
        name: "deployer",
        type: "address",
      },
      {
        internalType: "address",
        name: "autIDAddr",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "market",
        type: "uint256",
      },
      {
        internalType: "string",
        name: "metadata",
        type: "string",
      },
      {
        internalType: "uint256",
        name: "commitment",
        type: "uint256",
      },
      {
        internalType: "address",
        name: "pluginRegistry",
        type: "address",
      },
    ],
    name: "deployNova",
    outputs: [
      {
        internalType: "address",
        name: "_nova",
        type: "address",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
] as const;

const _bytecode =
  "0x608060405234801561001057600080fd5b506126ae806100206000396000f3fe608060405234801561001057600080fd5b506004361061002b5760003560e01c8063b4aa79dc14610030575b600080fd5b61004361003e3660046100d8565b61005f565b6040516001600160a01b03909116815260200160405180910390f35b60008088888888888888604051610075906100af565b6100859796959493929190610190565b604051809103906000f0801580156100a1573d6000803e3d6000fd5b509998505050505050505050565b612485806101f483390190565b80356001600160a01b03811681146100d357600080fd5b919050565b600080600080600080600060c0888a0312156100f357600080fd5b6100fc886100bc565b965061010a602089016100bc565b955060408801359450606088013567ffffffffffffffff8082111561012e57600080fd5b818a0191508a601f83011261014257600080fd5b81358181111561015157600080fd5b8b602082850101111561016357600080fd5b6020830196508095505050506080880135915061018260a089016100bc565b905092959891949750929550565b600060018060a01b03808a168352808916602084015287604084015260c060608401528560c0840152858760e0850137600060e0878501015260e0601f19601f880116840101915084608084015280841660a0840152509897505050505050505056fe60806040523480156200001157600080fd5b50604051620024853803806200248583398101604081905262000034916200033b565b600c80546001600160a01b0388166001600160a01b031991821681179092556000828152600460205260408120805460ff191660019081179091556003805491820181559091527fc2575a0e9e593c00f959f8c92f12db2869c3395a3b0502d05e2516446f71f85b0180549091169091179055620000b284620000fa565b600080546001600160a01b0319166001600160a01b038716179055620000d8826200017f565b620000e38362000204565b620000ee8162000280565b505050505050620005bb565b6000811180156200010b5750600481105b6200014e5760405162461bcd60e51b815260206004820152600e60248201526d1a5b9d985b1a59081b585c9ad95d60921b60448201526064015b60405180910390fd5b60088190556040517f4086cd87c923de65497ff5918262360a3284451fdc7ee5597eaa90abaf2345f490600090a150565b600081118015620001905750600b81105b620001d35760405162461bcd60e51b81526020600482015260126024820152711a5b9d985b1a590818dbdb5b5a5d1b595b9d60721b604482015260640162000145565b600b8190556040517f6e94e6036cb0a3a2ee59e8687248332f61e0e9c059b4946908091e2ff873649f90600090a150565b6000815111620002455760405162461bcd60e51b815260206004820152600b60248201526a1a5b9d985b1a59081d5c9b60aa1b604482015260640162000145565b6005620002538282620004ef565b506040517fd7a0756058a289c0ef8ae9d83008cd5710c64575760271d6f2af16f7b4af140190600090a150565b6001600160a01b038116620002d85760405162461bcd60e51b815260206004820152601660248201527f696e76616c696420706c7567696e526567697374727900000000000000000000604482015260640162000145565b600980546001600160a01b0319166001600160a01b0392909216919091179055565b6001600160a01b03811681146200031057600080fd5b50565b80516200032081620002fa565b919050565b634e487b7160e01b600052604160045260246000fd5b60008060008060008060c087890312156200035557600080fd5b86516200036281620002fa565b809650506020808801516200037781620002fa565b604089015160608a015191975095506001600160401b03808211156200039c57600080fd5b818a0191508a601f830112620003b157600080fd5b815181811115620003c657620003c662000325565b604051601f8201601f19908116603f01168101908382118183101715620003f157620003f162000325565b816040528281528d868487010111156200040a57600080fd5b600093505b828410156200042e57848401860151818501870152928501926200040f565b6000868483010152809850505050505050608087015191506200045460a0880162000313565b90509295509295509295565b600181811c908216806200047557607f821691505b6020821081036200049657634e487b7160e01b600052602260045260246000fd5b50919050565b601f821115620004ea57600081815260208120601f850160051c81016020861015620004c55750805b601f850160051c820191505b81811015620004e657828155600101620004d1565b5050505b505050565b81516001600160401b038111156200050b576200050b62000325565b62000523816200051c845462000460565b846200049c565b602080601f8311600181146200055b5760008415620005425750858301515b600019600386901b1c1916600185901b178555620004e6565b600085815260208120601f198616915b828110156200058c578886015182559484019460019091019084016200056b565b5085821015620005ab5787850151600019600388901b60f8161c191681555b5050505050600190811b01905550565b611eba80620005cb6000396000f3fe608060405234801561001057600080fd5b50600436106101c45760003560e01c806369130c8d116100f95780639c54df6411610097578063be9cd05211610071578063be9cd052146103c1578063cd29c71a146103d4578063d103449c146103e9578063d5f39488146103fc57600080fd5b80639c54df6414610378578063a230c5241461038b578063b5a8a3a1146103ae57600080fd5b806380f55605116100d357806380f5560514610338578063810e8c04146103415780638307bd241461035457806388098e3a1461036757600080fd5b806369130c8d1461030a578063704802751461031d5780637c0f6b351461033057600080fd5b806324d7806c116101665780633b4da69f116101405780633b4da69f146102be57806341dcea91146102d15780635daf08ca146102e457806368839d28146102f757600080fd5b806324d7806c1461027e5780632a79c611146102a157806331ae450b146102a957600080fd5b806311aee380116101a257806311aee3801461021957806314bfd6d01461022b5780631785f53c14610256578063206110db1461026957600080fd5b806303ffe330146101c957806310972e90146101f15780631130630c14610204575b600080fd5b6101dc6101d73660046117e3565b61040f565b60405190151581526020015b60405180910390f35b6101dc6101ff36600461180f565b610543565b6102176102123660046118c0565b610599565b005b6001545b6040519081526020016101e8565b61023e61023936600461180f565b6105dd565b6040516001600160a01b0390911681526020016101e8565b610217610264366004611940565b610607565b610271610729565b6040516101e891906119b4565b6101dc61028c366004611940565b60046020526000908152604090205460ff1681565b600b5461021d565b6102b1610802565b6040516101e89190611a16565b6102176102cc3660046117e3565b610864565b60095461023e906001600160a01b031681565b61023e6102f236600461180f565b610961565b6101dc6103053660046118c0565b610971565b61021761031836600461180f565b6109f0565b61021761032b366004611940565b610a28565b6102b1610b44565b61021d60085481565b61021761034f3660046118c0565b610ba4565b600d5461023e906001600160a01b031681565b6000546001600160a01b031661023e565b6102b1610386366004611a63565b610bdc565b6101dc610399366004611940565b60026020526000908152604090205460ff1681565b6102176103bc366004611940565b610dd9565b6102176103cf36600461180f565b610fa3565b6103dc610fdb565b6040516101e89190611b15565b6102176103f73660046118c0565b611069565b600c5461023e906001600160a01b031681565b600d546000906001600160a01b031661042a5750600161053d565b600d546001600160a01b0316158015906104b85750600d60009054906101000a90046001600160a01b03166001600160a01b03166322f3e2d46040518163ffffffff1660e01b8152600401602060405180830381865afa158015610492573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906104b69190611b28565b155b156104c55750600061053d565b600d54604051634f2b51c760e01b81526001600160a01b0385811660048301526024820185905290911690634f2b51c790604401602060405180830381865afa158015610516573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061053a9190611b28565b90505b92915050565b6000805b600a548110156105905782600a828154811061056557610565611b4a565b90600052602060002001540361057e5750600192915050565b8061058881611b76565b915050610547565b50600092915050565b3360009081526004602052604090205460ff166105d15760405162461bcd60e51b81526004016105c890611b8f565b60405180910390fd5b6105da816110a1565b50565b600381815481106105ed57600080fd5b6000918252602090912001546001600160a01b0316905081565b3360009081526004602052604090205460ff166106365760405162461bcd60e51b81526004016105c890611b8f565b60005b6003548110156106d057816001600160a01b03166003828154811061066057610660611b4a565b6000918252602090912001546001600160a01b0316036106be5760006003828154811061068f5761068f611b4a565b9060005260206000200160006101000a8154816001600160a01b0302191690836001600160a01b031602179055505b806106c881611b76565b915050610639565b506001600160a01b038116600081815260046020908152604091829020805460ff1916905590519182527ffa8ae95b9a4f666c3b5f27d11b5c2b9fe1045279f674e7a78ca8b087cba3802591015b60405180910390a150565b60606006805480602002602001604051908101604052809291908181526020016000905b828210156107f957838290600052602060002001805461076c90611bb6565b80601f016020809104026020016040519081016040528092919081815260200182805461079890611bb6565b80156107e55780601f106107ba576101008083540402835291602001916107e5565b820191906000526020600020905b8154815290600101906020018083116107c857829003601f168201915b50505050508152602001906001019061074d565b50505050905090565b6060600380548060200260200160405190810160405280929190818152602001828054801561085a57602002820191906000526020600020905b81546001600160a01b0316815260019091019060200180831161083c575b5050505050905090565b6000546001600160a01b031633146108ab5760405162461bcd60e51b815260206004820152600a60248201526913db9b1e48105d5d125160b21b60448201526064016105c8565b604051623ffe3360e41b81526001600160a01b03831660048201526024810182905230906303ffe33090604401602060405180830381865afa1580156108f5573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906109199190611b28565b6109535760405162461bcd60e51b815260206004820152600b60248201526a1b9bdd08185b1b1bddd95960aa1b60448201526064016105c8565b61095d8282611119565b5050565b600181815481106105ed57600080fd5b600654600090810361098557506000919050565b815160208084019190912060008181526007909252604090912054156109ae5750600192915050565b8060066000815481106109c3576109c3611b4a565b906000526020600020016040516109da9190611bf0565b6040518091039020036105905750600192915050565b3360009081526004602052604090205460ff16610a1f5760405162461bcd60e51b81526004016105c890611b8f565b6105da8161124b565b3360009081526004602052604090205460ff16610a575760405162461bcd60e51b81526004016105c890611b8f565b6001600160a01b03811660009081526002602052604090205460ff16610aae5760405162461bcd60e51b815260206004820152600c60248201526b2737ba10309036b2b6b132b960a11b60448201526064016105c8565b6001600160a01b0381166000818152600460209081526040808320805460ff191660019081179091556003805491820181559093527fc2575a0e9e593c00f959f8c92f12db2869c3395a3b0502d05e2516446f71f85b90920180546001600160a01b0319168417905590519182527fa06b993f17e63959ef40ec8755fc98020c50e9d2794ce5fc0886a7792a9fbaec910161071e565b6060600180548060200260200160405190810160405280929190818152602001828054801561085a576020028201919060005260206000209081546001600160a01b0316815260019091019060200180831161083c575050505050905090565b3360009081526004602052604090205460ff16610bd35760405162461bcd60e51b81526004016105c890611b8f565b6105da816113d8565b3360009081526004602052604090205460609060ff16610c0e5760405162461bcd60e51b81526004016105c890611b8f565b60005b8251811015610dd25760026000848381518110610c3057610c30611b4a565b6020908102919091018101516001600160a01b031682528101919091526040016000205460ff16610c8257828181518110610c6d57610c6d611b4a565b60006020918202929092010152600101610c11565b60046000848381518110610c9857610c98611b4a565b6020908102919091018101516001600160a01b031682528101919091526040016000205460ff16610dca576003838281518110610cd757610cd7611b4a565b60209081029190910181015182546001808201855560009485529284200180546001600160a01b0319166001600160a01b0390921691909117905584519091600491869085908110610d2b57610d2b611b4a565b60200260200101516001600160a01b03166001600160a01b0316815260200190815260200160002060006101000a81548160ff0219169083151502179055507fa06b993f17e63959ef40ec8755fc98020c50e9d2794ce5fc0886a7792a9fbaec838281518110610d9d57610d9d611b4a565b6020026020010151604051610dc191906001600160a01b0391909116815260200190565b60405180910390a15b600101610c11565b5090919050565b806001600160a01b031663a1308f276040518163ffffffff1660e01b8152600401602060405180830381865afa158015610e17573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610e3b9190611c66565b600114610e835760405162461bcd60e51b815260206004820152601660248201527527b7363c9027b73137b0b93234b7339028363ab3b4b760511b60448201526064016105c8565b600d546001600160a01b0316610ee9576009546001600160a01b03163314610ee45760405162461bcd60e51b81526020600482015260146024820152734f6e6c7920506c7567696e20526567697374727960601b60448201526064016105c8565b610f81565b604051630935e01b60e21b815233600482015230906324d7806c90602401602060405180830381865afa158015610f24573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610f489190611b28565b610f815760405162461bcd60e51b815260206004820152600a60248201526927b7363c9020b236b4b760b11b60448201526064016105c8565b600d80546001600160a01b0319166001600160a01b0392909216919091179055565b3360009081526004602052604090205460ff16610fd25760405162461bcd60e51b81526004016105c890611b8f565b6105da816115d8565b60058054610fe890611bb6565b80601f016020809104026020016040519081016040528092919081815260200182805461101490611bb6565b80156110615780601f1061103657610100808354040283529160200191611061565b820191906000526020600020905b81548152906001019060200180831161104457829003601f168201915b505050505081565b3360009081526004602052604090205460ff166110985760405162461bcd60e51b81526004016105c890611b8f565b6105da8161165a565b60008151116110e05760405162461bcd60e51b815260206004820152600b60248201526a1a5b9d985b1a59081d5c9b60aa1b60448201526064016105c8565b60056110ec8282611cce565b506040517fd7a0756058a289c0ef8ae9d83008cd5710c64575760271d6f2af16f7b4af140190600090a150565b6000546001600160a01b031633146111605760405162461bcd60e51b815260206004820152600a60248201526913db9b1e48105d5d125160b21b60448201526064016105c8565b6001600160a01b03821660009081526002602052604090205460ff16156111bc5760405162461bcd60e51b815260206004820152601060248201526f20b63932b0b23c90309036b2b6b132b960811b60448201526064016105c8565b6001600160a01b038216600081815260026020526040808220805460ff19166001908117909155805480820182559083527fb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf60180546001600160a01b03191690931790925590517f94d9b0a056867efca93631b338c7fde3befc3f54db36b90b8456b069385c30be9190a15050565b60095460408051631055995d60e31b815290516000926001600160a01b0316916382accae89160048083019260209291908290030181865afa158015611295573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906112b99190611d8e565b6040516339076b2160e11b8152600481018490529091506000906001600160a01b0383169063720ed64290602401600060405180830381865afa158015611304573d6000803e3d6000fd5b505050506040513d6000823e601f3d908101601f1916820160405261132c9190810190611dab565b51511161136c5760405162461bcd60e51b815260206004820152600e60248201526d696e76616c6964206d6f64756c6560901b60448201526064016105c8565b600a80546001810182556000919091527fc65a7bb8d6351c1cf70c95a316cc6a92839c986682d98bc35f958f4883f9d2a8018290556040518281527fc1866ccaad33ac161f17d9db7a528f0c819a376e1cad17ba2d5c9b49a7eba2cd9060200160405180910390a15050565b6113e181610971565b6114205760405162461bcd60e51b815260206004820152601060248201526f1d5c9b08191bd95cdb9d08195e1a5cdd60821b60448201526064016105c8565b80516020808301919091206000818152600790925260409091205460065461144a90600190611e5b565b811461155b57600680546000919061146490600190611e5b565b8154811061147457611474611b4a565b90600052602060002001805461148990611bb6565b80601f01602080910402602001604051908101604052809291908181526020018280546114b590611bb6565b80156115025780601f106114d757610100808354040283529160200191611502565b820191906000526020600020905b8154815290600101906020018083116114e557829003601f168201915b50505050509050600081805190602001209050826007600083815260200190815260200160002081905550816006848154811061154157611541611b4a565b9060005260206000200190816115579190611cce565b5050505b600680548061156c5761156c611e6e565b6001900381819060005260206000200160006115889190611780565b905560008281526007602052604080822091909155517f906b87aebf1e5cc40a1cebd6811c88addf04309f8c8ce71c7d6449d343e4ad09906115cb908590611b15565b60405180910390a1505050565b6000811180156115e85750600b81105b6116295760405162461bcd60e51b81526020600482015260126024820152711a5b9d985b1a590818dbdb5b5a5d1b595b9d60721b60448201526064016105c8565b600b8190556040517f6e94e6036cb0a3a2ee59e8687248332f61e0e9c059b4946908091e2ff873649f90600090a150565b80516020820120600654600090156116c2576000828152600760205260409020541515806116b9575081600660008154811061169857611698611b4a565b906000526020600020016040516116af9190611bf0565b6040518091039020145b156116c2575060015b80156117055760405162461bcd60e51b815260206004820152601260248201527175726c20616c72656164792065786973747360701b60448201526064016105c8565b600680546000848152600760205260408120829055600182018355919091527ff652222313e28459528d920b65115c16c04f3efc82aaedc97be59f3f377c0d3f016117508482611cce565b507f21d5cca3f840791ade736f51501810c14b8b01791ac4357713ed763ccbbaf3a9836040516115cb9190611b15565b50805461178c90611bb6565b6000825580601f1061179c575050565b601f0160209004906000526020600020908101906105da91905b808211156117ca57600081556001016117b6565b5090565b6001600160a01b03811681146105da57600080fd5b600080604083850312156117f657600080fd5b8235611801816117ce565b946020939093013593505050565b60006020828403121561182157600080fd5b5035919050565b634e487b7160e01b600052604160045260246000fd5b6040805190810167ffffffffffffffff8111828210171561186157611861611828565b60405290565b604051601f8201601f1916810167ffffffffffffffff8111828210171561189057611890611828565b604052919050565b600067ffffffffffffffff8211156118b2576118b2611828565b50601f01601f191660200190565b6000602082840312156118d257600080fd5b813567ffffffffffffffff8111156118e957600080fd5b8201601f810184136118fa57600080fd5b803561190d61190882611898565b611867565b81815285602083850101111561192257600080fd5b81602084016020830137600091810160200191909152949350505050565b60006020828403121561195257600080fd5b813561195d816117ce565b9392505050565b60005b8381101561197f578181015183820152602001611967565b50506000910152565b600081518084526119a0816020860160208601611964565b601f01601f19169290920160200192915050565b6000602080830181845280855180835260408601915060408160051b870101925083870160005b82811015611a0957603f198886030184526119f7858351611988565b945092850192908501906001016119db565b5092979650505050505050565b6020808252825182820181905260009190848201906040850190845b81811015611a575783516001600160a01b031683529284019291840191600101611a32565b50909695505050505050565b60006020808385031215611a7657600080fd5b823567ffffffffffffffff80821115611a8e57600080fd5b818501915085601f830112611aa257600080fd5b813581811115611ab457611ab4611828565b8060051b9150611ac5848301611867565b8181529183018401918481019088841115611adf57600080fd5b938501935b83851015611b095784359250611af9836117ce565b8282529385019390850190611ae4565b98975050505050505050565b60208152600061195d6020830184611988565b600060208284031215611b3a57600080fd5b8151801515811461195d57600080fd5b634e487b7160e01b600052603260045260246000fd5b634e487b7160e01b600052601160045260246000fd5b600060018201611b8857611b88611b60565b5060010190565b6020808252600d908201526c4e6f7420616e2061646d696e2160981b604082015260600190565b600181811c90821680611bca57607f821691505b602082108103611bea57634e487b7160e01b600052602260045260246000fd5b50919050565b6000808354611bfe81611bb6565b60018281168015611c165760018114611c2b57611c5a565b60ff1984168752821515830287019450611c5a565b8760005260208060002060005b85811015611c515781548a820152908401908201611c38565b50505082870194505b50929695505050505050565b600060208284031215611c7857600080fd5b5051919050565b601f821115611cc957600081815260208120601f850160051c81016020861015611ca65750805b601f850160051c820191505b81811015611cc557828155600101611cb2565b5050505b505050565b815167ffffffffffffffff811115611ce857611ce8611828565b611cfc81611cf68454611bb6565b84611c7f565b602080601f831160018114611d315760008415611d195750858301515b600019600386901b1c1916600185901b178555611cc5565b600085815260208120601f198616915b82811015611d6057888601518255948401946001909101908401611d41565b5085821015611d7e5787850151600019600388901b60f8161c191681555b5050505050600190811b01905550565b600060208284031215611da057600080fd5b815161195d816117ce565b60006020808385031215611dbe57600080fd5b825167ffffffffffffffff80821115611dd657600080fd5b9084019060408287031215611dea57600080fd5b611df261183e565b825182811115611e0157600080fd5b83019150601f82018713611e1457600080fd5b8151611e2261190882611898565b8181528886838601011115611e3657600080fd5b611e4582878301888701611964565b8252509183015192820192909252949350505050565b8181038181111561053d5761053d611b60565b634e487b7160e01b600052603160045260246000fdfea2646970667358221220dde59a0b49aff01ebd751b52bfe5aa55f3bc444ef8a3842aac2ad80810087e3a64736f6c63430008130033a2646970667358221220eb0bd6560f841f9f7039a2367fdb23814b1ba2e28d1bdb192d3ed3b555be7ad464736f6c63430008130033";

type NovaFactoryConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: NovaFactoryConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class NovaFactory__factory extends ContractFactory {
  constructor(...args: NovaFactoryConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
  }

  override deploy(
    overrides?: Overrides & { from?: string }
  ): Promise<NovaFactory> {
    return super.deploy(overrides || {}) as Promise<NovaFactory>;
  }
  override getDeployTransaction(
    overrides?: Overrides & { from?: string }
  ): TransactionRequest {
    return super.getDeployTransaction(overrides || {});
  }
  override attach(address: string): NovaFactory {
    return super.attach(address) as NovaFactory;
  }
  override connect(signer: Signer): NovaFactory__factory {
    return super.connect(signer) as NovaFactory__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): NovaFactoryInterface {
    return new utils.Interface(_abi) as NovaFactoryInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): NovaFactory {
    return new Contract(address, _abi, signerOrProvider) as NovaFactory;
  }
}
