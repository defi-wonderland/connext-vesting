// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IVestingEscrowSimple {
  /**
   * @notice Initialize the contract.
   * @dev This function is seperate from `constructor` because of the factory pattern
   * used in `VestingEscrowFactory.deploy_vesting_contract`. It may be called
   * once per deployment.
   * @param _admin Admin address
   * @param _token Address of the ERC20 token being distributed
   * @param _recipient Address to vest tokens for
   * @param _amount Amount of tokens being vested for `recipient`
   * @param _startTime Epoch time at which token distribution starts
   * @param _endTime Time until everything should be vested
   * @param _cliffLength Duration after which the first portion vests
   * @param _openClaim Whether or not the claim function can be called by anyone
   * @return _success Whether or not the initialization was successful
   */
  function initialize(
    address _admin,
    address _token,
    address _recipient,
    uint256 _amount,
    uint256 _startTime,
    uint256 _endTime,
    uint256 _cliffLength,
    bool _openClaim
  ) external returns (bool);

  function unclaimed() external view returns (uint256);
  function locked() external view returns (uint256);
  function claim() external returns (uint256);
  function claim(address beneficiary) external returns (uint256);
  function claim(address beneficiary, uint256 amount) external returns (uint256);
  function revoke() external;
  function revoke(uint256 ts) external;
  function revoke(uint256 ts, address beneficiary) external;
  function disown() external;
  function set_open_claim(bool open_claim) external;
  function collect_dust(address token) external;
  function collect_dust(address token, address beneficiary) external;
  function recipient() external view returns (address);
  function token() external view returns (address);
  function start_time() external view returns (uint256);
  function end_time() external view returns (uint256);
  function cliff_length() external view returns (uint256);
  function total_locked() external view returns (uint256);
  function total_claimed() external view returns (uint256);
  function disabled_at() external view returns (uint256);
  function open_claim() external view returns (bool);
  function initialized() external view returns (bool);
  function owner() external view returns (address);
}
