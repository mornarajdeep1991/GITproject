@isTest
public class MobileLocationPaymentTerms_Test {
    
    @isTest
    static void testMobileLocationPaymentTerms() {
        test.startTest();
        
        //create Opportunity and Opportunity_Property__c
        Opportunity opp = TestDataFactory.createOpportunity();
        insert opp;
        Location__c Loc = TestDataFactory.CreateLocation('U');
        loc.Location_Code__c = 'LOC-123-456';
        insert Loc;
        Property_Inventory__c inv = TestDataFactory.CreatePropertyInventory(Loc.Id);
        inv.recordTypeId = Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Package').getRecordTypeId();
        inv.Location__c = Loc.Id;
        inv.Instance__c = 'test';
        inv.Property_Status__c = 'Available';
        inv.Property_Type__c = 'Sale';
        insert inv;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/LocationPaymentTerms';
        
        req.addParameter('pInventoryId', inv.Id);
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        MobileLocationPaymentTerms.httpGet();
        
        test.stopTest();
    }
    
}