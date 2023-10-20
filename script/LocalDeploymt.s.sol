// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
/**
 * First, it collects all transactions from the script, and only then does it broadcast them all. It can essentially be split into 4 phases:
 * #1 Local Simulation - The contract script is run in a local evm. If a rpc/fork url has been provided, it will execute the script in that context. Any external call (not static, not internal) from a vm.broadcast and/or vm.startBroadcast will be appended to a list.
 *
 * #2 Onchain Simulation - Optional. If a rpc/fork url has been provided, then it will sequentially execute all the collected transactions from the previous phase here.
 *
 * #3 Broadcasting - Optional. If the --broadcast flag is provided and the previous phases have succeeded, it will broadcast the transactions collected at step 1. and simulated at step 2.
 *
 * #4 Verification - Optional. If the --verify flag is provided, there's an API key, and the previous phases have succeeded it will attempt to verify the contract. (eg. etherscan).
 *
 * # Supported RPC Methods
 *   https://book.getfoundry.sh/reference/anvil/
 */

import "src/ERC20Token.sol";
import "src/ERC721Token.sol";
import "src/ERC721Sales.sol";

contract AnvilDeploymtScript is Script {
    address public tis = address(this);
    uint256 public choice;
    string public url;
    uint256 public balcEthB4;
    uint256 public balcEthAf;
    uint256 public balcTokB4;
    uint256 public balcTokAf;
    uint256 public nftBalc;
    /**
     * For Arbitrum, convert some ETH into Arbitrum ETH:
     * https://bridge.arbitrum.io/?l2ChainId=421613
     * https://goerli.arbiscan.io
     */

    function setUp() public {}

    //default function to run in scripts
    function run() public {
        url = vm.rpcUrl("sepolia"); //get the RPC_URL from foundry.toml: [rpc_endpoints]
        console.log("url:", url);
        /* url = vm.rpcUrl("optimism");
        console.log("url:", url);
        url = vm.rpcUrl("arbitrum");
        console.log("url:", url);
        */
        uint256 privateKey = vm.envUint("ANVIL_PRIVATE_KEY");
        address alice = vm.rememberKey(vm.envUint("ANVIL_PRIVATE_KEY"));
        //vm.envAddress("ANVIL_SIGNER");
        vm.startBroadcast(privateKey);
        //vm.broadcast();
        choice = 4;
        console.log("choice:", choice);
        if (choice == 0) {
            console.log("do nothing");
            //console2_log(p0, p1);
        } else if (choice == 1) {
            ERC20Token goldtoken = new ERC20Token("GoldCoin", "GOLC");
            console.log("GoldCoin addr:", address(goldtoken));
            balcTokB4 = goldtoken.balanceOf(alice);
            console.log("alice GoldCoin balc:", balcTokB4);
        } else if (choice == 2) {
            ERC721Token dragons = new ERC721Token("DragonsNFT", "DRAG");
            balcTokB4 = dragons.balanceOf(alice);
            console.log("alice NFT balc:", balcTokB4);
        } else if (choice == 3) {
            ERC20DP6 usdt = new ERC20DP6("TetherUSD", "USDT");
            console.log("USDT addr:", address(usdt));
            balcTokB4 = usdt.balanceOf(alice);
            console.log("alice USDT balc:", balcTokB4);
        } else if (choice == 4) {
            balcTokB4 = alice.balance;
            console.log("alice ETH balc:", balcTokB4, balcTokB4 / 1e18);

            ERC20DP6 usdt = new ERC20DP6("TetherUSD", "USDT");
            console.log("USDT addr:", address(usdt));
            balcTokB4 = usdt.balanceOf(alice);
            console.log("alice USDT balc:", balcTokB4, balcTokB4 / 1e6);

            ERC721Token dragons = new ERC721Token("DragonsNFT", "DRAG");
            console.log("DragonsNFT addr:", address(dragons));
            balcTokB4 = dragons.balanceOf(alice);
            console.log("alice NFT balc:", balcTokB4);

            uint256 priceInWeiEth = 1e18;
            uint256 priceInWeiToken = 100e6;
            //ERC721Sales _sales =
            ERC721Sales sales = new ERC721Sales(address(usdt), address(dragons), priceInWeiEth, priceInWeiToken);
            address salesAddr = address(sales);
            console.log("Sales addr:", salesAddr);

            dragons.safeTransferFromBatch(alice, salesAddr, 0, 9);
            nftBalc = dragons.balanceOf(salesAddr);
            console.log("Sales nftBalc:", nftBalc);
        }
        vm.stopBroadcast();
    }
}