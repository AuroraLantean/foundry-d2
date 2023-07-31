// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "src/WETH.sol";
import "./Invariant_2.t.sol";

// Topics
// - Actor management... test multi user scenario

import {CommonBase} from "forge-std/Base.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {StdUtils} from "forge-std/StdUtils.sol";

// acting as multi users scenario
contract ActorManager is CommonBase, StdCheats, StdUtils {
    Handler[] public handlers;

    constructor(Handler[] memory _handlers) {
        handlers = _handlers;
    }

    function sendToFallback(uint256 handlerIndex, uint256 amount) public {
        uint256 index = bound(handlerIndex, 0, handlers.length - 1);
        handlers[index].sendToFallback(amount);
    }

    function deposit(uint256 handlerIndex, uint256 amount) public {
        uint256 index = bound(handlerIndex, 0, handlers.length - 1);
        handlers[index].deposit(amount);
    }

    function withdraw(uint256 handlerIndex, uint256 amount) public {
        uint256 index = bound(handlerIndex, 0, handlers.length - 1);
        handlers[index].withdraw(amount);
    }
}

contract WETH_Multi_Handler_Invariant_Tests is Test {
    WETH public weth;
    ActorManager public manager;
    Handler[] public handlers;

    function setUp() public {
        weth = new WETH();

        for (uint256 i = 0; i < 3; i++) {
            handlers.push(new Handler(weth));
            // Send 100 ETH to handler
            deal(address(handlers[i]), 100 * 1e18);
        }

        manager = new ActorManager(handlers);

        targetContract(address(manager));
    }

    function invariant_eth_balance() public {
        uint256 total = 0;
        for (uint256 i = 0; i < handlers.length; i++) {
            total += handlers[i].wethBalance();
            console.log("Handler num calls", i, handlers[i].numCalls());
        }
        console.log("ETH total from handlers:", total / 1e18);
        console.log("ETH in WETH:", address(weth).balance / 1e18);
        assertEq(address(weth).balance, total);
    }
}
