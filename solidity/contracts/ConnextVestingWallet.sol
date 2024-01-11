// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// solhint-disable-next-line no-unused-import
import {VestingWallet, VestingWalletWithCliff} from './VestingWalletWithCliff.sol';

import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
import {Ownable2Step} from '@openzeppelin/contracts/access/Ownable2Step.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {IVestingEscrowSimple} from 'interfaces/IVestingEscrowSimple.sol';

/**
 * @title   ConnextVestingWallet
 * NOTE:    The NEXT tokens will be subject to a twenty-four (24) months unlock schedule as follows:
 *          1/13 (~7.69% of the token grant) unlocks at the 1 year mark from NEXT token launch,
 *          and 1/13 unlocks every month thereafter for 12 months. All tokens are unlocked after 24 months.
 *          https://forum.connext.network/t/rfc-partnership-token-agreements/938
 */
contract ConnextVestingWallet is VestingWalletWithCliff, Ownable2Step {
  /**
   * --- Constants ---
   */
  uint64 public constant ONE_YEAR = 365 days;
  uint64 public constant ONE_MONTH = ONE_YEAR / 12;
  uint64 public constant SEPT_05_2023 = 1_693_872_000;
  uint64 public constant NEXT_TOKEN_LAUNCH = SEPT_05_2023;
  address public constant NEXT_TOKEN = 0xFE67A4450907459c3e1FFf623aA927dD4e28c67a; // Mainnet NEXT token

  /**
   * NOTE:  The equivalent vesting schedule has a 13 months duration, with a 1 month cliff,
   *        offsetted to start from `Sept 5th 2024 - 1 month`: At Sept 5th 2024 the cliff
   *        is triggered unlocking 1/13 of the tokens, and then 1/13 of the tokens will
   *        be linearly unlocked every month after that.
   */
  uint64 public constant VESTING_DURATION = ONE_YEAR + ONE_MONTH; //                  13 months duration
  uint64 public constant VESTING_CLIFF_DURATION = ONE_MONTH; //                       1 month cliff
  uint64 public constant VESTING_OFFSET = ONE_YEAR - ONE_MONTH; //                    11 months offset
  uint64 public constant VESTING_START_DATE = NEXT_TOKEN_LAUNCH + VESTING_OFFSET; //  Sept 5th 2024 - 1 month

  /**
   * --- Settable Storage ---
   */
  uint256 public immutable TOTAL_AMOUNT;

  constructor(
    address _beneficiary,
    uint256 _totalAmount
  ) VestingWalletWithCliff(_beneficiary, VESTING_START_DATE, VESTING_DURATION, VESTING_CLIFF_DURATION) {
    TOTAL_AMOUNT = _totalAmount;
  }

  /**
   * --- Errors ---
   */
  error NotAllowed();
  error ZeroAddress();

  /**
   * --- Overrides ---
   */

  /**
   * @inheritdoc  VestingWallet
   * @notice      This contract is only meant to vest NEXT tokens
   */
  function vestedAmount(uint64) public view virtual override returns (uint256 _amount) {
    return 0;
  }

  /**
   * @inheritdoc  VestingWallet
   * @notice      This contract is only meant to vest NEXT tokens
   */
  function vestedAmount(address _token, uint64 _timestamp) public view virtual override returns (uint256 _amount) {
    if (_token != NEXT_TOKEN) return 0;

    return _vestingSchedule(TOTAL_AMOUNT, _timestamp);
  }

  /**
   * @inheritdoc  VestingWallet
   * @notice      This contract is only meant to vest NEXT tokens
   */
  function releasable(address _token) public view virtual override returns (uint256 _amount) {
    if (_token != NEXT_TOKEN) return 0;

    _amount = vestedAmount(_token, uint64(block.timestamp)) - released(_token);
    uint256 _balance = IERC20(_token).balanceOf(address(this));
    _amount = _balance < _amount ? _balance : _amount;
  }

  /**
   * @inheritdoc Ownable2Step
   * @dev        Override needed by linearization
   */
  function _transferOwnership(address _newOwner) internal virtual override(Ownable2Step, Ownable) {
    super._transferOwnership(_newOwner);
  }

  /**
   * @inheritdoc Ownable2Step
   * @dev        Override needed by linearization
   */
  function transferOwnership(address _newOwner) public virtual override(Ownable2Step, Ownable) {
    super.transferOwnership(_newOwner);
  }

  /**
   * --- Dust Collector ---
   * @notice      Collect dust from the contract
   * @dev         This contract allows to withdraw any token, with the exception of vested NEXT tokens
   */
  function sendDust(IERC20 _token, uint256 _amount, address _to) external onlyOwner {
    if (_to == address(0)) revert ZeroAddress();
    if (_token == IERC20(NEXT_TOKEN) && released(NEXT_TOKEN) != TOTAL_AMOUNT) {
      revert NotAllowed();
    }

    if (_token == IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)) {
      // Sending ETH
      payable(_to).transfer(_amount);
    } else {
      // Sending ERC20s
      _token.transfer(_to, _amount);
    }
  }

  /**
   * --- Claim ---
   * @notice      Claim tokens from Llama Vesting contract
   * @dev         This func is needed because only the recipients can claim
   */
  function claim(address _llamaVestAddress) external onlyOwner {
    IVestingEscrowSimple(_llamaVestAddress).claim(address(this));
  }
}
