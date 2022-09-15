// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../../access/MPCManageable.sol";
import "../../access/AdminPausableControl.sol";

interface IAaveV3Pool {
    function mintUnbacked(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    function backUnbacked(
        address asset,
        uint256 amount,
        uint256 fee
    ) external;
}

interface IApp {
    function anyExecute(bytes calldata _data)
        external
        returns (bool success, bytes memory result);
}

interface IAnycallExecutor {
    function context()
        external
        returns (
            address from,
            uint256 fromChainID,
            uint256 nonce
        );
}

interface IAnycallV6Proxy {
    function executor() external view returns (address);

    function anyCall(
        address _to,
        bytes calldata _data,
        address _fallback,
        uint256 _toChainID,
        uint256 _flags
    ) external payable;
}

abstract contract AnycallClientBase is IApp, AdminPausableControl {
    address public callProxy;
    address public executor;
    mapping(uint256 => address) public clientPeers; // key is chainId

    modifier onlyExecutor() {
        require(msg.sender == executor, "AnycallClient: onlyExecutor");
        _;
    }

    constructor(address _admin, address _callProxy)
        AdminPausableControl(_admin)
    {
        require(_callProxy != address(0));
        callProxy = _callProxy;
        executor = IAnycallV6Proxy(callProxy).executor();
    }

    receive() external payable {
        require(
            msg.sender == callProxy,
            "AnycallClient: receive from forbidden sender"
        );
    }

    function setCallProxy(address _callProxy) external onlyAdmin {
        require(_callProxy != address(0));
        callProxy = _callProxy;
        executor = IAnycallV6Proxy(callProxy).executor();
    }

    function setClientPeers(
        uint256[] calldata _chainIds,
        address[] calldata _peers
    ) external onlyAdmin {
        require(_chainIds.length == _peers.length);
        for (uint256 i = 0; i < _chainIds.length; i++) {
            clientPeers[_chainIds[i]] = _peers[i];
        }
    }
}

contract AaveV3PoolAnycallClient is AnycallClientBase, MPCManageable {
    using SafeERC20 for IERC20;

    // pausable control roles
    bytes32 public constant PAUSE_CALLOUT_ROLE =
        keccak256("PAUSE_CALLOUT_ROLE");
    bytes32 public constant PAUSE_CALLIN_ROLE = keccak256("PAUSE_CALLIN_ROLE");
    bytes32 public constant PAUSE_FALLBACK_ROLE =
        keccak256("PAUSE_FALLBACK_ROLE");
    bytes32 public constant PAUSE_BACK_ROLE = keccak256("PAUSE_BACK_ROLE");

    address public aaveV3Pool;
    uint16 public referralCode;

    mapping(address => mapping(uint256 => address)) public tokenPeers;

    event LogCallout(
        address indexed token,
        address indexed sender,
        address indexed receiver,
        uint256 amount,
        uint256 toChainId
    );
    event LogCallin(
        address indexed token,
        address indexed sender,
        address indexed receiver,
        uint256 amount,
        uint256 fromChainId
    );
    event LogCalloutFail(
        address indexed token,
        address indexed sender,
        address indexed receiver,
        uint256 amount,
        uint256 toChainId
    );

    constructor(
        address _admin,
        address _mpc,
        address _callProxy,
        address _aaveV3Pool
    ) AnycallClientBase(_admin, _callProxy) MPCManageable(_mpc) {
        require(_aaveV3Pool != address(0));
        aaveV3Pool = _aaveV3Pool;
    }

    function setAavePool(address _aaveV3Pool) external onlyAdmin {
        require(_aaveV3Pool != address(0));
        aaveV3Pool = _aaveV3Pool;
    }

    function setReferralCode(uint16 _referralCode) external onlyAdmin {
        referralCode = _referralCode;
    }

    function setTokenPeers(
        address srcToken,
        uint256[] calldata chainIds,
        address[] calldata dstTokens
    ) external onlyAdmin {
        require(chainIds.length == dstTokens.length);
        for (uint256 i = 0; i < chainIds.length; i++) {
            tokenPeers[srcToken][chainIds[i]] = dstTokens[i];
        }
    }

    function backUnbacked(
        address asset,
        uint256 amount,
        uint256 fee
    ) external onlyMPC whenNotPaused(PAUSE_BACK_ROLE) {
        IAaveV3Pool(aaveV3Pool).backUnbacked(asset, amount, fee);
    }

    function callout(
        address token,
        uint256 amount,
        address receiver,
        uint256 toChainId,
        uint256 flags
    ) external payable whenNotPaused(PAUSE_CALLOUT_ROLE) {
        address clientPeer = clientPeers[toChainId];
        require(clientPeer != address(0), "AnycallClient: no dest client");

        address dstToken = tokenPeers[token][toChainId];
        require(dstToken != address(0), "AnycallClient: no dest token");

        uint256 oldCoinBalance;
        if (msg.value > 0) {
            oldCoinBalance = address(this).balance - msg.value;
        }

        uint256 old_balance = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        uint256 new_balance = IERC20(token).balanceOf(address(this));
        require(
            new_balance >= old_balance && new_balance <= old_balance + amount
        );
        // update amount to real balance increasement (some token may deduct fees)
        amount = new_balance - old_balance;

        bytes memory data = abi.encodeWithSelector(
            this.anyExecute.selector,
            token,
            dstToken,
            amount,
            msg.sender,
            receiver,
            toChainId
        );
        IAnycallV6Proxy(callProxy).anyCall{value: msg.value}(
            clientPeer,
            data,
            address(this),
            toChainId,
            flags
        );

        if (msg.value > 0) {
            uint256 newCoinBalance = address(this).balance;
            if (newCoinBalance > oldCoinBalance) {
                // return remaining fees
                (bool success, ) = msg.sender.call{
                    value: newCoinBalance - oldCoinBalance
                }("");
                require(success);
            }
        }

        emit LogCallout(token, msg.sender, receiver, amount, toChainId);
    }

    function anyExecute(bytes calldata data)
        external
        override
        onlyExecutor
        whenNotPaused(PAUSE_CALLIN_ROLE)
        returns (bool success, bytes memory result)
    {
        bytes4 selector = bytes4(data[:4]);
        if (selector == this.anyExecute.selector) {
            (
                address srcToken,
                address dstToken,
                uint256 amount,
                address sender,
                address receiver,

            ) = abi.decode(
                    data[4:],
                    (address, address, uint256, address, address, uint256)
                );

            (address from, uint256 fromChainId, ) = IAnycallExecutor(executor)
                .context();
            require(
                clientPeers[fromChainId] == from,
                "AnycallClient: wrong context"
            );
            require(
                tokenPeers[dstToken][fromChainId] == srcToken,
                "AnycallClient: mismatch source token"
            );

            if (IERC20(dstToken).balanceOf(address(this)) >= amount) {
                IERC20(dstToken).safeTransferFrom(
                    address(this),
                    receiver,
                    amount
                );
            } else {
                IAaveV3Pool(aaveV3Pool).mintUnbacked(
                    dstToken,
                    amount,
                    receiver,
                    referralCode
                );
            }

            emit LogCallin(dstToken, sender, receiver, amount, fromChainId);
        } else if (selector == 0xa35fe8bf) {
            // bytes4(keccak256('anyFallback(address,bytes)'))
            (address _to, bytes memory _data) = abi.decode(
                data[4:],
                (address, bytes)
            );
            anyFallback(_to, _data);
        } else {
            return (false, "unknown selector");
        }
        return (true, "");
    }

    function anyFallback(address to, bytes memory data)
        internal
        whenNotPaused(PAUSE_FALLBACK_ROLE)
    {
        (address _from, , ) = IAnycallExecutor(executor).context();
        require(_from == address(this), "AnycallClient: wrong context");

        (
            bytes4 selector,
            address srcToken,
            address dstToken,
            uint256 amount,
            address from,
            address receiver,
            uint256 toChainId
        ) = abi.decode(
                data,
                (bytes4, address, address, uint256, address, address, uint256)
            );

        require(
            selector == this.anyExecute.selector,
            "AnycallClient: wrong fallback data"
        );
        require(
            clientPeers[toChainId] == to,
            "AnycallClient: mismatch dest client"
        );
        require(
            tokenPeers[srcToken][toChainId] == dstToken,
            "AnycallClient: mismatch dest token"
        );

        if (IERC20(srcToken).balanceOf(address(this)) >= amount) {
            IERC20(srcToken).safeTransferFrom(address(this), from, amount);
        } else {
            IAaveV3Pool(aaveV3Pool).mintUnbacked(
                srcToken,
                amount,
                from,
                referralCode
            );
        }

        emit LogCalloutFail(srcToken, from, receiver, amount, toChainId);
    }
}
