// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

/// Fork tests across several chains in ONE `forge test` invocation.
contract MultichainForkTest is Test {
    function test_sepolia() public {
        vm.createSelectFork("sepolia");
        _check();
    }

    function test_monadTestnet() public {
        vm.createSelectFork("monad_testnet");
        _check();
    }

    function _check() internal {
        Counter counter = new Counter();
        counter.increment();
        assertEq(counter.number(), 1);
    }
}
