// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.19;

import {ISablierV2LockupDynamic} from '@sablier/v2-core/src/interfaces/ISablierV2LockupDynamic.sol';
import {MockLockupDynamicStreamCreator} from 'contracts/MockLockupDynamicStreamCreator.sol';
import {Broker, LockupDynamic} from '@sablier/v2-core/src/types/DataTypes.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {ud2x18} from '@prb/math/src/UD2x18.sol';
import {ud60x18} from '@prb/math/src/UD60x18.sol';
import {Test} from 'forge-std/Test.sol';
import {console} from 'forge-std/Console.sol';

/// @notice Example of how to create a Lockup Dynamic stream.
/// @dev This code is referenced in the docs: https://docs.sablier.com/contracts/v2/guides/create-stream/lockup-dynamic
contract MockLockupDynamicStreamCreatorTest is Test {
  address internal _owner = makeAddr('owner');

  address constant SABLIER_DYNAMIC_MAINNET = 0x39EFdC3dbB57B2388CcC4bb40aC4CB1226Bc9E44;

  ISablierV2LockupDynamic internal lockupDynamic;
  MockLockupDynamicStreamCreator internal creator;

  function setUp() public {
    // mint some NEXT tokens
    vm.createSelectFork(vm.rpcUrl('mainnet'), 18_820_679);
    creator = new MockLockupDynamicStreamCreator(ISablierV2LockupDynamic(SABLIER_DYNAMIC_MAINNET));
    deal(address(creator.ASSET()), address(creator), creator.TOTAL_AMOUNT());

    lockupDynamic = ISablierV2LockupDynamic(SABLIER_DYNAMIC_MAINNET);
  }

  function test_Creation() external {
    vm.prank(_owner);
    uint256 streamId = creator.createLockupDynamicStream();
    console.log('streamId: %s', streamId);
  }
}
