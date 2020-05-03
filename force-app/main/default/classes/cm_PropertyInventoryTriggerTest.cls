/*
  Author : Adeel Ahmad (adeel.ahmad@weare4c.com)
  Description : Test class for cm_PropertyInventoryTrigger
  Date : 04/04/2019
*/
@isTest
public class cm_PropertyInventoryTriggerTest {
    
    public static testMethod void testPITrigger(){
        Id unitRecordTypeId =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        insert objLoc;
        
        Location__c loc2 = TestDataFactory.CreateLocation('U');
        insert loc2;
        
        Location__c loc3 = TestDataFactory.CreateLocation('U');
        insert loc3;
        
        Location__c loc4 = TestDataFactory.CreateLocation('U');
        insert loc4;
        
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonMailingCountry ='United Arab Emirates';
        insert objAccount;
        
        Campaign objCampaign = TestDataFactory.CreateCampaign();
        objCampaign.type='Launch';
        insert objCampaign;
        
        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount.id;
        objOppor.CampaignID = objCampaign.id;
        insert objOppor;
   
        Property_Inventory__c objProINV1 = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV1.recordTypeId =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        objProINV1.Instance__c = 'test';
        objProINV1.Instance__c = 'test';
        objProINV1.Property_Status__c = 'Available';
        objProINV1.Org_ID__c = 127;
        objProINV1.cm_Related_Campaign__c = objCampaign.Id;
        objProINV1.Property_ID__c = '112233';
        objProINV1.Property_Status__c = '';
        insert objProINV1;
        
        objProINV1.Address__c = 'test';
        objProINV1.Unit_Position__c = 'Updated';
        objProINV1.Property_Status__c = 'Blocked';
        objProINV1.Blocked_Reason_Code__c = 'SOLD_CANCELLATION';
        objProINV1.DLD_Reference__c = 'test';
        objProINV1.cm_Related_Campaign__c = objCampaign.Id;
        upsert objProINV1;
        
        Property_Inventory__c blockedProp = TestDataFactory.CreatePropertyInventory(loc2.id);
        blockedProp.recordTypeId =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        blockedProp.Property_Status__c = 'Blocked';
        blockedProp.cm_Related_Campaign__c = objCampaign.Id;
        blockedProp.Parent_Location_Id__c = loc3.Id;
        insert blockedProp;
        
        blockedProp.Property_Status__c = 'Available';
        blockedProp.cm_Related_Campaign__c = objCampaign.Id;
        update blockedProp;
        
        Property_Inventory__c pkg = TestDataFactory.CreatePropertyInventory(loc4.id);
        pkg.recordTypeId =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        pkg.Property_Status__c = '';
        pkg.Instance__c = 'test';
        pkg.cm_Related_Campaign__c = objCampaign.Id;
        insert pkg;
    }
    
    public static testMethod void testPropertyInventortTrigger2(){
        //Insert a User
        User oUser = TestUtil.createUser(false);
        oUser.Assignment_Group_Active__c=True;
        insert oUser;
        
        //Creating campaign
		Campaign objCampaign = TestDataFactory.CreateCampaign(); 
        insert objCampaign;
        
        //Inserting location
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        objLoc.Building__c = 'Emaar';
        insert objLoc;
        
        //Inserting Property
        Property__c property = TestDataFactory.CreateProperty('Emaar');
        insert property;
        
        //inserting property inventory
        Property_Inventory__c objProINV = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV.Org_ID__c = 127;
        objProINV.cm_Related_Campaign__c = objCampaign.id;
        objProINV.Property_Status__c = 'Available';
        objProINV.Property__c = property.Id;
        objProINV.Attribute_Category__c = 'U';
        objProINV.blocked_reason_code__c = null;
        
        insert objProINV;
        
        //Insert a Campaign User
        Campaign_User__c oCampaignUser=TestDataFactory.CreateCampaignUser(oUser.Id,objCampaign.Id);
        insert oCampaignUser;
        
        //Insert a Campaign Unit
        Campaign_Unit__c  oUnit=TestDataFactory.CreateCampaignUnits(objCampaign.Id,objProINV.Id);
        insert oUnit;
    }
}