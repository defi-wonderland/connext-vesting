// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.19;

import {ISablierV2LockupDynamic} from '@sablier/v2-core/src/interfaces/ISablierV2LockupDynamic.sol';
import {SablierV2LockupDynamic} from '@sablier/v2-core/src/SablierV2LockupDynamic.sol';

import {TestLockupDynamicStreamCreator} from 'contracts/TestLockupDynamicStreamCreator.sol';
import {ISablierV2NFTDescriptor} from '@sablier/v2-core/src/interfaces/ISablierV2NFTDescriptor.sol';
import {ISablierV2Comptroller} from '@sablier/v2-core/src/interfaces/ISablierV2Comptroller.sol';
import {SablierV2NFTDescriptor} from '@sablier/v2-core/src/SablierV2NFTDescriptor.sol';
import {SablierV2Comptroller} from '@sablier/v2-core/src/SablierV2Comptroller.sol';

import {Broker, LockupDynamic} from '@sablier/v2-core/src/types/DataTypes.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {ud2x18} from '@prb/math/src/UD2x18.sol';
import {ud60x18} from '@prb/math/src/UD60x18.sol';
import {Test} from 'forge-std/Test.sol';
import {console} from 'forge-std/Console.sol';

/// @notice Example of how to create a Lockup Dynamic stream.
/// @dev This code is referenced in the docs: https://docs.sablier.com/contracts/v2/guides/create-stream/lockup-dynamic
contract TestLockupDynamicStreamCreatorTest is Test {
  address internal _owner = makeAddr('owner');

  address constant SABLIER_DYNAMIC_MAINNET = 0x39EFdC3dbB57B2388CcC4bb40aC4CB1226Bc9E44;
  address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

  uint256 constant TOTAL_AMOUNT = 24_960_000 ether;

  ISablierV2LockupDynamic internal lockupDynamic;
  ISablierV2Comptroller internal comptroller;
  ISablierV2NFTDescriptor internal nftDescriptor;
  TestLockupDynamicStreamCreator internal creator;

  function setUp() public {
    // mint some NEXT tokens
    vm.createSelectFork(vm.rpcUrl('mainnet'), 18_820_679);

    deal(DAI, _owner, TOTAL_AMOUNT);
    vm.startPrank(_owner);
    // deploy core
    comptroller = new SablierV2Comptroller(_owner);
    nftDescriptor = new SablierV2NFTDescriptor();
    lockupDynamic = new SablierV2LockupDynamic(_owner, comptroller, nftDescriptor, 300);
    // creator
    creator = new TestLockupDynamicStreamCreator(lockupDynamic);
    // approve
    IERC20(DAI).approve(address(creator), TOTAL_AMOUNT);
    vm.stopPrank();
  }

  function test_Creation() external {
    vm.prank(_owner);
    uint256 streamId = creator.createLockupDynamicStream(1000, 2000); // 1_920_000, 5_917_440, 17_122_560
    console.log('streamId: %s', streamId);
  }
}
