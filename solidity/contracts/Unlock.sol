// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable, Ownable2Step} from '@openzeppelin/contracts/access/Ownable2Step.sol';
import {IUnlock} from 'interfaces/IUnlock.sol';
import {IERC20} from 'isolmate/interfaces/tokens/IERC20.sol';

contract Unlock is Ownable2Step, IUnlock {
  /// @inheritdoc IUnlock
  uint256 public constant SECONDS_UNTIL_FIRST_MILESTONE = 365 days;

  /// @inheritdoc IUnlock
  IERC20 public immutable VESTING_TOKEN;

  /// @inheritdoc IUnlock
  uint256 public immutable TOTAL_AMOUNT;
  /// @inheritdoc IUnlock
  uint256 public immutable START_TIME;
  /// @inheritdoc IUnlock
  uint256 public immutable FIRST_MILESTONE_TIMESTAMP;
  /// @inheritdoc IUnlock
  uint256 public immutable UNLOCKED_AT_FIRST_MILESTONE;
  /// @inheritdoc IUnlock
  uint256 public immutable UNLOCKED_AFTER_FIRST_MILESTONE;

  /// @inheritdoc IUnlock
  uint256 public withdrawnAmount;

  constructor(uint256 _startTime, address _owner, IERC20 _vestingToken, uint256 _totalAmount) Ownable(_owner) {
    START_TIME = _startTime;
    TOTAL_AMOUNT = _totalAmount;
    VESTING_TOKEN = _vestingToken;
    FIRST_MILESTONE_TIMESTAMP = START_TIME + SECONDS_UNTIL_FIRST_MILESTONE;
    UNLOCKED_AT_FIRST_MILESTONE = TOTAL_AMOUNT / 13;
    UNLOCKED_AFTER_FIRST_MILESTONE = TOTAL_AMOUNT - UNLOCKED_AT_FIRST_MILESTONE;
  }

  /// @inheritdoc IUnlock
  function withdrawableAmount() public view returns (uint256 _withdrawableAmount) {
    _withdrawableAmount = _unlockedAmountAt(block.timestamp) - withdrawnAmount;
  }

  /// @inheritdoc IUnlock
  function unlockedAtTimestamp(uint256 _timestamp) external view returns (uint256 _unlockedAtTimestamp) {
    _unlockedAtTimestamp = _unlockedAmountAt(_timestamp);
  }

  /// @inheritdoc IUnlock
  function withdraw(address _receiver) external onlyOwner {
    uint256 _amount = withdrawableAmount();
    uint256 _balance = VESTING_TOKEN.balanceOf(address(this));

    if (_amount > _balance) _amount = _balance;

    withdrawnAmount += _amount;
    VESTING_TOKEN.transfer(_receiver, _amount);
  }

  /**
   * @notice Returns the amount of unlocked tokens at a given timestamp
   *
   * @dev f(x) = ax + b, where
   *      x = time since the first milestone
   *      a = remaining amount / totalTime
   *      b = total amount / 13
   * @param _timestamp The timestamp to query
   * @return _unlockedAmount The amount of unlocked tokens at the given timestamp
   */
  function _unlockedAmountAt(uint256 _timestamp) internal view returns (uint256 _unlockedAmount) {
    // 0 if the first milestone has not been reached yet
    if (_timestamp < FIRST_MILESTONE_TIMESTAMP) return _unlockedAmount;

    uint256 _timeSinceFirstMilestone = _timestamp - FIRST_MILESTONE_TIMESTAMP;
    _unlockedAmount = UNLOCKED_AT_FIRST_MILESTONE
      + (UNLOCKED_AFTER_FIRST_MILESTONE * _timeSinceFirstMilestone) / SECONDS_UNTIL_FIRST_MILESTONE;
    if (_unlockedAmount > TOTAL_AMOUNT) _unlockedAmount = TOTAL_AMOUNT;
  }
}
