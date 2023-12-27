// SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

interface IUnlock {
  error InsufficientUnlockedSupply();
  error Unauthorized();

  function unlockedSupply() external view returns (uint256 _unlockedSupply);
  function unlockedAtTimestamp(uint256 _timestamp) external view returns (uint256 _unlockedSupply);
  function withdraw(address _receiver) external;

  function startTime() external view returns (uint256 _startTime);
  function withdrawnSupply() external view returns (uint256 _withdrawnSupply);
  function totalAmount() external view returns (uint256 _totalAmount);
}
