// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable, Ownable2Step} from '@openzeppelin/contracts/access/Ownable2Step.sol';
import {IUnlock} from 'interfaces/IUnlock.sol';
import {IERC20} from 'isolmate/interfaces/tokens/IERC20.sol';

contract Unlock is Ownable2Step, IUnlock {
  uint256 public immutable TOTAL_AMOUNT;
  uint256 public immutable START_TIME;
  IERC20 public immutable VESTING_TOKEN;

  uint256 public withdrawnSupply;

  constructor(uint256 _startTime, address _owner, IERC20 _vestingToken, uint256 _totalAmount) Ownable(_owner) {
    START_TIME = _startTime;
    TOTAL_AMOUNT = _totalAmount;
    VESTING_TOKEN = _vestingToken;
  }

  function _unlockedSupply(uint256 _timestamp) internal view returns (uint256 _unlockedSupplyAmount) {
    uint256 _firstMilestoneTime = START_TIME + 365 days; // 1st milestone is 1 year after start time
    uint256 _totalTime = 365 days; // total unlock time after 1st milestone

    if (_timestamp < _firstMilestoneTime) return _unlockedSupplyAmount; // return 0 if not reached

    uint256 _firstMilestoneUnlockedAmount = TOTAL_AMOUNT / 13; // 1st milestone unlock amount
    uint256 _restAmount = TOTAL_AMOUNT - _firstMilestoneUnlockedAmount; // rest amount after 1st milestone
    uint256 _timePassed = _timestamp - _firstMilestoneTime; // time passed after 1st milestone

    // f(x) = ax + b
    // b = totalAmount / 13
    // a = restAmount / totalTime
    // x = timePassed
    _unlockedSupplyAmount = _firstMilestoneUnlockedAmount + (_restAmount * _timePassed) / _totalTime;
    if (_unlockedSupplyAmount > TOTAL_AMOUNT) _unlockedSupplyAmount = TOTAL_AMOUNT;
  }

  function withdrawableAmount() public view returns (uint256 _withdrawableAmount) {
    _withdrawableAmount = _unlockedSupply(block.timestamp) - withdrawnSupply;
  }

  function unlockedAtTimestamp(uint256 _timestamp) external view returns (uint256 _unlockedSupplyAmount) {
    _unlockedSupplyAmount = _unlockedSupply(_timestamp);
  }

  function withdraw(address _receiver) external {
    if (msg.sender != owner()) revert Unauthorized();

    uint256 _amount = withdrawableAmount();
    uint256 _balance = VESTING_TOKEN.balanceOf(address(this));

    if (_amount > _balance) _amount = _balance;

    withdrawnSupply += _amount;
    VESTING_TOKEN.transfer(_receiver, _amount);
  }
}
