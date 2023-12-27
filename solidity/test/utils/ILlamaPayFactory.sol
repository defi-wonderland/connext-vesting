// SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

interface ILlamaPayFactory {
  function createLlamaPayContract(address _token) external returns (address _contractAddress);
}
