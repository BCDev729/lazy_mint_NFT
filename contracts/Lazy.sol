// SPDX-License-Identifier: MIT
pragma solidity >=0.4.0 <0.9.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";



contract Lazy is  ERC721URIStorage, EIP712 ,AccessControl, Ownable, ERC721Enumerable {

    using ECDSA for bytes32;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint initialPrice = 0.25 ether;

    uint shareOfSale1 = 8300;
    uint shareOfSale2 = 1500;
    uint shareOfSale3 = 200;

    uint shareOfWhitelist1 = 5800;
    uint shareOfWhitelist2 = 4000;
    uint shareOfWhitelist3 = 200;

    // the address all signatures need to verify against
    mapping(address => bool) whiteLists;

    constructor(address payable minter) 
        ERC721("LAZY-MINTED_BOIS", "LAZY") 
        EIP712("LazyNFT-Voucher", "1") {
            _setupRole(MINTER_ROLE, minter);
        }

    address owner1 = 0x90F79bf6EB2c4f870365E785982E1f101E93b906;
    address owner2 = 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65;
    address owner3 = 0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc;

    function _verify(string calldata message, bytes calldata sign) public pure returns (address) {
        bytes32 b = keccak256(abi.encodePacked(message));
        return b.toEthSignedMessageHash().recover(sign);
    }

    function mintToken(string calldata message, bytes calldata sign) public payable{
        address signer =_verify(message, sign);
        require(hasRole(MINTER_ROLE, signer), "Signature invalid or unauthorized");
        require(msg.value == initialPrice, "not enough money");

        uint256 tokenId = _tokenIds.current();
        _tokenIds.increment();
        _mint(signer, tokenId);
        _setTokenURI(tokenId, message);        
        _transfer(signer, msg.sender, tokenId); 
        
        uint shareamount1;
        uint shareamount2;
        uint shareamount3;

        if (whiteLists[msg.sender]) {
            shareamount1 = shareOfWhitelist1;
            shareamount2 = shareOfWhitelist2;
            shareamount3 = shareOfWhitelist3;            
        }else{
            shareamount1 = shareOfSale1;
            shareamount2 = shareOfSale2;
            shareamount3 = shareOfSale3;   
        }
        (bool sent, ) = payable(owner1).call{value: (msg.value * shareamount1/ 10000)}("");
        require(sent, "Failed to send Ether");
        (sent, ) = payable(owner2).call{value: (msg.value * shareamount2/ 10000)}("");
        require(sent, "Failed to send Ether");
        (sent, ) = payable(owner3).call{value: (msg.value * shareamount3/ 10000)}("");
        require(sent, "Failed to send Ether");
    }

    function addWhitelistuser(address user) public onlyOwner{
        whiteLists[user] = true;
    }

    function removeWhitelistuser(address user) public onlyOwner{
        whiteLists[user] = false;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override (AccessControl, ERC721, ERC721Enumerable) returns (bool) {
        return ERC721.supportsInterface(interfaceId) || AccessControl.supportsInterface(interfaceId);
    }

    function _burn(uint256 tokenId) internal virtual override (ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override (ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function tokenURI(uint256 tokenId) public view virtual override (ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }


    // this is the test function; will be deleted after deploy on main net.
    function mint(uint256 tokenId, uint index) public onlyOwner{
        _mint(msg.sender, tokenId);
        string[] memory see = new string[](5);
        see[0] = 'https://gateway.pinata.cloud/ipfs/QmR3NepWfoadroEPKXSW6MDBpnvnYQf5i635xJ71N8N6pj/1.json';
        see[1] = 'https://gateway.pinata.cloud/ipfs/QmR3NepWfoadroEPKXSW6MDBpnvnYQf5i635xJ71N8N6pj/2.json';
        see[2] = 'https://gateway.pinata.cloud/ipfs/QmR3NepWfoadroEPKXSW6MDBpnvnYQf5i635xJ71N8N6pj/3.json';
        see[3] = 'https://gateway.pinata.cloud/ipfs/QmR3NepWfoadroEPKXSW6MDBpnvnYQf5i635xJ71N8N6pj/4.json';
        see[4] = 'https://gateway.pinata.cloud/ipfs/QmR3NepWfoadroEPKXSW6MDBpnvnYQf5i635xJ71N8N6pj/5.json';

        _setTokenURI(tokenId, see[index]); 
    }
        
}