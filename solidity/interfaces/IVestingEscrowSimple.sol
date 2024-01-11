// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IVestingEscrowSimple {
  function initialize(
    address _admin,
    address _token,
    address _recipient,
    uint256 _amount,
    uint256 _startTime,
    uint256 _endTime,
    uint256 _cliffLength
  ) external returns (bool _success);
  function unclaimed() external view returns (uint256 _amount);
  function locked() external view returns (uint256 _amount);
  function claim(address _beneficiary) external;
  function rug_pull() external;
  function commit_transfer_ownership(address _addr) external;
  function apply_transfer_ownership() external;
  function renounce_ownership() external;
  function collect_dust(address _token) external;
}
