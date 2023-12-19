// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import {ISablierV2LockupDynamic} from '@sablier/v2-core/src/interfaces/ISablierV2LockupDynamic.sol';
import {Broker, LockupDynamic} from '@sablier/v2-core/src/types/DataTypes.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {ud2x18} from '@prb/math/src/UD2x18.sol';
import {ud60x18} from '@prb/math/src/UD60x18.sol';

/// @notice Example of how to create a Lockup Dynamic stream.
/// @dev This code is referenced in the docs: https://docs.sablier.com/contracts/v2/guides/create-stream/lockup-dynamic
contract MockLockupDynamicStreamCreator {
  IERC20 public constant ASSET = IERC20(0x17422D756cE9024CC3fe7569f64941010eF277Db);
  uint128 public TOTAL_AMOUNT = 2_000_000_000_000_000_000_000;
  ISablierV2LockupDynamic public immutable lockupDynamic;

  constructor(ISablierV2LockupDynamic lockupDynamic_) {
    lockupDynamic = lockupDynamic_;
  }

  function createLockupDynamicStream() public returns (uint256 streamId) {
    // Approve the Sablier contract to spend DAI
    ASSET.approve(address(lockupDynamic), TOTAL_AMOUNT);

    // Declare the params struct
    LockupDynamic.CreateWithMilestones memory params;

    // Declare the function parameters
    params.sender = 0x54E0119cf6B50bD96a18c99f5227cce602097623; // The sender will be able to cancel the stream
    params.recipient = 0x4dC83b54500236a1BDd5d3c503e753609d71e371; // The recipient of the streamed assets
    params.totalAmount = TOTAL_AMOUNT; // Total amount is the amount inclusive of all fees
    params.asset = ASSET; // The streaming asset
    params.cancelable = true; // Whether the stream will be cancelable or not
    params.startTime = 1_699_027_200;
    params.broker = Broker(address(0), ud60x18(0)); // Optional parameter left undefined

    // Declare some dummy segments
    params.segments = new LockupDynamic.Segment[](1);
    params.segments[0] = LockupDynamic.Segment({
      amount: TOTAL_AMOUNT,
      exponent: ud2x18(3_000_000_000_000_000_000),
      milestone: 1_702_483_200
    });

    // Create the LockupDynamic stream
    streamId = lockupDynamic.createWithMilestones(params);
  }
}
