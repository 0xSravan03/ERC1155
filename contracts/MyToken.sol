// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MyToken is ERC1155, Ownable, Pausable, ERC1155Supply {
    uint256 public constant s_mintPrice = 0.01 ether;
    uint256 public constant s_allowlistMintPrice = 0.001 ether;
    uint256 public constant s_maxSupply = 50;
    mapping(address => bool) public allowList;

    enum AllowListStatus {
        CLOSED,
        OPEN
    }

    // Initial public mint status
    bool public publicMintOpen = false;

    AllowListStatus private status;

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

    function openAllowListMint() external onlyOwner {
        status = AllowListStatus.OPEN;
    }

    function closeAllowListMint() external onlyOwner {
        status = AllowListStatus.CLOSED;
    }

    function openPublicMint() external onlyOwner {
        publicMintOpen = true;
    }

    function addAllowList(address _address) external onlyOwner {
        allowList[_address] = true;
    }

    function addBatchAllowList(
        address[] calldata _addresses
    ) external onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            allowList[_addresses[i]] = true;
        }
    }

    function revokeAllowList(address _address) external onlyOwner {
        allowList[_address] = false;
    }

    function revokeBatchAllowList(
        address[] calldata _addresses
    ) external onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            allowList[_addresses[i]] = false;
        }
    }

    // Anyone can mint the token
    function publicMint(uint256 id, uint256 amount) public payable {
        require(
            (status == AllowListStatus.CLOSED) && publicMintOpen,
            "PUBLIC_MINT_NOT_OPENED"
        );
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

    modifier onlyAllowList() {
        require(allowList[msg.sender], "ALLOWLIST_ERROR");
        _;
    }

    function allowListMint(
        uint256 id,
        uint256 amount
    ) public payable onlyAllowList {
        require(status == AllowListStatus.OPEN, "MINT_NOT_OPENED");
        require(
            msg.value == (s_allowlistMintPrice * amount),
            "MINTPRICE_ERROR"
        );

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

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        (bool sent, ) = payable(owner()).call{value: balance}("");
        require(sent, "TRANSFER_FAILED");
    }
}
