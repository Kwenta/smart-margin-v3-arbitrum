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
    uint256 public constant INITIAL_DEBT = 2_244_714_058_540_271_627;

    address constant USDC_ADDR = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address constant WETH_ADDR = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;

    uint256 SWAP_AMOUNT = 1_352_346_556_314_334;

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
            hex"504e41550100000003b801000000040d00a8f4b75b298056eec7c850b063a86e662469f2dcba5b2dece3800ad96a7e58b53a341951f9bdb90e3be69316f0f3943db4fca7daaa312e665dd8649f637b17340103b87fdacf139b256d1b9be2295a192285f425c7fdbc00374fe16e6cbd211c17df55cf0b3d1bc82c1f4e4af50882f6e1e817c9c0d8115220381bb9db3cf98ce4590104868ff10154e07cd5879b04b34dfdd0ce39a309e51105aa3b8826cb7aa53fdbbc1dc07f4537a6d2cd2407ae34d679b8ff04fcafecb70b422c79adbb39e10ebfef0006c9a8afefeaeb75de5220ad8f90c47e3c27f0cbdf8b7a7032deb71b29abf3672c1f2ed9aa661dde492407bb87a0b2f9fcb3ee9e8216d87074d41683c5d88548290008714b96d791878d33f000ea4203f84f00f054313a612927a4350463b34ef75b9720f6e6bd35cb562990c80e896e162a6bd40ac5cc6b6a8e7b31088e266477eb37010ba577fb747fb1ea1a2e2518f86e6a82966c93eff675a15f57d6ac9aa0c6822ae70f6b2cd47bfcbb97061ed2a68ef1351a0ec488b9e379e5565dc9299cd17dbfaa000cc7a13d14f93d64d41fed0ec8220c509cdadcee117f549316c99770f46f4181697a447fa434dd9eb6e844283d3958bc3894f7f319918c624fa8ad8aa303de5d3d000d3f2de428664bf2b1d7eadf45975c836f314fbb4a2555bdc6b44173aaeb296a87096cb2901c01fa728c311e3a1850ea059dd6d7078a304af0f41e08b0de512341010ec4d0573d38497ac40d9907bfd719fe8e1dad361df52705705505b0d36fa11d6a7c0e5d0e104a869c0d2a9efb3c7950990867388f0d5c38118f367b3f02af1404000f9b310d14de9c9aa94d9333af826fd86e42eca2d31a8b05a60341e2a67fed0d2443251998d7d20560b49454c8ab04ed2c57897253a5eb8ca57eb14c9881e03e6b0110197c27d83381978f0f59d7ab0d6e220f0819f69c29194f873e8174f51dfdb1841d3cd1dc4e51e07708036f278c60ad9f8261ea65eb01475f9256a85c7382f0c201111ea40f41e4b524f425691fb83dfa36e9797d5294ce0580810d0b1afdb017e26e33c340138c79d56d32d189e97a4aba0d5f65539d26d986e5085ffa2cab6fc04d01124f9272dda70e019fb8e9b2db5a1f8183b13b4f68a4514fb3a23a730e794ad27162698908a116904635fcc736031bf0513a78dec73fc0d6247c26503222878ded0067258cf700000000001ae101faedac5851e32b9b23b5f9411a8c2bac4aae3ed4dd7b811dd1a72ea4aa71000000000564d5b4014155575600000000000a719ff90000271078a9ea58b123a752febe0b3aee38a09a1f4a8bff01005500eaa020c61cc479712813461ce153894a96a6c00b21ed0cfc2798d1f9a9e9c94a0000000005f5c6bc000000000000f8edfffffff80000000067258cf70000000067258cf60000000005f5c743000000000000fe050a1da36d5d990b156209effe9e5f63c7b2b42f4c5823ee5b4339eac7c840f0f125614e0199743e70251c2e05d61c506bfbc2e6c35bdcba82e2d8a29976667167062e9be9d49d361f0ee7ba15b327d1be67925f3547b826e1fe4c8fa002534d62acfb1bc167138c45b0bae1a81e0d8bda8e2e5471945c48f53b5b8b6ab80e4b892aa601662427827aaca03b35374e35c799f3bcbc8868ef45fb28cd5f0a34f33e462f5b91841f86d0c86621de1f7c9f0c10f02931cd0cc06d6becb4d476e1d2e1b328c04674f11dd641";

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
            _collateralAmount: 36_000_000_000_000_000,
            _collateral: WETH_ADDR,
            _zapMinAmountOut: 2_222_267_000_000_000_000,
            _unwrapMinAmountOut: 35_964_000_000_000_000,
            _swapMaxAmountIn: SWAP_AMOUNT,
            _path: swapPath
        });

        vm.stopPrank();

        uint256 balanceAfter = WETH.balanceOf(DEBT_ACTOR);

        assertGt(balanceAfter, balanceBefore);
    }
}
