// SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

import {IntegrationBase} from 'test/integration/IntegrationBase.sol';

import {IERC20} from 'isolmate/interfaces/tokens/IERC20.sol';
import {ILlamaPayFactory} from 'test/utils/ILlamaPayFactory.sol';

contract IntegrationLlamaVesting is IntegrationBase {
  function test_CreateStream() public {
    vm.prank(_alice);
    _llamaPay.createStream(address(_unlock), _PAY_PER_SEC);
    (uint40 lastPayerUpdate, uint216 totalPaidPerSec) = _llamaPay.payers(_alice);
    assertEq(totalPaidPerSec, _PAY_PER_SEC);
    assertEq(lastPayerUpdate, uint40(block.timestamp));
  }

  function test_Deposit() public {
    uint256 amount = 1 ether;
    deal(_nextToken, _alice, amount);
    vm.startPrank(_alice);

    _llamaPay.createStream(address(_unlock), _PAY_PER_SEC);
    IERC20(_nextToken).approve(address(_llamaPay), amount);
    _llamaPay.deposit(amount);
    assertEq(_llamaPay.balances(_alice), amount * 1e2); // decimal devisor +2 decimals

    vm.stopPrank();
  }

  function test_depositAndCreate() public {
    uint256 amount = 1 ether;
    deal(_nextToken, _alice, amount);
    vm.startPrank(_alice);

    IERC20(_nextToken).approve(address(_llamaPay), amount);
    _llamaPay.depositAndCreate(amount, address(_unlock), _PAY_PER_SEC);
    assertEq(_llamaPay.balances(_alice), amount * 1e2); // decimal devisor +2 decimals
    (uint40 lastPayerUpdate, uint216 totalPaidPerSec) = _llamaPay.payers(_alice);
    assertEq(totalPaidPerSec, _PAY_PER_SEC);
    assertEq(lastPayerUpdate, uint40(block.timestamp));

    assertEq(IERC20(_nextToken).balanceOf(_alice), 0);
    assertEq(IERC20(_nextToken).balanceOf(address(_llamaPay)), 1 ether);

    vm.stopPrank();
  }

  // todo: add tests for other functions in ILlamaPay + integration tests
}
