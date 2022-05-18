//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract ICtokenContract is ERC721, Ownable{

    ICtoken[] ICtokenChain;
    uint256 ICtokenID;

    enum Stage{Fab, PCBasm, SysInt, EndUsr}

    struct metaData{
        uint256 ECID;      // SHA256 hash of Electronic Chip Identifier for the IC       
        uint256 PID;       // Identifier for the  PCB containing the IC                     
        uint256 SID;       // Identifier for the System the PCB is built into
        uint256 netHash;   // SHA256 hash of gate-level netlist for the IC
        Stage   stage;     // production stage of the IC in the supplychain
        bool    status;    // status of the IC in the production stage
        address prevIdx;   // address of the previous version of the ICtoken
        uint8   version;   // version number of the ICtoken
    }

    struct ICkey{          // Implementation of the ICkey object
        uint256[] keyEncr; // I
        uint256   keyHash;
    }

    struct myOwner{        // Owner information of the ICtoken
        address   addrss;  // Address of the owner's Blockchain account
        uint256[] pubKey;  // owner's public key (RSA key sizes are 1024, 2048 or 4096)
    }

    struct ICtoken{
        metaData  metaData;
        ICkey     ICkey;
        myOwner   currOwner;
    }

    mapping(uint256 => uint256)   ECIDtoIdx;
    mapping(address => mapping(uint256 => uint256)) ownersdb;

    constructor() ERC721('ICtoken NFT', 'ICTOKEN') {
        ICtoken memory icToken;     // genesis token
        ICtokenChain.push(icToken);
        ICtokenID++;
    }

    function enrollIC(uint256 ECID) external returns (uint256){
        require (ECIDtoIdx[ECID] == 0, 'ECID already enrolled');
        ICtoken memory icToken;
        icToken.metaData.ECID = ECID;
        icToken.metaData.stage = Stage.Fab;
        icToken.metaData.status = false;
        icToken.currOwner.addrss = msg.sender;
        ICtokenChain.push(icToken);
        _safeMint(msg.sender, ICtokenID);
        ECIDtoIdx[ECID] = ICtokenID;
        ownersdb[msg.sender][ECID] = ICtokenID;
        ICtokenID++;
        return ICtokenID;
    }
}
