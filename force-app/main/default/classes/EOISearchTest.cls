@isTest
public class EOISearchTest {
    
    @testSetup static void setupData(){
        
        campaign cmp = TestDataFactory.createCampaigns();
        insert cmp;
        
        Account acc = TestDataFactory.createAccount();
        insert acc;
        
        Contact c = TestDataFactory.createContact();
        c.MobilePhone='677889';
        c.Phone='7378488';
        c.AccountId=acc.Id;
        insert c;
        
        Opportunity opp =  TestDataFactory.CreateOpportunity();
        opp.cm_Sales_Person__c=userInfo.getUserId();
        opp.AccountId=acc.Id;
        opp.ContactId=c.Id;
        opp.Type='Transfer';
        insert opp;
        
        ExpressofInterest__c eoi = TestDataFactory.createEOI();
        eoi.Campaign__c=cmp.id;
        eoi.Opportunity__c=opp.Id;
        eoi.Preferred_Communication__c='Email';
        eoi.Receipt_Number__c='12345';
        eoi.Queue_Type__c='Bulk';
        eoi.Payment_Method__c='Cash';
        insert eoi;
        
        ExpressofInterest__c eoi1 = TestDataFactory.createEOI();
        eoi1.Campaign__c=cmp.id;
        eoi1.Opportunity__c=opp.Id;
        eoi1.Preferred_Communication__c='Email';
        eoi1.Transfer_Number__c='12345';
        eoi1.Queue_Type__c='Bulk';
        eoi1.Payment_Method__c='Cash';
        insert eoi1;
  
        
    }
    
    static testmethod void mytest(){
     
       List<campaign> cmpLst = [select id from campaign LIMIT 1];
        List<ExpressofInterest__c> eoiLst = [select Preferred_Communication__c,Queue_Type__c from ExpressofInterest__c LIMIt 1];
        
        Test.startTest();
        EOISearch.getEOIdetails(cmpLst[0].Id,eoiLst[0].Preferred_Communication__c,eoiLst[0].Queue_Type__c);
        EOISearch.getEOIdetails(cmpLst[0].Id,'','');
        EOISearch.getEOIdetails('',eoiLst[0].Preferred_Communication__c,eoiLst[0].Queue_Type__c);
        EOISearch.getEOIdetails('',eoiLst[0].Preferred_Communication__c,'');
        EOISearch.getEOIdetails('','',eoiLst[0].Queue_Type__c);
        Test.stopTest();
        
    } 
    
     static testmethod void mytestService(){
     
          List<ExpressofInterest__c> eoiLst1 = [select Id from ExpressofInterest__c where Receipt_Number__c!=Null LIMIT 1];
       List<campaign> cmpLst = [select id from campaign LIMIT 1];
        List<ExpressofInterest__c> eoiLst = [select Id,Receipt_Number__c,Transfer_Number__c,Preferred_Communication__c,Queue_Type__c from ExpressofInterest__c where Id=:eoiLst1[0].Id LIMIt 1];
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new MockTestReceiptSerive());
        EOISearch.callReceiptService(eoiLst[0].Id);
        Test.stopTest();
        
    } 
    
  
    
     static testmethod void mytestService3(){
     
          List<ExpressofInterest__c> eoiLst1 = [select Id from ExpressofInterest__c where Receipt_Number__c!=Null LIMIT 1];
       List<campaign> cmpLst = [select id from campaign LIMIT 1];
        List<ExpressofInterest__c> eoiLst = [select Id,Receipt_Number__c,Transfer_Number__c,Preferred_Communication__c,Queue_Type__c from ExpressofInterest__c where Id=:eoiLst1[0].Id LIMIt 1];
        Test.startTest();
        EOISearch.callReceiptService(eoiLst[0].Id);
         Test.setMock(HttpCalloutMock.class, new MockTestReceiptSerive());
        Test.stopTest();
        
    } 
    
}