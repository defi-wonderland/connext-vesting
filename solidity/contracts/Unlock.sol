// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable, Ownable2Step} from '@openzeppelin/contracts/access/Ownable2Step.sol';
import {VestingWallet} from '@openzeppelin/contracts/finance/VestingWallet.sol';

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {IUnlock} from 'interfaces/IUnlock.sol';

contract Unlock is VestingWallet, Ownable2Step, IUnlock {
  uint256 public constant SECONDS_UNTIL_FIRST_MILESTONE = 365 days;
  uint256 public immutable TOTAL_AMOUNT;
  uint256 public immutable FIRST_MILESTONE_TIMESTAMP;
  uint256 public immutable UNLOCKED_AT_FIRST_MILESTONE;
  uint256 public immutable UNLOCKED_AFTER_FIRST_MILESTONE;

  constructor(
    uint256 _startTime,
    address _owner,
    uint256 _totalAmount
  ) VestingWallet(_owner, uint64(_startTime), 365 * 2 days) {
    TOTAL_AMOUNT = _totalAmount;
    FIRST_MILESTONE_TIMESTAMP = _startTime + SECONDS_UNTIL_FIRST_MILESTONE;
    UNLOCKED_AT_FIRST_MILESTONE = TOTAL_AMOUNT / 13;
    UNLOCKED_AFTER_FIRST_MILESTONE = TOTAL_AMOUNT - UNLOCKED_AT_FIRST_MILESTONE;
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
  function _vestingSchedule(
    uint256, /* _totalAllocation */
    uint64 _timestamp
  ) internal view virtual override returns (uint256 _unlockedAmount) {
    // 0 if the first milestone has not been reached yet
    if (_timestamp < FIRST_MILESTONE_TIMESTAMP) return _unlockedAmount;

    uint256 _timeSinceFirstMilestone = _timestamp - FIRST_MILESTONE_TIMESTAMP;
    _unlockedAmount = UNLOCKED_AT_FIRST_MILESTONE
      + (UNLOCKED_AFTER_FIRST_MILESTONE * _timeSinceFirstMilestone) / SECONDS_UNTIL_FIRST_MILESTONE;
    if (_unlockedAmount > TOTAL_AMOUNT) _unlockedAmount = TOTAL_AMOUNT;
  }

  function _transferOwnership(address _newOwner) internal virtual override(Ownable, Ownable2Step) {
    super._transferOwnership(_newOwner);
  }

  function transferOwnership(address _newOwner) public virtual override(Ownable, Ownable2Step) onlyOwner {
    super.transferOwnership(_newOwner);
  }

  function releasable(address _token) public view virtual override returns (uint256 _amount) {
    _amount = vestedAmount(_token, uint64(block.timestamp)) - released(_token);
    uint256 _balance = IERC20(_token).balanceOf(address(this));
    _amount = _balance < _amount ? _balance : _amount;
  }
}
