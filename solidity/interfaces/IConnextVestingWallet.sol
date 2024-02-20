// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

interface IConnextVestingWallet {
  /*///////////////////////////////////////////////////////////////
                             EVENTS
  //////////////////////////////////////////////////////////////*/

  /**
   * @notice Emits when the owner releases tokens
   * @param _token  The address of the released ERC20 token
   * @param _amount The amount of tokens released
   */
  event ERC20Released(address indexed _token, uint256 _amount);

  /*///////////////////////////////////////////////////////////////
                             ERRRORS
  //////////////////////////////////////////////////////////////*/

  /**
   * @notice Permission denied
   */
  error NotAllowed();

  /**
   * @notice Zero address not allowed
   */
  error ZeroAddress();

  /*///////////////////////////////////////////////////////////////
                            CONSTANTS
  //////////////////////////////////////////////////////////////*/

  /**
   * @notice NEXT token address
   * @return _nextToken The address of the NEXT token
   */
  function NEXT_TOKEN() external view returns (address _nextToken);

  /**
   * @notice Token launch date
   * @return _timestamp The timestamp of the token launch
   */
  function NEXT_TOKEN_LAUNCH() external view returns (uint64 _timestamp);

  /**
   * @notice 1 month in seconds (on average)
   * @return _timedelta The timedelta of one month
   */
  function ONE_MONTH() external view returns (uint64 _timedelta);

  /**
   * @notice 1 year in seconds
   * @return _timedelta The timedelta of one year
   */
  function ONE_YEAR() external view returns (uint64 _timedelta);

  /**
   * @notice Sept 5th 2023 in seconds
   * @return _timestamp The timestamp of Sept 5th 2023
   */
  function SEPT_05_2023() external view returns (uint64 _timestamp);

  /**
   * @notice Vesting cliff duration
   * @return _timedelta The timedelta of the cliff duration
   */
  function VESTING_CLIFF_DURATION() external view returns (uint64 _timedelta);

  /**
   * @notice Vesting duration including one month of cliff
   * @return _timedelta The timedelta of the vesting duration
   */
  function VESTING_DURATION() external view returns (uint64 _timedelta);

  /**
   * @notice Vesting warmup time
   * @return _timedelta The timedelta of the warmup time
   */
  function VESTING_OFFSET() external view returns (uint64 _timedelta);

  /**
   * @notice Vesting start date
   * @return _timestamp The timestamp of the start date
   */
  function VESTING_START_DATE() external view returns (uint64 _timestamp);

  /**
   * @notice Vesting cliff date
   * @return _timestamp The timestamp of the cliff date
   */
  function VESTING_CLIFF() external view returns (uint64 _timestamp);

  /**
   * @notice Vesting start date
   * @return _timestamp The timestamp of the start date
   */
  function VESTING_START() external view returns (uint64 _timestamp);

  /*///////////////////////////////////////////////////////////////
                             STORAGE
  //////////////////////////////////////////////////////////////*/

  /**
   * @notice Total amount of tokens to be vested
   * @return _amount The total amount of tokens
   */
  function TOTAL_AMOUNT() external view returns (uint256 _amount);

  /**
   * @notice The amount of NEXT tokens that are already released
   * @return _released The amount of tokens released
   */
  function released() external view returns (uint256 _released);

  /*///////////////////////////////////////////////////////////////
                            VESTING LOGIC
  //////////////////////////////////////////////////////////////*/

  /**
   * @notice Claim tokens from Llama Vesting contract
   * @param _llamaVestAddress  The address of the Llama Vesting contract
   */
  function claim(address _llamaVestAddress) external;

  /**
   * @notice Collect dust from the contract
   * @param _token  The address of the token to withdraw
   * @param _amount The amount of tokens to withdraw
   * @param _to     The address to send the tokens to
   */
  function sendDust(IERC20 _token, uint256 _amount, address _to) external;

  /**
   * @notice Release releasable NEXT tokens to the owner
   */
  function release() external;

  /**
   * @notice Calculate the amount of NEXT tokens vested at a given timestamp
   * @param _timestamp  The timestamp to calculate the vested amount
   * @return _amount The amount of tokens vested
   */
  function vestedAmount(uint64 _timestamp) external view returns (uint256 _amount);

  /**
   * @notice Calculate the amount of NEXT tokens ready to release
   * @return _amount The amount of tokens ready to release
   */
  function releasable() external view returns (uint256 _amount);
}
