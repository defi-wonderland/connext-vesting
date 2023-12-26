// SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

import {IntegrationBase} from 'test/integration/IntegrationBase.sol';
import {IOwnable2Steps} from 'test/utils/IOwnable2Steps.sol';
import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
import {IUnlock} from 'interfaces/IUnlock.sol';
import {IERC20} from 'isolmate/interfaces/tokens/IERC20.sol';

contract IntegrationUnlock is IntegrationBase {
  function test_Constructor() public {
    assertEq(IOwnable2Steps(address(_unlock)).owner(), _owner);
    assertEq(_unlock.startTime(), block.timestamp + 10 minutes);
  }

  function test_UnlockedAtTimestamp() public {
    assertEq(_unlock.unlockedAtTimestamp(_startTime), 0);
    assertEq(_unlock.unlockedAtTimestamp(_startTime + 364 days), 0 ether);
    assertEq(_unlock.unlockedAtTimestamp(_startTime + 365 days), 1_920_000 ether);

    assertEq(_unlock.unlockedAtTimestamp(_startTime + 365 days + 10 days) - 2_551_232 ether < 1 ether, true);
    assertEq(_unlock.unlockedAtTimestamp(_startTime + 365 days + 100 days) - 8_232_328 ether < 1 ether, true);

    assertEq(_unlock.unlockedAtTimestamp(_startTime + 365 days + 365 days), 24_960_000 ether);
  }

  function test_UnlockedAmount() public {
    assertEq(_unlock.unlockedSupply(), 0);
    vm.warp(_startTime + 364 days);
    assertEq(_unlock.unlockedSupply(), 0);
    vm.warp(_startTime + 365 days);
    assertEq(_unlock.unlockedSupply(), 1_920_000 ether);

    vm.warp(_startTime + 365 days + 10 days);
    assertEq(_unlock.unlockedSupply() - 2_551_232 ether < 1 ether, true);
    vm.warp(_startTime + 365 days + 100 days);
    assertEq(_unlock.unlockedSupply() - 8_232_328 ether < 1 ether, true);

    vm.warp(_startTime + 365 days + 365 days);
    assertEq(_unlock.unlockedSupply(), 24_960_000 ether);
  }

  function test_WithdrawNoSupply() public {
    vm.warp(_startTime + 364 days);
    vm.prank(_owner);
    _unlock.withdraw(_alice, _nextToken);
    assertEq(_unlock.withdrawnSupply(_nextToken), 0);
    assertEq(IERC20(_nextToken).balanceOf(_alice), 0);
  }

  function test_WithdrawUnauthorized() public {
    vm.warp(_startTime + 365 days);
    vm.expectRevert(abi.encodeWithSelector(IUnlock.Unauthorized.selector));
    _unlock.withdraw(_alice, _nextToken);
  }

  function test_WithdrawLegit() public {
    deal(_nextToken, address(_unlock), 2_000_000 ether); // deal more than withrawable
    vm.warp(_startTime + 365 days);
    vm.startPrank(_owner);

    _unlock.withdraw(_alice, _nextToken);
    assertEq(_unlock.withdrawnSupply(_nextToken), 1_920_000 ether);
    assertEq(IERC20(_nextToken).balanceOf(_alice), 1_920_000 ether);

    // try again and expect no changes
    _unlock.withdraw(_alice, _nextToken);
    assertEq(_unlock.withdrawnSupply(_nextToken), 1_920_000 ether);
    assertEq(IERC20(_nextToken).balanceOf(_alice), 1_920_000 ether);

    vm.stopPrank();
  }

  function test_transferOwnership() public {
    vm.prank(_owner);
    IOwnable2Steps(address(_unlock)).transferOwnership(_alice);
    assertEq(IOwnable2Steps(address(_unlock)).pendingOwner(), _alice);
    assertEq(IOwnable2Steps(address(_unlock)).owner(), _owner);

    address _bob = makeAddr('bob');
    vm.prank(_bob);
    vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, _bob));
    IOwnable2Steps(address(_unlock)).acceptOwnership();

    vm.prank(_alice);
    IOwnable2Steps(address(_unlock)).acceptOwnership();
    assertEq(IOwnable2Steps(address(_unlock)).owner(), _alice);
  }
}
