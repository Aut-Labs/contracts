// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import {IUtilsRegistry} from "../utilsRegistry/IUtilsRegistry.sol";

/// @title Conditional Aut token
/// @author Āut Labs
/// @notice Conditional Aut token with symbol c-aut
contract CAut is ERC1155, AccessControl {
     // @notice first reputation mining threshold of 24 periods
    uint256 private constant FIRST_MINING_REWARD_DURATION_THRESHOLD = 24;
    // @notice amount of months to mine tokens
    uint256 constant TOTAL_AMOUNT_OF_MINING_IN_MONTHS = 48;

    IUtilsRegistry immutable utilsRegistry;

    bytes32 public constant BURNER_ROLE = keccak256("BURNER");

    // @notice first period id
    uint256 public firstPeriodId = 1;

    /// @notice creates the Conditional Aut token (c-aut), initializes the sender as the admin, configures the UtilsRegistry contract, mints 100 million tokens to the sender
    /// @param _owner the owner of the contract
    /// @param _utilsRegistry the address of the plugin registry contract
    constructor(address _owner, address _utilsRegistry) ERC1155("") {
        require(_owner != address(0) && _utilsRegistry != address(0), "zero address passed as parameter");
        _grantRole(DEFAULT_ADMIN_ROLE, _owner);
        utilsRegistry = IUtilsRegistry(_utilsRegistry);
    }

    function mintInitialSupply(address receiver) external onlyRole(DEFAULT_ADMIN_ROLE){
        require(receiver != address(0), "cannot mint to zero address");
         // initialize tokensLeft mapping for each period
        for (uint256 i = firstPeriodId; i <= TOTAL_AMOUNT_OF_MINING_IN_MONTHS; i++) {
            // @todo add period number to description?
            _mint(receiver, i, getTokensForPeriod(i), "c-aut");
        }
    }

    /// @notice returns the amount of tokens that will be distributed within a given period
    /// @param _period the period in which we want to know the tokens that are being distributed
    /// @return the amount of tokens that will be distributed within a given period
    function getTokensForPeriod(uint256 _period) public pure returns (uint256) {
        // 500000 tokens for the first 2 years
        if (_period > 0 && _period <= FIRST_MINING_REWARD_DURATION_THRESHOLD) {
            return 500000 ether;
        }
        // 1000000 tokens for years 3 and 4
        if (_period > FIRST_MINING_REWARD_DURATION_THRESHOLD && _period <= TOTAL_AMOUNT_OF_MINING_IN_MONTHS) {
            return 1000000 ether;
        }
        return 0;
    }

      /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /// @notice restricts the transfer between accounts and will fail when the sender or receiver is not a registered plugin in the utils registry
    /// @param from the address of the sender
    /// @param to the address of the receiver
    /// @param id the period id of the token
    /// @param value the amount of tokens to transfer
    // @todo check what data parameter is used for exactly
    /// @param data additional data 
     function safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes memory data) public override {
        require(utilsRegistry.isPlugin(to) || utilsRegistry.isPlugin(from), "Transfer not allowed");
        address sender = _msgSender();
        if (from != sender && !isApprovedForAll(from, sender)) {
            revert ERC1155MissingApprovalForAll(sender, from);
        }
        _safeTransferFrom(from, to, id, value, data);
    }

    /// @notice restricts the transfer between accounts and will fail when the sender or receiver is not a registered plugin in the utils registry
    /// @param from the address of the sender
    /// @param to the address of the receiver
    /// @param ids array of period ids
    /// @param values array of amounts to transfer
    /// @param data additional data 
   function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) public override {
        require(utilsRegistry.isPlugin(to) || utilsRegistry.isPlugin(from), "Transfer not allowed");
        address sender = _msgSender();
    
        if (from != sender && !isApprovedForAll(from, sender)) {
            revert ERC1155MissingApprovalForAll(sender, from);
        }
        _safeBatchTransferFrom(from, to, ids, values, data);
    }

    /// @notice burn an amount of tokens for a given account, only callable by an address with the BURNER_ROLE
    /// @param account the address of the account to burn tokens from
    /// @param id the period id of the token
    /// @param value the amount of tokens to transfer
    /// @return bool whether the transfer was successful
    function burn(address account, uint256 id, uint256 value) external onlyRole(BURNER_ROLE) returns (bool) {
        _burn(account, id, value);
        return true;
    }
}
