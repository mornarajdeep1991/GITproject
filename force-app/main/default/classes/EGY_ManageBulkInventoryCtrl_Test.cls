/***********************************************************************************************
* Name              : EGY_ManageBulkInventoryCtrl_Test                                                 
* Description       : Test class for EGY_ManageBulkInventoryCtrl                                             
* Created Date      : 02/06/2018                                                    
* Created By        : Adeel Ahmad (adeel.ahmad@weare4c.com)    
* Jira/Req By       :                                                                                                                                         
* ----------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
* 1.0       Adeel       02/06/2018  Created                              
************************************************************************************************/
@IsTest
public with sharing class EGY_ManageBulkInventoryCtrl_Test {
	static testMethod void EGY_ManageBulkInventoryCtrl_Test() {
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
        insert objProINV;
        
        //Insert a Campaign User
        Campaign_User__c oCampaignUser=TestDataFactory.CreateCampaignUser(oUser.Id,objCampaign.Id);
        insert oCampaignUser;
        
        //Insert a Campaign Unit
        Campaign_Unit__c  oUnit=TestDataFactory.CreateCampaignUnits(objCampaign.Id,objProINV.Id);
        insert oUnit;
        
        System.runAs(oUser){
            MAP<String, String> propertyNames = EGY_ManageBulkInventoryCtrl.fetchFieldOptions('propertyNameFilterOption', '', '', '');
            MAP<String, String> statusFilterOptions = EGY_ManageBulkInventoryCtrl.fetchFieldOptions('statusFilterOption', '', '', '');
            MAP<String, String> campaignsFilterOptions = EGY_ManageBulkInventoryCtrl.fetchFieldOptions('CampaignsFilterOption', '', '', '');  
            MAP<String, String> buildingNameFilterOptions = EGY_ManageBulkInventoryCtrl.fetchFieldOptions('buildingNameFilterOption', '', '', '');        
            MAP<String, String> propertyTypeFilterOptions = EGY_ManageBulkInventoryCtrl.fetchFieldOptions('propertyTypeFilterOption', '', '', '');        
            MAP<String, String> unitModelFilterOptions = EGY_ManageBulkInventoryCtrl.fetchFieldOptions('unitModelFilterOption', '', '', ''); 
            MAP<String, String> bedroomsFilterOptions = EGY_ManageBulkInventoryCtrl.fetchFieldOptions('bedRoomsFilterOption', '', '', '');
            MAP<String, String> unitTypeFilterOptions = EGY_ManageBulkInventoryCtrl.fetchFieldOptions('unitTypeFilterOption', '', '', '');
            MAP<String, String> confirmTypeFilterOption = EGY_ManageBulkInventoryCtrl.fetchFieldOptions('confirmTypeFilterOption', '', '', '');
            
            //Checking dependent picklist options
			Map<String,List<String>> dependentMap = EGY_ManageBulkInventoryCtrl.getDependentOptionsImpl('Property_Inventory__c', 'Property_Type__c', 'Blocked_Type__c');
	
            //perform search
            LIST<Property_Inventory__c> searched = EGY_ManageBulkInventoryCtrl.doSearch(
                																		property.Id, 
                																		String.valueOf(campaignsFilterOptions.values()).split(',')[0], 
                																		'', 
                																		String.valueOf(buildingNameFilterOptions.values()).split(',')[0], 
                																		String.valueOf(unitModelFilterOptions.values()).split(',')[0], 
                																		String.valueOf(unitTypeFilterOptions.values()).split(',')[0], 
                																		String.valueOf(confirmTypeFilterOption.values()).split(',')[0],
                																		String.valueOf(bedroomsFilterOptions.values()).split(',')[0], 
                																		'', 
                																		'TEST', 
                																		'TEST REASON',
            																			'Id');
            
            LIST<Property_Inventory__c> updateable = EGY_ManageBulkInventoryCtrl.doSearch(property.Id,'','','','','','','','','','','Id');
            
            //Performing status update to block
            String updateableStatus = EGY_ManageBulkInventoryCtrl.updateProperties(updateable, '', 'Blocked', true, '', '', 'Test Reason to Block');
            
            //Performig status update to sale
            String updateableStatus_sale = EGY_ManageBulkInventoryCtrl.updateProperties(updateable, '', 'Sale', true, '', '', '');
            
            //Fetching fields 
            EGY_ManageBulkInventoryCtrl.fetchFields('EGY_ManageBulkInventory');
            
            //Remove Campaigns
            EGY_ManageBulkInventoryCtrl.removeCampaignFromInventories(updateable);
        }
	}
}