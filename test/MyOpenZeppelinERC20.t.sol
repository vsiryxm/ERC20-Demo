// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {MyOpenZeppelinERC20} from "../src/MyOpenZeppelinERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title MyOpenZeppelinERC20测试合约
 * @dev 测试OpenZeppelin实现的ERC20代币合约的所有核心功能
 */
contract MyOpenZeppelinERC20Test is Test {
    // 测试参数
    string constant TOKEN_NAME = "My OpenZeppelin Token";
    string constant TOKEN_SYMBOL = "MOT";
    uint8 constant TOKEN_DECIMALS = 18;
    uint256 constant INITIAL_SUPPLY = 1000000; // 100万代币（未考虑小数位数）

    // 测试账户
    address owner;
    address user1;
    address user2;

    // 合约实例
    MyOpenZeppelinERC20 token;

    // 设置测试环境
    function setUp() public {
        // 设置测试账户
        owner = address(0x1234); // 设置一个特定的所有者地址
        user1 = address(0x1);
        user2 = address(0x2);

        // 给测试账户一些ETH
        vm.deal(owner, 10 ether);
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);

        // 部署合约，注意OpenZeppelin版本需要指定owner
        vm.prank(owner); // 确保部署者是owner
        token = new MyOpenZeppelinERC20(
            TOKEN_NAME,
            TOKEN_SYMBOL,
            TOKEN_DECIMALS,
            INITIAL_SUPPLY,
            owner
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
        
        // 检查所有者余额
        assertEq(token.balanceOf(owner), expectedSupply, "Owner balance should match total supply");
    }

    // 测试转账功能
    function testTransfer() public {
        uint256 amount = 1000 * 10**uint256(TOKEN_DECIMALS);
        
        // 记录转账前的余额
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        uint256 user1BalanceBefore = token.balanceOf(user1);
        
        // 切换到owner身份执行转账
        vm.prank(owner);
        token.transfer(user1, amount);
        
        // 验证转账结果
        assertEq(token.balanceOf(owner), ownerBalanceBefore - amount, "Owner balance should decrease");
        assertEq(token.balanceOf(user1), user1BalanceBefore + amount, "User1 balance should increase");
    }

    // 测试转账失败情况（余额不足）
    function testTransferInsufficientBalance() public {
        uint256 ownerBalance = token.balanceOf(owner);
        uint256 excessAmount = ownerBalance + 1;
        
        // 预期转账会失败
        vm.prank(owner);
        vm.expectRevert(abi.encodeWithSignature("ERC20InsufficientBalance(address,uint256,uint256)", owner, ownerBalance, excessAmount));
        token.transfer(user1, excessAmount);
    }

    // 测试转账到零地址失败
    function testTransferToZeroAddress() public {
        uint256 amount = 1000 * 10**uint256(TOKEN_DECIMALS);
        
        // 预期转账到零地址会失败
        vm.prank(owner);
        vm.expectRevert(abi.encodeWithSignature("ERC20InvalidReceiver(address)", address(0)));
        token.transfer(address(0), amount);
    }

    // 测试授权功能
    function testApprove() public {
        uint256 amount = 1000 * 10**uint256(TOKEN_DECIMALS);
        
        // 执行授权
        vm.prank(owner);
        token.approve(user1, amount);
        
        // 验证授权结果
        assertEq(token.allowance(owner, user1), amount, "Allowance should match approved amount");
    }

    // 测试授权到零地址失败
    function testApproveToZeroAddress() public {
        uint256 amount = 1000 * 10**uint256(TOKEN_DECIMALS);
        
        // 预期授权到零地址会失败
        vm.prank(owner);
        vm.expectRevert(abi.encodeWithSignature("ERC20InvalidSpender(address)", address(0)));
        token.approve(address(0), amount);
    }

    // 测试授权转账功能
    function testTransferFrom() public {
        uint256 amount = 1000 * 10**uint256(TOKEN_DECIMALS);
        
        // 所有者授权user1可以转移代币
        vm.prank(owner);
        token.approve(user1, amount);
        
        // 记录转账前的余额
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        uint256 user2BalanceBefore = token.balanceOf(user2);
        
        // 切换到user1身份执行授权转账
        vm.prank(user1);
        token.transferFrom(owner, user2, amount);
        
        // 验证授权转账结果
        assertEq(token.balanceOf(owner), ownerBalanceBefore - amount, "Owner balance should decrease");
        assertEq(token.balanceOf(user2), user2BalanceBefore + amount, "User2 balance should increase");
        assertEq(token.allowance(owner, user1), 0, "Allowance should be reduced to zero");
    }

    // 测试授权转账失败情况（授权额度不足）
    function testTransferFromInsufficientAllowance() public {
        uint256 amount = 1000 * 10**uint256(TOKEN_DECIMALS);
        uint256 excessAmount = amount + 1;
        
        // 所有者授权user1可以转移代币
        vm.prank(owner);
        token.approve(user1, amount);
        
        // 切换到user1身份尝试转移超过授权额度的代币
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("ERC20InsufficientAllowance(address,uint256,uint256)", user1, amount, excessAmount));
        token.transferFrom(owner, user2, excessAmount);
    }

    // 测试重新授权功能
    function testReapprove() public {
        uint256 initialAmount = 1000 * 10**uint256(TOKEN_DECIMALS);
        uint256 newAmount = 1500 * 10**uint256(TOKEN_DECIMALS);
        
        // 初始授权
        vm.prank(owner);
        token.approve(user1, initialAmount);
        
        // 重新授权
        vm.prank(owner);
        token.approve(user1, newAmount);
        
        // 验证结果
        assertEq(token.allowance(owner, user1), newAmount, "Allowance should be updated to new amount");
    }

    // 测试授权为零
    function testApproveZero() public {
        uint256 initialAmount = 1000 * 10**uint256(TOKEN_DECIMALS);
        
        // 初始授权
        vm.prank(owner);
        token.approve(user1, initialAmount);
        
        // 授权为零
        vm.prank(owner);
        token.approve(user1, 0);
        
        // 验证结果
        assertEq(token.allowance(owner, user1), 0, "Allowance should be set to zero");
    }

    // 测试铸造功能（仅所有者可调用）
    function testMint() public {
        uint256 mintAmount = 1000 * 10**uint256(TOKEN_DECIMALS);
        
        // 记录铸造前的总供应量和用户余额
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 user1BalanceBefore = token.balanceOf(user1);
        
        // 切换到所有者身份铸造代币给user1
        vm.prank(owner);
        token.mint(user1, mintAmount);
        
        // 验证铸造结果
        assertEq(token.totalSupply(), totalSupplyBefore + mintAmount, "Total supply should increase");
        assertEq(token.balanceOf(user1), user1BalanceBefore + mintAmount, "User1 balance should increase");
    }

    // 测试非所有者铸造失败
    function testMintNotOwner() public {
        uint256 mintAmount = 1000 * 10**uint256(TOKEN_DECIMALS);
        
        // 切换到非所有者身份尝试铸造代币
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user1));
        token.mint(user2, mintAmount);
    }

    // 测试铸造到零地址失败
    function testMintToZeroAddress() public {
        uint256 mintAmount = 1000 * 10**uint256(TOKEN_DECIMALS);
        
        // 预期铸造到零地址会失败
        vm.prank(owner);
        vm.expectRevert(abi.encodeWithSignature("ERC20InvalidReceiver(address)", address(0)));
        token.mint(address(0), mintAmount);
    }

    // 测试销毁功能（使用ERC20Burnable接口）
    function testBurn() public {
        // 先转一些代币给user1
        uint256 transferAmount = 1000 * 10**uint256(TOKEN_DECIMALS);
        vm.prank(owner);
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
        vm.expectRevert(abi.encodeWithSignature("ERC20InsufficientBalance(address,uint256,uint256)", user1, user1Balance, excessAmount));
        token.burn(excessAmount);
    }

    // 测试授权销毁功能
    function testBurnFrom() public {
        // 先转一些代币给user1
        uint256 transferAmount = 1000 * 10**uint256(TOKEN_DECIMALS);
        vm.prank(owner);
        token.transfer(user1, transferAmount);
        
        // 设置要销毁的金额
        uint256 burnAmount = 500 * 10**uint256(TOKEN_DECIMALS);
        
        // user1授权user2可以销毁其代币
        vm.prank(user1);
        token.approve(user2, burnAmount);
        
        // 记录销毁前的总供应量和用户余额
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 user1BalanceBefore = token.balanceOf(user1);
        
        // 切换到user2身份销毁user1的代币
        vm.prank(user2);
        token.burnFrom(user1, burnAmount);
        
        // 验证销毁结果
        assertEq(token.totalSupply(), totalSupplyBefore - burnAmount, "Total supply should decrease");
        assertEq(token.balanceOf(user1), user1BalanceBefore - burnAmount, "User1 balance should decrease");
        assertEq(token.allowance(user1, user2), 0, "Allowance should be reduced to zero");
    }

    // 测试所有权转移
    function testTransferOwnership() public {
        // 切换到所有者身份转移所有权
        vm.prank(owner);
        token.transferOwnership(user1);
        
        // 验证所有权已转移
        assertEq(token.owner(), user1, "Ownership should be transferred");
    }

    // 测试非所有者转移所有权失败
    function testTransferOwnershipNotOwner() public {
        // 切换到非所有者身份尝试转移所有权
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user1));
        token.transferOwnership(user2);
    }

    // 测试放弃所有权
    function testRenounceOwnership() public {
        // 切换到所有者身份放弃所有权
        vm.prank(owner);
        token.renounceOwnership();
        
        // 验证所有权已放弃（所有者变为零地址）
        assertEq(token.owner(), address(0), "Ownership should be renounced");
    }

    // 测试非所有者放弃所有权失败
    function testRenounceOwnershipNotOwner() public {
        // 切换到非所有者身份尝试放弃所有权
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user1));
        token.renounceOwnership();
    }

    // 测试事件触发
    function testTransferEvent() public {
        uint256 amount = 1000 * 10**uint256(TOKEN_DECIMALS);
        
        // 预期会触发Transfer事件
        vm.expectEmit(true, true, false, true);
        emit IERC20.Transfer(owner, user1, amount);
        
        // 执行转账
        vm.prank(owner);
        token.transfer(user1, amount);
    }

    // 测试授权事件触发
    function testApprovalEvent() public {
        uint256 amount = 1000 * 10**uint256(TOKEN_DECIMALS);
        
        // 预期会触发Approval事件
        vm.expectEmit(true, true, false, true);
        emit IERC20.Approval(owner, user1, amount);
        
        // 执行授权
        vm.prank(owner);
        token.approve(user1, amount);
    }
}