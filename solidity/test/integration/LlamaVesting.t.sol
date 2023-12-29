// SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

import {IntegrationBase} from 'test/integration/IntegrationBase.sol';

contract IntegrationLlamaVesting is IntegrationBase {
  function test_CreateStream() public {
    vm.prank(_alice);
    _llamaPay.createStream(address(_unlock), _PAY_PER_SEC);
    (uint40 _lastPayerUpdate, uint216 _totalPaidPerSec) = _llamaPay.payers(_alice);
    assertEq(_totalPaidPerSec, _PAY_PER_SEC);
    assertEq(_lastPayerUpdate, uint40(block.timestamp));
  }

  function test_Deposit() public {
    uint256 _amount = 1 ether;
    deal(address(_nextToken), _alice, _amount);
    vm.startPrank(_alice);

    _llamaPay.createStream(address(_unlock), _PAY_PER_SEC);
    _nextToken.approve(address(_llamaPay), _amount);
    _llamaPay.deposit(_amount);
    assertEq(_llamaPay.balances(_alice), _amount * 1e2); // decimal devisor +2 decimals

    vm.stopPrank();
  }

  function test_depositAndCreate() public {
    uint256 _amount = 1 ether;
    deal(address(_nextToken), _alice, _amount);
    vm.startPrank(_alice);

    _nextToken.approve(address(_llamaPay), _amount);
    _llamaPay.depositAndCreate(_amount, address(_unlock), _PAY_PER_SEC);
    assertEq(_llamaPay.balances(_alice), _amount * 1e2); // decimal devisor +2 decimals
    (uint40 _lastPayerUpdate, uint216 _totalPaidPerSec) = _llamaPay.payers(_alice);
    assertEq(_totalPaidPerSec, _PAY_PER_SEC);
    assertEq(_lastPayerUpdate, uint40(block.timestamp));

    assertEq(_nextToken.balanceOf(_alice), 0);
    assertEq(_nextToken.balanceOf(address(_llamaPay)), 1 ether);

    vm.stopPrank();
  }

  // todo: add tests for other functions in ILlamaPay + integration tests
}
