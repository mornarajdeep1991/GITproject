@isTest
public class MobileGenerateDocuments_Test {
    
    @isTest
    static void testMobileGenerateDocuments() {
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
        Opportunity_Property__c oppPro = TestDataFactory.CreateOpportunityProperty(opp.Id, inv.Id);
        insert oppPro;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/GenerateDocuments/salesoffer';
        req.addParameter('oppId', opp.Id);
        
        
        RestContext.request = req;
        RestContext.response = res;
        MobileGenerateDocuments.httpPost();
        
        test.stopTest();
    }
    
    @isTest
    static void testMobileGenerateDocuments2() {
        test.startTest();
        
        //create Opportunity
        Opportunity opp = TestDataFactory.createOpportunity();
        insert opp;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/GenerateDocuments/salesoffer';
        req.addParameter('oppId', opp.Id);
        
        
        RestContext.request = req;
        RestContext.response = res;
        MobileGenerateDocuments.httpPost();
        
        test.stopTest();
    }
}