// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
import {Ownable2Step} from '@openzeppelin/contracts/access/Ownable2Step.sol';
import {VestingWallet} from '@openzeppelin/contracts/finance/VestingWallet.sol';
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
contract ConnextVestingWallet is VestingWallet, Ownable2Step, IConnextVestingWallet {
  /// @inheritdoc IConnextVestingWallet
  uint64 public constant ONE_YEAR = 365 days;

  /// @inheritdoc IConnextVestingWallet
  uint64 public constant ONE_MONTH = ONE_YEAR / 12;

  /// @inheritdoc IConnextVestingWallet
  uint64 public constant SEPT_05_2023 = 1_693_872_000;

  /// @inheritdoc IConnextVestingWallet
  uint64 public constant NEXT_TOKEN_LAUNCH = SEPT_05_2023;

  /// @inheritdoc IConnextVestingWallet
  address public constant NEXT_TOKEN = 0xFE67A4450907459c3e1FFf623aA927dD4e28c67a;

  /// @inheritdoc IConnextVestingWallet
  uint64 public constant VESTING_DURATION = ONE_YEAR + ONE_MONTH;

  /// @inheritdoc IConnextVestingWallet
  uint64 public constant VESTING_CLIFF_DURATION = ONE_MONTH;

  /// @inheritdoc IConnextVestingWallet
  uint64 public constant VESTING_OFFSET = ONE_YEAR - ONE_MONTH;

  /// @inheritdoc IConnextVestingWallet
  uint64 public constant VESTING_START_DATE = NEXT_TOKEN_LAUNCH + VESTING_OFFSET;

  /// @inheritdoc IConnextVestingWallet
  uint256 public immutable TOTAL_AMOUNT;

  /// @inheritdoc IConnextVestingWallet
  uint64 public immutable CLIFF;

  /// @param _beneficiary  The address of the beneficiary
  /// @param _totalAmount  The total amount of tokens to be unlocked
  constructor(
    address _beneficiary,
    uint256 _totalAmount
  ) VestingWallet(_beneficiary, VESTING_START_DATE, VESTING_DURATION) {
    CLIFF = VESTING_START_DATE + VESTING_CLIFF_DURATION;
    TOTAL_AMOUNT = _totalAmount;
  }

  /// This contract is only meant to unlock NEXT tokens
  /// @inheritdoc VestingWallet
  function vestedAmount(uint64) public view virtual override returns (uint256 _amount) {
    return 0;
  }

  /// We use custom vesting logic with cliffs and linear unlocking
  /// @inheritdoc VestingWallet
  function vestedAmount(address _token, uint64 _timestamp) public view virtual override returns (uint256 _amount) {
    if (_token != NEXT_TOKEN || _timestamp < CLIFF) {
      return 0;
    } else if (_timestamp >= end()) {
      return TOTAL_AMOUNT;
    } else {
      return (TOTAL_AMOUNT * (_timestamp - start())) / duration();
    }
  }

  /// This contract is only meant to unlock NEXT tokens
  /// @inheritdoc VestingWallet
  function releasable(address _token) public view virtual override returns (uint256 _amount) {
    _amount = vestedAmount(_token, uint64(block.timestamp)) - released(_token);
    uint256 _balance = IERC20(_token).balanceOf(address(this));
    _amount = _balance < _amount ? _balance : _amount;
  }

  /// Override needed by linearization
  /// @inheritdoc Ownable2Step
  function _transferOwnership(address _newOwner) internal virtual override(Ownable2Step, Ownable) {
    super._transferOwnership(_newOwner);
  }

  /// Override needed by linearization
  /// @inheritdoc Ownable2Step
  function transferOwnership(address _newOwner) public virtual override(Ownable2Step, Ownable) {
    super.transferOwnership(_newOwner);
  }

  /// @inheritdoc IConnextVestingWallet
  function sendDust(IERC20 _token, uint256 _amount, address _to) external onlyOwner {
    if (_to == address(0)) revert ZeroAddress();

    if (_token == IERC20(NEXT_TOKEN) && released(NEXT_TOKEN) != TOTAL_AMOUNT) {
      revert NotAllowed();
    }

    if (_token == IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)) {
      payable(_to).transfer(_amount); // Sending ETH
    } else {
      _token.transfer(_to, _amount); // Sending ERC20s
    }
  }

  /// @inheritdoc IConnextVestingWallet
  function claim(address _llamaVestAddress) external {
    IVestingEscrowSimple(_llamaVestAddress).claim(address(this));
  }
}
