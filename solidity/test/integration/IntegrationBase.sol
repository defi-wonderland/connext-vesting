// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {Test} from 'forge-std/Test.sol';

import {ConnextVestingWallet} from 'contracts/ConnextVestingWallet.sol';

import {Constants} from 'test/utils/Constants.sol';
import {ILlamaPay} from 'test/utils/ILlamaPay.sol';
import {ILlamaPayFactory} from 'test/utils/ILlamaPayFactory.sol';

// TODO: Inherit and run Deploy.sol script, instead of deploying the contract here
contract IntegrationBase is Test, Constants {
  address public owner = makeAddr('owner');
  address public payer = makeAddr('payer');

  IERC20 internal _nextToken = IERC20(NEXT_TOKEN_ADDRESS);
  ILlamaPayFactory internal _llamaPayFactory = ILlamaPayFactory(LLAMA_FACTORY_ADDRESS);

  ConnextVestingWallet internal _connextVestingWallet;
  ILlamaPay internal _llamaPay;

  function setUp() public virtual {
    vm.createSelectFork(vm.rpcUrl('mainnet'), FORK_BLOCK);

    _connextVestingWallet = new ConnextVestingWallet(owner, 24_960_000 ether);
    //! TODO: Replace for LlamaPay V2
    _llamaPay = ILlamaPay(_llamaPayFactory.createLlamaPayContract(NEXT_TOKEN_ADDRESS));

    deal(NEXT_TOKEN_ADDRESS, payer, TOTAL_AMOUNT);
    vm.prank(payer);
    _nextToken.approve(address(_llamaPay), TOTAL_AMOUNT);
  }
}
