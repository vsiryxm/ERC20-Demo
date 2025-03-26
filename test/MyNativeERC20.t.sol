// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {MyNativeERC20} from "../src/MyNativeERC20.sol";

/**
 * @title MyNativeERC20测试合约
 * @dev 测试原生ERC20代币合约的所有核心功能
 */
contract MyNativeERC20Test is Test {
    // 测试参数
    string constant TOKEN_NAME = "My Native Token";
    string constant TOKEN_SYMBOL = "MNT";
    uint8 constant TOKEN_DECIMALS = 18;
    uint256 constant INITIAL_SUPPLY = 1000000; // 100万代币（未考虑小数位数）

    // 测试账户
    address deployer;
    address user1;
    address user2;

    // 合约实例
    MyNativeERC20 token;

    // 设置测试环境
    function setUp() public {
        // 设置测试账户
        deployer = address(this); // 测试合约作为部署者
        user1 = address(0x1);
        user2 = address(0x2);

        // 给测试账户一些ETH
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);

        // 部署合约
        token = new MyNativeERC20(
            TOKEN_NAME,
            TOKEN_SYMBOL,
            TOKEN_DECIMALS,
            INITIAL_SUPPLY
        );
    }

    // 测试代币基本信息
    function testTokenInfo() public {
        assertEq(token.name(), TOKEN_NAME, "Token name should match");
        assertEq(token.symbol(), TOKEN_SYMBOL, "Token symbol should match");
        assertEq(token.decimals(), TOKEN_DECIMALS, "Token decimals should match");
        
        // 检查初始供应量（考虑小数位数）
        uint256 expectedSupply = INITIAL_SUPPLY * 10**uint256(TOKEN_DECIMALS);
        assertEq(token.totalSupply(), expectedSupply, "Total supply should match");
        
        // 检查部署者余额
        assertEq(token.balanceOf(deployer), expectedSupply, "Deployer balance should match total supply");
    }

    // 测试转账功能
    function testTransfer() public {
        uint256 amount = 1000 * 10**uint256(TOKEN_DECIMALS);
        
        // 记录转账前的余额
        uint256 deployerBalanceBefore = token.balanceOf(deployer);
        uint256 user1BalanceBefore = token.balanceOf(user1);
        
        // 执行转账
        bool success = token.transfer(user1, amount);
        
        // 验证转账结果
        assertTrue(success, "Transfer should succeed");
        assertEq(token.balanceOf(deployer), deployerBalanceBefore - amount, "Deployer balance should decrease");
        assertEq(token.balanceOf(user1), user1BalanceBefore + amount, "User1 balance should increase");
    }

    // 测试转账失败情况（余额不足）
    function testTransferInsufficientBalance() public {
        uint256 deployerBalance = token.balanceOf(deployer);
        uint256 excessAmount = deployerBalance + 1;
        
        // 预期转账会失败
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        token.transfer(user1, excessAmount);
    }

    // 测试转账到零地址失败
    function testTransferToZeroAddress() public {
        uint256 amount = 1000 * 10**uint256(TOKEN_DECIMALS);
        
        // 预期转账到零地址会失败
        vm.expectRevert("ERC20: transfer to the zero address");
        token.transfer(address(0), amount);
    }

    // 测试授权功能
    function testApprove() public {
        uint256 amount = 1000 * 10**uint256(TOKEN_DECIMALS);
        
        // 执行授权
        bool success = token.approve(user1, amount);
        
        // 验证授权结果
        assertTrue(success, "Approve should succeed");
        assertEq(token.allowance(deployer, user1), amount, "Allowance should match approved amount");
    }

    // 测试授权到零地址失败
    function testApproveToZeroAddress() public {
        uint256 amount = 1000 * 10**uint256(TOKEN_DECIMALS);
        
        // 预期授权到零地址会失败
        vm.expectRevert("ERC20: approve to the zero address");
        token.approve(address(0), amount);
    }

    // 测试授权转账功能
    function testTransferFrom() public {
        uint256 amount = 1000 * 10**uint256(TOKEN_DECIMALS);
        
        // 部署者授权user1可以转移代币
        token.approve(user1, amount);
        
        // 记录转账前的余额
        uint256 deployerBalanceBefore = token.balanceOf(deployer);
        uint256 user2BalanceBefore = token.balanceOf(user2);
        
        // 切换到user1身份执行授权转账
        vm.prank(user1);
        bool success = token.transferFrom(deployer, user2, amount);
        
        // 验证授权转账结果
        assertTrue(success, "TransferFrom should succeed");
        assertEq(token.balanceOf(deployer), deployerBalanceBefore - amount, "Deployer balance should decrease");
        assertEq(token.balanceOf(user2), user2BalanceBefore + amount, "User2 balance should increase");
        assertEq(token.allowance(deployer, user1), 0, "Allowance should be reduced to zero");
    }

    // 测试授权转账失败情况（授权额度不足）
    function testTransferFromInsufficientAllowance() public {
        uint256 amount = 1000 * 10**uint256(TOKEN_DECIMALS);
        uint256 excessAmount = amount + 1;
        
        // 部署者授权user1可以转移代币
        token.approve(user1, amount);
        
        // 切换到user1身份尝试转移超过授权额度的代币
        vm.prank(user1);
        vm.expectRevert("ERC20: transfer amount exceeds allowance");
        token.transferFrom(deployer, user2, excessAmount);
    }

    // 测试增加授权额度功能
    function testIncreaseAllowance() public {
        uint256 initialAmount = 1000 * 10**uint256(TOKEN_DECIMALS);
        uint256 increaseAmount = 500 * 10**uint256(TOKEN_DECIMALS);
        
        // 初始授权
        token.approve(user1, initialAmount);
        
        // 增加授权额度
        bool success = token.increaseAllowance(user1, increaseAmount);
        
        // 验证结果
        assertTrue(success, "IncreaseAllowance should succeed");
        assertEq(token.allowance(deployer, user1), initialAmount + increaseAmount, "Allowance should be increased");
    }

    // 测试减少授权额度功能
    function testDecreaseAllowance() public {
        uint256 initialAmount = 1000 * 10**uint256(TOKEN_DECIMALS);
        uint256 decreaseAmount = 500 * 10**uint256(TOKEN_DECIMALS);
        
        // 初始授权
        token.approve(user1, initialAmount);
        
        // 减少授权额度
        bool success = token.decreaseAllowance(user1, decreaseAmount);
        
        // 验证结果
        assertTrue(success, "DecreaseAllowance should succeed");
        assertEq(token.allowance(deployer, user1), initialAmount - decreaseAmount, "Allowance should be decreased");
    }

    // 测试减少授权额度失败情况（减少金额超过当前授权额度）
    function testDecreaseAllowanceBelowZero() public {
        uint256 initialAmount = 1000 * 10**uint256(TOKEN_DECIMALS);
        uint256 excessAmount = initialAmount + 1;
        
        // 初始授权
        token.approve(user1, initialAmount);
        
        // 尝试减少超过当前授权额度的金额
        vm.expectRevert("ERC20: decreased allowance below zero");
        token.decreaseAllowance(user1, excessAmount);
    }

    // 测试铸造功能
    function testMint() public {
        uint256 mintAmount = 1000 * 10**uint256(TOKEN_DECIMALS);
        
        // 记录铸造前的总供应量和用户余额
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 user1BalanceBefore = token.balanceOf(user1);
        
        // 铸造代币给user1
        token.mint(user1, mintAmount);
        
        // 验证铸造结果
        assertEq(token.totalSupply(), totalSupplyBefore + mintAmount, "Total supply should increase");
        assertEq(token.balanceOf(user1), user1BalanceBefore + mintAmount, "User1 balance should increase");
    }

    // 测试铸造到零地址失败
    function testMintToZeroAddress() public {
        uint256 mintAmount = 1000 * 10**uint256(TOKEN_DECIMALS);
        
        // 预期铸造到零地址会失败
        vm.expectRevert("ERC20: mint to the zero address");
        token.mint(address(0), mintAmount);
    }

    // 测试销毁功能
    function testBurn() public {
        // 先转一些代币给user1
        uint256 transferAmount = 1000 * 10**uint256(TOKEN_DECIMALS);
        token.transfer(user1, transferAmount);
        
        // 设置要销毁的金额
        uint256 burnAmount = 500 * 10**uint256(TOKEN_DECIMALS);
        
        // 记录销毁前的总供应量和用户余额
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 user1BalanceBefore = token.balanceOf(user1);
        
        // 切换到user1身份销毁代币
        vm.prank(user1);
        token.burn(burnAmount);
        
        // 验证销毁结果
        assertEq(token.totalSupply(), totalSupplyBefore - burnAmount, "Total supply should decrease");
        assertEq(token.balanceOf(user1), user1BalanceBefore - burnAmount, "User1 balance should decrease");
    }

    // 测试销毁失败情况（余额不足）
    function testBurnInsufficientBalance() public {
        // 获取user1当前余额
        uint256 user1Balance = token.balanceOf(user1);
        uint256 excessAmount = user1Balance + 1;
        
        // 切换到user1身份尝试销毁超过余额的代币
        vm.prank(user1);
        vm.expectRevert("ERC20: burn amount exceeds balance");
        token.burn(excessAmount);
    }

    // 测试事件触发
    function testTransferEvent() public {
        uint256 amount = 1000 * 10**uint256(TOKEN_DECIMALS);
        
        // 预期会触发Transfer事件
        vm.expectEmit(true, true, false, true);
        emit MyNativeERC20.Transfer(deployer, user1, amount);
        
        // 执行转账
        token.transfer(user1, amount);
    }

    // 测试授权事件触发
    function testApprovalEvent() public {
        uint256 amount = 1000 * 10**uint256(TOKEN_DECIMALS);
        
        // 预期会触发Approval事件
        vm.expectEmit(true, true, false, true);
        emit MyNativeERC20.Approval(deployer, user1, amount);
        
        // 执行授权
        token.approve(user1, amount);
    }
}