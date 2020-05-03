@isTest(SeeAllData=false)
private class CM_EmaarUtils_Test {
    private static testMethod void PositiveTest1() {
        
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
        objContact.LastName = 'Dubai - CH';
        objContact.Email = 'test@emaarq.ae.test';
        objContact.cm_Birthdate__c = system.today().addYears(-28);
        objContact.cm_Passport_Number__c = 'IND1235q';
        objContact.cm_Resident_Of_UAE__c = true;
        objContact.cm_National_ID_No__c = 'UAE2010569q';
        insert objContact;
        
        Campaign objCampaign = TestDataFactory.CreateCampaign();
        insert objCampaign;

        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount.id;
        objOppor.CampaignID = objCampaign.id;
        objOppor.cm_Sales_Person__c = Userinfo.getUserId();     
        insert objOppor;
        
        Opportunity objOppor1 = TestDataFactory.createOpportunity();
        objOppor1.AccountId = objAccount2.id;
        objOppor1.CampaignID = objCampaign.id;
        objOppor1.cm_Sales_Person__c = Userinfo.getUserId();        
        objOppor1.cm_Contact__c = objContact.Id;
        insert objOppor1;
        
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        objLoc.Location_Code__c = '14567';
        insert objLoc;
        
        Property_Inventory__c objProINV = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV.Instance__c = '123456';
        insert objProINV;
        
        Opportunity_Property__c objOP = new Opportunity_Property__c();
        objOP.cm_Opportunity__c = objOppor.Id;
        objOP.cm_Property_Inventory__c = objProINV.Id;
        objOP.Sales_Order__c = 'Test Sales Order';
        insert objOP;
        
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
        
        Test.startTest();
        CM_EmaarUtils.CheckInterimApprovals(objOppor.id);
        CM_EmaarUtils.GenerateSalesOffer(objOppor.Id);
        CM_EmaarUtils.prepareImageURL();
        //CM_EmaarUtils.sendEmail(objOppor1.Id,'Test');
        CM_EmaarUtils.ApproveProperties(objOppor.Id);
        CM_EmaarUtils.ValidateOpportunityfields(objAccount.Id);
        CM_EmaarUtils.ValidateBusinessAccountFields(objAccount2.Id, objOppor1.Id);
        CM_EmaarUtils.UpdatePropertyInventories(objOppor.Id);
        CM_EmaarUtils.getRecordTypeId('Account','EGY Corporate Account');
        Test.stopTest();

    }

    private static testMethod void PositiveTest3() {
        
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
        insert objOppor;
        
        Opportunity objOppor1 = TestDataFactory.createOpportunity();
        objOppor1.AccountId = objAccount2.id;
        objOppor1.CampaignID = objCampaign.id;
        objOppor1.cm_Sales_Person__c = Userinfo.getUserId();        
        objOppor1.cm_Contact__c = objContact.Id;
        insert objOppor1;
        
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
        
        Test.startTest(); 
        
        CM_EmaarUtils.paymentApproval(new Opportunity(Id=objOppor.Id), 'Cash', 'Cash','Cash', 1000);
        string sParentLogId = CM_EmaarUtils.createParentLog(objOppor.Id, 'Test Class');
        CM_EmaarUtils.CreateLOg('TestClass', objOppor.Id, objOppor.Id, 'Test', 'Test', 'Test XML', 'Test', 'Test', objLoc.Id, 'Test', objCampaign.Id, 'Test', 'Test', Userinfo.getOrganizationId(), sParentLogId);
        CM_EmaarUtils.updateLog(sParentLogId, 3, 3, 0);
        Attachment objA = new Attachment(Name='Test',ParentId=objOppor.Id,body=blob.valueOf('test'));
        insert objA;
        CM_EmaarUtils.getValueFromXMLString('<test>', 'test');
        CM_EmaarUtils.CreateSpecialApprovals(1000, new Opportunity(Id=objOppor.Id), 'Cash', 'Visa', 'Test Comments');
        CM_EmaarUtils.createPaymentRecord(1000, new Opportunity(Id=objOppor.Id),'');
        CM_EmaarUtils.GetRecordTypeIdByDeveloperName('Account', 'Corporate Account');
        CM_EmaarUtils.GetCampaignAttributes(objCampaign.Id);
        try{}catch(Exception ex){}
        Test.stopTest();

    }
    
    private static testMethod void PositiveTest4() {
        
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
        insert objOppor;
        
        Opportunity objOppor1 = TestDataFactory.createOpportunity();
        objOppor1.AccountId = objAccount2.id;
        objOppor1.CampaignID = objCampaign.id;
        objOppor1.cm_Sales_Person__c = Userinfo.getUserId();        
        objOppor1.cm_Contact__c = objContact.Id;
        insert objOppor1;
        
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        insert objLoc;
        
        Property_Inventory__c objProINV = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV.Instance__c = '123456';
        insert objProINV;
        
        Opportunity_Property__c objOP = new Opportunity_Property__c();
        objOP.cm_Opportunity__c = objOppor.Id;
        objOP.cm_Property_Inventory__c = objProINV.Id;
        //objOP.Sales_Order__c = 'Test Sales Order';
        insert objOP;
        
        Opportunity_Property__c objOP1 = new Opportunity_Property__c();
        objOP1.cm_Opportunity__c = objOppor1.Id;
        objOP1.cm_Property_Inventory__c = objProINV.Id;
        //objOP1.Sales_Order__c = 'Test Sales Order 2';
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
        
        cm_Integration_Settings__c objIS = new cm_Integration_Settings__c(Name='ORACLE',cm_SOA_key__c='SADA',cm_AES_Key__c='QWASQWASQWASQWAS',cm_UD_ID__c='DAA',cm_Username__c='ASDA');
        insert objIS;
        
        Mobile_Configurations__c objMC = new Mobile_Configurations__c();
        objMC.Name = 'Configuration';
        objMC.cm_Sales_Admin_Username__c = Userinfo.getUserName();
        objMC.Tempo_Campaign_ID__c = objCampaign.id;
        insert objMC;
        
        string sParentLogId = CM_EmaarUtils.createParentLog(objOppor.Id, 'Test Class'); 
        
        Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl());
        Test.startTest(); 
            try{
             //EmmarBookingProcess.CreateParty_SalesOrder(objOppor1.Id,sParentLogId, 'public', 'Dubai Lunch', new map<string,string>());    
            }catch(exception ex){
                
            }
            
        Test.stopTest();

    }
    
    private static testMethod void PositiveTest5() {
        
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
        insert objOppor;
        
        Opportunity objOppor1 = TestDataFactory.createOpportunity();
        objOppor1.AccountId = objAccount2.id;
        objOppor1.CampaignID = objCampaign.id;
        objOppor1.cm_Sales_Person__c = Userinfo.getUserId();        
        objOppor1.cm_Contact__c = objContact.Id;
        objOppor1.LR_waiver__c = '1%';
        insert objOppor1;
        
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        insert objLoc;
        
        Property_Inventory__c objProINV = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV.Instance__c = '123456';
        insert objProINV;
        
        Opportunity_Property__c objOP = new Opportunity_Property__c();
        objOP.cm_Opportunity__c = objOppor.Id;
        objOP.cm_Property_Inventory__c = objProINV.Id;
        //objOP.Sales_Order__c = 'Test Sales Order';
        insert objOP;
        
        Opportunity_Property__c objOP1 = new Opportunity_Property__c();
        objOP1.cm_Opportunity__c = objOppor1.Id;
        objOP1.cm_Property_Inventory__c = objProINV.Id;
        //objOP1.Sales_Order__c = 'Test Sales Order 2';
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
        
        cm_Integration_Settings__c objIS = new cm_Integration_Settings__c(Name='ORACLE',cm_SOA_key__c='SADA',cm_AES_Key__c='QWASQWASQWASQWAS',cm_UD_ID__c='DAA',cm_Username__c='ASDA');
        insert objIS;
        
        Mobile_Configurations__c objMC = new Mobile_Configurations__c();
        objMC.Name = 'Configuration';
        objMC.Tempo_Campaign_ID__c = objCampaign.id;
        objMC.cm_Sales_Admin_Username__c = Userinfo.getUserName();
        insert objMC;
        try{
            string sParentLogId = CM_EmaarUtils.createParentLog(objOppor.Id, 'Test Class'); 
            //emaarServicesComCreatesrbpelprocessVTest.MilestoneStatus = 'ERROR';
            Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl());
            Test.startTest(); 
                emaarServicesComCreatesrbpelprocessVTest.CalloutType = 'executePerformAction';
                //emaarServicesComCreatesrbpelprocessVTest.MilestoneStatus = '';
                CM_EmaarUtils.CreateContentAttachments(objOppor1.Id);
            Test.stopTest();
        }catch(exception ex){}

    }
    
    private static testMethod void GenericUtilsTest() {
        Test.setMock(HttpCalloutMock.class, new TestHttpMockTestHelper());
        CM_EmaarUtils.formatDate(system.now());
        CM_EmaarUtils.makeHTTPCall('https://Test.ame','test soap ');
        CM_EmaarUtils.GetSessionID(false);
        CM_EmaarUtils.getCreatableFieldsSOQL('Account');
        
    }
    
    private static testMethod void myUnitTest() {
        
        Account objAccount = TestDataFactory.createBAccount();
        objAccount.Name = 'Test Class Account';
        objAccount.cm_Account_key__c = 'Ravi###ravi@pwc.com###00971123456789###Test Class Account';
        insert objAccount;
        
        Contact objContact = new Contact();
        objContact.AccountId = objAccount.Id;
        objContact.FirstName = 'Ravi'; 
        objContact.LastName = 'PWC';
        objContact.Email = 'ravi@pwc.com';
        objContact.Phone = '00971123456789';
        objContact.MobilePhone = '00971123456789';
        objContact.cm_Birthdate__c = system.today().addYears(-28);
        objContact.cm_Passport_Number__c = 'IND1235q';
        objContact.cm_Resident_Of_UAE__c = true;
        objContact.cm_National_ID_No__c = 'UAE2010569q';
        objContact.cm_Contact_key__c = 'Ravi###ravi@pwc.com###00971123456789###Test Class Account';
        insert objContact;
        
        Campaign objCampaign = TestDataFactory.CreateCampaign();
        insert objCampaign;
        
        Lead objLead = TestDataFactory.CreateLead();
        objLead.cm_campaignId__c = objCampaign.Id;
        objLead.Company = 'Test Class Account';
        objLead.FirstName = 'Ravi'; 
        objLead.LastName = 'PWC';
        objLead.Email = 'ravi@pwc.com';
        objLead.Phone = '00971123456789';
        objLead.MobilePhone = '00971123456789';
        objLead.Reason_for_Visit__c =  'Agent';
        //objLead.Other__c = 'Test Class';
        insert objLead;
        
        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount.id;
        objOppor.CampaignID = objCampaign.id;
        objOppor.cm_Sales_Person__c = Userinfo.getUserId();        
        objOppor.cm_Contact__c = objContact.Id;
        objOppor.LR_waiver__c = '1%';
        //objOppor.SPA_Signed__c = 'Yes';
        insert objOppor;
        
        Test.setMock(HttpCalloutMock.class, new TestHttpMockTestHelper());
        
    }
    
    private static testMethod void myUnitTest1() {
        
        Account objAccount = TestDataFactory.createBAccount();
        objAccount.Name = 'Test Class Account';
        objAccount.cm_Account_key__c = 'Ravi###ravi@pwc.com###00971123456789###Test Class Account';
        insert objAccount;
        
        Contact objContact = new Contact();
        objContact.AccountId = objAccount.Id;
        objContact.FirstName = 'Ravi'; 
        objContact.LastName = 'PWC';
        objContact.Email = 'ravi@pwc.com';
        objContact.Phone = '00971123456789';
        objContact.MobilePhone = '00971123456789';
        objContact.cm_Birthdate__c = system.today().addYears(-28);
        objContact.cm_Passport_Number__c = 'IND1235q';
        objContact.cm_Resident_Of_UAE__c = true;
        objContact.cm_National_ID_No__c = 'UAE2010569q';
        objContact.cm_Contact_key__c = 'Ravi###ravi@pwc.com###00971123456789###Test Class Account';
        insert objContact;
        
        Campaign objCampaign = TestDataFactory.CreateCampaign();
        insert objCampaign;
        
        Lead objLead = TestDataFactory.CreateLead();
        objLead.cm_campaignId__c = objCampaign.Id;
        objLead.Company = 'Test Class Account';
        objLead.FirstName = 'Ravi'; 
        objLead.LastName = 'PWC';
        objLead.Email = 'ravi@pwc.com';
        objLead.Phone = '00971123456789';
        objLead.MobilePhone = '00971123456789';
        objLead.Reason_for_Visit__c =  'Agent';
        //objLead.Other__c = 'Test Class';
        insert objLead;
        
        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount.id;
        objOppor.CampaignID = objCampaign.id;
        objOppor.cm_Sales_Person__c = Userinfo.getUserId();        
        objOppor.cm_Contact__c = objContact.Id;
        objOppor.LR_waiver__c = '1%';
        //objOppor.SPA_Signed__c = 'Yes';
        insert objOppor;
        
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        insert objLoc;
        
        Property_Inventory__c objProINV = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV.Instance__c = '123456';
        insert objProINV;
        
        Opportunity_Property__c objOP = new Opportunity_Property__c();
        objOP.cm_Opportunity__c = objOppor.Id;
        objOP.cm_Property_Inventory__c = objProINV.Id;
        insert objOP;
        
        cm_Integration_Settings__c objIS = new cm_Integration_Settings__c(Name='ORACLE',cm_SOA_key__c='SADA',cm_AES_Key__c='SDA',cm_UD_ID__c='DAA',cm_Username__c='ASDA');
        insert objIS;
        
        Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl());
        test.startTest();
            emaarServicesComCreatesrbpelprocessVTest.CalloutType = 'executePerformAction';
        test.stopTest();
        
    }
    
    private static testMethod void myUnitTest2() {
        
        Account objAccount = TestDataFactory.createBAccount();
        objAccount.Name = 'Test Class Account';
        objAccount.cm_Account_key__c = 'Ravi###ravi@pwc.com###00971123456789###Test Class Account';
        insert objAccount;
        
        Contact objContact = new Contact();
        objContact.AccountId = objAccount.Id;
        objContact.FirstName = 'Ravi'; 
        objContact.LastName = 'PWC';
        objContact.Email = 'ravi@pwc.com';
        objContact.Phone = '00971123456789';
        objContact.MobilePhone = '00971123456789';
        objContact.cm_Birthdate__c = system.today().addYears(-28);
        objContact.cm_Passport_Number__c = 'IND1235q';
        objContact.cm_Resident_Of_UAE__c = true;
        objContact.cm_National_ID_No__c = 'UAE2010569q';
        objContact.cm_Contact_key__c = 'Ravi###ravi@pwc.com###00971123456789###Test Class Account';
        insert objContact;
        
        Campaign objCampaign = TestDataFactory.CreateCampaign();
        insert objCampaign;
        
        Lead objLead = TestDataFactory.CreateLead();
        objLead.cm_campaignId__c = objCampaign.Id;
        objLead.Company = 'Test Class Account';
        objLead.FirstName = 'Ravi'; 
        objLead.LastName = 'PWC';
        objLead.Email = 'ravi@pwc.com';
        objLead.Phone = '00971123456789';
        objLead.MobilePhone = '00971123456789';
        objLead.Reason_for_Visit__c =  'Agent';
        //objLead.Other__c = 'Test Class';
        insert objLead;
        
        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount.id;
        objOppor.CampaignID = objCampaign.id;
        objOppor.cm_Sales_Person__c = Userinfo.getUserId();        
        objOppor.cm_Contact__c = objContact.Id;
        objOppor.LR_waiver__c = '1%';
        objOppor.SPA_Signed__c = 'Yes';
        insert objOppor;
        
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        insert objLoc;
        
        Property_Inventory__c objProINV = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV.Instance__c = '123456';
        insert objProINV;
        
        Opportunity_Property__c objOP = new Opportunity_Property__c();
        objOP.cm_Opportunity__c = objOppor.Id;
        objOP.cm_Property_Inventory__c = objProINV.Id;
        insert objOP;
        
        cm_Integration_Settings__c objIS = new cm_Integration_Settings__c(Name='ORACLE',cm_SOA_key__c='SADA',cm_AES_Key__c='SDA',cm_UD_ID__c='DAA',cm_Username__c='ASDA');
        insert objIS;
        
    }
    
    private static testMethod void myUnitTest3() {
        
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
        objAccount.Salutation = 'Female';
        objAccount.cm_National_ID_Expiry_Date__pc = system.today().addYears(5);
        objAccount.cm_Visa_Expiry_Date__pc = system.today().addYears(5);
        objAccount.cm_Passport_Issue_Date__pc = system.today().addYears(-1);
        objAccount.cm_Birthdate__pc = system.today().addYears(-25);
        objAccount.cm_Passport_Expiry_Date__pc = system.today().addYears(5);
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
        insert objOppor;
        
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        insert objLoc;
        
        Property_Inventory__c objProINV = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV.Instance__c = '123456';
        insert objProINV;
        
        Opportunity_Property__c objOP = new Opportunity_Property__c();
        objOP.cm_Opportunity__c = objOppor.Id;
        objOP.cm_Property_Inventory__c = objProINV.Id;
        insert objOP;
        
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
        
        cm_Integration_Settings__c objIS = new cm_Integration_Settings__c(Name='ORACLE',cm_SOA_key__c='SADA',cm_AES_Key__c='QWASQWASQWASQWAS',cm_UD_ID__c='DAA',cm_Username__c='ASDA');
        insert objIS;
        
        Mobile_Configurations__c objMC = new Mobile_Configurations__c();
        objMC.Name = 'Configuration';
        objMC.cm_Sales_Admin_Username__c = Userinfo.getUserName();
        objMC.Tempo_Campaign_ID__c = objCampaign.id;
        insert objMC;
        
        string sParentLogId = CM_EmaarUtils.createParentLog(objOppor.Id, 'Test Class'); 
        
        Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl());
        Test.startTest(); 
             emaarServicesComCreatesrbpelprocessVTest.CalloutType = 'Sales Order Creation for Joint Owners';
             //EmmarBookingProcess.CreateParty_SalesOrder(objOppor.Id,sParentLogId, 'public', 'Dubai Lunch', new map<string,string>());    
        Test.stopTest();
        
        Decimal orgId = CM_EmaarUtils.getOrgId('', '', '');
        Set<Id> invIds = CM_EmaarUtils.getAccessableInventoryIds();
        Attachment att = new Attachment();
        att.Body = Blob.valueOf('Test Attachment');
        att.Name = 'Test Attachment';
        att.ParentId = objOppor.Id;
        insert att;
        CM_EMaarUtils.DeleteContentAttachments('success-'+att.Id);
        SET<Id> inventoryByCampaignId = CM_EmaarUtils.getInventoryByCampaignId(objCampaign.Id);
        SET<Id> inventoryByCampaignIds = CM_EmaarUtils.getInventoryByCampaignIds(objCampaign.Id);
        
        //Updated Methods
        CM_EmaarUtils.UpdateUserPreferences(true);
		CM_EmaarUtils.fieldsMapByQueryingFieldValue('buildingsFilterOption', '', invIds);
        CM_EmaarUtils.fieldsMapByQueryingFieldValue('unitTypeFilterOption', '', invIds);
        CM_EmaarUtils.fieldsMapByQueryingFieldValue('unitModelFilterOption', '', invIds);
        CM_EmaarUtils.fieldsMapByQueryingFieldValue('bedroomsFilterOption', '', invIds);
        CM_EmaarUtils.fieldsMapByQueryingFieldValue('projectsFilterOption', '', invIds);
        CM_EmaarUtils.fieldsMapByQueryingFieldValue('CampaignsFilterOption', '', invIds);        
		CM_EmaarUtils.fieldsMapByQueryingFieldValue('buildingsFilterOption', 'test', invIds);
        CM_EmaarUtils.fieldsMapByQueryingFieldValue('unitTypeFilterOption', 'test', invIds);
        CM_EmaarUtils.fieldsMapByQueryingFieldValue('unitModelFilterOption', 'test', invIds);
        CM_EmaarUtils.fieldsMapByQueryingFieldValue('bedroomsFilterOption', 'test', invIds);
        
		CM_EmaarUtils.getFieldNameToFieldLabelMap('127');     
        CM_EmaarUtils.formtStringValue('"hello');
        CM_EmaarUtils.formatORACLEDate(Date.today());
        CM_EmaarUtils.formatORACLEDate(null);
        CM_EmaarUtils.convertStringToArabicNumber('12345');
        CM_EmaarUtils.convertStringToArabicNumber('123456');
        CM_EmaarUtils.convertStringToArabicNumber('1234567');
        CM_EmaarUtils.convertStringToArabicNumber('12345678');
        CM_EmaarUtils.convertStringToArabicNumber('123456789');
        CM_EmaarUtils.convertStringToArabicNumber('1234567890');
        CM_EmaarUtils.convertStringToArabicNumber('12345678901');
        CM_EmaarUtils.convertStringToArabicNumber('123456789012');
    }
}