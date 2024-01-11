// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IVestingEscrowFactory {
  function deploy_vesting_contract(
    address _token,
    address _recipient,
    uint256 _amount,
    uint256 _vestingDuration,
    uint256 _vestingStart,
    uint256 _cliffLength
  ) external returns (address _vestingEscrowSimple);
}
