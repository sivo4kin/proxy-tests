// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
pragma solidity ^0.8.12;

contract TestExecutor {

    string public writing;



    function execute(string calldata input) public returns (bool){
        writing = input;
        return true;

    }

}

contract ERC1167Factory is Ownable {

    using Clones for address;
    using Address for address;

    address public master;

    event NewClone(address indexed contractAddress);



    constructor(address _master) {
        master = _master;
    }

    function getCounterFactualAddress(bytes32 salt) public view returns (address) {
        require(master != address(0), "master must be set");
        return master.predictDeterministicAddress(salt);
    }

    function createClone(bytes32 salt) public {
        master.cloneDeterministic(salt);
        address qeAddr = getCounterFactualAddress(salt);
        require(Address.isContract(qeAddr), "not deployed yet");
    }


    function createCloneAndExecute(bytes32 salt, bytes memory data) external {
        require(getCounterFactualAddress(salt) != address(0), "address(0)");
        createClone(salt);
        address qeAddress = getCounterFactualAddress(salt);
        require(Address.isContract(qeAddress), "not deployed yet");
        bytes memory result = Address.functionCall(qeAddress, data);
    }

    function isClone(address query) external view returns (bool result) {
        bytes20 targetBytes = bytes20(master);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x363d3d373d3d3d363d7300000000000000000000000000000000000000000000)
            mstore(add(clone, 0xa), targetBytes)
            mstore(add(clone, 0x1e), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

            let other := add(clone, 0x40)
            extcodecopy(query, other, 0, 0x2d)
            result := and(
            eq(mload(clone), mload(other)),
            eq(mload(add(clone, 0xd)), mload(add(other, 0xd)))
            )
        }
    }
}
