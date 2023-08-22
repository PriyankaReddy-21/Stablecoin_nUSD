# Stablecoin_nUSD
Implementation of stable coin named "nUSD" which is backed by Ethereum.

The task is to create a new stablecoin called nUSD. The stablecoin will be backed by ETH (similar to DAI). The primary goal of this project is to allow users to deposit ETH and receive 50% of its value in nUSD. Additionally, there will be a redeem function to convert nUSD back into either ETH. If 'n' number of coins are to be redeemed then following criteria should be satisfied - 
Minimum account balance >= 2 * current USD value of ETH * n  

Some important notes -

- We will be using the Sepolia Testnet and running the code on Remix IDE.
- Total supply of nUSD tokens will be held by the contract address
- All transactions will be done in wei. The contract will handle wei-ether conversion internally.
- 1 ether = 1000000000000000000 wei (18 zeroes)
- User should deposit amount in Wei, in positive integers only.
- For all divisions and conversions, solidity by default generates only interger quotient, rounds down and ignores all decimals.
- Floating point values will not be generated or accepted as input.
- Little loss of value in tokens or ethers is possible due to this limitation.
- The code runs flawlessly. In case you experience any glitch or system hang, it is usually due to Remix IDE. Please refresh Remix IDE and try again.

For complete test cases and results, please go through the PDF - " Test cases and results."
