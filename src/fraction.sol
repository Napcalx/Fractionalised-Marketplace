// SPDX-License-Identifier: ISC
pragma solidity ^0.8.0;

// import "./interface/IMFNFT.sol";
// import "./interface/IERC721.sol";
// import "./math/SafeMath.sol";
// import "./helper/Verifier.sol";

// contract MFNFT is IMFNFT, Verifier {

//     mapping(uint256 => mapping(address => uint256)) private _balances;

//     mapping(uint256 => mapping(address => mapping(address => uint256)))
//         private _allowed;

//     // uint256 private _totalSupply;
//     mapping(uint256 => uint256) _totalSupply;

//     // NFT Contract Address
//     // address private _parentToken;
//     mapping(uint256 => address) _parentToken;

//     // NFT ID of NFT(RFT) - TokenId
//     // uint256 private _parentTokenId;
//     mapping(uint256 => uint256) _parentTokenId;

//     //
//     mapping(address => mapping(uint256 => uint256)) private _Ids;

//     // Scalar value to distinguish fractionalized NFT
//     uint256 public _id;

//     // Admin Address to Set the Parent NFT
//     address private _admin;

//     // Event emitted when token is added
//     event TokenAddition(
//         address indexed token,
//         uint256 tokenId,
//         uint256 _id,
//         uint256 totalSupply
//     );

//     constructor() {
//         _admin = msg.sender;
//     }

//     /**
//      * @dev onlyAdmin prohibits function calls arbitrary msg.sender
//      * except _admin
//      */
//     modifier onlyAdmin() {
//         require(msg.sender == _admin);
//         _;
//     }

//     /**
//      * @dev Mandatory function to receive NFT as a contract(CA)
//      * @return Bytes4 which is the selector of this function
//      */
//     function onERC721Received(
//         address _operator,
//         address _from,
//         uint256 _tokenId,
//         bytes calldata _data
//     ) external pure returns (bytes4) {
//         return this.onERC721Received.selector;
//     }

//     /**
//      * @dev (ERC165) Determines if this contract supports Re-FT(ERC1633).
//      * @param interfaceID The bytes4 to query if it matches with the contract interface id.
//      */
//     function supportsInterface(bytes4 interfaceID)
//         external
//         pure
//         returns (bool)
//     {
//         return
//             interfaceID == this.supportsInterface.selector || // ERC165
//             interfaceID == this.parentToken.selector || // parentToken()
//             interfaceID == this.parentTokenId.selector || // parentTokenId()
//             interfaceID ==
//             this.parentToken.selector ^ this.parentTokenId.selector; // RFT
//     }

//     /**
//      * @dev Sets the Address of NFT Contract Address & NFT Token ID
//      * @param parentNFTContractAddress The address NFT Contract address.
//      * @param parentNFTTokenId The token id of NFT.
//      */
//     function setParentNFT(
//         address parentNFTContractAddress,
//         uint256 parentNFTTokenId,
//         uint256 totalSupply
//     ) public onlyAdmin {
//         require(
//             parentNFTContractAddress != address(0),
//             "MFNFT::setParentNFT: Parent NFT Contract should not be zero"
//         );
//         require(
//             getTokenId(parentNFTContractAddress, parentNFTTokenId) == 0,
//             "MFNFT::setParentNFT: Already owned(fractionalized) by this contract"
//         );

//         verifyOwnership(parentNFTContractAddress, parentNFTTokenId);

//         _id++;

//         _Ids[parentNFTContractAddress][parentNFTTokenId] = _id;

//         _parentToken[_id] = parentNFTContractAddress;
//         _parentTokenId[_id] = parentNFTTokenId;

//         _totalSupply[_id] = totalSupply;
//         _balances[_id][msg.sender] = totalSupply;

//         emit TokenAddition(
//             parentNFTContractAddress,
//             parentNFTTokenId,
//             _id,
//             totalSupply
//         );
//     }

//     /**
//      * @dev Returns the tokenId of with the given NFT information
//      * @return An uint256 value representing the tokenId of given NFT
//      */
//     function getTokenId(address token, uint256 tokenId)
//         public
//         view
//         returns (uint256)
//     {
//         return _Ids[token][tokenId];
//     }

//     /**
//      * @dev Returns if the NFT is owned(fractionalized) by this contract.
//      * @return An bool representing whether the NFT is fractionalized by this contract
//      */
//     function isRegistered(address token, uint256 tokenId) public view returns (bool) {
//         return (_Ids[token][tokenId] != 0);
//     }

//     /**
//      * @dev Returns the Address of Parent Token Address
//      * @return An Address representing the address of NFT Contract this Re-FT is pointing to.
//      */
//     function parentToken(uint256 tokenId) external view returns (address) {
//         return _parentToken[tokenId];
//     }

//     function parentTokenId(uint256 tokenId) external view returns (uint256) {
//         return _parentTokenId[tokenId];
//     }

//     function totalSupply(uint256 tokenId)
//         public
//         view
//         override
//         returns (uint256)
//     {
//         return _totalSupply[tokenId];
//     }

//     function balanceOf(address owner, uint256 tokenId)
//         public
//         view
//         override
//         returns (uint256)
//     {
//         return _balances[tokenId][owner];
//     }

//     function allowance(
//         address owner,
//         address spender,
//         uint256 tokenId
//     ) public view override returns (uint256) {
//         return _allowed[tokenId][owner][spender];
//     }

//     function transfer(
//         address to,
//         uint256 tokenId,
//         uint256 value
//     ) public override returns (bool) {
//         _transfer(msg.sender, to, tokenId, value);
//         return true;
//     }

//     function approve(
//         address spender,
//         uint256 tokenId,
//         uint256 value
//     ) public override returns (bool) {
//         require(spender != address(0));

//         _allowed[tokenId][msg.sender][spender] = value;
//         emit Approval(msg.sender, spender, tokenId, value);
//         return true;
//     }

//     function transferFrom(
//         address from,
//         address to,
//         uint256 tokenId,
//         uint256 value
//     ) public override returns (bool) {
//         _allowed[tokenId][from][msg.sender] = _allowed[tokenId][from][
//             msg.sender
//         ].sub(value);
//         _transfer(from, to, tokenId, value);
//         emit Approval(
//             from,
//             msg.sender,
//             tokenId,
//             _allowed[tokenId][from][msg.sender]
//         );
//         return true;
//     }

//     function _transfer(
//         address from,
//         address to,
//         uint256 tokenId,
//         uint256 value
//     ) internal {
//         require(to != address(0));

//         _balances[tokenId][from] = _balances[tokenId][from].sub(value);
//         _balances[tokenId][to] = _balances[tokenId][to].add(value);

//         emit Transfer(from, to, tokenId, value);
//     }
// }
