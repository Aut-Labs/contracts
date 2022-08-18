# Āut Protocol - Smart Contracts
Āut is an expandable protocol for Role-based Membership in Web3 Communities & DAOs.

DAOs can be much more than _Smart Treasuries_, Āut introduces native Roles & Interactions directly at contract level, to power the 2nd generation of DAOs. The DAO 2.0s, or a Coordination Renaissance.

To read more about Āut, visit our [Docs](https://docs.aut.id).
Below, you'll find a simple walkthrough to get started using Āut's Smart Contracts.

# Setup 

1. Create .env file and put your testing private key there
    ```
    PRIVATE_KEY='your_private_key'
    ```

2. Install dependencies
`npm install`

3. Compile the smart contracts 
`npm run compile`

4. In a separate terminal (optional)
`npx hardhat node`

5. Run tests (optional)
`npm run test`

You're ready to go! 🚀🚀🚀

> **_Recommendation:_** If you're building on top of the Aut Protocol Contracts, we strongly recommend running them locally and testing on Hardhat Network/Ganache Network before moving forward with a testnet deployment.
----
> > **_Resources:_** 🍫 🍫 🍫 Ganachere sources: https://trufflesuite.com/docs/ganache/
🎩 🎩 🎩 Hardhat sources: https://hardhat.org/tutorial

# Deployments (locally or not)

1. Select your desired network in hardhat.config.json under default network
2. Run `npm run deployAutID` and store the output address of AutID 
2. Run `npm run deployDAOExpanderFactory` and store the output address of DAOExpanderFactory
3. Run `npm run deployDAOTypes` and store the addresses DAO Types of all the Checkers and Types
4. Deploy DAOExpanerRegistry:  
    4.1. Replace autIDAddr, daoTypesAddr and daoExpanderFactoryAddr in deployDAOExpanderRegistry.js 
    4.2. Run `npm run deployDAOExpanderRegistry`
    
> **_Tip:_** If you're expanding the DAO Types that the product supports, for testing purposes, you can add it to /scripts/deployDAOTypes.js

``` javascript
  const YourMembershipChecker = await hre.ethers.getContractFactory("YourMembershipChecker");
  const yourMembershipChecker = await YourMembershipChecker.deploy();
  await yourMembershipChecker.deployed();
  
  await (await daoTypes.addNewMembershipChecker(yourMembershipChecker.address)).wait();
```

----
Happy hacking on āut contracts 🤓 🤓 🤓 !! 
 
## Useful commands
```shell
npm run compile
npm run test
npx hardhat clean
npx hardhat accounts
npx hardhat compile
npx hardhat node
npx hardhat help
```
