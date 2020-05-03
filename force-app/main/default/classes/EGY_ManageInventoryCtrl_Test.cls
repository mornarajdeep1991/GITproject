/***********************************************************************************************
* Name              : EGY_ManageInventoryCtrl_Test                                                 
* Description       : Test class for EGY_ManageInventoryCtrl                                             
* Created Date      : 02/06/2018                                                    
* Created By        : Adeel Ahmad (adeel.ahmad@weare4c.com)    
* Jira/Req By       :                                                                                                                                         
* ----------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
* 1.0       Adeel       02/06/2018  Created                              
************************************************************************************************/
@isTest
public class EGY_ManageInventoryCtrl_Test {
    static testMethod void EGY_ManageInventoryCtrl_Test() {
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
            //Populating all field options
            MAP<String, String> propertyNames = EGY_ManageInventoryCtrl.fetchFieldOptions('propertyNameFilterOption', '');
            MAP<String, String> statusFilterOptions = EGY_ManageInventoryCtrl.fetchFieldOptions('statusFilterOption', '');
            MAP<String, String> campaignsFilterOptions = EGY_ManageInventoryCtrl.fetchFieldOptions('CampaignsFilterOption', '');        
            MAP<String, String> buildingNameFilterOptions = EGY_ManageInventoryCtrl.fetchFieldOptions('buildingNameFilterOption', '');        
            MAP<String, String> propertyTypeFilterOptions = EGY_ManageInventoryCtrl.fetchFieldOptions('propertyTypeFilterOption', '');        
            MAP<String, String> unitModelFilterOptions = EGY_ManageInventoryCtrl.fetchFieldOptions('unitModelFilterOption', ''); 
            MAP<String, String> bedroomsFilterOptions = EGY_ManageInventoryCtrl.fetchFieldOptions('bedRoomsFilterOption', '');             

            //Assert for filter option
            System.assert(statusFilterOptions.values().size() > 0);
            
            //Perform search
            LIST<Property_Inventory__c> searched = EGY_ManageInventoryCtrl.doSearch
                                                    ('',
                                                     String.valueOf(propertyNames.values()).split(',')[0],
                                                     String.valueOf(statusFilterOptions.values()).split(',')[0],
                                                     '',
                                                     'Emaar',
                                                     String.valueOf(propertyTypeFilterOptions.values()).split(',')[0],
                                                     String.valueOf(unitModelFilterOptions.values()).split(',')[0],
                                                     String.valueOf(bedroomsFilterOptions.values()).split(',')[0],
                                                    'Id');
            test.startTest();
            LIST<Property_Inventory__c> searched_with_params = EGY_ManageInventoryCtrl.doSearch('','Emaar','','','','','','','Id');
            System.assert(searched_with_params.size() > 0);
            
            //Updating property inventory status
            String updateableStatus = EGY_ManageInventoryCtrl.setPropertyInventoryStatus(objProINV.Id, 'Block', 'Test Comments');                       
            System.assert(updateableStatus == 'Status Successfully updated');
            
            //Fetching fields 
            EGY_ManageInventoryCtrl.fetchFields('EGY_ManageInventory');
            test.stopTest();
        }
    }
}