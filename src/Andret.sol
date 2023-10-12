// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "lib/solmate/src/tokens/ERC721.sol";

contract Andret is ERC721("Tauri", "TNFT") {

    error ERC721Nonexistent();
    error ERC721InvalidReceiver();
    error ERC721IncorrectOwner();
    error ERC721InsufficientApproval();

    // mapping(uint256 tokenId => address) _ownerOf;
    mapping(address owner => uint256) private _balances;

    mapping(uint256 tokenId => address) private _tokenApprovals;
    mapping(address owner => mapping(address operator => bool)) private _operatorApprovals;


    function tokenURI(
        uint256 id
    ) public view virtual override returns(string memory) {
        return "base-marketplace";
    }
    
    function mint(
        address receiver, 
        uint256 tokenId
    ) public payable {
        _mint(receiver, tokenId);
    }

    function _approve(address to, uint256 tokenId, address auth) internal {
        _approve(to, tokenId, auth);
    }

    function _transfer(address from, address to, uint256 tokenId) internal {
        if (to == address(0)) {
            revert ERC721InvalidReceiver();
        }
        address previousOwner = _update(to, tokenId, address(0));
        if (previousOwner == address(0)) {
            revert ERC721Nonexistent();
        } else if (previousOwner != from) {
            revert ERC721IncorrectOwner();
        }
    }

    function transferFrom(address from, address to, uint256 tokenId) public override virtual {
        if (to == address(0)) {
            revert ERC721InvalidReceiver();
        }
        // Setting an "auth" arguments enables the `_isAuthorized` check which verifies that the token exists
        // (from != 0). Therefore, it is not needed to verify that the return value is not 0 here.
        address previousOwner = _update(to, tokenId, _msgSender());
        if (previousOwner != from) {
            revert ERC721IncorrectOwner();
        }
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _update(address to, uint256 tokenId, address auth) internal virtual returns (address) {
        address from = ownerOf(tokenId);

        // Perform (optional) operator check
        if (auth != address(0)) {
            _checkAuthorized(from, auth, tokenId);
        }

        // Execute the update
        if (from != address(0)) {
            // Clear approval. No need to re-authorize or emit the Approval event
            _approve(address(0), tokenId, address(0));

            unchecked {_balances[from] -= 1;}
        }

        if (to != address(0)) {
            unchecked {
                _balances[to] += 1;
            }
        }

        _ownerOf[tokenId] = to;

        emit Transfer(from, to, tokenId);

        return from;
    }

    function _checkAuthorized(address owner, address spender, uint256 tokenId) internal view virtual {
        if (!_isAuthorized(owner, spender, tokenId)) {
            if (owner == address(0)) {
                revert ERC721Nonexistent();
            } else {
                revert ERC721InsufficientApproval();
            }
        }
    }

    function _isAuthorized(address owner, address spender, uint256 tokenId) internal view virtual returns (bool) {
        return
            spender != address(0) &&
            (owner == spender || _getApproved(tokenId) == spender);
    }

    function _getApproved(uint256 tokenId) internal view virtual returns (address) {
        return _tokenApprovals[tokenId];
    }
  

}

