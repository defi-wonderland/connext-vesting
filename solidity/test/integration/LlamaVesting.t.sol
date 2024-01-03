// SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

import {IntegrationBase} from 'test/integration/IntegrationBase.sol';

import {console} from 'forge-std/console.sol';

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
    assertEq(_nextToken.balanceOf(address(_llamaPay)), _amount);
    assertEq(_nextToken.balanceOf(_alice), 0);

    vm.stopPrank();
  }

  function test_depositAndCreate() public {
    uint256 _amount = 1 ether;
    deal(address(_nextToken), _alice, _amount);
    vm.startPrank(_alice);

    _nextToken.approve(address(_llamaPay), _amount);
    _llamaPay.depositAndCreate(_amount, address(_unlock), _PAY_PER_SEC);
    assertEq(_llamaPay.balances(_alice), _amount * 1e2); // decimal devisor +2 decimals
    assertEq(_nextToken.balanceOf(address(_llamaPay)), _amount);
    assertEq(_nextToken.balanceOf(_alice), 0);

    (uint40 _lastPayerUpdate, uint216 _totalPaidPerSec) = _llamaPay.payers(_alice);
    assertEq(_totalPaidPerSec, _PAY_PER_SEC);
    assertEq(_lastPayerUpdate, uint40(block.timestamp));

    assertEq(_nextToken.balanceOf(_alice), 0);
    assertEq(_nextToken.balanceOf(address(_llamaPay)), 1 ether);

    vm.stopPrank();
  }

  function test_ModifyStream() public {
    uint256 _amount = 1 ether;
    deal(address(_nextToken), _alice, _amount);
    vm.startPrank(_alice);
    _nextToken.approve(address(_llamaPay), _amount);
    _llamaPay.depositAndCreate(_amount, address(_unlock), _PAY_PER_SEC);
    vm.stopPrank();

    // somebody modifies the stream
    vm.prank(_owner);
    // solhint-disable-next-line quotes
    vm.expectRevert("stream doesn't exist");
    _llamaPay.modifyStream(address(_unlock), _PAY_PER_SEC, address(_unlock), _PAY_PER_SEC * 2);
    (, uint216 _totalPaidPerSec) = _llamaPay.payers(_alice);
    assertEq(_totalPaidPerSec, _PAY_PER_SEC); // nothing changed for alice

    // alice modifies the stream
    vm.prank(_alice);
    _llamaPay.modifyStream(address(_unlock), _PAY_PER_SEC, address(_unlock), _PAY_PER_SEC * 2);
    (, _totalPaidPerSec) = _llamaPay.payers(_alice);
    assertEq(_totalPaidPerSec, _PAY_PER_SEC * 2); // changed for alice
  }

  function test_PauseStream() public {
    uint256 _amount = 1 ether;
    deal(address(_nextToken), _alice, _amount);

    vm.startPrank(_alice);
    _nextToken.approve(address(_llamaPay), _amount);
    _llamaPay.depositAndCreate(_amount, address(_unlock), _PAY_PER_SEC);
    vm.stopPrank();

    // somebody pauses the stream
    vm.prank(_owner);
    // solhint-disable-next-line quotes
    vm.expectRevert("stream doesn't exist");
    _llamaPay.pauseStream(address(_unlock), _PAY_PER_SEC);
    (, uint216 _totalPaidPerSec) = _llamaPay.payers(_alice);
    assertEq(_totalPaidPerSec, _PAY_PER_SEC); // nothing changed for alice

    vm.warp(block.timestamp + 1 days); // wait for 1 day

    // alice pauses the stream
    vm.prank(_alice);
    _llamaPay.pauseStream(address(_unlock), _PAY_PER_SEC);
    (, _totalPaidPerSec) = _llamaPay.payers(_alice);
    assertEq(_totalPaidPerSec, 0); // changed for alice
    assertEq(_amount - _nextToken.balanceOf(address(_unlock)) < 0.1 ether, true); // unlock got its tokens (with rounding)
  }

  function test_VestAndUnlock() public {
    deal(address(_nextToken), _owner, _TOTAL_AMOUNT);

    vm.startPrank(_owner);

    uint256 _vestingStartTime = block.timestamp;
    _nextToken.approve(address(_llamaPay), _TOTAL_AMOUNT);
    _llamaPay.depositAndCreate(_TOTAL_AMOUNT, address(_unlock), _PAY_PER_SEC);

    // before 1st milestone
    uint256 _timePassed = _unlockStartTime + 364 days;
    uint256 _vestedAmount = (_timePassed - _vestingStartTime) * _PAY_PER_SEC / 1e2;
    uint256 _unlockedAmount = 0;
    vm.warp(_timePassed);

    _llamaPay.withdraw(_owner, address(_unlock), _PAY_PER_SEC);
    assertEq(_nextToken.balanceOf(address(_unlock)), _vestedAmount); // unlock got its tokens
    _unlock.withdraw(_owner);
    assertEq(_unlock.withdrawnSupply(), _unlockedAmount); // not unlocked yet
    assertEq(_nextToken.balanceOf(_owner), _unlockedAmount);

    // after 1st milestone
    _timePassed = _unlockStartTime + 365 days + 10 days;
    _vestedAmount = (_timePassed - _vestingStartTime) * _PAY_PER_SEC / 1e2;
    _unlockedAmount = 2_551_232 ether; // approximated
    vm.warp(_timePassed);
    _llamaPay.withdraw(_owner, address(_unlock), _PAY_PER_SEC);
    _unlock.withdraw(_owner);
    assertEq(_unlock.withdrawnSupply() - _unlockedAmount < 1 ether, true); // unlocked less than vested (with rounding)
    assertEq(_nextToken.balanceOf(_owner) - _unlockedAmount < 1 ether, true);

    // linear unlock after 1st milestone
    _timePassed = _unlockStartTime + 365 days * 2; // end of unlock
    _vestedAmount = (_timePassed - _vestingStartTime) * _PAY_PER_SEC / 1e2;
    _unlockedAmount = 24_960_000 ether;
    vm.warp(_timePassed);
    _llamaPay.withdraw(_owner, address(_unlock), _PAY_PER_SEC);
    _unlock.withdraw(_owner);
    assertEq(_unlock.withdrawnSupply() - _vestedAmount < 0.00001 ether, true); // vested less than unlocked (with rounding)
    assertEq(_nextToken.balanceOf(_owner) - _vestedAmount < 0.00001 ether, true);

    // end of the vesting
    _timePassed = _unlockStartTime + 365 days * 4 + 10 days; // end of unlock
    _vestedAmount = (_timePassed - _vestingStartTime) * _PAY_PER_SEC / 1e2;
    _unlockedAmount = 24_960_000 ether;
    vm.warp(_timePassed);
    _llamaPay.withdraw(_owner, address(_unlock), _PAY_PER_SEC);
    _unlock.withdraw(_owner);

    assertEq(_unlockedAmount - _unlock.withdrawnSupply() < 0.01 ether, true); // unlocked all (with rounding)
    assertEq(_unlockedAmount - _nextToken.balanceOf(_owner) < 0.01 ether, true);

    vm.stopPrank();
  }
}
