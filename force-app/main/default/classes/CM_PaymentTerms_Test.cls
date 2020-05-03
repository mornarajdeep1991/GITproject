/***********************************************************************************************
* Name              : CM_PaymentTerms_Test                                                 
* Description       : Test class for CM_PaymentTerms                                             
* Created Date      : 01/06/2018                                                    
* Created By        : Adeel Ahmad (adeel.ahmad@weare4c.com)    
* Jira/Req By       :                                                                                                                                         
* ----------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
* 1.0       Adeel       01/06/2018  Created                              
************************************************************************************************/
@isTest
private class CM_PaymentTerms_Test {
    private static testMethod void test() {
        
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonMailingCountry ='United Arab Emirates';
        insert objAccount;
      
        
        Campaign objCampaign = TestDataFactory.CreateCampaign();
        insert objCampaign;
        
        
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        objLoc.Location_Code__c= 'UAE';
        insert objloc;
        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.CampaignID = objCampaign.id;
        objOppor.AccountId = objAccount.Id;
        
        insert objOppor;
        
        Property_Inventory__c objProINV = TestDataFactory.CreatePropertyInventory(objLoc.id);
        Property_Inventory__c objProINV1 = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV.recordTypeId  =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        objProINV.Instance__c = 'test';
        objProINV.location__c = objloc.id;
        insert objProINV;
        
        Opportunity_Property__c objOP = TestDataFactory.CreateOpportunityProperty(objOppor.id,objProINV.id);
        objop.Campaign_Id__c = '5';
        insert objOP;
        
         Payment_Terms__c pt=TestDataFactory.createPaymentTerms();
         insert pt;
         
         Property_Inventory__c  objProperty_Inventory=TestDataFactory.CreatePackage();
         insert objProperty_Inventory;

         string resultXML = '<P_RESULT_XML xmlns="http://xmlns.oracle.com/pcbpel/adapter/db/APPS/XX_MOBILE_INT_PKG/PERFORM_ACTION/"><XX_SALES_LAUNCH xmlns=""><XX_LOC_PAYMENT_TERMS_T>';
         resultXML = resultXML+'<XX_LOC_PAYMENT_TERMS_O><LOCATION_ID>273425</LOCATION_ID><ORG_ID>898</ORG_ID><LOCATION_CODE>DE Maple-V-423</LOCATION_CODE>';
         resultXML = resultXML+'<INST_NUMBER>1</INST_NUMBER><NET_AMOUNT>207189</NET_AMOUNT><NET_PERCENT>10</NET_PERCENT><TERMDAYS>0</TERMDAYS><TERMDATE>2016-05-04</TERMDATE>';
         resultXML = resultXML+'<MILESTONE_NAME>1st Installment</MILESTONE_NAME><SM_HEADER_ID>958</SM_HEADER_ID><SCHEDULE_TYPE>STANDARD</SCHEDULE_TYPE>';
         resultXML = resultXML+'</XX_LOC_PAYMENT_TERMS_O></XX_LOC_PAYMENT_TERMS_T></XX_SALES_LAUNCH></P_RESULT_XML>';
        
       
        apexpages.currentPage().getParameters().put('Id',objOppor.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(objOppor);
        Cm_PaymentTerms objPayTerms = new Cm_PaymentTerms(sc);
        objPayTerms.ServiceCall();
        
        
        objPayTerms.submitTermSelection();
        //objPayTerms.submitTermSelection();
        ///objPayTerms.CheckAgent();
        //Cm_PaymentTerms.parsedata(resultXML);
        Cm_PaymentTerms.PropertyUnitwrap obj = new Cm_PaymentTerms.PropertyUnitwrap();
        
    }
   
    
   
}