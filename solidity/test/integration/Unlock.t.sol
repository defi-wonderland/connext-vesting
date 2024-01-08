// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable, Ownable2Step} from '@openzeppelin/contracts/access/Ownable2Step.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {IntegrationBase} from 'test/integration/IntegrationBase.sol';

contract IntegrationUnlock is IntegrationBase {
  address public receiver = makeAddr('receiver');

  address internal _unlockAddress;
  uint64 internal _firstMilestoneTimestamp;

  function setUp() public override {
    super.setUp();

    _unlockAddress = address(_unlock);
    _firstMilestoneTimestamp = uint64(_unlock.start() + 365 days);
  }

  /**
   * @notice Testing the constructor logic, it should set the owner and the start time
   */
  function test_Constructor() public {
    assertEq(Ownable2Step(_unlockAddress).owner(), owner);
    assertEq(_unlock.start(), block.timestamp + 10 minutes);
  }

  /**
   * @notice The unlocked amount should be different at various points in time.
   *  At the beginning of the unlocking period: 0 tokens
   *  Just before the first milestone: 0 token
   *  At the first milestone: 1,920,000 tokens
   *  10 days after the first milestone: 2,551,232 tokens
   *  100 days after the first milestone: 8,232,328 tokens
   *  At the end of the unlocking period: 24,960,000 tokens
   *  After the end of the unlocking period: 24,960,000 tokens
   */
  function test_UnlockedAtTimestamp() public {
    assertEq(_unlock.vestedAmount(address(_nextToken), _unlockStartTime), 0);
    assertEq(_unlock.vestedAmount(address(_nextToken), _firstMilestoneTimestamp - 1), 0);

    assertEq(_unlock.vestedAmount(address(_nextToken), _firstMilestoneTimestamp), 1_920_000 ether);

    assertApproxEqAbs(
      _unlock.vestedAmount(address(_nextToken), _firstMilestoneTimestamp + 10 days), 2_551_232 ether, MAX_DELTA
    );
    assertApproxEqAbs(
      _unlock.vestedAmount(address(_nextToken), _firstMilestoneTimestamp + 100 days), 8_232_328 ether, MAX_DELTA
    );

    assertEq(_unlock.vestedAmount(address(_nextToken), _firstMilestoneTimestamp + 365 days), 24_960_000 ether);
    assertEq(_unlock.vestedAmount(address(_nextToken), _firstMilestoneTimestamp + 365 days + 10 days), 24_960_000 ether);
  }

  /**
   * @notice The withdrawable amount should be different at various points in time, the same way as the unlocked amount.
   * It should take into account already withdrawn tokens.
   */
  function test_Releasable() public {
    deal(NEXT_TOKEN_ADDRESS, _unlockAddress, 25_000_000 ether);

    assertEq(_unlock.releasable(address(_nextToken)), 0);

    vm.warp(_unlockStartTime + 364 days);
    assertEq(_unlock.releasable(address(_nextToken)), 0);

    vm.warp(_firstMilestoneTimestamp);
    assertEq(_unlock.releasable(address(_nextToken)), 1_920_000 ether);

    vm.warp(_firstMilestoneTimestamp + 10 days);
    assertApproxEqAbs(_unlock.releasable(address(_nextToken)), 2_551_232 ether, MAX_DELTA);

    // vm.prank(owner);
    _unlock.release(address(_nextToken));
    assertEq(_unlock.releasable(address(_nextToken)), 0 ether);

    // 2,551,232 tokens have been withdrawn
    vm.warp(_firstMilestoneTimestamp + 100 days);
    assertApproxEqAbs(_unlock.releasable(address(_nextToken)), 8_232_328 ether - 2_551_232 ether, MAX_DELTA);

    vm.warp(_firstMilestoneTimestamp + 365 days);
    assertApproxEqAbs(_unlock.releasable(address(_nextToken)), 24_960_000 ether - 2_551_232 ether, MAX_DELTA);

    vm.warp(_firstMilestoneTimestamp + 365 days + 10 days);
    assertApproxEqAbs(_unlock.releasable(address(_nextToken)), 24_960_000 ether - 2_551_232 ether, MAX_DELTA);
  }

  /**
   * @notice Testing the withdrawal logic. The unlocking rate should not depend on the balance of the contract.
   */
  function test_Withdraw() public {
    // Deal more tokens that will be locked
    deal(NEXT_TOKEN_ADDRESS, _unlockAddress, 2_000_000 ether);
    vm.warp(_firstMilestoneTimestamp);

    // vm.startPrank(owner);
    _unlock.release(address(_nextToken));

    // Even though the contract has more tokens, the unlocked amount should be the same
    assertEq(_unlock.released(address(_nextToken)), 1_920_000 ether);
    assertEq(_nextToken.balanceOf(owner), 1_920_000 ether);

    // Try again and expect no changes
    _unlock.release(address(_nextToken));
    assertEq(_unlock.released(address(_nextToken)), 1_920_000 ether);
    assertEq(_nextToken.balanceOf(owner), 1_920_000 ether);

    // vm.stopPrank();
  }

  /**
   * @notice Shouldn't revert if there is nothing to withdraw
   */
  function test_Withdraw_NoSupply() public {
    vm.prank(owner);
    _unlock.release(address(_nextToken));

    assertEq(_unlock.released(address(_nextToken)), 0);
    assertEq(_nextToken.balanceOf(owner), 0);
  }

  // /**
  //  * @notice Shouldn't allow anyone but the owner to initiate the withdrawal
  //  */
  // function test_Withdraw_Unauthorized() public {
  //   address _randomAddress = makeAddr('randomAddress');
  //   vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, _randomAddress));
  //   vm.prank(_randomAddress);
  //   _unlock.release(address(_nextToken));
  // }

  /**
   * @notice 2-step ownership transfer
   */
  function test_transferOwnership() public {
    address _newOwner = makeAddr('newOwner');
    Ownable2Step _unlockOwnable = Ownable2Step(_unlockAddress);

    vm.prank(owner);
    _unlockOwnable.transferOwnership(_newOwner);

    assertEq(_unlockOwnable.pendingOwner(), _newOwner);
    assertEq(_unlockOwnable.owner(), owner);

    address _bob = makeAddr('bob');
    vm.prank(_bob);
    vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, _bob));
    _unlockOwnable.acceptOwnership();

    vm.prank(_newOwner);
    _unlockOwnable.acceptOwnership();
    assertEq(_unlockOwnable.owner(), _newOwner);
  }

  // /**
  //  * @notice The dust collector should allow the owner to send ETH and ERC20s to any address
  //  */
  // function test_SendDust() public {
  //   IERC20 _dai = IERC20(DAI_ADDRESS);
  //   address _randomAddress = makeAddr('randomAddress');
  //   uint256 _dustAmount = 1000;

  //   vm.deal(_unlockAddress, _dustAmount);
  //   deal(DAI_ADDRESS, _unlockAddress, _dustAmount);
  //   deal(NEXT_TOKEN_ADDRESS, _unlockAddress, _dustAmount);

  //   // Random dude cannot collect dust
  //   address _bob = makeAddr('bob');
  //   vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, _bob));
  //   vm.prank(_bob);
  //   // _unlock.sendDust(_dai, _dustAmount, _randomAddress);
  //   _unlock.release(address(_dai));

  //   // Can't collect the vesting token
  //   assertEq(_nextToken.balanceOf(_randomAddress), 0);
  //   vm.prank(owner);
  //   _unlock.release(address(_nextToken));
  //   assertEq(_nextToken.balanceOf(_randomAddress), 0);

  //   // Collect an ERC20 token
  //   assertEq(_dai.balanceOf(_randomAddress), 0);
  //   vm.prank(owner);
  //   _unlock.release(address(_dai));
  //   assertEq(_dai.balanceOf(_randomAddress), _dustAmount);

  //   // Collect ETH
  //   assertEq(_randomAddress.balance, 0);
  //   vm.prank(owner);
  //   _unlock.release(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
  //   assertEq(_randomAddress.balance, _dustAmount);
  // }
}
