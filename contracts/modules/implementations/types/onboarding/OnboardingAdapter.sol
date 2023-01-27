//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "../../../interfaces/modules/onboarding/IOnboardingPlugin.sol";
import "../../../interfaces/registry/IPluginRegistry.sol";


contract OnboardingAdapter is Ownable {
    IPluginRegistry public pluginRegistry;
    mapping(IOnboardingPlugin => bool) public onboardingPlugins;
    IOnboardingPlugin[] public onboardingPluginsArray;

    constructor(IPluginRegistry _pluginRegistry) {
        pluginRegistry = _pluginRegistry;
    }

    modifier onlyPluginRegistry() {
        require(msg.sender == address(pluginRegistry), "Only PluginRegistry can call this function");
        _;
    }

    function addOnboardingPlugin(IOnboardingPlugin _onboardingPlugin) external onlyPluginRegistry {
        require(!onboardingPlugins[_onboardingPlugin], "Plugin already added");
        onboardingPlugins[_onboardingPlugin] = true;
        onboardingPluginsArray.push(_onboardingPlugin);
    }

    function isOnboarded(address member, uint role) public view returns (bool onboarded) {
        for (uint i = 0; i < onboardingPluginsArray.length; i++) {
            if (onboardingPluginsArray[i].isOnboarded(member, role)) {
                return true;
            }
        }
        return false;
    }

    function getOnboarded(address member, uint role) public view returns (IOnboardingPlugin[] memory) {
        IOnboardingPlugin[] memory relevantPlugins = new IOnboardingPlugin[](onboardingPluginsArray.length);
        uint onboardedPluginsCount = 0;
        for (uint i = 0; i < onboardingPluginsArray.length; i++) {
            if (onboardingPluginsArray[i].isOnboarded(member, role)) {
                relevantPlugins[onboardedPluginsCount] = onboardingPluginsArray[i];
                onboardedPluginsCount++;
            }
        }
        IOnboardingPlugin[] memory onboardedPlugins = new IOnboardingPlugin[](onboardedPluginsCount);
        for (uint i = 0; i < onboardedPluginsCount; i++) {
            onboardedPlugins[i] = relevantPlugins[i];
        }
        return onboardedPlugins;
    }
}
