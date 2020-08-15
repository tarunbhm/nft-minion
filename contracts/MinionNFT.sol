pragma solidity ^0.5.0;

import "@nomiclabs/buidler/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Full.sol";

import "./MinionOwnable.sol";

/**
 * @title Full ERC721 Token
 * @dev This implementation includes all the required and some optional functionality of the ERC721 standard
 * Moreover, it includes approve all functionality using operator terminology.
 * This implementation includes minting permissions to a Minion or Moloch members
 *
 * See https://eips.ethereum.org/EIPS/eip-721
 */
contract MinionNFT is ERC721Full, MinionOwnable {

    constructor(string memory name, string memory symbol, address minionAddress) public ERC721Full(name, symbol) MinionOwnable(minionAddress) {
    }

    /**
     * @dev Function to mint tokens.
     * @param to The address that will receive the minted token.
     * @param tokenId The token id to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address to, uint256 tokenId) public onlyMinionOrMember returns (bool) {
        require(isMember(to), "MinionNFT: to address is not a member of moloch");
        _mint(to, tokenId);
        return true;
    }

    /**
     * @dev Function to mint tokens.
     * @param to The address that will receive the minted tokens.
     * @param tokenId The token id to mint.
     * @param tokenURI The token URI of the minted token.
     * @return A boolean that indicates if the operation was successful.
     */
    function mintWithTokenURI(address to, uint256 tokenId, string memory tokenURI) public onlyMinionOrMember returns (bool) {
        require(isMember(to), "MinionNFT: to address is not a member of moloch");
        _mint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
        return true;
    }

    /**
     * @dev Function to set the token URI for a given token.
     *
     * Reverts if the token ID does not exist.
     *
     * TIP: if all token IDs share a prefix (e.g. if your URIs look like
     * `http://api.myproject.com/token/<id>`), use {setBaseURI} to store
     * it and save gas.
     */
    function setTokenURI(uint256 tokenId, string memory _tokenURI) public {
        _setTokenURI(tokenId, _tokenURI);
    }

    /**
     * @dev Function to set the base URI for all token IDs. It is
     * automatically added as a prefix to the value returned in {tokenURI}.
     */
    function setBaseURI(string memory baseURI) public {
        _setBaseURI(baseURI);
    }
}