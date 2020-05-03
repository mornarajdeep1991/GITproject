/***********************************************************************************************
* Name              : CampaignUnitTriggerHelper_Test                                                 
* Description       : Test class for CampaignUnitTriggerHelper                                             
* Created Date      : 30/05/2018                                                    
* Created By        : Divya Chary (divya.chary@were4c.com)    
* Jira/Req By       :                                                                                                                                         
* ----------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
* 1.0       Divya       30/05/2018  Created                              
************************************************************************************************/
@isTest
public class CampaignUnitTriggerHelper_Test{
    static testMethod void createCampaignUserTest(){
        //Insert a User
       User oUser = TestUtil.createUser(false);
       oUser.Assignment_Group_Active__c=True;
       insert oUser;
       
       //Create a Location
       Location__c oLoc= TestDataFactory.CreateLocation('U');
       insert oLoc;
       
       //Insert a Property Inventory record
       Property_Inventory__c oInventory= TestDataFactory.CreatePropertyInventory(oLoc.Id);
       insert oInventory;
       
       //Insert a Campaign
       Campaign oCampaign= TestDataFactory.CreateCampaign();
       insert oCampaign;
       
       //Insert a Campaign User
       Campaign_User__c oCampaignUser=TestDataFactory.CreateCampaignUser(oUser.Id,oCampaign.Id);
       insert oCampaignUser;
       
       //Insert a Campaign Unit
       Campaign_Unit__c  oUnit=TestDataFactory.CreateCampaignUnits(oCampaign.Id,oInventory.Id);
       insert oUnit;
       
    }
}