// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title OpenZeppelin实现的ERC20代币合约
 * @dev 这是一个使用OpenZeppelin库实现的ERC20代币，用于教学目的
 * 展示了如何使用标准库快速创建功能完整的代币
 */
contract MyOpenZeppelinERC20 is ERC20, ERC20Burnable, Ownable {
    // 代币小数位数，默认为18
    uint8 private _decimals;

    /**
     * @dev 构造函数，初始化代币基本信息并铸造初始供应量
     * @param name_ 代币名称
     * @param symbol_ 代币符号
     * @param decimals_ 代币小数位数
     * @param initialSupply 初始供应量（未考虑小数位数）
     * @param owner 合约所有者地址
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 initialSupply,
        address owner
    ) ERC20(name_, symbol_) Ownable(owner) {
        _decimals = decimals_;
        
        // 计算实际供应量，考虑小数位数
        uint256 actualSupply = initialSupply * 10**uint256(decimals_);
        
        // 铸造初始供应量给合约所有者
        _mint(owner, actualSupply);
    }

    /**
     * @dev 返回代币小数位数
     * @return 代币小数位数
     */
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev 铸造新代币函数（仅合约所有者可调用）
     * @param to 接收者地址
     * @param amount 铸造金额
     */
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}