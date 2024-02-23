// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract Constants {
  // Rounding error up to 1 token
  uint256 public constant MAX_DELTA = 1 ether;

  // The block to use for integration tests
  uint256 public constant FORK_BLOCK = 19_012_745;

  // The total amount of tokens to be vested
  uint256 public constant TOTAL_AMOUNT = 24_960_000 ether;

  address public constant DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
  address public constant NEXT_TOKEN_ADDRESS = 0xFE67A4450907459c3e1FFf623aA927dD4e28c67a;
  address public constant LLAMA_FACTORY_ADDRESS = 0xB93427b83573C8F27a08A909045c3e809610411a;

  // Vesting info
  uint64 public constant AUG_01_2022 = 1_659_312_000; // vesting start date
  uint64 public constant SEP_05_2023 = 1_693_872_000; // launch date
  uint64 public constant VESTING_DURATION = 365 days * 4;

  // Time
  uint64 public constant YEAR = 365 days;
  uint64 public constant MONTH = 365 days / 12;
}
