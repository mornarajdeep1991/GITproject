@isTest
private class UpdateProcessWorkItemsQueueable_Test {

  private static testMethod void test() {
        //RestRequest req = new RestRequest();
        //req.requestURI = '/services/apexrest/abc/xyz/';
        
        // Insert an account
        list<ProcessInstanceWorkItem> lstItems = new list<ProcessInstanceWorkItem>();
        UpdateProcessWorkItemsQueueable objQJo = new UpdateProcessWorkItemsQueueable(lstItems);

        User user1 = TestDataFactory.CreateStandardUser();
        
        // TO DO: implement unit test
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
        
        Account objAgency = TestDataFactory.createBAccount();
        objAgency.BillingCity = 'Dubai';
        objAgency.BillingCountry = 'United Arab Emirates';
        objAgency.BillingStreet = 'Down Town Area';
        objAgency.cm_Date_of_Incorporation__c = system.today().addYears(-3);
        objAgency.cm_Country_Of_Incorporation__c = 'United Arab Emirates';
        objAgency.cm_Trade_License_Expiry_Date__c = system.today().addYears(2);
        objAgency.cm_Trade_License_Number__c = 'CL1234';
        objAgency.cm_Phone_Country_Code__c='India: 0091';
        objAgency.cm_Is_Agent__c = true;
        insert objAgency;
        
        Campaign objCampaign = TestDataFactory.CreateCampaign();
        insert objCampaign;
        
        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount.id;
        objOppor.CampaignID = objCampaign.id;
        objOppor.cm_Sales_Person__c = Userinfo.getUserId();
        objOppor.cm_Agency_Name__c =    objAgency.Id;  
        insert objOppor;
        
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        objLoc.Location_Code__c = '14567';
        insert objLoc;
        
        Property_Inventory__c objProINV = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV.Instance__c = '123456';
        insert objProINV;
        
        Opportunity_Property__c objOP = new Opportunity_Property__c();
        objOP.cm_Opportunity__c = objOppor.Id;
        objOP.cm_Property_Inventory__c = objProINV.Id;
        objOP.Sales_Order__c = '1234';
        objOP.Booking_Price__c = 123456;
        objOP.cm_Order_Status__c = 'SOLD';
        objOP.cm_Order_Date__c = system.today();
        insert objOP;
    
      cm_Interim_Approval_Type__c objIAT = new cm_Interim_Approval_Type__c();
        objIAT.Name = 'LR Waiver';
        insert objIAT;
   
       cm_Interim_Approvals__c objIA = new cm_Interim_Approvals__c();
        objIA.cm_Opportunity__c = objOppor.id;
        objIA.cm_Interim_Approval_Type__c = objIAT.Id;
        objIA.cm_Decision__c = 'Decision Pending';
        objIA.Next_Approver__c = Label.Finance_User;
        objIA.First_Level_Approver__c = Label.Finance_User;
        objIA.Assign_To__c = Label.Finance_User;
        
        insert objIA; 
        objIA.Approval_Status__c = 'Submitted for Approval';  
        update objIA;
        
        Test.startTest();
        // Create an approval request for the account
        try {
          Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
          req1.setComments('Submitting request for approval.');
          req1.setObjectId(objIA.id);
          
          // Submit on behalf of a specific submitter
          req1.setSubmitterId(user1.Id); 
          
          // Submit the record to specific process and skip the criteria evaluation
          req1.setProcessDefinitionNameOrId('LR_Waiver_Special_Approval_Process');
          req1.setSkipEntryCriteria(true);
          
          // Submit the approval request for the account
          Approval.ProcessResult result = Approval.process(req1);
          
          for(ProcessInstanceWorkItem objItem : [select Id, ActorId from ProcessInstanceWorkitem]) {
              lstItems.add(new ProcessInstanceWorkItem(Id = objItem.Id, ActorId = objItem.ActorId));
          }
         
        UpdateProcessWorkItemsQueueable objQJob = new UpdateProcessWorkItemsQueueable(lstItems);
        system.enqueueJob(objQJob);
      
        } catch(Exception e) {
             
         Boolean error = false;
       if (Test.isRunningTest()) { 
        error  = false; 
        } if (error) { 
  
}   
        UpdateProcessWorkItemsQueueable objQ = new UpdateProcessWorkItemsQueueable(lstItems);
        system.enqueueJob(objQ);
          
        }
    Test.stopTest();
        
  }

}