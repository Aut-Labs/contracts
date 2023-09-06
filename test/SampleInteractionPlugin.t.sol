//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {DeploysInit} from "./DeploysInit.t.sol";

import {LocalRep} from "../contracts/plugins/interactions/LocalReputation.sol";
import "../contracts/plugins/interactions/ILocalReputation.sol";
import {SampleInteractionPlugin} from "../contracts/plugins/interactions/SampleInteractionPlugin.sol";

contract TestSampleInteractionPlugin is DeploysInit {
    LocalRep LocalRepAlgo;
    ILocalReputation iLR;
    SampleInteractionPlugin InteractionPlugin;

    uint256 taskPluginId;
    address Admin;

    function setUp() public override {
        super.setUp();

        LocalRepAlgo = new LocalRep();
        vm.label(address(LocalRepAlgo), "LocalRep");

        iLR = ILocalReputation(address(LocalRepAlgo));

        InteractionPlugin = new SampleInteractionPlugin(address(Nova), address(iLR) );
        vm.label(address(InteractionPlugin), "InteractionPlugin");

        vm.prank(A1);
        aID.mint("a Name","urlll",1,4,address(Nova));



        uint256[] memory depmodrek;

        vm.prank(A0);
        uint256 pluginDefinitionID =
            IPR.addPluginDefinition(payable(A1), "owner can spoof metadata", 0, true, depmodrek);

        vm.prank(A0);
        IPR.addPluginToDAO(address(InteractionPlugin), pluginDefinitionID);

        taskPluginId = IPR.tokenIdFromAddress(address(InteractionPlugin));

         Admin = A0;
        assertTrue(Nova.isAdmin(Admin), "expected deployer admin");
    }

    function testUnconfiguredInteraction() public {
        vm.startPrank(A1);
        uint256 number1 = InteractionPlugin.number();
        InteractionPlugin.incrementNumber("");
        uint256 number2 = InteractionPlugin.number();
        InteractionPlugin.incrementNumber("averyrandomstring");
        uint256 number3 = InteractionPlugin.number();
        assertTrue(number1 + number2 == number3, "Not Incremented");

        vm.stopPrank();
    }


    function testSetWeight() public {

            
        bytes[] memory datas = new bytes[](2);
        uint256[] memory points = new uint256[](2);



        datas[0] = abi.encodePacked(InteractionPlugin.incrementNumberPlusOne.selector);
        datas[1] = abi.encodeWithSelector(InteractionPlugin.incrementNumber.selector,"averyrandomstring");
        
        points[0] = 5;
        points[1] = 500;

        vm.expectRevert(LocalRep.OnlyAdmin.selector);
        iLR.setInteractionWeights(address(InteractionPlugin),datas, points);

        vm.prank(Admin);
        iLR.setInteractionWeights(address(InteractionPlugin), datas, points);


        uint256 number1 = InteractionPlugin.number();
        testUnconfiguredInteraction();
        uint256 number2 = InteractionPlugin.number();

        individualState memory IS1 = iLR.getIndividualState(A2, address(Nova));

        vm.prank(A2); 
        InteractionPlugin.incrementNumberPlusOne();

        individualState memory IS2 = iLR.getIndividualState(A2, address(Nova));
        assertTrue(IS2.GC > 0, "has some points");
        assertTrue(IS1.GC < IS2.GC, "no points gained");


        vm.prank(A1);
        InteractionPlugin.incrementNumber("averyrandomstring");
        individualState memory IS3 = iLR.getIndividualState(A1, address(Nova));
        assertTrue(IS3.GC >= 500, "data dependend");




    }

}
