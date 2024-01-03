// SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

import {IERC20} from 'isolmate/interfaces/tokens/IERC20.sol';

interface IUnlock {
  /*///////////////////////////////////////////////////////////////
                              VARIABLES
  //////////////////////////////////////////////////////////////*/

  /**
   * @notice Returns the timestamp of the beginning of the vesting period
   *
   * @return _startTime The timestamp of the beginning of the vesting period
   */
  function START_TIME() external view returns (uint256 _startTime);

  /**
   * @notice Returns the total amount of vested tokens
   *
   * @return _totalAmount The total amount of vested tokens
   */
  function TOTAL_AMOUNT() external view returns (uint256 _totalAmount);

  /**
   * @notice Returns the vesting token
   *
   * @return _vestingToken The vesting token
   */
  function VESTING_TOKEN() external view returns (IERC20 _vestingToken);

  /**
   * @notice Returns the timestamp of the first milestone, at which a part of the vested tokens will be unlocked
   *
   * @return _firstMilestoneTimestamp The timestamp of the first milestone
   */
  function FIRST_MILESTONE_TIMESTAMP() external view returns (uint256 _firstMilestoneTimestamp);

  /**
   * @notice Returns the amount of the vested tokens that will be unlocked at the first milestone
   *
   * @return _unlockedAtFirstMilestone The amount of the vested tokens that will be unlocked at the first milestone
   */
  function UNLOCKED_AT_FIRST_MILESTONE() external view returns (uint256 _unlockedAtFirstMilestone);

  /**
   * @notice Returns the amount of the vested tokens that will be gradually unlocked after the first milestone
   *
   * @return _unlockedAfterFirstMilestone The amount of the vested tokens that will be unlocked at the first milestone
   */
  function UNLOCKED_AFTER_FIRST_MILESTONE() external view returns (uint256 _unlockedAfterFirstMilestone);

  /**
   * @notice Returns the number of days that should pass before the first milestone is reached
   *
   * @return _daysUntilFirstMilestone The number of days before the first milestone
   */
  function DAYS_UNTIL_FIRST_MILESTONE() external view returns (uint256 _daysUntilFirstMilestone);

  /**
   * @notice Returns the amount of tokens that have been withdrawn
   *
   * @return _withdrawnAmount The amount of withdrawn tokens
   */
  function withdrawnAmount() external view returns (uint256 _withdrawnAmount);

  /**
   * @notice Returns the amount of tokens that can be withdrawn
   *
   * @return _withdrawableAmount The amount of withdrawable tokens
   */
  function withdrawableAmount() external view returns (uint256 _withdrawableAmount);

  /**
   * @notice Returns the amount of tokens that can be withdrawn at a given timestamp
   *
   * @return _unlockedAtTimestamp The amount of tokens that can be withdrawn at the given timestamp
   */
  function unlockedAtTimestamp(uint256 _timestamp) external view returns (uint256 _unlockedAtTimestamp);

  /*///////////////////////////////////////////////////////////////
                              LOGIC
  //////////////////////////////////////////////////////////////*/

  /**
   * @notice Withdraws the tokens that have been unlocked
   *
   * @param _receiver The address of the receiver
   */
  function withdraw(address _receiver) external;
}
