// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Web3BridgeDonation.sol";
import "src/TestToken.sol";

contract ContractTest is Test {

    Web3BridgeDonation web3D;
    TestToken token;
    function setUp() public {
        hoax(0xF775103c8BCB600218B9354F2dE76a7cd96cefc5);
        web3D = new Web3BridgeDonation();
        hoax(0xe75B467b5623Bf0C07cb3C0D585083C383fCD28F);
        token = new TestToken();
    }

    function testCanDepositNativeToken() public {
      bool result = web3D.donateNativeToken{value: 0.08 ether}();
      assertEq(result, true);
    }

    function testOwnerCanWithdrawNativeToken() public {
        hoax(0xF775103c8BCB600218B9354F2dE76a7cd96cefc5);
        bool result = web3D.withdrawNative{value:0.08 ether}();
        assertEq(result, true);
    }

    function testRevertWithdrawNativeTokenIfNotOwner() public {
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        bool result = web3D.withdrawNative{value:0.08 ether}();
        assertEq(result, false);
    }

    function testCanDepositOtherTokens() public{
        vm.startPrank(0xe75B467b5623Bf0C07cb3C0D585083C383fCD28F);
        token.approve(address(web3D), 100000e18);
        bool result =  web3D.donate(address(token), 100e18);
        assertEq(result, true);
    }

    function testOwnerCanWithdrawOtherToken() public {
        vm.startPrank(0xe75B467b5623Bf0C07cb3C0D585083C383fCD28F);
        token.approve(address(web3D), 100000e18);
        web3D.donate(address(token), 100e18);
        vm.stopPrank();
        hoax(0xF775103c8BCB600218B9354F2dE76a7cd96cefc5);
        bool result = web3D.withdraw(address(token), 100e18);
        assertEq(result, true);
        uint bal = token.balanceOf(0xF775103c8BCB600218B9354F2dE76a7cd96cefc5);
        assertEq(bal, 100e18);
    }

    function testRevertWithdrawOtherTokenIfNotOwner() public {
        vm.startPrank(0xe75B467b5623Bf0C07cb3C0D585083C383fCD28F);
        token.approve(address(web3D), 100000e18);
        web3D.donate(address(token), 100e18);
        vm.stopPrank();
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        web3D.withdraw(address(token), 100e18);
    }
}
