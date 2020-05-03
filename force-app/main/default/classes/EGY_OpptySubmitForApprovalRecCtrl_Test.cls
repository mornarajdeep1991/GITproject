@isTest 
public class EGY_OpptySubmitForApprovalRecCtrl_Test {
    static testMethod void doTest() {
        
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonEmail ='test@gmail.com';
        objAccount.PersonMobilePhone ='5678903456';
        insert objAccount;
        
        
        Campaign objCampaign = TestDataFactory.CreateCampaign();
        objCampaign.type='Launch';
        insert objCampaign;
        
        
        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount.id;
        objOppor.CampaignID = objCampaign.id;
        insert objOppor;
        
        Opportunity objOppor1 = TestDataFactory.createOpportunity();
        objOppor1.AccountId = null;
        objOppor1.CampaignID = null;
        objOppor1.Type_of_Property_Interest__c=null;
        insert objOppor1;
        
        test.starttest();
        EGY_OpptySubmitForApprovalRecirectCntrl oController = new EGY_OpptySubmitForApprovalRecirectCntrl();
        EGY_OpptySubmitForApprovalRecirectCntrl.getPendingSpecialApprovals(objOppor.id);
        EGY_OpptySubmitForApprovalRecirectCntrl.getOppInfo(objOppor.id);        
        EGY_OpptySubmitForApprovalRecirectCntrl.checkOpportunityPropertyStatus(objOppor.id);
        EGY_OpptySubmitForApprovalRecirectCntrl.validateOpportunityProperties(objOppor.id);
        EGY_OpptySubmitForApprovalRecirectCntrl.validateOpportunityFields(objOppor.id);
       
        
        test.stopTest();
    }
    static testMethod void doTestAgain() {
       
        Account objAccount1 = TestDataFactory.createPAccount();
        objAccount1.PersonEmail =null;
        objAccount1.PersonMobilePhone =null;
        insert objAccount1;
        
        Opportunity objOppor1 = TestDataFactory.createOpportunity();
        objOppor1.AccountId = objAccount1.id;
        insert objOppor1;
        
        
         Contact objContact = TestDataFactory.createContact();
        objContact.MobilePhone=null;
        objContact.Email=null;
        objContact.MailingStreet=null;
        insert objContact;
     
        test.starttest();
        EGY_OpptySubmitForApprovalRecirectCntrl oController = new EGY_OpptySubmitForApprovalRecirectCntrl();
        EGY_OpptySubmitForApprovalRecirectCntrl.getPendingSpecialApprovals(objOppor1.id);
        EGY_OpptySubmitForApprovalRecirectCntrl.getOppInfo(objOppor1.id);        
        EGY_OpptySubmitForApprovalRecirectCntrl.checkOpportunityPropertyStatus(objOppor1.id);
        EGY_OpptySubmitForApprovalRecirectCntrl.validateOpportunityProperties(objOppor1.id);
        EGY_OpptySubmitForApprovalRecirectCntrl.validateOpportunityFields(objOppor1.id);
       
        
        test.stopTest();
    }
    static testMethod void doTestThrice() {
       
        Account objAccount1 = TestDataFactory.createBAccount();
        insert objAccount1;
        
        Contact objContact = TestDataFactory.createContact();
        objContact.MobilePhone=null;
        objContact.Email=null;
        objContact.MailingStreet=null;
        insert objContact;
        
        Opportunity objOppor1 = TestDataFactory.createOpportunity();
        objOppor1.AccountId = objAccount1.id;
        objOppor1.cm_Contact__c=NULL;
        objOppor1.Type_of_Property_Interest__c=NULL;
        insert objOppor1;
        
        
     
        test.starttest();
        EGY_OpptySubmitForApprovalRecirectCntrl oController = new EGY_OpptySubmitForApprovalRecirectCntrl();
        EGY_OpptySubmitForApprovalRecirectCntrl.getPendingSpecialApprovals(objOppor1.id);
        EGY_OpptySubmitForApprovalRecirectCntrl.getOppInfo(objOppor1.id);        
        EGY_OpptySubmitForApprovalRecirectCntrl.checkOpportunityPropertyStatus(objOppor1.id);
        EGY_OpptySubmitForApprovalRecirectCntrl.validateOpportunityProperties(objOppor1.id);
        EGY_OpptySubmitForApprovalRecirectCntrl.validateOpportunityFields(objOppor1.id);
       
        
        test.stopTest();
    }
    static testMethod void doTestFour() {
       
        Account objAccount1 = TestDataFactory.createBAccount();
        insert objAccount1;
        
        Contact objContact = TestDataFactory.createContact();
        objContact.MobilePhone=null;
        objContact.Email=null;
        objContact.MailingStreet=null;
        insert objContact;
        
        Opportunity objOppor1 = TestDataFactory.createOpportunity();
        objOppor1.AccountId = objAccount1.id;
        objOppor1.cm_Contact__c=objContact.Id;
        objOppor1.Type_of_Property_Interest__c=NULL;
        insert objOppor1;
        
        
     
        test.starttest();
        EGY_OpptySubmitForApprovalRecirectCntrl oController = new EGY_OpptySubmitForApprovalRecirectCntrl();
        EGY_OpptySubmitForApprovalRecirectCntrl.getPendingSpecialApprovals(objOppor1.id);
        EGY_OpptySubmitForApprovalRecirectCntrl.getOppInfo(objOppor1.id);        
        EGY_OpptySubmitForApprovalRecirectCntrl.checkOpportunityPropertyStatus(objOppor1.id);
        EGY_OpptySubmitForApprovalRecirectCntrl.validateOpportunityProperties(objOppor1.id);
        EGY_OpptySubmitForApprovalRecirectCntrl.validateOpportunityFields(objOppor1.id);
       
        
        test.stopTest();
    }
}