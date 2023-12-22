// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {IERC20} from 'isolmate/interfaces/tokens/IERC20.sol';

/**
 * @title Unlock Contract
 * @author Wonderland
 * @notice Used for unlocking NEXT tokens over time
 */
interface IUnlock {
  error InsufficientUnlockedSupply();
  error Unauthorized();

  function unlockedSupply(address _token) external view returns (uint256 unlockedSupply_);
  function unlockedAtTimestamp(address _token, uint256 _timestamp) external view returns (uint256 unlockedSupply_);
  function withdraw(address _receiver, address _token, uint256 _amount) external;

  function startTime() external view returns (uint256 startTime_);
  function withdrawedSupply(address _token) external view returns (uint256 withdrawedSupply_);
  function TOTAL_SUPPLY() external view returns (uint256 totalSupply_);
}
