// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IVestingEscrowSimple {
  event ApplyOwnership(address _admin);
  event Claim(address indexed _recipient, uint256 _claimed);
  event CommitOwnership(address _admin);
  event Fund(address indexed _recipient, uint256 _amount);
  event RugPull(address _recipient, uint256 _rugged);

  function admin() external view returns (address _admin);
  function apply_transfer_ownership() external;
  function claim() external;
  function claim(address _beneficiary) external;
  function claim(address _beneficiary, uint256 _amount) external;
  function cliff_length() external view returns (uint256 _length);
  function collect_dust(address _token) external;
  function commit_transfer_ownership(address _addr) external;
  function disabled_at() external view returns (uint256 _timestamp);
  function end_time() external view returns (uint256 _timestamp);
  function future_admin() external view returns (address _futureAdmin);
  function initialize(
    address _admin,
    address _token,
    address _recipient,
    uint256 _amount,
    uint256 _startTime,
    uint256 _endTime,
    uint256 _cliffLength
  ) external returns (bool _success);
  function initialized() external view returns (bool _isInitialized);
  function locked() external view returns (uint256 _amount);
  function recipient() external view returns (address _recipient);
  function renounce_ownership() external;
  function rug_pull() external;
  function start_time() external view returns (uint256 _startTime);
  function token() external view returns (address _vestingToken);
  function total_claimed() external view returns (uint256 _amount);
  function total_locked() external view returns (uint256 _amount);
  function unclaimed() external view returns (uint256 _amount);
}
