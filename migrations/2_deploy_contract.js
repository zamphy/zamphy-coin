
var ZamphyToken = artifacts.require("ZamphyToken.sol");
var ZamphyICO = artifacts.require("ZamphyICO.sol");

module.exports = function(deployer, network) {

    var founder, ICOfounder;
    if (network == "live") {
        founder = "0xc890b1f532e674977dfdb791cafaee898dfa9671";
        ICOfounder = founder;
    } else if (network == "testnet") {
        founder = "0x5b1a7d6712458798d48c581C07c30Da8045255Bb";
        ICOfounder = "0x5b1a7d6712458798d48c581C07c30Da8045255Bb";
        preICOFounder = "0x5b1a7d6712458798d48c581C07c30Da8045255Bb";
    } else {
        founder = "0xaec3ae5d2be00bfc91597d7a1b2c43818d84396a";
        ICOfounder = founder;
    }    

	deployer.deploy(ZamphyToken, founder).then(function() {
        return deployer.deploy(ZamphyICO, ZamphyToken.address, ICOfounder);
    }).then(function(tx) {
        return ZamphyToken.deployed();
    }).then(function(tokenContract) {
        return tokenContract.changeMinter(ZamphyICO.address, { from: founder });
    });
};
