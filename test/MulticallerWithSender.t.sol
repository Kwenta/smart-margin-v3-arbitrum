// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.27;

import {Bootstrap} from "test/utils/Bootstrap.sol";
import {MulticallerWithSender as MWS} from "src/utils/MulticallerWithSender.sol";
import {EIP7412} from "src/utils/EIP7412.sol";
import {EIP7412Mock} from "test/utils/mocks/EIP7412Mock.sol";
import {IERC20} from "src/utils/zap/interfaces/IERC20.sol";

contract MulticallerWithSenderTest is Bootstrap {
    MWS mws;
    EIP7412Mock eip7412Mock;
    address constant DEPLOYED_ENGINE =
        0x3eBAEAD525a11872B60A3B53E13F17E3351c24e7;
    address payable constant DEPLOYED_MWS =
        payable(0x5f5b1c1b21E493EA646cd76FDd6a56A247DA3957);
    uint256 constant ARBITRUM_BLOCK_NUMBER_MWS = 266_214_702;

    function setUp() public {
        vm.rollFork(ARBITRUM_BLOCK_NUMBER_MWS);
        initializeArbitrum();

        mws = MWS(DEPLOYED_MWS);
        eip7412Mock = new EIP7412Mock();

        /// @dev this is needed because MWS hardcodes the live Engine contract address
        /// therefore we cannot use our boostrap test state, we must fork
        vm.startPrank(ACTOR);
        perpsMarketProxy.grantPermission({
            accountId: accountId,
            permission: ADMIN_PERMISSION,
            user: DEPLOYED_ENGINE
        });
        vm.stopPrank();
    }
}

contract MulticallerWithSenderEngine is MulticallerWithSenderTest {
    function test_multicall_engine_depositCollateralETH() public {
        uint256 availableMargin =
            uint256(perpsMarketProxy.getAvailableMargin(accountId));
        assertEq(availableMargin, 0);

        vm.deal(ACTOR, 2 ether);

        bytes[] memory data = new bytes[](2);
        uint256[] memory values = new uint256[](2);

        data[0] = abi.encodeWithSelector(
            engine.depositCollateralETH.selector, accountId, 1 ether, 1
        );

        values[0] = 1 ether;

        data[1] = abi.encodeWithSelector(
            engine.depositCollateralETH.selector, accountId, 1 ether, 1
        );

        values[1] = 1 ether;

        vm.startPrank(ACTOR);
        mws.aggregateWithSender{value: values[0] + values[1]}(data, values);
        vm.stopPrank();

        availableMargin =
            uint256(perpsMarketProxy.getAvailableMargin(accountId));
        uint256 expectedMargin = 2 ether * ETH_PRICE;
        assertWithinTolerance(expectedMargin, availableMargin, 2);
    }

    function test_multicall_engine_fulfillOracleQuery_depositCollateralETH()
        public
    {
        uint256 availableMargin =
            uint256(perpsMarketProxy.getAvailableMargin(accountId));
        assertEq(availableMargin, 0);

        vm.deal(ACTOR, 5 + 1 ether);

        bytes[] memory data = new bytes[](2);
        uint256[] memory values = new uint256[](2);

        // call mock oracle to simulate payable function call
        data[0] = abi.encodeWithSelector(
            EIP7412.fulfillOracleQuery.selector,
            address(eip7412Mock),
            abi.encodePacked("")
        );

        values[0] = 5;

        data[1] = abi.encodeWithSelector(
            engine.depositCollateralETH.selector, accountId, 1 ether, 1
        );

        values[1] = 1 ether;

        vm.startPrank(ACTOR);
        mws.aggregateWithSender{value: values[0] + values[1]}(data, values);
        vm.stopPrank();

        availableMargin =
            uint256(perpsMarketProxy.getAvailableMargin(accountId));
        uint256 expectedMargin = 1 ether * ETH_PRICE;
        assertWithinTolerance(expectedMargin, availableMargin, 2);
    }
}
