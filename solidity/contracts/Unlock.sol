// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {IERC20} from 'isolmate/interfaces/tokens/IERC20.sol';
import {IUnlock} from 'interfaces/IUnlock.sol';
import {Owned} from 'solmate/auth/Owned.sol';

contract Unlock is Owned, IUnlock {
  uint256 public constant TOTAL_SUPPLY = 24_960_000 ether;

  uint256 public startTime;
  mapping(address _token => uint256 _amount) public withdrawedSupply;

  constructor(uint256 _startTime, address _owner) Owned(_owner) {
    startTime = _startTime;
  }

  function _unlockedSupply(address _token, uint256 _timestamp) internal view returns (uint256 _unlockedSupplyReturn) {
    if (_timestamp < startTime + 365 days) {
      _unlockedSupplyReturn = 0;
    } else {
      _unlockedSupplyReturn =
        TOTAL_SUPPLY / 13 + (TOTAL_SUPPLY * 12 / 13) * (_timestamp - startTime - 365 days) / 365 days;
      _unlockedSupplyReturn -= withdrawedSupply[_token];
    }
  }

  function unlockedSupply(address _token) external view returns (uint256 _unlockedSupplyReturn) {
    _unlockedSupplyReturn = _unlockedSupply(_token, block.timestamp);
  }

  function unlockedAtTimestamp(
    address _token,
    uint256 _timestamp
  ) external view returns (uint256 _unlockedSupplyReturn) {
    _unlockedSupplyReturn = _unlockedSupply(_token, _timestamp);
  }

  function withdraw(address _receiver, address _token, uint256 _amount) external {
    if (_amount > _unlockedSupply(_token, block.timestamp)) revert InsufficientUnlockedSupply();
    if (msg.sender != owner) revert Unauthorized();
    withdrawedSupply[_token] += _amount;
    IERC20(_token).transfer(_receiver, _amount);
  }
}
