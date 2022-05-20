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
        uint256 prevIdx;   // address of the previous version of the ICtoken
        uint8   version;   // version number of the ICtoken
        bool    defective; // whether the IC is defective or not 
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

    struct TokenUpdater {
        uint256 ECID;
        uint256 PID;
        uint256 SID;
        uint256 prevECID;
        Stage stage;
        bool status;
    }

    struct OwnedTokens {
        bool active;
        mapping(uint256 => uint256) tokens;
    }

    struct IDs {
        bool active;
        uint256[] IDs;
    }

    mapping(uint256 => uint256)   ECIDtoIdx;
    mapping(address => OwnedTokens) ownersdb;
    mapping(uint256 => IDs) PCBdb;
    mapping(uint256 => IDs) SYSdb;

    constructor() ERC721('ICtoken NFT', 'ICTOKEN') {
        ICtoken memory icToken;     // genesis token
        ICtokenChain.push(icToken);
        ICtokenID++;
    }

    function enrollOwner() external returns (bool) {
        require (ownersdb[msg.sender].active == false, 'Address already enrolled');
        ownersdb[msg.sender].active = true;
        return true;
    }

    // @shashank: it doesn't look like we are signing transactions rn
    // so this just checks that the current owner of the provided ECID is the provided ownerAddr
    function verifyTransaxn(address ownerAddr, uint256 ECID) external view returns (bool) {
        require (ownersdb[ownerAddr].active == true, 'Owner addr not enrolled');
        return ownersdb[ownerAddr].tokens[ECID] > 0;
    }

    function enrollIC(uint256 ECID) external returns (uint256){
        require (ECIDtoIdx[ECID] == 0, 'ECID already enrolled');
        require(ownersdb[msg.sender].active == true, 'Owner addr not enrolled yet');
        ICtoken memory icToken;
        icToken.metaData.ECID = ECID;
        icToken.metaData.stage = Stage.Fab;
        icToken.metaData.status = false;
        icToken.currOwner.addrss = msg.sender;
        ICtokenChain.push(icToken);
        _safeMint(msg.sender, ICtokenID);
        ECIDtoIdx[ECID] = ICtokenID;
        ownersdb[msg.sender].tokens[ECID] = ICtokenID;
        ICtokenID++;
        return ICtokenID;
    }

    function updateStage(TokenUpdater memory tokenUpdater) external returns (uint256) {
        require(ownersdb[msg.sender].active == true, 'Onwer addr not enrolled');
        ICtoken memory prevToken = ICtokenChain[ECIDtoIdx[tokenUpdater.prevECID]];
        metaData memory prevData = prevToken.metaData;
        require(ownersdb[msg.sender].tokens[prevData.ECID] > 0, 'Cannot update unowned ECID');
        require(tokenUpdater.stage > prevData.stage || tokenUpdater.stage == prevData.stage && tokenUpdater.status == true && prevData.status == false, 'Cannot revert to previous state');
        require(prevData.defective == false, 'Cannot update stage of defective IC');
        ICtoken memory icToken;
        icToken.metaData = prevData;
        icToken.metaData.stage = tokenUpdater.stage;
        icToken.metaData.status = tokenUpdater.status;
        icToken.metaData.prevIdx = ECIDtoIdx[tokenUpdater.prevECID];
        icToken.metaData.version = prevData.version + 1;
        ICtokenChain.push(icToken);
        _safeMint(msg.sender, ICtokenID);
        ECIDtoIdx[icToken.metaData.ECID] = ICtokenID;        
        ICtokenID++;
        return ICtokenID;
    }

    function updatePIDorSID(TokenUpdater[] memory tokenUpdaters) external returns (uint256) {
        require(ownersdb[msg.sender].active == true, 'Onwer addr not enrolled');
        bool samePID = true;
        bool sameSID = true;
        for (uint i = 0; i < tokenUpdaters.length; i++) {
            require(ECIDtoIdx[tokenUpdaters[i].ECID] != 0, 'An ECID not enrolled yet');
            require(ownersdb[msg.sender].tokens[tokenUpdaters[i].ECID] > 0, 'Cannot update unowned ECID');
            require(ICtokenChain[ECIDtoIdx[tokenUpdaters[i].ECID]].metaData.defective == false, 'Cannot update defective IC');
            if (tokenUpdaters[i].PID != tokenUpdaters[0].PID) {
                samePID = false;
            }
            if (tokenUpdaters[i].SID != tokenUpdaters[0].SID) {
                sameSID = false;
            }
        }

        require(samePID || sameSID, 'Invalid array of updating data');

        if (samePID) {
            require(PCBdb[tokenUpdaters[0].PID].active == false, 'PID already exists');
            for (uint i = 0; i < tokenUpdaters.length; i++) {
                require(ICtokenChain[ECIDtoIdx[tokenUpdaters[i].ECID]].metaData.status == false, 'All statuses should be 0');
                require(ICtokenChain[ECIDtoIdx[tokenUpdaters[i].ECID]].metaData.stage == Stage.PCBasm, 'All stages should be PCBasm');
                require(ICtokenChain[ECIDtoIdx[tokenUpdaters[i].ECID]].metaData.SID == 0, 'All chips should not have SID yet');
                require(ICtokenChain[ECIDtoIdx[tokenUpdaters[i].ECID]].metaData.PID == 0, 'All chips should not have PID yet');

            }
        } else if (sameSID) {
            require(SYSdb[tokenUpdaters[0].SID].active == false, 'PID already exists');
            for (uint i = 0; i < tokenUpdaters.length; i++) {
                require(ICtokenChain[ECIDtoIdx[tokenUpdaters[i].ECID]].metaData.status == false, 'All statuses should be 0');
                require(ICtokenChain[ECIDtoIdx[tokenUpdaters[i].ECID]].metaData.stage == Stage.SysInt, 'All stages should be SysInt');
                require(ICtokenChain[ECIDtoIdx[tokenUpdaters[i].ECID]].metaData.PID != 0, 'All chips should have a PID already');
                require(ICtokenChain[ECIDtoIdx[tokenUpdaters[i].ECID]].metaData.SID == 0, 'All chips should not have SID yet');
            }   
        }

        if (samePID) {
            PCBdb[tokenUpdaters[0].PID].active = true;
        } else {
            SYSdb[tokenUpdaters[0].SID].active = true;
        }

        for (uint i = 0; i < tokenUpdaters.length; i++) {
            ICtoken memory icToken = ICtokenChain[ECIDtoIdx[tokenUpdaters[i].ECID]];
            if (samePID) {
                icToken.metaData.PID = tokenUpdaters[0].PID;
                PCBdb[tokenUpdaters[0].PID].IDs.push(ECIDtoIdx[tokenUpdaters[i].ECID]);
            } else {
                icToken.metaData.SID = tokenUpdaters[0].SID;
                SYSdb[tokenUpdaters[0].SID].IDs.push(ECIDtoIdx[tokenUpdaters[i].ECID]);

            }
            icToken.metaData.version += 1;
            icToken.metaData.prevIdx = ECIDtoIdx[icToken.metaData.ECID];
            ECIDtoIdx[icToken.metaData.ECID] = ICtokenID;
            ICtokenChain.push(icToken);
            _safeMint(msg.sender, ICtokenID);
            ICtokenID++;
        }

        return ICtokenID;
    }

    function transferIC(uint256 ECID, address nextOwner) external returns (uint256) {
        require(ownersdb[nextOwner].active == true, 'Next owner addr not enrolled');
        require(ownersdb[msg.sender].active == true, 'Onwer addr not enrolled');
        require(ECIDtoIdx[ECID] != 0, 'ECID must be enrolled');
        require(ownersdb[msg.sender].tokens[ECID] > 0, 'ECID must belong to current owner');
        require(ICtokenChain[ECIDtoIdx[ECID]].metaData.defective == false, 'Cannot update defective IC');
        require(ICtokenChain[ECIDtoIdx[ECID]].metaData.status == true, 'Can only transfer ICs with status 1');
        ICtoken memory icToken = ICtokenChain[ECIDtoIdx[ECID]];
        icToken.currOwner.addrss = nextOwner;
        icToken.metaData.version += 1;
        icToken.metaData.prevIdx = ECIDtoIdx[ECID];
        ECIDtoIdx[ECID] = ICtokenID;
        ICtokenChain.push(icToken);
        ownersdb[msg.sender].tokens[ECID] = 0;
        ownersdb[nextOwner].tokens[ECID] = ICtokenID;
        safeTransferFrom(msg.sender, nextOwner, ICtokenID);
        ICtokenID++;

        return ICtokenID;
    } 

    function refurbishIC(uint256 ECID) external returns (uint256) {
        require(ownersdb[msg.sender].active == true, 'Onwer addr not enrolled');
        require(ECIDtoIdx[ECID] != 0, 'ECID must be enrolled');
        require(ICtokenChain[ECIDtoIdx[ECID]].metaData.defective == false, 'Cannot update defective IC');
        require(ICtokenChain[ECIDtoIdx[ECID]].metaData.stage == Stage.EndUsr && ICtokenChain[ECIDtoIdx[ECID]].metaData.status == true, 'Can only refurbish ICs in 4/1 stage');
        ICtoken memory icToken = ICtokenChain[ECIDtoIdx[ECID]];
        icToken.metaData.version += 1;
        icToken.metaData.stage = Stage.SysInt;
        icToken.metaData.status = false;
        icToken.metaData.prevIdx = ECIDtoIdx[ECID];
        ECIDtoIdx[ECID] = ICtokenID;
        ICtokenChain.push(icToken);
        _safeMint(msg.sender, ICtokenID);
        ICtokenID++;
        return ICtokenID;
    }
}
