// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable, Ownable2Step} from '@openzeppelin/contracts/access/Ownable2Step.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

import {ConnextVestingWallet} from 'contracts/ConnextVestingWallet.sol';
import {IntegrationBase} from 'test/integration/IntegrationBase.sol';

contract IntegrationConnextVestingWallet is IntegrationBase {
  address public receiver = makeAddr('receiver');

  address internal _connextVestingWalletAddress;
  uint64 internal _firstMilestoneTimestamp;

  function setUp() public override {
    super.setUp();

    _connextVestingWalletAddress = address(_connextVestingWallet);
    _firstMilestoneTimestamp = uint64(_connextVestingWallet.cliff());
  }

  /**
   * @notice Testing the constructor logic, it should set the owner and the start time
   */
  function test_Constructor() public {
    assertEq(Ownable2Step(_connextVestingWalletAddress).owner(), owner);
    assertEq(_connextVestingWallet.initTimestamp(), block.timestamp + 10 minutes);
    assertEq(_connextVestingWallet.start(), block.timestamp + 10 minutes + 365 days * 11 / 12);
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
    assertEq(_connextVestingWallet.vestedAmount(NEXT_TOKEN_ADDRESS, _unlockStartTime), 0);
    assertEq(_connextVestingWallet.vestedAmount(NEXT_TOKEN_ADDRESS, _firstMilestoneTimestamp - 1), 0);

    assertEq(_connextVestingWallet.vestedAmount(NEXT_TOKEN_ADDRESS, _firstMilestoneTimestamp), 1_920_000 ether);

    assertApproxEqAbs(
      _connextVestingWallet.vestedAmount(NEXT_TOKEN_ADDRESS, _firstMilestoneTimestamp + 10 days),
      2_551_232 ether,
      MAX_DELTA
    );
    assertApproxEqAbs(
      _connextVestingWallet.vestedAmount(NEXT_TOKEN_ADDRESS, _firstMilestoneTimestamp + 100 days),
      8_232_328 ether,
      MAX_DELTA
    );

    assertEq(
      _connextVestingWallet.vestedAmount(NEXT_TOKEN_ADDRESS, _firstMilestoneTimestamp + 365 days), 24_960_000 ether
    );
    assertEq(
      _connextVestingWallet.vestedAmount(NEXT_TOKEN_ADDRESS, _firstMilestoneTimestamp + 365 days + 10 days),
      24_960_000 ether
    );
  }

  /**
   * @notice The withdrawable amount should be different at various points in time, the same way as the unlocked amount.
   * It should take into account already withdrawn tokens.
   */
  function test_WithdrawableAmount() public {
    deal(NEXT_TOKEN_ADDRESS, _connextVestingWalletAddress, 25_000_000 ether);

    assertEq(_connextVestingWallet.releasable(NEXT_TOKEN_ADDRESS), 0);

    vm.warp(_unlockStartTime + 364 days);
    assertEq(_connextVestingWallet.releasable(NEXT_TOKEN_ADDRESS), 0);

    vm.warp(_firstMilestoneTimestamp);
    assertEq(_connextVestingWallet.releasable(NEXT_TOKEN_ADDRESS), 1_920_000 ether);

    vm.warp(_firstMilestoneTimestamp + 10 days);
    assertApproxEqAbs(_connextVestingWallet.releasable(NEXT_TOKEN_ADDRESS), 2_551_232 ether, MAX_DELTA);

    _connextVestingWallet.release(NEXT_TOKEN_ADDRESS);
    assertEq(_connextVestingWallet.releasable(NEXT_TOKEN_ADDRESS), 0 ether);

    // 2,551,232 tokens have been withdrawn
    vm.warp(_firstMilestoneTimestamp + 100 days);
    assertApproxEqAbs(
      _connextVestingWallet.releasable(NEXT_TOKEN_ADDRESS), 8_232_328 ether - 2_551_232 ether, MAX_DELTA
    );

    vm.warp(_firstMilestoneTimestamp + 365 days);
    assertApproxEqAbs(
      _connextVestingWallet.releasable(NEXT_TOKEN_ADDRESS), 24_960_000 ether - 2_551_232 ether, MAX_DELTA
    );

    vm.warp(_firstMilestoneTimestamp + 365 days + 10 days);
    assertApproxEqAbs(
      _connextVestingWallet.releasable(NEXT_TOKEN_ADDRESS), 24_960_000 ether - 2_551_232 ether, MAX_DELTA
    );
  }

  /**
   * @notice Testing the withdrawal logic. The unlocking rate should not depend on the balance of the contract.
   */
  function test_Withdraw() public {
    // Deal more tokens that will be locked
    deal(NEXT_TOKEN_ADDRESS, _connextVestingWalletAddress, 2_000_000 ether);
    vm.warp(_firstMilestoneTimestamp);

    vm.startPrank(owner);
    _connextVestingWallet.release(NEXT_TOKEN_ADDRESS);

    // Even though the contract has more tokens, the unlocked amount should be the same
    assertEq(_connextVestingWallet.released(NEXT_TOKEN_ADDRESS), 1_920_000 ether);
    assertEq(_nextToken.balanceOf(owner), 1_920_000 ether);

    // Try again and expect no changes
    _connextVestingWallet.release(NEXT_TOKEN_ADDRESS);
    assertEq(_connextVestingWallet.released(NEXT_TOKEN_ADDRESS), 1_920_000 ether);
    assertEq(_nextToken.balanceOf(owner), 1_920_000 ether);

    vm.stopPrank();
  }

  /**
   * @notice Shouldn't revert if there is nothing to withdraw
   */
  function test_Withdraw_NoSupply() public {
    _connextVestingWallet.release(NEXT_TOKEN_ADDRESS);

    assertEq(_connextVestingWallet.releasable(NEXT_TOKEN_ADDRESS), 0);
    assertEq(_nextToken.balanceOf(owner), 0);
  }

  /**
   * @notice 2-step ownership transfer
   */
  function test_transferOwnership() public {
    address _newOwner = makeAddr('newOwner');
    Ownable2Step _unlockOwnable = Ownable2Step(_connextVestingWalletAddress);

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

  /**
   * @notice The dust collector should allow the owner to send ETH and ERC20s to any address
   */
  function test_SendDust() public {
    IERC20 _dai = IERC20(DAI_ADDRESS);
    address _randomAddress = makeAddr('randomAddress');
    uint256 _dustAmount = 1000;

    vm.deal(_connextVestingWalletAddress, _dustAmount);
    deal(DAI_ADDRESS, _connextVestingWalletAddress, _dustAmount);
    deal(NEXT_TOKEN_ADDRESS, _connextVestingWalletAddress, _dustAmount + _connextVestingWallet.TOTAL_AMOUNT());

    // Random dude cannot collect dust
    address _bob = makeAddr('bob');
    vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, _bob));
    vm.prank(_bob);
    _connextVestingWallet.sendDust(_dai, _dustAmount, _randomAddress);

    // Can't collect the vesting token
    assertEq(_nextToken.balanceOf(_randomAddress), 0);
    vm.expectRevert(abi.encodeWithSelector(ConnextVestingWallet.NoVestingAgreement.selector));
    vm.prank(owner);
    _connextVestingWallet.sendDust(_nextToken, _dustAmount, _randomAddress);
    assertEq(_nextToken.balanceOf(_randomAddress), 0);

    // Collect an ERC20 token
    assertEq(_dai.balanceOf(_randomAddress), 0);
    vm.prank(owner);
    _connextVestingWallet.sendDust(_dai, _dustAmount, _randomAddress);
    assertEq(_dai.balanceOf(_randomAddress), _dustAmount);

    // Collect ETH
    assertEq(_randomAddress.balance, 0);
    vm.prank(owner);
    _connextVestingWallet.sendDust(IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE), _dustAmount, _randomAddress);
    assertEq(_randomAddress.balance, _dustAmount);

    // Collect vesting token after the vesting period has ended
    vm.warp(_firstMilestoneTimestamp + 365 days * 3 + 10 days);
    assertEq(_nextToken.balanceOf(_randomAddress), 0);
    _connextVestingWallet.release(NEXT_TOKEN_ADDRESS);
    vm.prank(owner);
    _connextVestingWallet.sendDust(_nextToken, _dustAmount, _randomAddress);
    assertEq(_nextToken.balanceOf(_randomAddress), _dustAmount);
  }
}
