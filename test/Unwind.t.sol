// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.27;

import {Bootstrap, Engine} from "test/utils/Bootstrap.sol";
import {IEngine} from "src/interfaces/IEngine.sol";
import {MathLib} from "src/libraries/MathLib.sol";

contract UnwindTest is Bootstrap {
    using MathLib for int128;
    using MathLib for int256;
    using MathLib for uint256;

    address public constant DEBT_ACTOR =
        address(0x72A8EA777f5Aa58a1E5a405931e2ccb455B60088);
    uint128 public constant ACCOUNT_ID =
        170_141_183_460_469_231_731_687_303_715_884_105_766;
    uint256 public constant INITIAL_DEBT = 3_476_723_239_659_051_520;

    address constant USDC_ADDR = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address constant WETH_ADDR = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;

    uint256 SWAP_AMOUNT = 1_863_937_271_005_953;

    function setUp() public {
        vm.rollFork(269_969_820);
        initializeArbitrum();

        synthMinter.mint_sUSD(DEBT_ACTOR, AMOUNT);

        vm.startPrank(DEBT_ACTOR);
        perpsMarketProxy.grantPermission({
            accountId: ACCOUNT_ID,
            permission: ADMIN_PERMISSION,
            user: address(engine)
        });
        vm.stopPrank();

        /// @dev Update price feed for USDC
        bytes32[] memory priceIds = new bytes32[](1);
        priceIds[0] =
            0xeaa020c61cc479712813461ce153894a96a6c00b21ed0cfc2798d1f9a9e9c94a; // USDC price feed

        // Current timestamp
        uint64[] memory publishTimes = new uint64[](1);
        publishTimes[0] = uint64(block.timestamp);

        // update data corresponding to the USDC price feed at block.timestamp
        bytes[] memory updateData = new bytes[](1);
        updateData[0] =
            hex"504e41550100000003b801000000040d001f911549a7a42d309d3843688e51d5b9b6c5c230b881c5ea10d581f4f5fb9dc034b7a4d720977ebb23d73464b3f20dfb86e7247f6d40ef64607c7705ace7d9100103105c8e6139881c163c207f5ce97bc085287ad3478d3e7fc18a34ac8ca5e123965b2c4a02a2b40f25ac648406fbfd3909bc8afe071504157fde4025fb419c271700042a8db53799cc1e7b0077839f3db90e968c4551e29db56184c0cba1b42c574dda0140d9ed330d810d7d88d57ce12a7eeefab20c657077c54753bd1926aece427a00068dc50aee0f692d483d0956dae6d33362a3e8b638d753de31fefe0c49d79a08d83d752912bb632ad6840221c7712c521fee6895a6efe8906d7e05cff84436a405010824e28ae6227e2996f43685e4e0627e74a3cbb83d1976a9cf83f264e85491c8b47731ef415fb2a6f4aec39aa949b4962fde49e59d39c1baa07c79f2a9c0ee2aa7000a02290a4d4ab221747e13b948e5557d4af70abe5deb86c9ff5c85336bbe7015cf458a44933a2d8483b60f4e84c01136a10495e6dc16997fee21784d6881758013000cbc00a65025e54954cffe3a0d198072a6d6c00cd8b1c8d6de320569830adf0eff6263e5faf67bd5710de9f2697727dc39e04c07d90fb88a7fde6339d1e30c490c000da02ceecf3294b31d60cadc7e6f34b60fcb6c9dbec9e5e560d0d9268240c57e497ca6ce35b389d28d580e42a4c8ca4271c0f788a983a66ec2fc6fef1495b78ab0000e22ab527f8ffa1de4c72a43e08533785ceefe564226ae740dcd5b722288b3c32874c3af15d8b693dea0122095d787d84de43e8a35c1cdc26f950405b29c25bfac000ffb1dae60878c8f740080827816f1e184fa2cfa6c21079402d1c9485a6cce541658f511c8bdc6b1500f7adc2c8bf7334243af1d5b10cbb8659822dd634ffc316c001095504651aec239a0f65a6999801bfe477aa60cecfd34358cfba36be35548357b641b2e0a073c9e09e2cd7799ba42a8ed976c715d43c4d9244ea5b99ef0dfb8560111377924dcaba0deaa97fb683fda1da22742d37c4dd2aba24f25d3a1f31f21651f64250c3d48e6801783abf0c03fbfce4cccecb540bc442b94637556f05e5cdb790112daff1ac205840bd65d97c6f939e7e0c91d7c12b4f2d2981da4688d909c793287679cd8ba1ea16007a60bd4e7125e45b7a58278d8d16d425a2acc6c24c171c89701672501c600000000001ae101faedac5851e32b9b23b5f9411a8c2bac4aae3ed4dd7b811dd1a72ea4aa71000000000563771b014155575600000000000a7041600000271040db12dad32cacbf3eab08562f8886303fb3cfdb01005500eaa020c61cc479712813461ce153894a96a6c00b21ed0cfc2798d1f9a9e9c94a0000000005f5e12500000000000118b7fffffff800000000672501c600000000672501c50000000005f5c85500000000000119520afd50d1b06c773e3d4cfb305f6094a62f4598af7bdc391d4a165511ebfd94f19cae1ccecee0b77b19e5b73ccc7f0f5f33f71acfacdbe33be615c7a8f4345eb3f5f027d6077e3bd0cddca11f6e8c40b7abe418cf37e66406eeae267af42f63d9fa6afac62e257ea758a778f23098b54c0cf07f3e3cb52c5f78be7e3511032e90ca52e46ac2310e28e7003b5b23244794619cc3ec4e3eee2f57c494638c743b4c7f7adffb702e24a40303177c461a2306ce99df7780ce380849efda772f065caa02820d2d1437ccc0ae";

        vm.deal(address(this), 100);
        // Update the prices
        pyth.updatePriceFeedsIfNecessary{value: 100}(
            updateData, priceIds, publishTimes
        );
    }

    function test_unwindCollateral_UNAUTHORIZED() public {
        vm.expectRevert(abi.encodeWithSelector(IEngine.Unauthorized.selector));
        engine.unwindCollateral(accountId, 1, 1, address(0), 1, 1, 1, "");
    }

    function test_unwindCollateralETH_UNAUTHORIZED() public {
        vm.expectRevert(abi.encodeWithSelector(IEngine.Unauthorized.selector));
        engine.unwindCollateral(accountId, 1, 1, address(0), 1, 1, 1, "");
    }

    function test_unwindCollateral() public {
        uint256 initialAccountDebt = perpsMarketProxy.debt(ACCOUNT_ID);
        assertEq(initialAccountDebt, INITIAL_DEBT);

        int256 withdrawableMargin =
            perpsMarketProxy.getWithdrawableMargin(ACCOUNT_ID);

        /// While there is debt, withdrawable margin should be 0
        assertEq(withdrawableMargin, 0);

        int256 availableMargin = perpsMarketProxy.getAvailableMargin(ACCOUNT_ID);
        assertGt(availableMargin, 0);

        uint256 balanceBefore = WETH.balanceOf(DEBT_ACTOR);

        vm.startPrank(DEBT_ACTOR);

        uint24 FEE_30 = 3000;
        bytes memory weth_path = abi.encodePacked(USDC_ADDR, FEE_30, WETH_ADDR);

        engine.unwindCollateral({
            _accountId: ACCOUNT_ID,
            _collateralId: 4,
            _collateralAmount: 39_000_000_000_000_000,
            _collateral: WETH_ADDR,
            _zapMinAmountOut: 3_441_957_000_000_000_000,
            _unwrapMinAmountOut: 38_961_000_000_000_000,
            _swapMaxAmountIn: SWAP_AMOUNT,
            _path: weth_path
        });

        vm.stopPrank();

        uint256 balanceAfter = WETH.balanceOf(DEBT_ACTOR);

        assertGt(balanceAfter, balanceBefore);
    }
}
