// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.27;

import {IEngine} from "src/interfaces/IEngine.sol";
import {Bootstrap} from "test/utils/Bootstrap.sol";

contract CollateralTest is Bootstrap {
    function setUp() public {
        vm.rollFork(ARBITRUM_BLOCK_NUMBER);
        initializeArbitrum();

        /// @dev Update price feeds
        bytes32[] memory priceIds = new bytes32[](3);
        priceIds[0] =
            0x56a3121958b01f99fdc4e1fd01e81050602c7ace3a571918bb55c6a96657cca9; // tBTC price feed
        priceIds[1] =
            0x6ec879b1e9963de5ee97e9c8710b742d6228252a5e2ca12d4ae81d7fe5ee8c5d; // USDe price feed
        priceIds[2] =
            0x2b89b9dc8fdf9f34709a5b106b472f0f39bb6ca9ce04b0fd7f2e971688e2e53b; // USDT price feed

        // Current timestamp
        uint64[] memory publishTimes = new uint64[](3);
        publishTimes[0] = uint64(block.timestamp);
        publishTimes[1] = uint64(block.timestamp);
        publishTimes[2] = uint64(block.timestamp);

        // update data corresponding to the different price feeds at block.timestamp
        bytes[] memory updateData = new bytes[](3);
        updateData[0] =
            hex"504e415501000000054401000000041300e3e07a21c75498a61a82d4b2fa37bbebeaa8f8abe17fb3db97271745a373c06c2c1d372960c73e411fe10f6cdc6ebbb46ef9581f131a6e1c778ab10034fc5aa30001cec1889e5f0a89184937b4778ac1ae8725cb19896855fb58a7c624bb084fc6fb3332d325258e5e8176ec7a9de74c514364835c65eff19a2b5ee60474fc76afb60102bf2050e1fe26ca0b0dd98a8bc3dfd3eb2ce6f99974a9e91bdada1c79e7f44b3c4fab5c7ff05d53f242396e0d58acd3032818f776b0ae7b372f661b5cc6848c5101031c143bc117e93f706e0f09b2b928bcc9536615f3ffdcd2399151cb9d13bc47055a2ef52df3a90f210068ac16e19ec39e182bd133e7b9e9176c481707ea9abda001043168c440f04560eb44474085748b099d3242f30cb81c2d0acbab883b405747ca5d48842161331304563c937bc464c3188cd121fa10174ea50f5d7c310016573200054d6b4acdd74475763bbb26cf2b47f18e5b83e84e181205eeae0c0904e8d0ea812348e17f3638ed400b602acc3bfabb3e5f715ca2a590181bac05db5e4126b7b800066f978a0bc5b6cd01767587574ca7e678cbc971e8b2d36b306401b1412910b2ad13c426f4ac29ff3115b4c7e6ad13f23104baadb2cb88abfebdb60efb588b8b870107c7cdda4ddf8ee4b72152e965b0256bbf704b2b9c53c256d52deb2d13b68fc72b7dbebbba7148132570c25d9e7c70ec476e36368ed9f707982088f59b4dc2b20d0108e9cc45f9b460ffd1e7a12604da1506431abe53b6e70a0baf8eeb31bf8a9f3d6914ed163361170d008845a9310cff0963ef6c87937435676e67bc5265160659b70009f2bdfd0983f1087f718394aa29566cab8e14b0a31765ff4a372cddc60dccc9da394960886b7f6e25dd5e864fb7b2a7f318201cfba586f2566d9ebbc0ef03aa21010a5f6da79e89f009e6829f946aa3adf22854239cbdf182549c1d6126e17f6c0d936ce163b18e0b4a6d2253962003b08647728cb348a1b2f7dc763aa4c114b7fae7000b3ee68b890448cf0e99f4f043abe029fe5fb42d90f21700d41b77463203476e13140f077753e426dbad34a1cec5817c964c87955d0be563532e26b192717544c6010cc0b24137e84b4c7c81f08f2d1cb50f2e809f9968696fcf684ec446f3e8dd266e4ea019ada05b17f26321368ae8c68ef4ca5432b7891b6e3a613a2d4562743b81010d8d7179f7d179c0debc33427bd1aa4237da0e30dec43249028e0bdfaaf90b21713725b815676478379c9e7583575afb025dc4df24e14b3a7ff5130e9e75c162af000e0e71a6a8f0fdfbe4bc0889e02d4e61d9df3cacb7ea1d463625146ec1e44501222673299fec3e666845161014c7680050ea272b2b38cc09e5ebcce4ea108532b2000fe64403eedafc901eb118c25ab62814b1901f3c959cf75b72eb8de57c6a73241752a14d30b238ef62e76cb3580c636ae8ebacabba82e813c120a15eeaf51bc2f901101c0a4b0b08ce8791be395f5572c5923db935dd0978f8ca88b3b4d31fa749c9a6008b8b8c0ec518d5767c000c36691f37aee9c96866442d8cdd31f273c2af8b090111b551f0353caf870c667d8ab1a581b1ed98a2e3b6dae2e3ddcd764b5dd41f71135291d1c1e394d66e447776e378eed1dbc73852fdaf10c326ee25370ca44c964b001220b4932328f73a9dd570f2ff3b2f030f40333a62dab39f9d2d45de043b6d86dd3ede8bafebf09ce3b9c3d53596870778c7f66f301d30a7d802329522a230bbe6016717b4ed00000000001ae101faedac5851e32b9b23b5f9411a8c2bac4aae3ed4dd7b811dd1a72ea4aa71000000000542d622014155575600000000000a4f445f0000271033f17e93710e1d51d3c4902305687d619171ff110100550056a3121958b01f99fdc4e1fd01e81050602c7ace3a571918bb55c6a96657cca90000061cadb8157c00000007979b3e36fffffff8000000006717b4ed000000006717b4ec0000061722f9a30000000008885604880a073ed5de7a33d9fbdcd8d7f947d062bf4304167d6acf708be47f7466827df8b0fceb110891ed9eb64e01898936382cbb8e933f55b03756e940e3ee841cc311a068a7c7ecf0646d7a2e6723c1adefd9f4e817705a9e7f84ed64c50978b93f0da573792a6e0cca09b0bf6220f44f843cdb4703ef6e974d31db286063e6364efbced9d7ebafcb9911b8eac5643ff35ad102d5ee91b1617d7818a915dadbad766428f11d6f6287ce71bfc89e1cb2b6f716569c88efba8af9e83ecfe539d17d65fd52f86948affbda815d";
        updateData[1] =
            hex"504e415501000000054401000000041300e3e07a21c75498a61a82d4b2fa37bbebeaa8f8abe17fb3db97271745a373c06c2c1d372960c73e411fe10f6cdc6ebbb46ef9581f131a6e1c778ab10034fc5aa30001cec1889e5f0a89184937b4778ac1ae8725cb19896855fb58a7c624bb084fc6fb3332d325258e5e8176ec7a9de74c514364835c65eff19a2b5ee60474fc76afb60102bf2050e1fe26ca0b0dd98a8bc3dfd3eb2ce6f99974a9e91bdada1c79e7f44b3c4fab5c7ff05d53f242396e0d58acd3032818f776b0ae7b372f661b5cc6848c5101031c143bc117e93f706e0f09b2b928bcc9536615f3ffdcd2399151cb9d13bc47055a2ef52df3a90f210068ac16e19ec39e182bd133e7b9e9176c481707ea9abda001043168c440f04560eb44474085748b099d3242f30cb81c2d0acbab883b405747ca5d48842161331304563c937bc464c3188cd121fa10174ea50f5d7c310016573200054d6b4acdd74475763bbb26cf2b47f18e5b83e84e181205eeae0c0904e8d0ea812348e17f3638ed400b602acc3bfabb3e5f715ca2a590181bac05db5e4126b7b800066f978a0bc5b6cd01767587574ca7e678cbc971e8b2d36b306401b1412910b2ad13c426f4ac29ff3115b4c7e6ad13f23104baadb2cb88abfebdb60efb588b8b870107c7cdda4ddf8ee4b72152e965b0256bbf704b2b9c53c256d52deb2d13b68fc72b7dbebbba7148132570c25d9e7c70ec476e36368ed9f707982088f59b4dc2b20d0108e9cc45f9b460ffd1e7a12604da1506431abe53b6e70a0baf8eeb31bf8a9f3d6914ed163361170d008845a9310cff0963ef6c87937435676e67bc5265160659b70009f2bdfd0983f1087f718394aa29566cab8e14b0a31765ff4a372cddc60dccc9da394960886b7f6e25dd5e864fb7b2a7f318201cfba586f2566d9ebbc0ef03aa21010a5f6da79e89f009e6829f946aa3adf22854239cbdf182549c1d6126e17f6c0d936ce163b18e0b4a6d2253962003b08647728cb348a1b2f7dc763aa4c114b7fae7000b3ee68b890448cf0e99f4f043abe029fe5fb42d90f21700d41b77463203476e13140f077753e426dbad34a1cec5817c964c87955d0be563532e26b192717544c6010cc0b24137e84b4c7c81f08f2d1cb50f2e809f9968696fcf684ec446f3e8dd266e4ea019ada05b17f26321368ae8c68ef4ca5432b7891b6e3a613a2d4562743b81010d8d7179f7d179c0debc33427bd1aa4237da0e30dec43249028e0bdfaaf90b21713725b815676478379c9e7583575afb025dc4df24e14b3a7ff5130e9e75c162af000e0e71a6a8f0fdfbe4bc0889e02d4e61d9df3cacb7ea1d463625146ec1e44501222673299fec3e666845161014c7680050ea272b2b38cc09e5ebcce4ea108532b2000fe64403eedafc901eb118c25ab62814b1901f3c959cf75b72eb8de57c6a73241752a14d30b238ef62e76cb3580c636ae8ebacabba82e813c120a15eeaf51bc2f901101c0a4b0b08ce8791be395f5572c5923db935dd0978f8ca88b3b4d31fa749c9a6008b8b8c0ec518d5767c000c36691f37aee9c96866442d8cdd31f273c2af8b090111b551f0353caf870c667d8ab1a581b1ed98a2e3b6dae2e3ddcd764b5dd41f71135291d1c1e394d66e447776e378eed1dbc73852fdaf10c326ee25370ca44c964b001220b4932328f73a9dd570f2ff3b2f030f40333a62dab39f9d2d45de043b6d86dd3ede8bafebf09ce3b9c3d53596870778c7f66f301d30a7d802329522a230bbe6016717b4ed00000000001ae101faedac5851e32b9b23b5f9411a8c2bac4aae3ed4dd7b811dd1a72ea4aa71000000000542d622014155575600000000000a4f445f0000271033f17e93710e1d51d3c4902305687d619171ff11010055006ec879b1e9963de5ee97e9c8710b742d6228252a5e2ca12d4ae81d7fe5ee8c5d0000000005f6c2a20000000000024a4cfffffff8000000006717b4ed000000006717b4ec0000000005f681dd000000000001eb610a0ce69e786af8d5d444214b3c705d084cbd19499c6376c9c2c1115b38b3720f5fc4354dc60556f66784e2cc2a563b4433b6193a152c4aebe4042468eb8ccf6b5ad1e3b34862b445822621fc94831f86b74280c9b238780d393ea76034a5931d9a0dc618a15be83970ccaa9f32ef9c74c9c66c6981897a86b3ec2f2ea4a92c9206abd9b0e23efccd35448a3d62f35ad102d5ee91b1617d7818a915dadbad766428f11d6f6287ce71bfc89e1cb2b6f716569c88efba8af9e83ecfe539d17d65fd52f86948affbda815d";
        updateData[2] =
            hex"504e415501000000054401000000041300e3e07a21c75498a61a82d4b2fa37bbebeaa8f8abe17fb3db97271745a373c06c2c1d372960c73e411fe10f6cdc6ebbb46ef9581f131a6e1c778ab10034fc5aa30001cec1889e5f0a89184937b4778ac1ae8725cb19896855fb58a7c624bb084fc6fb3332d325258e5e8176ec7a9de74c514364835c65eff19a2b5ee60474fc76afb60102bf2050e1fe26ca0b0dd98a8bc3dfd3eb2ce6f99974a9e91bdada1c79e7f44b3c4fab5c7ff05d53f242396e0d58acd3032818f776b0ae7b372f661b5cc6848c5101031c143bc117e93f706e0f09b2b928bcc9536615f3ffdcd2399151cb9d13bc47055a2ef52df3a90f210068ac16e19ec39e182bd133e7b9e9176c481707ea9abda001043168c440f04560eb44474085748b099d3242f30cb81c2d0acbab883b405747ca5d48842161331304563c937bc464c3188cd121fa10174ea50f5d7c310016573200054d6b4acdd74475763bbb26cf2b47f18e5b83e84e181205eeae0c0904e8d0ea812348e17f3638ed400b602acc3bfabb3e5f715ca2a590181bac05db5e4126b7b800066f978a0bc5b6cd01767587574ca7e678cbc971e8b2d36b306401b1412910b2ad13c426f4ac29ff3115b4c7e6ad13f23104baadb2cb88abfebdb60efb588b8b870107c7cdda4ddf8ee4b72152e965b0256bbf704b2b9c53c256d52deb2d13b68fc72b7dbebbba7148132570c25d9e7c70ec476e36368ed9f707982088f59b4dc2b20d0108e9cc45f9b460ffd1e7a12604da1506431abe53b6e70a0baf8eeb31bf8a9f3d6914ed163361170d008845a9310cff0963ef6c87937435676e67bc5265160659b70009f2bdfd0983f1087f718394aa29566cab8e14b0a31765ff4a372cddc60dccc9da394960886b7f6e25dd5e864fb7b2a7f318201cfba586f2566d9ebbc0ef03aa21010a5f6da79e89f009e6829f946aa3adf22854239cbdf182549c1d6126e17f6c0d936ce163b18e0b4a6d2253962003b08647728cb348a1b2f7dc763aa4c114b7fae7000b3ee68b890448cf0e99f4f043abe029fe5fb42d90f21700d41b77463203476e13140f077753e426dbad34a1cec5817c964c87955d0be563532e26b192717544c6010cc0b24137e84b4c7c81f08f2d1cb50f2e809f9968696fcf684ec446f3e8dd266e4ea019ada05b17f26321368ae8c68ef4ca5432b7891b6e3a613a2d4562743b81010d8d7179f7d179c0debc33427bd1aa4237da0e30dec43249028e0bdfaaf90b21713725b815676478379c9e7583575afb025dc4df24e14b3a7ff5130e9e75c162af000e0e71a6a8f0fdfbe4bc0889e02d4e61d9df3cacb7ea1d463625146ec1e44501222673299fec3e666845161014c7680050ea272b2b38cc09e5ebcce4ea108532b2000fe64403eedafc901eb118c25ab62814b1901f3c959cf75b72eb8de57c6a73241752a14d30b238ef62e76cb3580c636ae8ebacabba82e813c120a15eeaf51bc2f901101c0a4b0b08ce8791be395f5572c5923db935dd0978f8ca88b3b4d31fa749c9a6008b8b8c0ec518d5767c000c36691f37aee9c96866442d8cdd31f273c2af8b090111b551f0353caf870c667d8ab1a581b1ed98a2e3b6dae2e3ddcd764b5dd41f71135291d1c1e394d66e447776e378eed1dbc73852fdaf10c326ee25370ca44c964b001220b4932328f73a9dd570f2ff3b2f030f40333a62dab39f9d2d45de043b6d86dd3ede8bafebf09ce3b9c3d53596870778c7f66f301d30a7d802329522a230bbe6016717b4ed00000000001ae101faedac5851e32b9b23b5f9411a8c2bac4aae3ed4dd7b811dd1a72ea4aa71000000000542d622014155575600000000000a4f445f0000271033f17e93710e1d51d3c4902305687d619171ff11010055002b89b9dc8fdf9f34709a5b106b472f0f39bb6ca9ce04b0fd7f2e971688e2e53b0000000005f4c802000000000002d2e2fffffff8000000006717b4ed000000006717b4ec0000000005f4df2300000000000250a50afec2ebba05262b9ce993c4dab31417e198885c3b6ab874984a058f08868257407dd4012e9cc1aeb8f1444da33c48af077171327ba9ba03de6714c335558be4cb771ec8abce5027dad98a3ba0abb321abe34c7c5e6d55b481b0dfb59a784e9342bf2cae0160c15d315553454773ffb2c3fc5555305a1c3167b6c3310de4755a56aaf93929628a51bca9870bc388e33e154b506cb909bc60fbb8280b01a70e3498f11d6f6287ce71bfc89e1cb2b6f716569c88efba8af9e83ecfe539d17d65fd52f86948affbda815d";

        vm.deal(address(this), 1000);
        // Update the prices
        pyth.updatePriceFeedsIfNecessary{value: 1000}(
            updateData, priceIds, publishTimes
        );
    }
}

contract DepositCollateral is CollateralTest {
    function test_depositCollateral() public {
        uint256 preBalance = sUSD.balanceOf(ACTOR);

        vm.startPrank(ACTOR);

        sUSD.approve(address(engine), type(uint256).max);

        engine.modifyCollateral({
            _accountId: accountId,
            _synthMarketId: SUSD_SPOT_MARKET_ID,
            _amount: int256(AMOUNT)
        });

        vm.stopPrank();

        uint256 postBalance = sUSD.balanceOf(ACTOR);

        assertEq(postBalance, preBalance - AMOUNT);
    }

    function test_depositCollateral_availableMargin() public {
        vm.startPrank(ACTOR);

        sUSD.approve(address(engine), type(uint256).max);

        engine.modifyCollateral({
            _accountId: accountId,
            _synthMarketId: SUSD_SPOT_MARKET_ID,
            _amount: int256(AMOUNT)
        });

        vm.stopPrank();

        int256 availableMargin = perpsMarketProxy.getAvailableMargin(accountId);
        assertEq(availableMargin, int256(AMOUNT));
    }

    function test_depositCollateral_collateralAmount() public {
        vm.startPrank(ACTOR);

        sUSD.approve(address(engine), type(uint256).max);

        engine.modifyCollateral({
            _accountId: accountId,
            _synthMarketId: SUSD_SPOT_MARKET_ID,
            _amount: int256(AMOUNT)
        });

        vm.stopPrank();

        uint256 collateralAmountOfSynth =
            perpsMarketProxy.getCollateralAmount(accountId, SUSD_SPOT_MARKET_ID);
        assertEq(collateralAmountOfSynth, AMOUNT);
    }

    function test_depositCollateral_totalCollateralValue() public {
        vm.startPrank(ACTOR);

        sUSD.approve(address(engine), type(uint256).max);

        engine.modifyCollateral({
            _accountId: accountId,
            _synthMarketId: SUSD_SPOT_MARKET_ID,
            _amount: int256(AMOUNT)
        });

        vm.stopPrank();

        uint256 totalCollateralValue =
            perpsMarketProxy.totalCollateralValue(accountId);
        assertEq(totalCollateralValue, AMOUNT);
    }

    function test_depositCollateral_insufficient_balance() public {
        vm.startPrank(ACTOR);

        sUSD.approve(address(engine), type(uint256).max);

        vm.expectRevert(
            abi.encodeWithSelector(
                InsufficientBalance.selector, AMOUNT + 1, AMOUNT
            )
        );

        engine.modifyCollateral({
            _accountId: accountId,
            _synthMarketId: SUSD_SPOT_MARKET_ID,
            _amount: int256(AMOUNT + 1)
        });

        vm.stopPrank();
    }

    /// @custom:todo fix OracleDataRequired error
    // function test_depositCollateral_zap() public {
    //     uint256 decimalsFactor = 10 ** (18 - USDT.decimals());

    //     deal(address(USDT), ACTOR, SMALLEST_AMOUNT);

    //     vm.startPrank(ACTOR);

    //     USDT.approve(address(engine), type(uint256).max);

    // uint256 availableMarginBefore =
    //     uint256(perpsMarketProxy.getAvailableMargin(accountId));
    // assertEq(availableMarginBefore, 0);

    //     engine.modifyCollateralZap({
    //         _accountId: accountId,
    //         _amount: int256(SMALLEST_AMOUNT),
    //         _swapTolerance: SMALLEST_AMOUNT - 3,
    //         _zapTolerance: SMALLEST_AMOUNT - 3,
    //         _collateral: USDT
    //     });

    //     vm.stopPrank();

    //     uint256 availableMargin =
    //         uint256(perpsMarketProxy.getAvailableMargin(accountId));
    //     uint256 expectedMargin = SMALLEST_AMOUNT * decimalsFactor;
    //     assertWithinTolerance(expectedMargin, availableMargin, 3);
    // }

    function test_depositCollateral_wrap() public {
        deal(address(WETH), ACTOR, SMALLER_AMOUNT);

        vm.startPrank(ACTOR);

        WETH.approve(address(engine), type(uint256).max);

        uint256 availableMarginBefore =
            uint256(perpsMarketProxy.getAvailableMargin(accountId));
        assertEq(availableMarginBefore, 0);

        engine.modifyCollateralWrap({
            _accountId: accountId,
            _amount: int256(SMALLER_AMOUNT),
            _tolerance: SMALLER_AMOUNT,
            _collateral: WETH,
            _synthMarketId: 4
        });

        vm.stopPrank();

        uint256 availableMargin =
            uint256(perpsMarketProxy.getAvailableMargin(accountId));
        uint256 expectedMargin = SMALLER_AMOUNT * ETH_PRICE;
        assertWithinTolerance(expectedMargin, availableMargin, 2);
    }

    /// @custom:todo fix OracleDataRequired error
    // function test_depositCollateral_wrapTBTC() public {
    //     deal(address(tBTC), ACTOR, 1);

    //     vm.startPrank(ACTOR);

    //     tBTC.approve(address(engine), type(uint256).max);

    // uint256 availableMarginBefore =
    //     uint256(perpsMarketProxy.getAvailableMargin(accountId));
    // assertEq(availableMarginBefore, 0);

    //     engine.modifyCollateralWrap({
    //         _accountId: accountId,
    //         _amount: int256(1),
    //         _tolerance: 1,
    //         _collateral: tBTC,
    //         _synthMarketId: 3
    //     });

    //     vm.stopPrank();

    //     // uint256 availableMargin = uint256(perpsMarketProxy.getAvailableMargin(accountId));
    //     // uint256 expectedMargin = BTC_PRICE; // todo add BTC_PRICE to constants
    //     // assertWithinTolerance(expectedMargin, availableMargin, 2);
    // }

    /// @custom:todo fix OracleDataRequired error
    // function test_depositCollateral_wrapUSDE() public {
    //     uint256 decimalsFactor = 10 ** (18 - USDe.decimals());

    //     deal(address(USDe), ACTOR, SMALLER_AMOUNT);

    //     vm.startPrank(ACTOR);

    //     USDe.approve(address(engine), type(uint256).max);

    // uint256 availableMarginBefore =
    //     uint256(perpsMarketProxy.getAvailableMargin(accountId));
    // assertEq(availableMarginBefore, 0);

    //     engine.modifyCollateralWrap({
    //         _accountId: accountId,
    //         _amount: int256(SMALLER_AMOUNT),
    //         _tolerance: SMALLER_AMOUNT,
    //         _collateral: USDe,
    //         _synthMarketId: 5
    //     });

    //     vm.stopPrank();

    //     // uint256 availableMargin = uint256(perpsMarketProxy.getAvailableMargin(accountId));
    //     // uint256 expectedMargin = SMALLEST_AMOUNT * decimalsFactor;
    //     // assertWithinTolerance(expectedMargin, availableMargin, 2);
    // }

    /// @notice This test is expected to fail because sUSD is not a supported collateral
    function test_depositCollateral_wrapfail_sUSD() public {
        deal(address(sUSD), ACTOR, SMALLER_AMOUNT);

        vm.startPrank(ACTOR);

        sUSD.approve(address(engine), type(uint256).max);

        vm.expectRevert();
        engine.modifyCollateralWrap({
            _accountId: accountId,
            _amount: int256(SMALLER_AMOUNT),
            _tolerance: SMALLER_AMOUNT,
            _collateral: sUSD,
            _synthMarketId: 0
        });
    }

    /// @notice This test is expected to fail because USDC is not a supported collateral
    function test_depositCollateral_wrapfail_USDC() public {
        deal(address(USDC), ACTOR, SMALLEST_AMOUNT);

        vm.startPrank(ACTOR);

        USDC.approve(address(engine), type(uint256).max);

        vm.expectRevert();
        engine.modifyCollateralWrap({
            _accountId: accountId,
            _amount: int256(SMALLEST_AMOUNT),
            _tolerance: SMALLEST_AMOUNT,
            _collateral: USDC,
            _synthMarketId: 2
        });
    }

    function test_depositCollateral_ETH() public {
        vm.deal(ACTOR, SMALLER_AMOUNT);

        uint256 availableMarginBefore =
            uint256(perpsMarketProxy.getAvailableMargin(accountId));
        assertEq(availableMarginBefore, 0);

        vm.startPrank(ACTOR);

        engine.depositCollateralETH{value: SMALLER_AMOUNT}({
            _accountId: accountId,
            _amount: SMALLER_AMOUNT,
            _tolerance: SMALLER_AMOUNT
        });

        vm.stopPrank();

        uint256 availableMargin =
            uint256(perpsMarketProxy.getAvailableMargin(accountId));
        uint256 expectedMargin = SMALLER_AMOUNT * ETH_PRICE;
        assertWithinTolerance(expectedMargin, availableMargin, 2);
    }

    function test_depositCollateral_ETH_Fuzz(uint256 amount) public {
        /// @dev amount must be less than max MarketCollateralAmount - currentDepositedCollateral
        vm.assume(amount < MAX_WRAPPABLE_AMOUNT);
        vm.assume(amount > SMALLEST_AMOUNT);
        vm.deal(ACTOR, amount);

        uint256 availableMarginBefore =
            uint256(perpsMarketProxy.getAvailableMargin(accountId));
        assertEq(availableMarginBefore, 0);

        vm.startPrank(ACTOR);

        engine.depositCollateralETH{value: amount}({
            _accountId: accountId,
            _amount: amount,
            _tolerance: amount * 97 / 100
        });

        vm.stopPrank();

        uint256 availableMargin =
            uint256(perpsMarketProxy.getAvailableMargin(accountId));
        uint256 expectedMargin = amount * ETH_PRICE;
        assertWithinTolerance(expectedMargin, availableMargin, 3);
    }

    function test_depositCollateral_ETH_Partial_Fuzz(uint256 amount) public {
        /// @dev amount must be less than max MarketCollateralAmount - currentDepositedCollateral
        vm.assume(amount < MAX_WRAPPABLE_AMOUNT);
        vm.assume(amount > SMALLEST_AMOUNT * 2);
        vm.deal(ACTOR, amount);

        uint256 availableMarginBefore =
            uint256(perpsMarketProxy.getAvailableMargin(accountId));
        assertEq(availableMarginBefore, 0);

        vm.startPrank(ACTOR);

        engine.depositCollateralETH{value: amount}({
            _accountId: accountId,
            _amount: amount - SMALLEST_AMOUNT,
            _tolerance: (amount - SMALLEST_AMOUNT) * 97 / 100
        });

        vm.stopPrank();

        uint256 availableMargin =
            uint256(perpsMarketProxy.getAvailableMargin(accountId));
        uint256 expectedMargin = (amount - SMALLEST_AMOUNT) * ETH_PRICE;
        assertWithinTolerance(expectedMargin, availableMargin, 3);

        assertEq(address(engine).balance, SMALLEST_AMOUNT);
    }
}

contract WithdrawCollateral is CollateralTest {
    function test_withdrawCollateral() public {
        vm.startPrank(ACTOR);

        sUSD.approve(address(engine), type(uint256).max);

        engine.modifyCollateral({
            _accountId: accountId,
            _synthMarketId: SUSD_SPOT_MARKET_ID,
            _amount: int256(AMOUNT)
        });

        uint256 preBalance = sUSD.balanceOf(ACTOR);

        engine.modifyCollateral({
            _accountId: accountId,
            _synthMarketId: SUSD_SPOT_MARKET_ID,
            _amount: -int256(SMALLER_AMOUNT)
        });

        vm.stopPrank();

        uint256 postBalance = sUSD.balanceOf(ACTOR);

        assertEq(postBalance, preBalance + SMALLER_AMOUNT);
    }

    function test_withdrawCollateral_zero() public {
        /// @notice is amount is zero, modifyCollateral will logically treat
        /// the interaction as a withdraw which will then revert

        vm.startPrank(ACTOR);

        sUSD.approve(address(engine), type(uint256).max);

        engine.modifyCollateral({
            _accountId: accountId,
            _synthMarketId: SUSD_SPOT_MARKET_ID,
            _amount: int256(AMOUNT)
        });

        vm.expectRevert(abi.encodeWithSelector(InvalidAmountDelta.selector, 0));

        engine.modifyCollateral({
            _accountId: accountId,
            _synthMarketId: SUSD_SPOT_MARKET_ID,
            _amount: 0
        });

        vm.stopPrank();
    }

    function test_withdrawCollateral_insufficient_account_collateral_balance()
        public
    {
        vm.startPrank(ACTOR);

        sUSD.approve(address(engine), type(uint256).max);

        engine.modifyCollateral({
            _accountId: accountId,
            _synthMarketId: SUSD_SPOT_MARKET_ID,
            _amount: int256(AMOUNT)
        });

        vm.expectRevert(
            abi.encodeWithSelector(
                InsufficientSynthCollateral.selector,
                SUSD_SPOT_MARKET_ID,
                AMOUNT,
                AMOUNT + 1
            )
        );

        engine.modifyCollateral({
            _accountId: accountId,
            _synthMarketId: SUSD_SPOT_MARKET_ID,
            _amount: -int256(AMOUNT + 1)
        });

        vm.stopPrank();
    }

    /// @custom:todo fix OracleDataRequired error
    // function test_withdrawCollateral_zap() public {
    //     uint256 decimalsFactor = 10 ** (18 - USDT.decimals());

    //     deal(address(USDT), ACTOR, SMALLER_AMOUNT);

    //     vm.startPrank(ACTOR);

    //     USDT.approve(address(engine), type(uint256).max);

    //     // add the collateral
    //     engine.modifyCollateralZap({
    //         _accountId: accountId,
    //         _amount: int256(SMALLER_AMOUNT),
    //         _swapTolerance: 1,
    //         _zapTolerance: 1,
    //         _collateral: USDT
    //     });

    //     uint256 postBalanceUSDT = USDT.balanceOf(ACTOR);
    //     assertEq(postBalanceUSDT, 0);

    //     uint256 preBalanceUSDC = USDC.balanceOf(ACTOR);
    //     assertEq(preBalanceUSDC, 0);

    //     uint256 availableMargin =
    //         uint256(perpsMarketProxy.getAvailableMargin(accountId)); // 78_133551009252750000

    //     // remove the collateral
    //     engine.modifyCollateralZap({
    //         _accountId: accountId,
    //         _amount: -int256(availableMargin),
    //         _swapTolerance: 1,
    //         _zapTolerance: 1,
    //         _collateral: USDT
    //     });

    //     vm.stopPrank();
    //     uint256 postBalanceUSDC = USDC.balanceOf(ACTOR);
    //     uint256 expectedBalance = postBalanceUSDC * decimalsFactor;
    //     assertWithinTolerance(expectedBalance, availableMargin, 30);
    // }

    /// @custom:todo fix OracleDataRequired error
    // function test_withdrawCollateral_zap_Unauthorized() public {
    //     deal(address(USDT), ACTOR, SMALLER_AMOUNT);

    //     vm.startPrank(ACTOR);

    //     USDT.approve(address(engine), type(uint256).max);

    //     engine.modifyCollateralZap({
    //         _accountId: accountId,
    //         _amount: int256(SMALLER_AMOUNT),
    //         _swapTolerance: 1,
    //         _zapTolerance: 1,
    //         _collateral: USDT
    //     });

    //     vm.stopPrank();

    //     vm.expectRevert(abi.encodeWithSelector(IEngine.Unauthorized.selector));

    //     engine.modifyCollateralZap({
    //         _accountId: accountId,
    //         _amount: -int256(1),
    //         _swapTolerance: 1,
    //         _zapTolerance: 1,
    //         _collateral: USDT
    //     });
    // }

    function test_withdrawCollateral_wrap() public {
        deal(address(WETH), ACTOR, SMALLER_AMOUNT);

        vm.startPrank(ACTOR);

        WETH.approve(address(engine), type(uint256).max);

        engine.modifyCollateralWrap({
            _accountId: accountId,
            _amount: int256(SMALLER_AMOUNT),
            _tolerance: SMALLER_AMOUNT,
            _collateral: WETH,
            _synthMarketId: 4
        });

        uint256 preBalance = WETH.balanceOf(ACTOR);
        assertEq(preBalance, 0);

        engine.modifyCollateralWrap({
            _accountId: accountId,
            _amount: -int256(SMALLER_AMOUNT),
            _tolerance: SMALLER_AMOUNT,
            _collateral: WETH,
            _synthMarketId: 4
        });

        vm.stopPrank();

        uint256 postBalance = WETH.balanceOf(ACTOR);
        assertEq(postBalance, SMALLER_AMOUNT);
    }

    function test_withdrawCollateral_wrap_Unauthorized() public {
        deal(address(WETH), ACTOR, SMALLER_AMOUNT);

        vm.startPrank(ACTOR);

        WETH.approve(address(engine), type(uint256).max);

        engine.modifyCollateralWrap({
            _accountId: accountId,
            _amount: int256(SMALLER_AMOUNT),
            _tolerance: SMALLER_AMOUNT,
            _collateral: WETH,
            _synthMarketId: 4
        });

        vm.stopPrank();

        vm.expectRevert(abi.encodeWithSelector(IEngine.Unauthorized.selector));

        engine.modifyCollateralWrap({
            _accountId: accountId,
            _amount: -int256(SMALLER_AMOUNT),
            _tolerance: SMALLER_AMOUNT,
            _collateral: WETH,
            _synthMarketId: 4
        });
    }

    function test_withdrawCollateral_ETH() public {
        uint256 preBalance = ACTOR.balance;

        vm.deal(ACTOR, SMALLER_AMOUNT);

        vm.startPrank(ACTOR);

        engine.depositCollateralETH{value: SMALLER_AMOUNT}({
            _accountId: accountId,
            _amount: SMALLER_AMOUNT,
            _tolerance: SMALLER_AMOUNT
        });

        uint256 midBalance = ACTOR.balance;
        assertEq(midBalance, 0);

        engine.withdrawCollateralETH({
            _accountId: accountId,
            _amount: int256(SMALLER_AMOUNT),
            _tolerance: SMALLER_AMOUNT
        });

        vm.stopPrank();

        uint256 postBalance = ACTOR.balance;
        assertEq(postBalance, preBalance + SMALLER_AMOUNT);
    }

    function test_withdrawCollateral_ETH_Fuzz(uint256 amount) public {
        uint256 preBalance = ACTOR.balance;

        /// @dev amount must be less than max MarketCollateralAmount
        vm.assume(amount < MAX_WRAPPABLE_AMOUNT);
        vm.assume(amount > SMALLEST_AMOUNT);
        vm.deal(ACTOR, amount);

        vm.startPrank(ACTOR);

        engine.depositCollateralETH{value: amount}({
            _accountId: accountId,
            _amount: amount,
            _tolerance: amount * 97 / 100
        });

        uint256 midBalance = ACTOR.balance;
        assertEq(midBalance, 0);

        engine.withdrawCollateralETH({
            _accountId: accountId,
            _amount: int256(amount) - 1,
            _tolerance: amount * 97 / 100
        });

        vm.stopPrank();

        uint256 postBalance = ACTOR.balance;
        assertWithinTolerance(preBalance + amount, postBalance, 3);
    }

    function test_withdrawCollateral_ETH_Unauthorized() public {
        vm.deal(ACTOR, SMALLER_AMOUNT);

        vm.startPrank(ACTOR);

        engine.depositCollateralETH{value: SMALLER_AMOUNT}({
            _accountId: accountId,
            _amount: SMALLER_AMOUNT,
            _tolerance: SMALLER_AMOUNT
        });

        vm.stopPrank();

        vm.expectRevert(abi.encodeWithSelector(IEngine.Unauthorized.selector));

        engine.withdrawCollateralETH({
            _accountId: accountId,
            _amount: int256(SMALLER_AMOUNT),
            _tolerance: SMALLER_AMOUNT
        });
    }
}
