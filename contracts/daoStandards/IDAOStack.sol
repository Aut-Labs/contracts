//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


interface IDAOStack {
    /// @notice Function in the DAOStack contract for fetching its nativeToken
    /// @return The address of the nativeToken
    function nativeToken() external view returns (IERC20);

    /// @notice Function in the DAOStack contract for fetching its nativeReputation
    /// @return The address of the nativeReputation
    function nativeReputation() external view returns (IERC20);
}
