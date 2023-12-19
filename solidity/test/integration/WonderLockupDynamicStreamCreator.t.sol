// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.19;

import {ISablierV2LockupDynamic} from '@sablier/v2-core/src/interfaces/ISablierV2LockupDynamic.sol';
import {Broker, LockupDynamic} from '@sablier/v2-core/src/types/DataTypes.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {ud2x18} from '@prb/math/src/UD2x18.sol';
import {ud60x18} from '@prb/math/src/UD60x18.sol';
import {Test} from 'forge-std/Test.sol';
import {console} from 'forge-std/Console.sol';
import {WonderLockupDynamicStreamCreator} from 'contracts/WonderLockupDynamicStreamCreator.sol';

/// @notice Example of how to create a Lockup Dynamic stream.
/// @dev This code is referenced in the docs: https://docs.sablier.com/contracts/v2/guides/create-stream/lockup-dynamic
contract WonderLockupDynamicStreamCreatorTest is Test {
  address internal _owner = makeAddr('owner');
  WonderLockupDynamicStreamCreator internal creator;

  address public constant SABLIER_DYNAMIC_MAINNET = 0x39EFdC3dbB57B2388CcC4bb40aC4CB1226Bc9E44;
  uint256 public constant TOTAL_AMOUNT = 24_960_000 ether;

  function setUp() public {
    // mint some NEXT tokens
    vm.createSelectFork(vm.rpcUrl('mainnet'), 18_820_679);
    creator = new WonderLockupDynamicStreamCreator(ISablierV2LockupDynamic(SABLIER_DYNAMIC_MAINNET));
    deal(creator.NEXT_MAINNET(), _owner, TOTAL_AMOUNT);
    vm.prank(_owner);
    IERC20(creator.NEXT_MAINNET()).approve(address(creator), TOTAL_AMOUNT);
  }

  function test_Creation() external {
    assertEq(TOTAL_AMOUNT, 1_920_000 ether + 5_917_440 ether + 17_122_560 ether);
    assertEq(IERC20(creator.NEXT_MAINNET()).balanceOf(_owner), TOTAL_AMOUNT);
    assertEq(IERC20(creator.NEXT_MAINNET()).allowance(_owner, address(creator)), TOTAL_AMOUNT);
    console.log('here');
    vm.prank(_owner);
    uint256 streamId = creator.createLockupDynamicStream(1_920_000 ether, 5_917_440 ether, 17_122_560 ether);
    console.log('streamId: %s', streamId);
  }
}
