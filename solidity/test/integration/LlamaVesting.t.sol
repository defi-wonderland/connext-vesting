// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IntegrationBase} from 'test/integration/IntegrationBase.sol';

/**
 * TODO: Add generic test to show the behaviour of vesting contract + llamaPay stream
 *       At the beginning of the unlocking period: 0 tokens
 *       Then limited by vesting contract
 *       Then limited by llamaPay (after vesting period has ended)
 */
contract IntegrationLlamaVesting is IntegrationBase {
  uint256 internal _vestingStartTime;

  function setUp() public override {
    super.setUp();
    _vestingStartTime = _connextVestingWallet.start();
  }

  function test_VestAndUnlock_LaunchDate() public {
    // Before the cliff
    uint256 _timestamp = LAUNCH_DATE;
    // The unlocking contract holds the tokens
    _warpAndWithdraw(_timestamp);
    _assertWalletBalance(6_838_356 ether);
    _assertOwnerBalance(0 ether);
  }

  function test_VestAndUnlock_1SecBeforeCliff() public {
    // 1 secont before the cliff
    uint256 _timestamp = LAUNCH_DATE + 365 days - 1;
    _warpAndWithdraw(_timestamp);
    _assertWalletBalance(13_078_355 ether);
    _assertOwnerBalance(0 ether);
  }

  function test_VestAndUnlock_Cliff() public {
    // Just at the cliff date
    uint256 _timestamp = LAUNCH_DATE + 365 days;
    _warpAndWithdraw(_timestamp);
    _assertWalletBalance(11_158_356 ether);
    _assertOwnerBalance(1_920_000 ether);
  }

  function test_VestAndUnlock_1MonthAfterCliff() public {
    // 1 month after the cliff
    uint256 _timestamp = LAUNCH_DATE + 365 days + 365 days / 12;
    _warpAndWithdraw(_timestamp);
    _assertWalletBalance(9_758_356 ether);
    _assertOwnerBalance(3_840_000 ether);
  }

  function test_VestAndUnlock_1YearAfterCliff() public {
    // 1 year after the cliff
    uint256 _timestamp = LAUNCH_DATE + 365 days + 365 days;
    _warpAndWithdraw(_timestamp);
    _assertWalletBalance(0 ether);
    _assertOwnerBalance(19_318_356 ether);
  }

  function test_VestAndUnlock_2YearsAfterCliff() public {
    // 2 years after the cliff
    uint256 _timestamp = LAUNCH_DATE + 365 days + 365 days + 365 days;
    _warpAndWithdraw(_timestamp);
    _assertWalletBalance(0 ether);
    _assertOwnerBalance(24_960_000 ether);
  }

  /**
   * @notice Travel in future and withdraw all available balance from the vesting contract to the unlock, then to the owner
   */
  function _warpAndWithdraw(uint256 _timestamp) internal {
    vm.warp(_timestamp);
    vm.prank(owner);
    _connextVestingWallet.claim(address(_llamaVest));
    _connextVestingWallet.release(NEXT_TOKEN_ADDRESS);
  }

  /**
   * @notice Each withdrawal should equally increase the withdrawn amount and the owner's balance
   */
  function _assertOwnerBalance(uint256 _balance) internal {
    assertApproxEqAbs(_connextVestingWallet.released(NEXT_TOKEN_ADDRESS), _balance, MAX_DELTA);
    assertApproxEqAbs(_nextToken.balanceOf(owner), _balance, MAX_DELTA);
  }

  /**
   * @notice Assert the connext vesting wallet balance is equal to the given amount (with a delta of MAX_DELTA)
   */
  function _assertWalletBalance(uint256 _balance) internal {
    assertApproxEqAbs(_nextToken.balanceOf(address(_connextVestingWallet)), _balance, MAX_DELTA);
  }
}
