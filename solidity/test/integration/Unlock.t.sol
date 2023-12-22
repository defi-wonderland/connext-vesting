// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {IntegrationBase} from 'test/integration/IntegrationBase.sol';
import {IOwned} from 'test/utils/IOwned.sol';
import {IUnlock} from 'interfaces/IUnlock.sol';
import {IERC20} from 'isolmate/interfaces/tokens/IERC20.sol';

contract IntegrationUnlock is IntegrationBase {
  function test_Constructor() public {
    assertEq(IOwned(address(_unlock)).owner(), _owner);
    assertEq(_unlock.startTime(), block.timestamp + 10 minutes);
  }

  function test_UnlockedAtTimestamp() public {
    assertEq(_unlock.unlockedAtTimestamp(_nextToken, _startTime), 0);
    assertEq(_unlock.unlockedAtTimestamp(_nextToken, _startTime + 364 days), 0 ether);
    assertEq(_unlock.unlockedAtTimestamp(_nextToken, _startTime + 365 days), 1_920_000 ether);

    assertEq(_unlock.unlockedAtTimestamp(_nextToken, _startTime + 365 days + 10 days) - 2_551_232 ether < 1 ether, true);
    assertEq(
      _unlock.unlockedAtTimestamp(_nextToken, _startTime + 365 days + 100 days) - 8_232_328 ether < 1 ether, true
    );

    assertEq(_unlock.unlockedAtTimestamp(_nextToken, _startTime + 365 days + 365 days), 24_960_000 ether);
  }

  function test_UnlockedAmount() public {
    assertEq(_unlock.unlockedSupply(_nextToken), 0);
    vm.warp(_startTime + 364 days);
    assertEq(_unlock.unlockedSupply(_nextToken), 0);
    vm.warp(_startTime + 365 days);
    assertEq(_unlock.unlockedSupply(_nextToken), 1_920_000 ether);

    vm.warp(_startTime + 365 days + 10 days);
    assertEq(_unlock.unlockedSupply(_nextToken) - 2_551_232 ether < 1 ether, true);
    vm.warp(_startTime + 365 days + 100 days);
    assertEq(_unlock.unlockedSupply(_nextToken) - 8_232_328 ether < 1 ether, true);

    vm.warp(_startTime + 365 days + 365 days);
    assertEq(_unlock.unlockedSupply(_nextToken), 24_960_000 ether);
  }

  function test_WithdrawNoSupply() public {
    vm.warp(_startTime + 364 days);
    vm.prank(_owner);
    vm.expectRevert(abi.encodeWithSelector(IUnlock.InsufficientUnlockedSupply.selector));
    _unlock.withdraw(_alice, _nextToken, 1);
  }

  function test_WithdrawUnauthorized() public {
    vm.warp(_startTime + 365 days);
    vm.expectRevert(abi.encodeWithSelector(IUnlock.Unauthorized.selector));
    _unlock.withdraw(_alice, _nextToken, 1);
  }

  function test_WithdrawLegit() public {
    deal(_nextToken, address(_unlock), 1_920_000 ether);
    vm.warp(_startTime + 365 days);
    vm.startPrank(_owner);

    _unlock.withdraw(_alice, _nextToken, 1_920_000 ether);
    assertEq(_unlock.withdrawedSupply(_nextToken), 1_920_000 ether);
    assertEq(IERC20(_nextToken).balanceOf(_alice), 1_920_000 ether);

    vm.expectRevert(abi.encodeWithSelector(IUnlock.InsufficientUnlockedSupply.selector));
    _unlock.withdraw(_alice, _nextToken, 1);

    vm.stopPrank();
  }
}
