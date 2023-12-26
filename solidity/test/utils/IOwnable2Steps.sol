// SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

interface IOwnable2Steps {
  function transferOwnership(address _newOwner) external;
  function acceptOwnership() external;

  function pendingOwner() external view returns (address _pendingOwner);
  function owner() external view returns (address _owner);
}
