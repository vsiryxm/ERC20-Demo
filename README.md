# ERC20代币演示项目

本项目旨在以新手教学为目的，展示如何从零开始实现ERC20代币以及如何使用标准库快速创建功能完整的代币。

这是一个基于Foundry开发的ERC20代币演示项目，包含两种实现方式：

1. **原生实现 (MyNativeERC20.sol)**: 不依赖任何外部库的ERC20代币实现
2. **OpenZeppelin实现 (OpenZeppelinERC20.sol)**: 使用OpenZeppelin库实现的ERC20代币

如有疑问，请在微信上联系我：xinmin-yang，加好友时记得备注：ERC20 Demo


## 环境准备

### 安装Git

如果您尚未安装Git，请访问[Git官网](https://git-scm.com/downloads)下载并安装。

### 安装Foundry

Foundry是一个用Rust编写的以太坊应用开发工具包，包含以下组件：

- **Forge**: 以太坊测试框架（类似Truffle、Hardhat和DappTools）
- **Cast**: 用于与EVM智能合约交互、发送交易和获取链数据的瑞士军刀
- **Anvil**: 本地以太坊节点，类似于Ganache、Hardhat Network
- **Chisel**: 快速、实用且详细的Solidity REPL

在终端中运行以下命令安装Foundry：

```shell
# 获取安装脚本
curl -L https://foundry.paradigm.xyz | bash

# 加载环境变量
source ~/.bashrc  # 或 source ~/.zshrc（如果使用zsh）

# 安装Foundry
foundryup
```

验证安装：

```shell
forge --version
cast --version
anvil --version
```

## 项目设置

### 克隆项目

```shell
# 克隆项目仓库
git clone https://github.com/vsiryxm/erc20-demo.git
cd erc20-demo
```

### 安装依赖

```shell
# 安装项目依赖
forge install
```

这将安装项目所需的依赖，包括OpenZeppelin合约库。

## 编译合约

```shell
# 编译所有合约
forge build
```

## 测试合约

```shell
# 运行所有测试
forge test

# 运行特定测试并显示详细日志
forge test --match-contract MyNativeERC20Test -vvv
```

## 部署合约

### 在本地网络部署

1. 首先，启动本地以太坊节点：

```shell
anvil
```

2. 在新的终端窗口中，部署合约：

```shell
# 部署MyNativeERC20合约
forge script script/DeployMyNativeERC20.s.sol --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast

# 部署MyOpenZeppelinERC20合约
forge script script/DeployMyOpenZeppelinERC20.s.sol --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast
```

注意：上述私钥是Anvil默认提供的第一个账户私钥，仅用于开发环境。

### 在测试网络部署

```shell
# 设置环境变量 
# 也可以在项目根目录下新建.env文件，然后参考.env.example中的配置项，然后source .env
export PRIVATE_KEY=你的私钥
export ETHERSCAN_API_KEY=你的Etherscan API密钥

# 部署到Sepolia测试网
forge script script/DeployMyNativeERC20.s.sol --rpc-url https://eth-sepolia.g.alchemy.com/v2/{YOUR_KEY} --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
forge script script/DeployMyOpenZeppelinERC20.s.sol --rpc-url https://eth-sepolia.g.alchemy.com/v2/{YOUR_KEY} --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
```

## 合约功能

### MyNativeERC20.sol

原生ERC20实现包含以下功能：

- 基本的ERC20标准功能（转账、授权等）
- 增加/减少授权额度
- 铸造新代币
- 销毁代币

### MyOpenZeppelinERC20.sol

OpenZeppelin实现包含以下功能：

- 继承自OpenZeppelin的ERC20标准功能
- 可销毁功能（ERC20Burnable）
- 所有权控制（Ownable）
- 铸造新代币（仅所有者可调用）

## 其他命令

### 格式化代码

```shell
forge fmt
```

### Gas快照

```shell
forge snapshot
```

### 帮助命令

```shell
forge --help
anvil --help
cast --help
```

## 文档

更多关于Foundry的信息，请访问[官方文档](https://book.getfoundry.sh/)。
