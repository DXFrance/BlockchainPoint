var ConvertLib = artifacts.require("./ConvertLib.sol");
var ChainPoint = artifacts.require("./ChainPoint.sol");

module.exports = function(deployer) {
  deployer.deploy(ConvertLib);
  deployer.link(ConvertLib, ChainPoint);
  deployer.deploy(ChainPoint);
};
