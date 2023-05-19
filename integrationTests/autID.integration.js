const autIDAddress = "0x0b3e1f75c415125B30b51384DE69C0b819CF4b52";
const daoExpanderRegistryAddress = "0xde80c0eF7FFE533b095B5DAeb6F7A7298a201b39";

const comMetadata =
  "bafkreidjy6xlyf2he4iopzijy7bws3yl34xhwh726ca2xd7temqoqkz6xy";
const { assert } = require("chai");
var ethers = require("ethers");

require("dotenv").config();

var autIDAbi = require("../artifacts/contracts/AutID.sol/AutID.json").abi;

var daoExpanderRegistryAbi =
  require("../artifacts/contracts/expander/DAOExpanderRegistry.sol/DAOExpanderRegistry.json").abi;

var daoExpanderAbi =
  require("../artifacts/contracts/expander/DAOExpander.sol/DAOExpander.json").abi;

  // /Users/tagamite/Desktop/dev/aut/contracts/artifacts/contracts/modules/implementations/types/tasks/plugins/questTasks/OnboardingOffchainVerifiedTaskPlugin.sol/OnboardingQuestOffchainVerifiedTaskPlugin.dbg.json
var offchaintaskabi =
require("../artifacts/contracts/plugins/tasks/OffchainVerifiedTaskPlugin.sol/OffchainVerifiedTaskPlugin.json").abi;

var onchaintaskabi =
require("../artifacts/contracts/plugins/tasks/OpenTaskPlugin.sol/OpenTaskPlugin.json").abi;

var onboardingAbi =
require("../artifacts/contracts/plugins/onboarding/QuestOnboardingPlugin.sol/QuestOnboardingPlugin.json").abi;

var questAbi =
require("../artifacts/contracts/plugins/quests/QuestPlugin.sol/QuestPlugin.json").abi;

var autDAOAbi = 
require("../artifacts/contracts/autDAO/AutDAO.sol/AutDAO.json").abi;

const provider = new ethers.providers.JsonRpcProvider(
  "https://matic-mumbai.chainstacklabs.com/"
);

// Wallet connected to a provider
const senderWalletMnemonic = ethers.Wallet.fromMnemonic(
  process.env.MNEMONIC_2,
  "m/44'/60'/0'/0/0"
);
// const senderWallet = new ethers.Wallet(process.env.PRIVATE_KEY);
let signer = senderWalletMnemonic.connect(provider);
// console.log(signer.address)
// const wallet = ethers.Wallet.createRandom();
// console.log(wallet.address);
// console.log(wallet.mnemonic);
// console.log(wallet.privateKey);

const autIDContract = new ethers.Contract(autIDAddress, autIDAbi, signer);
const daoExpanderRegistryContract = new ethers.Contract(
  daoExpanderRegistryAddress,
  daoExpanderRegistryAbi,
  signer
);

async function mint(daoExpander) {
  const a = await autIDContract.mint(
    'tao',
    "bafkreibjs7jvzzxiqrpyyhjvk3dwxgsff6ctgjyfnmwjksir6dhqni2m3a",
    1,
    7,
    daoExpander,
    {
      gasLimit: 1000000,
    }
  );

  const b = await a.wait();
  console.log(b);
}

async function getHolderDAOs(user) {
  const daos = await autIDContract.getHolderDAOs(user);
  console.log("daos:", daos);
}

async function getAutIDMetadata(tokenId) {
  const metadata = await autIDContract.tokenURI(tokenId);
  console.log("metadata:", metadata);
}

async function getDAOData(daoExpander) {
  const daoExpanderContract = new ethers.Contract(
    daoExpander,
    daoExpanderAbi,
    signer
  );

  const data = await daoExpanderContract.getDAOData();
  console.log("data:", data);
}

async function getMembershipData(user, daoExpander) {
  const data = await autIDContract.getMembershipData(user, daoExpander);
  console.log("data:", data);
}

async function getDAOExpanders() {
  const getDAOExpanders = await daoExpanderRegistryContract.getDAOExpanders();
  console.log("[getDAOExpanders]:", getDAOExpanders);
}

async function deployDAOExpander() {
  const a = await daoExpanderRegistryContract.deployDAOExpander(
    1,
    '0x73297cb191a7f510C440a1Ce64Cb2E1b18753409',
    1,
    'bafkreidjy6xlyf2he4iopzijy7bws3yl34xhwh726ca2xd7temqoqkz6xy',
    8);
    console.log(a);
    console.log(await a.wait());
};


async function getDAOExpanders() {
  const a = await daoExpanderRegistryContract.getDAOExpanders();
    console.log(a);
};
async function isAdmin(daoExpander, user) {
  const daoExpanderContract = new ethers.Contract(
    daoExpander,
    daoExpanderAbi,
    signer
  );

  const isAdmin = await daoExpanderContract.isAdmin(user);
  console.log('isAdmin', isAdmin);
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function passOnboarding(daoExpander, member) {
  const daoExpanderContract = new ethers.Contract(
    daoExpander,
    daoExpanderAbi,
    signer
  );
  await daoExpanderContract.passOnboarding([member]);
}

async function addMember(swLegacyDAO, member) {
  const c = new ethers.Contract(swLegacyDAO, SWLegacyDAOAbi, signer);
  const a = await c.addMember(member);
  console.log(a);
}

async function getAutIDAddrFrinDAOExpander(daoExpander) {
  const daoExpanderContract = new ethers.Contract(daoExpander, daoExpanderRegistryAbi, signer);
  const addr = await daoExpanderContract.autIDAddr();
  console.log('[getAutIDAddrFrinDAOExpander]: addr', addr);
}

async function getDAOMetadata(daoExpander) {
  const daoExpanderContract = new ethers.Contract(daoExpander, daoExpanderRegistryAbi, signer);
  const metadata = await daoExpanderContract.getMetadataUri();
  console.log('[getDAOMetadata]:', metadata);
}


async function getAutIDUsername(username) {
  const addr = await autIDContract.autIDUsername(username);
  console.log('[autIDUsername]: addr', addr);
}

async function setOffchainVerifierAddress(taskAddr, addr) {
const contr = new ethers.Contract(taskAddr, offchaintaskabi, signer);
const a = await contr.setOffchainVerifierAddress(addr);
console.log(a);
}


async function getStatusPerSubmitter(taskAddr, taskID, submitter) {
  const contr = new ethers.Contract(taskAddr, onchaintaskabi, signer);
  const a = await contr.getStatusPerSubmitter(taskID, submitter);
  console.log(a);
}

async function getCompletionTime(taskAddr, taskID, submitter) {
  const contr = new ethers.Contract(taskAddr, onchaintaskabi, signer);
  const a = await contr.getCompletionTime(taskID, submitter);
  console.log(a);
}


async function getSubmissionIdPerTaskAndUser(taskAddr, taskID, submitter) {
  const contr = new ethers.Contract(taskAddr, onchaintaskabi, signer);
  const a = await contr.getSubmissionIdPerTaskAndUser(taskID, submitter);
  console.log(a);
}



async function getTaskByID(taskAddr, taskID) {
  const contr = new ethers.Contract(taskAddr, onchaintaskabi, signer);
  const a = await contr.getById(taskID);
  console.log(a);
  return a;
}

async function finalize(taskAddr, taskID, submitter) {
  const contr = new ethers.Contract(taskAddr, offchaintaskabi, signer);
  const a = await contr.finalizeFor(taskID, submitter);
  console.log(await a.wait());
}

async function isOnboarded(onboardingAddress, member, role) {
  const contr = new ethers.Contract(onboardingAddress, onboardingAbi, signer);
  const a = await contr.isOnboarded(member, role);
  console.log(a);
}


async function hasCompletedAQuest(questAddress, member, questId) {
  const contr = new ethers.Contract(questAddress, questAbi, signer);
  const a = await contr.hasCompletedAQuest(member, questId);
  console.log(a);
}
async function getTimeOfCompletion(questAddress, member, questId) {
  const contr = new ethers.Contract(questAddress, questAbi, signer);
  const a = await contr.getTimeOfCompletion(member, questId);
  console.log(a);
}


async function canJoin(daoAddress, member, role) {
  const contr = new ethers.Contract(daoAddress, autDAOAbi, signer);
  const a = await contr.canJoin(member, role);
  console.log(a);
}

async function isOnboardingActive(onboardingAddress) {
  const contr = new ethers.Contract(onboardingAddress, onboardingAbi, signer);
  const a = await contr.isActive();
  console.log(a);
}

async function canJoin(daoAddress, member, role) {
  const contr = new ethers.Contract(daoAddress, autDAOAbi, signer);
  const a = await contr.canJoin(member, role);
  console.log(a);
}

async function getQuestById(questAddress, questId) {
    const contr = new ethers.Contract(questAddress, questAbi, signer);
  const a = await contr.getById(questId);
  // console.log(a);
  return a;
}


async function isOngoing(questAddress, questId) {
  const contr = new ethers.Contract(questAddress, questAbi, signer);
const a = await contr.isOngoing(questId);
console.log(a);
return a;
}


async function isPending(questAddress, questId) {
  const contr = new ethers.Contract(questAddress, questAbi, signer);
const a = await contr.isPending(questId);
console.log(a);
return a;
}


async function getQuestAddressByOnboarding(onboardingAddr) {
    const contr = new ethers.Contract(onboardingAddr, onboardingAbi, signer);
  const a = await contr.questsPlugin();
  console.log(a);
}

async function test() {

  const b = await provider.getBlock(35783110);
  console.log('current:', b.timestamp);
  // await getQuestAddressByOnboarding('0xc016Ae39DE9A9bb194d1B6b2DB4E98B0407669e2');
  const quest = await getQuestById('0x75a01Ba3E3D71F32981496C16a040865A02C2530', 1);
  // await isPending('0x75a01Ba3E3D71F32981496C16a040865A02C2530', 1);
  // await isOngoing('0x75a01Ba3E3D71F32981496C16a040865A02C2530', 1);
  console.log('start:  ', quest['startDate'].toString());
  // console.log(quest['durationInHours'].toString());
  console.log('end  :  ', +quest['startDate'].toString() + 2*3600);

  console.log(+quest['startDate'].toString() > b.timestamp);
  // await getSubmissionIdPerTaskAndUser('0xE951f9c7DE2ca53f187deE7628B5fa90259E34c0', 6, '0x257a674aC62296326d78e6260571A077Ea4bF81b')
  // await finalize('0x8ED093b0e09F06f120f7FF2BA39F1ddfF73Ded59', 1, '0x0d6d3183697aA153d7861B137b9cc13757f25C87')
  // await getStatusPerSubmitter('0xadA9D147b4857f00BE52Df72463E4A90112f938F', 2, '0xE79A5fbc800ABA2074b0e54c68e51a5F6a38E07e')
  // await isOnboarded('0x9b9B04dca2E1d318fb92DFc5769FF50Ecdc43f23','0x8B5F0fBaaa1C41C0759eae5cCf77f62e4ea3D64f', 1);
  // await isOnboarded('0x9b9B04dca2E1d318fb92DFc5769FF50Ecdc43f23','0x8B5F0fBaaa1C41C0759eae5cCf77f62e4ea3D64f', 2);
  // await isOnboarded('0x9b9B04dca2E1d318fb92DFc5769FF50Ecdc43f23','0x8B5F0fBaaa1C41C0759eae5cCf77f62e4ea3D64f', 3);

  // await canJoin('0x86DB01dc85CCEF14b74C7863835fdFbd5485FA16','0x8B5F0fBaaa1C41C0759eae5cCf77f62e4ea3D64f', 1);
  // await canJoin('0x86DB01dc85CCEF14b74C7863835fdFbd5485FA16','0x8B5F0fBaaa1C41C0759eae5cCf77f62e4ea3D64f', 2);
  // await canJoin('0x86DB01dc85CCEF14b74C7863835fdFbd5485FA16','0x8B5F0fBaaa1C41C0759eae5cCf77f62e4ea3D64f', 3);

  // await isOnboarded('0x9b9B04dca2E1d318fb92DFc5769FF50Ecdc43f23','0x8B5F0fBaaa1C41C0759eae5cCf77f62e4ea3D64f', 2);
  // await isOnboardingActive('0x9b9B04dca2E1d318fb92DFc5769FF50Ecdc43f23');
  // const task = await getTaskByID('0x1492Cde3d2Bfbf60909542DBFcF3d5C4a4A2454f', 1);
  // console.log(task['startDate'].toString());
  // console.log(task['endDate'].toString());


  // const quest = '0x9A934A05720231a40a35C8871f9186C2aBE93dC9'
  // const id = 3;
  // const user = '0x2d41B96735108e4EF8B2C5C6e9eFfA425Cb7f6dF';

  // canJoin('0x86DB01dc85CCEF14b74C7863835fdFbd5485FA16', '0xFdbe9337b9Ac9E2E419f21C766cb108dDa7cB394', 1);
  // await hasCompletedAQuest(quest, user, id);

  // await getTimeOfCompletion(quest, user, 1);
  // await getTimeOfCompletion(quest, user, 2);
  // await getTimeOfCompletion(quest, user, 3);
  // await getCompletionTime('0xadA9D147b4857f00BE52Df72463E4A90112f938F', 2, '0xE79A5fbc800ABA2074b0e54c68e51a5F6a38E07e')
  // await getSubmissionIdPerTaskAndUser('0x8ED093b0e09F06f120f7FF2BA39F1ddfF73Ded59', 1, '0x0d6d3183697aA153d7861B137b9cc13757f25C87')
  // await getSubmissionIdPerTaskAndUser('0x8ED093b0e09F06f120f7FF2BA39F1ddfF73Ded59', 1, '0x2d41B96735108e4EF8B2C5C6e9eFfA425Cb7f6dF');
  // await getSubmissionIdPerTaskAndUser('0xE951f9c7DE2ca53f187deE7628B5fa90259E34c0', 3, '0x257a674aC62296326d78e6260571A077Ea4bF81b')
  // setOffchainVerifierAddress('0xb49CB4361A9314d6cA676CE259E6D8857DC66c5f','0xa5332a8BFeaff6AD8c195A3EC55F46a028ca02cC')
  // await addMember('0x6706a83EF8E2228D639fBA5f6cc5308d6A6114Bd', signer.address);

  // await deployDAOExpander();
  // const daoExpander = "0xCe050Ee1166D15a16B173Bed3b2Ebb856c67Ac27";
  // await getAutIDUsername('Taualnt');
  // await getAutIDMetadata(2);
  // await getPoll(pollsAddress, 0);
  // await createPoll(pollsAddress, 0, timestamp, 'bafkreibcuujzwl7hzd6uwi5t5zajur2tkdu2nhyouqvccd4oak3hyhijgy')
  // await addMember(daoAddr, '0x720Db641247BAacf528c696518C28153eB0E1100');
  // await getAutIDAddrForComExt(daoExpander);
  // await depl(1, '0x73297cb191a7f510C440a1Ce64Cb2E1b18753409')
  // await passOnboarding(daoExpander, '0x7660aa261d27A2A32d4e7e605C1bc2BA515E5f81');
  // await getComData(daoExpander);
  // const community = '0x96dCCC06b1729CD8ccFe849CE9cA7e020e19515c';
  // await getCommunityData(user, daoExpander);
  // await getComData(daoExpander)
  // await getSWMetadata(0);
  // await createCommunity(1, "0x7DeF7A0C6553B9f7993a131b5e30AB59386837E0");
  // await mint(daoExpander);
  // await isAdmin(daoExpander, user);
  // await getDAOExpanders();
  // await getDAOMetadata(daoExpander);
}

test();
