var ConvertLib = artifacts.require("./ConvertLib.sol");
var Helpers = artifacts.require("./Helpers.sol");
var ChainPoint = artifacts.require("./ChainPoint.sol");

module.exports = function(deployer) {
  deployer.deploy(ConvertLib);
  deployer.deploy(Helpers);
  deployer.link(ConvertLib, ChainPoint);
  deployer.link(Helpers, ChainPoint);
  deployer.deploy(ChainPoint);
};