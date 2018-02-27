pragma solidity ^0.4.18;
//0xA5B04Cbff6C4F69Ae34ee2B94385771a9905Bc59
import "./StandardToken.sol";
import "./SafeMath.sol";

contract ZamphyToken is StandardToken, SafeMath {

    /*
     * External contracts
     */
    address public minter;

    /*
     * Token meta data
     */
    string constant public name = "Zamphy";
    string constant public symbol = "ZAM";
    uint8 constant public decimals = 8;

    // Address of the founder of Zamphy.
    address public founder = 0x5b1a7d6712458798d48c581C07c30Da8045255Bb;

    // Multisig address of the founders
    address public multisig = 0x5b1a7d6712458798d48c581C07c30Da8045255Bb;

    // Address where all tokens created during ICO stage initially allocated
    address constant public allocationAddressICO = 0x5b1a7d6712458798d48c581C07c30Da8045255Bb;

    // Address where all tokens created during preICO stage initially allocated
    //address constant public allocationAddressPreICO = 0x5b1a7d6712458798d48c581C07c30Da8045255Bb;

    // address constant public allocationAddressMinigSupply = 0x5b1a7d6712458798d48c581C07c30Da8045255Bb;

    // address constant public allocationAddressReservedForPromoters = 0x5b1a7d6712458798d48c581C07c30Da8045255Bb;

    // 3780000 tokens during preICO  6%
    uint constant public preICOSupply = mul(3780000, 100000000);

    // 20790000 tokens during ICO   33%
    uint constant public ICOSupply = mul(20790000, 100000000);

    /// tokens during mining  45%
    uint constant public minigSupply = mul(28350000,100000000);

    //tokens reservedForPromoters 16%
    uint constant public reservedForPromoters = mul(10080000,100000000);

    // Max number of tokens that can be minted
    uint public maxTotalSupply = mul(63000000,100000000);

    /*
     * Modifiers
     */
    modifier onlyFounder() {
        // Only founder is allowed to do this action.
        if (msg.sender != founder) {
            throw;
        }
        _;
    }

    modifier onlyMinter() {
        // Only minter is allowed to proceed.
        if (msg.sender != minter) {
            throw;
        }
        _;
    }

    /*
     * Contract functions
     */

    /// @dev Crowdfunding contract issues new tokens for address. Returns success.
    /// @param _for Address of receiver.
    /// @param tokenCount Number of tokens to issue.
    function issueTokens(address _for, uint tokenCount)
        external
        payable
        onlyMinter
        returns (bool)
    {
        if (tokenCount == 0) {
            return false;
        }

        if (add(totalSupply, tokenCount) > maxTotalSupply) {
            throw;
        }

        totalSupply = add(totalSupply, tokenCount);
        balances[_for] = add(balances[_for], tokenCount);
        Issuance(_for, tokenCount);
        return true;
    }

    /// @dev Function to change address that is allowed to do emission.
    /// @param newAddress Address of new emission contract.
    function changeMinter(address newAddress)
        public
        onlyFounder
        returns (bool)
    {   
        // Forbid previous emission contract to distribute tokens minted during ICO stage
        delete allowed[allocationAddressICO][minter];

        minter = newAddress;

        // Allow emission contract to distribute tokens minted during ICO stage
        allowed[allocationAddressICO][minter] = balanceOf(allocationAddressICO);
    }

    /// @dev Function to change founder address.
    /// @param newAddress Address of new founder.
    function changeFounder(address newAddress)
        public
        onlyFounder
        returns (bool)
    {   
        founder = newAddress;
    }

    /// @dev Function to change multisig address.
    /// @param newAddress Address of new multisig.
    function changeMultisig(address newAddress)
        public
        onlyFounder
        returns (bool)
    {
        multisig = newAddress;
    }

    /// @dev Contract constructor function sets initial token balances.
    function ZamphyToken(address founderAddress)
    {   
        // Set founder address
        founder = founderAddress;

        // Allocate all created tokens during ICO stage to allocationAddressICO.
        // balances[allocationAddressICO] = ICOSupply;

        // Allocate all created tokens during preICO stage to allocationAddressPreICO.
        // balances[allocationAddressPreICO] = preICOSupply;

        //allocate total supply during mining
        // balances[allocationAddressMinigSupply] = minigSupply;

        //allocate total supply which is reservedForPromoters
        balances[founder] = maxTotalSupply;

        // Allow founder to distribute tokens during preICO stage
        // allowed[allocationAddressPreICO][founder] = preICOSupply;

        // Give 14 percent of all tokens to founders.
        // balances[multisig] = div(mul(ICOSupply, 14), 86);

        // Set correct totalSupply and limit maximum total supply.
        totalSupply = add(preICOSupply, ICOSupply);
        totalSupply = add(totalSupply, minigSupply);
        totalSupply = add(totalSupply, reservedForPromoters);
    }
}
