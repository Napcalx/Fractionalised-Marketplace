// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "./Andret.sol";

contract Marketplace {
    Andret _Andret; // The ERC721 NFT contract
    uint256 public feePercent = 10; // 0.1% fee
    struct Listing {
        address seller;
        uint256 tokenId;
        uint256 totalFractions;
        uint256 fractionsAvailable;
        bool active;
    }

    address public admin;
    uint256 public Id;

    Listing[] public listings;
    mapping(uint256 => mapping(address => uint256)) public Fractions; // User's fractional ownership

    event Listed(uint256 Id, address owner, uint256 tokenId, uint256 totalFractions);
    event FractionPurchased(uint256 Id, address buyer, uint256 fractionsPurchased);
    event FractionTransferred(uint256 Id, address from, address to, uint256 fractionsTransferred);

    constructor() {
        admin = msg.sender;
    }

    function list(uint256 _Id, uint256 _totalFractions) external {
        require(_totalFractions > 0, "Total fractions must be greater than 0");
        require(_Andret.ownerOf(_Id) == msg.sender, "Only NFT owner can list");
        _Andret.transferFrom(msg.sender, address(this), _Id);

        Id = listings.length;
        listings.push(Listing({
            seller: msg.sender,
            tokenId: _Id,
            totalFractions: _totalFractions,
            fractionsAvailable: _totalFractions,
            active: false

        }));
        emit Listed(Id, msg.sender, _Id, _totalFractions);
    }

    function purchaseFractions(uint256 _Id, uint256 _fractionsToPurchase) payable external {
        Listing storage listing = listings[_Id];
        require(listing.fractionsAvailable >= _fractionsToPurchase, "Not enough fractions available");
        uint256 cost = (_fractionsToPurchase * listing.totalFractions) / listing.fractionsAvailable;
        uint256 fee = (cost * feePercent) / 10000; // 0.1% fee
    

        listing.seller.call{value: cost + fee}("");
        listing.seller.call{value: fee}("");
        _Andret.transferFrom(address(this), msg.sender, listing.tokenId);
        Fractions[_Id][msg.sender] += _fractionsToPurchase;
        listing.fractionsAvailable -= _fractionsToPurchase;
        emit FractionPurchased(_Id, msg.sender, _fractionsToPurchase);
    }

    function transferFractions(uint256 _Id, address _to, uint256 _fractionsToTransfer) external {
        require(Fractions[_Id][msg.sender] >= _fractionsToTransfer, "Not enough fractions to transfer");
        Fractions[_Id][msg.sender] -= _fractionsToTransfer;
        Fractions[_Id][_to] += _fractionsToTransfer;
        emit FractionTransferred(_Id, msg.sender, _to, _fractionsToTransfer);
    }

    function getListingCount() external view returns (uint256) {
        return listings.length;
    }
}


