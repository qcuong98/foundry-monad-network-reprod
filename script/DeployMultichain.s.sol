// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Counter} from "../src/Counter.sol";

contract DeployMultichain is Script {
    /// Deploys to every chain from ONE `forge script` invocation.
    function run() public {
        deploy("sepolia");
        deploy("monad_testnet");
    }

    /// Deploys to a single chain (workaround: one invocation per network family).
    function deploy(string memory chain) public {
        vm.createSelectFork(chain);
        vm.startBroadcast();
        Counter counter = new Counter();
        vm.stopBroadcast();
        console.log(chain, address(counter));
    }
}
