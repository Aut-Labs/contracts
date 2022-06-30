const autIDAddress = "0xCeb3300b7de5061c633555Ac593C84774D160309";
const communityRegistryAddress = "0x4b1e5a1490039811eFb256f7cef3dca994D68af9";

const comMetadata =
  "bafkreidjy6xlyf2he4iopzijy7bws3yl34xhwh726ca2xd7temqoqkz6xy";
const { assert } = require("chai");
var ethers = require("ethers");

require("dotenv").config();

var autIDAbi = require("../artifacts/contracts/AutID.sol/AutID.json").abi;

var communityRegistryAbi =
  require("../artifacts/contracts/CommunityRegistry.sol/CommunityRegistry.json").abi;

var communityExtensionAbi =
  require("../artifacts/contracts/CommunityExtension.sol/CommunityExtension.json").abi;

var swLegacyCommunityAbi =
  require("../artifacts/contracts/mocks/SWLegacyCommunity.sol/SWLegacyCommunity.json").abi;
var pollsAbi =
  require("../artifacts/contracts/activities/Poll.sol/Polls.json").abi;

const provider = new ethers.providers.JsonRpcProvider(
  "https://matic-mumbai.chainstacklabs.com/"
);

// Wallet connected to a provider
// const senderWalletMnemonic = ethers.Wallet.fromMnemonic(
//   process.env.MNEMONIC_2,
//   "m/44'/60'/0'/0/0"
// );
const senderWalletMnemonic = new ethers.Wallet(process.env.MNEMONIC);
let signer = senderWalletMnemonic.connect(provider);
// const wallet = ethers.Wallet.createRandom();
// console.log(signer.address);
// console.log(wallet.mnemonic);
// console.log(wallet.privateKey);

const autIDContract = new ethers.Contract(autIDAddress, autIDAbi, signer);
const communityRegistryContract = new ethers.Contract(
  communityRegistryAddress,
  communityRegistryAbi,
  signer
);

async function mint(communityExtension) {
  const a = await autIDContract.mint(
    'migrenaa',
    "bafkreigigsavco2dtgcg6ehmunu5cjzr7xiarsrxm6bfw5m5wpor5rfpoi",
    1,
    7,
    communityExtension,
    {
      gasLimit: 1000000,
    }
  );

  const b = await a.wait();
  console.log(b);
}

async function getCommunities(user) {
  const communities = await autIDContract.getCommunities(user);
  console.log("communities:", communities);
}

async function getSWMetadata(tokenId) {
  const metadata = await autIDContract.tokenURI(tokenId);
  console.log("metadata:", metadata);
}

async function getComData(comExtension) {
  const communityExtensionContract = new ethers.Contract(
    comExtension,
    communityExtensionAbi,
    signer
  );

  const data = await communityExtensionContract.getComData();
  console.log("data:", data);
}

async function getCommunityData(user, community) {
  const data = await autIDContract.getCommunityData(user, community);
  console.log("data:", data);
}

async function getCommunities() {
  const getCommunities = await communityRegistryContract.getCommunities();
  console.log("[getCommunities]:", getCommunities);
}
function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function passOnboarding(communityExtension, member) {
  const communityExtensionContract = new ethers.Contract(
    communityExtension,
    communityExtensionAbi,
    signer
  );
  await communityExtensionContract.passOnboarding([member]);
  // console.log("[active community]", com);
}

async function addMember(communityAddress, member) {
  const c = new ethers.Contract(communityAddress, swLegacyCommunityAbi, signer);

  const a = await c.addMember(member);
  console.log(a);
}

async function createCommunity(contractType, daoAddr) {
  const a = await communityRegistryContract.createCommunity(
    contractType,
    daoAddr,
    1,
    comMetadata,
    8
  );
  console.log(a);
}

async function createPoll(pollsAddress, role, dueDate, uri) {
  const pollsContract = new ethers.Contract(pollsAddress, pollsAbi, signer);
  const a = await pollsContract.create(role, dueDate, uri);
  console.log(a);
}

async function getPoll(pollsAddress, pollID) {
  const pollsContract = new ethers.Contract(pollsAddress, pollsAbi, signer);
  const poll = await pollsContract.communityExtension();
  console.log('[poll]: ', poll);
}

async function getAutIDAddrForComExt(communityExtension) {
  const communityExtensionContract = new ethers.Contract(communityExtension, communityRegistryAbi, signer);
  const addr = await communityExtensionContract.autIDAddr();
  console.log('[getAutIDAddrForComExt]: addr', addr);
}
async function test() {
  const communityExtension = "0x7623c3237f045388D97a8EC6420157cb164f91c8";
  const daoAddr = '0x3Dcf2c5D8b8997A3E5740DC8507Ed4E5533Dde14'
  const user = "0x33400efca704d14635cb85a381c1e28dc504ef65";
  const pollsAddress = '0x270e27E4E6422C311449E9aA258B3181235837ce'
  const blockNumber = await provider.getBlockNumber()
  const timestamp = (await provider.getBlock(blockNumber)).timestamp;
  // await getPoll(pollsAddress, 0);
  // await createPoll(pollsAddress, 0, timestamp, 'bafkreibcuujzwl7hzd6uwi5t5zajur2tkdu2nhyouqvccd4oak3hyhijgy')
  // await addMember('0x3Dcf2c5D8b8997A3E5740DC8507Ed4E5533Dde14', signer.address);
  // await addMember(daoAddr, '0x720Db641247BAacf528c696518C28153eB0E1100');
  // await getAutIDAddrForComExt(communityExtension);
  // await createCommunity(1, '0x73297cb191a7f510C440a1Ce64Cb2E1b18753409')
  // await passOnboarding(communityExtension, '0x7660aa261d27A2A32d4e7e605C1bc2BA515E5f81');
  // await getCommunities();
  // await getComData(communityExtension);
  // const community = '0x96dCCC06b1729CD8ccFe849CE9cA7e020e19515c';
  // await getCommunityData(user, community);
  // await getComData(communityExtension)
  // await getSWMetadata(0);
  // await createCommunity(1, "0x7DeF7A0C6553B9f7993a131b5e30AB59386837E0");
  // await getCommunities();
  // await mint(communityExtension);
  await getCommunities();
}

test();
