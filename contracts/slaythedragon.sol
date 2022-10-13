//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol"; 
import "../node_modules/@openzeppelin/contracts/security/Pausable.sol"; 

//things need to check for
/**
* @title SlayTheDragon: a erc 1155 minting contract for rewarding minigames in the Knights who say Nah
* @author Christopher Carl Flattum
* @notice Mapping of player structs holds crucial information
* @notice deployer must set main contract address with functions in file
* @notice can change URI via default 1155 function for reuse
*/
contract slaythedragon is ERC1155, Ownable, Pausable
{
    //using Strings for string;

    address private thisContract;
    address private mainContract;

    mapping (address => player) private _players;

    struct player{
        //address player;
        bool awarded;
        uint256 timeLastPlayed;
        bool approved;
    }

     constructor() ERC1155("URI PATH TO BE EDITED"){
        thisContract = address(this);
     }

     function mintReward(address toMint) external onlyOwner
     {
        //requires that 1. Have not minted before
        require(_players[toMint].awarded == false, "Already minted reward");
        //2. have won game / are approved to mint
        require( _players[toMint].approved == true, "Must win game to be able to mint");

        //change player variables to signify awarded state
        _players[toMint].awarded = true;
        //change player variable to remove their approval 
        //this is done as for future integration sake; could be better as an array of bools signifying the first, second, etc
        _players[toMint].approved = false;

        //UNFINISHED.. what ID?
        _mint(toMint, id, 1, 0);
     }

     function changeMainContractAddy(address newAddy) external onlyOwner
     {
        mainContract = newAddy;
     }

    //returns true if has been awarded already, false if not 
     function beenRewarded(address play) public view returns (bool allowed)
     {
        if(_players[play].awarded == false)
        {
        return false;
        }
        else
        {
        return true;
        }
     }

     //returns true if have not played in two days
     function checkLastPlay(address play) public view returns (bool allowed)
     {
        //if time last played + 2 days is before now, 
        if((_players[play].timeLastPlayed + 86400) < block.timestamp)
        {
            return true;
        }
        else
        {
            return false;
        }
     }

    //internal (?) function that puts on a 'whitelist' to allow minting
     function addWhitelist(address play) public onlyOwner 
     {
        //set whitelist variable to true for a certain address play
        //called by the website when the player wins the game
        _players[play].approved = true;
     }
     
     //function that is called during/after playing - signaling the win/loss, and adding timestamps
     function receivePlay(address play, bool result) external onlyOwner
     {
        //when player plays, the website calls this function to add results
        _players[play].timeLastPlayed = block.timestamp;

        //if we won, add to whitelist
        if(result == true)
        {
            addWhitelist(play);
        }
     }


}

