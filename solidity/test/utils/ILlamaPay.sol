// SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

interface ILlamaPay {
  function token() external view returns (address _token);
  function payers(address _payer) external view returns (uint40 _lastPayerUpdate, uint216 _totalPaidPerSec);
  function balances(address _payer) external view returns (uint256 _balance);
  function createStream(address to, uint216 amountPerSec) external;
  function depositAndCreate(uint256 amountToDeposit, address to, uint216 amountPerSec) external;
  function deposit(uint256 amount) external;
  function modifyStream(address oldTo, uint216 oldAmountPerSec, address to, uint216 amountPerSec) external;
  function pauseStream(address to, uint216 amountPerSec) external;
}
