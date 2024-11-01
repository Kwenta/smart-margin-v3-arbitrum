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
    uint256 public constant INITIAL_DEBT = 8_381_435_606_953_380_465;

    address constant USDC_ADDR = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address constant WETH_ADDR = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;

    function setUp() public {
        vm.rollFork(ARBITRUM_BLOCK_NUMBER);
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
            hex"504e415501000000050201000000041200c263f5843d0b80e0b369d475843cb4592c46eed8eb47075499cfe9795cd0f8a92e528c07c6c416e18e693b2bb902ae90996dd8c10257f4cf936873786e9a68df00023b936189db6081a4dde281c253391dea32002bfc72877b9e0ee79346278df66d6d0b583e094fec5b2e2a65a960db951665cac7f6f6e898a9ba41ecedbf76bac80103aceff91ffada63928ea46a08e9d55d097be3fca20d0dd2dd6d1a282f8acee9b018cedaff4c2dca4c4d9b9ff23e81240f3a429e181b824f8f744ff9156765566301045c0beff121317afff3990f94cfddfb72b206c1e4034958c70b8b4557eec6389976677243060a852d10459a77841061aec4d7878e7f1073e275ced2aef4c4d3490105f026549c8f256180ec7104d17cd8735546ce90957bb5a1b7f5c641c9c5877a6734d20834ac35822f59d8d4921cac49b7cdb3abcb2b0d34a1d22291fcd53cd67e0106de816e10ae36ebc937f17c0f9ac5c5fa96de6beebd44a024430299a9ac2e97b24f0301ed9e1254f7aa929cf7f1b37d53780747bb09d6114612e63767d5f79ce100071e8733013dadab0e67b5e7bf14240a6f1ae0430b205c83f20dcdfc5e45c4707c705e7c39503d2fb25d725c5b5e61ef0b7d4e41a28f0d59df3488ebabe789fc480108d8a3337a33959db15098211f49a214576896a614c41236be403c579b448427815c82aa76622e3c23fbd6cefc62a79178b54295dc849aa2a5a336ae408b08f85f0109934fe428f4c88b9c6b8fc7a2166ea88a9c6b4e3f5a6aeefd9aecf1acec41679673d6c51af30e8d15e8678838a11483c8ac7a5ee5ad78e334656a0de61a20f76d010ae6465aa1e9493823c52ad871b30134fe8d1787c41e00a3083ddcaa63937130e7448956e75d4e5e8968e7b2fbb84aaf1ea7e2c62342d37644666f628a918aaed9000ba4b868900eceea2f0e3b5795250f339faffa7ac571b3a58401ff3d224fe6f8a11b5db34d4139b4be18bce893d563a2a24d88b3c8f1bafc13b521164f3d4d54b9010cdf4776c0a6ed8609ccd26e2bdfc81e5919f887c33a3d706b2743a9528a9adcae41db90ca880caa7308aff9c0408eca39b90426f90634a04578937a0dcd2872b5000d841d13a68db293bcab149b8983e7ae95aad1d7f9efd0b91dc778d3373f880349623655fe35d8b4ac72dac8c04a8fadaf7262a35ab19af07f2d92827363efe411010e0feb502cf69bbec4fb01207ea74be3aba296cb6e18430f3b48f9aecf7a905f3b29b52e48d8f48641a54946a93e0cc98b9fad1c5ec43db6cb4a0da150860f73ff000f556222f649241627ebd466dec555100edf073d552b290cfeeab4087d715c15927b9887cc99678b630edd3d7c8141e1038f6aa807c1c1ba7623de6ef3a4c32fde01109ee331809ddd5f5414b292a6c622606267e66c3d2120a1b49bf1e09396c38581749c3f67ee1d77a30eb4ca0ce6a95ea60eaa8bd9eccc5f98dd931f5ffc70db89001156a64e268614bf17341fb6d7707e4806978b223648ddb27151bd9d8b0b2bf88740df9414efe0ab154703b2eeb1e813032f5801e00c7c16abb6d404fbd444c7670112c94178f6096e55ec7a2b122d4bbac456d9d9b1b736e4736848095802ad634707617581527ffc2d5a0ca57b2fe7af967e113fa24499664cb9c0d7cb05cdbc32db01671909b300000000001ae101faedac5851e32b9b23b5f9411a8c2bac4aae3ed4dd7b811dd1a72ea4aa7100000000054612ab014155575600000000000a5283eb0000271051a8369abb2b7822887724483c358aae8842856301005500eaa020c61cc479712813461ce153894a96a6c00b21ed0cfc2798d1f9a9e9c94a0000000005f5e27b0000000000012b17fffffff800000000671909b300000000671909b20000000005f5ce0c0000000000014c3f0aca11e0edf19ead0795ce17c6c6c11dbd59397d81f2bfb6a904ef0ed11938fc611621ecd2617a5a14bf49c0d03a15e7debb405abd4be2dbcf77956d4c27a51de72bb2b17636ad12adeb9764a8922d2a9ac963ff9f7103cda085f716c853e3528226ddcf84278f9f6da994b0689c225f1d48b9c02ba27b3438fc857323418a850f2dc644c6c5309901ee4948b543d9924d80405c8813930058d98253debd86f63168f37d412f49fb5f3d32e51b71c53bfd9d45d35bbc91ca8f47c16dcb7a34a897daebf0fcf5b90279";

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
            _collateralAmount: 38_000_000_000_000_000,
            _collateral: WETH_ADDR,
            _zapMinAmountOut: 829_762_200_000_000_000,
            _unwrapMinAmountOut: 3_796_200_000_000_000,
            _swapMaxAmountIn: 3_824_606_425_619_680,
            _path: weth_path
        });

        vm.stopPrank();

        uint256 balanceAfter = WETH.balanceOf(DEBT_ACTOR);

        assertGt(balanceAfter, balanceBefore);
        availableMargin = perpsMarketProxy.getAvailableMargin(ACCOUNT_ID);
        assertEq(availableMargin, 0);
    }
}
