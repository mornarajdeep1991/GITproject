@isTest
private class CampaignServiceTest {
    
    static testmethod void mytest(){
        
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
        
        ExpressofInterest__c eoi1 = TestDataFactory.createEOI();
        eoi1.Campaign__c=cmp.id;
        eoi1.Opportunity__c=opp.Id;
        eoi1.Preferred_Communication__c='Email';
        eoi1.Queue_Type__c='Villa';
        eoi1.Type_of_Villa__c='Town';
        eoi1.Payment_Confirmation__c='Confirmed';
        eoi1.Payment_Method__c='Cash';
        insert eoi1;
            
        ExpressofInterest__c eoi2 = TestDataFactory.createEOI();
        eoi2.Campaign__c=cmp.id;
        eoi2.Opportunity__c=opp.Id;
        eoi2.Preferred_Communication__c='Email';
        eoi2.Queue_Type__c='Apartment';
        eoi2.Payment_Confirmation__c='Confirmed';
        eoi2.Payment_Method__c='Cash';
        insert eoi2;
        
        Campaign cmp1 = new Campaign();
        cmp1.Id=cmp.Id;
        cmp1.Status='Completed';
        update cmp1;
        
        
    }
    
    static testmethod void mytest2(){
        
          Campaign cmp = TestDataFactory.createCampaigns();
        cmp.Status='In Progress';
        insert cmp;
        
        delete cmp;
        
        
    }

}