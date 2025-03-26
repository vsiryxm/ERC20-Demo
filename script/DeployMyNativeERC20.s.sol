// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {MyNativeERC20} from "../src/MyNativeERC20.sol";

/**
 * @title MyNativeERC20部署脚本
 * @dev 用于部署MyNativeERC20合约的脚本
 */
contract DeployMyNativeERC20Script is Script {
    // 部署参数
    string public constant TOKEN_NAME = "My Native Token";
    string public constant TOKEN_SYMBOL = "MNT";
    uint8 public constant TOKEN_DECIMALS = 18;
    uint256 public constant INITIAL_SUPPLY = 1000000; // 100万代币（未考虑小数位数）

    MyNativeERC20 public token;

    function setUp() public {}

    function run() public {
        // 获取部署者私钥
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // 如果没有设置环境变量，使用默认的Anvil私钥
        if (deployerPrivateKey == 0) {
            deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        }

        // 开始广播交易
        vm.startBroadcast(deployerPrivateKey);

        // 部署合约
        token = new MyNativeERC20(
            TOKEN_NAME,
            TOKEN_SYMBOL,
            TOKEN_DECIMALS,
            INITIAL_SUPPLY
        );

        // 输出部署信息
        console.log("MyNativeERC20 deployed at:", address(token));
        console.log("Token Name:", token.name());
        console.log("Token Symbol:", token.symbol());
        console.log("Token Decimals:", token.decimals());
        console.log("Total Supply:", token.totalSupply());

        // 停止广播交易
        vm.stopBroadcast();
    }
}