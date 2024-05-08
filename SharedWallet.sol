// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SharedWallet {
    address private _owner;

    mapping(address => bool) private _owners;

    modifier isOwner() {
        require(msg.sender == _owner, "Not contract owner");
        _;
    }

    modifier validOwner() {
      require(msg.sender == _owner || _owners[msg.sender], "Not contract owner or owners of shared wallet");
      _;
    }


    event DepositFunds(address from, uint256 amount);
    event WithdrawFunds(address from, uint256 amount);
    event TransferFunds(address from, address to, uint256 amount);

    constructor() {
      _owner = msg.sender;
    }

    function addOwner(address owner) public isOwner {
      _owners[owner] = true;
    }

    function removeOwner(address owner) public isOwner {
      _owners[owner] = false;
    }

    receive() external payable {
      emit DepositFunds(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public validOwner {
      require(address(this).balance >= amount);
      payable(msg.sender).transfer(amount);
      emit WithdrawFunds(msg.sender, amount);
    }

    function transferTo(address payable to, uint256 amount) public validOwner {
      require(address(this).balance >= amount);
      payable(to).transfer(amount);
      emit TransferFunds(msg.sender, to, amount);
    }
}
