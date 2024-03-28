// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IVestingEscrowSimple {
  /**
   * @notice Initialize the contract.
   * @dev This function is seperate from `constructor` because of the factory pattern
   * used in `VestingEscrowFactory.deploy_vesting_contract`. It may be called once per deployment.
   * @param _owner Owner address
   * @param _token Address of the ERC20 token being distributed
   * @param _recipient Address to vest tokens for
   * @param _amount Amount of tokens being vested for `recipient`
   * @param _startTime Epoch time at which token distribution starts
   * @param _endTime Time until everything should be vested
   * @param _cliffLength Duration (in seconds) after which the first portion vests
   * @param _openClaim Switch if anyone can claim for `recipient`
   * @return _success Whether or not the initialization was successful
   */
  function initialize(
    address _owner,
    address _token,
    address _recipient,
    uint256 _amount,
    uint256 _startTime,
    uint256 _endTime,
    uint256 _cliffLength,
    bool _openClaim
  ) external returns (bool _success);

  /**
   * @notice Get the number of unclaimed, vested tokens for recipient.
   * @return _unclaimed The amount of unclaimed tokens.
   */
  function unclaimed() external view returns (uint256 _unclaimed);

  /**
   * @notice Get the number of locked tokens for recipient.
   * @return _locked The amount of locked tokens.
   */
  function locked() external view returns (uint256 _locked);

  /**
   * @notice Claim tokens which have vested for the caller.
   * @return _claimed The amount of tokens claimed.
   */
  function claim() external returns (uint256 _claimed);

  /**
   * @notice Claim tokens which have vested for a specified beneficiary.
   * @param _beneficiary The address to transfer claimed tokens to.
   * @return _claimed The amount of tokens claimed.
   */
  function claim(address _beneficiary) external returns (uint256 _claimed);

  /**
   * @notice Claim a specified amount of tokens which have vested for a specified beneficiary.
   * @param _beneficiary The address to transfer claimed tokens to.
   * @param _amount The amount of tokens to claim.
   * @return _claimed The amount of tokens claimed.
   */
  function claim(address _beneficiary, uint256 _amount) external returns (uint256 _claimed);

  /**
   * @notice Disable further flow of tokens and renounce ownership.
   */
  function revoke() external;

  /**
   * @notice Disable further flow of tokens from a specific timestamp and renounce ownership.
   * @param _timestamp The timestamp to disable further token flow.
   */
  function revoke(uint256 _timestamp) external;

  /**
   * @notice Disable further flow of tokens from a specific timestamp, transfer unvested tokens to a beneficiary, and renounce ownership.
   * @param _timestamp The timestamp to disable further token flow.
   * @param _beneficiary The address to transfer unvested tokens to.
   */
  function revoke(uint256 _timestamp, address _beneficiary) external;

  /**
   * @notice Renounce owner control of the escrow, effectively making it ownerless.
   */
  function disown() external;

  /**
   * @notice Disallow or allow anyone to claim tokens for `recipient`.
   * @param _openClaim True to allow anyone to claim, false to restrict to recipient only.
   */
  function set_open_claim(bool _openClaim) external;

  /**
   * @notice Transfer any ERC20 tokens sent to the contract address to a beneficiary.
   * @param _token The address of the ERC20 token to transfer.
   */
  function collect_dust(address _token) external;

  /**
   * @notice Transfer any ERC20 tokens sent to the contract address to a specified beneficiary.
   * @param _token The address of the ERC20 token to transfer.
   * @param _beneficiary The address to transfer the tokens to.
   */
  function collect_dust(address _token, address _beneficiary) external;

  /**
   * @notice Returns the address of the recipient.
   * @return _recipient The address of the recipient.
   */
  function recipient() external view returns (address _recipient);

  /**
   * @notice Returns the address of the token being vested.
   * @return _token The ERC20 token address.
   */
  function token() external view returns (address _token);

  /**
   * @notice Returns the start time of the vesting period.
   * @return _startTime The start time as a UNIX timestamp.
   */
  function start_time() external view returns (uint256 _startTime);

  /**
   * @notice Returns the end time of the vesting period.
   * @return _endTime The end time as a UNIX timestamp.
   */
  function end_time() external view returns (uint256 _endTime);

  /**
   * @notice Returns the cliff length in seconds.
   * @return _cliffLength The cliff length in seconds.
   */
  function cliff_length() external view returns (uint256 _cliffLength);

  /**
   * @notice Returns the total amount of tokens locked in the contract.
   * @return _totalLocked The total amount of locked tokens.
   */
  function total_locked() external view returns (uint256 _totalLocked);

  /**
   * @notice Returns the total amount of tokens claimed by the recipient.
   * @return totalClaimed The total amount of claimed tokens.
   */
  function total_claimed() external view returns (uint256 totalClaimed);

  /**
   * @notice Returns the timestamp at which the token flow was disabled, if ever.
   * @return _disabledAt The disable timestamp, or the end time if never disabled.
   */
  function disabled_at() external view returns (uint256 _disabledAt);

  /**
   * @notice Indicates whether anyone can claim tokens on behalf of the recipient.
   * @return _openClaim True if open claiming is enabled, false otherwise.
   */
  function open_claim() external view returns (bool _openClaim);

  /**
   * @notice Indicates whether the contract has been initialized.
   * @return _initialized True if the contract has been initialized, false otherwise.
   */
  function initialized() external view returns (bool _initialized);

  /**
   * @notice Returns the address of the owner.
   * @return owner The address of the owner.
   */
  function owner() external view returns (address owner);
}
