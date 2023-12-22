// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {IERC20} from 'isolmate/interfaces/tokens/IERC20.sol';
import {Test} from 'forge-std/Test.sol';

import {Unlock, IUnlock} from 'contracts/Unlock.sol';

contract IntegrationBase is Test {
  uint256 internal constant _FORK_BLOCK = 18_842_671;

  address internal _owner = makeAddr('owner');
  address internal _alice = makeAddr('alice');
  address internal _nextToken = 0xFE67A4450907459c3e1FFf623aA927dD4e28c67a; // real mainnet NEXT token
  IUnlock internal _unlock;
  uint256 internal _startTime;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), _FORK_BLOCK);

    _startTime = block.timestamp + 10 minutes;

    vm.prank(_alice);
    _unlock = new Unlock(_startTime, _owner);
  }
}
