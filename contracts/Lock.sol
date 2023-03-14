// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Nextme is ERC721, Pausable, Ownable, ERC721Burnable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    mapping(uint => string) tokenURIStorage;
    mapping(address => string) didStorage;
    string public contractURI;
    bytes32 public root;
    uint public mintPrice;
    string public didHost;

    constructor() ERC721("Nextme", "Nextme") {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint(
        string memory tokenURI_,
        string memory did_
    ) external payable {
        require(msg.value >= mintPrice, "ERR_NOT_ENOUGH_ETH");
        _mint(tokenURI_, did_);
    }

    function whiteMint(
        bytes32[] memory proof,
        string memory tokenURI_,
        string memory did_
    ) external payable {
        require(
            isWhiteLists(proof, keccak256(abi.encodePacked(msg.sender))),
            "ERR_NOT_WHITELIST"
        );
        _mint(tokenURI_, did_);
    }

    function _mint(
        string memory tokenURI_,
        string memory did_
    ) public onlyOwner {
        require(this.balanceOf(msg.sender) == 0, "ERR_HAS_MINTED");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        tokenURIStorage[tokenId] = tokenURI_;
        didStorage[msg.sender] = did_;
    }

    function tokenURI(
        uint tokenID_
    ) public view override returns (string memory) {
        return tokenURIStorage[tokenID_];
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override whenNotPaused {
        require(from != address(0), "ERR_SBT_CANT_NOT_TRANSFER");
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function isWhiteLists(
        bytes32[] memory proof,
        bytes32 leaf
    ) private view returns (bool) {
        return MerkleProof.verify(proof, root, leaf);
    }

    function DID() external view returns (string memory) {
        return string.concat(didHost, ":", didStorage[msg.sender]);
    }

    receive() external payable {}

    /// ========================ONLY OWNER===========================================
    function setContractURI(string memory contractURI_) external onlyOwner {
        contractURI = contractURI_;
    }

    function setRoot(bytes32 root_) external onlyOwner {
        root = root_;
    }

    function setMintPrice(uint mintPrice_) external onlyOwner {
        mintPrice = mintPrice_;
    }

    function setDidHost(string memory host_) external onlyOwner {
        didHost = host_;
    }

    function withdraw(address receiver) external payable onlyOwner {
        payable(receiver).call{value: address(this).balance}("");
    }
}
