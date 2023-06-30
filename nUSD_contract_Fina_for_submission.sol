// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/* **************** Notes ****************

   - We will be using the Sepolia Testnet
   - Total supply of nUSD tokens will be held by the contract address
   - All transactions will be done in wei. The contract will handle wei-ether conversion internally.
   - 1 ether = 1000000000000000000 wei (18 zeroes)
   - User should deposit amount in Wei, in positive integers only.
   - For all divisions and conversions, solidity by default generates only interger quotient, rounds down and ignores all decimals.
   - Floating point values will not be generated or accepted as input.
   - Little loss of value in tokens or ethers is possible due to this limitation.

   *************************************** */

contract nUSD {
    
    AggregatorV3Interface internal priceFeed;

    uint256 totalSupply = 1000; 
    string internal constant name = "nUSD";
    mapping(address => uint256) balances;

    // event Transfer(address indexed From, address indexed To, uint256 Value);
    event Deposit (uint256 Wei_Deposited, uint256 Current_Exhange_Rate, uint256 Tokens_Generated, address indexed User_Address);
    event Redeem (uint256 Collateral_Tokens, uint256 Tokens_Redeemed, uint256 Value_in_Wei, address indexed User_Address);

    // All transactions will be done in wei. The contract will handle wei-ether conversion internally.
    // 1 ether = 1000000000000000000 wei (18 zeroes)
    
    constructor() 
    {
        priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306); // ETH-USD exchange rate from Sepolia Testnet
        balances[address(this)] = totalSupply; // Total supply of tokens will be held by the contract address
    }

    receive () external payable {}      //Enables the contract to receive ether

    function TotalSupply() public view returns (uint256) 
    {
        return totalSupply;
    }

    function Unminted() public view returns (uint256) 
    {
        return balances[address(this)];
    }

    function BalanceOf(address tokenOwner) public view returns (uint256) 
    {
        return balances[tokenOwner];
    }

    function SendTokens(address sender, address receiver, uint256 numTokens) internal returns (bool) 
    {
        // Check token balance
        require(numTokens <= balances[sender], "Insufficient token balance");
        
        // Deduct tokens from sender account
        balances[sender] = balances[sender]-numTokens;
        
        // Add tokens to receiver account
        balances[receiver] = balances[receiver]+numTokens;
        
        //emit Transfer(sender, receiver, numTokens);
        return true;
    }

    // User should deposit amount in Wei, in positive integers only.
    // For all divisions and conversion, solidity by default generates only interger quotient, rounds down and ignores all decimals.
    // Floating point values will not be generated or accepted as input.

    function  deposit (uint256 amount) public payable returns (bool) 
    {
        require (amount > 1000000000000000, "You have to send more than 0.001 ethers.");
        require (amount == msg.value, "Please enter the amount in value section also.");

        // Fetch current exchange rate of ether from chainlink ;
        uint256 ex_rate = uint256 (getExchRate());

        // Convert wei amount to USD value
        uint256 exch_amount = (ex_rate * amount) / 1000000000000000000;
        
        // Calculate tokens
        uint256 numTokens =  exch_amount / 2 ; 

        // Transfer tokens from contract to user
        require((SendTokens(address(this), msg.sender, numTokens)), "Unable to generate tokens.");
        
        // Transfer Wei from user to contract in exchange for tokens
        payable(address(this)).transfer(amount);
        
        emit Deposit(amount, ex_rate, numTokens, msg.sender);
        return (true);
    }

    function getExchRate() public view returns (int) 
    {

        // Get current exchange rate from chainlink - Sepolia testnet
        (
            /*uint80 roundID */,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        
        // Price received with 8 decimal points, convert to actual USD value.
        int usd_price = price / 100000000;

        return (usd_price);
    }

    function redeem(uint256 numTokens) public payable returns (bool)
    {
        uint256 ex_rate = uint256(getExchRate());

        // Convert tokens into wei amount as per current exchange rate
        uint256 numWei = (numTokens * 2 * 1000000000000000000)/ ex_rate;

        // Calculate collateral token amount that should be available in the user account
        uint256 collateral = numTokens * 4;

        // Convert wei amount to eth
        // uint256 numEth = numWei/1000000000000000000;

        // Check if the user account has the required collateral
        require(BalanceOf(msg.sender) >= collateral, "Minimum collateral amount not available");

        // Transfer tokens from user account to contract
        require(SendTokens(msg.sender, address(this), numTokens),"Tokens were not redeemed");

        // Transfer tokens money to user account in Wei
        (payable(msg.sender)).transfer(numWei);
        
        emit Redeem (collateral, numTokens, numWei, msg.sender);
        return (true);

    }

}