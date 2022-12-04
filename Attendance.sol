// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Payroll is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("Payroll", "PAY") {
                owner = msg.sender;
    }

    address public owner;

    mapping (address => uint256) hourWorked;
    mapping(address => uint256) rates;
    address[] public coders;
    uint256 empCode;
    mapping(uint256 => address) empCodes;

    event Register(address indexed Coder, uint256 Code, uint NFT);

    function registerMe(string memory tokenURI) public {
        // Check if not already registered
        require(_registered(), "Already registered");
        empCode++;
        coders.push(msg.sender);
        empCodes[empCode] = msg.sender;
        
        uint256 newId = _tokenIds.current();
        _mint(msg.sender, newId);
        _setTokenURI(newId, tokenURI);

        _tokenIds.increment();

        emit Register(msg.sender, empCode, newId);
    }

    function _registered() internal view returns(bool){
        for (uint i =0; i<coders.length; i++){
            if(coders[i]==msg.sender){
                return false;
            }
        }
        return true;
    }

    modifier onlyOwner{
        require(msg.sender==owner, "Only owner");
        _;
    }

    event FixRate(uint256 Code, uint Amount);
    function fixRate(uint256 _code, uint256 _rate) external onlyOwner {
        address a = empCodes[_code];
        rates[a] = _rate;
        emit FixRate(_code,_rate);
    }

    function clockHours(uint256 _hours) external {
        hourWorked[msg.sender] += _hours;

    }

    function bulkTransfer() external payable onlyOwner{
        for(uint i=0; i<coders.length; i++){
            uint amount = hourWorked[coders[i]]*rates[coders[i]];
            if(amount!=0){
                hourWorked[coders[i]] =0;
                payable(coders[i]).transfer(amount);
            }
            
        }
    }
    event Fund(uint256 Amount);
    function fundContract () public payable {
        payable(address(this)).transfer(msg.value);
        emit Fund(msg.value);
    }

    receive() external payable {}

}