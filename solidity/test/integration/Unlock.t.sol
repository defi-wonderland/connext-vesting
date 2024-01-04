// SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

import {Ownable, Ownable2Step} from '@openzeppelin/contracts/access/Ownable2Step.sol';
import {IntegrationBase} from 'test/integration/IntegrationBase.sol';

contract IntegrationUnlock is IntegrationBase {
  address public receiver = makeAddr('receiver');

  address internal _unlockAddress;
  uint256 internal _firstMilestoneTimestamp;

  function setUp() public override {
    super.setUp();

    _unlockAddress = address(_unlock);
    _firstMilestoneTimestamp = _unlock.FIRST_MILESTONE_TIMESTAMP();
  }

  function test_Constructor() public {
    assertEq(Ownable2Step(_unlockAddress).owner(), owner);
    assertEq(_unlock.START_TIME(), block.timestamp + 10 minutes);
  }

  function test_UnlockedAtTimestamp() public {
    assertEq(_unlock.unlockedAtTimestamp(_unlockStartTime), 0);
    assertEq(_unlock.unlockedAtTimestamp(_firstMilestoneTimestamp - 1), 0);

    assertEq(_unlock.unlockedAtTimestamp(_firstMilestoneTimestamp), 1_920_000 ether);

    assertApproxEqAbs(_unlock.unlockedAtTimestamp(_firstMilestoneTimestamp + 10 days), 2_551_232 ether, MAX_DELTA);
    assertApproxEqAbs(_unlock.unlockedAtTimestamp(_firstMilestoneTimestamp + 100 days), 8_232_328 ether, MAX_DELTA);

    assertEq(_unlock.unlockedAtTimestamp(_firstMilestoneTimestamp + 365 days), 24_960_000 ether);
    assertEq(_unlock.unlockedAtTimestamp(_firstMilestoneTimestamp + 365 days + 10 days), 24_960_000 ether);
  }

  function test_WithdrawableAmount() public {
    deal(NEXT_TOKEN_ADDRESS, _unlockAddress, 25_000_000 ether);

    assertEq(_unlock.withdrawableAmount(), 0);

    vm.warp(_unlockStartTime + 364 days);
    assertEq(_unlock.withdrawableAmount(), 0);

    vm.warp(_firstMilestoneTimestamp);
    assertEq(_unlock.withdrawableAmount(), 1_920_000 ether);

    vm.warp(_firstMilestoneTimestamp + 10 days);
    assertApproxEqAbs(_unlock.withdrawableAmount(), 2_551_232 ether, MAX_DELTA);

    vm.prank(owner);
    _unlock.withdraw(receiver);
    assertEq(_unlock.withdrawableAmount(), 0 ether);

    vm.warp(_firstMilestoneTimestamp + 100 days);
    assertApproxEqAbs(8_232_328 ether - _unlock.withdrawableAmount(), 2_551_232 ether, MAX_DELTA);

    vm.warp(_firstMilestoneTimestamp + 365 days);
    assertApproxEqAbs(24_960_000 ether - _unlock.withdrawableAmount(), 2_551_232 ether, MAX_DELTA);

    vm.warp(_firstMilestoneTimestamp + 365 days + 10 days);
    assertApproxEqAbs(24_960_000 ether - _unlock.withdrawableAmount(), 2_551_232 ether, MAX_DELTA);
  }

  function test_Withdraw() public {
    // deal more than withdrawable
    deal(NEXT_TOKEN_ADDRESS, _unlockAddress, 2_000_000 ether);
    vm.warp(_firstMilestoneTimestamp);

    vm.startPrank(owner);
    _unlock.withdraw(receiver);
    assertEq(_unlock.withdrawnAmount(), 1_920_000 ether);
    assertEq(_nextToken.balanceOf(receiver), 1_920_000 ether);

    // try again and expect no changes
    _unlock.withdraw(receiver);
    assertEq(_unlock.withdrawnAmount(), 1_920_000 ether);
    assertEq(_nextToken.balanceOf(receiver), 1_920_000 ether);

    vm.stopPrank();
  }

  function test_Withdraw_NoSupply() public {
    vm.prank(owner);
    _unlock.withdraw(receiver);

    assertEq(_unlock.withdrawnAmount(), 0);
    assertEq(_nextToken.balanceOf(receiver), 0);
  }

  function test_Withdraw_Unauthorized() public {
    address _randomAddress = makeAddr('randomAddress');
    vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, _randomAddress));
    vm.prank(_randomAddress);
    _unlock.withdraw(receiver);
  }

  function test_transferOwnership() public {
    address _newOwner = makeAddr('newOwner');
    Ownable2Step _unlockOwnable = Ownable2Step(_unlockAddress);

    vm.prank(owner);
    _unlockOwnable.transferOwnership(_newOwner);

    assertEq(_unlockOwnable.pendingOwner(), _newOwner);
    assertEq(_unlockOwnable.owner(), owner);

    address _bob = makeAddr('bob');
    vm.prank(_bob);
    vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, _bob));
    _unlockOwnable.acceptOwnership();

    vm.prank(_newOwner);
    _unlockOwnable.acceptOwnership();
    assertEq(_unlockOwnable.owner(), _newOwner);
  }
}
