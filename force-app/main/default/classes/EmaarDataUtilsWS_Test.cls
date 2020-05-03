@isTest
private class EmaarDataUtilsWS_Test {
  
  static testMethod void myUnitTest1() {
    // Implement test code

    Account objAccount = new Account();

    EmaarDataUtilsWS.upsertPersonAccount(new list<Account>{objAccount});
    EmaarDataUtilsWS.upsertBusinessAccount(new list<Account>{objAccount});

    objAccount = new Account();
    objAccount.Name = 'Test Account';
    insert objAccount;

    EmaarDataUtilsWS.upsertAccounts(new list<Account>{objAccount});

    EmaarDataUtilsWS.ContactWrapper objConWrapper = new EmaarDataUtilsWS.ContactWrapper();
    objConWrapper.lstContacts = new list<Contact>();
    Contact objCon = new Contact();
    objCon.AccountId = objAccount.Id;
    objCon.FirstName = 'Test';
    objCon.LastName = 'Emaar ';
    objConWrapper.lstContacts.add(objCon);
    objConWrapper.AccountId = objAccount.Id;

    EmaarDataUtilsWS.upsertContact(new list<EmaarDataUtilsWS.ContactWrapper>{objConWrapper});

    Property__c prop = new Property__c();
        prop.Property_Name__c = 'Test Property';
        prop.Property_ID__c='001';    
        prop.Vendor_name__c = 'Emaar';
    prop.Oracle_seq_number__c = 123;

    EmaarDataUtilsWS.upsertProperty(new list<Property__c>{prop});

    Location__c objLoc = TestDataFactory.CreateLocation('U');
    objLoc.Oracle_seq_number__c = 1234;

    EmaarDataUtilsWS.upsertLocation(new list<Location__c>{objLoc});

    Property_Inventory__c objProINV1 = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV1.recordTypeId =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        objProINV1.Instance__c = 'test';
        objProINV1.Instance__c = 'test';
        insert objProINV1;
        
        
        Opportunity objOppor = TestDataFactory.createOpportunity();
        insert objoppor;
        
        list<Opportunity_Property__c> lstOppProp = new list<Opportunity_Property__c>();

        Opportunity_Property__c OpporProp = TestDataFactory.CreateOpportunityProperty(objOppor.id,objProINV1.id);
        OpporProp.Sales_Order__c = '12345';
        OpporProp.Oracle_seq_number__c = 1234;
        lstOppProp.add(OpporProp);

        OpporProp = TestDataFactory.CreateOpportunityProperty(objOppor.id,objProINV1.id);
        OpporProp.Sales_Order__c = '12346';
        OpporProp.Oracle_seq_number__c = 123;
        lstOppProp.add(OpporProp);
        insert lstOppProp;
        lstOppProp[0].Sales_Order__c = '';
        EmaarDataUtilsWS.upsertOrders(lstOppProp);


        EmaarDataUtilsWS.upsertInventory(new list<Property_Inventory__c>{objProINV1});
  }
  
}