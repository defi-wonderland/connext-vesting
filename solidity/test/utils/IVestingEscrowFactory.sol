// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IVestingEscrowFactory {
  event VestingEscrowCreated(
    address indexed _funder,
    address indexed _token,
    address indexed _recipient,
    address _escrow,
    uint256 _amount,
    uint256 _vestingStart,
    uint256 _vestingDuration,
    uint256 _cliffLength,
    bool _openClaim
  );

  function deploy_vesting_contract(
    address _token,
    address _recipient,
    uint256 _amount,
    uint256 _vestingDuration
  ) external returns (address _vestingContract);

  function deploy_vesting_contract(
    address _token,
    address _recipient,
    uint256 _amount,
    uint256 _vestingDuration,
    uint256 _vestingStart
  ) external returns (address _vestingContract);

  function deploy_vesting_contract(
    address _token,
    address _recipient,
    uint256 _amount,
    uint256 _vestingDuration,
    uint256 _vestingStart,
    uint256 _cliffLength
  ) external returns (address _vestingContract);

  function deploy_vesting_contract(
    address _token,
    address _recipient,
    uint256 _amount,
    uint256 _vestingDuration,
    uint256 _vestingStart,
    uint256 _cliffLength,
    bool _openClaim
  ) external returns (address _vestingContract);

  function deploy_vesting_contract(
    address _token,
    address _recipient,
    uint256 _amount,
    uint256 _vestingDuration,
    uint256 _vestingStart,
    uint256 _cliffLength,
    bool _openClaim,
    uint256 _supportVyper
  ) external returns (address _vestingContract);

  function deploy_vesting_contract(
    address _token,
    address _recipient,
    uint256 _amount,
    uint256 _vestingDuration,
    uint256 _vestingStart,
    uint256 _cliffLength,
    bool _openClaim,
    uint256 _supportVyper,
    address _owner
  ) external returns (address _vestingContract);

  function escrows(uint256 _id) external view returns (address _escrow);
  function escrows_length() external view returns (uint256 _id);
  function target() external view returns (address _vestingEscrowSimpleTemplate);
}
