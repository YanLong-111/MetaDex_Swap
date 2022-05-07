// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// @title IDodoMultiSwap
interface IDodoMultiSwap {

    function mixSwap(
        address fromToken,
        address toToken,
        uint256 fromTokenAmount,
        uint256 minReturnAmount,
        address[] calldata mixAdapters,
        address[] calldata mixPairs,
        address[] calldata assetTo,
        uint256 directions,
        bytes[] calldata moreInfos,
        uint256 deadLine
    ) external returns (uint256 returnAmount);
}

// @title IDODOV2Proxy01
interface IDODOV2Proxy01 {

    function dodoSwapV2ETHToToken(
        address toToken,
        uint256 minReturnAmount,
        address[] memory dodoPairs,
        uint256 directions,
        bool isIncentive,
        uint256 deadLine
    ) external payable returns (uint256 returnAmount);

    function dodoSwapV2TokenToETH(
        address fromToken,
        uint256 fromTokenAmount,
        uint256 minReturnAmount,
        address[] memory dodoPairs,
        uint256 directions,
        bool isIncentive,
        uint256 deadLine
    ) external returns (uint256 returnAmount);

    function dodoSwapV2TokenToToken(
        address fromToken,
        address toToken,
        uint256 fromTokenAmount,
        uint256 minReturnAmount,
        address[] memory dodoPairs,
        uint256 directions,
        bool isIncentive,
        uint256 deadLine
    ) external returns (uint256 returnAmount);

    function dodoSwapV1(
        address fromToken,
        address toToken,
        uint256 fromTokenAmount,
        uint256 minReturnAmount,
        address[] memory dodoPairs,
        uint256 directions,
        bool isIncentive,
        uint256 deadLine
    ) external payable returns (uint256 returnAmount);

    function externalSwap(
        address fromToken,
        address toToken,
        address approveTarget,
        address to,
        uint256 fromTokenAmount,
        uint256 minReturnAmount,
        bytes memory callDataConcat,
        bool isIncentive,
        uint256 deadLine
    ) external payable returns (uint256 returnAmount);

    function mixSwap(
        address fromToken,
        address toToken,
        uint256 fromTokenAmount,
        uint256 minReturnAmount,
        address[] memory mixAdapters,
        address[] memory mixPairs,
        address[] memory assetTo,
        uint256 directions,
        bool isIncentive,
        uint256 deadLine
    ) external payable returns (uint256 returnAmount);

}

// @title MetaDexSwap contract
interface MetaDexSwap {
    /*
    * @dev Calculate the fee ratio
    * @param  fromAmount     Amount of a token to sell NOTE：calculated with decimals，For example 1ETH = 10**18
    * @param  projectId      The id of the project that has been cooperated with
    * @return newFromAmount_ From amount after handling fee
    */
    function _getHandlingFee(uint256 fromAmount, string calldata projectId, address fromToken) external returns (uint256, uint256);

    /*
    * @dev Save user data
    * @param  projectId      The id of the project that has been cooperated with
    * @return newFromAmount_ From amount after handling fee
    */
    function _recordData(string calldata projectId, address fromToken, uint256 treasuryBounty) external;
}

// @title dodoSwapInterface
contract dodoSwapInterface is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public _ETH_ADDRESS_;
    MetaDexSwap public metaDexSwapAddr;

    constructor()  {
        _ETH_ADDRESS_ = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    }

    fallback() external payable {}

    receive() external payable {}

    /**
    * @notice Binding external accounting contracts
    * @dev onlyOwner use
    * @param _metaDexSwapAddr External contract address
    */
    function setMetaDexSwapAddr(address _metaDexSwapAddr) public onlyOwner {
        metaDexSwapAddr = MetaDexSwap(_metaDexSwapAddr);
    }

    /**
    * @notice Use IDodoMultiSwap interface mixSwap function
    * @dev  dodo api data return
    * @param projectId Project id
    * @param addressArray 0.addressArray 1.toAddr 2.fromToken 3.toToken
    * ...
    */
    function dodoMixSwapOne(
        string calldata projectId,
        address[] memory addressArray,
        uint256 fromTokenAmount,
        address[] memory mixAdapters,
        address[] memory mixPairs,
        address[] memory assetTo,
        uint256 directions,
        bytes[] memory moreInfos
    ) external payable {

        tokensTransferFrom(addressArray[2], fromTokenAmount, addressArray[0]);

        uint256 fromAmount = _generalBalanceOf(addressArray[2], address(this));

        bytes memory data = abi.encodeWithSelector(
            IDodoMultiSwap.mixSwap.selector,
            addressArray[2],
            addressArray[3],
            fromAmount,
            1,
            mixAdapters,
            mixPairs,
            assetTo,
            directions,
            moreInfos,
            block.timestamp + 60);

        (bool success,) = addressArray[1].call{value : addressArray[2] == _ETH_ADDRESS_ ? fromAmount : 0}(data);
        require(success, "API_SWAP_FAILED");
        refund(projectId, addressArray[3], addressArray[2]);
    }

    /**
    * @notice Use IDODOV2Proxy01 interface mixSwap function
    * @dev  dodo api data return
    * @param projectId Project id
    * @param addressArray 0.approveAddr 1.toAddr 2.fromToken 3.toToken
    * ...
    */
    function dodoMixSwapTwo(
        string calldata projectId,
        address[] memory addressArray,
        uint256 fromTokenAmount,
        address[] memory mixAdapters,
        address[] memory mixPairs,
        address[] memory assetTo,
        uint256 directions,
        bool isIncentive
    ) external payable {

        tokensTransferFrom(addressArray[2], fromTokenAmount, addressArray[0]);

        uint256 fromAmount = _generalBalanceOf(addressArray[2], address(this));

        bytes memory data = abi.encodeWithSelector(
            IDODOV2Proxy01.mixSwap.selector,
            addressArray[2],
            addressArray[3],
            fromAmount,
            1,
            mixAdapters,
            mixPairs,
            assetTo,
            directions,
            isIncentive,
            block.timestamp + 60 );

        (bool success,) = addressArray[1].call{value : addressArray[2] == _ETH_ADDRESS_ ? fromAmount : 0}(data);
        require(success, "API_SWAP_FAILED");

        refund(projectId, addressArray[3], addressArray[2]);

    }

    /**
    * @notice Use IDODOV2Proxy01 interface dodoSwapV2ETHToToken function
    * @dev  dodo api data return
    * @param projectId Project id
    * ...
    */
    function dodoSwapV2ETHToToken(
        string calldata projectId,
        address toAddress,
        address toToken,
        address[] memory dodoPairs,
        uint256 directions,
        bool isIncentive
    ) external payable {

        uint256 fromAmount = _generalBalanceOf(_ETH_ADDRESS_, address(this));

        bytes memory data = abi.encodeWithSelector(
            IDODOV2Proxy01.dodoSwapV2ETHToToken.selector,
            toToken,
            1,
            dodoPairs,
            directions,
            isIncentive,
            block.timestamp + 60);

        (bool success,) = toAddress.call{value : fromAmount}(data);
        require(success, "API_SWAP_FAILED");

        refund(projectId, toToken, _ETH_ADDRESS_);

    }

    /**
    * @notice Use IDODOV2Proxy01 interface dodoSwapV2TokenToToken function
    * @dev dodo api data return
    * @param projectId Project id
    * @param addressArray 0.approveAddr 1.toAddr 2.fromToken 3.toToken
    * ...
    */
    function dodoSwapV2TokenToToken(
        string calldata projectId,
        address[] memory addressArray,
        uint256 fromTokenAmount,
        address[] memory dodoPairs,
        uint256 directions,
        bool isIncentive
    ) external payable {

        tokensTransferFrom(addressArray[2], fromTokenAmount, addressArray[0]);

        uint256 fromAmount = _generalBalanceOf(addressArray[2], address(this));

        bytes memory data = abi.encodeWithSelector(
            IDODOV2Proxy01.dodoSwapV2TokenToToken.selector,
            addressArray[2],
            addressArray[3],
            fromAmount,
            1,
            dodoPairs,
            directions,
            isIncentive,
            block.timestamp + 60);

        (bool success,) = addressArray[1].call{value : addressArray[2] == _ETH_ADDRESS_ ? fromAmount : 0}(data);
        require(success, "API_SWAP_FAILED");

        refund(projectId, addressArray[3], addressArray[2]);

    }

    /**
    * @notice Use IDODOV2Proxy01 interface externalSwap function
    * @dev  dodo api data return
    * @param projectId Project id
    * @param addressArray 0.approveAddr 1.toAddr 2.fromToken 3.toToken
    * ...
    */
    function externalSwap(
        string calldata projectId,
        address[] memory addressArray,
        address approveTarget,
        address to,
        uint256 fromTokenAmount,
        bytes calldata callDataConcat,
        bool isIncentive
    ) external payable {

        tokensTransferFrom(addressArray[2], fromTokenAmount, addressArray[0]);

        uint256 fromAmount = _generalBalanceOf(addressArray[2], address(this));

        bytes memory data = abi.encodeWithSelector(
            IDODOV2Proxy01.externalSwap.selector,
            addressArray[2],
            addressArray[3],
            approveTarget,
            to,
            fromAmount,
            1,
            callDataConcat,
            isIncentive,
            block.timestamp + 60);

        (bool success,) = addressArray[1].call{value : addressArray[2] == _ETH_ADDRESS_ ? fromAmount : 0}(data);
        require(success, "API_SWAP_FAILED");

        refund(projectId, addressArray[3], addressArray[2]);

    }

    /**
    * @notice Use IDODOV2Proxy01 interface dodoSwapV1 function
    * @dev  dodo api data return
    * @param projectId Project id
    * @param addressArray 0.approveAddr 1.toAddr 2.fromToken 3.toToken
    * ...
    */
    function dodoSwapV1(
        string calldata projectId,
        address[] memory addressArray,
        uint256 fromTokenAmount,
        address[] memory dodoPairs,
        uint256 directions,
        bool isIncentive
    ) external payable {

        tokensTransferFrom(addressArray[2], fromTokenAmount, addressArray[0]);

        uint256 fromAmount = _generalBalanceOf(addressArray[2], address(this));

        bytes memory data = abi.encodeWithSelector(
            IDODOV2Proxy01.dodoSwapV1.selector,
            addressArray[2],
            addressArray[3],
            fromAmount,
            1,
            dodoPairs,
            directions,
            isIncentive,
            block.timestamp + 60);

        (bool success,) = addressArray[1].call{value : addressArray[2] == _ETH_ADDRESS_ ? fromAmount : 0}(data);
        require(success, "API_SWAP_FAILED");

        refund(projectId, addressArray[3], addressArray[2]);

    }

    /**
    * @notice Use IDODOV2Proxy01 interface dodoSwapV1 function
    * @dev  dodo api data return
    * @param projectId Project id
    * @param addressArray 0.approveAddr 1.toAddr 2.fromToken 3.toToken
    * ...
    */
    function dodoSwapV2TokenToETH(
        string calldata projectId,
        address[] memory addressArray,
        uint256 fromTokenAmount,
        address[] memory dodoPairs,
        uint256 directions,
        bool isIncentive
    ) external {

        tokensTransferFrom(addressArray[2], fromTokenAmount, addressArray[0]);

        uint256 fromAmount = _generalBalanceOf(addressArray[2], address(this));

        bytes memory data = abi.encodeWithSelector(
            IDODOV2Proxy01.dodoSwapV2TokenToETH.selector,
            addressArray[2],
            fromAmount,
            1,
            dodoPairs,
            directions,
            isIncentive,
            block.timestamp + 60 * 10);

        (bool success,) = addressArray[1].call{value : addressArray[2] == _ETH_ADDRESS_ ? fromAmount : 0}(data);
        require(success, "API_SWAP_FAILED");

        refund(projectId, _ETH_ADDRESS_, addressArray[2]);


    }

    /**
    * @notice Collect user tokens (support ETH or BNB)
    * @param fromToken Receive the user's token address
    * @param fromTokenAmount The amount of tokens charged to the user
    * @param approveAddress "targetApproveAddr" returned by dodo api
    */
    function tokensTransferFrom(
        address fromToken,
        uint256 fromTokenAmount,
        address approveAddress
    ) private {
        if (fromToken != _ETH_ADDRESS_) {
            IERC20(fromToken).safeTransferFrom(_msgSender(), address(this), fromTokenAmount);
            _generalApproveMax(fromToken, approveAddress, fromTokenAmount);
        } else {
            require(fromTokenAmount == msg.value, "MS:f2");
        }
    }

    /*
    * @dev Max Approve of user's sold tokens
    * @param token  Approve token address
    * @param to     Approve address
    * @param amount Number of transactions
    */
    function _generalApproveMax(
        address token,
        address to,
        uint256 amount
    ) internal {
        uint256 allowance = IERC20(token).allowance(address(this), to);
        if (allowance < amount) {
            IERC20(token).safeApprove(to, ~uint256(0));
        }
    }

    /*
    * @dev Send the tokens exchanged by the user to the user
    * @param token  Send token address
    * @param to     Payment address
    * @param amount Amount of tokens sent
    */
    function _generalTransfer(
        address token,
        address to,
        uint256 amount
    ) internal {
        if (amount > 0) {
            if (token == _ETH_ADDRESS_) {
                payable(to).transfer(amount);
            } else {
                IERC20(token).safeTransfer(to, amount);
            }
        }
    }

    /*
    * @dev Query the token balance in an address
    * @param token Query token address
    * @param who   The queried address
    */
    function _generalBalanceOf(
        address token,
        address who
    ) internal view returns (uint256) {
        if (token == _ETH_ADDRESS_) {
            return who.balance;
        } else {
            return IERC20(token).balanceOf(who);
        }
    }

    function refund(
        string calldata projectId,
        address toToken,
        address fromToken
    ) internal {
        //require(_generalBalanceOf(fromToken, address(this)), "MS:f1");
        uint256 fromTokenBalanceOf = _generalBalanceOf(fromToken, address(this));
        if (fromTokenBalanceOf > 0) {
            _generalTransfer(fromToken, _msgSender(), fromTokenBalanceOf);
        } else {
            uint256 returnAmount = _generalBalanceOf(toToken, address(this));
            (uint256 newFromAmount_, uint256 treasuryBounty_) = metaDexSwapAddr._getHandlingFee(returnAmount, projectId, toToken);
            _generalTransfer(toToken, address(metaDexSwapAddr), returnAmount.sub(newFromAmount_));
            _generalTransfer(toToken, _msgSender(), _generalBalanceOf(toToken, address(this)));
            metaDexSwapAddr._recordData(projectId, toToken, treasuryBounty_);
        }
    }

}