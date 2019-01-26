pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Platform.sol";
import "../contracts/Company.sol";
import "../contracts/Token.sol";

contract TestPlatform {
    // Global variables
    Platform kmp;
    Company bc;
    Token token;

    // Global constants
    address constant SOME_ADDRESS = 0xdA35deE8EDDeAA556e4c26268463e26FB91ff74f;
    uint256 constant TOTAL_SUPPLY = 1000;

    function beforeAll() public {
        kmp = Platform(DeployedAddresses.Platform());
        bc = kmp.createCompany(
            "Global Company Name",
            "123456789",
            "www.google.com",
            "did:eth:0x2f3fcf4c3",
            SOME_ADDRESS
        );
        token = kmp.createTokenForCompany(
            address(bc),
            "Tokenzito",
            "TKZT",
            TOTAL_SUPPLY
        );
    }

    function testCreateCompany() public {
        string memory companyName = "Some  Name";
        Company newBc = kmp.createCompany(
            companyName,
            "123456789",
            "www.google.com",
            "did:eth:0x2f3fcf4c3",
            SOME_ADDRESS
        );
        Assert.equal(newBc.name(), companyName, "Company name is incorrect.");

    }

    function testCreateToken() public {
        Token aToken = kmp.createTokenForCompany(
            address(bc),
            "AnotherToken",
            "ATK",
            TOTAL_SUPPLY
        );
        Assert.notEqual(
            address(aToken),
            address(token),
            "New token should have been created."
        );
        Assert.equal(
            aToken.totalSupply(),
            TOTAL_SUPPLY,
            "Total supply is incorrect"
        );
    }

    function testGetUserTokenBalance() public {
        uint256 userBalance = kmp.getUserTokenBalance(
            address(bc),
            address(token),
            address(this)
        );
        Assert.equal(
            userBalance,
            TOTAL_SUPPLY,
            "User token balance incorrect"
        );
    }

    function testGetUserTokenZeroBalance() public {
        uint256 userBalance = kmp.getUserTokenBalance(
            address(bc),
            address(token),
            SOME_ADDRESS
        );
        Assert.equal(userBalance, 0, "User token balance incorrect");
    }

    function testTokenInCompany() public {
        bool result = kmp.tokenInCompany(address(bc), address(token));
        Assert.isTrue(result, "Token not found.");
        address nonExistentToken = 0xFC18Cbc391dE84dbd87dB83B20935D3e89F5dd91;
        result = kmp.tokenInCompany(address(bc), address(nonExistentToken));
        Assert.isFalse(result, "Non-Existent Token was found, but shouldn't.");
    }

    function testFindCompanyOwner() public {
        address owner = kmp.findCompanyOwnerUtil(address(bc));
        Assert.equal(owner, bc.owner(), "Company owner found not correct.");
    }

    function testFindCompanyOwnerNotFound() public {
        address owner = kmp.findCompanyOwnerUtil(address(SOME_ADDRESS));
        Assert.equal(owner, address(0), "We found an owner and we shouldn't.");
    }

}