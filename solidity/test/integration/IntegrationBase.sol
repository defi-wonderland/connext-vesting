// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {Test} from 'forge-std/Test.sol';

import {IUnlock, Unlock} from 'contracts/Unlock.sol';

import {Constants} from 'test/utils/Constants.sol';
import {ILlamaPay} from 'test/utils/ILlamaPay.sol';
import {ILlamaPayFactory} from 'test/utils/ILlamaPayFactory.sol';

contract IntegrationBase is Test, Constants {
  address public owner = makeAddr('owner');

  IERC20 internal _nextToken = IERC20(NEXT_TOKEN_ADDRESS);
  ILlamaPayFactory internal _llamaPayFactory = ILlamaPayFactory(LLAMA_FACTORY_ADDRESS);

  IUnlock internal _unlock;
  ILlamaPay internal _llamaPay;
  uint256 internal _unlockStartTime;

  function setUp() public virtual {
    vm.createSelectFork(vm.rpcUrl('mainnet'), FORK_BLOCK);

    _unlockStartTime = block.timestamp + 10 minutes;

    _unlock = new Unlock(_unlockStartTime, owner, _nextToken, TOTAL_AMOUNT);
    _llamaPay = ILlamaPay(_llamaPayFactory.createLlamaPayContract(NEXT_TOKEN_ADDRESS));
  }
}
