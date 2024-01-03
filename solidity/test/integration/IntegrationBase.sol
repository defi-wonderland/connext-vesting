// SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

import {Test} from 'forge-std/Test.sol';

import {IUnlock, Unlock} from 'contracts/Unlock.sol';

import {IERC20} from 'isolmate/interfaces/tokens/IERC20.sol';
import {ILlamaPay} from 'test/utils/ILlamaPay.sol';
import {ILlamaPayFactory} from 'test/utils/ILlamaPayFactory.sol';

contract IntegrationBase is Test {
  uint256 internal constant _FORK_BLOCK = 18_842_671;
  uint256 internal constant _TOTAL_AMOUNT = 24_960_000 ether; // total tokens vested
  uint216 internal constant _PAY_PER_SEC = 0.19786910197 * 1e20; // linear vesting for 4 years (20 decimals according to llama docs)

  address internal _owner = makeAddr('owner');
  address internal _alice = makeAddr('alice');
  IERC20 internal _nextToken = IERC20(0xFE67A4450907459c3e1FFf623aA927dD4e28c67a); // real mainnet NEXT token
  ILlamaPayFactory internal _llamaPayFactory = ILlamaPayFactory(0xde1C04855c2828431ba637675B6929A684f84C7F); // real mainnet factory
  IUnlock internal _unlock;
  ILlamaPay internal _llamaPay;
  uint256 internal _unlockStartTime;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), _FORK_BLOCK);

    _unlockStartTime = block.timestamp + 10 minutes;

    vm.prank(_alice);
    _unlock = new Unlock(_unlockStartTime, _owner, _nextToken, _TOTAL_AMOUNT);
    _llamaPay = ILlamaPay(_llamaPayFactory.createLlamaPayContract(address(_nextToken)));
  }
}
