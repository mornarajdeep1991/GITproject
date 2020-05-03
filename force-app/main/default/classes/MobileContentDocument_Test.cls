@isTest
public class MobileContentDocument_Test {
    
    @isTest
    static void testMobileContentDocument() {
        test.startTest();
        
        //create lead
        Lead lead = TestDataFactory.CreateLead();
        lead.Company = 'Test Class';
        lead.FirstName = 'test'; 
        lead.LastName = 'one';
        lead.LeadSource = 'Self Generated';
        lead.Email = 'test@one.com';
        lead.Phone = '019286';
        lead.MobilePhone = '234567890';
        lead.Reason_for_Visit__c = 'Agent';
        lead.Property_Advisor__c = UserInfo.getUserId();
        insert lead;        
        
        ContentVersion contentVersionInsert = new ContentVersion(Title = 'Test', PathOnClient = 'Test.jpg', VersionData = Blob.valueOf('Test Content Data'), IsMajorVersion = true);
        insert contentVersionInsert;
        List<ContentDocument> documents = [SELECT Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = lead.id;
        contentlink.ShareType = 'V';
        contentlink.LinkedEntityId = lead.Id; 
        contentlink.ContentDocumentId = documents[0].Id;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/MobileContentDocument/'; 
        req.addParameter('relatedId', lead.Id);
        
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        MobileContentDocument.httpGet();
        test.stopTest();
    }
}