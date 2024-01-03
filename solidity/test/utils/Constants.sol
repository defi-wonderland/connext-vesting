// SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

contract Constants {
  // Rounding error up to 1 token
  uint256 public constant MAX_DELTA = 1 ether;

  // The block to use for integration tests
  uint256 public constant FORK_BLOCK = 18_927_563;

  // The total amount of tokens to be vested
  uint256 public constant TOTAL_AMOUNT = 24_960_000 ether;

  // The amount of tokens to be streamed per second, TOTAL_AMOUNT / 4 years, with 20 decimals
  uint216 public constant PAY_PER_SECOND = 0.19786910197869101978 * 1e20;

  address public constant NEXT_TOKEN_ADDRESS = 0xFE67A4450907459c3e1FFf623aA927dD4e28c67a;
  address public constant LLAMA_FACTORY_ADDRESS = 0xde1C04855c2828431ba637675B6929A684f84C7F;
}
