// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IntegrationBase} from 'test/integration/IntegrationBase.sol';

import {console} from 'forge-std/console.sol';
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
    uint256 _timestamp = VESTING_START_DATE;
    // The unlocking contract holds the tokens
    _warpAndWithdraw(_timestamp);
    _assertBalances(0);
    assertEq(_nextToken.balanceOf(address(_connextVestingWallet)), 0);
  }

  function test_VestAndUnlock_1SecBeforeCliff() public {
    // 1 secont before the cliff
    uint256 _timestamp = VESTING_START_DATE + 365 days - 1;
    _warpAndWithdraw(_timestamp);
    _assertBalances(0);
    assertApproxEqAbs(_nextToken.balanceOf(address(_connextVestingWallet)), 6_239_999 ether, MAX_DELTA);
  }

  function test_VestAndUnlock_Cliff() public {
    // Just at the cliff date
    uint256 _timestamp = VESTING_START_DATE + 365 days;
    _warpAndWithdraw(_timestamp);
    _assertBalances(1_920_000 ether);
    assertApproxEqAbs(
      _nextToken.balanceOf(address(_connextVestingWallet)), 6_240_000 ether - 1_920_000 ether, MAX_DELTA
    );
  }

  function test_VestAndUnlock_1MonthAfterCliff() public {
    // 1 month after the cliff
    uint256 _timestamp = VESTING_START_DATE + 365 days + 30 days;
    _warpAndWithdraw(_timestamp);
    _assertBalances(3_840_000 ether); // 1_920_000 * 2
    assertApproxEqAbs(
      _nextToken.balanceOf(address(_connextVestingWallet)), 6_752_876 ether - 3_840_000 ether, MAX_DELTA
    );
  }

  function test_VestAndUnlock_1YearAfterCliff() public {
    // After the unlocking period has ended
    uint256 _timestamp = VESTING_START_DATE + 365 days + 365 days;
    _warpAndWithdraw(_timestamp);
    _assertBalances(12_480_000 ether); // half of the total
    assertApproxEqAbs(
      _nextToken.balanceOf(address(_connextVestingWallet)), 24_960_000 ether - 12_480_000 ether, MAX_DELTA
    );
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
  function _assertBalances(uint256 _balance) internal {
    assertApproxEqAbs(_connextVestingWallet.released(NEXT_TOKEN_ADDRESS), _balance, MAX_DELTA);
    assertApproxEqAbs(_nextToken.balanceOf(owner), _balance, MAX_DELTA);
  }
}
