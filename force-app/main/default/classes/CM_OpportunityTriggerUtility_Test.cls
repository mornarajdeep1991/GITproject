@isTest
private class CM_OpportunityTriggerUtility_Test {
    
    @testSetup
    static void testSetup() {
        //Insert a User
        User oUser = TestUtil.createUser(false);
        oUser.Assignment_Group_Active__c=True;
        insert oUser;

    }
    
    static testMethod void ReferralTest() {
        
        
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        //Insert a User
        user u =[select id,userroleid from user where id =: userinfo.getuserid()];
        User oUser;
        User oUser1;
        system.runAs(u){
        
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'Property Advisor');
        insert r;
        
        oUser = TestUtil.creatingUser(false,'Sales Admin');
        oUser.Assignment_Group_Active__c=True;
        oUser.Restrict_Booking__c = true;
        insert oUser;
        
        oUser1 = TestUtil.creatingUser(false,'Sales Admin');
        oUser1.Assignment_Group_Active__c=True;
        insert oUser1;
        
        
        u.UserRoleId = r.id;
        u.Restrict_Booking__c = true;
        update u;
        }
        
        
        cm_Integration_Settings__c isetting = new cm_Integration_Settings__c();
        isetting.name = 'ORACLE';
        isetting.cm_SOA_Key__c = 'test';
        isetting.cm_AES_Key__c = 'test';
        isetting.cm_UD_ID__c = 'test';
        insert isetting;
        
        
        
        
        
        
        Account objAcc = TestDataFactory.createPAccount();
        objAcc.Party_Id__c = '987654';
        objAcc.Supplier_ID__c = '898989';
        objAcc.Target__c = 10000;
        insert objAcc;
        
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.Party_Id__c = '987654';
        objaccount.cm_Mobile_Number__pc = '1234567890';
        objaccount.PersonMobilePhone = '1234567890';
        objAccount.Parent_Account__c = objAcc.id;
        insert objAccount;
        Campaign objCampaign = TestDataFactory.CreateCampaign();
        insert objCampaign;
        
        Mobile_Configurations__c mobileconfig = new Mobile_Configurations__c();
        mobileconfig.name = 'Configuration';
        mobileconfig.cm_Sales_Admin_Username__c = oUser.userName;
        mobileconfig.Tempo_Campaign_ID__c = objCampaign.id;
        insert mobileconfig;
        
        
        Opportunity objOpp = new Opportunity();
        objOpp.AccountId = objAccount.Id;
        objOpp.CampaignId = objCampaign.Id;
        objOpp.Name = 'Test Opportunity';
        objOpp.CloseDate = system.today().addDays(30);
        objOpp.StageName = 'Generating Sales Offer';
        objOpp.cm_Sales_Person__c = UserInfo.getUserId();
        objOpp.cm_Approval_Status__c = 'Payment Processing';
        objOpp.Property_Booked_Date__c = system.today();
        objOpp.Is_From_Online_Sales__c = true;
        objOpp.OwnerId = oUser.Id;
        objOpp.cm_Agency_Name__c = objAcc.Id;
        objOpp.Type_of_Property_Interest__c='Store';
        insert objOpp;
        
        objOpp.cm_Agency_Name__c = null;
        
        objOpp.StageName = 'Closed Won';
        objopp.Allow_Closed_Won__c = true;
        objOpp.Referral__c = objAccount.Id;
        objOpp.OwnerId = oUser1.Id;
        
        update objOpp;
        
        cm_Interim_Approval_Type__c objIAT = new cm_Interim_Approval_Type__c();
        objIAT.Name = 'Change of Payment Plan';
        objIAT.cm_Action_By__c = 'sales Executive';
        objIAT.cm_Approving_Authority_1__c = 'sales Manager';
        objIAT.name= 'Holding DP / LR';
        insert objIAT;
        
        cm_Interim_Approvals__c objIApp = new cm_Interim_Approvals__c();
        objIApp.cm_Interim_Approval_Type__c = objIAT.id;
        objIApp.cm_Opportunity__c = objOpp.id;
        objIApp.cm_Selected_Units__c = 'test';
        objIApp.Next_Approver__c = oUser.Id;
        insert objIApp;
        objIApp.Next_Approver__c = oUser.Id;
        objIApp.Assign_To__c = oUser.Id;
        objIApp.First_Level_Approver__c = oUser.Id;
        objIApp.Second_Level_Approver__c = oUser.Id;
        objIApp.Third_Level_Approver__c = oUser.Id;
        objIApp.Opportunity_Owner__c = oUser.Id; 
        system.runas(u){
            update objIApp;
            objOpp.OwnerId = oUser.Id;
            system.debug('***************************');
            update objOpp;
            objopp.stageName = 'Closed Lost';
            update objOpp;
        }
    }
    
    static testMethod void ReferralTest1() {
        
        
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        //Insert a User
        User oUser = TestUtil.creatingUser(false,'Sales Admin');
        oUser.Assignment_Group_Active__c=True;
        oUser.Restrict_Booking__c = true;
        insert oUser;
        
        User oUser1 = TestUtil.creatingUser(false,'Sales Admin');
        oUser1.Assignment_Group_Active__c=True;
        oUser1.Restrict_Booking__c = true;
        insert oUser1;
        
        cm_Integration_Settings__c isetting = new cm_Integration_Settings__c();
        isetting.name = 'ORACLE';
        isetting.cm_SOA_Key__c = 'test';
        isetting.cm_AES_Key__c = 'test';
        isetting.cm_UD_ID__c = 'test';
        insert isetting;
        
        
        
        
        
        
        Account objAcc = TestDataFactory.createBAccount();
        objAcc.Party_Id__c = '987654';
        objAcc.Supplier_ID__c = '898989';
        objAcc.Target__c = 10000;
        insert objAcc;
        
        Account objAccount = TestDataFactory.createBAccount();
        objAccount.Party_Id__c = '987654';
        objAccount.Parent_Account__c = objAcc.id;
        insert objAccount;
        
        contact con  = TestDataFactory.createContact();
        con.cm_Mobile_Number__c = '34567890';
        insert con;
        
        Campaign objCampaign = TestDataFactory.CreateCampaign();
        insert objCampaign;
        
        Mobile_Configurations__c mobileconfig = new Mobile_Configurations__c();
        mobileconfig.name = 'Configuration';
        mobileconfig.cm_Sales_Admin_Username__c = oUser.userName;
        mobileconfig.Tempo_Campaign_ID__c = objCampaign.id;
        insert mobileconfig;
        
        
        Opportunity objOpp = new Opportunity();
        objOpp.AccountId = objAccount.Id;
        objOpp.CampaignId = objCampaign.Id;
        objOpp.Name = 'Test Opportunity';
        objOpp.cm_contact__c = con.id;
        objOpp.CloseDate = system.today().addDays(30);
        objOpp.StageName = 'Generating Sales Offer';
        objOpp.cm_Sales_Person__c = UserInfo.getUserId();
        objOpp.cm_Approval_Status__c = 'Payment Processing';
        objOpp.Property_Booked_Date__c = system.today();
        objOpp.Is_From_Online_Sales__c = true;
        objOpp.OwnerId = oUser.Id;
        objOpp.cm_Agency_Name__c = objAcc.Id;
        objOpp.Type_of_Property_Interest__c='Store';
        insert objOpp;
        
        objOpp.cm_Agency_Name__c = null;
        
        objOpp.StageName = 'Closed Won';
        objopp.Allow_Closed_Won__c = true;
        objOpp.Referral__c = objAccount.Id;
        objOpp.OwnerId = oUser1.Id;
        objOpp.cm_Approval_Status__c = 'Pending with Admin';
        update objOpp;
        
        cm_OpportunityTriggerUtility.isSyncCall = false;
        objOpp.OwnerId = oUser.Id;
        objOpp.cm_Approval_Status__c = 'Approved by Admin';
        system.debug('***************************');
        update objOpp;
        objopp.stageName = 'Closed Lost';
        update objOpp;
    }

    
}