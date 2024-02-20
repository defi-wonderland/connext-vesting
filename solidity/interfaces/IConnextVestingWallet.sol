// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

interface IConnextVestingWallet {
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
   * @dev Mainnet address
   * @return _nextToken The address of the NEXT token
   */
  function NEXT_TOKEN() external view returns (address _nextToken);

  /**
   * @notice Token launch date
   * @dev Equals to Sept 5th 2023
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
   * @return _timedelta The timestamp of Sept 5th 2023
   */
  function SEPT_05_2023() external view returns (uint64 _timedelta);

  /**
   * @notice Vesting cliff duration
   * @dev 1 month cliff
   * @return _timedelta The timedelta of the cliff duration
   */
  function VESTING_CLIFF_DURATION() external view returns (uint64 _timedelta);

  /**
   * NOTE:  The equivalent vesting schedule has a 13 months duration, with a 1 month cliff,
   *        offsetted to start from `Sept 5th 2024 - 1 month`: At Sept 5th 2024 the cliff
   *        is triggered unlocking 1/13 of the tokens, and then 1/13 of the tokens will
   *        be linearly unlocked every month after that.
   */

  /**
   * @notice Vesting duration including one month of cliff
   * @dev 13 months duration
   * @return _timedelta The timedelta of the vesting duration
   */
  function VESTING_DURATION() external view returns (uint64 _timedelta);

  /**
   * @notice Vesting warmup time
   * @dev 11 months offset
   * @return _timedelta The timedelta of the warmup time
   */
  function VESTING_OFFSET() external view returns (uint64 _timedelta);

  /**
   * @notice Vesting start date
   * @dev Sept 5th 2024 - 1 month
   * @return _timestamp The timestamp of the start date
   */
  function VESTING_START_DATE() external view returns (uint64 _timestamp);

  /*///////////////////////////////////////////////////////////////
                             STORAGE
  //////////////////////////////////////////////////////////////*/

  /**
   * @notice Total amount of tokens to be vested
   * @dev Set into constructor
   * @return _amount The total amount of tokens
   */
  function TOTAL_AMOUNT() external view returns (uint256 _amount);

  /**
   * @notice The cliff timestamp
   * @dev Set into constructor
   * @return _timestamp The timestamp of the cliff
   */
  function CLIFF() external view returns (uint64 _timestamp);

  /*///////////////////////////////////////////////////////////////
                            CUSTOM LOGIC
  //////////////////////////////////////////////////////////////*/

  /**
   * @notice Claim tokens from Llama Vesting contract
   * @dev This func is needed because only the recipients can claim
   * @param _llamaVestAddress  The address of the Llama Vesting contract
   */
  function claim(address _llamaVestAddress) external;

  /**
   * @notice Collect dust from the contract
   * @dev This contract allows to withdraw any token, with the exception of unlocked NEXT tokens
   * @param _token  The address of the token to withdraw
   * @param _amount The amount of tokens to withdraw
   * @param _to     The address to send the tokens to
   */
  function sendDust(IERC20 _token, uint256 _amount, address _to) external;
}
