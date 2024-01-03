// SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

import {IntegrationBase} from 'test/integration/IntegrationBase.sol';

contract IntegrationLlamaVesting is IntegrationBase {
  uint256 _vestingStartTime;

  function setUp() public override {
    super.setUp();
    deal(NEXT_TOKEN_ADDRESS, owner, TOTAL_AMOUNT);
    _vestingStartTime = block.timestamp;

    vm.prank(owner);
    _nextToken.approve(address(_llamaPay), TOTAL_AMOUNT);
  }

  function test_VestAndUnlock() public {
    vm.startPrank(owner);
    _llamaPay.depositAndCreate(TOTAL_AMOUNT, address(_unlock), PAY_PER_SECOND);

    // before 1st milestone
    uint256 _timePassed = _unlockStartTime + 364 days;
    uint256 _vestedAmount = (_timePassed - _vestingStartTime) * PAY_PER_SECOND / 1e2;
    uint256 _unlockedAmount = 0;
    vm.warp(_timePassed);

    _llamaPay.withdraw(owner, address(_unlock), PAY_PER_SECOND);
    assertEq(_nextToken.balanceOf(address(_unlock)), _vestedAmount); // unlock got its tokens
    _unlock.withdraw(owner);
    assertEq(_unlock.withdrawnAmount(), _unlockedAmount); // not unlocked yet
    assertEq(_nextToken.balanceOf(owner), _unlockedAmount);

    // after 1st milestone
    _timePassed = _unlockStartTime + 365 days + 10 days;
    _unlockedAmount = 2_551_232 ether; // approximated

    vm.warp(_timePassed);
    _llamaPay.withdraw(owner, address(_unlock), PAY_PER_SECOND);
    _unlock.withdraw(owner);

    // unlocked less than vested (with rounding)
    assertApproxEqAbs(_unlock.withdrawnAmount(), _unlockedAmount, 1 ether);
    assertApproxEqAbs(_nextToken.balanceOf(owner), _unlockedAmount, 1 ether);

    // linear unlock after 1st milestone
    _timePassed = _unlockStartTime + 365 days * 2;
    _vestedAmount = (_timePassed - _vestingStartTime) * PAY_PER_SECOND / 1e2;
    _unlockedAmount = 24_960_000 ether;
    vm.warp(_timePassed);
    _llamaPay.withdraw(owner, address(_unlock), PAY_PER_SECOND);
    _unlock.withdraw(owner);

    // vested less than unlocked (with rounding)
    assertApproxEqAbs(_unlock.withdrawnAmount(), _vestedAmount, 0.00001 ether);
    assertApproxEqAbs(_nextToken.balanceOf(owner), _vestedAmount, 0.00001 ether);

    // after the unlocking period has ended
    _timePassed = _unlockStartTime + 365 days * 4 + 10 days;
    _unlockedAmount = 24_960_000 ether;
    vm.warp(_timePassed);
    _llamaPay.withdraw(owner, address(_unlock), PAY_PER_SECOND);
    _unlock.withdraw(owner);

    assertApproxEqAbs(_unlockedAmount, _unlock.withdrawnAmount(), 0.01 ether); // unlocked all (with rounding)
    assertApproxEqAbs(_unlockedAmount, _nextToken.balanceOf(owner), 0.01 ether);

    vm.stopPrank();
  }
}
