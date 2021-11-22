// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./UserLevel.sol";

contract DwarfSpaceForce is ERC721Enumerable, Ownable, UserLevel {
    using Strings for uint256;

    string public baseTokenURI;
    uint256 public maxSupply = 10000;
    uint256 public reserve = 200;
    uint256 public maxPreSaleMint = 3;
    uint256 public maxPublicSaleMint = 10;
    bool public isPreSaleActive = false;
    bool public isPublicSaleActive = false;
    
    // uint256 public price = 10 ether;
    uint256 public price = 0.1 ether;
    uint256 public rewardFirstLevel = 26;
    uint256 public rewardSecondLevel = 11;
    uint256 public rewardThirdLevel = 4;

    mapping(address => bool) public whitelist;

    uint256 public totalWhitelist;
    
    struct InviteeInfo {
        address invitor;
        address invitee;
        uint inviteeMintCount;
        uint level;
    }

    /**
    * @dev Throws if called by any account is not whitelisted.
    */
    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], 'Sorry, this address is not on the whitelist. Please message us on Discord.');
        _;
    }

    
    constructor() ERC721("Dwarf Space Force", "DSF") {
        //setBaseURI(baseURI);
    }

	
    /**
    Mint reserve dwarf for the company
     */

    function mintReserve(uint256 _mintCount) public onlyOwner {
        uint256 supply = totalSupply();
        uint256 tokenCount = balanceOf(msg.sender);

        require(_mintCount > 0,                          'Dwarf count can not be 0');
        require(tokenCount + _mintCount <= reserve,      'This transaction would exceed reserve supply of dwarf.');
        require(supply + _mintCount <= maxSupply,        'This transaction would exceed max supply of dwarf');

        for (uint256 i = 0; i < _mintCount; i++) {
            if (totalSupply() < maxSupply) {
                _safeMint(msg.sender, supply + i);
            }
        }
    }

    /**
    Add multiple addresses to whitelist
    */
    function multipleAddressesToWhiteList(address[] memory addresses) public onlyOwner {
        for(uint256 i =0; i < addresses.length; i++) {
            singleAddressToWhiteList(addresses[i]);
        }
    }

    /**
    Add single address to whitelist
    */

    function singleAddressToWhiteList(address userAddress) public onlyOwner {
        require(userAddress != address(0), "Address can not be zero");
        whitelist[userAddress] = true;
        totalWhitelist++;
    }

    /**
    Remove multiple addresses from whitelist
     */
    function removeAddressesFromWhiteList(address[] memory addresses) public onlyOwner {
        for(uint i =0; i<addresses.length; i++) {
            removeAddressFromWhiteList(addresses[i]);
        }
    }

    /**
    Remove single address from whitelist
     */
    function removeAddressFromWhiteList(address userAddress) public onlyOwner {
        require(userAddress != address(0), "Address can not be zero");
        whitelist[userAddress] = false;
        totalWhitelist--;
    }

    function preSaleMint(uint256 _mintCount) public payable onlyWhitelisted {
        uint256 supply = totalSupply();
        uint256 tokenCount = balanceOf(msg.sender);

        require(isPreSaleActive,                                'Pre sale is not active');
        require(_mintCount > 0,                                 'Dwarf count can not be 0');
        require(tokenCount + _mintCount <= maxPreSaleMint,      'You have already minted your dwarf');
        require(_mintCount <= maxPreSaleMint,                    string(abi.encodePacked('You can only mint ', maxPreSaleMint.toString(), ' dwarfs in one transaction')));
        require(supply + _mintCount <= maxSupply,                'This transaction would exceed max supply of dwarf');
        require(msg.value >= price * _mintCount,                 'Ether value is too low');

        for (uint256 i = 0; i < _mintCount; i++) {
            if (totalSupply() < maxSupply) {
                _safeMint(msg.sender, supply + i);
            }
        }

        require(payable(owner()).send(msg.value));
    }

    function mint(uint256 _mintCount, string memory invitedCode) public payable {
        uint256 supply = totalSupply();
        address invitor = getCode(invitedCode);
        if (bytes(invitedCode).length != 0 && invitor != address(0x0) && invitor != msg.sender ) {
            price = price * 4/5;
        }
        require(isPublicSaleActive,                   'Public sale is not active');
        require(_mintCount > 0,                       'Dwarf count can not be 0');
        require(_mintCount <= maxPublicSaleMint,      string(abi.encodePacked('You can only mint ', maxPublicSaleMint.toString(), ' dwarfs in one transaction')));
        require(supply + _mintCount <= maxSupply,     'This transaction would exceed max supply of dwarf');
        require(msg.value >= price * _mintCount,      'Ether value is too low');

        for (uint256 i = 0; i < _mintCount; i++) {
            if (totalSupply() < maxSupply) {
                _safeMint(msg.sender, supply + i);
            }
        }
        
        
        // address[] memory topLevelUsers = getTop3Account(msg.sender);
        
        if (invitor == address(0x0) || invitor == msg.sender) {
            require(payable(owner()).send(price * _mintCount));
        } else if (invitor == primeUser) {
            require(payable(primeUser).send(price * rewardFirstLevel * _mintCount / 100));
            require(payable(owner()).send(price * (100 - rewardFirstLevel) * _mintCount / 100));
        } 
        // else if (topLevelUsers[1] == primeUser) {
        //     require(payable(topLevelUsers[0]).send(price * rewardFirstLevel * _mintCount / 100));
        //     require(payable(primeUser).send(price * rewardSecondLevel * _mintCount / 100));
        //     require(payable(owner()).send(price * (100 - rewardFirstLevel - rewardSecondLevel) * _mintCount / 100));
        // } else if (topLevelUsers[2] == primeUser) {
        //     require(payable(topLevelUsers[0]).send(price * rewardFirstLevel * _mintCount / 100));
        //     require(payable(topLevelUsers[1]).send(price * rewardSecondLevel * _mintCount / 100));
        //     require(payable(primeUser).send(price * rewardThirdLevel * _mintCount / 100));
        //     require(payable(owner()).send(price * (100 - rewardFirstLevel - rewardSecondLevel - rewardThirdLevel) * _mintCount / 100));
        // } 
        else {
            require(payable(invitor).send(price * rewardFirstLevel * _mintCount / 100));
            require(payable(owner()).send(price * (100 - rewardFirstLevel) * _mintCount / 100));
            // require(payable(topLevelUsers[1]).send(price * rewardSecondLevel * _mintCount / 100));
            // require(payable(topLevelUsers[2]).send(price * rewardThirdLevel * _mintCount / 100));
           
        }
        
        price = 0.1 ether;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }

    function setPrice(uint256 _price) public onlyOwner {
        price = _price;
    }

    function setMaxPreSale(uint256 _number) public onlyOwner {
        maxPreSaleMint = _number;
    }

    function flipPreSale() public onlyOwner {
        isPublicSaleActive = false;
        isPreSaleActive = !isPreSaleActive;
    }

    function flipPublicSale() public onlyOwner {
        isPreSaleActive = false;
        isPublicSaleActive = !isPublicSaleActive;
    }

    function tokensOfOwner(address owner) public view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(owner);
        uint256[] memory tokenIds = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(owner, i);
        }
        return tokenIds;
    }

    function info(string memory invitedCode) public view returns (uint256, uint256, uint256, bool, bool, address, address) {
        address invitedAddress;
        invitedAddress = getCode(invitedCode);
        return (price, maxPreSaleMint, maxPublicSaleMint, isPreSaleActive, isPublicSaleActive, primeUser, invitedAddress);
    }
    
    function extraInfo() public view returns (address, address[] memory) {
        return (primeUser, users);
    }
    
    function setPrimeUser(address account) public onlyOwner {
        _setPrimeUser(account);
    }
    
    function getInvitors3LevelOfAccount(address inviteeL0) public view returns (InviteeInfo[] memory) {
        uint totalCount = 0;
        for (uint i = 0; i < inviterMap[inviteeL0].length; i++) {
            address inviteeL1 = inviterMap[inviteeL0][i];
            totalCount++;
            
            for (uint j = 0; j < inviterMap[inviteeL1].length; j++) {
                address inviteeL2 = inviterMap[inviteeL1][j];
                totalCount++;
                
                totalCount += inviterMap[inviteeL2].length;
            }
        }

        InviteeInfo[] memory inviteeInfo = new InviteeInfo[](totalCount);
        uint256[] memory tokenIds;
        uint idx = 0;
        
        for (uint i = 0; i < inviterMap[inviteeL0].length; i++) {
            address inviteeL1 = inviterMap[inviteeL0][i];
            InviteeInfo memory infoL1;
            infoL1.invitor = inviteeL0;
            infoL1.invitee = inviteeL1;
            tokenIds = tokensOfOwner(inviteeL1);
            infoL1.inviteeMintCount = tokenIds.length;
            infoL1.level = 1;
            
            inviteeInfo[idx] = infoL1; idx++;
            
            for (uint j = 0; j < inviterMap[inviteeL1].length; j++) {
                address inviteeL2 = inviterMap[inviteeL1][j];
                InviteeInfo memory infoL2;
                infoL2.invitor = inviteeL1;
                infoL2.invitee = inviteeL2;
                tokenIds = tokensOfOwner(inviteeL2);
                infoL2.inviteeMintCount = tokenIds.length;
                infoL2.level = 2;
                
                inviteeInfo[idx] = infoL2; idx++;
                
                for (uint k = 0; k < inviterMap[inviteeL2].length; k++) {
                    address inviteeL3 = inviterMap[inviteeL2][k];
                    InviteeInfo memory infoL3;
                    infoL3.invitor = inviteeL2;
                    infoL3.invitee = inviteeL3;
                    tokenIds = tokensOfOwner(inviteeL3);
                    infoL3.inviteeMintCount = tokenIds.length;
                    infoL3.level = 3;
                    
                    inviteeInfo[idx] = infoL3; idx++;
                }
            }
        }
        
        return inviteeInfo;
    }


    // Withdraw ether from contract
    function withdraw() public onlyOwner {
        require(address(this).balance > 0, "Balance must be positive");
        
        uint256 _balance = address(this).balance;

        payable(owner()).transfer(_balance);
    }
}
