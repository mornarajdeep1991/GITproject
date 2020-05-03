@isTest
public class ExpressofInterestServiceTest {

        @testsetup static void extest(){
        Account acc = TestDataFactory.createAccount();
        insert acc;
        
        Contact c = TestDataFactory.createContact();
        c.MobilePhone='677889';
        c.Phone='7378488';
        c.AccountId=acc.Id;
        insert c;
        
        Campaign cmp = TestDataFactory.createCampaigns();
        cmp.Status='In Progress';
        insert cmp;
        
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
        eoi.Queue_Type__c='Bulk';
        eoi.Bulk_number_of_Apartments__c=3;
        eoi.Bulk_number_of_Villa__c=2;
        eoi.Payment_Confirmation__c='Confirmed';
        eoi.Payment_Method__c='Cash';
        insert eoi;
        
              
    }
    
     static testmethod void updateEXP(){
        
     List<ExpressofInterest__c> explst = [select id,Receipt_Number__c from ExpressofInterest__c LIMIT 1];
          explst[0].Receipt_Number__c='12345';
        update explst;
    }
    
     static testmethod void deleteEXP(){
        
     List<ExpressofInterest__c> explst = [select id,Receipt_Number__c from ExpressofInterest__c LIMIT 1];
         
        delete explst;
   
        
    }
}