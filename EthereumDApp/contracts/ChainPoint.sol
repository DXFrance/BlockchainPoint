pragma solidity ^0.4.15;

import "../contracts/Helpers.sol";

contract ChainPoint {

  // Structure for a checkpoint
  struct CheckPoint {
    string username;
    uint date;
    bool step1;
    bool step2;
  }

  // Map userid (GUID) to checkpoint struct
  mapping (string => CheckPoint) checkpoints;

  mapping (uint => string) userids;
  
  // Events
  event CheckPointAchieved(string userid, string username, uint step);
  event JourneyAchieved(string userid, string username);

  address public creator;
  uint public usersnumber = 0;
 
  //ctor
  function ChainPoint() {
   creator = msg.sender;
  }

  function kill() {
    selfdestruct(creator);
  }

  // Add a checkpoint
 function check(string userid, string username, uint step) public returns (bytes32) {
 
    //bytes32 returnuserid = keccak256("abc");
    bytes32 returnuserid = Helpers.stringToBytes32(userid);

    // Store checkpoint
    if (checkpoints[userid].date == 0) {
      checkpoints[userid] = CheckPoint(username, now, false, false);
      userids[usersnumber] = userid;
      usersnumber = usersnumber + 1;
    }

    if (step == 0) 
      checkpoints[userid].step1 = true;
    if (step == 1) 
      checkpoints[userid].step2 = true;

    // Send event for the checkpoint
    CheckPointAchieved(userid, username, step);

    // Check if all steps done
    if (checkpoints[userid].step1 &&
      checkpoints[userid].step2)  {
        // Check event for the end of journey
        JourneyAchieved(userid, username);
      }

   return returnuserid;
  }

  // Just for testing

  function getCheckDate(string userid) returns (uint date) {
    return checkpoints[userid].date;
  }
  
  function getCheckedUsersNumber() public returns (uint) {
    return usersnumber;
  }

  function getCheckedUser(uint usernumber) public returns (bytes32) {

    bytes32 returnuserid = Helpers.stringToBytes32(userids[usernumber]);

    return returnuserid;
  }
}