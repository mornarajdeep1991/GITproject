/*****************************************/
/**
*  @Who     Rajnish Kumar <rajnishkumar393@gmail.com>
*  @When    07/06/2018
*  @What    Test Class for : EmaarWebServiceUtils
*/
/****************************************/
@IsTest
private with sharing class EmaarWebServiceUtils_Test
{
    private static testMethod void coverMethods1()
    {
        cm_Integration_Settings__c custSet = new cm_Integration_Settings__c(Name='ORACLE',cm_SOA_key__c='SADA',cm_AES_Key__c='mypassword123456',cm_UD_ID__c='DAA',cm_Username__c='ASDA');
        INSERT custSet;
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl());
        
        try{
        emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresponse = EmaarWebServiceUtils.executePaymentTerms('Test','Test','Test','Test','Test','Test','Test','Test');
        
        
        }catch(exception e){}
        Test.stopTest();
    }
    
     private static testMethod void coverMethods2()
    {
        cm_Integration_Settings__c custSet = new cm_Integration_Settings__c(Name='ORACLE',cm_SOA_key__c='SADA',cm_AES_Key__c='mypassword123456',cm_UD_ID__c='DAA',cm_Username__c='ASDA');
        insert custSet;

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

        string AccountXML = '<XX_PARTY_INFO><XX_PARTY_DETAILS><PARTY><P_TITLE>MR.</P_TITLE><P_DESIGNATION/><P_GLOBAL_PARTY_ID/><P_PARTY_ID>27418550</P_PARTY_ID><P_PARTY_TYPE>PERSON</P_PARTY_TYPE><P_FIRST_NAME>Yousef</P_FIRST_NAME><P_MIDDLE_NAME></P_MIDDLE_NAME><P_LAST_NAME>Almarzooqi</P_LAST_NAME><P_FULL_NAME>Yousef Almarzooqi</P_FULL_NAME><P_NATIONALITY></P_NATIONALITY><P_PLACE_OF_BIRTH></P_PLACE_OF_BIRTH><P_NATIONAL_ID></P_NATIONAL_ID><P_NATIONAL_ID_EXPIRY></P_NATIONAL_ID_EXPIRY><P_VISA_EXPIRY_DATE></P_VISA_EXPIRY_DATE><P_ID_TYPE>PASSPORT</P_ID_TYPE><P_ID></P_ID><P_ID_EXPIRY_DATE></P_ID_EXPIRY_DATE><P_ID_ISSUE_DATE></P_ID_ISSUE_DATE><P_DOB></P_DOB><P_AGE_GROUP></P_AGE_GROUP><P_AVG_MONTHLY_INCOME></P_AVG_MONTHLY_INCOME><P_ADDRESS1>.</P_ADDRESS1><P_ADDRESS2/><P_POBOX></P_POBOX><P_CITY>.-.</P_CITY><P_POSTAL_CODE></P_POSTAL_CODE><P_COUNTRY>AE</P_COUNTRY><P_LOCATION_ID>405441</P_LOCATION_ID><P_PHONE_COUNT>1</P_PHONE_COUNT><P_EMAIL_COUNT>1</P_EMAIL_COUNT><P_GENDER></P_GENDER><P_DATE_OF_INCORPORATION></P_DATE_OF_INCORPORATION><P_COUNTRY_OF_INCORPORATION></P_COUNTRY_OF_INCORPORATION><P_TRADE_LICENSE_EXPIRY_DATE></P_TRADE_LICENSE_EXPIRY_DATE><P_INCORPORATION_AUTHORITY/><P_COUNTRY_OF_RESIDENCE></P_COUNTRY_OF_RESIDENCE></PARTY><PHONE_DETAILS><PHONE_DETAIL><P_CONTACT_POINT_TYPE>PHONE</P_CONTACT_POINT_TYPE><P_PHONE_LINE_TYPE>MOBILE</P_PHONE_LINE_TYPE><P_PHONE_COUNTRY_CODE>971</P_PHONE_COUNTRY_CODE><P_PHONE_AREA_CODE>55</P_PHONE_AREA_CODE><P_PHONE_NUMBER>432146</P_PHONE_NUMBER></PHONE_DETAIL><PHONE_DETAIL><P_CONTACT_POINT_TYPE>PHONE</P_CONTACT_POINT_TYPE><P_PHONE_LINE_TYPE>GEN</P_PHONE_LINE_TYPE><P_PHONE_COUNTRY_CODE>0</P_PHONE_COUNTRY_CODE><P_PHONE_AREA_CODE></P_PHONE_AREA_CODE><P_PHONE_NUMBER></P_PHONE_NUMBER></PHONE_DETAIL></PHONE_DETAILS><EMAIL_DETAILS><EMAIL_DETAIL><P_CONTACT_POINT_TYPE>EMAIL</P_CONTACT_POINT_TYPE><P_EMAIL_ADDRESS>isnasgh@gmail.com</P_EMAIL_ADDRESS></EMAIL_DETAIL></EMAIL_DETAILS></XX_PARTY_DETAILS><XX_JOINT_OWNERS/></XX_PARTY_INFO>';

        Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl());
        
        test.startTest();
            emaarServicesComCreatesrbpelprocessVTest.CalloutType = 'executePerformAction';
            EmaarWebServiceUtils.executeCreateSalesOrder(AccountXML,'Test','Test','Test','Test','Test','Test',11.0);
        test.stopTest();
    }
    
    private static testMethod void coverMethods3()
    {
        cm_Integration_Settings__c custSet = new cm_Integration_Settings__c(Name='ORACLE',cm_SOA_key__c='SADA',cm_AES_Key__c='mypassword123456',cm_UD_ID__c='DAA',cm_Username__c='ASDA');
        INSERT custSet; 
        Test.startTest();
        Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl());
        emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresponse1 = EmaarWebServiceUtils.executePaymentTerms('Test','Test','Test','Test','Test','Test','Test','Test');
        Test.stopTest();
    
    }
    
    private static testMethod void coverMethods4()
    {
        cm_Integration_Settings__c custSet = new cm_Integration_Settings__c(Name='ORACLE',cm_SOA_key__c='SADA',cm_AES_Key__c='mypassword123456',cm_UD_ID__c='DAA',cm_Username__c='ASDA');
        INSERT custSet;
        Test.startTest();
        Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl());
        emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresponse2 = EmaarWebServiceUtils.executeCreateSalesOrder('Test','Test','Test','Test','Test','Test','Test',98.00);
        Test.stopTest();
    }
    private static testMethod void coverMethods5()
    {
        cm_Integration_Settings__c custSet = new cm_Integration_Settings__c(Name='ORACLE',cm_SOA_key__c='SADA',cm_AES_Key__c='mypassword123456',cm_UD_ID__c='DAA',cm_Username__c='ASDA');
        INSERT custSet;
        Test.startTest();
        Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl());
        
        
        emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresponse3 = EmaarWebServiceUtils.updatesyncInventory('Test','Test','Test','Test','Test','Test');
        Test.stopTest();
    }
    private static testMethod void coverMethods6()
    {
        cm_Integration_Settings__c custSet = new cm_Integration_Settings__c(Name='ORACLE',cm_SOA_key__c='SADA',cm_AES_Key__c='mypassword123456',cm_UD_ID__c='DAA',cm_Username__c='ASDA');
        INSERT custSet;
        Test.startTest();
        Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl());
        emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresponse4 = EmaarWebServiceUtils.updateInventory('Test','Test','Test','Test','Test','Test');
        Test.stopTest();
    
    }
    private static testMethod void coverMethods7()
    {
        Campaign objCampaign = TestDataFactory.CreateCampaign();
        insert objCampaign;
        
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonMailingCountry ='United Arab Emirates';
        insert objAccount;
        
        Opportunity objOppor = TestDataFactory.createOpportunity();     
        objOppor.CampaignID = objCampaign.id;
        objOppor.AccountId = objAccount.Id;
        insert objOppor;
        
        Reciepts__c re = new Reciepts__c();
        re.Reciept_Date__c = system.today();
        insert re;
    
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        insert objLoc;
        
        Property_Inventory__c objProINV = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV.Instance__c = 'test';
        insert objProINV;
        
        Opportunity_Property__c oppProp = new Opportunity_Property__c(cm_Opportunity__c = objOppor.id,cm_Property_Inventory__c = objProINV.id);
        insert oppProp;
        cm_Integration_Settings__c custSet = new cm_Integration_Settings__c(Name='ORACLE',cm_SOA_key__c='SADA',cm_AES_Key__c='mypassword123456',cm_UD_ID__c='DAA',cm_Username__c='ASDA');
        INSERT custSet; 
        Test.startTest();
        Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl());
        try{
        emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresponse5 = EmaarWebServiceUtils.executePerformConcurrentAction_GETRECIEPT(re,oppProp.id);
        }catch(exception e){}
        Test.stopTest();
    }
   
    private static testMethod void coverMethods8()
    {   
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonMailingCountry ='United Arab Emirates';
        insert objAccount;  
        
        Campaign objCampaign = TestDataFactory.CreateCampaign();
        insert objCampaign;
        
        Opportunity objOppor = TestDataFactory.createOpportunity();     
        objOppor.CampaignID = objCampaign.id;
        objOppor.AccountId = objAccount.Id;
        insert objOppor;
        
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        insert objLoc;
        
        Property_Inventory__c objProINV = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV.Instance__c = 'test';
        insert objProINV;
        
        Opportunity_Property__c oppProp = new Opportunity_Property__c();
        oppProp.cm_Opportunity__c = objOppor.id;
        oppProp.sales_Order__c = objOppor.Id;
        oppProp.cm_Property_Inventory__c = objProINV.id;
        insert oppProp;
        
        cm_Integration_Settings__c custSet = new cm_Integration_Settings__c(Name='ORACLE',cm_SOA_key__c='SADA',cm_AES_Key__c='mypassword123456',cm_UD_ID__c='DAA',cm_Username__c='ASDA');
        INSERT custSet;
        Test.startTest();
        Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl());
        emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresponse = EmaarWebServiceUtils.executePropertyStatusUpdate(oppProp.sales_Order__c,'Test','Test'); 
        Test.stopTest();
    }
    
    private static testMethod void coverMethods9()
    {
    
        cm_Integration_Settings__c custSet = new cm_Integration_Settings__c(Name='ORACLE',cm_SOA_key__c='SADA',cm_AES_Key__c='mypassword123456',cm_UD_ID__c='DAA',cm_Username__c='ASDA');
        INSERT custSet;
        Test.startTest();
        Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl());
        try{
        EmaarWebServiceUtils.updateAsyncInventory('Test','Test','Test','Test','Test','Test');
        }catch(exception e){}
        Test.stopTest();
    }
    
     private static testMethod void coverMethods10()
    {
        
        Campaign objCampaign = TestDataFactory.CreateCampaign();
        insert objCampaign;
        
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonMailingCountry ='United Arab Emirates';
        insert objAccount;
        
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        insert objLoc;
        /*
        Property_Inventory__c objProINV = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV.Instance__c = '123456';
        insert objProINV;
        */
        Property_Inventory__c propInven = New Property_Inventory__c();
        propInven.CurrencyIsoCode = 'EGP';
        insert propInven;
        
        
        Opportunity objOpport = TestDataFactory.createOpportunity();     
        objOpport.CampaignID = objCampaign.id;
        objOpport.AccountId = objAccount.Id;
        insert objOpport;
        
        Opportunity_Property__c objOP = new Opportunity_Property__c();
        objOP.cm_Opportunity__c = objOpport.Id;
        objOP.cm_Property_Inventory__c = propInven.Id;
        objOP.Sales_Order__c = objOpport.Id;
        insert objOP;
        
       
        cm_Integration_Settings__c custSet = new cm_Integration_Settings__c(Name='ORACLE',cm_SOA_key__c='SADA',cm_AES_Key__c='mypassword123456',cm_UD_ID__c='DAA',cm_Username__c='ASDA');
        INSERT custSet;
        Test.startTest();
        Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl());
        try{
        EmaarWebServiceUtils.callPropertyStatusUpdate(objOpport.Id,'Test','Test','Test','test','test','test');
        EmaarWebServiceUtils.updateAsyncInventory('Test','Test','Test','Test','Test','Test');
        
        }catch(exception e){}
        //}catch(exception e){}
        Test.stopTest();
    }
    
    private static testMethod void coverMethods11()
    {
        //String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Account' and Name = 'Individual_Account'].Id;
        //Id RecordTyp = Schema.SObjectType.Account.getRecordTypeIdecordTypeInfosByName().get('Individual Account').getRecordTypeId();
        //RecordType rec = [Select id from RecordType where name='Individual Account' and sobjecttype='Account'];

        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonMailingCountry ='United Arab Emirates';
        //objAccount.RecordtypeId = strRecordTypeId;
        insert objAccount;
        
                
       cm_Integration_Settings__c custSet = new cm_Integration_Settings__c(Name='ORACLE',cm_SOA_key__c='SADA',cm_AES_Key__c='mypassword123456',cm_UD_ID__c='DAA',cm_Username__c='ASDA');
        INSERT custSet;
        Test.startTest();
        Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl());
        try{
        EmaarWebServiceUtils.createPartyXML(objAccount);
        }catch(exception e){}
        Test.stopTest();
    }
    
    private static testMethod void coverMethods12(){
        
        cm_Integration_Settings__c custSet = new cm_Integration_Settings__c(Name='ORACLE',cm_SOA_key__c='SADA',cm_AES_Key__c='mypassword123456',cm_UD_ID__c='DAA',cm_Username__c='ASDA');
        INSERT custSet;
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl());
        
        try{
        emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresponse = EmaarWebServiceUtils.syncPrimaryContactDetails('Test','Test','Test','Test','Test','Test','Test',22.0);
         
        }catch(exception e){}
        Test.stopTest();
    }
   
    private static testMethod void coverMethods13(){
        
        cm_Integration_Settings__c custSet = new cm_Integration_Settings__c(Name='ORACLE',cm_SOA_key__c='SADA',cm_AES_Key__c='mypassword123456',cm_UD_ID__c='DAA',cm_Username__c='ASDA');
        INSERT custSet;
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl());
        
        try{
         emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresponse = EmaarWebServiceUtils.executeCreateExpressionOfInterest('Test',20.0);
         
        }catch(exception e){}
        Test.stopTest();
    }
     private static testMethod void coverMethods14()
    {
        Reciepts__c recp = New Reciepts__c();
        recp.Reciept_Date__c = System.today();
        insert recp;
        
        cm_Integration_Settings__c custSet = new cm_Integration_Settings__c(Name='ORACLE',cm_SOA_key__c='SADA',cm_AES_Key__c='mypassword123456',cm_UD_ID__c='DAA',cm_Username__c='ASDA');
        INSERT custSet;
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl());
        
        try{
         emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresponse = EmaarWebServiceUtils.executePerformConcurrentAction_GETRECIEPT_EOI(recp,'Test',2);
         
        }catch(exception e){}
        Test.stopTest();
    }
    
    static testMethod void myUnitTest1(){
        cm_Integration_Settings__c custSet = new cm_Integration_Settings__c(Name='ORACLE',cm_SOA_key__c='SADA',cm_AES_Key__c='mypassword123456',cm_UD_ID__c='DAA',cm_Username__c='ASDA');
        insert custSet;

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

        string AccountXML = '<XX_PARTY_INFO><XX_PARTY_DETAILS><PARTY><P_TITLE>MR.</P_TITLE><P_DESIGNATION/><P_GLOBAL_PARTY_ID/><P_PARTY_ID>27418550</P_PARTY_ID><P_PARTY_TYPE>PERSON</P_PARTY_TYPE><P_FIRST_NAME>Yousef</P_FIRST_NAME><P_MIDDLE_NAME></P_MIDDLE_NAME><P_LAST_NAME>Almarzooqi</P_LAST_NAME><P_FULL_NAME>Yousef Almarzooqi</P_FULL_NAME><P_NATIONALITY></P_NATIONALITY><P_PLACE_OF_BIRTH></P_PLACE_OF_BIRTH><P_NATIONAL_ID></P_NATIONAL_ID><P_NATIONAL_ID_EXPIRY></P_NATIONAL_ID_EXPIRY><P_VISA_EXPIRY_DATE></P_VISA_EXPIRY_DATE><P_ID_TYPE>PASSPORT</P_ID_TYPE><P_ID></P_ID><P_ID_EXPIRY_DATE></P_ID_EXPIRY_DATE><P_ID_ISSUE_DATE></P_ID_ISSUE_DATE><P_DOB></P_DOB><P_AGE_GROUP></P_AGE_GROUP><P_AVG_MONTHLY_INCOME></P_AVG_MONTHLY_INCOME><P_ADDRESS1>.</P_ADDRESS1><P_ADDRESS2/><P_POBOX></P_POBOX><P_CITY>.-.</P_CITY><P_POSTAL_CODE></P_POSTAL_CODE><P_COUNTRY>AE</P_COUNTRY><P_LOCATION_ID>405441</P_LOCATION_ID><P_PHONE_COUNT>1</P_PHONE_COUNT><P_EMAIL_COUNT>1</P_EMAIL_COUNT><P_GENDER></P_GENDER><P_DATE_OF_INCORPORATION></P_DATE_OF_INCORPORATION><P_COUNTRY_OF_INCORPORATION></P_COUNTRY_OF_INCORPORATION><P_TRADE_LICENSE_EXPIRY_DATE></P_TRADE_LICENSE_EXPIRY_DATE><P_INCORPORATION_AUTHORITY/><P_COUNTRY_OF_RESIDENCE></P_COUNTRY_OF_RESIDENCE></PARTY><PHONE_DETAILS><PHONE_DETAIL><P_CONTACT_POINT_TYPE>PHONE</P_CONTACT_POINT_TYPE><P_PHONE_LINE_TYPE>MOBILE</P_PHONE_LINE_TYPE><P_PHONE_COUNTRY_CODE>971</P_PHONE_COUNTRY_CODE><P_PHONE_AREA_CODE>55</P_PHONE_AREA_CODE><P_PHONE_NUMBER>432146</P_PHONE_NUMBER></PHONE_DETAIL><PHONE_DETAIL><P_CONTACT_POINT_TYPE>PHONE</P_CONTACT_POINT_TYPE><P_PHONE_LINE_TYPE>GEN</P_PHONE_LINE_TYPE><P_PHONE_COUNTRY_CODE>0</P_PHONE_COUNTRY_CODE><P_PHONE_AREA_CODE></P_PHONE_AREA_CODE><P_PHONE_NUMBER></P_PHONE_NUMBER></PHONE_DETAIL></PHONE_DETAILS><EMAIL_DETAILS><EMAIL_DETAIL><P_CONTACT_POINT_TYPE>EMAIL</P_CONTACT_POINT_TYPE><P_EMAIL_ADDRESS>isnasgh@gmail.com</P_EMAIL_ADDRESS></EMAIL_DETAIL></EMAIL_DETAILS></XX_PARTY_DETAILS><XX_JOINT_OWNERS/></XX_PARTY_INFO>';

        Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl());
        
        test.startTest();
            emaarServicesComCreatesrbpelprocessVTest.CalloutType = 'executePerformAction';
           // EmaarWebServiceUtils.createORACLEParty(AccountXML,null);
        test.stopTest();
    }

    static testMethod void myUnitTest2(){
        
        cm_Integration_Settings__c custSet = new cm_Integration_Settings__c(Name='ORACLE',cm_SOA_key__c='SADA',cm_AES_Key__c='mypassword123456',cm_UD_ID__c='DAA',cm_Username__c='ASDA');
        insert custSet;

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

        string AccountXML = '<XX_PARTY_INFO><XX_PARTY_DETAILS><PARTY><P_TITLE>MR.</P_TITLE><P_DESIGNATION/><P_GLOBAL_PARTY_ID/><P_PARTY_ID>27418550</P_PARTY_ID><P_PARTY_TYPE>PERSON</P_PARTY_TYPE><P_FIRST_NAME>Yousef</P_FIRST_NAME><P_MIDDLE_NAME></P_MIDDLE_NAME><P_LAST_NAME>Almarzooqi</P_LAST_NAME><P_FULL_NAME>Yousef Almarzooqi</P_FULL_NAME><P_NATIONALITY></P_NATIONALITY><P_PLACE_OF_BIRTH></P_PLACE_OF_BIRTH><P_NATIONAL_ID></P_NATIONAL_ID><P_NATIONAL_ID_EXPIRY></P_NATIONAL_ID_EXPIRY><P_VISA_EXPIRY_DATE></P_VISA_EXPIRY_DATE><P_ID_TYPE>PASSPORT</P_ID_TYPE><P_ID></P_ID><P_ID_EXPIRY_DATE></P_ID_EXPIRY_DATE><P_ID_ISSUE_DATE></P_ID_ISSUE_DATE><P_DOB></P_DOB><P_AGE_GROUP></P_AGE_GROUP><P_AVG_MONTHLY_INCOME></P_AVG_MONTHLY_INCOME><P_ADDRESS1>.</P_ADDRESS1><P_ADDRESS2/><P_POBOX></P_POBOX><P_CITY>.-.</P_CITY><P_POSTAL_CODE></P_POSTAL_CODE><P_COUNTRY>AE</P_COUNTRY><P_LOCATION_ID>405441</P_LOCATION_ID><P_PHONE_COUNT>1</P_PHONE_COUNT><P_EMAIL_COUNT>1</P_EMAIL_COUNT><P_GENDER></P_GENDER><P_DATE_OF_INCORPORATION></P_DATE_OF_INCORPORATION><P_COUNTRY_OF_INCORPORATION></P_COUNTRY_OF_INCORPORATION><P_TRADE_LICENSE_EXPIRY_DATE></P_TRADE_LICENSE_EXPIRY_DATE><P_INCORPORATION_AUTHORITY/><P_COUNTRY_OF_RESIDENCE></P_COUNTRY_OF_RESIDENCE></PARTY><PHONE_DETAILS><PHONE_DETAIL><P_CONTACT_POINT_TYPE>PHONE</P_CONTACT_POINT_TYPE><P_PHONE_LINE_TYPE>MOBILE</P_PHONE_LINE_TYPE><P_PHONE_COUNTRY_CODE>971</P_PHONE_COUNTRY_CODE><P_PHONE_AREA_CODE>55</P_PHONE_AREA_CODE><P_PHONE_NUMBER>432146</P_PHONE_NUMBER></PHONE_DETAIL><PHONE_DETAIL><P_CONTACT_POINT_TYPE>PHONE</P_CONTACT_POINT_TYPE><P_PHONE_LINE_TYPE>GEN</P_PHONE_LINE_TYPE><P_PHONE_COUNTRY_CODE>0</P_PHONE_COUNTRY_CODE><P_PHONE_AREA_CODE></P_PHONE_AREA_CODE><P_PHONE_NUMBER></P_PHONE_NUMBER></PHONE_DETAIL></PHONE_DETAILS><EMAIL_DETAILS><EMAIL_DETAIL><P_CONTACT_POINT_TYPE>EMAIL</P_CONTACT_POINT_TYPE><P_EMAIL_ADDRESS>isnasgh@gmail.com</P_EMAIL_ADDRESS></EMAIL_DETAIL></EMAIL_DETAILS></XX_PARTY_DETAILS><XX_JOINT_OWNERS/></XX_PARTY_INFO>';

        Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl());
        
        test.startTest();
            emaarServicesComCreatesrbpelprocessVTest.CalloutType = 'executePerformAction';
            EmaarWebServiceUtils.updateAsyncInventory('','','','','','');
            EmaarWebServiceUtils.updatesyncInventory('','','','','','');
            EmaarWebServiceUtils.updateInventory('','','','','','');
            EmaarWebServiceUtils.ManageInventoryUpdates('','','','','','','');
            try{
                //EmaarWebServiceUtils.createORACLEPartyService(AccountXML,objAccount2.Id+'abc');
            }catch(Exception ex){}
        test.stopTest();
    }

    static testMethod void myUnitTest3(){
        
        cm_Integration_Settings__c custSet = new cm_Integration_Settings__c(Name='ORACLE',cm_SOA_key__c='SADA',cm_AES_Key__c='mypassword123456',cm_UD_ID__c='DAA',cm_Username__c='ASDA');
        insert custSet;

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

        Campaign objCampaign = TestDataFactory.CreateCampaign();
        insert objCampaign;

        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount2.id;
        objOppor.cm_Sales_Person__c = Userinfo.getUserId();       
        objOppor.CampaignId = objCampaign.Id; 
        insert objOppor;
        
        Mobile_Configurations__c objMC = new Mobile_Configurations__c();
        objMC.Name = 'Configuration';
        objMC.cm_Sales_Admin_Username__c = Userinfo.getUserName();
        objMC.Tempo_Campaign_ID__c = objCampaign.Id;
        insert objMC;

        Location__c objLoc = TestDataFactory.CreateLocation('U');
        insert objLoc;
        
        Property_Inventory__c objProINV = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV.Instance__c = '123456';
        insert objProINV;
        
        Opportunity_Property__c objOP = new Opportunity_Property__c();
        objOP.cm_Opportunity__c = objOppor.Id;
        objOP.cm_Property_Inventory__c = objProINV.Id;
        objOP.Sales_Order__c = objOppor.Id;
        insert objOP;

        Reciepts__c objReceipt = new Reciepts__c ();
        objReceipt.GL_Date__c = system.today();
        objReceipt.Reciept_Date__c = system.today();
        objReceipt.cm_Opportunity_Property__c = objOP.Id;

        Reciepts__c objReceipt1 = new Reciepts__c ();
        objReceipt1.GL_Date__c = system.today();
        objReceipt1.Reciept_Date__c = system.today();
        objReceipt1.cm_Opportunity_Property__c = objOP.Id;
        objReceipt1.cm_KeyToSend__c = '123456###1234567###1234567###1234567###1234567###1234567###1234567###1234567';
        insert objReceipt1;

        Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl());
        string AccountXML = '<XX_PARTY_INFO><XX_PARTY_DETAILS><PARTY><P_TITLE>MR.</P_TITLE><P_DESIGNATION/><P_GLOBAL_PARTY_ID/><P_PARTY_ID>27418550</P_PARTY_ID><P_PARTY_TYPE>PERSON</P_PARTY_TYPE><P_FIRST_NAME>Yousef</P_FIRST_NAME><P_MIDDLE_NAME></P_MIDDLE_NAME><P_LAST_NAME>Almarzooqi</P_LAST_NAME><P_FULL_NAME>Yousef Almarzooqi</P_FULL_NAME><P_NATIONALITY></P_NATIONALITY><P_PLACE_OF_BIRTH></P_PLACE_OF_BIRTH><P_NATIONAL_ID></P_NATIONAL_ID><P_NATIONAL_ID_EXPIRY></P_NATIONAL_ID_EXPIRY><P_VISA_EXPIRY_DATE></P_VISA_EXPIRY_DATE><P_ID_TYPE>PASSPORT</P_ID_TYPE><P_ID></P_ID><P_ID_EXPIRY_DATE></P_ID_EXPIRY_DATE><P_ID_ISSUE_DATE></P_ID_ISSUE_DATE><P_DOB></P_DOB><P_AGE_GROUP></P_AGE_GROUP><P_AVG_MONTHLY_INCOME></P_AVG_MONTHLY_INCOME><P_ADDRESS1>.</P_ADDRESS1><P_ADDRESS2/><P_POBOX></P_POBOX><P_CITY>.-.</P_CITY><P_POSTAL_CODE></P_POSTAL_CODE><P_COUNTRY>AE</P_COUNTRY><P_LOCATION_ID>405441</P_LOCATION_ID><P_PHONE_COUNT>1</P_PHONE_COUNT><P_EMAIL_COUNT>1</P_EMAIL_COUNT><P_GENDER></P_GENDER><P_DATE_OF_INCORPORATION></P_DATE_OF_INCORPORATION><P_COUNTRY_OF_INCORPORATION></P_COUNTRY_OF_INCORPORATION><P_TRADE_LICENSE_EXPIRY_DATE></P_TRADE_LICENSE_EXPIRY_DATE><P_INCORPORATION_AUTHORITY/><P_COUNTRY_OF_RESIDENCE></P_COUNTRY_OF_RESIDENCE></PARTY><PHONE_DETAILS><PHONE_DETAIL><P_CONTACT_POINT_TYPE>PHONE</P_CONTACT_POINT_TYPE><P_PHONE_LINE_TYPE>MOBILE</P_PHONE_LINE_TYPE><P_PHONE_COUNTRY_CODE>971</P_PHONE_COUNTRY_CODE><P_PHONE_AREA_CODE>55</P_PHONE_AREA_CODE><P_PHONE_NUMBER>432146</P_PHONE_NUMBER></PHONE_DETAIL><PHONE_DETAIL><P_CONTACT_POINT_TYPE>PHONE</P_CONTACT_POINT_TYPE><P_PHONE_LINE_TYPE>GEN</P_PHONE_LINE_TYPE><P_PHONE_COUNTRY_CODE>0</P_PHONE_COUNTRY_CODE><P_PHONE_AREA_CODE></P_PHONE_AREA_CODE><P_PHONE_NUMBER></P_PHONE_NUMBER></PHONE_DETAIL></PHONE_DETAILS><EMAIL_DETAILS><EMAIL_DETAIL><P_CONTACT_POINT_TYPE>EMAIL</P_CONTACT_POINT_TYPE><P_EMAIL_ADDRESS>isnasgh@gmail.com</P_EMAIL_ADDRESS></EMAIL_DETAIL></EMAIL_DETAILS></XX_PARTY_DETAILS><XX_JOINT_OWNERS/></XX_PARTY_INFO>';
        test.startTest();
            emaarServicesComCreatesrbpelprocessVTest.CalloutType = 'executePerformAction';
            EmaarWebServiceUtils.executePropertyStatusUpdate(objOppor.Id,'','');
            EmaarWebServiceUtils.executePropertyStatusUpdate(objOppor.Id,'', '','','');
            EmaarWebServiceUtils.executePropertyStatusUpdate(objOppor.Id,'','','','','','');
            EmaarWebServiceUtils.UpdatePropertyBulk(AccountXML);    
            EmaarWebServiceUtils.executePerformConcurrentAction_GETRECIEPT(objReceipt,objOppor.Id);

        test.stopTest();
    }

    static testMethod void myUnitTest4(){
        
        cm_Integration_Settings__c custSet = new cm_Integration_Settings__c(Name='ORACLE',cm_SOA_key__c='SADA',cm_AES_Key__c='mypassword123456',cm_UD_ID__c='DAA',cm_Username__c='ASDA');
        insert custSet;

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

        Campaign objCampaign = TestDataFactory.CreateCampaign();
        insert objCampaign;

        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount2.id;
        objOppor.cm_Sales_Person__c = Userinfo.getUserId();       
        objOppor.CampaignId = objCampaign.Id; 
        insert objOppor;
        
        Mobile_Configurations__c objMC = new Mobile_Configurations__c();
        objMC.Name = 'Configuration';
        objMC.cm_Sales_Admin_Username__c = Userinfo.getUserName();
        objMC.Tempo_Campaign_ID__c = objCampaign.Id;
        insert objMC;

        Location__c objLoc = TestDataFactory.CreateLocation('U');
        insert objLoc;
        
        Property_Inventory__c objProINV = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV.Instance__c = '123456';
        insert objProINV;
        
        Opportunity_Property__c objOP = new Opportunity_Property__c();
        objOP.cm_Opportunity__c = objOppor.Id;
        objOP.cm_Property_Inventory__c = objProINV.Id;
        objOP.Sales_Order__c = objOppor.Id;
        insert objOP;

        Reciepts__c objReceipt = new Reciepts__c ();
        objReceipt.GL_Date__c = system.today();
        objReceipt.Reciept_Date__c = system.today();
        objReceipt.cm_Opportunity_Property__c = objOP.Id;

        Reciepts__c objReceipt1 = new Reciepts__c ();
        objReceipt1.GL_Date__c = system.today();
        objReceipt1.Reciept_Date__c = system.today();
        objReceipt1.cm_Opportunity_Property__c = objOP.Id;
        objReceipt1.cm_KeyToSend__c = '123456###1234567###1234567###1234567###1234567###1234567###1234567###1234567';
        insert objReceipt1;

        Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl());
        string AccountXML = '<XX_PARTY_INFO><XX_PARTY_DETAILS><PARTY><P_TITLE>MR.</P_TITLE><P_DESIGNATION/><P_GLOBAL_PARTY_ID/><P_PARTY_ID>27418550</P_PARTY_ID><P_PARTY_TYPE>PERSON</P_PARTY_TYPE><P_FIRST_NAME>Yousef</P_FIRST_NAME><P_MIDDLE_NAME></P_MIDDLE_NAME><P_LAST_NAME>Almarzooqi</P_LAST_NAME><P_FULL_NAME>Yousef Almarzooqi</P_FULL_NAME><P_NATIONALITY></P_NATIONALITY><P_PLACE_OF_BIRTH></P_PLACE_OF_BIRTH><P_NATIONAL_ID></P_NATIONAL_ID><P_NATIONAL_ID_EXPIRY></P_NATIONAL_ID_EXPIRY><P_VISA_EXPIRY_DATE></P_VISA_EXPIRY_DATE><P_ID_TYPE>PASSPORT</P_ID_TYPE><P_ID></P_ID><P_ID_EXPIRY_DATE></P_ID_EXPIRY_DATE><P_ID_ISSUE_DATE></P_ID_ISSUE_DATE><P_DOB></P_DOB><P_AGE_GROUP></P_AGE_GROUP><P_AVG_MONTHLY_INCOME></P_AVG_MONTHLY_INCOME><P_ADDRESS1>.</P_ADDRESS1><P_ADDRESS2/><P_POBOX></P_POBOX><P_CITY>.-.</P_CITY><P_POSTAL_CODE></P_POSTAL_CODE><P_COUNTRY>AE</P_COUNTRY><P_LOCATION_ID>405441</P_LOCATION_ID><P_PHONE_COUNT>1</P_PHONE_COUNT><P_EMAIL_COUNT>1</P_EMAIL_COUNT><P_GENDER></P_GENDER><P_DATE_OF_INCORPORATION></P_DATE_OF_INCORPORATION><P_COUNTRY_OF_INCORPORATION></P_COUNTRY_OF_INCORPORATION><P_TRADE_LICENSE_EXPIRY_DATE></P_TRADE_LICENSE_EXPIRY_DATE><P_INCORPORATION_AUTHORITY/><P_COUNTRY_OF_RESIDENCE></P_COUNTRY_OF_RESIDENCE></PARTY><PHONE_DETAILS><PHONE_DETAIL><P_CONTACT_POINT_TYPE>PHONE</P_CONTACT_POINT_TYPE><P_PHONE_LINE_TYPE>MOBILE</P_PHONE_LINE_TYPE><P_PHONE_COUNTRY_CODE>971</P_PHONE_COUNTRY_CODE><P_PHONE_AREA_CODE>55</P_PHONE_AREA_CODE><P_PHONE_NUMBER>432146</P_PHONE_NUMBER></PHONE_DETAIL><PHONE_DETAIL><P_CONTACT_POINT_TYPE>PHONE</P_CONTACT_POINT_TYPE><P_PHONE_LINE_TYPE>GEN</P_PHONE_LINE_TYPE><P_PHONE_COUNTRY_CODE>0</P_PHONE_COUNTRY_CODE><P_PHONE_AREA_CODE></P_PHONE_AREA_CODE><P_PHONE_NUMBER></P_PHONE_NUMBER></PHONE_DETAIL></PHONE_DETAILS><EMAIL_DETAILS><EMAIL_DETAIL><P_CONTACT_POINT_TYPE>EMAIL</P_CONTACT_POINT_TYPE><P_EMAIL_ADDRESS>isnasgh@gmail.com</P_EMAIL_ADDRESS></EMAIL_DETAIL></EMAIL_DETAILS></XX_PARTY_DETAILS><XX_JOINT_OWNERS/></XX_PARTY_INFO>';
        test.startTest();
            emaarServicesComCreatesrbpelprocessVTest.CalloutType = 'executePerformAction';
            EmaarWebServiceUtils.callUpdatePartyService(AccountXML,objAccount2.id);
        test.stopTest();
    }
    static testMethod void myUnitTest5(){
        cm_Integration_Settings__c custSet = new cm_Integration_Settings__c(Name='ORACLE',cm_SOA_key__c='SADA',cm_AES_Key__c='mypassword123456',cm_UD_ID__c='DAA',cm_Username__c='ASDA');
        insert custSet;

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

        Campaign objCampaign = TestDataFactory.CreateCampaign();
        insert objCampaign;

        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount2.id;
        objOppor.cm_Sales_Person__c = Userinfo.getUserId();       
        objOppor.CampaignId = objCampaign.Id; 
        insert objOppor;
        
        Mobile_Configurations__c objMC = new Mobile_Configurations__c();
        objMC.Name = 'Configuration';
        objMC.cm_Sales_Admin_Username__c = Userinfo.getUserName();
        objMC.Tempo_Campaign_ID__c = objCampaign.Id;
        insert objMC;

        Location__c objLoc = TestDataFactory.CreateLocation('U');
        insert objLoc;
        
        Property_Inventory__c objProINV = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV.Instance__c = '123456';
        insert objProINV;
        
        Opportunity_Property__c objOP = new Opportunity_Property__c();
        objOP.cm_Opportunity__c = objOppor.Id;
        objOP.cm_Property_Inventory__c = objProINV.Id;
        objOP.Sales_Order__c = objOppor.Id;
        insert objOP;

        Reciepts__c objReceipt = new Reciepts__c ();
        objReceipt.GL_Date__c = system.today();
        objReceipt.Reciept_Date__c = system.today();
        objReceipt.cm_Opportunity_Property__c = objOP.Id;

        Reciepts__c objReceipt1 = new Reciepts__c ();
        objReceipt1.GL_Date__c = system.today();
        objReceipt1.Reciept_Date__c = system.today();
        objReceipt1.cm_Opportunity_Property__c = objOP.Id;
        objReceipt1.cm_KeyToSend__c = '123456###1234567###1234567###1234567###1234567###1234567###1234567###1234567';
        insert objReceipt1;

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
        objAccount.cm_Date_of_Incorporation__c  = system.today().addYears(5);
        insert objAccount;

        Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl());
        string AccountXML = '<XX_PARTY_INFO><XX_PARTY_DETAILS><PARTY><P_TITLE>MR.</P_TITLE><P_DESIGNATION/><P_GLOBAL_PARTY_ID/><P_PARTY_ID>27418550</P_PARTY_ID><P_PARTY_TYPE>PERSON</P_PARTY_TYPE><P_FIRST_NAME>Yousef</P_FIRST_NAME><P_MIDDLE_NAME></P_MIDDLE_NAME><P_LAST_NAME>Almarzooqi</P_LAST_NAME><P_FULL_NAME>Yousef Almarzooqi</P_FULL_NAME><P_NATIONALITY></P_NATIONALITY><P_PLACE_OF_BIRTH></P_PLACE_OF_BIRTH><P_NATIONAL_ID></P_NATIONAL_ID><P_NATIONAL_ID_EXPIRY></P_NATIONAL_ID_EXPIRY><P_VISA_EXPIRY_DATE></P_VISA_EXPIRY_DATE><P_ID_TYPE>PASSPORT</P_ID_TYPE><P_ID></P_ID><P_ID_EXPIRY_DATE></P_ID_EXPIRY_DATE><P_ID_ISSUE_DATE></P_ID_ISSUE_DATE><P_DOB></P_DOB><P_AGE_GROUP></P_AGE_GROUP><P_AVG_MONTHLY_INCOME></P_AVG_MONTHLY_INCOME><P_ADDRESS1>.</P_ADDRESS1><P_ADDRESS2/><P_POBOX></P_POBOX><P_CITY>.-.</P_CITY><P_POSTAL_CODE></P_POSTAL_CODE><P_COUNTRY>AE</P_COUNTRY><P_LOCATION_ID>405441</P_LOCATION_ID><P_PHONE_COUNT>1</P_PHONE_COUNT><P_EMAIL_COUNT>1</P_EMAIL_COUNT><P_GENDER></P_GENDER><P_DATE_OF_INCORPORATION></P_DATE_OF_INCORPORATION><P_COUNTRY_OF_INCORPORATION></P_COUNTRY_OF_INCORPORATION><P_TRADE_LICENSE_EXPIRY_DATE></P_TRADE_LICENSE_EXPIRY_DATE><P_INCORPORATION_AUTHORITY/><P_COUNTRY_OF_RESIDENCE></P_COUNTRY_OF_RESIDENCE></PARTY><PHONE_DETAILS><PHONE_DETAIL><P_CONTACT_POINT_TYPE>PHONE</P_CONTACT_POINT_TYPE><P_PHONE_LINE_TYPE>MOBILE</P_PHONE_LINE_TYPE><P_PHONE_COUNTRY_CODE>971</P_PHONE_COUNTRY_CODE><P_PHONE_AREA_CODE>55</P_PHONE_AREA_CODE><P_PHONE_NUMBER>432146</P_PHONE_NUMBER></PHONE_DETAIL><PHONE_DETAIL><P_CONTACT_POINT_TYPE>PHONE</P_CONTACT_POINT_TYPE><P_PHONE_LINE_TYPE>GEN</P_PHONE_LINE_TYPE><P_PHONE_COUNTRY_CODE>0</P_PHONE_COUNTRY_CODE><P_PHONE_AREA_CODE></P_PHONE_AREA_CODE><P_PHONE_NUMBER></P_PHONE_NUMBER></PHONE_DETAIL></PHONE_DETAILS><EMAIL_DETAILS><EMAIL_DETAIL><P_CONTACT_POINT_TYPE>EMAIL</P_CONTACT_POINT_TYPE><P_EMAIL_ADDRESS>isnasgh@gmail.com</P_EMAIL_ADDRESS></EMAIL_DETAIL></EMAIL_DETAILS></XX_PARTY_DETAILS><XX_JOINT_OWNERS/></XX_PARTY_INFO>';
        test.startTest();
            emaarServicesComCreatesrbpelprocessVTest.CalloutType = 'executePerformAction';
            EmaarWebServiceUtils.updateJointOwnerService(objAccount2.Id, objOppor.Id,'', '', '');

        test.stopTest();
    }
}