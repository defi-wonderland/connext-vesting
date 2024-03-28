// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {Test} from 'forge-std/Test.sol';

import {Deploy} from 'scripts/Deploy.sol';
import {Constants} from 'test/utils/Constants.sol';

import {IVestingEscrowSimple} from 'interfaces/IVestingEscrowSimple.sol';
import {IVestingEscrowFactory} from 'test/utils/IVestingEscrowFactory.sol';

contract IntegrationBase is Test, Constants, Deploy {
  address public owner = _OWNER;
  address public payer = makeAddr('payer');

  IERC20 internal _nextToken = IERC20(NEXT_TOKEN_ADDRESS);
  IVestingEscrowFactory internal _vestingEscrowFactory = IVestingEscrowFactory(VESTING_ESCROW_FACTORY_ADDRESS);
  IVestingEscrowSimple internal _vestingEscrow;

  function setUp() public virtual {
    vm.createSelectFork(vm.rpcUrl('mainnet'), FORK_BLOCK);

    // deploy
    run();

    deal(NEXT_TOKEN_ADDRESS, payer, TOTAL_AMOUNT);

    // approve before deployment
    vm.prank(payer);
    _nextToken.approve(address(_vestingEscrowFactory), TOTAL_AMOUNT);

    // deploy vesting contract
    vm.prank(payer);
    _vestingEscrow = IVestingEscrowSimple(
      _vestingEscrowFactory.deploy_vesting_contract(
        NEXT_TOKEN_ADDRESS, address(_connextVestingWallet), TOTAL_AMOUNT, VESTING_DURATION, AUG_01_2022, 0
      )
    );
  }
}
