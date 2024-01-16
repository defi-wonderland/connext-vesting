// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {VestingWallet} from '@openzeppelin/contracts/finance/VestingWallet.sol';

contract VestingWalletWithCliff is VestingWallet {
  uint64 private immutable _CLIFF;

  constructor(
    address _beneficiary,
    uint64 _vestingStartTimestamp,
    uint64 _durationSeconds,
    uint64 _cliffDurationSeconds
  ) VestingWallet(_beneficiary, _vestingStartTimestamp, _durationSeconds) {
    _CLIFF = _vestingStartTimestamp + _cliffDurationSeconds;
  }

  /**
   * @dev Getter for the cliff timestamp.
   */
  function cliff() public view virtual returns (uint256 _timestamp) {
    return _CLIFF;
  }

  /**
   * @dev Virtual implementation of the vesting formula. This returns the amount vested, as a function of time, for
   * an asset given its total historical allocation.
   */
  function _vestingSchedule(
    uint256 _totalAllocation,
    uint64 _timestamp
  ) internal view virtual override returns (uint256 _amount) {
    if (_timestamp < cliff()) {
      return 0;
    } else if (_timestamp >= end()) {
      return _totalAllocation;
    } else {
      return (_totalAllocation * (_timestamp - start())) / duration();
    }
  }
}
