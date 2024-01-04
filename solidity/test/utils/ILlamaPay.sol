// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface ILlamaPay {
  function token() external view returns (address _token);
  function payers(address _payer) external view returns (uint40 _lastPayerUpdate, uint216 _totalPaidPerSec);
  function balances(address _payer) external view returns (uint256 _balance);
  function getPayerBalance(address _payer) external view returns (uint256 _balance);

  function createStream(address _to, uint216 _amountPerSec) external;
  function depositAndCreate(uint256 _amountToDeposit, address _to, uint216 _amountPerSec) external;
  function deposit(uint256 _amount) external;
  function withdraw(address _from, address _to, uint216 _amountPerSec) external;
  function modifyStream(address _oldTo, uint216 _oldAmountPerSec, address _to, uint216 _amountPerSec) external;
  function pauseStream(address _to, uint216 _amountPerSec) external;
}
