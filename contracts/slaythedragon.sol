//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol"; 
import "../node_modules/@openzeppelin/contracts/security/Pausable.sol";
import "../node_modules/@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

//things need to check for 
//1. Function Visibility

//REQUIREMENTS TO BE IMPLEMENTED STILL:
// NON-TRANSFERABLE BADGE
// 1 DAY COOLDOWN - DONE
// Must inherit a custom contract. (and use to remove Transfer function lmao)
//actually no they are internal functions ^ but yes remove transfer function lol 
//Implement burn function (betting this will be wanted in future interation)

/**
* @title SlayTheDragon: a erc 1155 minting contract for rewarding minigames in the Knights who say Nah
* @author Christopher Carl Flattum for Knights Who Say Nah LLC
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

   //uint8 private _nftID = 1;

   mapping (address => player) private _players;

   //player struct, incluiding mapping from NFT to bool to check if already awarded
   struct player{
        //address player;
        mapping(uint => bool) awarded;
        mapping(uint => uint256) timeLastPlayed;
    }

     constructor() ERC1155("URI PATH TO BE EDITED"){
        thisContract = address(this);
     }
      /**
      * @notice Minting Reward Function
      * @param toMint is the address we are minting to
      * @param rewardID is the tokenID of the reward we are minting
      * @param sig is a ECDSA signature that is sent from our front end, being signed by a known wallet.
      * @notice This checks a signature against a _signerAddress, which is set by a setter function
      * @notice This checks they havent minted reward, that the sig is valid, tracks that the award is set, and mints
      * @notice THIS IS NOT MINTING SOULBOUND TOKENS. THIS IS MINTING NORMALLY. MUST CHANGE INHERITANCE TO A NON ERC1155 CONTRACT
      */
   function mintReward(address toMint, uint8 rewardID, bytes calldata sig) public
   {
      //requires that 1. Have not minted before
      require(_players[toMint].awarded[rewardID] == false, "Already minted reward");
      //2. checks that the signature passed was signed by a wallet of our choosing
      require(_signerAddress == keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32",
            bytes32(uint256(uint160(msg.sender))))
        ).recover(sig), "no but nice try though!");

      //change player variables to signify awarded state
      _players[toMint].awarded[rewardID] = true;

      //mints to address, using ID, one NFT, no extra data
      _mint(toMint, rewardID, 1, "");
   }

     
   //This sets the address of the signer that the minting function is checking against; 
   //intended use: clean wallet on server will sign message, which will be checked in the mint function
   //allows for GASLESS approval / whitelisting
   function setSigner(address signerAddress) public onlyOwner
   {
      _signerAddress = signerAddress;
   }

   // function changeReward(uint8 id) public onlyOwner
   // {
   //    _nftID = id;
   // }

    //not actually needed with current design; iteration upon design may require
   function changeMainContractAddy(address newAddy) external onlyOwner
   {
      mainContract = newAddy;
   }

    //getter function that allows us to check whether a player has been rewarded with a certain 
    //reward already. Not sure fully needed but adding for future functionality
   function beenRewarded(address play, uint8 id) public view returns (bool allowed)
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
     //remix estimated this at 7.5 cents
   function attemptPlay(address play, uint8 rewardID) public
   {
      _players[play].timeLastPlayed[rewardID] = block.timestamp;
   }

   //This function is a Getter Function to access the last play time of a specific player on a specific game 
   function playedLast(address play, uint8 rewardID) public view returns(uint lastPlayed)
   {
    return _players[play].timeLastPlayed[rewardID];
   }


   //this function checks if the wallet is ok to try playing - this is checked before they are allowed to try
   //called before the above function attemptPlay which notates into memory they are trying to play
   function checkBeforePlaying(address play, uint8 rewardID) public view returns (bool oktoPlay)
   {
     if(_players[play].awarded[rewardID] == false && ((_players[play].timeLastPlayed[rewardID] + 86400) < block.timestamp))
     {
         return true;
     }
     else
     {
      return false;
     }
   }

   //overriding the transfer function
   //write Nat-spec format for this and below TODO
   function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override onlyOwner {
        require(msg.sender == _signerAddress, "Badges won in fights are non-transferable.");

        _safeTransferFrom(from, to, id, amount, data);
    }

   //overriding the transfer function
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override onlyOwner {
        require(msg.sender == _signerAddress, "Badges won in fights are non-transferable.");

        _safeBatchTransferFrom(from, to, id, amount, data);
    }

   //should this be Public? Will players burn their tokens themselves and mint something new, or?
   //function burnRewards(address player, uint8[] memory ids) external onlyOwner
   {
      //not finished
     // _burnBatch
   }
}

