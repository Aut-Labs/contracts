//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";

contract DAOTrifolds is Context {
    event NodeAdded(uint64 primaryKey, uint64 uplink, uint8 nodeType, bytes32 symbol, address operator);

    enum ENodeType {
        Cusp,
        Trifold
    }

    struct TNode {
        uint64 uplink;
        uint64 depth;
        uint8 nodeType;
        address operator;
        bytes32 symbol;
    }

    modifier initialized {
        require(_initialized);
        _;
    }

    TNode[] internal _graph;
    mapping(uint64 => uint64[]) internal _nodeUplinkExpJumps;

    bool private _initialized;

    function _initializer() internal initialized {
        TNode memory node;
        _graph.push(node);
        _initialized = true;
    }

    function _setOperator(uint64 authorization, uint64 to, address operator) internal initialized {
        require(to < _graph.length);
        require(operator != address(0));
        require(_graph[authorization].operator == _msgSender());
        require(_checkUplink(to, authorization));
        _graph[to].operator = operator;
    }

    function _setSymbol(uint64 authorization, uint64 to, bytes32 symbol) internal initialized {
        require(to < _graph.length);
        require(symbol != bytes32(0));
        require(_graph[authorization].operator == _msgSender());
        require(_checkUplink(to, authorization));
        _graph[to].symbol = symbol;
    }

    function _addTrifold(uint64 to, bytes32 symbol, bytes32[3] calldata roles) internal initialized {
        uint64 length = uint64(_graph.length);
        require(to < length);
        TNode memory toNode = _graph[to];
        require(toNode.nodeType == uint8(ENodeType.Cusp));
        address sender = _msgSender();
        require(_isOperator(to, sender));

        TNode memory trifoldNode;
        TNode[3] memory cuspNodes;
        trifoldNode.depth = toNode.depth + 1;
        trifoldNode.uplink = to;
        trifoldNode.nodeType = uint8(ENodeType.Trifold);
        trifoldNode.operator = sender;
        trifoldNode.symbol = symbol;
        _graph.push(trifoldNode);
        _fillUplinkExpJumps(length);
        emit NodeAdded(length, to, uint8(ENodeType.Trifold), symbol, sender);

        for (uint i; i != 3; ++i) {
            cuspNodes[i].depth = trifoldNode.depth + 1;
            cuspNodes[i].uplink = length;
            cuspNodes[i].nodeType = uint8(ENodeType.Cusp);
            cuspNodes[i].operator = sender;
            cuspNodes[i].symbol = roles[i];
            _graph.push(cuspNodes[i]);
            emit NodeAdded(length + uint64(i) + 1, length, uint8(ENodeType.Cusp), symbol, sender);
        }
    }

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

    // --- slow version

    function _isOperator(uint64 node, address who) internal view returns(bool) {
        uint64 cur = node;
        while (cur != 0) {
            if (who == _graph[cur].operator) {
                return true;
            }
            cur = _graph[cur].uplink;
        }
        return false;
    }

    // ---
}
