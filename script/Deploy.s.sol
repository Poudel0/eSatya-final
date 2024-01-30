// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import "forge-std/Script.sol";
import"../src/eNRS.sol";
import"../src/eNRS_Engine.sol";


contract Deploy is Script {

    address constant PRICEFEED = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
   

   function  run() public returns(eNRS,eNRS_Engine) {
    vm.startBroadcast();
     eNRS enrs = new eNRS();
    eNRS_Engine engine = new eNRS_Engine(PRICEFEED,address(enrs));
        
    enrs.transferOwnership(address(engine));

    vm.stopBroadcast();
    return(enrs,engine);

   }
}

