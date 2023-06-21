pragma solidity ^0.5.1;

import "./safemath.sol";

contract SupportLab5{
    event noteregistered(uint32 id, string Title, string who);
    event chemregistered(uint32 id, string ChemName, uint32 zanryo);
    event calculated(uint32 id, string ChemName, uint32 zanryo);
    event renewed(uint32 id, string ChemName, uint32 zanryo);
    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;
    uint32 constant Deleted = 4294967295;
    address public owner;

    struct Note{
                    uint32 NoID;
                    uint32 date;
                    string Title_who;
                    string pass;
                    string MokutekiAndMethodAndResult;
                    string UseChem;
    }

    struct Chemical{
                    uint32 ChemID;
                    uint32 date;
                    string ChemName;
                    uint32 used;
                    uint32 zanryo;
                    uint32 lastdate;
                    string place;
                    string who;
    }

    Note[] private notes;
    Chemical[] private chemicals;
    mapping (uint32 => address) private chemToOwner;
    mapping (address => uint32[]) private ownerchems;
    mapping (uint32 => address) private noteToOwner;
    mapping (address => uint32[]) private ownernotes;
    
    modifier onlyOwner() {
                require(msg.sender == owner);
                _;
        }
    
    modifier onlyOwnerOfNote(uint32 _NoID) {
                require(msg.sender == noteToOwner[_NoID]);
                _;
        }
    
    modifier onlyOwnerOfChem(uint32 _ChemID) {
                require(msg.sender == chemToOwner[_ChemID]);
                _;
        }
    
    modifier notDeletedNote(uint32 _NoID) {
                require(uint32(notes[_NoID].NoID) != Deleted);
                _;
        }
        
    modifier notDeletedChem(uint32 _ChemID) {
                require(uint32(chemicals[_ChemID].ChemID) != Deleted);
                _;
        }
        
    constructor() public {
                owner = msg.sender;
        }
    
    
    function NoteRegister(uint32 _NoID, uint32 _date, string calldata _Title_who, string calldata _pass, string calldata _MokutekiAndMethodAndResult, string calldata _UseChem ) external onlyOwner {
            uint32 id = uint32(notes.push(Note(_NoID, _date, _Title_who, _pass, _MokutekiAndMethodAndResult, _UseChem))) - 1;
            noteToOwner[id] = msg.sender;
            ownernotes[msg.sender].push(id);
            emit noteregistered(id, _Title_who, _pass);
    }
    

    function ChemRegister(uint32 _ChemID, uint32 _date, string calldata _ChemName, uint32 _used, uint32 _zanryo, uint32 _lastdate, string calldata _place, string calldata _who) external onlyOwner {
            uint32 id = uint32(chemicals.push(Chemical(_ChemID, _date, _ChemName, _used, _zanryo, _lastdate, _place, _who))) - 1;
            chemToOwner[id] = msg.sender;
            ownerchems[msg.sender].push(id);
            emit chemregistered(id, _ChemName, _zanryo);
    }

    
    function calc(uint32 _ChemID, string calldata _ChemName, uint32 _used, uint32 _zanryo, uint32 _lastdate, string calldata _place, string calldata _who ) external notDeletedChem(_ChemID) onlyOwnerOfChem(_ChemID) {
            Chemical storage myChem = chemicals[_ChemID];
            if(keccak256(abi.encodePacked(chemicals[_ChemID].ChemName)) == keccak256(abi.encodePacked(_ChemName))) {
                uint32 karizanryo = chemicals[_ChemID].zanryo - _used;
                if(_zanryo == karizanryo) {
                    myChem.used = _used;
                    myChem.zanryo = _zanryo;
                    myChem.lastdate = _lastdate;
                    myChem.place = _place;
                    myChem.who = _who;
                    emit calculated(_ChemID, _ChemName, _zanryo);
                }
                else {
                }
            }
            else {
            }
            
    }
    
    
    function renew(uint32 _ChemID, uint32 _renewdate, string calldata _ChemName, uint32 _zanryo, uint32 _newzanryo, string calldata _place, string calldata _who ) external notDeletedChem(_ChemID) onlyOwnerOfChem(_ChemID) {
            Chemical storage myChem = chemicals[_ChemID];
            if(keccak256(abi.encodePacked(chemicals[_ChemID].ChemName)) == keccak256(abi.encodePacked(_ChemName))) {
                if(chemicals[_ChemID].zanryo == _zanryo) {
                    uint32 karizanryo = chemicals[_ChemID].zanryo + _newzanryo;
                    myChem.zanryo = karizanryo;
                    myChem.lastdate = _renewdate;
                    myChem.place = _place;
                    myChem.who = _who;
                    emit renewed(_ChemID, _ChemName, _zanryo);
                }
                else {
                }
            }
            else {
            }
    }
    
    
    
    function getNotesCount() external view returns (uint32) {
        return uint32(notes.length);
    }
    

    function getChemicalsCount() external view returns (uint32) {  
            return uint32(chemicals.length);
    }

    
    function getMyNotesInfo(uint32 _NoID) external notDeletedNote(_NoID) view returns (uint32, uint32, string memory, string memory ) {
            return (notes[_NoID].NoID, notes[_NoID].date, notes[_NoID].Title_who, notes[_NoID].UseChem );
    }
    

    function getMyNotes(uint32 _NoID, string calldata _pass) external notDeletedNote(_NoID) view returns (uint32, uint32, string memory, string memory, string memory ) {
            if(keccak256(abi.encodePacked(notes[_NoID].pass)) == keccak256(abi.encodePacked(_pass))) {
                return (notes[_NoID].NoID, notes[_NoID].date, notes[_NoID].Title_who, notes[_NoID].MokutekiAndMethodAndResult, notes[_NoID].UseChem );
            }
            else {
            }
    }
    
    
    function getMyChemicalInfo(uint32 _ChemID) external notDeletedChem(_ChemID) view returns (uint32, uint32, string memory, uint32, uint32, string memory) {
            return (chemicals[_ChemID].ChemID, chemicals[_ChemID].date, chemicals[_ChemID].ChemName, chemicals[_ChemID].zanryo, chemicals[_ChemID].lastdate, chemicals[_ChemID].place);
    }

    
    function getMyChemicalUsed(uint32 _ChemID) external notDeletedChem(_ChemID) view returns (uint32, string memory, uint32, uint32, uint32, string memory, string memory) {
            return (chemicals[_ChemID].ChemID, chemicals[_ChemID].ChemName, chemicals[_ChemID].used, chemicals[_ChemID].zanryo, chemicals[_ChemID].lastdate, chemicals[_ChemID].place, chemicals[_ChemID].who);
    }
}
