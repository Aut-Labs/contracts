//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Aut} from "../contracts/repfi/token/AUT.sol";
import {Distributor} from "../contracts/repfi/token/Distributor.sol";

import "forge-std/Script.sol";

contract DeployAll is Script {
    address public owner;
    address public projectMultisig;
    uint256 public privateKey;
    bool public deploying;

   
    Aut public aut;
   
    address public sale;
    address public founderInvestors;
    address public earlyContributors;
    address public airdrop;
    address public listing;
    address public kolsAdvisors;
    address public treasury;
    address public reputationMiningSafe;
    
    Distributor public distributor;

    struct TNamedAddress {
        address target;
        string name;
    }

    function version() public pure returns (uint256 major, uint256 minor, uint256 patch) {
        return (0, 1, 1);
    }

    function setOwner(address _owner) public {
        owner = _owner;
        projectMultisig = owner;
    }

    function setUp() public {
        if (block.chainid == 137) {
            owner = vm.envAddress("MAINNET_OWNER_ADDRESS");
            privateKey = vm.envUint("MAINNET_PRIVATE_KEY");
            deploying = true;
            projectMultisig = vm.envAddress("MAINNET_PROJECT_MULTISIG_ADDRESS");

            // token allocation contracts
            sale = vm.envAddress("MAINNET_SALE_MULTISIG");
            treasury = vm.envAddress("MAINNET_TREASURY_MULTISIG");
            airdrop = vm.envAddress("MAINNET_AIRDROP_MULTISIG");
            listing = vm.envAddress("MAINNET_LISTING_MULTISIG");
            founderInvestors = vm.envAddress("MAINNET_FOUNDER_INVESTORS_MULTISIG");
            earlyContributors = vm.envAddress("MAINNET_EARLY_CONTRIBUTORS_MULTISIG");
            kolsAdvisors = vm.envAddress("MAINNET_KOLS_ADVISORS_MULTISIG");
            reputationMiningSafe = vm.envAddress("MAINNET_REPUTATION_MINING_MULTISIG");
        } else if (block.chainid == 80002) {
            owner = vm.envAddress("TESTNET_OWNER_ADDRESS");
            privateKey = vm.envUint("TESTNET_PRIVATE_KEY");
            deploying = true;
            projectMultisig = vm.envAddress("TESTNET_PROJECT_MULTISIG_ADDRESS");

            // token allocation contracts
            sale = vm.envAddress("TESTNET_SALE_MULTISIG");
            treasury = vm.envAddress("TESTNET_TREASURY_MULTISIG");
            airdrop = vm.envAddress("TESTNET_AIRDROP_MULTISIG");
            listing = vm.envAddress("TESTNET_LISTING_MULTISIG");
            founderInvestors = vm.envAddress("TESTNET_FOUNDER_INVESTORS_MULTISIG");
            earlyContributors = vm.envAddress("TESTNET_EARLY_CONTRIBUTORS_MULTISIG");
            kolsAdvisors = vm.envAddress("TESTNET_KOLS_ADVISORS_MULTISIG");
            reputationMiningSafe = vm.envAddress("TESTNET_REPUTATION_MINING_MULTISIG");
        } else {
            // testing
            privateKey = 567890;
            owner = vm.addr(privateKey);

            // token allocation contracts
            sale = makeAddr("sale");
            treasury = makeAddr("treasury");
            airdrop = makeAddr("airdrop");
            listing = makeAddr("listing");
            founderInvestors = makeAddr("foundersInvestors");
            earlyContributors = makeAddr("earlyContributors");
            kolsAdvisors = makeAddr("kolsAdvisors");
            reputationMiningSafe = makeAddr("reputationMiningSafe");
        }
        console.log("setUp -- done");

        vm.startBroadcast(privateKey);
    }

    function run() public {

        // deploy token contracts
        aut = deployAutToken();

        // deploy distributor
        distributor = deployDistributor(
            aut,
            sale,
            reputationMiningSafe,
            airdrop,
            founderInvestors,
            earlyContributors,
            listing,
            treasury,
            kolsAdvisors
        );

        // send tokens to distribution contract
        aut.transfer(address(distributor), 100000000 ether); // 100 million aut tokens

        // distribute tokens
        distributor.distribute();

        if (deploying) {
            string memory filename = "deployments.txt";
            TNamedAddress[10] memory na;
            na[0] = TNamedAddress({name: "aut", target: address(aut)});
            na[1] = TNamedAddress({name: "sale", target: address(sale)});
            na[2] = TNamedAddress({name: "founderInvestors", target: address(founderInvestors)});
            na[3] = TNamedAddress({name: "earlyContributors", target: address(earlyContributors)});
            na[4] = TNamedAddress({name: "airdrop", target: address(airdrop)});
            na[5] = TNamedAddress({name: "kolsAdvisors", target: address(kolsAdvisors)});
            na[6] = TNamedAddress({name: "treasury", target: address(treasury)});
            na[7] = TNamedAddress({name: "reputationMining", target: address(reputationMiningSafe)});
            na[8] = TNamedAddress({name: "listing", target: address(listing)});
            na[9] = TNamedAddress({name: "distributor", target: address(distributor)});

            vm.writeLine(filename, string.concat(vm.toString(block.chainid), " ", vm.toString(block.timestamp)));
            for (uint256 i = 0; i != na.length; ++i) {
                vm.writeLine(
                    filename,
                    string.concat(vm.toString(i), ". ", na[i].name, ": ", vm.toString(na[i].target))
                );
            }
            vm.writeLine(filename, "\n");
        }
    }
}

function deployAutToken() returns (Aut) {
    Aut aut = new Aut();
    return aut;
}

function deployDistributor(
    Aut _aut,
    address _sale,
    address _reputationMining,
    address _airdrop,
    address _founderInvestors,
    address _earlyContributors,
    address _listing,
    address _treasury,
    address _kolsAdvisors
) returns (Distributor) {
    Distributor distributor = new Distributor(
        _aut,
        _sale,
        _reputationMining,
        _airdrop,
        _founderInvestors,
        _earlyContributors,
        _listing,
        _treasury,
        _kolsAdvisors
    );
    return distributor;
}
