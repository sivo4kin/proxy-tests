// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ERC1167Factory.sol";
import "@account-abstraction/contracts/core/EntryPoint.sol";
import "@account-abstraction/contracts/samples/SimpleAccount.sol";
import "@account-abstraction/contracts/samples/SimpleAccountFactory.sol";
import "../src/ERC1967TestExecutorFactory.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract ERC1167FactoryTest is Test {

    ERC1167Factory public simplAccFactory;
    EntryPoint public entryPoint;
    SimpleAccount public simpleAccImpl;
    SimpleAccountFactory public simpleAccountFactory;
    TestExecutor public testExecutorImpl;
    ERC1167Factory public testExecutorFactory;
    ERC1967TestExecutorFactory public erc1967TestExecutorFactory;


    function setUp() public {
        entryPoint = new EntryPoint();
        simpleAccImpl = new SimpleAccount(entryPoint);
        simpleAccountFactory = new SimpleAccountFactory(entryPoint);
        simplAccFactory = new ERC1167Factory(address(simpleAccImpl));
        testExecutorImpl = new TestExecutor();
        testExecutorFactory = new ERC1167Factory(address(testExecutorImpl));
        erc1967TestExecutorFactory = new ERC1967TestExecutorFactory(address(testExecutorImpl), address(simplAccFactory));
    }

    function testWalletDeployment() public {
        uint256[2] memory publicKey = [uint256(0x1), uint256(0x2)];
        bytes32 salt = hex'00';
        console.logBytes32(salt);
        address walletAddr = simplAccFactory.getCounterFactualAddress(salt);
        console.logAddress(walletAddr);
        simplAccFactory.createClone(salt);
        SimpleAccount acc = SimpleAccount(payable(walletAddr));
        assertEq(address(acc), walletAddr);
    }


    function test1167CallWithCallData() public {
        bytes memory callData = abi.encodeWithSelector(TestExecutor.execute.selector, "test-msd");
        bytes memory result = Address.functionCall(address(testExecutorImpl), callData);
        assertEq(testExecutorImpl.writing(), "test-msd");
    }


    function test1167CreateAndExecute() public {
        bytes32 salt = hex'00';
        string memory msg = "TEST_MESSAGE";
        address teAddr = testExecutorFactory.getCounterFactualAddress(salt);
        bytes memory callData = abi.encodeWithSelector(TestExecutor.execute.selector, msg);
        testExecutorFactory.createCloneAndExecute(salt, callData);
        TestExecutor te = TestExecutor(teAddr);
        assertEq(te.writing(), msg);
    }

    function test1967factorytester() public {

        address eoaOwner = makeAddr("eoaOwner");

        bytes memory initCode = abi.encodePacked(address(simpleAccountFactory), abi.encodeWithSelector(simpleAccountFactory.createAccount.selector, eoaOwner, 0));

        erc1967TestExecutorFactory.createSender(initCode);

        address addr = simpleAccountFactory.getAddress(eoaOwner, 0);

        erc1967TestExecutorFactory.createTestExecutor(eoaOwner, 2);

        address cloneAddr = erc1967TestExecutorFactory.getAddress(eoaOwner, 2);

        TestExecutor te = TestExecutor(cloneAddr);

        assertEq(te.writing(), Strings.toHexString(eoaOwner));

    }


    function testCreateAndExecute() public {

        address eoaOwner = makeAddr("eoaOwner");

        string memory msg = "TEST_MESSAGE";

        bytes memory callData = abi.encodeWithSelector(TestExecutor.execute.selector, msg);

        erc1967TestExecutorFactory.createTestExecutorAndExecute(eoaOwner, 3, callData);

        address cloneAddr = erc1967TestExecutorFactory.getAddress(eoaOwner, 3);

        TestExecutor te = TestExecutor(cloneAddr);

        assertEq(te.writing(), "TEST_MESSAGE");

    }

}



