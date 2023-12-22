// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

interface IOwned {
  function owner() external view returns (address _owner);
}
