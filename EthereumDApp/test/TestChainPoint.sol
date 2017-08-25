pragma solidity ^0.4.15;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/ChainPoint.sol";
import "../contracts/Helpers.sol";

contract TestChainPoint {

    function testCheckUsingDeployedContract() {
      ChainPoint instance = ChainPoint(DeployedAddresses.ChainPoint());

      var userid = "0F623638-9B01-4ca6-A553-72709801DB1C";
      var username = "scott";
      var expected = Helpers.stringToBytes32(userid);

      var returnUserid = instance.check(userid, username, 0);

      Assert.equal(returnUserid, expected, "userid was wrongly returned");
    }

    function testCheckPointDateUsingDeployedContract() {
    ChainPoint instance = ChainPoint(DeployedAddresses.ChainPoint());

    var userid = "0F623638-9B01-4ca6-A553-72709801DB1C";
    var username = "scott";
    
    instance.check(userid, username, 0);
    var checkpointdate = instance.getCheckDate(userid);

    Assert.notEqual(checkpointdate, 0, "checkDate was not correctly set");
  }

  function testGetCheckedUsersNumberUsingDeployedContract() {
    ChainPoint instance = ChainPoint(DeployedAddresses.ChainPoint());

    var userid = "0F623638-9B01-4ca6-A553-72709801DB1C";
    var username = "scott";
    
    instance.check(userid, username, 0);

    var usersNumber = instance.getCheckedUsersNumber();

    Assert.notEqual(usersNumber, 0, "usersNumber should not be null");
  }

  function testgetCheckedUserIdUsingDeployedContract() {
    ChainPoint instance = ChainPoint(DeployedAddresses.ChainPoint());
    
    var userid = "0F623638-9B01-4ca6-A553-72709801DB1C";
    var username = "scott";
    var expected = Helpers.stringToBytes32(username);

    instance.check(userid, username, 0);
    var checkedUser = instance.getCheckedUser(0);

    Assert.notEqual(checkedUser, expected, "CheckedUsers was not correctly set");
  }
}