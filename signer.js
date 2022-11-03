

const fs = require('fs');

const Web3 = require('web3');
const web3 = new Web3(Web3.givenProvider);

address = "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2";

const signer = web3.eth.accounts.privateKeyToAccount(
    process.env.SIGNER_PKEY
);

let message = `0x000000000000000000000000${address.substring(2)}`;
    console.log(`Signing ${address} :: ${message}`);

    // Sign the message, update the `signedMessages` dict
    // storing only the `signature` value returned from .sign()
    let { signature } = signer.sign(message);
    
    
    console.log(signature);

    