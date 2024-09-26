const { ethers } = require("ethers");
const AutID = require("./out/AutID.sol/AutID.json");
const HubRegistry = require("./out/HubRegistry.sol/HubRegistry.json");
const fs = require("fs");
require("dotenv").config();

const loadDeployedContracts = () => {
  const data = fs.readFileSync("deployments.txt", "utf8");
  const blocks = data.trim().split(/\n\s*\n/);

  let parsedBlocks = [];
  for (let block of blocks) {
    let lines = block.trim().split("\n");
    if (lines.length > 0) {
      let header = lines[0].trim();
      let [someNumber, timestampStr] = header.split(" ");
      let timestamp = parseInt(timestampStr, 10);

      let contractMap = {};
      for (let i = 1; i < lines.length; i++) {
        let line = lines[i].trim();
        let match = line.match(/^\d+\.\s+([^:]+):\s+(.+)$/);
        if (match) {
          let name = match[1].trim();
          let address = match[2].trim();
          contractMap[name] = address;
        }
      }

      parsedBlocks.push({
        timestamp,
        contracts: contractMap,
      });
    }
  }
  parsedBlocks.sort((a, b) => b.timestamp - a.timestamp);
  let latestContracts = parsedBlocks[0].contracts;
  return latestContracts;
};

async function getOverrides(provider, percentageIncrease = 2000) {
  const feeData = await provider.getFeeData();
  const percentageMultiplier = BigInt(100 + percentageIncrease);
  const hundred = BigInt(100);

  const adjustedMaxPriorityFeePerGas =
    (BigInt(feeData.maxPriorityFeePerGas) * percentageMultiplier) / hundred;

  let adjustedMaxFeePerGas =
    (BigInt(feeData.maxFeePerGas) * percentageMultiplier) / hundred;

  const latestBlock = await provider.getBlock("latest");
  const baseFeePerGas = BigInt(latestBlock.baseFeePerGas);

  const minRequiredMaxFeePerGas = baseFeePerGas + adjustedMaxPriorityFeePerGas;

  if (adjustedMaxFeePerGas < minRequiredMaxFeePerGas) {
    adjustedMaxFeePerGas = minRequiredMaxFeePerGas;
  }

  const gasLimit = 4_000_000n;

  const overrides = {
    maxPriorityFeePerGas: adjustedMaxPriorityFeePerGas,
    maxFeePerGas: adjustedMaxFeePerGas,
    gasLimit: gasLimit,
  };

  for (const key in overrides) {
    console.log(`${key}: ${overrides[key].toString()}`);
  }

  return overrides;
}

async function main() {
  const provider = new ethers.providers.JsonRpcProvider(
    process.env.TESTNET_RPC_URL,
  );

  const ownerPrivateKey = process.env.TESTNET_PRIVATE_KEY;
  const { autIDProxy, hubRegistryProxy } = loadDeployedContracts();
  const ownerWallet = new ethers.Wallet(ownerPrivateKey, provider);
  const overrides = await getOverrides(provider);
  const autIdOwner = new ethers.Contract(
    autIDProxy.trim(),
    AutID.abi,
    ownerWallet,
  );
  const hubRegistryOwner = new ethers.Contract(
    hubRegistryProxy.trim(),
    HubRegistry.abi,
    ownerWallet,
  );

  // Deploy a hub
  const roles = [1, 2, 3];
  const market = 1;
  const metadata = "Mock Metadata";
  const commitment = 1;

  console.log("Deploying hub...");
  const deployHubTx = await hubRegistryOwner.deployHub(
    roles,
    market,
    metadata,
    commitment,
    overrides,
  );
  const deployHubReceipt = await deployHubTx.wait();

  const hubDeployedEvent = deployHubReceipt.events.find(
    (event) => event.event === "HubCreated",
  );
  const hubAddress = hubDeployedEvent.args[1];
  console.log("Hub deployed at address:");

  const role = 1;
  const userCommitment = 3;
  const username = "alice";
  const optionalURI = "ipfs://QmXZnZ";

  console.log("Alice is creating a record and joining the hub...");
  const joinTx = await autIdOwner.createRecordAndJoinHub(
    role,
    userCommitment,
    hubAddress,
    username,
    optionalURI,
    overrides,
  );
  const joinReceipt = await joinTx.wait();
  console.log("Alice has joined the hub.");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error executing script:", error);
    process.exit(1);
  });
