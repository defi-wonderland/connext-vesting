// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ConnextVestingWallet} from 'contracts/ConnextVestingWallet.sol';

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {Script, console} from 'forge-std/Script.sol';

contract Deploy is Script {
  ConnextVestingWallet public connextVestingWallet;

  uint64 public constant START_TIME = 1_693_872_000;
  uint256 public constant TOTAL_AMOUNT = 24_960_000 ether;
  address public constant OWNER = 0x74fEa3FB0eD030e9228026E7F413D66186d3D107;

  function run() public {
    address deployer = vm.rememberKey(vm.envUint('DEPLOYER_PRIVATE_KEY'));

    require(START_TIME > 0, 'START_TIME');
    require(TOTAL_AMOUNT > 0, 'TOTAL_AMOUNT');
    require(OWNER != address(0), 'OWNER');

    vm.startBroadcast(deployer);
    connextVestingWallet = new ConnextVestingWallet(START_TIME, OWNER, TOTAL_AMOUNT);
    vm.stopBroadcast();

    require(connextVestingWallet.owner() == OWNER, 'owner');
    require(connextVestingWallet.start() == START_TIME, 'START_TIME');
    require(connextVestingWallet.totalAmount() == TOTAL_AMOUNT, 'TOTAL_AMOUNT');
  }
}
