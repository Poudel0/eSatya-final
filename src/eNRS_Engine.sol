// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./eNRS.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


/**
 * @author sandman
 * @title eNRS_Engine
 * Stablecoin equivalent to 1$ == 1355.5 NRS
 */

contract eNRS_Engine is ReentrancyGuard{


    error NotEnoughBalance();
    error FailedToMint();
    error NotEnoughTokensToredeem();

    address immutable I_PRICEFEED;
    eNRS immutable I_ENRS;
    constructor(address _priceFeed, address eNRSAddress){
        I_PRICEFEED= _priceFeed;
        I_ENRS= eNRS(eNRSAddress);
    }

    mapping(address => mapping (uint256 => uint256) ) public balances;      //address => eth deposited => tokens minted
    mapping(address=> uint256) public deposited;




    function depositCollateral() payable public returns(bool){
        deposited[msg.sender]+=msg.value;
        return true;
    }

    function mintTokens(uint256 _amount) public returns(bool){
        if (deposited[msg.sender]<_amount)
            revert NotEnoughBalance();
        balances[msg.sender][deposited[msg.sender]]+= _amount;
        bool success = I_ENRS.mint(msg.sender,_amount);
        if(success) {return success;}
            else {
                revert FailedToMint();
            }
    }

    function redeemToken(uint256 _amount) public returns(bool){
        if(balances[msg.sender][deposited[msg.sender]]<_amount){
            revert NotEnoughTokensToredeem();
        }
        balances[msg.sender][deposited[msg.sender]]-=_amount;
        deposited[msg.sender]-= _amount;
        I_ENRS.burn(_amount);
        (bool success,) = msg.sender.call{value:_amount}("");
        require(success,"Redeem Failed");
        return(success);
    }

    function getNRSValue(uint256 _amount) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(I_PRICEFEED);
        (, int256 price,,,) = priceFeed.latestRoundData();
        return ((uint256(price) * 1e10 * 133) * _amount) / 1e18; // Additional Fee Precision * Precision
    }



}