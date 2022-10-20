//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol"; 
import "../node_modules/@openzeppelin/contracts/security/Pausable.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "../node_modules/@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

//things need to check for 
//1. Function Visibility

//very modular contract: could be made into a couple different functions instead 

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
   using ECDSA for bytes32;

   address private thisContract;
   address private mainContract;

   address private _signerAddress;

   uint8 private _nftID = 1;

   mapping (address => player) private _players;

   //player struct, incluiding mapping from NFT to bool to check if already awarded
   struct player{
        //address player;
        mapping(uint => bool) awarded;
        uint256 timeLastPlayed;
    }

     constructor() ERC1155("URI PATH TO BE EDITED"){
        thisContract = address(this);
     }

     function mintReward(address toMint, bytes calldata sig) public
     {
        //requires that 1. Have not minted before
        require(_players[toMint].awarded[_nftID] == false, "Already minted reward");
        //2. checks that the signature passed was signed by a wallet of our choosing
        require(_signerAddress == keccak256(
               abi.encodePacked("\x19Ethereum Signed Message:\n32",
               bytes32(uint256(uint160(msg.sender)))
            )
        ).recover(sig), "no but nice try though!");

        //change player variables to signify awarded state
        _players[toMint].awarded[_nftID] = true;

        //mints to address, using ID, one NFT, no extra data
        _mint(toMint, _nftID, 1, "");
     }

     function setSigner(address signerAddress) public onlyOwner
     {
         _signerAddress = signerAddress;
     }

     function changeReward(uint8 id) public onlyOwner
     {
         _nftID = id;
     }

    //not actually needed with current design; iteration upon design may require
     function changeMainContractAddy(address newAddy) external onlyOwner
     {
        mainContract = newAddy;
     }

    //getter function that allows us to check whether a player has been rewarded with a certain 
    //reward already. Not sure fully needed but adding for future functionality
     function beenRewarded(address play, uint id) public view returns (bool allowed)
     {
        if(_players[play].awarded[id] == false)
        {
        return false;
        }
        else
        {
        return true;
        }
     }

     //This transaction is signed by a player as a prerequisite to playing;
     //notates the time they tried to play to prevent them from playing again too soon in the future
     function attemptPlay(address play) public
     {
        _players[play].timeLastPlayed = block.timestamp;
     }

       //this function checks if the wallet is ok to try playing - this is checked before they are allowed to try
       //called before the above function attemptPlay which notates into memory they are trying to play
     function checkBeforePlaying(address play) public view returns (bool oktoPlay)
     {
        if(_players[play].awarded[_nftID] == false && ((_players[play].timeLastPlayed + 172800) < block.timestamp))
        {
            return true;
        }
     }

     function playedLast(address play) public view returns(uint lastPlayed)
     {
      return _players[play].timeLastPlayed;
     }
}

