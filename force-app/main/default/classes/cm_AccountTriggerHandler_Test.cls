@isTest
public class cm_AccountTriggerHandler_Test{
    @isTest
    static void generalTest() {

        Campaign objCampaign = TestDataFactory.CreateCampaign();
        insert objCampaign;

        Mobile_Configurations__c objMC = new Mobile_Configurations__c();
        objMC.Name = 'Configuration';
        objMC.cm_Sales_Admin_Username__c = Userinfo.getUserName();
        objMC.Tempo_Campaign_ID__c = objCampaign.id;
        insert objMC;

        cm_Integration_Settings__c custSet = new cm_Integration_Settings__c(Name='ORACLE',cm_SOA_key__c='SADA',cm_AES_Key__c='mypassword123456',cm_UD_ID__c='DAA',cm_Username__c='ASDA');
        insert custSet;

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
        objAccount.cm_Phone_Country_Code__c = 'India: 0091';

        objAccount.personMobilePhone = '521234567';
        objAccount.cm_Mobile_Country_Code__pc = 'India: 0091';
        objAccount.Emirate__c = 'Dubai';
        objAccount.BillingCountry = 'India';
        objAccount.ShippingCountry = 'India';
        objAccount.cm_Country_Of_Incorporation__c = 'India';
        objAccount.cm_Trade_License_Expiry_Date__c = system.today().addYears(2);
        objAccount.Party_Id__c = '12345';
        objAccount.Parent_Account__c = null;
        insert objAccount;

        objAccount.Party_Id__c = '123456';
        objAccount.BillingStreet = 'EBP';
        objAccount.BillingCountry = 'United States';
        objAccount.BillingCity = 'NY';
        objAccount.BillingPostalCode = '123456' ;
        objAccount.cm_P_O_Box__c = '12345';
    
        objAccount.Phone = '12345678';
        objAccount.cm_Phone_Country_Code__c = 'India: 0091';
        objAccount.ShippingStreet = 'EBP';
        objAccount.ShippingCountry = 'United States';
        objAccount.ShippingCity = 'NY';
        objAccount.ShippingPostalCode = '123456' ;
        objAccount.Shipping_P_O_Box__c = '12345';
        

        objAccount.cm_Date_of_Incorporation__c = system.today().addYears(-1);
        objAccount.PersonMobilePhone = '09876543234';
        objAccount.City_of_Incorporation__c = 'Hyderabad';
        objAccount.cm_Nationality__pc = 'India';
        objAccount.cm_Country_Of_Incorporation__c = '';
        objAccount.Salutation = 'Mr.';
        objAccount.PersonEmail = 'test@2.a';
        objAccount.cm_Trade_License_Expiry_Date__c = null;
        objAccount.cm_Passport_Expiry_Date__pc = system.today().addDays(4);
        //try{
        update objAccount;
        //}catch(Exception ex){}

    }
    
    @isTest
    static void agencyAccountTest() {
    EmaarWebserviceUtils.isUpdated = false;
        Campaign objCampaign = TestDataFactory.CreateCampaign();
        insert objCampaign;

        Mobile_Configurations__c objMC = new Mobile_Configurations__c();
        objMC.Name = 'Configuration';
        objMC.cm_Sales_Admin_Username__c = Userinfo.getUserName();
        objMC.Tempo_Campaign_ID__c = objCampaign.id;
        insert objMC;

        cm_Integration_Settings__c custSet = new cm_Integration_Settings__c(Name='ORACLE',cm_SOA_key__c='SADA',cm_AES_Key__c='mypassword123456',cm_UD_ID__c='DAA',cm_Username__c='ASDA');
        insert custSet;

        Account objAccount = TestDataFactory.createBAccount();
        
        Id RecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker Account').getRecordTypeId();
        
        objAccount.BillingCity = 'Dubai';
        objAccount.BillingCountry = 'United Arab Emirates';
        objAccount.BillingStreet = 'Down Town Area';
        objAccount.cm_Date_of_Incorporation__c = system.today().addYears(-1);
        objAccount.Shipping_Mobile_Number__c = '521234567';
        objAccount.Shipping_Mobile_Country_Code__c = 'India: 0091';
        objAccount.cm_Phone_Country_Code__c = 'India: 0091';

        objAccount.Emirate__c = 'Dubai';
        objAccount.BillingCountry = 'India';
        objAccount.ShippingCountry = 'India';
        objAccount.cm_Country_Of_Incorporation__c = 'India';
        objAccount.cm_Trade_License_Expiry_Date__c = system.today().addYears(2);
        objAccount.RecordTypeId = RecordTypeId;
        objAccount.cm_Is_Agent__c = true;
        objAccount.Supplier_ID__c = '123456';
        insert objAccount;
        
        objAccount.BillingStreet = 'EBP';
        objAccount.BillingCountry = 'United States';
        objAccount.BillingCity = 'NY';
        objAccount.BillingPostalCode = '123456' ;
        objAccount.cm_P_O_Box__c = '12345';
        objAccount.Shipping_Country__c = 'United States';
        objAccount.ShippingState = 'California';

        objAccount.ShippingStreet = 'EBP';
        objAccount.ShippingCountry = 'United States';
        objAccount.ShippingCity = 'NY';
        objAccount.ShippingPostalCode = '123456' ;
        objAccount.Shipping_P_O_Box__c = '12345';

        objAccount.cm_Date_of_Incorporation__c = system.today().addYears(-1);
        objAccount.City_of_Incorporation__c = 'Hyderabad';
        objAccount.cm_Country_Of_Incorporation__c = '';
        objAccount.cm_Trade_License_Expiry_Date__c = null;
        //try{
        update objAccount;
        
        Contact objContact = new Contact();
        objCOntact.FirstName = 'Test';
        objCOntact.LastName = 'Class';
        objCOntact.Email = 'ravi@em.ae';
        objCOntact.AccountId = objAccount.Id;
        objCOntact.Sys_Authorised_Officer__c = true;
        objCOntact.Sys_Is_Admin__c = true;
        insert objCOntact;
        
        map<Id,Account> mapOld = new map<Id,Account>();
        mapOld.put(objAccount.Id,objAccount);
        
        objAccount.Is_Frozen__c = true;
        map<id,id> accountparentMap = new map<id,id>();
        accountparentMap.put(objAccount.Id,objAccount.Id);
        //}catch(Exception ex){}

    }
    
}