// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

interface IUnlock {
  error InsufficientUnlockedSupply();
  error Unauthorized();

  function unlockedSupply(address _token) external view returns (uint256 _unlockedSupply);
  function unlockedAtTimestamp(address _token, uint256 _timestamp) external view returns (uint256 _unlockedSupply);
  function withdraw(address _receiver, address _token, uint256 _amount) external;

  function startTime() external view returns (uint256 _startTime);
  function withdrawedSupply(address _token) external view returns (uint256 _withdrawedSupply);
  function TOTAL_SUPPLY() external view returns (uint256 _totalSupply);
}
