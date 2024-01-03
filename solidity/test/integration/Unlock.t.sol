// SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
import {IUnlock} from 'interfaces/IUnlock.sol';
import {IntegrationBase} from 'test/integration/IntegrationBase.sol';
import {IOwnable2Steps} from 'test/utils/IOwnable2Steps.sol';

contract IntegrationUnlock is IntegrationBase {
  function test_Constructor() public {
    assertEq(IOwnable2Steps(address(_unlock)).owner(), _owner);
    assertEq(_unlock.START_TIME(), block.timestamp + 10 minutes);
  }

  function test_UnlockedAtTimestamp() public {
    assertEq(_unlock.unlockedAtTimestamp(_unlockStartTime), 0);
    assertEq(_unlock.unlockedAtTimestamp(_unlockStartTime + 364 days), 0 ether);
    assertEq(_unlock.unlockedAtTimestamp(_unlockStartTime + 365 days), 1_920_000 ether);

    assertEq(_unlock.unlockedAtTimestamp(_unlockStartTime + 365 days + 10 days) - 2_551_232 ether < 1 ether, true);
    assertEq(_unlock.unlockedAtTimestamp(_unlockStartTime + 365 days + 100 days) - 8_232_328 ether < 1 ether, true);

    assertEq(_unlock.unlockedAtTimestamp(_unlockStartTime + 365 days + 365 days), 24_960_000 ether);
    assertEq(_unlock.unlockedAtTimestamp(_unlockStartTime + 365 days + 365 days + 10 days), 24_960_000 ether);
  }

  function test_WithdrawableAmount() public {
    deal(address(_nextToken), address(_unlock), 25_000_000 ether);

    assertEq(_unlock.withdrawableAmount(), 0);
    vm.warp(_unlockStartTime + 364 days);
    assertEq(_unlock.withdrawableAmount(), 0);
    vm.warp(_unlockStartTime + 365 days);
    assertEq(_unlock.withdrawableAmount(), 1_920_000 ether);
    vm.warp(_unlockStartTime + 365 days + 10 days);
    assertEq(_unlock.withdrawableAmount() - 2_551_232 ether < 1 ether, true);

    vm.prank(_owner);
    _unlock.withdraw(_alice);
    assertEq(_unlock.withdrawableAmount(), 0 ether);

    vm.warp(_unlockStartTime + 365 days + 100 days);
    assertEq(8_232_328 ether - _unlock.withdrawableAmount() - 2_551_232 ether < 1 ether, true);
    vm.warp(_unlockStartTime + 365 days + 365 days);
    assertEq(24_960_000 ether - _unlock.withdrawableAmount() - 2_551_232 ether < 1 ether, true);
    vm.warp(_unlockStartTime + 365 days + 365 days + 10 days);
    assertEq(24_960_000 ether - _unlock.withdrawableAmount() - 2_551_232 ether < 1 ether, true);
  }

  function test_WithdrawNoSupply() public {
    vm.warp(_unlockStartTime + 364 days);
    vm.prank(_owner);
    _unlock.withdraw(_alice);
    assertEq(_unlock.withdrawnSupply(), 0);
    assertEq(_nextToken.balanceOf(_alice), 0);
  }

  function test_WithdrawUnauthorized() public {
    vm.warp(_unlockStartTime + 365 days);
    vm.expectRevert(abi.encodeWithSelector(IUnlock.Unauthorized.selector));
    vm.prank(_alice);
    _unlock.withdraw(_alice);
  }

  function test_WithdrawLegit() public {
    deal(address(_nextToken), address(_unlock), 2_000_000 ether); // deal more than withrawable
    vm.warp(_unlockStartTime + 365 days);
    vm.startPrank(_owner);

    _unlock.withdraw(_alice);
    assertEq(_unlock.withdrawnSupply(), 1_920_000 ether);
    assertEq(_nextToken.balanceOf(_alice), 1_920_000 ether);

    // try again and expect no changes
    _unlock.withdraw(_alice);
    assertEq(_unlock.withdrawnSupply(), 1_920_000 ether);
    assertEq(_nextToken.balanceOf(_alice), 1_920_000 ether);

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
