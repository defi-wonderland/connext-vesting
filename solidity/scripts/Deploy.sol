// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Unlock} from '../contracts/Unlock.sol';

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {Script, console} from 'forge-std/Script.sol';

contract Deploy is Script {
  Unlock public unlock;

  IERC20 public constant NEXT = IERC20(0xFE67A4450907459c3e1FFf623aA927dD4e28c67a);
  uint256 public constant START_TIME = 1_693_872_000;
  uint256 public constant TOTAL_AMOUNT = 24_960_000 ether;
  address public constant OWNER = 0x555B1Ea88dD9B9DA96bc0E35805e1D1C6802552f;

  function run() public {
    address deployer = vm.rememberKey(vm.envUint('DEPLOYER_PRIVATE_KEY'));

    require(START_TIME > 0, 'START_TIME');
    require(TOTAL_AMOUNT > 0, 'TOTAL_AMOUNT');
    require(OWNER != address(0), 'OWNER');
    require(address(NEXT) != address(0), 'VESTING_TOKEN');

    vm.startBroadcast(deployer);
    unlock = new Unlock(START_TIME, OWNER, NEXT, TOTAL_AMOUNT);
    vm.stopBroadcast();

    require(unlock.owner() == OWNER, 'owner');
    require(unlock.START_TIME() == START_TIME, 'START_TIME');
    require(unlock.TOTAL_AMOUNT() == TOTAL_AMOUNT, 'TOTAL_AMOUNT');
    require(unlock.VESTING_TOKEN() == NEXT, 'VESTING_TOKEN');
  }
}
