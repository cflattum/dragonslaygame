//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol"; 

contract slaythedragon is ERC1155, Ownable 
{
    address private thisContract;


     constructor() public ERC1155("URI PATH TO BE EDITED"){
        thisContract = address(this);
     }
     


}

