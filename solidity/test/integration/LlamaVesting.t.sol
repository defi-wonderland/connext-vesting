// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IntegrationBase} from 'test/integration/IntegrationBase.sol';

contract IntegrationLlamaVesting is IntegrationBase {
  uint256 internal _vestingStartTime;

  function setUp() public override {
    super.setUp();
    _vestingStartTime = _connextVestingWallet.VESTING_START_DATE() + _connextVestingWallet.VESTING_DURATION();
  }

  function test_VestAndUnlock() public {
    // At launch date
    uint256 _timestamp = SEP_05_2023;
    _warpAndWithdraw(_timestamp);
    _assertWalletBalance(6_838_356 ether);
    _assertOwnerBalance(0 ether);

    // Launch date + 1 year - 1 second
    _timestamp = SEP_05_2023 + YEAR - 1;
    _warpAndWithdraw(_timestamp);
    _assertWalletBalance(13_078_355 ether);
    _assertOwnerBalance(0 ether);

    // Launch date + 1 year
    _timestamp = SEP_05_2023 + YEAR;
    _warpAndWithdraw(_timestamp);
    _assertWalletBalance(11_158_356 ether);
    _assertOwnerBalance(1_920_000 ether);

    // Launch date + 1 year + 1 month
    _timestamp = SEP_05_2023 + YEAR + MONTH;
    _warpAndWithdraw(_timestamp);
    _assertWalletBalance(9_758_356 ether);
    _assertOwnerBalance(3_840_000 ether);

    // Launch date + 2 years
    _timestamp = SEP_05_2023 + 2 * YEAR;
    _warpAndWithdraw(_timestamp);
    _assertWalletBalance(0 ether);
    _assertOwnerBalance(19_318_356 ether);

    // Vesting start date + 4 years
    _timestamp = AUG_01_2022 + 4 * YEAR;
    _warpAndWithdraw(_timestamp);
    _assertWalletBalance(0 ether);
    _assertOwnerBalance(24_960_000 ether);
  }

  /**
   * @notice Travel in future and withdraw all available balance from the vesting contract to the unlock, then to the owner
   */
  function _warpAndWithdraw(uint256 _timestamp) internal {
    vm.warp(_timestamp);
    _connextVestingWallet.claim(address(_llamaVest));
    _connextVestingWallet.release();
  }

  /**
   * @notice Each withdrawal should equally increase the withdrawn amount and the owner's balance
   */
  function _assertOwnerBalance(uint256 _balance) internal {
    assertApproxEqAbs(_connextVestingWallet.released(), _balance, MAX_DELTA);
    assertApproxEqAbs(_nextToken.balanceOf(owner), _balance, MAX_DELTA);
  }

  /**
   * @notice Assert the connext vesting wallet balance is equal to the given amount
   */
  function _assertWalletBalance(uint256 _balance) internal {
    assertApproxEqAbs(_nextToken.balanceOf(address(_connextVestingWallet)), _balance, MAX_DELTA);
  }
}
