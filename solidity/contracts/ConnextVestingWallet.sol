// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {VestingWalletWithCliff} from './VestingWalletWithCliff.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract ConnextVestingWallet is VestingWalletWithCliff {
  address constant BENEFICIARY_ADDRESS = address(420);
  address constant CONNEXT_TOKEN_ADDRESS = address(420);

  uint64 constant ONE_YEAR = 365 days;
  uint64 constant AUG_01_2023 = 12_345_678;
  uint64 constant VESTING_OFFSET = ONE_YEAR - ONE_YEAR / 12;

  uint64 constant VESTING_START_DATE = AUG_01_2023 + VESTING_OFFSET;
  uint64 constant VESTING_DURATION = ONE_YEAR * 13 / 12;
  uint64 constant VESTING_CLIFF_DURATION = ONE_YEAR / 12;

  uint256 constant TOTAL_AMOUNT = 2_000_000;

  constructor()
    VestingWalletWithCliff(BENEFICIARY_ADDRESS, VESTING_START_DATE, VESTING_DURATION, VESTING_CLIFF_DURATION)
  {}

  error NoVestingAgreement();

  function vestedAmount(uint64) public view virtual override returns (uint256) {
    revert NoVestingAgreement();
  }

  /**
   * @dev Calculates the amount of tokens that has already vested.
   */
  function vestedAmount(address _token, uint64 _timestamp) public view virtual override returns (uint256) {
    if (_token != CONNEXT_TOKEN_ADDRESS) revert NoVestingAgreement();
    return _vestingSchedule(TOTAL_AMOUNT, _timestamp);
  }

  function releasable() public view virtual override returns (uint256) {
    revert NoVestingAgreement();
  }

  function releasable(address _token) public view virtual override returns (uint256 _amount) {
    if (_token != CONNEXT_TOKEN_ADDRESS) revert NoVestingAgreement();

    _amount = vestedAmount(_token, uint64(block.timestamp)) - released(_token);
    uint256 _balance = IERC20(_token).balanceOf(address(this));
    _amount = _balance < _amount ? _balance : _amount;
  }

  error ZeroAddress();

  function sendDust(IERC20 _token, uint256 _amount, address _to) external onlyOwner {
    if (_to == address(0)) revert ZeroAddress();
    if (_token == IERC20(CONNEXT_TOKEN_ADDRESS) && released(CONNEXT_TOKEN_ADDRESS) != TOTAL_AMOUNT) {
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
