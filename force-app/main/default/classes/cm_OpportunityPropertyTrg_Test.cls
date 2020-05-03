/***********************************************************************************************
* Name              : EGY_AddEOIController_Test                                                 
* Description       : Test class for EGY_AddEOIController                                             
* Created Date      : 09/06/2018                                                    
* Created By        : Adeel Ahmad (adeel.ahmad@weare4c.com)    
* Jira/Req By       :                                                                                                                                         
* ----------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
* 1.0       Adeel       09/06/2018  Created                              
************************************************************************************************/
@IsTest
public class cm_OpportunityPropertyTrg_Test {
    public static testMethod void Test_OpportunityPropertyTrg(){
        list<Cm_AddProperties.Propertywrap> lstPropertywrap = new list<Cm_AddProperties.Propertywrap>();
        Id unitRecordTypeId =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        insert objLoc;
        
        cm_Administrator_Settings__c AdmSett = New cm_Administrator_Settings__c();
        AdmSett.Name='ADMIN';
        AdmSett.Temp_Campaign_Property_Count__c=2;
        insert AdmSett;
        
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonMailingCountry ='United Arab Emirates';
        insert objAccount;
        
        Campaign objCampaign = TestDataFactory.CreateCampaign();
        objCampaign.type='Launch';
        //objCampaign.IsActive = true;
        objCampaign.cm_No_of_properties_customers_can_buy__c ='2';
        insert objCampaign;
        
        Campaign_User__c  CampUser = TestDataFactory.CreateCampaignUser(UserInfo.getUserId(),objCampaign.id);
        insert CampUser;
        
        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount.id;
        objOppor.CampaignID = objCampaign.id;
        insert objOppor;
        
        Property_Inventory__c objProINV1 = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV1.recordTypeId =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Package').getRecordTypeId();
        objProINV1.Instance__c = 'test';
        objProINV1.Property_Status__c='Available';
        objProINV1.Property_Type__c= 'Sale';
        insert objProINV1;
        
        Opportunity_Property__c oppPro =TestDataFactory.CreateOpportunityProperty(objOppor.id,objProINV1.id);
        oppPro.cm_Order_Status__c = 'SOLD_CANCELLED';
        oppPro.Booking_Price__c = 1500000;
        oppPro.Campaign_Price__c = 1500000;
        oppPro.Total_Maintenance_Fee__c = 250000;
        insert oppPro;
        
        oppPro.cm_Order_Status__c = 'SOLD';
        update oppPro;

		Delete oppPro;       
    }
}