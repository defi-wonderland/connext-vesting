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
   */
  function NEXT_TOKEN() external view returns (address);

  /**
   * @notice Token launch date
   * @dev Equals to Sept 5th 2023
   */
  function NEXT_TOKEN_LAUNCH() external view returns (uint64);

  /**
   * @notice 1 month in seconds (on average)
   */
  function ONE_MONTH() external view returns (uint64);

  /**
   * @notice 1 year in seconds
   */
  function ONE_YEAR() external view returns (uint64);

  /**
   * @notice Sept 5th 2023 in seconds
   */
  function SEPT_05_2023() external view returns (uint64);

  /**
   * @notice Vesting cliff duration
   * @dev 1 month cliff
   */
  function VESTING_CLIFF_DURATION() external view returns (uint64);

  /**
   * NOTE:  The equivalent vesting schedule has a 13 months duration, with a 1 month cliff,
   *        offsetted to start from `Sept 5th 2024 - 1 month`: At Sept 5th 2024 the cliff
   *        is triggered unlocking 1/13 of the tokens, and then 1/13 of the tokens will
   *        be linearly unlocked every month after that.
   */

  /**
   * @notice Vesting duration including one month of cliff
   * @dev 13 months duration
   */
  function VESTING_DURATION() external view returns (uint64);

  /**
   * @notice Vesting warmup time
   * @dev 11 months offset
   */
  function VESTING_OFFSET() external view returns (uint64);

  /**
   * @notice Vesting start date
   * @dev Sept 5th 2024 - 1 month
   */
  function VESTING_START_DATE() external view returns (uint64);

  /*///////////////////////////////////////////////////////////////
                             STORAGE
  //////////////////////////////////////////////////////////////*/

  /**
   * @notice Total amount of tokens to be vested
   * @dev Set into constructor
   */
  function TOTAL_AMOUNT() external view returns (uint256);

  /**
   * @notice The cliff timestamp
   * @dev Set into constructor
   */
  function CLIFF() external view returns (uint64);

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
