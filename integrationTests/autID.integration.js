const autIDAddress = "0x2ECefB89d166560d514B9dD3E84B1Dfec33A958B";
const daoExpanderRegistryAddress = "0xeBDf871b95E2C62B2d297591d52FeC29a187f87c";

const comMetadata =
  "bafkreidjy6xlyf2he4iopzijy7bws3yl34xhwh726ca2xd7temqoqkz6xy";
const { assert } = require("chai");
var ethers = require("ethers");

require("dotenv").config();

var autIDAbi = require("../artifacts/contracts/AutID.sol/AutID.json").abi;

var daoExpanderRegistryAbi =
  require("../artifacts/contracts/DAOExpanderRegistry.sol/DAOExpanderRegistry.json").abi;

var daoExpanderAbi =
  require("../artifacts/contracts/DAOExpander.sol/DAOExpander.json").abi;

var swLegacyDAOAbi =
  require("../artifacts/contracts/mocks/SWLegacyDAO.sol/SWLegacyDAO.json").abi;
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
console.log(signer.address)
// const wallet = ethers.Wallet.createRandom();
// console.log(signer.address);
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
    'migrenaa',
    "bafkreigigsavco2dtgcg6ehmunu5cjzr7xiarsrxm6bfw5m5wpor5rfpoi",
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

async function isCoreTeam(daoExpander, user) {
  const daoExpanderContract = new ethers.Contract(
    daoExpander,
    daoExpanderAbi,
    signer
  );

  const isCoreTeam = await daoExpanderContract.isCoreTeam(user);
  console.log('isCoreTeam', isCoreTeam);
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
  const c = new ethers.Contract(swLegacyDAO, swLegacyCommunityAbi, signer);
  const a = await c.addMember(member);
  console.log(a);
}

async function getAutIDAddrFrinDAOExpander(daoExpander) {
  const daoExpanderContract = new ethers.Contract(daoExpander, daoExpanderRegistryAbi, signer);
  const addr = await daoExpanderContract.autIDAddr();
  console.log('[getAutIDAddrFrinDAOExpander]: addr', addr);
}

async function getAutIDUsername(username) {
  const addr = await autIDContract.autIDUsername(username);
  console.log('[autIDUsername]: addr', addr);
}
async function test() {
  const daoExpander = "0xEf300E25897343e8d2d4b55F7b606fc90958beB0";
  const daoAddr = '0x3Dcf2c5D8b8997A3E5740DC8507Ed4E5533Dde14'
  const user = "0x1d6571bcCEa66F624d1232c63195D7E9708A0BB4";
  await getAutIDUsername('Taualnt');
  await getAutIDMetadata(4);
  // await getPoll(pollsAddress, 0);
  // await createPoll(pollsAddress, 0, timestamp, 'bafkreibcuujzwl7hzd6uwi5t5zajur2tkdu2nhyouqvccd4oak3hyhijgy')
  // await addMember('0x3Dcf2c5D8b8997A3E5740DC8507Ed4E5533Dde14', signer.address);
  // await addMember(daoAddr, '0x720Db641247BAacf528c696518C28153eB0E1100');
  // await getAutIDAddrForComExt(daoExpander);
  // await createCommunity(1, '0x73297cb191a7f510C440a1Ce64Cb2E1b18753409')
  // await passOnboarding(daoExpander, '0x7660aa261d27A2A32d4e7e605C1bc2BA515E5f81');
  // await getCommunities();
  // await getComData(daoExpander);
  // const community = '0x96dCCC06b1729CD8ccFe849CE9cA7e020e19515c';
  // await getCommunityData(user, daoExpander);
  // await getComData(daoExpander)
  // await getSWMetadata(0);
  // await createCommunity(1, "0x7DeF7A0C6553B9f7993a131b5e30AB59386837E0");
  // await getCommunities();
  // await mint(daoExpander);
  // await getCommunities();
  // await isCoreTeam(daoExpander, user);
}

test();
