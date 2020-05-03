@isTest
private class GenerateEmaarReciept_Test {
  private static testMethod void test() {
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
        objContact.LastName = 'Dubai - CH';
        objContact.Email = 'test@emaarq.ae.test';
        objContact.cm_Birthdate__c = system.today().addYears(-28);
        objContact.cm_Passport_Number__c = 'IND1235q';
        objContact.cm_Resident_Of_UAE__c = true;
        objContact.cm_National_ID_No__c = 'UAE2010569q';
        insert objContact;
        
        Campaign objCampaign = TestDataFactory.CreateCampaign();
        insert objCampaign;

        
        Opportunity objOppor1 = TestDataFactory.createOpportunity();
        objOppor1.AccountId = objAccount2.id;
        objOppor1.CampaignID = objCampaign.id;
        objOppor1.cm_Sales_Person__c = Userinfo.getUserId();        
        objOppor1.cm_Contact__c = objContact.Id;
        insert objOppor1;
        
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        objLoc.Location_Code__c = '14567';
        insert objLoc;
        
        Property_Inventory__c objProINV = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV.Instance__c = '123456';
        insert objProINV;
        
        Opportunity_Property__c objOP = new Opportunity_Property__c();
        objOP.cm_Opportunity__c = objOppor1.Id;
        objOP.cm_Property_Inventory__c = objProINV.Id;
        objOP.Sales_Order__c = 'Test Sales Order';
        insert objOP;
        
        Reciepts__c objReceipt = new Reciepts__c ();
        objReceipt.GL_Date__c = system.today();
        objReceipt.Reciept_Date__c = system.today();
        objReceipt.cm_Opportunity_Property__c = objOP.Id;
        objreceipt.Opportunity__c = objOppor1.id;
        insert objReceipt;
        
        apexpages.currentPage().getParameters().put('id',objOP.id);
        apexpages.currentPage().getParameters().put('recid',objReceipt.id);
        GenerateEmaarReciept obj = new GenerateEmaarReciept();
        obj.prepareImageURL();
        obj.GetReciept();
        
        
  }
}