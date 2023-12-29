// SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

import {IERC20} from 'isolmate/interfaces/tokens/IERC20.sol';

interface IUnlock {
  error InsufficientUnlockedSupply();
  error Unauthorized();

  function unlockedSupply() external view returns (uint256 _unlockedSupply);
  function unlockedAtTimestamp(uint256 _timestamp) external view returns (uint256 _unlockedSupply);
  function withdraw(address _receiver) external;

  function START_TIME() external view returns (uint256 _startTime);
  function withdrawnSupply() external view returns (uint256 _withdrawnSupply);
  function TOTAL_AMOUNT() external view returns (uint256 _totalAmount);
  function VESTING_TOKEN() external view returns (IERC20 _vestingToken);
}
