// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.19;

import {ISablierV2LockupDynamic} from '@sablier/v2-core/src/interfaces/ISablierV2LockupDynamic.sol';
import {Broker, LockupDynamic} from '@sablier/v2-core/src/types/DataTypes.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {ud2x18} from '@prb/math/src/UD2x18.sol';
import {ud60x18} from '@prb/math/src/UD60x18.sol';
import {Test} from 'forge-std/Test.sol';
import {console} from 'forge-std/Console.sol';

/// @notice Example of how to create a Lockup Dynamic stream.
/// @dev This code is referenced in the docs: https://docs.sablier.com/contracts/v2/guides/create-stream/lockup-dynamic
contract LockupDynamicStreamCreatorTest is Test {
  address internal _owner = makeAddr('owner');

  address constant SABLIER_DYNAMIC_MAINNET = 0x39EFdC3dbB57B2388CcC4bb40aC4CB1226Bc9E44;
  address constant NEXT_MAINNET = 0xFE67A4450907459c3e1FFf623aA927dD4e28c67a;

  address constant SABLIER_DYNAMIC_GOERLI = 0x4BE70EDe968e9dBA12DB42b9869Bec66bEDC17d7;
  address constant NEXT_GOERLI = 0x7ea6eA49B0b0Ae9c5db7907d139D9Cd3439862a1;

  uint256 constant TOTAL_AMOUNT = 24_960_000 ether;

  ISablierV2LockupDynamic internal lockupDynamic;

  function setUp() public {
    // mint some NEXT tokens
    vm.createSelectFork(vm.rpcUrl('mainnet'), 18_820_753);
    deal(NEXT_MAINNET, _owner, TOTAL_AMOUNT);
    vm.prank(_owner);
    IERC20(NEXT_MAINNET).approve(address(this), TOTAL_AMOUNT);

    lockupDynamic = ISablierV2LockupDynamic(SABLIER_DYNAMIC_MAINNET);
  }

  function test_Creation() external {
    uint256 streamId = createLockupDynamicStream(1_920_000, 5_917_440, 17_122_560);
    console.log('streamId: %s', streamId);
  }

  function createLockupDynamicStream(
    uint256 amount0,
    uint256 amount1,
    uint256 amount2
  ) public returns (uint256 streamId) {
    // Sum the segment amounts
    uint256 totalAmount = amount0 + amount1 + amount2;

    // Transfer the provided amount of DAI tokens to this contract
    IERC20(NEXT_MAINNET).transferFrom(_owner, address(this), totalAmount);

    // Approve the Sablier contract to spend DAI
    IERC20(NEXT_MAINNET).approve(address(lockupDynamic), totalAmount);

    console.log('HERE');

    // Declare the params struct
    LockupDynamic.CreateWithMilestones memory params;

    // Declare the function parameters
    params.sender = _owner; // The sender will be able to cancel the stream
    params.recipient = address(0xcafe); // The recipient of the streamed assets
    params.totalAmount = uint128(totalAmount); // Total amount is the amount inclusive of all fees
    params.asset = IERC20(NEXT_MAINNET); // The streaming asset
    params.cancelable = true; // Whether the stream will be cancelable or not
    params.startTime = uint40(block.timestamp);
    params.broker = Broker(address(0), ud60x18(0)); // Optional parameter left undefined

    // Declare some dummy segments
    params.segments = new LockupDynamic.Segment[](3);
    params.segments[0] = LockupDynamic.Segment({
      amount: uint128(amount0),
      exponent: ud2x18(0), // unlock at milestone
      milestone: uint40(block.timestamp + 365 days) // 12 months
    });
    params.segments[1] = (
      LockupDynamic.Segment({
        amount: uint128(amount1),
        exponent: ud2x18(1e18), // linear unlock
        milestone: uint40(block.timestamp + 365 days + 90 days) // ~15 months
      })
    );
    params.segments[2] = (
      LockupDynamic.Segment({
        amount: uint128(amount2),
        exponent: ud2x18(1e18), // linear unlock
        milestone: uint40(block.timestamp + (365 days * 4)) // 48 months
      })
    );

    console.log('HERE');

    // Create the LockupDynamic stream
    streamId = lockupDynamic.createWithMilestones(params);

    console.log('HERE');
  }
}
