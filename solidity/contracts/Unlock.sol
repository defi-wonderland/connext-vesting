// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {IERC20} from 'isolmate/interfaces/tokens/IERC20.sol';
import {IUnlock} from 'interfaces/IUnlock.sol';
import {Owned} from 'solmate/auth/Owned.sol';

contract Unlock is Owned, IUnlock {
  uint256 public startTime;
  mapping(address _token => uint256 _amount) public withdrawedSupply;

  uint256 public constant TOTAL_SUPPLY = 24_960_000 ether;

  constructor(uint256 _startTime, address _owner) Owned(_owner) {
    startTime = _startTime;
  }

  function _unlockedSupply(address _token, uint256 _timestamp) internal view returns (uint256 unlockedSupply_) {
    if (_timestamp < startTime + 365 days) {
      unlockedSupply_ = 0;
    } else {
      unlockedSupply_ = TOTAL_SUPPLY / 13 + (TOTAL_SUPPLY * 12 / 13) * (_timestamp - startTime - 365 days) / 365 days;
      unlockedSupply_ -= withdrawedSupply[_token];
    }
  }

  function unlockedSupply(address _token) external view returns (uint256 unlockedSupply_) {
    unlockedSupply_ = _unlockedSupply(_token, block.timestamp);
  }

  function unlockedAtTimestamp(address _token, uint256 _timestamp) external view returns (uint256 unlockedSupply_) {
    unlockedSupply_ = _unlockedSupply(_token, _timestamp);
  }

  function withdraw(address _receiver, address _token, uint256 _amount) external {
    if (_amount > _unlockedSupply(_token, block.timestamp)) revert InsufficientUnlockedSupply();
    if (msg.sender != owner) revert Unauthorized();
    withdrawedSupply[_token] += _amount;
    IERC20(_token).transfer(_receiver, _amount);
  }
}
