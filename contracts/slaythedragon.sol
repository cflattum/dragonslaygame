//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol"; 
import "../node_modules/@openzeppelin/contracts/security/Pausable.sol";
import "../node_modules/@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "../node_modules/@openzeppelin/contracts/utils/Strings.sol";


/**
* @title SlayTheDragon: an erc 1155 minting contract for rewarding minigames in the Knights who say Nah
* @author Christopher Carl Flattum for Knights Who Say Nah LLC
* @notice Mapping of player structs holds crucial information
* @notice deployer must set signer with functions in file
* @notice can change URI via default 1155 function for reuse
*/
contract slaythedragon is ERC1155Burnable,Ownable,Pausable
{
   using Strings for string;
   using ECDSA for bytes32;

   address private thisContract;
   address private mainContract;
   bool private transfersAllowed = false;

   address private _signerAddress;

   mapping (address => player) private _players;

   //player struct, incluiding mapping from NFT to bool to check if already awarded
   struct player{
        //address player;
        mapping(uint => bool) awarded;
        // mapping(uint => uint256) timeLastPlayed;
    }

     constructor() ERC1155("QmdHztQaKM4EoKiEQWVu9LzJiznTSnqYnGY7knc4aLVoFU"){
        thisContract = address(this);
     }
      /**
      * @notice Minting Reward Function
      * @param toMint is the address we are minting to
      * @param rewardID is the tokenID of the reward we are minting
      * @param sig is a ECDSA signature that is sent from our front end, being signed by a known wallet.
      * @notice This checks a signature against a _signerAddress, which is set by a setter function
      * @notice This checks they havent minted reward, that the sig is valid, tracks that the award is set, and mints
      */
   function mintReward(address toMint, uint8 rewardID, bytes calldata sig) public whenNotPaused
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
      //not using safemint bc this is an end user function and we are not worried about a contract 
      //not accepting our transfer (:
      _mint(toMint, rewardID, 1, "");
   }

   function ownerMint(address toMint, uint8 rewardID) public onlyOwner
   {
    //ensure we do not give a player two of the same badge
    require(_players[toMint].awarded[rewardID] == false, "Already minted reward");

    //change player variables to signify awarded state
      _players[toMint].awarded[rewardID] = true;

    //mint to player
      _mint(toMint,rewardID,1,"");
   }


   function batchOwnerMint(address[] memory _toMint, uint8 rewardID) public onlyOwner
   {
    //for each address in the calldata, 
    for(uint i = 0; i < _toMint.length; i++)
    {
        //check that each player has not received badge already
        require(_players[_toMint[i]].awarded[rewardID] == false, "Already minted reward");

        //change player variables to signify awarded state
        _players[_toMint[i]].awarded[rewardID] = true;

        //mint to each player
        _mint(_toMint[i],rewardID,1,"");
    }
   }

     
   //This sets the address of the signer that the minting function is checking against; 
   //intended use: clean wallet on server will sign message, which will be checked in the mint function
   //allows for GASLESS approval / whitelisting
   function setSigner(address signerAddress) public onlyOwner
   {
      _signerAddress = signerAddress;
   }

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

   function allowTransfers(bool allow) external onlyOwner
   {
      transfersAllowed = allow;
   }
   
   //this function checks if the wallet is ok to try playing - this is checked before they are allowed to try
   //called before the above function attemptPlay which notates into memory they are trying to play
   function checkBeforePlaying(address play, uint8 rewardID) public view returns (bool oktoPlay)
   {
     if(_players[play].awarded[rewardID] == false)
     {
         return true;
     }
     else
     {
      return false;
     }
   }

   //overriding the transfer function
   //write Nat-spec format for this and below
   function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {

        require(transfersAllowed == true, "Badges won in fights are non-transferable.");

        _safeTransferFrom(from, to, id, amount, data);
    }

   //overriding the transfer function
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory id,
        uint256[] memory amount,
        bytes memory data
    ) public virtual override {
        require(transfersAllowed == true, "Badges won in fights are non-transferable.");

        _safeBatchTransferFrom(from, to, id, amount, data);
    }

    function changeURI(string memory newuri) external onlyOwner {
        _setURI(newuri);
    }

    function uri(uint256 _id) public view override returns (string memory) {
    return Strings.strConcat(
      uri,
      Strings.uint2str(_id),
      ".json"
    );
  }


    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

}