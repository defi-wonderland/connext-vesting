// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {VestingWalletWithCliff} from './VestingWalletWithCliff.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract ConnextVestingWallet is VestingWalletWithCliff {
  address constant BENEFICIARY_ADDRESS = 0x74fEa3FB0eD030e9228026E7F413D66186d3D107;
  address constant CONNEXT_TOKEN_ADDRESS = 0xFE67A4450907459c3e1FFf623aA927dD4e28c67a;

  uint64 constant ONE_YEAR = 365 days;
  uint64 constant SEPT_05_2023 = 1_693_872_000;

  /**
   * @dev Vesting schedule:
   *      - 1/13 of the tokens will be released after 1 year, starting from Sept 5th 2023
   *      - 1/13 of the tokens will be released every month after that, for 12 months
   * 
   *     The equivalent vesting schedule has a 13 months duration, with a 1 month cliff, offsetted to
   *     start from `Sept 5th 2024 - 1 month`: At Sept 5th 2024 the cliff is triggered unlocking
   *     1/13 of the tokens, and then 1/13 of the tokens will be linearly unlocked every month after that.
   */
  uint64 constant VESTING_OFFSET = ONE_YEAR - ONE_YEAR / 12;
  uint64 constant VESTING_START_DATE = SEPT_05_2023 + VESTING_OFFSET;
  uint64 constant VESTING_DURATION = ONE_YEAR * 13 / 12;
  uint64 constant VESTING_CLIFF_DURATION = ONE_YEAR / 12;

  uint256 constant TOTAL_AMOUNT = 24_960_000 ether;

  constructor()
    VestingWalletWithCliff(BENEFICIARY_ADDRESS, VESTING_START_DATE, VESTING_DURATION, VESTING_CLIFF_DURATION)
  {}

  error NoVestingAgreement();
  error ZeroAddress();

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
