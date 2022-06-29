// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const AutID = await hre.ethers.getContractFactory("AutID");
  const autID = AutID.attach('0x96e7341457e4dDd57003178951A9d41A2a828676');
  const communityExtension = '0x75878b9701308470296cD69b734fa8b2f4303f5e';
  const a = await autID.mint(
    'migrenaa',
    'https://drive.google.com/file/d/1h8Yup0aGQsS3DcMkoYmSfWy-WrLULHm6/view?usp=sharing',
    1,
    7,
    communityExtension,
    {
      gasLimit:1000000
    }
  )
  
  console.log(a);
  const b = await a.wait();
  console.log(b);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
