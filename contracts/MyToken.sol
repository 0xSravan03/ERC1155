// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MyToken is ERC1155, Ownable, Pausable, ERC1155Supply {
    uint256 public constant s_mintPrice = 0.01 ether;
    uint256 public constant s_maxSupply = 100;

    constructor(string memory URI) ERC1155(URI) {}

    // custom Errors
    error MintPriceError(uint256 mintPrice);
    error SupplyLimitExceeded(uint256 totalSupply);
    error WrongTokenId(uint256 id);

    function setURI(string memory newURI) public onlyOwner {
        _setURI(newURI);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    // Anyone can mint the token
    function mint(uint256 id, uint256 amount) public payable {
        if (msg.value != (s_mintPrice * amount)) {
            revert MintPriceError(msg.value);
        }
        if (id > 2) {
            revert WrongTokenId(id);
        }
        if (totalSupply(id) + amount > s_maxSupply) {
            revert SupplyLimitExceeded(s_maxSupply);
        }
        _mint(msg.sender, id, amount, "");
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyOwner {
        _mintBatch(to, ids, amounts, data);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) whenNotPaused {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    // Overriding URI function to get the right Uri.
    function uri(
        uint256 _id
    ) public view virtual override returns (string memory) {
        require(exists(_id), "Invalid Token Id");
        return
            string(
                abi.encodePacked(super.uri(_id), Strings.toString(_id), ".json")
            );
    }
}
