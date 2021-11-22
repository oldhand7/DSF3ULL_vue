// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UserLevel {
	address primeUser;

	mapping(address => address[]) inviterMap;
	mapping(address => address) topAccountMap;

	address[] users;

    struct codeInvitee {
        address invitor;
        string  acode;
        string  pcode;
    }

    mapping(address => codeInvitee[]) codeCreators;

    mapping(string => address) public codeGenerators;
   
    event UserInvited(address sender, address account);
	event UserUnInvited(address sender, address account);
	event saveInviteCode(address sender);

    function saveCode(string memory code) public {
       codeGenerators[code] = msg.sender;
       emit saveInviteCode(msg.sender);
    }
    
    function getCode(string memory code) public view returns (address)  {
        // address invitor;
        //   codeGenerators[code] = msg.sender;
         if (codeGenerators[code] == address(0x0)) return address(0x0);
         else {
               
             return codeGenerators[code];
         }
    } 
    
	function inviteUser( string memory invitedCode ) public {
	    address account;
	    account = msg.sender;
	   // require(isExistUser(msg.sender), "SenderNotExist");
        require(!isExistUser(account), "AccountAlreadyExist");

        users.push(account);
        address invitdUser = codeGenerators[invitedCode];
        inviterMap[invitdUser].push(account);
        topAccountMap[account] = msg.sender;
        
        emit UserInvited(msg.sender, account);
	}

	function unInviteUser( address account ) public {
	    require(isExistUser(msg.sender), "SenderNotExist");
	    require(isExistUser(account), "AccountNotExist");
	    require(topAccountMap[msg.sender] != account, "SenderNotInvitedAccount");
	    require(inviterMap[account].length == 0, "SubInvitedUserExist");

        uint idx = 0; uint i = 0;
        for (i = 0; i < users.length; i++) {
            if (users[i] != account) {
                users[idx] = users[i];
                idx++;
            } else continue;
        }
        users.pop();

        idx = 0;
        for (i = 0; i < inviterMap[msg.sender].length; i++) {
            if (inviterMap[msg.sender][i] != account) {
                inviterMap[msg.sender][idx] = inviterMap[msg.sender][i];
                idx++;
            } else continue;
        }
        inviterMap[msg.sender].pop();

        delete topAccountMap[account];
        
        emit UserUnInvited(msg.sender, account);
	}

	function getTop3Account( address account ) internal view returns(address[] memory) {
        address[] memory top_users = new address[](3);
        top_users[0] = address(0x0);
        top_users[1] = address(0x0);
        top_users[2] = address(0x0);
        
        if (topAccountMap[account] == address(0x0)) return top_users;
	    if (account == primeUser) return top_users;

        top_users[0] = topAccountMap[account];

        if (top_users[0] != primeUser) {
            top_users[1] = topAccountMap[top_users[0]];
            require(isExistUser(top_users[1]), "AccountNotExist");

            if (top_users[1] != primeUser) {
                top_users[2] = topAccountMap[top_users[1]];
                require(isExistUser(top_users[2]), "AccountNotExist");
            }
        }
        
        return top_users;
    }
    
    function _setPrimeUser(address account) internal {
        primeUser = account;
        users.push(primeUser);
    }

	function isExistUser( address account ) internal view returns(bool) {
		for (uint i = 0; i < users.length; i++) {
			if (users[i] == account) {
			    return true;
			}
		}
		return false;
	}
}
