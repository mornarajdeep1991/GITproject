@isTest (SeeAllData=true)
public class EGY_OpportunityPaymentsController_Test {
    static testMethod void doTest() {
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonEmail ='test@gmail.com';
        objAccount.PersonMobilePhone ='5678903456';
        insert objAccount;
        
        Contact objContact = TestDataFactory.createContact();
        objContact.MobilePhone=null;
        objContact.Email=null;
        objContact.MailingStreet=null;
        insert objContact;
        
        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount.id;
        objOppor.cm_Contact__c=objContact.Id;
        insert objOppor;
        
        test.starttest();
        EGY_OpportunityPaymentsController oController = new EGY_OpportunityPaymentsController();
        
        MAP<String, String> stateFld = EGY_OpportunityPaymentsController.fetchFieldOptions('state');
        MAP<String, String> countryFld = EGY_OpportunityPaymentsController.fetchFieldOptions('country');
        MAP<String, String> countrycodesFld = EGY_OpportunityPaymentsController.fetchFieldOptions('CountryCodes');
        MAP<String, String> countryofIncorpFld = EGY_OpportunityPaymentsController.fetchFieldOptions('Country Of Incorporation');
        MAP<String, String> ordersourceFld = EGY_OpportunityPaymentsController.fetchFieldOptions('Order_Source__c');
        MAP<String, String> ordereventFld = EGY_OpportunityPaymentsController.fetchFieldOptions('Order_Event__c');
        MAP<String, String> paymentModeFld = EGY_OpportunityPaymentsController.fetchFieldOptions('PaymentModes');
        MAP<String, String> chequeDeositMethodsFld = EGY_OpportunityPaymentsController.fetchFieldOptions('ChequeDeositMethods');
        MAP<String, String> wireTransferDepositMethodsFld = EGY_OpportunityPaymentsController.fetchFieldOptions('WireTransferDepositMethods');
        MAP<String, String> creditCardOptionsFld = EGY_OpportunityPaymentsController.fetchFieldOptions('CreditCardOptions');
        
        
        EGY_OpportunityPaymentsController.getOpportunityInfo(objOppor.id);
        EGY_OpportunityPaymentsController.getAccountInfo(objAccount.id,'EGY_PersonAccount',objContact.id);
        EGY_OpportunityPaymentsController.getContactInfo('EGY_PersonAccount',objContact.id);
        EGY_OpportunityPaymentsController.getAddedProperties(objOppor.id);
        EGY_OpportunityPaymentsController.upsertPersonAccount(objAccount,objOppor.id);
        EGY_OpportunityPaymentsController.upsertBusinessAccount(objAccount,objOppor.id);
        EGY_OpportunityPaymentsController.upsertOpptyContact(objContact);
        EGY_OpportunityPaymentsController.createSalesOrder(objOppor.id);
        
        test.stopTest();
        
        
    }
    static testmethod void testcase2(){
        
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonEmail ='test@gmail.com';
        objAccount.PersonMobilePhone ='5678903456';
        insert objAccount;
        
        Contact objContact = TestDataFactory.createContact();
        objContact.MobilePhone=null;
        objContact.Email=null;
        objContact.MailingStreet=null;
        insert objContact;
        
        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount.id;
        objOppor.cm_Contact__c=objContact.Id;
        insert objOppor;
        test.startTest();
        EGY_OpportunityPaymentsController.cancelSalesBooking(objOppor.id);
        EGY_OpportunityPaymentsController.submit(objOppor.id, 'Cheque', 'Cash','Online Payment Link', 100.00, True, 'Test exception Comments');
        EGY_OpportunityPaymentsController.upsertOpportunity(objOppor.id,objOppor);
        EGY_OpportunityPaymentsController.validateOpportunityProperties(objOppor.id);
        EGY_OpportunityPaymentsController.getRecordTypeId('Opportunity','Admin Rejection');
        test.stopTest();
    }
    static testmethod void testcase3(){
        
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonEmail ='test@gmail.com';
        objAccount.PersonMobilePhone ='5678903456';
        objAccount.BillingCountryCode ='';
        insert objAccount;
        
        Contact objContact = TestDataFactory.createContact();
        objContact.MobilePhone=null;
        objContact.Email=null;
        objContact.MailingStreet=null;
        insert objContact;
        
        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount.id;
        objOppor.cm_Contact__c=objContact.Id;
        insert objOppor;
        test.startTest();
        EGY_OpportunityPaymentsController.getAccountInfo(objAccount.id,'',objContact.id);
        EGY_OpportunityPaymentsController.getContactInfo('',objContact.id);
        EGY_OpportunityPaymentsController.upsertPersonAccount(objAccount,objOppor.id);
        test.stopTest();
    }
    static testMethod void doTest4() {
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonEmail ='test@gmail.com';
        objAccount.PersonMobilePhone ='5678903456';
        insert objAccount;
        
        Contact objContact = TestDataFactory.createContact();
        objContact.MobilePhone=null;
        objContact.Email=null;
        objContact.MailingStreet=null;
        insert objContact;
        
        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount.id;
        objOppor.cm_Contact__c=objContact.Id;
        insert objOppor;
        
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
        insert objProINV;
        
        Opportunity_Property__c objOP = new Opportunity_Property__c();
        objOP.cm_Opportunity__c = objOppor.Id;
        objOP.cm_Property_Inventory__c = objProINV.Id;
        objOP.Campaign_Id__c = null;
        objOP.Campaign_Map_Id__c = null;
        insert objOP;
        
        test.starttest();
        EGY_OpportunityPaymentsController oController = new EGY_OpportunityPaymentsController();
        EGY_OpportunityPaymentsController.validateOpportunityProperties(objOppor.id);
        
        
        test.stopTest();
        
        
    }
}