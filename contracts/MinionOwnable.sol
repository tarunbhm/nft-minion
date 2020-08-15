pragma solidity ^0.5.0;

import "./interfaces/moloch/IMinion.sol";
import "./interfaces/moloch/IMoloch.sol";

/**
 * @dev Copied from openzeppelin `Ownable` to make minion owner. Also ads support for
 * following
 * - `onlyMinion` -> Minion contract is given permission
 * - `onlyMember` -> Moloch members are given permission
 * - `onlyMinionOrMember` -> Minion or Moloch members are given permission
 */
contract MinionOwnable {
    address private _minion;
    address private _moloch;

    event MinionshipTransferred(address indexed previousMinion, address indexed newMinion);

    /**
     * @dev Initializes the contract setting the deployer as the initial minion.
     */
    constructor (address minionAddress) internal {
        _minion = minionAddress;
        _moloch = IMinion(_minion).moloch();
        emit MinionshipTransferred(address(0), minionAddress);
    }

    /**
     * @dev Returns the address of the current minion.
     */
    function minion() public view returns (address) {
        return _minion;
    }

    /**
     * @dev Returns the address of the current minion parent moloch.
     */
    function moloch() public view returns (address) {
        return _moloch;
    }

    /**
     * @dev Throws if called by any account other than the minion.
     */
    modifier onlyMinion() {
        require(isMinion(), "MinionOwnable: caller is not the minion");
        _;
    }

    /**
     * @dev Returns true if the caller is the current minion.
     */
    function isMinion() public view returns (bool) {
        return msg.sender == _minion;
    }

    /**
     * @dev Throws if called by any account other than the moloch member.
     */
    modifier onlyMember() {
        require(isMember(), "MinionOwnable: caller is not the moloch member");
        _;
    }

    /**
     * @dev Returns true if given address is the current moloch member.
     * Can be used in other contracts to check membership of any address
     */
    function isMember(address memberAddress) public view returns (bool) {
        ( , uint256 memberStakes, , , , ) = IMoloch(_moloch).members(memberAddress);
        return memberStakes > 0;
    }

    /**
     * @dev Returns true if the caller is the current moloch member.
     */
    function isMember() public view returns (bool) {
        return isMember(msg.sender);
    }

    /**
     * @dev Throws if called by any account other than the minion or moloch member.
     */
    modifier onlyMinionOrMember() {
        require(isMinion(), "MinionOwnable: caller is not the moloch member");
        _;
    }

    /**
     * @dev Returns true if the caller is the either current minion or moloch member.
     */
    function isMinionOrMember() public view returns (bool) {
        return isMinion() || isMember();
    }

    /**
     * @dev Leaves the contract without minion. It will not be possible to call
     * `onlyMinion` functions anymore. Can only be called by the current minion.
     *
     * NOTE: Renouncing minionship will leave the contract without an minion,
     * thereby removing any functionality that is only available to the minion.
     */
    function renounceMinionship() public onlyMinion {
        emit MinionshipTransferred(_minion, address(0));
        _minion = address(0);
    }

    /**
     * @dev Transfers minionship of the contract to a new account (`newMinion`).
     * Can only be called by the current minion.
     */
    function transferMinionship(address newMinion) public onlyMinion {
        _transferMinionship(newMinion);
    }

    /**
     * @dev Transfers minionship of the contract to a new account (`newMinion`).
     */
    function _transferMinionship(address newMinion) internal {
        require(newMinion != address(0), "Ownable: new minion is the zero address");
        emit MinionshipTransferred(_minion, newMinion);
        _minion = newMinion;
        _moloch = IMinion(_minion).moloch();
    }
}
