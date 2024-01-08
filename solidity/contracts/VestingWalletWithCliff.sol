// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {VestingWallet} from '@openzeppelin/contracts/finance/VestingWallet.sol';

contract VestingWalletWithCliff is VestingWallet {
  uint64 private immutable _cliff;

  constructor(
    address beneficiary,
    uint64 startTimestamp,
    uint64 durationSeconds,
    uint64 cliffSeconds
  ) VestingWallet(beneficiary, startTimestamp, durationSeconds) {
    _cliff = startTimestamp + cliffSeconds;
  }

  /**
   * @dev Getter for the cliff timestamp.
   */
  function cliff() public view virtual returns (uint256) {
    return _cliff;
  }

  /**
   * @dev Virtual implementation of the vesting formula. This returns the amount vested, as a function of time, for
   * an asset given its total historical allocation.
   */
  function _vestingSchedule(uint256 totalAllocation, uint64 timestamp) internal view virtual override returns (uint256) {
    if (timestamp < cliff()) {
      return 0;
    } else if (timestamp >= end()) {
      return totalAllocation;
    } else {
      return (totalAllocation * (timestamp - start())) / duration();
    }
  }
}
