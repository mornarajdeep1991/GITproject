/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class CM_GenerateSalesOffer_Test {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Account objAccount = TestDataFactory.createPAccount();
      objAccount.PersonMailingCountry ='United Arab Emirates';
      objAccount.cm_Birthdate__pc = system.today().addYears(-28);
      objAccount.cm_Passport_Number__pc = 'IND123456';
      objAccount.cm_Resident_Of_UAE__pc = false;
      objAccount.BillingCity = 'Dubai';
      objAccount.BillingCountry = 'United Arab Emirates';
      objAccount.BillingStreet = 'Down Town Area';
      objAccount.cm_Date_of_Incorporation__c = system.today().addYears(-3);
      objAccount.cm_Country_Of_Incorporation__c = 'United Arab Emirates';
      objAccount.cm_Trade_License_Expiry_Date__c = system.today().addYears(2);
      objAccount.cm_Trade_License_Number__c = 'CL1234';
      insert objAccount;
      
      Account objAccount2 = TestDataFactory.createBAccount();
      objAccount2.BillingCity = 'Dubai';
      objAccount2.BillingCountry = 'United Arab Emirates';
      objAccount2.BillingStreet = 'Down Town Area';
      objAccount2.cm_Date_of_Incorporation__c = system.today().addYears(-3);
      objAccount2.cm_Country_Of_Incorporation__c = 'United Arab Emirates';
      objAccount2.cm_Trade_License_Expiry_Date__c = system.today().addYears(2);
      objAccount2.cm_Trade_License_Number__c = 'CL1234';
      objAccount2.Party_Type__c = 'ORGANIZATION';
      insert objAccount2;
      
      Contact objContact = new Contact();
      objContact.AccountId = objAccount2.Id;
      objContact.FirstName = 'RB'; 
      objContact.LastName = 'Dubai';
      objContact.Email = 'test@emaar.ae.test';
      objContact.cm_Birthdate__c = system.today().addYears(-28);
      objContact.cm_Passport_Number__c = 'IND1235';
      objContact.cm_Resident_Of_UAE__c = true;
      objContact.cm_National_ID_No__c = 'UAE2010569';
      insert objContact;
      
      Campaign objCampaign = TestDataFactory.CreateCampaign();
      insert objCampaign;

      Opportunity objOppor = TestDataFactory.createOpportunity();
      objOppor.AccountId = objAccount.id;
      objOppor.CampaignID = objCampaign.id;
      objOppor.cm_Sales_Person__c = Userinfo.getUserId();      
      insert objOppor;
      
      Opportunity objOppor1 = TestDataFactory.createOpportunity();
      objOppor1.AccountId = objAccount2.id;
      objOppor1.CampaignID = objCampaign.id;
      objOppor1.cm_Sales_Person__c = Userinfo.getUserId();      
      objOppor1.cm_Contact__c = objContact.Id;
      insert objOppor1;
        
        Location__c objLoc = TestDataFactory.CreateLocation('U');
      insert objLoc;
        
        Property_Inventory__c objProINV = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV.Instance__c = '123456';
        insert objProINV;
        
        Opportunity_Property__c objOP = new Opportunity_Property__c();
        objOP.cm_Opportunity__c = objOppor.Id;
        objOP.cm_Property_Inventory__c = objProINV.Id;
        objOP.Sales_Order__c = 'Test Sales Order';
        insert objOP;
        
        Joint_Owner__c objJoint =  TestDataFactory.CreateJointOwner(objAccount.id,objOppor.id);
        insert objJoint;
        
        Attachment objA = new Attachment();
        objA.Name = 'Test';
        objA.ParentId = objOP.Id;
        objA.Body = blob.valueOf('test');
        insert objA;
        
        cm_Integration_Settings__c objIS = new cm_Integration_Settings__c(Name='ORACLE',cm_SOA_key__c='SADA',cm_AES_Key__c='SDA',cm_UD_ID__c='DAA',cm_Username__c='ASDA');
        insert objIS;
        
        apexpages.currentpage().getparameters().put('id',objOppor.Id);
        test.startTest();
          
          emaarServicesComCreatesrbpelprocessVTest.CalloutType = 'ExecutePaymentTerms';
          Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl());
          
          CM_GenerateSalesOffer objGS = new CM_GenerateSalesOffer();
          
          CM_GenerateSalesOffer.Responsewrap objWrap = new CM_GenerateSalesOffer.Responsewrap();
          objWrap.INST_NUMBER = null;
          objWrap.LOCATION_CODE = null;
          objWrap.LOCATION_ID = null;
          objWrap.MIL_PERCENTAGE = null;
          objWrap.MILESTONE_NAME = null;
          objWrap.MILESTONE_NAME_ARB = null;
          objWrap.NET_AMOUNT = null;
          objWrap.NET_PERCENT = null;
          objWrap.ORG_ID = null;
          objWrap.SCHEDULE_TYPE = null;
          objWrap.SM_HEADER_ID = null;
          objWrap.TERMDATE = null;
          objWrap.TERMDAYS = null;
          //objGS.parsedata(objWrap);
          CM_GenerateSalesOffer.UnitPaymentTerms objGU = new CM_GenerateSalesOffer.UnitPaymentTerms();
          objGU.strUnit = null;
          objGU.lstResponsewrap = null;
          
          CM_GenerateSalesOffer.AttachmentURLwrap objGA = new CM_GenerateSalesOffer.AttachmentURLwrap();
          objGA.Unit = null;
          
          objGS.objAccount = null;
          objGS.fileId = null;
          
          //objGS.PreparePaymentTerms
        
        test.stopTest();
    }
}