/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed   
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SpecialApprovalTigger_Test {
  
  @isTest
    static void myUnitTest() {
        
        /*Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,isActive = true,
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_1@testorg.com');
        insert u;*/
        
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonMailingCountry ='United Arab Emirates';
        insert objAccount;
        
        
        
        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount.id;
        insert objOppor;
        
        cm_Administrator_Settings__c custSetting = new cm_Administrator_Settings__c(Payment_Due_Minutes__c=30,Admin_User__c=userinfo.getUserId(),name='ADMIN',cm_booking_timer__c =20);
        INSERT custSetting;
        
        list<cm_Interim_Approval_Type__c> lstTypes = new list<cm_Interim_Approval_Type__c>();
        list<cm_Interim_Approvals__c> lstApprovels = new list<cm_Interim_Approvals__c>(); 
        
        map<Id,string> mapTypeName = new map<Id,string>();
        
        cm_Interim_Approval_Type__c type1 = new cm_Interim_Approval_Type__c(is_active__c=true,cm_Approving_Authority_1__c = 'Sales Person',cm_Mandatory__c = true,Name = 'Cash - Less than 20k',cm_Action_By__c = 'Property Advisor');
        lstTypes.add(type1);
        
        type1 = new cm_Interim_Approval_Type__c(is_active__c=true,cm_Approving_Authority_1__c = 'Sales Manager',cm_Mandatory__c = true,Name = 'Holding DP / LR',cm_Action_By__c = 'Property Advisor');
        lstTypes.add(type1);
        
        type1 = new cm_Interim_Approval_Type__c(is_active__c=true,cm_Approving_Authority_1__c = 'Sales Person',cm_Mandatory__c = true,Name = 'CIL Exception',cm_Action_By__c = 'Property Advisor');
        lstTypes.add(type1);
        
        type1 = new cm_Interim_Approval_Type__c(is_active__c=true,cm_Approving_Authority_1__c = 'Sales Manager',cm_Mandatory__c = true,Name = 'LR Waiver',cm_Action_By__c = 'Property Advisor');
        lstTypes.add(type1);
        
        insert lstTypes;
        
        cm_Interim_Approvals__c IA2;
        
        for(cm_Interim_Approval_Type__c objType : lstTypes){
          IA2 = new cm_Interim_Approvals__c(Next_Approver__c=UserInfo.getUserId(),
                            Date_To_Hold__c = system.today(),
                                                        cm_Decision__c = 'Decision Pending', 
                                                        cm_Interim_Approval_Type__c = objType.Id,
                                                        cm_Opportunity__c = objOppor.id,
                                                         cm_Selected_Units_New__c = 'EH Land Sale-P-E177',
                                                         LR_Wavier__c = '2'
                                                        );
      if(objType.Name == 'Holding DP / LR'){
        IA2.Is_Automated__c = true;
      }
      if(objType.Name == 'Cash - Less than 20k'){
        IA2.Payment_Option__c = 'Online Payment Link';
      }
      lstApprovels.add(IA2);
      mapTypeName.put(objType.Id,objType.Name);
        }
    
        insert lstApprovels;
        
        
        for(cm_Interim_Approvals__c obj : lstApprovels){
          if(mapTypeName.get(obj.cm_Interim_Approval_Type__c) == 'LR Waiver'){
            obj.Approval_Status__c = 'Approving Authority 1 Approved';
          }
          if(mapTypeName.get(obj.cm_Interim_Approval_Type__c) == 'Holding DP / LR'){
            obj.Approval_Status__c = 'Approving Authority 1 Approved';
          } 
        }
        update lstApprovels;
        map<id,cm_Interim_Approvals__c> mapData = new map<id,cm_Interim_Approvals__c> ();
        for(cm_Interim_Approvals__c obj : lstApprovels){
          
          if(mapTypeName.get(obj.cm_Interim_Approval_Type__c) == 'LR Waiver'){
            obj.Approval_Status__c = 'Approving Authority 2 Approved';
          }
          if(mapTypeName.get(obj.cm_Interim_Approval_Type__c) == 'Holding DP / LR'){
            obj.Approval_Status__c = 'Approving Authority 2 Approved';
          }
          mapData.put(obj.id,obj);
        }
        update lstApprovels;
        
        for(cm_Interim_Approvals__c obj : lstApprovels){
          if(mapTypeName.get(obj.cm_Interim_Approval_Type__c) == 'Holding DP / LR'){
            obj.Approval_Status__c = 'Approving Authority 3 Approved';
          }
        }
        update lstApprovels;
        
    }
    @isTest
    static void myUnitTest1() {
        
        /*Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,isActive = true,
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_1@testorg.com');
        insert u;*/
        
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonMailingCountry ='United Arab Emirates';
        insert objAccount;
        
        
        
        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount.id;
        insert objOppor;
        
        cm_Administrator_Settings__c custSetting = new cm_Administrator_Settings__c(Payment_Due_Minutes__c=30,Admin_User__c=userinfo.getUserId(),name='ADMIN',cm_booking_timer__c =20);
        INSERT custSetting;
        
        list<cm_Interim_Approval_Type__c> lstTypes = new list<cm_Interim_Approval_Type__c>();
        list<cm_Interim_Approvals__c> lstApprovels = new list<cm_Interim_Approvals__c>(); 
        
        map<Id,string> mapTypeName = new map<Id,string>();
        
        cm_Interim_Approval_Type__c type1 = new cm_Interim_Approval_Type__c(is_active__c=true,cm_Approving_Authority_1__c = 'Sales Person',cm_Mandatory__c = true,Name = 'Cash - Less than 20k',cm_Action_By__c = 'Property Advisor');
        lstTypes.add(type1);
        
        type1 = new cm_Interim_Approval_Type__c(is_active__c=true,cm_Approving_Authority_1__c = 'Sales Manager',cm_Mandatory__c = true,Name = 'Holding DP / LR',cm_Action_By__c = 'Property Advisor');
        lstTypes.add(type1);
        
        type1 = new cm_Interim_Approval_Type__c(is_active__c=true,cm_Approving_Authority_1__c = 'Sales Person',cm_Mandatory__c = true,Name = 'CIL Exception',cm_Action_By__c = 'Property Advisor');
        lstTypes.add(type1);
        
        type1 = new cm_Interim_Approval_Type__c(is_active__c=true,cm_Approving_Authority_1__c = 'Sales Manager',cm_Mandatory__c = true,Name = 'LR Waiver',cm_Action_By__c = 'Property Advisor');
        lstTypes.add(type1);
        
        insert lstTypes;
        
        cm_Interim_Approvals__c IA2;
        
        for(cm_Interim_Approval_Type__c objType : lstTypes){
          IA2 = new cm_Interim_Approvals__c(Next_Approver__c=UserInfo.getUserId(),
                            Date_To_Hold__c = system.today(),
                                                        cm_Decision__c = 'Decision Pending', 
                                                        cm_Interim_Approval_Type__c = objType.Id,
                                                        cm_Opportunity__c = objOppor.id,
                                                         cm_Selected_Units_New__c = 'EH Land Sale-P-E177',
                                                         LR_Wavier__c = '2'
                                                        );
      if(objType.Name == 'Holding DP / LR'){
        IA2.Is_Automated__c = true;
      }
      if(objType.Name == 'Cash - Less than 20k'){
        IA2.Payment_Option__c = 'Online Payment Link';
      }
      lstApprovels.add(IA2);
      mapTypeName.put(objType.Id,objType.Name);
        }
    
        insert lstApprovels;
        
         
        map<id,cm_Interim_Approvals__c> mapData = new map<id,cm_Interim_Approvals__c> ();
        for(cm_Interim_Approvals__c obj : lstApprovels){
          mapData.put(obj.id,obj);
        }
        SpecialApprovalTriggerHandler_Actions.Execute_AfterDeleteActions(mapData);
        SpecialApprovalTriggerHandler_Actions.getNumberofApprovalsRequired(system.today().addDays(-5),system.today().adddays(5));
        SpecialApprovalTriggerHandler_Actions.getDaysToHold(system.today().addDays(-5),system.today().adddays(5));
        
        delete lstApprovels;

    }
    @isTest
    static void myUnitTest2() {
        
        /*Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,isActive = true,
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_1@testorg.com');
        insert u;*/
        
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonMailingCountry ='United Arab Emirates';
        insert objAccount;
        
        
        
        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount.id;
        insert objOppor;
        
        cm_Administrator_Settings__c custSetting = new cm_Administrator_Settings__c(Payment_Due_Minutes__c=30,Admin_User__c=userinfo.getUserId(),name='ADMIN',cm_booking_timer__c =20);
        INSERT custSetting;
        
        list<cm_Interim_Approval_Type__c> lstTypes = new list<cm_Interim_Approval_Type__c>();
        list<cm_Interim_Approvals__c> lstApprovels = new list<cm_Interim_Approvals__c>();
        
        map<Id,string> mapTypeName = new map<Id,string>();
        
        cm_Interim_Approval_Type__c type1 = new cm_Interim_Approval_Type__c(is_active__c=true,cm_Approving_Authority_1__c = 'Sales Person',cm_Mandatory__c = true,Name = 'Cash - Less than 20k',cm_Action_By__c = 'Property Advisor');
        lstTypes.add(type1);
        
        type1 = new cm_Interim_Approval_Type__c(is_active__c=true,cm_Approving_Authority_1__c = 'Sales Manager',cm_Mandatory__c = true,Name = 'Holding DP / LR',cm_Action_By__c = 'Property Advisor');
        lstTypes.add(type1);
        
        type1 = new cm_Interim_Approval_Type__c(is_active__c=true,cm_Approving_Authority_1__c = 'Sales Person',cm_Mandatory__c = true,Name = 'CIL Exception',cm_Action_By__c = 'Property Advisor');
        lstTypes.add(type1);
        
        type1 = new cm_Interim_Approval_Type__c(is_active__c=true,cm_Approving_Authority_1__c = 'Sales Manager',cm_Mandatory__c = true,Name = 'LR Waiver',cm_Action_By__c = 'Property Advisor');
        lstTypes.add(type1);
        
        insert lstTypes;
        
        cm_Interim_Approvals__c IA2;
        
        for(cm_Interim_Approval_Type__c objType : lstTypes){
          IA2 = new cm_Interim_Approvals__c(Next_Approver__c=UserInfo.getUserId(),
                            Date_To_Hold__c = system.today(),
                                                        cm_Decision__c = 'Decision Pending',
                                                        cm_Interim_Approval_Type__c = objType.Id,
                                                        cm_Opportunity__c = objOppor.id,
                                                         cm_Selected_Units_New__c = 'EH Land Sale-P-E177',
                                                         LR_Wavier__c = '2'
                                                        );
      if(objType.Name == 'Holding DP / LR'){
        IA2.Is_Automated__c = true;
      }
      if(objType.Name == 'Cash - Less than 20k'){
        IA2.Payment_Option__c = 'Online Payment Link';
      }
      lstApprovels.add(IA2);
      mapTypeName.put(objType.Id,objType.Name);
        }
    
        insert lstApprovels;
       
        
        for(cm_Interim_Approvals__c obj : lstApprovels){
          if(mapTypeName.get(obj.cm_Interim_Approval_Type__c) == 'LR Waiver'){
            obj.Approval_Status__c = 'Approving Authority 1 Approved';
          }
          if(mapTypeName.get(obj.cm_Interim_Approval_Type__c) == 'Holding DP / LR'){
            obj.Approval_Status__c = 'Approving Authority 1 Approved';
          }
        }
        update lstApprovels;
        map<id,cm_Interim_Approvals__c> mapData = new map<id,cm_Interim_Approvals__c> ();
        for(cm_Interim_Approvals__c obj : lstApprovels){
          if(mapTypeName.get(obj.cm_Interim_Approval_Type__c) == 'LR Waiver'){
            obj.Approval_Status__c = 'Approving Authority 2 Approved';
          }
          if(mapTypeName.get(obj.cm_Interim_Approval_Type__c) == 'Holding DP / LR'){ 
            obj.Approval_Status__c = 'Approving Authority 2 Approved';
          }
          mapData.put(obj.id,obj);
        }
        update lstApprovels;
        
        string test1 = userinfo.getUserId();
        

    }
    @isTest
    static void AddJointOwner_ApproavlTest() {
        
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonMailingCountry ='United Arab Emirates';
        insert objAccount;
        
        Account objAccount1 = TestDataFactory.createPAccount();
        objAccount1.PersonMailingCountry ='United Arab Emirates';
        insert objAccount1;
        
        Attachment objA = new Attachment(Name='Test',ParentId=objAccount1.Id,body=blob.valueOf('test'));
        insert objA;
        
        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount.id;
        insert objOppor;
        
        cm_Administrator_Settings__c custSetting = new cm_Administrator_Settings__c(Payment_Due_Minutes__c=30,Admin_User__c=userinfo.getUserId(),name='ADMIN',cm_booking_timer__c =20);
        INSERT custSetting;
        
        list<cm_Interim_Approval_Type__c> lstTypes = new list<cm_Interim_Approval_Type__c>();
        list<cm_Interim_Approvals__c> lstApprovels = new list<cm_Interim_Approvals__c>();
        
        map<Id,string> mapTypeName = new map<Id,string>();
        
        cm_Interim_Approval_Type__c  type1 = new cm_Interim_Approval_Type__c(is_active__c=true,cm_Approving_Authority_1__c = 'Sales Manager',cm_Mandatory__c = true,Name = 'Request to add a Joint Owner',cm_Action_By__c = 'Property Advisor');
        lstTypes.add(type1);    
        
        insert lstTypes;
        cm_Interim_Approvals__c IA2;
        for(cm_Interim_Approval_Type__c objType : lstTypes){
          IA2 = new cm_Interim_Approvals__c(Next_Approver__c=UserInfo.getUserId(),
                            Date_To_Hold__c = system.today(),
                                                        cm_Decision__c = 'Decision Pending',
                                                        cm_Interim_Approval_Type__c = objType.Id,
                                                        cm_Opportunity__c = objOppor.id,
                                                         cm_Selected_Units_New__c = 'EH Land Sale-P-E177',
                                                         Requested_Joint_Owner__c = objAccount1.id
                                                        );
      lstApprovels.add(IA2);
      mapTypeName.put(objType.Id,objType.Name);
      
        }
        insert lstApprovels;
        map<Id,cm_Interim_Approvals__c> mapNew = new map<Id,cm_Interim_Approvals__c>();
        map<Id,cm_Interim_Approvals__c> mapOld = new map<Id,cm_Interim_Approvals__c>();
        for(cm_Interim_Approvals__c objS:lstApprovels){
            mapNew.put(objS.id,objS);
        }
        for(cm_Interim_Approvals__c obj : lstApprovels){
          if(mapTypeName.get(obj.cm_Interim_Approval_Type__c) == 'Request to add a Joint Owner'){
            obj.cm_Decision__c = 'Approved';
          }
        }
        update lstApprovels;
        for(cm_Interim_Approvals__c obj : lstApprovels){
          mapOld.put(obj.id,obj);
        }
    }
    @isTest
    static void ManagePriceChangeRequestsTest() {
        
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonMailingCountry ='United Arab Emirates';
        insert objAccount;
        
        Account objAccount1 = TestDataFactory.createPAccount();
        objAccount1.PersonMailingCountry ='United Arab Emirates';
        insert objAccount1;

        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount.id;
        insert objOppor;
        
        cm_Administrator_Settings__c custSetting = new cm_Administrator_Settings__c(Payment_Due_Minutes__c=30,Admin_User__c=userinfo.getUserId(),name='ADMIN',cm_booking_timer__c =20);
        INSERT custSetting;
        
        list<cm_Interim_Approval_Type__c> lstTypes = new list<cm_Interim_Approval_Type__c>();
        list<cm_Interim_Approvals__c> lstApprovels = new list<cm_Interim_Approvals__c>();
        
        map<Id,string> mapTypeName = new map<Id,string>();
        
        cm_Interim_Approval_Type__c type1 = new cm_Interim_Approval_Type__c(is_active__c=true,cm_Approving_Authority_1__c = 'Sales Manager',cm_Mandatory__c = true,Name = 'Price Discount / Price Adjustment',cm_Action_By__c = 'Property Advisor');
        lstTypes.add(type1);   
        insert lstTypes;
        map<Id,cm_Interim_Approvals__c> mapNew = new map<Id,cm_Interim_Approvals__c>();
        map<Id,cm_Interim_Approvals__c> mapOld = new map<Id,cm_Interim_Approvals__c>();
        for(cm_Interim_Approval_Type__c objType : lstTypes){
              cm_Interim_Approvals__c IA2 = new cm_Interim_Approvals__c(Next_Approver__c=UserInfo.getUserId(),
               Date_To_Hold__c = system.today(),
                     cm_Decision__c = 'Decision Pending',
                     cm_Interim_Approval_Type__c = objType.Id,
                     cm_Opportunity__c = objOppor.id,
                     cm_Selected_Units_New__c = 'EH Land Sale-P-E177',
                     Requested_Joint_Owner__c = objAccount1.id,
                     Discount_Price_Adjustment__c = 'Price Discount'
                 );
      lstApprovels.add(IA2);
      mapTypeName.put(objType.Id,objType.Name);
        }
        insert lstApprovels;
        for(cm_Interim_Approvals__c objS:lstApprovels){
            mapNew.put(objS.id,objS);
        }
        for(cm_Interim_Approvals__c objAPP:lstApprovels){
            objAPP.Approval_Status__c= 'Submitted for Approval';
        }
        update lstApprovels;
        
        for(cm_Interim_Approvals__c obj : lstApprovels){
          mapOld.put(obj.id,obj);
        }
        for(cm_Interim_Approvals__c objAPP:lstApprovels){
            objAPP.Approval_Status__c= 'Inventory Manager Approved';
        }
        update lstApprovels;
        for(cm_Interim_Approvals__c obj : lstApprovels){
          mapOld.put(obj.id,obj);
        }
        for(cm_Interim_Approvals__c objAPP:lstApprovels){
            objAPP.Approval_Status__c= 'Inventory Manager Rejected';
        }
        update lstApprovels;
        for(cm_Interim_Approvals__c obj : lstApprovels){
          mapOld.put(obj.id,obj);
        }
    }
    @isTest(seealldata = true)
    static void ManageSharedDealApprovals_ApprovedSDTest() {
        
        list<user> lstProp = [Select id,managerId,Approving_Manager__c,cm_user_code__c,cm_team_code__c from User where profile.name like '%Property%' and isActive=true and Exclude_assignment__c = false];

        
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonMailingCountry ='United Arab Emirates';
        insert objAccount;
        
        Account objAccount1 = TestDataFactory.createPAccount();
        objAccount1.PersonMailingCountry ='United Arab Emirates';
        insert objAccount1;
        
        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount.id;
        insert objOppor;
        
        list<cm_Interim_Approval_Type__c> lstTypes = new list<cm_Interim_Approval_Type__c>();
        list<cm_Interim_Approvals__c> lstApprovels = new list<cm_Interim_Approvals__c>();
        
        map<Id,string> mapTypeName = new map<Id,string>();
        
        cm_Interim_Approval_Type__c  type1 = new cm_Interim_Approval_Type__c(is_active__c=true,cm_Approving_Authority_1__c = 'Sales Manager',cm_Mandatory__c = true,Name = 'Shared Deal Tagging',cm_Action_By__c = 'Property Advisor');
        lstTypes.add(type1);    
        
        insert lstTypes;
        cm_Interim_Approvals__c IA2;
        for(cm_Interim_Approval_Type__c objType : lstTypes){
          IA2 = new cm_Interim_Approvals__c(Next_Approver__c=UserInfo.getUserId(),
                             Date_To_Hold__c = system.today(),
                                                         cm_Decision__c = 'Decision Pending',
                                                         cm_Interim_Approval_Type__c = objType.Id,
                                                         cm_Opportunity__c = objOppor.id,
                                                         cm_Selected_Units_New__c = 'EH Land Sale-P-E177',
                                                         Tagging_Property_Advisor__c = lstProp[0].id,
                                                         Tagging_Property_Advisor2__c = lstProp[1].id,
                                                         Tagging_Property_Advisor3__c = lstProp[2].id,
                                                         Tagging_Property_Advisor4__c = lstProp[3].id,
                                                         Tagging_Property_Advisor5__c = lstProp[4].id,
                                                         PA_Manager__c = lstProp[0].managerId
                                                        );
      lstApprovels.add(IA2);
      mapTypeName.put(objType.Id,objType.Name);
      
        }
        insert lstApprovels;
        
        map<Id,cm_Interim_Approvals__c> mapNew = new map<Id,cm_Interim_Approvals__c>();
        map<Id,cm_Interim_Approvals__c> mapOld = new map<Id,cm_Interim_Approvals__c>();
        for(cm_Interim_Approvals__c objS:lstApprovels){
            mapNew.put(objS.id,objS);
        }
        for(cm_Interim_Approvals__c obj : lstApprovels){
          if(mapTypeName.get(obj.cm_Interim_Approval_Type__c) == 'Shared Deal Tagging'){
            obj.cm_Decision__c = 'Approved';
          }
        }
        update lstApprovels;
        for(cm_Interim_Approvals__c obj : lstApprovels){
          mapOld.put(obj.id,obj);
        }
        for(cm_Interim_Approvals__c obj : lstApprovels){
          if(mapTypeName.get(obj.cm_Interim_Approval_Type__c) == 'Shared Deal Tagging'){
            obj.cm_Decision__c = 'Rejected';
          }
        }
        update lstApprovels;
        for(cm_Interim_Approvals__c obj : lstApprovels){
          mapOld.put(obj.id,obj);
        }
        
    }
     @isTest(seealldata = true)
    static void BeforeUpdate_ManageSharedDealApprovalsTest() {
        
        list<user> lstProp = [Select id,managerId,Approving_Manager__c,cm_user_code__c,cm_team_code__c from User where profile.name like '%Property%' and isActive=true and Exclude_assignment__c = false];

        
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonMailingCountry ='United Arab Emirates';
        insert objAccount;
        
        Account objAccount1 = TestDataFactory.createPAccount();
        objAccount1.PersonMailingCountry ='United Arab Emirates';
        insert objAccount1;
        
        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount.id;
        insert objOppor;
        
        list<cm_Interim_Approval_Type__c> lstTypes = new list<cm_Interim_Approval_Type__c>();
        list<cm_Interim_Approvals__c> lstApprovels = new list<cm_Interim_Approvals__c>();
        
        map<Id,string> mapTypeName = new map<Id,string>();
        
        cm_Interim_Approval_Type__c  type1 = new cm_Interim_Approval_Type__c(is_active__c=true,cm_Approving_Authority_1__c = 'Sales Manager',cm_Mandatory__c = true,Name = 'Shared Deal Tagging',cm_Action_By__c = 'Property Advisor');
        lstTypes.add(type1);    
        
        insert lstTypes;
        cm_Interim_Approvals__c IA2;
        for(cm_Interim_Approval_Type__c objType : lstTypes){
          IA2 = new cm_Interim_Approvals__c(Next_Approver__c=UserInfo.getUserId(),
                             Date_To_Hold__c = system.today(),
                                                         cm_Decision__c = 'Decision Pending',
                                                         cm_Interim_Approval_Type__c = objType.Id,
                                                         cm_Opportunity__c = objOppor.id,
                                                         cm_Selected_Units_New__c = 'EH Land Sale-P-E177',
                                                         Tagging_Property_Advisor__c = lstProp[0].id,
                                                         PA_Manager__c = lstProp[0].managerId
                                                        );
      lstApprovels.add(IA2);
      mapTypeName.put(objType.Id,objType.Name);
      
        }
        insert lstApprovels;
        
        for(cm_Interim_Approvals__c obj : lstApprovels){
          if(mapTypeName.get(obj.cm_Interim_Approval_Type__c) == 'Shared Deal Tagging'){
            obj.Approval_Status__c = 'Approving Authority 1 Approved';
          }
        }
        update lstApprovels;
        
        for(cm_Interim_Approvals__c obj : lstApprovels){
          if(mapTypeName.get(obj.cm_Interim_Approval_Type__c) == 'Shared Deal Tagging'){
            obj.Approval_Status__c = 'Approving Authority 2 Approved';
          }
        }
        update lstApprovels;
        
        for(cm_Interim_Approvals__c obj : lstApprovels){
          if(mapTypeName.get(obj.cm_Interim_Approval_Type__c) == 'Shared Deal Tagging'){
            obj.Approval_Status__c = 'Approving Authority 3 Approved';
          }
        }
        update lstApprovels;
        
        for(cm_Interim_Approvals__c obj : lstApprovels){
          if(mapTypeName.get(obj.cm_Interim_Approval_Type__c) == 'Shared Deal Tagging'){
            obj.Approval_Status__c = 'Approving Authority 4 Approved';
          }
        }
        update lstApprovels;
        
        for(cm_Interim_Approvals__c obj : lstApprovels){
          if(mapTypeName.get(obj.cm_Interim_Approval_Type__c) == 'Shared Deal Tagging'){
            obj.Approval_Status__c = 'Approving Authority 5 Approved';
          }
        }
        update lstApprovels;
    }
}