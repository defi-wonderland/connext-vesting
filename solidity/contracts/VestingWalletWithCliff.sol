// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {VestingWallet} from '@openzeppelin/contracts/finance/VestingWallet.sol';

contract VestingWalletWithCliff is VestingWallet {
  /**
   * @dev The cliff timestamp, set into constructor
   */
  uint64 private immutable _CLIFF;

  /**
   * @dev Constructor that initializes the vesting schedule.
   * @param _beneficiary The beneficiary of the vested tokens.
   * @param _vestingStartTimestamp The start time of the vesting schedule.
   * @param _durationSeconds The duration of the vesting schedule, in seconds.
   * @param _cliffDurationSeconds The duration before the cliff, in seconds.
   */
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
   * @return _timestamp The timestamp of the cliff.
   */
  function cliff() public view virtual returns (uint256 _timestamp) {
    return _CLIFF;
  }

  /**
   * @dev Virtual implementation of the vesting formula. This returns the amount vested, as a function of time, for
   * an asset given its total historical allocation.
   * @param _totalAllocation The total amount of tokens to be vested.
   * @param _timestamp The timestamp to calculate vesting for.
   * @return _amount The amount to vest for the passed timestamp.
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
