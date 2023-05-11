// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@account-abstraction/contracts/core/SenderCreator.sol";
//import "@openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./ERC1167Factory.sol";
import "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/utils/Create2.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract ERC1967TestExecutorFactory {
    using Address for address;

    address public implementation;
    address public factory;

    SenderCreator private immutable senderCreator = new SenderCreator();
    constructor(address _implementation, address _factory){
        implementation = _implementation;
        factory = _factory;
    }


    function createTestExecutor(address owner, uint256 salt) public returns (TestExecutor ret) {
        ret = TestExecutor(payable(new ERC1967Proxy{salt : bytes32(salt)}(
                address(implementation),
                abi.encodeCall(TestExecutor.execute, Strings.toHexString(owner))
            )));
    }


    function getAddress(address owner, uint256 salt) public view returns (address) {
        return Create2.computeAddress(bytes32(salt), keccak256(abi.encodePacked(
                type(ERC1967Proxy).creationCode,
                abi.encode(
                    address(implementation),
                    abi.encodeCall(TestExecutor.execute, Strings.toHexString(owner))
                )
            )));
    }


    function createTestExecutorAndExecute(address owner, uint256 salt, bytes calldata data) public returns (TestExecutor ret) {
        createTestExecutor(owner, salt);
        address addr = getAddress(owner, salt);
        require(Address.isContract(addr), "not deployed yet");
        bytes memory result = Address.functionCall(addr, data);
    }


    function createSender(bytes calldata initCode) public {
        address sender1 = senderCreator.createSender(initCode);
        require(sender1 != address(0));
        require(Address.isContract(sender1));
    }

}
