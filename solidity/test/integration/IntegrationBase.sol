// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {Test} from 'forge-std/Test.sol';

import {ConnextVestingWallet} from 'contracts/ConnextVestingWallet.sol';

import {Constants} from 'test/utils/Constants.sol';
import {ILlamaPay} from 'test/utils/ILlamaPay.sol';
import {ILlamaPayFactory} from 'test/utils/ILlamaPayFactory.sol';

contract IntegrationBase is Test, Constants {
  address public owner = makeAddr('owner');
  address public payer = makeAddr('payer');

  IERC20 internal _nextToken = IERC20(NEXT_TOKEN_ADDRESS);
  ILlamaPayFactory internal _llamaPayFactory = ILlamaPayFactory(LLAMA_FACTORY_ADDRESS);

  ConnextVestingWallet internal _connextVestingWallet;
  ILlamaPay internal _llamaPay;
  uint64 internal _unlockStartTime;

  function setUp() public virtual {
    vm.createSelectFork(vm.rpcUrl('mainnet'), FORK_BLOCK);

    _unlockStartTime = uint64(block.timestamp + 10 minutes);

    _connextVestingWallet = new ConnextVestingWallet(_unlockStartTime, NEXT_TOKEN_ADDRESS, owner);
    _llamaPay = ILlamaPay(_llamaPayFactory.createLlamaPayContract(NEXT_TOKEN_ADDRESS));

    deal(NEXT_TOKEN_ADDRESS, payer, TOTAL_AMOUNT);
    vm.prank(payer);
    _nextToken.approve(address(_llamaPay), TOTAL_AMOUNT);
  }
}
