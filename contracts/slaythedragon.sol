//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol"; 
import "../node_modules/@openzeppelin/contracts/security/Pausable.sol"; 

//things need to check for

contract slaythedragon is ERC1155, Ownable, Pausable
{
    //using Strings for string;

    address private thisContract;
    address private mainContract;
    mapping (address -> player) private _players;

    struct player{
        address player;
        bool awarded;
        uint timeLastPlayed;
    }

     constructor() ERC1155("URI PATH TO BE EDITED"){
        thisContract = address(this);
     }

     function mintReward(address toMint) external
     {
        require(condition);
     }

     function changeMainContractAddy(address newAddy) external onlyOwner
     {
        mainContract = newAddy;
     }

     function checkReward(address player) returns (bool allowed)
     {
        require(_drivers[msg.sender].awarded == false), "Already minted reward";
     }
     function checkLastPlay(address player) returns (bool allowed)
     {

     }
     


}

