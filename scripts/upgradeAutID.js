const { ethers, upgrades } = require('hardhat');

async function main () {
    console.log(await ethers.provider.getBlockNumber())

  const autIDAddressMumbai = ''
  const autIDAddressGoerli = ''
  const AutID = await ethers.getContractFactory('AutID');
  console.log('Upgrading AutID...');
  await upgrades.upgradeProxy(autIDAddressGoerli, AutID, {
    initializer: 'initialize'
});
  console.log('AutID upgraded');
}


main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
