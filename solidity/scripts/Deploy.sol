// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ConnextVestingWallet} from 'contracts/ConnextVestingWallet.sol';

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {Script, console} from 'forge-std/Script.sol';

contract Deploy is Script {
  ConnextVestingWallet internal _connextVestingWallet;

  uint256 internal constant _TOTAL_AMOUNT = 24_960_000 ether;
  address internal constant _OWNER = 0x74fEa3FB0eD030e9228026E7F413D66186d3D107;

  function run() public {
    address deployer = vm.rememberKey(vm.envUint('DEPLOYER_PRIVATE_KEY'));

    require(_TOTAL_AMOUNT > 0, 'TOTAL_AMOUNT');
    require(_OWNER != address(0), 'OWNER');

    vm.startBroadcast(deployer);
    _connextVestingWallet = new ConnextVestingWallet(_OWNER, _TOTAL_AMOUNT);
    vm.stopBroadcast();

    require(_connextVestingWallet.owner() == _OWNER, 'owner');
    require(_connextVestingWallet.TOTAL_AMOUNT() == _TOTAL_AMOUNT, 'TOTAL_AMOUNT');
  }
}
