pragma solidity ^0.4.18;
//0x2D8e35D0AaC632011D8432C0fB3A06f0D395f8f7
import "./ZamphyToken.sol";

/// @title ZamphyICO contract - Takes funds from users and issues tokens.

contract ZamphyPreICO {

    /*
     * External contracts
     */
    ZamphyToken public zamphyToken = ZamphyToken(0x0);

    /*
     * Crowdfunding parameters
     */
    // uint constant public CROWDFUNDING_PERIOD = 12 days;
    // Goal threshold, 10000 ETH
    // uint constant public CROWDSALE_TARGET = 10000 ether;

    /*
     *  Storage
     */
    address public founder;
    address public multisig;
    uint public startDate = 1516233601;
    uint public endDate = 1517443199;
    uint public icoBalance = 0;
    uint public baseTokenPrice = 1000000; 
    uint public discountedPrice = baseTokenPrice;
    bool public isICOActive = false;

    // participant address => value in Wei
    mapping (address => uint) public investments;

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

    modifier minInvestment() {
        // User has to send at least the ether value of one token.
        if (msg.value < baseTokenPrice) {
            throw;
        }
        _;
    }

    modifier icoActive() {
        if (isICOActive == false) {
            throw;
        }
        _;
    }

    modifier applyBonus() {
        uint icoDuration = now - startDate;
        if (icoDuration >= 248 hours) {
            discountedPrice = baseTokenPrice;
        }
        else if (icoDuration >= 176 hours) {
            discountedPrice = (baseTokenPrice * 100) / 107;
        }
        else if (icoDuration >= 104 hours) {
            discountedPrice = (baseTokenPrice * 100) / 120;
        }
        else if (icoDuration >= 32 hours) {
            discountedPrice = (baseTokenPrice * 100) / 142;
        }
        else if (icoDuration >= 12 hours) {
            discountedPrice = (baseTokenPrice * 100) / 150;
        }
        else {
            discountedPrice = (baseTokenPrice * 100) / 170;
        }
        _;
    }

    /// @dev Allows user to create tokens if token creation is still going
    /// and cap was not reached. Returns token count.
    function fund()
        public
        applyBonus
        icoActive
        minInvestment
        payable
        returns (uint)
    {
        // Token count is rounded down. Sent ETH should be multiples of baseTokenPrice.
        uint tokenCount = msg.value / discountedPrice;
        // Ether spent by user.
        uint investment = tokenCount * discountedPrice;
        // Send change back to user.
        if (msg.value > investment && !msg.sender.send(msg.value - investment)) {
            throw;
        }
        // Update fund's and user's balance and total supply of tokens.
        icoBalance += investment;
        investments[msg.sender] += investment;
        // Send funds to founders.
        if (!multisig.send(investment)) {
            // Could not send money
            throw;
        }
        if (!zamphyToken.issueTokens(msg.sender, tokenCount)) {
            // Tokens could not be issued.
            throw;
        }
        return tokenCount;
    }

    /// @dev Issues tokens for users who made BTC purchases.
    /// @param beneficiary Address the tokens will be issued to.
    /// @param _tokenCount Number of tokens to issue.
    function fundBTC(address beneficiary, uint _tokenCount)
        external
        applyBonus
        icoActive
        onlyFounder
        returns (uint)
    {
        // Approximate ether spent.
        uint investment = _tokenCount * discountedPrice;
        // Update fund's and user's balance and total supply of tokens.
        icoBalance += investment;
        investments[beneficiary] += investment;
        if (!zamphyToken.issueTokens(beneficiary, _tokenCount)) {
            // Tokens could not be issued.
            throw;
        }
        return _tokenCount;
    }

    
    /// @dev Contract constructor function sets founder and multisig addresses.
    function ZamphyICO(address _multisig) {
        // Set founder address
        founder = msg.sender;
        // Set multisig address
        multisig = _multisig;
    }

    /// @dev Fallback function. Calls fund() function to create tokens.
    function () payable {
        fund();
    }
}