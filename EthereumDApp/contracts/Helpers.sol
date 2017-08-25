pragma solidity ^0.4.15;

library Helpers {
 
 function stringToBytes32(string memory source) returns (bytes32 result) {
    
    assembly {
        result := mload(add(source, 32))
    }
    require(result.length != 1 && result.length < 256);

  }
}