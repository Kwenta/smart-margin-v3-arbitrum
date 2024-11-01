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
    uint256 public constant INITIAL_DEBT = 2904906141298364509;

    address constant USDC_ADDR = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address constant WETH_ADDR = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;

    // 1600104571620674
    uint256 SWAP_AMOUNT = 1600104571620674;

    bytes swapPath;
    string pathId;

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
            hex"504e41550100000003b801000000040d00dc854c59882b895d2eb769d2559b81a64093cd33b44a1b20fe41ef7866b118ac6bd20770017013ede5e129d7e562b91f32909538a395c5a253c4fffd306f6d5801023a79d8e30e6bd4417813571cb4eb53de79858ef9bcc98027ada84f141a28f4113b445a98c0e57f8e787e0c6ae8f3e8de7dd9397005826bb7069d25f8614e62010004171720e1d6d75a0c6f82e178f60d482ada337a5ba0f0abfafee05f7d999df73c3e7c71945e62b6f46482f9df6f71752fb04b28d92cd3b3af47dca04ea0367a940006b18df51b50f97c401347bb7eb5928244ae709ef083ede52c28afcd2c4dbc39c10327681a58c0f74855d8518fa69f44de6471d288761d61927e1b51011e28c7e60008a22bfb8b4e67800ee1c54f36f17a1facdb175260e557a9b0fc1fd61926fafa680558a1b29aba7fb4da3746c77dde777fb205a38b253c25305938edb5cfac8251000aa34599bf78d4c06e395df0ccf2a4ea9b71c2df4ed94a3d1113919a90d767a87e48d0d8e978585ccebb7edf658ab8269d711b4ade95cbe9e59e789e3e991165a6010bae42b5249bd26eb21a322f6a20ff07e773d73a3e0a6804c17ed0d59c04ab996f076183f8b7286ef7f4609e3fd3170c0375cf2c4ce4d310bf23ce96a37240d7ab010c684832ce08eeca8a45b1d730c6a4839480ff912f58e6d7717a6559d8b17551af4fce73b988c77baf7650acf8276eb4a4707c01ec7260329abee71438cad90d33010d962a8280687cf3028b1ee9bdd07987e371a85a944a1e2d3dc85bc36213d948cf634b182b7a063ea4ddc80fe9fac099eb819f561cd8327a2ec25261a37fab20e0000e42c83cf7511c16c44fe9f098abb588f83bd4a301a5fbfb24dfdf7be62cd7405307a748593c5b70b9196cf3f60b5711264e6054729dbbdfcb539f86f760d19999000f5f73476ea4037daab49b1b5bc81ff258b797cad6ee10ece23055869a0a6d1656684dca9d9e9cebb886ec5c9746ba0c06dc8ad6e25c703630c31a1a98941cc10e001109a7e439174bf54bf081553872ebc178a9991123299a6982f3bb8148389c937f29d17327f43e01dfa3562e138620063fd448914d2756c20a80cff21e29d5cb640012e2cc21e7baa30c116548770443983c854061858fb0a49344ed47a4f53ebc5753521d2eadfbf701eef518ca80b13581a63817167bd89bf3ff6902388332bd4e75016724e55c00000000001ae101faedac5851e32b9b23b5f9411a8c2bac4aae3ed4dd7b811dd1a72ea4aa710000000005632fd3014155575600000000000a6ffa1400002710f308eea15cf1b00498b2e14f0678841431e664be01005500eaa020c61cc479712813461ce153894a96a6c00b21ed0cfc2798d1f9a9e9c94a0000000005f5d40300000000000136ddfffffff8000000006724e55c000000006724e55b0000000005f5d5d600000000000170c50a0e13d5dac884f1244bb5ff8607ca017197c70fa74b4ca9959b5fcb7291e0df1d0e28aa53277e03b8ec12159dc1698fca5aca93b12f40b85f80a6579417cd88e645241fe9d12b46141116be7dfa8eba3d9939a69f7b3fc4df243ba7da496137a132a6b9240bcf63034a8bb14625fc2b5c9dc840e1cdc36b5ebc736a8d4e82a617da80db66e03a30d95a09a33976f10348187e3d99162b179ddfd418df929139f4aa76b2020622c682f938dfa3629ce9473338fce9e9cc76170caf92b307893c30bfaa9f8ec077cee2";

        vm.deal(address(this), 100);
        // Update the prices
        pyth.updatePriceFeedsIfNecessary{value: 100}(
            updateData, priceIds, publishTimes
        );

        headers.push("Content-Type: application/json");
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

        pathId = getOdosQuotePathId(
                ARBITRUM_CHAIN_ID, ARBITRUM_WETH, SWAP_AMOUNT, ARBITRUM_USDC
            );

        swapPath = getAssemblePath(pathId);

        engine.unwindCollateral({
            _accountId: ACCOUNT_ID,
            _collateralId: 4,
            _collateralAmount: 34357000000000000,
            _collateral: WETH_ADDR,
            _zapMinAmountOut: 2732065100000000000,
            _unwrapMinAmountOut: 32606510850000000,
            _swapMaxAmountIn: SWAP_AMOUNT,
            _path: swapPath
        });

        vm.stopPrank();

        uint256 balanceAfter = WETH.balanceOf(DEBT_ACTOR);

        assertGt(balanceAfter, balanceBefore);
        availableMargin = perpsMarketProxy.getAvailableMargin(ACCOUNT_ID);
        assertEq(availableMargin, 0);
    }
}
