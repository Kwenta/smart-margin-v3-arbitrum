// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.27;

import {ERC1967Proxy as Proxy} from
    "lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Engine} from "src/Engine.sol";
import {MulticallerWithSender} from "src/utils/MulticallerWithSender.sol";
import {BaseParameters} from "script/utils/parameters/BaseParameters.sol";
import {BaseSepoliaParameters} from
    "script/utils/parameters/BaseSepoliaParameters.sol";
import {ArbitrumParameters} from
    "script/utils/parameters/ArbitrumParameters.sol";
import {ArbitrumSepoliaParameters} from
    "script/utils/parameters/ArbitrumSepoliaParameters.sol";

// forge utils
import {Script} from "lib/forge-std/src/Script.sol";

/// @title Kwenta Smart Margin v3 deployment script
/// @author JaredBorders (jaredborders@pm.me)
contract Setup is Script {
    function deploySystem(
        address perpsMarketProxy,
        address spotMarketProxy,
        address sUSDProxy,
        address pDAO,
        address zap,
        address usdc,
        address weth
    ) public returns (Engine engine) {
        engine = new Engine({
            _perpsMarketProxy: perpsMarketProxy,
            _spotMarketProxy: spotMarketProxy,
            _sUSDProxy: sUSDProxy,
            _pDAO: pDAO,
            _zap: zap,
            _usdc: usdc,
            _weth: weth
        });

        // deploy ERC1967 proxy and set implementation to engine
        Proxy proxy = new Proxy(address(engine), "");

        // "wrap" proxy in IEngine interface
        engine = Engine(address(proxy));
    }
}

/// @dev steps to deploy and verify on Arbitrum:
/// (1) load the variables in the .env file via `source .env`
/// (2) run `forge script script/Deploy.s.sol:DeployArbitrum --rpc-url $ARBITRUM_RPC_URL --etherscan-api-key $ARBISCAN_API_KEY --broadcast --verify -vvvv`
contract DeployArbitrum is Setup, ArbitrumParameters {
    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        Setup.deploySystem({
            perpsMarketProxy: PERPS_MARKET_PROXY,
            spotMarketProxy: SPOT_MARKET_PROXY,
            sUSDProxy: USD_PROXY,
            pDAO: PDAO,
            zap: ZAP,
            usdc: USDC,
            weth: WETH
        });

        vm.stopBroadcast();
    }
}

/// @dev steps to deploy and verify on Arbitrum Sepolia:
/// (1) load the variables in the .env file via `source .env`
/// (2) run `forge script script/Deploy.s.sol:DeployArbitrumSepolia --rpc-url $ARBITRUM_SEPOLIA_RPC_URL --etherscan-api-key $ARBISCAN_API_KEY --broadcast --verify -vvvv`
contract DeployArbitrumSepolia is Setup, ArbitrumSepoliaParameters {
    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        Setup.deploySystem({
            perpsMarketProxy: PERPS_MARKET_PROXY,
            spotMarketProxy: SPOT_MARKET_PROXY,
            sUSDProxy: USD_PROXY,
            pDAO: PDAO,
            zap: ZAP,
            usdc: USDC,
            weth: WETH
        });

        vm.stopBroadcast();
    }
}

/// @dev steps to deploy and verify on Arbitrum:
/// (1) load the variables in the .env file via `source .env`
/// (2) run `forge script script/Deploy.s.sol:DeployMulticallArbitrum --rpc-url $ARBITRUM_RPC_URL --etherscan-api-key $ARBISCAN_API_KEY --broadcast --verify -vvvv`
contract DeployMulticallArbitrum is Setup, ArbitrumParameters {
    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        new MulticallerWithSender();

        vm.stopBroadcast();
    }
}
