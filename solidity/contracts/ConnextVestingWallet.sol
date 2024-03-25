// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
import {Ownable2Step} from '@openzeppelin/contracts/access/Ownable2Step.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

import {IConnextVestingWallet} from 'interfaces/IConnextVestingWallet.sol';
import {IVestingEscrowSimple} from 'interfaces/IVestingEscrowSimple.sol';

/**
 * @title   ConnextVestingWallet
 * NOTE:    The NEXT tokens will be subject to a twenty-four (24) months unlock schedule as follows:
 *          1/13 (~7.69% of the token grant) unlocks at the 1 year mark from NEXT token launch,
 *          and 1/13 unlocks every month thereafter for 12 months. All tokens are unlocked after 24 months.
 *          https://forum.connext.network/t/rfc-partnership-token-agreements/938
 */
contract ConnextVestingWallet is Ownable2Step, IConnextVestingWallet {
  /// @inheritdoc IConnextVestingWallet
  uint64 public constant ONE_YEAR = 365 days;

  /// @inheritdoc IConnextVestingWallet
  uint64 public constant ONE_MONTH = ONE_YEAR / 12;

  /// @inheritdoc IConnextVestingWallet
  uint64 public constant SEPT_05_2023 = 1_693_872_000;

  /// @inheritdoc IConnextVestingWallet
  uint64 public constant NEXT_TOKEN_LAUNCH = SEPT_05_2023; // Equals to Sept 5th 2023

  /// @inheritdoc IConnextVestingWallet
  IERC20 public constant NEXT_TOKEN = IERC20(0xFE67A4450907459c3e1FFf623aA927dD4e28c67a); // Mainnet NEXT token address

  /// @inheritdoc IConnextVestingWallet
  uint64 public constant UNLOCK_DURATION = ONE_YEAR + ONE_MONTH; // 13 months duration

  /// @inheritdoc IConnextVestingWallet
  uint64 public constant UNLOCK_CLIFF_DURATION = ONE_MONTH; // 1 month cliff

  /// @inheritdoc IConnextVestingWallet
  uint64 public constant UNLOCK_OFFSET = ONE_YEAR - ONE_MONTH; // 11 months offset

  /// @inheritdoc IConnextVestingWallet
  uint64 public constant UNLOCK_START = NEXT_TOKEN_LAUNCH + UNLOCK_OFFSET; // Sept 5th 2024 - 1 month

  /// @inheritdoc IConnextVestingWallet
  uint64 public constant UNLOCK_CLIFF = UNLOCK_START + UNLOCK_CLIFF_DURATION; // Sept 5th 2024

  /// @inheritdoc IConnextVestingWallet
  uint64 public constant UNLOCK_END = UNLOCK_START + UNLOCK_DURATION; // Sept 5th 2025

  /// @inheritdoc IConnextVestingWallet
  uint256 public immutable TOTAL_AMOUNT; // Set into constructor

  /// @inheritdoc IConnextVestingWallet
  uint256 public released;

  /**
   * @param _owner The address of the beneficiary
   * @param _totalAmount The total amount of tokens to be unlocked
   */
  constructor(address _owner, uint256 _totalAmount) Ownable(_owner) {
    TOTAL_AMOUNT = _totalAmount;
  }

  /**
   * NOTE:  The equivalent unlock schedule has a 13 months duration, with a 1 month cliff,
   *        offsetted to start from `Sept 5th 2024 - 1 month`: At Sept 5th 2024 the cliff
   *        is triggered unlocking 1/13 of the tokens, and then 1/13 of the tokens will
   *        be linearly unlocked every month after that.
   */

  /// @inheritdoc IConnextVestingWallet
  function vestedAmount(uint64 _timestamp) public view returns (uint256 _amount) {
    if (_timestamp < UNLOCK_CLIFF) {
      return 0;
    } else if (_timestamp >= UNLOCK_END) {
      return TOTAL_AMOUNT;
    } else {
      return (TOTAL_AMOUNT * (_timestamp - UNLOCK_START)) / UNLOCK_DURATION;
    }
  }

  /// @inheritdoc IConnextVestingWallet
  function release() public {
    uint256 _amount = releasable();
    released += _amount;
    NEXT_TOKEN.transfer(owner(), _amount);
    emit ERC20Released(address(NEXT_TOKEN), _amount);
  }

  /// @inheritdoc IConnextVestingWallet
  function releasable() public view returns (uint256 _amount) {
    _amount = vestedAmount(uint64(block.timestamp)) - released;
    uint256 _balance = NEXT_TOKEN.balanceOf(address(this));
    _amount = _balance < _amount ? _balance : _amount;
  }

  /**
   * @inheritdoc IConnextVestingWallet
   * @dev This contract allows to withdraw any token, with the exception of unlocked NEXT tokens
   */
  function sendDust(IERC20 _token, uint256 _amount, address _to) external onlyOwner {
    if (_to == address(0)) revert ZeroAddress();

    if (_token == NEXT_TOKEN && (released != TOTAL_AMOUNT || block.timestamp < UNLOCK_END)) {
      revert NotAllowed();
    }

    if (_token == IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)) {
      payable(_to).transfer(_amount); // Sending ETH
    } else {
      _token.transfer(_to, _amount); // Sending ERC20s
    }
  }

  /**
   * @inheritdoc IConnextVestingWallet
   * @dev This func is needed because only the recipients can claim
   */
  function claim(IVestingEscrowSimple _llamaVest) external {
    _llamaVest.claim(address(this));
  }
}
