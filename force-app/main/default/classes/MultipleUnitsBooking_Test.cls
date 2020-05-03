@istest
public class MultipleUnitsBooking_Test {
    static testmethod void testcase1(){
      
        test.startTest();
        
        //string strEmailTemplateID =  [select id from EmailTemplate where DeveloperName='Auto_Debit_Email_Template'].id ;
        
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        insert objLoc;
        
        Property_Inventory__c objProINV = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV.Instance__c = '123456';
        insert objProINV;
        
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonMailingCountry ='United Arab Emirates';
        insert objAccount;
        
        Campaign objCampaign = TestDataFactory.CreateCampaign();
        insert objCampaign;

        
        Opportunity objOppor1 = TestDataFactory.createOpportunity();
        objOppor1.AccountId = objAccount.id;
        objOppor1.CampaignID = objCampaign.id;
        objOppor1.cm_Sales_Person__c = userinfo.getUserId();
        objOppor1.ownerId = userinfo.getUserId();
        //objOppor1.StageName = 'Generating Sales Offer';
        objOppor1.Is_Package_Unit__c = true;
        objOppor1.cm_status__c = 'Booked - Payment Pending';
       // objOppor1.Bundle_ID__c = '123456';
        insert objOppor1;
        
        objOppor1.Account = objAccount;
        
        Opportunity objOP = TestDataFactory.createOpportunity();
        objOP.AccountId = objAccount.id;
        objOP.CampaignID = objCampaign.id;
        objOP.ownerId = userinfo.getUserId();
        //objOP.cm_Opportunity__c = objOppor1.Id;
        //objOP.cm_Property_Inventory__c = objProINV.id;
        
        insert objOP;
        
        Opportunity_Property__c objOPp = new Opportunity_Property__c();
        objOPp.cm_Opportunity__c = objOppor1.Id;
        objOPp.cm_Property_Inventory__c = objProINV.id;
        objOPp.cm_Order_Status__c = 'Booked';
        objOPp.Is_Package_Unit__c = true;
        insert objOPp;
        
        Joint_Owner__c objJoint =  TestDataFactory.CreateJointOwner(objAccount.id,objOppor1.id);
        insert objJoint;
        list<id> setOppIds = new list<id>();
        setOppIds.add(objOppor1.id);
        setOppIds.add(objOP.id);
        
        list<Opportunity> lstOpp = new list<opportunity>();
        lstOpp.add(objOppor1);
        lstOpp.add(objOp);
        
        Document documentObj = new Document();
        documentObj.Body = Blob.valueOf('Some Document Text');
        documentObj.ContentType = 'application/pdf';
        documentObj.DeveloperName = 'my_document';
        documentObj.IsPublic = true;
        documentObj.Name = 'My Document';
        documentObj.FolderId = UserInfo.getUserId();
        insert documentObj;
        
        Mobile_Configurations__c objMC = new Mobile_Configurations__c();
        objMC.Name = 'Configuration';
        objMC.cm_Sales_Admin_Username__c = Userinfo.getUserName();
        objMC.Tempo_Campaign_ID__c = objCampaign.id;
        insert objMC;

        cm_Interim_Approval_Type__c objIAT = new cm_Interim_Approval_Type__c();
        objIAT.Name = 'Referral Special Approval';
        insert objIAT;
        
        cm_Interim_Approvals__c objIA = new cm_Interim_Approvals__c();
        objIA.cm_Opportunity__c = objOppor1.id;
        objIA.cm_Interim_Approval_Type__c = objIAT.Id;
        //objIA.cm_Decision__c = 'Decision Pending';
        objIA.Approval_Status__c = 'Rejected';
        insert objIA;
    
    
        multipleunitsBooking.PackageBookingCheck(string.valueOf(ObjAccount.id));
        multipleunitsBooking.CreateSpecialApprovals('2.22', lstOpp, 'selChequeOption', '5', 'DepositMethod', 'strSelCreditCardOption', 'strExceptionComments');
        multipleunitsBooking.paymentApproval(setOppIds, 'selPaymentMode', 'DepositMethod', 'selChequeOption', 'strSelCreditCardOption', '5', '2.22');
        //multipleunitsBooking.PaymentProcessCheck(string.valueOf(ObjAccount.id));
        
        multipleunitsBooking.createMultipleOpportunities(string.valueOf(objOppor1.id));
        multipleunitsBooking.Checkmultiple(string.valueOf(objOppor1.id));
        //multipleunitsBooking.paymentApproval(setOppIds, 'selPaymentMode', 'DepositMethod', 'selChequeOption', 'strSelCreditCardOption', '5', '2.22');
        multipleunitsBooking.CreatePOPTASK(setOppIDs);
        //multipleunitsBooking.CreateSpecialApprovals('2.22', lstOpp, 'selChequeOption', '5', 'DepositMethod', 'strSelCreditCardOption', 'strExceptionComments');
        //multipleunitsBooking.sendEmail(objOppor1,'submit');
        //multipleunitsBooking.CheckforPackageUnits(string.valueOf(objOppor1.id));
        //multipleunitsBooking.sendAutoDebitEmail(lstOpp, documentObj, strEmailTemplateID);
        //multipleunitsBooking.createPaymentRecord('2.22',lstOpp,'');
        
        Test.stopTest();
      }
      
      static testmethod void testcase2(){
        User U = [Select Id From User Where Id =:Userinfo.getUserId() limit 1];
       
        System.runAs(U){
            //InsertFutureEmailTemplate.insertTemplate();
            EmailTemplate validEmailTemplate = new EmailTemplate();
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'TestEmailTemplate2';
            validEmailTemplate.DeveloperName = 'Interim_Approval_Template_VF';
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.FolderId = UserInfo.getUserId();
            insert validEmailTemplate;
        }

        test.startTest();
        
        //string strEmailTemplateID =  [select id from EmailTemplate where DeveloperName='Auto_Debit_Email_Template'].id ;
        
        User objUser = TestDataFactory.CreateStandardUser();
        objUser.Approving_Manager__c = UserInfo.getUserId();

        //objUser.Approving_Manager__r.Email = 'abc@gmail.com';
        insert objUser;

        Location__c objLoc = TestDataFactory.CreateLocation('U');
        objLoc.Building__c = 'miami';
        insert objLoc;
        
        Property_Inventory__c objProINV = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV.Instance__c = '123456';
        insert objProINV;
        
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonMailingCountry ='United Arab Emirates';
        insert objAccount;

        
        Campaign objCampaign = TestDataFactory.CreateCampaign();
        insert objCampaign;

        
        Opportunity objOppor1 = TestDataFactory.createOpportunity();
        objOppor1.AccountId = objAccount.id;
        objOppor1.CampaignID = objCampaign.id;
        objOppor1.cm_Sales_Person__c = objUser.Id;
        //objOppor1.cm_Sales_Person__c = userinfo.getUserId();
        objOppor1.ownerId = userinfo.getUserId();
        insert objOppor1;
        
        objOppor1.Account = objAccount;
        
        Opportunity objOP = TestDataFactory.createOpportunity();
        objOP.AccountId = objAccount.id;
        objOP.CampaignID = objCampaign.id;
        objOP.ownerId = userinfo.getUserId();
        //objOP.cm_Opportunity__c = objOppor1.Id;
        //objOP.cm_Property_Inventory__c = objProINV.id;
        
        insert objOP;
        
        Opportunity_Property__c objOPp = new Opportunity_Property__c();
        objOPp.cm_Opportunity__c = objOppor1.Id;
        objOPp.cm_Property_Inventory__c = objProINV.id;
        objOPp.cm_Order_Status__c = 'Booked';
        objOPp.Is_Package_Unit__c = true;
        insert objOPp;
        
        Joint_Owner__c objJoint =  TestDataFactory.CreateJointOwner(objAccount.id,objOppor1.id);
        insert objJoint;
        list<id> setOppIds = new list<id>();
        setOppIds.add(objOppor1.id);
        setOppIds.add(objOP.id);
        
        list<Opportunity> lstOpp = new list<opportunity>();
        lstOpp.add(objOppor1);
        lstOpp.add(objOp);

        cm_Interim_Approval_Type__c objIAT = new cm_Interim_Approval_Type__c();
        objIAT.Name = 'Referral Special Approval';
        insert objIAT;
        
        cm_Interim_Approvals__c objIA = new cm_Interim_Approvals__c();
        objIA.cm_Opportunity__c = objOppor1.id;
        objIA.cm_Interim_Approval_Type__c = objIAT.Id;
        //objIA.cm_Decision__c = 'Decision Pending';
        objIA.Approval_Status__c = 'Rejected';
        insert objIA;
    
        
        Document documentObj = new Document();
        documentObj.Body = Blob.valueOf('Some Document Text');
        documentObj.ContentType = 'application/pdf';
        documentObj.DeveloperName = 'my_document';
        documentObj.IsPublic = true;
        documentObj.Name = 'My Document';
        documentObj.FolderId = UserInfo.getUserId();
        insert documentObj;
    
        Mobile_Configurations__c objMC = new Mobile_Configurations__c();
        objMC.Name = 'Configuration';
        objMC.cm_Sales_Admin_Username__c = Userinfo.getUserName();
        objMC.Tempo_Campaign_ID__c = objCampaign.id;
        insert objMC;

        
    
    
        //multipleunitsBooking.createMultipleOpportunities(string.valueOf(objOppor1.id));
        //multipleunitsBooking.Checkmultiple(string.valueOf(objOppor1.id));
        //multipleunitsBooking.PaymentProcessCheck(string.valueOf(ObjAccount.id));
        //multipleunitsBooking.PackageBookingCheck(string.valueOf(ObjAccount.id));
        //multipleunitsBooking.paymentApproval(setOppIds, 'selPaymentMode', 'DepositMethod', 'selChequeOption', 'strSelCreditCardOption', '5', '2.22');
      //multipleunitsBooking.CreatePOPTASK(setOppIDs);
        multipleunitsBooking.CreateSpecialApprovals('2.22', lstOpp, 'selChequeOption', '5', 'DepositMethod', 'strSelCreditCardOption', 'strExceptionComments');
        multipleunitsBooking.sendEmail(objOppor1,'submit');
        multipleunitsBooking.CheckforPackageUnits(string.valueOf(objOppor1.id));
        //multipleunitsBooking.sendAutoDebitEmail(lstOpp, documentObj, validEmailTemplate.Id);
        multipleunitsBooking.createPaymentRecord('2.22',lstOpp,'');
        multipleunitsBooking.paymentApproval_multiple(setOppIds, 'selPaymentMode', 'DepositMethod', 'selChequeOption', 'strSelCreditCardOption', '5', '2.22');
        Test.stopTest();
      }

    static testmethod void testcase3(){
        User U = [Select Id From User Where Id =:Userinfo.getUserId() limit 1];
       
        System.runAs(U){
        //InsertFutureEmailTemplate.insertTemplate();
        EmailTemplate validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'TestEmailTemplate';
        validEmailTemplate.DeveloperName = 'Auto_Debit_Email_Template';
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.FolderId = UserInfo.getUserId();
        insert validEmailTemplate;
        }

        Test.startTest();

        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonMailingCountry ='United Arab Emirates';
        //objAccount.PersonEmail = 'rahulseth567@gmail.com';
        insert objAccount;
       
        Campaign objCampaign = TestDataFactory.CreateCampaign();
        insert objCampaign;
      
        Opportunity objOppor1 = TestDataFactory.createOpportunity();
        objOppor1.AccountId = objAccount.id;
        objOppor1.CampaignID = objCampaign.id;
        objOppor1.cm_Sales_Person__c = userinfo.getUserId();
        objOppor1.ownerId = userinfo.getUserId();
        objOppor1.StageName = 'Generating Sales Offer';
        objOppor1.Is_Package_Unit__c = true;
        objOppor1.cm_status__c = 'Booked - Payment Pending';
        objOppor1.Bundle_ID__c = '123456';
        objOppor1.em_Contacted__c = false;
        insert objOppor1;
        
        
        objOppor1.Account = objAccount;
        
        Opportunity objOP = TestDataFactory.createOpportunity();
        objOP.AccountId = objAccount.id;
        objOP.CampaignID = objCampaign.id;
        objOP.ownerId = userinfo.getUserId();
        //objOP.cm_Opportunity__c = objOppor1.Id;
        //objOP.cm_Property_Inventory__c = objProINV.id;
        
        insert objOP;

        list<Opportunity> lstOpp = new list<opportunity>();
        lstOpp.add(objOppor1);
        lstOpp.add(objOp);
        
        Document documentObj = new Document();
        documentObj.Body = Blob.valueOf('Some Document Text');
        documentObj.ContentType = 'application/pdf';
        documentObj.DeveloperName = 'my_document';
        documentObj.IsPublic = true;
        documentObj.Name = 'My Document';
        documentObj.FolderId = UserInfo.getUserId();
        documentObj.Type = 'txt';
        insert documentObj;
        
        EmailTemplate objTemplate = [Select Id From EmailTemplate WHERE DeveloperName = 'Auto_Debit_Email_Template' ];

        multipleunitsBooking.PaymentProcessCheck(string.valueOf(ObjAccount.id));
        multipleunitsBooking.PackageBookingCheck(string.valueOf(ObjAccount.id));
        multipleunitsBooking.sendAutoDebitEmail(lstOpp, documentObj, objTemplate.Id);
        
        Test.stopTest();
        
    }

      
}