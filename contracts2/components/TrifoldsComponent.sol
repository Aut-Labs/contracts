//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../base/ComponentBase.sol";


/// two levels of token access
// 1 -- admin (can manage the token id)
// 2 -- operator (can act on behalf of token id)

contract TrifoldsComponent is Initializable, ComponentBase, ERC721Upgradeable {
    event NodeAdded(uint64 primaryKey, uint64 uplink, uint8 nodeType, bytes32 symbol, address operator);

    enum ENodeType {
        Cusp,
        Trifold
    }

    struct TNode {
        uint64 uplink;
        uint64 depth;
        uint8 nodeType;
        bytes32 ipfsHash;
    }

    TNode[] internal _graph;
    mapping(uint64 => uint64[]) internal _nodeUplinkExpJumps;

    function initialize(string memory name_, string memory symbol_) public initializer {
        ERC721Upgradeable.__ERC721_init(name_, symbol_);
        TNode memory node;
        _graph.push(node);
        _mint(_msgSender(), 0);
    }

    /// @dev set associated hash 
    function _setIpfsHash(uint64 authorization, uint64 to, bytes32 ipfsHash) internal {
        require(to < _graph.length);
        require(ipfsHash != bytes32(0));
        require(ERC721Upgradeable.isApprovedForAll(ERC721Upgradeable.ownerOf(authorization), _msgSender()));
        require(_checkUplink(to, authorization));
        _graph[to].ipfsHash = ipfsHash;
    }

    /// @dev add Trifold node with its Cusps
    function _addTrifold(uint64 authorization, uint64 to, bytes32 ipfsHash, bytes32[3] calldata roles) internal {
        address sender = _msgSender();
        uint64 length = uint64(_graph.length);
        require(to < length);
        TNode memory toNode = _graph[to];
        require(toNode.nodeType == uint8(ENodeType.Cusp));
        require(ERC721Upgradeable.isApprovedForAll(ERC721Upgradeable.ownerOf(authorization), _msgSender()));
        require(_checkUplink(to, authorization));

        TNode memory trifoldNode;
        TNode[3] memory cuspNodes;
        trifoldNode.depth = toNode.depth + 1;
        trifoldNode.uplink = to;
        trifoldNode.nodeType = uint8(ENodeType.Trifold);
        trifoldNode.ipfsHash = ipfsHash;
        _graph.push(trifoldNode);
        _mint(sender, length);
        _fillUplinkExpJumps(length);
        emit NodeAdded(length, to, uint8(ENodeType.Trifold), ipfsHash, sender);

        for (uint i; i != 3; ++i) {
            cuspNodes[i].depth = trifoldNode.depth + 1;
            cuspNodes[i].uplink = length;
            cuspNodes[i].nodeType = uint8(ENodeType.Cusp);
            cuspNodes[i].ipfsHash = roles[i];
            _graph.push(cuspNodes[i]);
            ERC721Upgradeable._mint(sender, length + i + 1);

            emit NodeAdded(length + uint64(i) + 1, length, uint8(ENodeType.Cusp), ipfsHash, sender);
        }
    }

    /// @dev fill an array of ancestors at 2^i distances 
    function _fillUplinkExpJumps(uint64 to) internal {
        TNode memory node = _graph[to];
        uint64[64] memory jumps;
        uint256 count;
        uint64 curNodeId = to;
        for(; (1 << count) < node.depth; ++count) {
            uint256 targetDepth = node.depth - (1 << count);
            while(_graph[curNodeId].depth != targetDepth) {
                curNodeId = _graph[curNodeId].uplink;
            }
            jumps[count] = curNodeId;
        }
        uint64[] memory jumpsCut = new uint64[](count);
        for(uint256 i; i != count; ++i) {
            jumpsCut[i] = jumps[i];
        }
        _nodeUplinkExpJumps[to] = jumpsCut;
    }

    /// @dev checks if `to` node descends to `from` node
    function _checkUplink(uint64 from, uint64 to) internal view returns(bool) {
        TNode memory fromNode = _graph[from];
        TNode memory toNode = _graph[to];
        while (fromNode.depth < toNode.depth) {
            if (fromNode.nodeType == uint8(ENodeType.Trifold)) {
                uint256 diff = toNode.depth - fromNode.depth;
                uint256 jumpExp;
                while ((1 << jumpExp) <= diff) {
                    ++jumpExp;
                }
                from = _nodeUplinkExpJumps[from][jumpExp];
            } else {
                from = fromNode.uplink;
            }
            fromNode = _graph[from];
        }
        return from == to;
    }
}
