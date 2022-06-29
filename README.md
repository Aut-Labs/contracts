# AutID Smart Contracts

yada yada yada 

# Setup 

1. Create .env file and put your testing mnemonic there
    ```
    MNEMONIC='some mnemonic'
    ```

1. Install dependencies
`npm install`

2. Compile the smart contracts 
`npm run compile`

3. Run tests (optional)
`npm run test`

You're ready to go! 🚀🚀🚀

# Ganache local setup 🍫🍫🍫

## Prerequisites: 
1. Ganache installed :) 

## Setup: 

1. Run Ganache
2. Quickstart with Ethereum
3. Copy the mnemonic and put it your .env file
4. Put defaultNetwork in hardhat.config.js to be ganache
5. That's it 🚀🚀🚀 

Now all the queries and scripts you call are going to be to your Ganache network. 

## Deploy the contracts locally

1. Run `npm run deployMemTypes` and store the output address of MembershipTypes 
2. Run `npm run deployMembershipCheckers` and store the output address of MembershipTypes
3. Run `npm run deployAutID` and store the contract address from your console
4. Deploy Community Registry:  
    4.1. Replace membershipTypesAddr and autIDAddr in deployCommunityRegistry.sol 
    4.2. Run `npm run deployCommunityRegistry`
    

Happy hacking on AutID contracts 🤓 🤓 🤓 !! 
 
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
