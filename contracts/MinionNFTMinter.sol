pragma solidity ^0.5.0;

import "@nomiclabs/buidler/console.sol";
import "./interfaces/erc721/IERC721.sol";
import "./interfaces/moloch/IMinion.sol";
import "./interfaces/moloch/IMoloch.sol";

contract MinionNFTMinter {

    struct Token {
        string mintMethodSignature;
        // Mapping of minion address to owner address who configured this minion
        mapping (address => address) minionOwners;
    }

    // Mapping of token address to Token struct
    mapping (address => Token) tokens;

    event TokenConfigured(address indexed token, address indexed minion);
    event TokenUnlisted(address indexed token, address indexed minion);
    event TokenMinted(address indexed to, address indexed token, address indexed minion);

    modifier onlyOwner(address token, address minion) {
        require(owner(token, minion) == msg.sender);
        _;
    }

    function owner(address token, address minion) public view returns (address) {
        return tokens[token].minionOwners[minion];
    }

    function configureToken(string memory mintMethodSignature, address _token, address _minion) public {
        require(msg.sender == IERC721(_token).owner(), "Please configure Token that you own");
        // TODO call method to grant minting permission to minion
        Token storage token = tokens[_token];

        token.mintMethodSignature = mintMethodSignature;
        token.minionOwners[_minion] = msg.sender;

        emit TokenConfigured(_token, _minion);
    }

    function unlistToken(address _token, address _minion) public onlyOwner(_token, _minion) {
        // TODO call method to revoke minting permission to minion
        Token storage token = tokens[_token];
        delete token.minionOwners[_minion];

        emit TokenUnlisted(_token, _minion);
    }

    function mint(address _token, address to, uint256 tokenId) external returns (bool) {
        // Shoud be called by minion
        Token storage token = tokens[_token];

        // Token can only be minted by Minion or by members (and only for members)
        if (token.minionOwners[msg.sender] != address(0x0)) {
            // If msg.sender is not minion check that the msg.sender and token receiver are members
            address moloch = IMinion(msg.sender).moloch();
            ( , uint256 receiverStakes, , , , ) = IMoloch(moloch).members(to);
            ( , uint256 senderStakes, , , , ) = IMoloch(moloch).members(msg.sender);
            require(senderStakes > 0 && receiverStakes > 0);
        }

        // Mint token
        (bool minted, ) = _token.call(abi.encodeWithSignature(token.mintMethodSignature, to, tokenId));

        return minted;
    }
}