// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IVestingEscrowSimple {
  /**
   * @notice Emits when a new owner confirms his ownership
   * @param _admin Address of the new owner
   */
  event ApplyOwnership(address _admin);

  /**
   * @notice Emits when claim func is triggered
   * @param _recipient Address to send tokens to
   * @param _claimed Amount of claimed tokens
   */
  event Claim(address indexed _recipient, uint256 _claimed);

  /**
   * @notice Emits when the old owner transfers his ownership
   * @param _admin Future admin address
   */
  event CommitOwnership(address _admin);

  /**
   * @notice Emits on initialization and when the vesting is funded
   * @param _recipient Address of the recipient of the vesting tokens
   * @param _amount Amount of tokens to be vested
   */
  event Fund(address indexed _recipient, uint256 _amount);

  /**
   * @notice Emits when rug_pull func is triggered
   * @param _recipient Address to send tokens to
   * @param _rugged Amount of rugged tokens
   */
  event RugPull(address _recipient, uint256 _rugged);

  /**
   * @notice Admin of the contract
   * @return _admin Address of the admin
   */
  function admin() external view returns (address _admin);

  /**
   * @notice Apply pending ownership transfer
   * @dev Only future admin can call this func
   */
  function apply_transfer_ownership() external;

  /**
   * @notice Claim tokens which have vested
   * @dev Caller is the beneficiary, claim all available tokens
   */
  function claim() external;

  /**
   * @notice Claim tokens which have vested
   * @dev Claim all available tokens
   * @param _beneficiary Address to send tokens to
   */
  function claim(address _beneficiary) external;

  /**
   * @notice Claim tokens which have vested
   * @dev Claim a specific amount of tokens to a specific address
   * @param _beneficiary Address to send tokens to
   * @param _amount Amount of tokens to claim
   */
  function claim(address _beneficiary, uint256 _amount) external;

  /**
   * @notice Duration after which the first portion vests
   * @return _length Duration in seconds
   */
  function cliff_length() external view returns (uint256 _length);

  /**
   * @notice Collect dust tokens
   * @dev Collect tokens that are not the vesting token
   * @param _token Address of the token to collect
   */
  function collect_dust(address _token) external;

  /**
   * @notice Trigger ownership transfer
   * @dev Only admin can call this func
   * @param _addr Address of the future admin
   */
  function commit_transfer_ownership(address _addr) external;

  /**
   * @notice Get time when the vesting will be disabled
   * @dev Set to a vesting end date
   * @return _timestamp Timestamp when the vesting will be disabled
   */
  function disabled_at() external view returns (uint256 _timestamp);

  /**
   * @notice Time when the vesting will finish
   * @dev Set to a vesting end date
   * @return _timestamp Timestamp when the vesting will finish
   */
  function end_time() external view returns (uint256 _timestamp);

  /**
   * @notice Pending admin address
   * @return _futureAdmin Address of the future admin
   */
  function future_admin() external view returns (address _futureAdmin);

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
   * @return _success Whether or not the initialization was successful
   */
  function initialize(
    address _admin,
    address _token,
    address _recipient,
    uint256 _amount,
    uint256 _startTime,
    uint256 _endTime,
    uint256 _cliffLength
  ) external returns (bool _success);

  /**
   * @notice Check if the contract is initialized
   * @return _isInitialized Whether or not the contract is initialized
   */
  function initialized() external view returns (bool _isInitialized);

  /**
   * @notice Get the number of locked tokens for recipient
   * @return _amount Amount of locked tokens
   */
  function locked() external view returns (uint256 _amount);

  /**
   * @notice Recipient of the vesting tokens.
   * @return _recipient Address of the recipient
   */
  function recipient() external view returns (address _recipient);

  /**
   * @notice Renounce admin control of the escrow
   */
  function renounce_ownership() external;

  /**
   * @notice Disable further flow of tokens and clawback the unvested part to admin
   */
  function rug_pull() external;

  /**
   * @notice Vesting start time
   * @return _startTime Timestamp when the vesting will start
   */
  function start_time() external view returns (uint256 _startTime);

  /**
   * @notice Vesting token
   * @return _vestingToken Address of the vesting token
   */
  function token() external view returns (address _vestingToken);

  /**
   * @notice Total amount of tokens that are already claimed
   * @return _amount Amount of tokens
   */
  function total_claimed() external view returns (uint256 _amount);

  /**
   * @notice Get the number of locked tokens for recipient
   * @return _amount Amount of tokens
   */
  function total_locked() external view returns (uint256 _amount);

  /**
   * @notice Get the number of unclaimed, vested tokens for recipient
   * @return _amount Amount of tokens
   */
  function unclaimed() external view returns (uint256 _amount);
}
