@istest
public class SalesAdminAssignment_Test {
    public static testmethod void testcase1(){
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
        
        Account objAccount2 = TestDataFactory.createBAccount();
        objAccount2.BillingCity = 'Dubai';
        objAccount2.BillingCountry = 'United Arab Emirates';
        objAccount2.BillingStreet = 'Down Town Area';
        objAccount2.cm_Date_of_Incorporation__c = system.today().addYears(-3);
        objAccount2.cm_Country_Of_Incorporation__c = 'United Arab Emirates';
        objAccount2.cm_Trade_License_Expiry_Date__c = system.today().addYears(2);
        objAccount2.cm_Trade_License_Number__c = 'CL1234';
        objAccount2.Party_Type__c = 'ORGANIZATION';
        insert objAccount2;
        
        Contact objContact = new Contact();
        objContact.AccountId = objAccount2.Id;
        objContact.FirstName = 'RB'; 
        objContact.LastName = 'Dubai';
        objContact.Email = 'test@emaar.ae.test';
        objContact.cm_Birthdate__c = system.today().addYears(-28);
        objContact.cm_Passport_Number__c = 'IND1235';
        objContact.cm_Resident_Of_UAE__c = true;
        objContact.cm_National_ID_No__c = 'UAE2010569';
        insert objContact;
        
        Campaign objCampaign = TestDataFactory.CreateCampaign();
        insert objCampaign;

        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount.id;
        objOppor.CampaignID = objCampaign.id;
        objOppor.cm_Sales_Person__c = Userinfo.getUserId(); 
        objOppor.stageName='Pending Approval';
        objOppor.cm_Approval_Status__c='Approved by Admin';
        objOppor.Compliance_Process__c = false;
        insert objOppor;
        
        Opportunity objOppor1 = TestDataFactory.createOpportunity();
        objOppor1.AccountId = objAccount2.id;
        objOppor1.CampaignID = objCampaign.id;
        objOppor1.cm_Sales_Person__c = Userinfo.getUserId();        
        objOppor1.cm_Contact__c = objContact.Id;
        objOppor1.stageName='Pending Approval';
        objOppor1.cm_Approval_Status__c='Pending with Admin';
        objOppor1.Compliance_Process__c = false;
        insert objOppor1;
        
        Opportunity objOppor2 = TestDataFactory.createOpportunity();
        objOppor2.AccountId = objAccount2.id;
        objOppor2.CampaignID = objCampaign.id;
        objOppor2.cm_Sales_Person__c = Userinfo.getUserId();        
        objOppor2.cm_Contact__c = objContact.Id;
        objOppor2.stageName='Pending Approval';
        objOppor2.cm_Approval_Status__c='Pending with Admin';
        objOppor2.Compliance_Process__c = false;
        insert objOppor2;
        
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        insert objLoc;
        
        Property_Inventory__c objProINV = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV.Instance__c = '123456';
        insert objProINV;
        
        Opportunity_Property__c objOP = new Opportunity_Property__c();
        objOP.cm_Opportunity__c = objOppor.Id;
        objOP.cm_Property_Inventory__c = objProINV.Id;
        objOP.Sales_Order__c = 'Test Sales Order';
        insert objOP;
        
        Opportunity_Property__c objOP1 = new Opportunity_Property__c();
        objOP1.cm_Opportunity__c = objOppor1.Id;
        objOP1.cm_Property_Inventory__c = objProINV.Id;
        objOP1.Sales_Order__c = 'Test Sales Order 2';
        insert objOP1;
        
        Joint_Owner__c objJoint =  TestDataFactory.CreateJointOwner(objAccount.id,objOppor.id);
        insert objJoint;
        
        list<Document> lstOrgDocs = new list<Document>();
        Document objDoc = new Document();
        objDoc.FolderId = Userinfo.getUserId();
        objDoc.Name = 'EMAAR_Logo';
        objDoc.Body = Blob.valueOf('Organization Name');
        objDoc.DeveloperName = 'EMAAR_Logo';
        lstOrgDocs.add(objDoc);
        
        objDoc = new Document();
        objDoc.FolderId = Userinfo.getUserId();
        objDoc.Name = 'Nshama_Logo';
        objDoc.Body = Blob.valueOf('Organization Name');
        objDoc.DeveloperName = 'Nshama_Logo';
        lstOrgDocs.add(objDoc);
        
        objDoc = new Document();
        objDoc.FolderId = Userinfo.getUserId();
        objDoc.Name = 'CreditCard_Authorization';
        objDoc.Body = Blob.valueOf('Organization Name');
        objDoc.DeveloperName = 'CreditCard_Authorization';
        lstOrgDocs.add(objDoc);
        
        insert lstOrgDocs;
        
        OpportunityTeamMember objOTM = new OpportunityTeamMember();
        objOTM.OpportunityId = objOppor.Id;
        objOTM.OpportunityAccessLevel = 'Read';
        objOTM.TeamMemberRole = 'Property Advisor';
        objOTM.UserId = Userinfo.getUserId();
        insert objOTM;
        
        cm_Integration_Settings__c objIS = new cm_Integration_Settings__c(Name='ORACLE',cm_SOA_key__c='SADA',cm_AES_Key__c='SDA',cm_UD_ID__c='DAA',cm_Username__c='ASDA');
        insert objIS;
        
        Mobile_Configurations__c objMC = new Mobile_Configurations__c();
        objMC.Name = 'Configuration';
        objMC.cm_Sales_Admin_Username__c = Userinfo.getUserName();
        objMC.Tempo_Campaign_ID__c = objCampaign.id;
        insert objMC;
        
        //TestDataFactory.CreateSMSGateWay(true);
        Test.setMock(HttpCalloutMock.class, new TestHttpMockTestHelper());
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u2 = new User(Alias = 'standt', Email='standardur@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='standuser@testorg.com');
        insert u2;
        
        //objOppor2.OwnerId = u2.Id; 
        //update objOppor2; 
        
        
        user ui = [select id from user where id=:userinfo.getUserId()];
        
        system.runAs(ui){
            
            
            boolean isCGroupinserted = false,isBFroupinserted=false;
            for(group g : [SELECT Id FROM Group WHERE developername = 'Customer_Direct_Admin_Group']){
                GroupMember gm = new GroupMember(GroupId = g.id,UserOrGroupId = userinfo.getUserId());
                isCGroupinserted = true;
                insert gm;
            }
            for(group g : [SELECT Id FROM Group WHERE developername = 'Broker_Direct_Admin_Group']){
                GroupMember gm = new GroupMember(GroupId = g.id,UserOrGroupId = userinfo.getUserId());
                isBFroupinserted = true;
                insert gm;
                /*Group subGrp  = new Group();
                subGrp.name = 'Test Group2';
                subGrp.Type = 'Regular'; 
                Insert subGrp; 
 
                //Assign Role To Parent Group
                GroupMember grpMem2 = new GroupMember();
                grpMem2.UserOrGroupId = subGrp.Id;
                grpMem2.GroupId = g.Id;
                Insert grpMem2;
                */
                GroupMember gm2 = new GroupMember(GroupId = g.id,UserOrGroupId = u2.Id);
                isBFroupinserted = true;
                insert gm2;

                GroupMember gmu= new GroupMember(); 
                gmu.GroupId=gm.id;
            gmu.UserOrGroupId = userinfo.getUserId();
                
            }
            if(!isCGroupinserted){
                Group testGroup = new Group();
                testGroup.Name = 'Customer_Direct_Admin_Group';
                testGroup.DeveloperName = 'Customer_Direct_Admin_Group';
                INSERT testGroup;
                GroupMember gmu= new GroupMember(); 
                gmu.GroupId=testGroup.id;
            gmu.UserOrGroupId = userinfo.getUserId();
                insert gmu;
            }
            if(!isBFroupinserted){
                Group testGroup = new Group();
                testGroup.Name = 'Broker_Direct_Admin_Group';
                testGroup.DeveloperName = 'Broker_Direct_Admin_Group';
                INSERT testGroup;
                GroupMember gmu= new GroupMember(); 
                gmu.GroupId=testGroup.id;
                gmu.UserOrGroupId = userinfo.getUserId();
                insert gmu;
                GroupMember gm2 = new GroupMember(GroupId = testGroup.id,UserOrGroupId = u2.Id);
                isBFroupinserted = true;
                insert gm2;
            }
            user u = testdatafactory.CreateStandardUser();
            insert u;
           
 
            
            recordtype recid= [select id from recordtype where developername='SE_to_Sales_Admin_Auto_Assignment'];
            Configuration__c conf = new Configuration__c();
            conf.RecordTypeId  = recid.id;
            conf.Team__c = 'DCH';
            conf.Sales_Admin__c = u.id;
            insert conf;
        } 
        Test.startTest(); 
        
        Attachment objA = new Attachment(Name='Test',ParentId=objOppor.Id,body=blob.valueOf('test'));
        insert objA;
        
        SalesAdminAssignment.Check_Last_7_Days(objAccount.id);
        SalesAdminAssignment.AssignDefaultAdmin(Userinfo.getUserId());
        SalesAdminAssignment.TeamDefaultAssignment('DCH');
        SalesAdminAssignment.GetNextOwnerId();
        SalesAdminAssignment.GetNextOwnerId_CustomerDirect();
        SalesAdminAssignment.GetNextOwnerId_BrokerDirect();
        Test.stopTest();
    }
}