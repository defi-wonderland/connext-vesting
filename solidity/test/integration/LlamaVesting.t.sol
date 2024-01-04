// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IntegrationBase} from 'test/integration/IntegrationBase.sol';

contract IntegrationLlamaVesting is IntegrationBase {
  uint256 internal _vestingStartTime;

  function setUp() public override {
    super.setUp();
    _vestingStartTime = block.timestamp;
  }

  function test_VestAndUnlock() public {
    vm.prank(payer);
    _llamaPay.depositAndCreate(TOTAL_AMOUNT, address(_unlock), PAY_PER_SECOND);

    // Before the 1st milestone
    uint256 _timestamp = _unlock.FIRST_MILESTONE_TIMESTAMP() - 1;
    uint256 _vestedAmount = (_timestamp - _vestingStartTime) * PAY_PER_SECOND / 1e2;

    // The unlocking contract holds the tokens
    _warpAndWithdraw(_timestamp);
    _assertBalances(0);
    assertEq(_nextToken.balanceOf(address(_unlock)), _vestedAmount);

    // After the 1st milestone
    _warpAndWithdraw(_unlock.FIRST_MILESTONE_TIMESTAMP() + 10 days);
    _assertBalances(2_551_232 ether);

    // Linear unlock after the 1st milestone
    _warpAndWithdraw(_unlock.FIRST_MILESTONE_TIMESTAMP() + 365 days);
    _assertBalances(12_480_118 ether);

    // After the unlocking period has ended
    _warpAndWithdraw(_unlock.FIRST_MILESTONE_TIMESTAMP() + 365 days * 3 + 10 days);
    _assertBalances(24_960_000 ether);
  }

  /**
   * @notice Travel in future and withdraw all available balance from the vesting contract to the unlock, then to the owner
   */
  function _warpAndWithdraw(uint256 _timestamp) internal {
    vm.warp(_timestamp);
    _llamaPay.withdraw(payer, address(_unlock), PAY_PER_SECOND);

    vm.prank(owner);
    _unlock.withdraw(owner);
  }

  /**
   * @notice Each withdrawal should equally increase the withdrawn amount and the owner's balance
   */
  function _assertBalances(uint256 _balance) internal {
    assertApproxEqAbs(_unlock.withdrawnAmount(), _balance, MAX_DELTA);
    assertApproxEqAbs(_nextToken.balanceOf(owner), _balance, MAX_DELTA);
  }
}
