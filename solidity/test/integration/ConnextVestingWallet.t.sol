// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable, Ownable2Step} from '@openzeppelin/contracts/access/Ownable2Step.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

import {ConnextVestingWallet, IConnextVestingWallet} from 'contracts/ConnextVestingWallet.sol';
import {Constants} from 'test/utils/Constants.sol';

import {IVestingEscrowSimple} from 'interfaces/IVestingEscrowSimple.sol';
import {IVestingEscrowFactory} from 'test/utils/IVestingEscrowFactory.sol';

import {Test} from 'forge-std/Test.sol';

contract UnitConnextVestingWallet is Test, Constants {
  address public receiver = makeAddr('receiver');

  ConnextVestingWallet internal _connextVestingWallet;
  address internal _connextVestingWalletAddress;
  uint64 internal _unlockCliff;
  uint64 internal _connextTokenLaunch;

  address public owner = makeAddr('owner');
  address public payer = makeAddr('payer');

  IERC20 internal _nextToken = IERC20(NEXT_TOKEN_ADDRESS);
  IVestingEscrowFactory internal _llamaVestFactory = IVestingEscrowFactory(LLAMA_FACTORY_ADDRESS);
  IVestingEscrowSimple internal _llamaVest;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), FORK_BLOCK);

    deal(NEXT_TOKEN_ADDRESS, payer, TOTAL_AMOUNT);

    // approve before deployment
    vm.prank(payer);
    _nextToken.approve(address(_llamaVestFactory), TOTAL_AMOUNT);

    // deploy vesting contract
    vm.prank(payer);
    _llamaVest = IVestingEscrowSimple(
      _llamaVestFactory.deploy_vesting_contract(
        NEXT_TOKEN_ADDRESS, address(_connextVestingWallet), TOTAL_AMOUNT, VESTING_DURATION, AUG_01_2022, 0
      )
    );

    // set total amount as 13 ether
    _connextVestingWallet = new ConnextVestingWallet(owner, 13 ether);
    _connextVestingWalletAddress = address(_connextVestingWallet);
    _connextTokenLaunch = uint64(_connextVestingWallet.NEXT_TOKEN_LAUNCH());
    _unlockCliff = uint64(_connextVestingWallet.UNLOCK_CLIFF());
  }

  /**
   * @notice Testing the constructor logic, it should set the owner and the start time
   */
  function test_Constructor() public {
    assertEq(Ownable2Step(_connextVestingWalletAddress).owner(), owner);
    assertEq(_connextVestingWallet.TOTAL_AMOUNT(), 13 ether);
  }

  /**
   * @notice The unlocked amount should be different at various points in time.
   *  At the beginning of the unlocking period: 0 tokens
   *  Just before the first milestone: 0 token
   *  At the first milestone: 1 ether tokens
   *  1 month after the first milestone: 2 ether tokens
   *  2 month after the first milestone: 3 ether tokens
   *  At the end of the unlocking period: 13 ether tokens
   *  After the end of the unlocking period: 13 ether tokens
   */
  function test_UnlockedAtTimestamp() public {
    assertEq(_connextVestingWallet.vestedAmount(_connextTokenLaunch), 0);
    assertEq(_connextVestingWallet.vestedAmount(_unlockCliff - 1), 0);

    assertEq(_connextVestingWallet.vestedAmount(_unlockCliff), 1 ether);

    assertEq(_connextVestingWallet.vestedAmount(_unlockCliff + MONTH), 2 ether);

    assertEq(_connextVestingWallet.vestedAmount(_unlockCliff + MONTH * 2), 3 ether);

    assertEq(_connextVestingWallet.vestedAmount(_unlockCliff + YEAR), 13 ether);

    assertEq(_connextVestingWallet.vestedAmount(_unlockCliff + YEAR + 10 days), 13 ether);
  }

  /**
   * @notice The withdrawable amount should be different at various points in time, the same way as the unlocked amount.
   * It should take into account already withdrawn tokens.
   */
  function test_WithdrawableAmount() public {
    deal(NEXT_TOKEN_ADDRESS, _connextVestingWalletAddress, 15 ether);

    assertEq(_connextVestingWallet.releasable(), 0);

    vm.warp(_connextTokenLaunch + YEAR - 1);
    assertEq(_connextVestingWallet.releasable(), 0);

    vm.warp(_unlockCliff);
    assertEq(_connextVestingWallet.releasable(), 1 ether);

    vm.warp(_unlockCliff + MONTH);
    assertEq(_connextVestingWallet.releasable(), 2 ether);

    _connextVestingWallet.release();
    assertEq(_connextVestingWallet.releasable(), 0 ether);

    // 2 ether have been withdrawn
    vm.warp(_unlockCliff + MONTH * 2);
    assertEq(_connextVestingWallet.releasable(), 3 ether - 2 ether);

    vm.warp(_unlockCliff + YEAR);
    assertEq(_connextVestingWallet.releasable(), 13 ether - 2 ether);

    vm.warp(_unlockCliff + YEAR + 10 days);
    assertEq(_connextVestingWallet.releasable(), 13 ether - 2 ether);
  }

  /**
   * @notice Testing the withdrawal logic. The unlocking rate should not depend on the balance of the contract.
   */
  function test_Withdraw() public {
    // Deal more tokens that will be locked
    deal(NEXT_TOKEN_ADDRESS, _connextVestingWalletAddress, 2 ether);
    vm.warp(_unlockCliff);

    vm.startPrank(owner);
    _connextVestingWallet.release();

    // Even though the contract has more tokens, the unlocked amount should be the same
    assertEq(_connextVestingWallet.released(), 1 ether);
    assertEq(_nextToken.balanceOf(owner), 1 ether);

    // Try again and expect no changes
    _connextVestingWallet.release();
    assertEq(_connextVestingWallet.released(), 1 ether);
    assertEq(_nextToken.balanceOf(owner), 1 ether);

    vm.stopPrank();
  }

  /**
   * @notice Shouldn't revert if there is nothing to withdraw
   */
  function test_Withdraw_NoSupply() public {
    _connextVestingWallet.release();

    assertEq(_connextVestingWallet.releasable(), 0);
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
    vm.expectRevert(abi.encodeWithSelector(IConnextVestingWallet.NotAllowed.selector));
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
    vm.warp(_connextVestingWallet.UNLOCK_END());
    assertEq(_nextToken.balanceOf(_randomAddress), 0);
    _connextVestingWallet.release();
    
    // Can't collect the vesting token before the unlock period has ended
    vm.warp(_connextVestingWallet.UNLOCK_END() - 1);
    vm.expectRevert(abi.encodeWithSelector(IConnextVestingWallet.NotAllowed.selector));
    vm.prank(owner);
    _connextVestingWallet.sendDust(_nextToken, _dustAmount, _randomAddress);
    // After all tokens were released AND the unlock period has ended, the dust can be collected
    vm.warp(_connextVestingWallet.UNLOCK_END());
    vm.prank(owner);
    _connextVestingWallet.sendDust(_nextToken, _dustAmount, _randomAddress);
    assertEq(_nextToken.balanceOf(_randomAddress), _dustAmount);
  }
}
