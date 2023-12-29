// SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

import {Test} from 'forge-std/Test.sol';

import {Unlock, IUnlock} from 'contracts/Unlock.sol';
import {ILlamaPayFactory} from 'test/utils/ILlamaPayFactory.sol';
import {ILlamaPay} from 'test/utils/ILlamaPay.sol';
import {IERC20} from 'isolmate/interfaces/tokens/IERC20.sol';

contract IntegrationBase is Test {
  uint256 internal constant _FORK_BLOCK = 18_842_671;
  uint256 internal constant _TOTAL_AMOUNT = 24_960_000 ether; // total tokens vested
  uint216 internal constant _PAY_PER_SEC = 0.19786910197 ether; // linear vesting for 4 years

  address internal _owner = makeAddr('owner');
  address internal _alice = makeAddr('alice');
  IERC20 internal _nextToken = IERC20(0xFE67A4450907459c3e1FFf623aA927dD4e28c67a); // real mainnet NEXT token
  ILlamaPayFactory internal _llamaPayFactory = ILlamaPayFactory(0xde1C04855c2828431ba637675B6929A684f84C7F); // real mainnet factory
  IUnlock internal _unlock;
  ILlamaPay internal _llamaPay;
  uint256 internal _startTime;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), _FORK_BLOCK);

    _startTime = block.timestamp + 10 minutes;

    vm.prank(_alice);
    _unlock = new Unlock(_startTime, _owner, address(_nextToken), _TOTAL_AMOUNT);
    _llamaPay = ILlamaPay(_llamaPayFactory.createLlamaPayContract(address(_nextToken)));
  }
}
