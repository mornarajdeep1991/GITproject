@isTest
public class MobileOpportunitySubmitApproval_Test {
    
    @isTest
    static void testOneGetMobApproval() {
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
        req.requestURI = '/services/apexrest/SubmitApproval';
        
        req.addParameter('oppId', inv.Id);
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        MobileOpportunitySubmitApproval.httpGet();
        
        req.addParameter('oppId', opp.Id);
        MobileOpportunitySubmitApproval.httpGet();
        /*
Account Acc = TestDataFactory.createBAccount();
Acc.BillingCity = 'Dubai';
Acc.BillingCountry = 'United Arab Emirates';
Acc.BillingStreet = 'Down Town Area';
Acc.cm_Date_of_Incorporation__c = system.today().addYears(-3);
Acc.cm_Country_Of_Incorporation__c = 'United Arab Emirates';
Acc.cm_Trade_License_Expiry_Date__c = system.today().addYears(2);
Acc.cm_Trade_License_Number__c = 'CL1234';
Acc.Party_Type__c = 'ORGANIZATION';
insert Acc;
*/
        Lead newLead = new Lead(LastName = 'Fry', Company='Fry And Sons', Property_Advisor__c = UserInfo.getUserId());
        insert newLead;
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(newLead.Id);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        Contact cont = new Contact();
        //cont.AccountId = Acc.Id;
        cont.AccountId = lcr.AccountId;
        cont.FirstName = 'RB'; 
        cont.LastName = 'Dubai - CH';
        cont.Email = 'test@emaarq.ae.test';
        cont.cm_Birthdate__c = system.today().addYears(-28);
        cont.cm_Passport_Number__c = 'IND1235q';
        cont.cm_Resident_Of_UAE__c = true;
        cont.cm_National_ID_No__c = 'UAE2010569q';
        cont.MobilePhone = '4567890';
        cont.Email = 'test@test.com';
        cont.MailingStreet = 'test St';
        insert cont;
        
        opp.cm_Contact__c = cont.Id;
        update opp;
        MobileOpportunitySubmitApproval.httpGet();
        
        
        oppPro.Sales_Order__c = 'uniqueExternalKey';
        update oppPro;
        MobileOpportunitySubmitApproval.httpGet();
        
        test.stopTest();
    }
    
    @isTest
    static void testTwoGetMobApproval() {
        test.startTest();
        
        //create Opportunity and Opportunity_Property__c
        /*
Account Acc = TestDataFactory.createBAccount();
Acc.BillingCity = 'Dubai';
Acc.BillingCountry = 'United Arab Emirates';
Acc.BillingStreet = 'Down Town Area';
Acc.cm_Date_of_Incorporation__c = system.today().addYears(-3);
Acc.cm_Country_Of_Incorporation__c = 'United Arab Emirates';
Acc.cm_Trade_License_Expiry_Date__c = system.today().addYears(2);
Acc.cm_Trade_License_Number__c = 'CL1234';
Acc.Party_Type__c = 'ORGANIZATION';
insert Acc;
*/
        
        Lead newLead = new Lead(LastName = 'Fry', Company='Fry And Sons', Property_Advisor__c = UserInfo.getUserId());
        insert newLead;
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(newLead.Id);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        Contact cont = new Contact();
        //cont.AccountId = Acc.Id;
        cont.AccountId = lcr.AccountId;
        cont.FirstName = 'RB'; 
        cont.LastName = 'Dubai - CH';
        cont.Email = 'test@emaarq.ae.test';
        cont.cm_Birthdate__c = system.today().addYears(-28);
        cont.cm_Passport_Number__c = 'IND1235q';
        cont.cm_Resident_Of_UAE__c = true;
        cont.cm_National_ID_No__c = 'UAE2010569q';
        cont.MobilePhone = '4567890';
        cont.Email = 'test@test.com';
        cont.MailingStreet = 'test St';
        insert cont;
        Opportunity opp = TestDataFactory.createOpportunity();
        opp.cm_Contact__c = cont.Id;
        //opp.AccountId = Acc.Id;
        opp.AccountId = lcr.AccountId;
        opp.Type_of_Property_Interest__c = 'Apartment';
        insert opp;
        Location__c Loc = TestDataFactory.CreateLocation('U');
        loc.Location_Code__c = 'LOC-123-456';
        insert Loc;
        Property_Inventory__c inv = TestDataFactory.CreatePropertyInventory(Loc.Id);
        //inv.recordTypeId = Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Manager').getRecordTypeId();
        inv.Location__c = Loc.Id;
        inv.Instance__c = 'test';
        inv.Property_Status__c = 'Available';
        inv.Property_Type__c = 'Sale';
        insert inv;
        Opportunity_Property__c oppPro = TestDataFactory.CreateOpportunityProperty(opp.Id, inv.Id);
        insert oppPro;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/SubmitApproval';
        req.addParameter('oppId', opp.Id);
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        MobileOpportunitySubmitApproval.httpGet();
        
        
        oppPro.Campaign_Map_Id__c = 'testCampaign';
        oppPro.Campaign_Id__c = 'testCampaignId';
        update oppPro;
        MobileOpportunitySubmitApproval.httpGet();
        
        inv.Property_Type__c = 'Blocked';
        update inv;
        MobileOpportunitySubmitApproval.httpGet();
        test.stopTest();
    }
    
    @isTest
    static void testPostMobApproval() {
        test.startTest();
        
        /*
Account Acc = TestDataFactory.createBAccount();
Acc.BillingCity = 'Dubai';
Acc.BillingCountry = 'United Arab Emirates';
Acc.BillingStreet = 'Down Town Area';
Acc.cm_Date_of_Incorporation__c = system.today().addYears(-3);
Acc.cm_Country_Of_Incorporation__c = 'United Arab Emirates';
Acc.cm_Trade_License_Expiry_Date__c = system.today().addYears(2);
Acc.cm_Trade_License_Number__c = 'CL1234';
Acc.Party_Type__c = 'ORGANIZATION';
insert Acc;
*/
        Lead newLead = new Lead(LastName = 'Fry', Company='Fry And Sons', Property_Advisor__c = UserInfo.getUserId());
        insert newLead;
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(newLead.Id);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        Contact cont = new Contact();
        //cont.AccountId = Acc.Id;
        cont.AccountId = lcr.AccountId;
        cont.FirstName = 'RB'; 
        cont.LastName = 'Dubai - CH';
        cont.Email = 'test@emaarq.ae.test';
        cont.cm_Birthdate__c = system.today().addYears(-28);
        cont.cm_Passport_Number__c = 'IND1235q';
        cont.cm_Resident_Of_UAE__c = true;
        cont.cm_National_ID_No__c = 'UAE2010569q';
        cont.MobilePhone = '4567890';
        cont.Email = 'test@test.com';
        cont.MailingStreet = 'test St';
        insert cont;
        Opportunity opp = TestDataFactory.createOpportunity();
        opp.cm_Contact__c = cont.Id;
        //opp.AccountId = Acc.Id;
        opp.AccountId = lcr.AccountId;
        opp.Type_of_Property_Interest__c = 'Apartment';
        insert opp;
        
        //test post method
        MobileOpportunitySubmitApproval.SubmitForApprovalPostRequestDTO postReq = new MobileOpportunitySubmitApproval.SubmitForApprovalPostRequestDTO();
        //postReq.accountInfo = Acc;
        postReq.accountInfo = new Account(Id = lcr.AccountId);
        postReq.contactInfo = cont;
        postReq.isPersonAccount = False;
        postReq.opportunityId = opp.Id;
        postReq.paymentMode = '';
        postReq.depositMethod = '';
        postReq.creditCardOption = '';
        postReq.amount = 900;
        postReq.exc = False;
        postReq.exceptionComments = '';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        req.requestURI = '/services/apexrest/SubmitApproval/UpdateAccountContact';
        MobileOpportunitySubmitApproval.httpPost(postReq);
        
        req.requestURI = '/services/apexrest/SubmitApproval/CreateSalesOrder';
        MobileOpportunitySubmitApproval.httpPost(postReq);
        
        req.requestURI = '/services/apexrest/SubmitApproval/submitOpportunity';
        MobileOpportunitySubmitApproval.httpPost(postReq);
        
        req.requestURI = '/services/apexrest/SubmitApproval/cancelBooking';
        MobileOpportunitySubmitApproval.httpPost(postReq);
        
        test.stopTest();
    }
    
}