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
private class EmaarBookingProcess_Test {
  @isTest
    static void myUnitTest() {
      Account objAccount = TestDataFactory.createPAccount();
      objAccount.PersonMailingCountry ='United Arab Emirates';
      objAccount.cm_Birthdate__pc = system.today().addYears(-28);
      objAccount.cm_Passport_Number__pc = 'IND123456';
      objAccount.cm_Resident_Of_UAE__pc = false;
      objAccount.BillingCity = 'Dubai';
      objAccount.BillingCountry = 'United Arab Emirates';
      objAccount.BillingStreet = 'Down Town Area';
        objAccount.Salutation = 'HH';
        objAccount.cm_National_ID_Expiry_Date__pc = system.today().addYears(2);
        objAccount.cm_Date_of_Incorporation__c = system.today().addYears(-1);
      objAccount.cm_Trade_License_Expiry_Date__c = system.today().addYears(2);
        objAccount.cm_Visa_Expiry_Date__pc = system.today().addYears(2);
      objAccount.cm_Passport_Issue_Date__pc  = system.today().addYears(-1);
        objAccount.cm_Passport_Expiry_Date__pc  = system.today().addYears(2);
        objAccount.Shipping_Mobile_Number__c = '521234567';
        objAccount.Shipping_Mobile_Country_Code__c = 'India: 0091';
        objAccount.personMobilePhone = '521234567';
        objAccount.cm_Mobile_Country_Code__pc = 'India: 0091';
        objAccount.Emirate__c = 'Dubai';
        objAccount.BillingCountry = 'United States';
        objAccount.ShippingCountry = 'United States';
      insert objAccount;
      
      
      
        Account objJointOwner = TestDataFactory.createPAccount();
        objJointOwner.PersonMailingCountry ='United Arab Emirates';
        objJointOwner.cm_Birthdate__pc = system.today().addYears(-28);
      objJointOwner.cm_Passport_Number__pc = 'IND123456';
      objJointOwner.cm_Resident_Of_UAE__pc = false;
      objJointOwner.BillingCity = 'Dubai';
      objJointOwner.BillingCountry = 'United Arab Emirates';
      objJointOwner.BillingStreet = 'Down Town Area';
        objJointOwner.Salutation = 'HH';
        objJointOwner.cm_National_ID_Expiry_Date__pc = system.today().addYears(2);
        objJointOwner.cm_Date_of_Incorporation__c = system.today().addYears(-1);
      objJointOwner.cm_Trade_License_Expiry_Date__c = system.today().addYears(2);
        objJointOwner.cm_Visa_Expiry_Date__pc = system.today().addYears(2);
      objJointOwner.cm_Passport_Issue_Date__pc  = system.today().addYears(-1);
        objJointOwner.cm_Passport_Expiry_Date__pc  = system.today().addYears(2);
        objJointOwner.Shipping_Mobile_Number__c = '521234567';
        objJointOwner.Shipping_Mobile_Country_Code__c = 'India: 0091';
        objJointOwner.personMobilePhone = '521234567';
        objJointOwner.cm_Mobile_Country_Code__pc = 'India: 0091';
        objJointOwner.Emirate__c = 'Dubai';
        objJointOwner.BillingCountry = 'United States';
        objJointOwner.ShippingCountry = 'United States';
        insert objJointOwner;
        
      Campaign objCampaign = TestDataFactory.CreateCampaign();
      insert objCampaign;

        Mobile_Configurations__c objMC = new Mobile_Configurations__c();
        objMC.Name = 'Configuration';
        objMC.cm_Sales_Admin_Username__c = Userinfo.getUserName();
        objMC.Tempo_Campaign_ID__c = objCampaign.id;
        insert objMC;
        
        cm_Integration_Settings__c custSet = new cm_Integration_Settings__c(Name='ORACLE',cm_SOA_key__c='SADA',cm_AES_Key__c='mypassword123456',cm_UD_ID__c='DAA',cm_Username__c='ASDA');
        insert custSet;
        
      Opportunity objOppor = TestDataFactory.createOpportunity();
      objOppor.AccountId = objAccount.id;
      objOppor.CampaignID = objCampaign.id;
      objOppor.Is_from_Broker_App__c = true;
      objOppor.Sales_Admin_Approved_by__c  = Userinfo.getUserId();
      objOppor.Lead_Conversion_Date__c =date.today();
      objOppor.cm_Sales_Person__c = Userinfo.getUserId();   
        objOppor.cm_Agency_Name__c = objAccount.id;
        insert objOppor;
      
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        objLoc.Location_ID__c = '123456';
        objLoc.Location_Code__c = 'BD Test RB-1234';
        
      insert objLoc;
        
        Property_Inventory__c objProINV = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV.Instance__c = '123456';
        objProINV.Property_Status__c = 'Draft';
        objProINV.VAT_Rate__c = 2;
        objProINV.VAT_Amount__c= 200;
        objProINV.Org_ID__c = 1234;
        insert objProINV;
        
        Opportunity_Property__c objOP = new Opportunity_Property__c();
        objOP.cm_Opportunity__c = objOppor.Id;
        objOP.cm_Property_Inventory__c = objProINV.Id;
        insert objOP;
        
        Joint_Owner__c objJoint =  TestDataFactory.CreateJointOwner(objJointOwner.id,objOppor.id);
        insert objJoint;
        
        Service_Logs__c lg = new Service_Logs__c(Process_Name__c = 'EmaarBookingProcess Test Class');
    insert lg;
        
        test.startTest();
          
          Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl());
          EmaarBookingProcess.CreateParty_SalesOrder(objOppor.Id , lg.Id, 'Temo Dubai', 'Kiosk', new map<string,string>());
          
        test.stopTest();
        
    }
    
    @isTest
    static void myUnitTest1() {
        Id RecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('EGY Corporate Account').getRecordTypeId();
      Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        objAccount.RecordTypeId = RecordTypeId;
      objAccount.BillingCity = 'Dubai';
      objAccount.BillingCountry = 'United Arab Emirates';
      objAccount.BillingStreet = 'Down Town Area';
        objAccount.cm_Date_of_Incorporation__c = system.today().addYears(-1);
      objAccount.cm_Trade_License_Expiry_Date__c = system.today().addYears(2);
        objAccount.Shipping_Mobile_Number__c = '521234567';
        objAccount.Shipping_Mobile_Country_Code__c = 'India: 0091';
        //objAccount.Corporate_Phone__c = '521234567';
        //objAccount.Corporate_Phone_Country_Code__c = 'India: 0091';
        objAccount.VAT_Registration_No__c = '98765456';
      insert objAccount;
      
        Contact objContact = new Contact();
        objContact.FirstName = 'Test';
        objContact.LastName = 'Contact';
        objContact.Salutation = 'HE';
        objContact.cm_Gender__c = 'Female';
        objContact.Email = 'ravi@emaar.ae';
        objContact.MobilePhone = '526515651';
        objContact.cm_Mobile_Country_Code__c = 'India: 0091';
        objContact.cm_Nationality__c = 'India';
        objContact.AccountId = objAccount.Id;
        insert objContact;
        
                
        Account objJointOwner = TestDataFactory.createPAccount();
        objJointOwner.PersonMailingCountry ='United Arab Emirates';
        objJointOwner.cm_Birthdate__pc = system.today().addYears(-28);
      objJointOwner.cm_Passport_Number__pc = 'IND123456';
      objJointOwner.cm_Resident_Of_UAE__pc = false;
      objJointOwner.BillingCity = 'Dubai';
      objJointOwner.BillingCountry = 'United Arab Emirates';
      objJointOwner.BillingStreet = 'Down Town Area';
        objJointOwner.Salutation = 'HH';
        objJointOwner.cm_National_ID_Expiry_Date__pc = system.today().addYears(2);
        objJointOwner.cm_Date_of_Incorporation__c = system.today().addYears(-1);
      objJointOwner.cm_Trade_License_Expiry_Date__c = system.today().addYears(2);
        objJointOwner.cm_Visa_Expiry_Date__pc = system.today().addYears(2);
      objJointOwner.cm_Passport_Issue_Date__pc  = system.today().addYears(-1);
        objJointOwner.cm_Passport_Expiry_Date__pc  = system.today().addYears(2);
        objJointOwner.Shipping_Mobile_Number__c = '521234567';
        objJointOwner.Shipping_Mobile_Country_Code__c = 'India: 0091';
        objJointOwner.personMobilePhone = '521234567';
        objJointOwner.cm_Mobile_Country_Code__pc = 'India: 0091';
        objJointOwner.Emirate__c = 'Dubai';
        objJointOwner.BillingCountry = 'United States';
        objJointOwner.ShippingCountry = 'United States';
        insert objJointOwner;
        
      Campaign objCampaign = TestDataFactory.CreateCampaign();
      insert objCampaign;


        Mobile_Configurations__c objMC = new Mobile_Configurations__c();
        objMC.Name = 'Configuration';
        objMC.cm_Sales_Admin_Username__c = Userinfo.getUserName();
        objMC.Tempo_Campaign_ID__c = objCampaign.id;
        insert objMC;
       
        cm_Integration_Settings__c custSet = new cm_Integration_Settings__c(Name='ORACLE',cm_SOA_key__c='SADA',cm_AES_Key__c='mypassword123456',cm_UD_ID__c='DAA',cm_Username__c='ASDA');
        insert custSet;
        
      Opportunity objOppor = TestDataFactory.createOpportunity();
      objOppor.AccountId = objAccount.id;
      objOppor.CampaignID = objCampaign.id;
      objOppor.cm_Sales_Person__c = Userinfo.getUserId();   
        objOppor.cm_Agency_Name__c = objAccount.id;
        insert objOppor;
        
        Opportunity objOppo = TestDataFactory.createOpportunity();
      objOppo.AccountId = objAccount.id;
      objOppo.CampaignID = objCampaign.id;
      objOppo.cm_Sales_Person__c = Userinfo.getUserId();   
        objOppo.cm_Agency_Name__c = objAccount.id;
        insert objOppo;
      
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        objLoc.Location_ID__c = '123456';
        objLoc.Location_Code__c = 'BD Test RB-1234';
        
      insert objLoc;
        
        Property_Inventory__c objProINV = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV.Instance__c = '123456';
        objProINV.Property_Status__c = 'Draft';
        objProINV.Org_ID__c = 1234;
        insert objProINV;
        
        Opportunity_Property__c objOP = new Opportunity_Property__c();
        objOP.cm_Opportunity__c = objOppor.Id;
        objOP.cm_Property_Inventory__c = objProINV.Id;
        insert objOP;
        
        Joint_Owner__c objJoint =  TestDataFactory.CreateJointOwner(objJointOwner.id,objOppor.id);
        insert objJoint;
        
        Service_Logs__c lg = new Service_Logs__c(Process_Name__c = 'EmaarBookingProcess Test Class');
    insert lg;
        
        
          Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl());
          //EmaarBookingProcess.CreateParty_SalesOrder(objOppor.Id , lg.Id, 'Temo Dubai', 'Kiosk', new map<string,string>());
        try{
        test.startTest();
          EmaarBookingProcess.CreateParty_ExpressionOfInterest(objOppo.id);
        test.stopTest(); 
        }catch (Exception e) {
          }
          //EmaarBookingProcess.CreateParty_ExpressionOfInterest(objOppo.Id);
        
        }
    @isTest
    static void myUnitTest2() {
        Id RecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('EGY Corporate Account').getRecordTypeId();
      Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        objAccount.RecordTypeId = RecordTypeId;
      objAccount.BillingCity = 'Dubai';
      objAccount.BillingCountry = 'United Arab Emirates';
      objAccount.BillingStreet = 'Down Town Area';
        objAccount.cm_Date_of_Incorporation__c = system.today().addYears(-1);
      objAccount.cm_Trade_License_Expiry_Date__c = system.today().addYears(2);
        objAccount.Shipping_Mobile_Number__c = '521234567';
        objAccount.Shipping_Mobile_Country_Code__c = 'India: 0091';
        //objAccount.Corporate_Phone__c = '521234567';
        //objAccount.Corporate_Phone_Country_Code__c = 'India: 0091';
        objAccount.VAT_Registration_No__c = '98765456';
      insert objAccount;
      
        Contact objContact = new Contact();
        objContact.FirstName = 'Test';
        objContact.LastName = 'Contact';
        objContact.Salutation = 'HH';
        objContact.cm_Gender__c = 'Female';
        objContact.Email = 'ravi@emaar.ae';
        objContact.MobilePhone = '526515651';
        objContact.cm_Mobile_Country_Code__c = 'India: 0091';
        objContact.cm_Nationality__c = 'India';
        objContact.AccountId = objAccount.Id;
        insert objContact;
        
        Account objJointOwner = TestDataFactory.createPAccount();
        objJointOwner.PersonMailingCountry ='United Arab Emirates';
        objJointOwner.cm_Birthdate__pc = system.today().addYears(-28);
      objJointOwner.cm_Passport_Number__pc = 'IND123456';
      objJointOwner.cm_Resident_Of_UAE__pc = false;
      objJointOwner.BillingCity = 'Dubai';
      objJointOwner.BillingCountry = 'United Arab Emirates';
      objJointOwner.BillingStreet = 'Down Town Area';
        objJointOwner.Salutation = 'HH';
        objJointOwner.cm_National_ID_Expiry_Date__pc = system.today().addYears(2);
        objJointOwner.cm_Date_of_Incorporation__c = system.today().addYears(-1);
      objJointOwner.cm_Trade_License_Expiry_Date__c = system.today().addYears(2);
        objJointOwner.cm_Visa_Expiry_Date__pc = system.today().addYears(2);
      objJointOwner.cm_Passport_Issue_Date__pc  = system.today().addYears(-1);
        objJointOwner.cm_Passport_Expiry_Date__pc  = system.today().addYears(2);
        objJointOwner.Shipping_Mobile_Number__c = '521234567';
        objJointOwner.Shipping_Mobile_Country_Code__c = 'India: 0091';
        objJointOwner.personMobilePhone = '521234567';
        objJointOwner.cm_Mobile_Country_Code__pc = 'India: 0091';
        objJointOwner.Emirate__c = 'Dubai';
        objJointOwner.BillingCountry = 'United States';
        objJointOwner.ShippingCountry = 'United States';
        insert objJointOwner;
        
        
        
      Campaign objCampaign = TestDataFactory.CreateCampaign();
      insert objCampaign;


        Mobile_Configurations__c objMC = new Mobile_Configurations__c();
        objMC.Name = 'Configuration';
        objMC.cm_Sales_Admin_Username__c = Userinfo.getUserName();
        objMC.Tempo_Campaign_ID__c = objCampaign.id;
        insert objMC;
       
        cm_Integration_Settings__c custSet = new cm_Integration_Settings__c(Name='ORACLE',cm_SOA_key__c='SADA',cm_AES_Key__c='mypassword123456',cm_UD_ID__c='DAA',cm_Username__c='ASDA');
        insert custSet;
        
      Opportunity objOppor = TestDataFactory.createOpportunity();
      objOppor.AccountId = objAccount.id;
      objOppor.CampaignID = objCampaign.id;
      objOppor.cm_Sales_Person__c = Userinfo.getUserId();   
        objOppor.cm_Agency_Name__c = objAccount.id;
        insert objOppor;
        
        Opportunity objOppo = TestDataFactory.createOpportunity();
      objOppo.AccountId = objAccount.id;
      objOppo.CampaignID = objCampaign.id;
      objOppo.cm_Sales_Person__c = Userinfo.getUserId();   
        objOppo.cm_Agency_Name__c = objAccount.id;
        insert objOppo;
      
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        objLoc.Location_ID__c = '123456';
        objLoc.Location_Code__c = 'BD Test RB-1234';
        
      insert objLoc;
        
        Property_Inventory__c objProINV = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV.Instance__c = '123456';
        objProINV.Property_Status__c = 'Draft';
        objProINV.Org_ID__c = 1234;
        insert objProINV;
        
        Opportunity_Property__c objOP = new Opportunity_Property__c();
        objOP.cm_Opportunity__c = objOppor.Id;
        objOP.cm_Property_Inventory__c = objProINV.Id;
        insert objOP;

        Joint_Owner__c objJoint =  TestDataFactory.CreateJointOwner(objJointOwner.id,objOppor.id);
        insert objJoint;
        
        Service_Logs__c lg = new Service_Logs__c(Process_Name__c = 'EmaarBookingProcess Test Class');
    insert lg;
        
        test.startTest(); 

          Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl());
          EmaarBookingProcess.CreateParty_SalesOrder(objOppor.Id , lg.Id, 'Temo Dubai', 'Kiosk', new map<string,string>());
         // EmaarBookingProcess.SalesOrderPaymentType('-');
        test.stopTest(); 
        }
}