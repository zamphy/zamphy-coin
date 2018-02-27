pragma solidity ^0.4.18;
//0x59964B11Fe30497b78C0b280Ef6b5efEB35BEe65
import "./ZamphyToken.sol";
import "./SafeMath.sol";

contract ZamphyICO is SafeMath {

    /*
     * External contracts
     */
    ZamphyToken public zamphyToken;

    // Address of the founder of Zamphy.
    address public founder = 0x5b1a7d6712458798d48c581C07c30Da8045255Bb;

    // Address where all tokens created during ICO stage initially allocated
    address public ICOFounder = 0x5b1a7d6712458798d48c581C07c30Da8045255Bb;

    // Start date of the ICO
    uint public startDate = 1517443201;  // 2018-02-01 00:00:01 UTC

    // End date of the ICO
    uint public endDate = 1522108799;  // 2018-03-27 23:59:50 UTC

    // Token price without discount during the ICO stage
    uint public baseTokenPrice = 10000000; // 0.001 ETH, considering 8 decimal places

    // Number of tokens distributed to investors
    uint public tokensDistributed = 0;

    

    /*
     *  Modifiers
     */
    modifier onlyFounder() {
        // Only founder is allowed to do this action.
        if (msg.sender != founder) {
            throw;
        }
        _;
    }

    modifier minInvestment(uint investment) {
        // User has to send at least the ether value of one token.
    if (investment < baseTokenPrice) {
            throw;
        }
        _;
    }

    /// @dev Returns current bonus
    function getCurrentBonus()
        public
        constant
        returns (uint)
    {
        return getBonus(now);
    }

    /// @dev Returns bonus for the specific moment
    /// @param timestamp Time of investment (in seconds)
    function getBonus(uint timestamp)
        public
        constant
        returns (uint)
    {   
        return 1000; // 0%
        // if (timestamp > endDate) {
        //     throw;
        // }

        // if (startDate > timestamp) {
        //     return 1499;  // 49.9%
        // }

        // uint icoDuration = timestamp - startDate;
        // if (icoDuration >= 16 days) {
        //     return 1000;  // 0%
        // } else if (icoDuration >= 9 days) {
        //     return 1125;  // 12.5%
        // } else if (icoDuration >= 2 days) {
        //     return 1250;  // 25%
        // } else {
        //     return 1499;  // 49.9%
        // }
    }

    function calculateTokens(uint investment, uint timestamp)
        public
        constant
        returns (uint)
    {
        // calculate discountedPrice
        uint discountedPrice = div(mul(baseTokenPrice, 1000), getBonus(timestamp));

        // Token count is rounded down. Sent ETH should be multiples of baseTokenPrice.
        return div(investment, discountedPrice);
    }


    /// @dev Issues tokens for users who made BTC purchases.
    /// @param beneficiary Address the tokens will be issued to.
    /// @param investment Invested amount in Wei
    /// @param timestamp Time of investment (in seconds)
    function fixInvestment(address beneficiary, uint investment, uint timestamp)
        external
        onlyFounder
        minInvestment(investment)
        returns (uint)
    {   

        // Calculate number of tokens to mint
        uint tokenCount = calculateTokens(investment, timestamp);

        // Update fund's and user's balance and total supply of tokens.
        tokensDistributed = add(tokensDistributed, tokenCount);

        // Distribute tokens.
        if (!zamphyToken.transferFrom(ICOFounder, beneficiary, tokenCount)) {
            // Tokens could not be issued.
            throw;
        }

        return tokenCount;
    }

    /// @dev Contract constructor
    function ZamphyICO(address tokenAddress, address founderAddress) {
        // Set token address
        zamphyToken = ZamphyToken(tokenAddress);

        // Set founder address
        founder = founderAddress;
    }

    /// @dev Fallback function
    function () payable {
        throw;
    }
}
