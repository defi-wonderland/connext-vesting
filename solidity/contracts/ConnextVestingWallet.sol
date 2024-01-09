// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {VestingWallet, VestingWalletWithCliff} from './VestingWalletWithCliff.sol';

import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
import {Ownable2Step} from '@openzeppelin/contracts/access/Ownable2Step.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

/**
 * @dev Vesting schedule:
 *      - 1/13 of the tokens will be released after 1 year, starting from _initTimestamp
 *      - 1/13 of the tokens will be released every month after that, for 12 months
 *
 *     The equivalent vesting schedule has a 13 months duration, with a 1 month cliff, offsetted to
 *     start from e.g. Jan 1st 2023: At Feb 1st 2023 the cliff is triggered unlocking
 *     1/13 of the tokens, and then 1/13 of the tokens will be linearly unlocked every month after that.
 */
contract ConnextVestingWallet is VestingWalletWithCliff, Ownable2Step {
  uint64 public constant ONE_YEAR = 365 days;
  uint64 public constant ONE_MONTH = ONE_YEAR / 12;
  address public constant PAYMENT_TOKEN = 0xFE67A4450907459c3e1FFf623aA927dD4e28c67a; // Mainnet NEXT token

  uint64 public constant VESTING_OFFSET = ONE_YEAR - ONE_MONTH;
  uint64 public constant VESTING_DURATION = ONE_YEAR + ONE_MONTH;
  uint64 public constant VESTING_CLIFF_DURATION = ONE_MONTH;

  uint64 public initTimestamp;
  uint256 public totalAmount;

  constructor(
    uint64 _initTimestamp,
    address _beneficiary,
    uint256 _totalAmount
  ) VestingWalletWithCliff(_beneficiary, _initTimestamp + VESTING_OFFSET, VESTING_DURATION, VESTING_CLIFF_DURATION) {
    totalAmount = _totalAmount;
    initTimestamp = _initTimestamp;
  }

  error NoVestingAgreement();
  error ZeroAddress();

  /// @inheritdoc VestingWallet
  /// @dev This contract is only meant to vest CONNEXT tokens
  function vestedAmount(uint64) public view virtual override returns (uint256 _amount) {
    revert NoVestingAgreement();
  }

  /// @inheritdoc VestingWallet
  /// @dev This contract is only meant to vest CONNEXT tokens
  function vestedAmount(address _token, uint64 _timestamp) public view virtual override returns (uint256 _amount) {
    if (_token != PAYMENT_TOKEN) revert NoVestingAgreement();

    return _vestingSchedule(totalAmount, _timestamp);
  }

  /// @inheritdoc VestingWallet
  /// @dev This contract is only meant to vest CONNEXT tokens
  function releasable() public view virtual override returns (uint256 _amount) {
    revert NoVestingAgreement();
  }

  /// @inheritdoc VestingWallet
  /// @dev This contract is only meant to vest CONNEXT tokens
  function releasable(address _token) public view virtual override returns (uint256 _amount) {
    if (_token != PAYMENT_TOKEN) revert NoVestingAgreement();

    _amount = vestedAmount(_token, uint64(block.timestamp)) - released(_token);
    uint256 _balance = IERC20(_token).balanceOf(address(this));
    _amount = _balance < _amount ? _balance : _amount;
  }

  /// @inheritdoc Ownable2Step
  /// @dev override to aviod linearization
  function _transferOwnership(address _newOwner) internal virtual override(Ownable2Step, Ownable) {
    super._transferOwnership(_newOwner);
  }

  /// @inheritdoc Ownable2Step
  /// @dev override to aviod linearization
  function transferOwnership(address _newOwner) public virtual override(Ownable2Step, Ownable) {
    super.transferOwnership(_newOwner);
  }

  /// @notice Collect dust from the contract
  /// @dev This contract allows to withdraw any token, with the exception of vested CONNEXT tokens
  function sendDust(IERC20 _token, uint256 _amount, address _to) external onlyOwner {
    if (_to == address(0)) revert ZeroAddress();
    if (_token == IERC20(PAYMENT_TOKEN) && released(PAYMENT_TOKEN) != totalAmount) {
      revert NoVestingAgreement();
    }

    if (_token == IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)) {
      // Sending ETH
      payable(_to).transfer(_amount);
    } else {
      // Sending ERC20s
      _token.transfer(_to, _amount);
    }
  }
}
