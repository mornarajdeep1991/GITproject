@isTest
public class MobileAppConvertLead_Test {
    
    @isTest
    static void testMobileAppConvertLead() {
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
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ConvertLead/' + lead.Id; 
        
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        
        MobileAppConvertLead.httpGet();
        
        MobileAppConvertLead.httpGet();
        test.stopTest();
    }
}