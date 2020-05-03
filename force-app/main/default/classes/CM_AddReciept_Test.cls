@isTest
private class CM_AddReciept_Test {
    private static testMethod void test() {
        Id unitRecordTypeId =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        insert objLoc;
        
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonMailingCountry ='United Arab Emirates';
        insert objAccount;
        
        Campaign objCampaign = TestDataFactory.CreateCampaign();
        objCampaign.No_Of_Receipts__c = '1';
        insert objCampaign;
        
        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount.id;
        objOppor.CampaignID = objCampaign.id;
        insert objOppor;
        
        Property_Inventory__c objProINV = TestDataFactory.CreatePropertyInventory(objLoc.id);
        Property_Inventory__c objProINV1 = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV.recordTypeId =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        objProINV.Instance__c = 'test';
        insert objProINV;
        
        Opportunity_Property__c OpporProp = TestDataFactory.CreateOpportunityProperty(objOppor.id,objProINV.id);
        insert OpporProp;
        
        Campaign_Attributes__c CampAttr =  TestDataFactory.CreateCampaignAttributes();
        insert CampAttr;
        
        ApexPages.StandardController sc ;
        apexpages.currentPage().getParameters().put('Id',OpporProp.id);
        
        Payment_Methods__c objPM =new Payment_Methods__c();
        objPM.Building__c ='build';
        objPM.Receipt_Method__c ='build';
        objPM.Property__c = 'PROP';
        insert objPM;
        
        ApexPages.currentPage().getHeaders().put('iPhone','User-Agent'); 
        ApexPages.currentPage().getHeaders().put('User-Agent','test'); 
        
        Reciepts__c objreciept1 = new Reciepts__c();
        objreciept1.Reciept_Number__c = '12345';
        objreciept1.GL_Date__c = system.today();
        objreciept1.Reciept_Date__c= system.today();
        
        objreciept1.Opportunity__c=objOppor.id;
            //objOppor
        insert objreciept1;
    
        cm_Integration_Settings__c custSet = new cm_Integration_Settings__c(Name='ORACLE',cm_SOA_key__c='SADA',cm_AES_Key__c='mypassword123456',cm_UD_ID__c='DAA',cm_Username__c='ASDA');
        insert custSet;
        
        Mobile_Configurations__c mobileConfig=new Mobile_Configurations__c();
        mobileConfig.name='Configuration';
        mobileConfig.cm_IT_Email_Addresses__c='anas.halbawi@nsigulf.com,nsharma@emaar.ae';
        mobileConfig.cm_Drawloop_API_URL__c='https://apps.drawloop.com/SFLogin.aspx';
        mobileConfig.cm_Payment_SLA_Duration__c=120;
        mobileConfig.cm_Sales_Admin_Username__c='dxb_salesops@emaar.ae.partialdev';
        mobileConfig.Tempo_Campaign_ID__c='701580000000rSl';
        mobileConfig.Build_Number__c='205';
        mobileConfig.Sales_Admin_User_ID__c=userInfo.getUserId();
        mobileConfig.Recently_Released_Color__c='#319fd3';
        
        insert mobileConfig;
        
        
        Cm_AddReciept controll = new Cm_AddReciept(sc);
        controll.selCurrencyCode = 'INR';
        controll.exchangeRate = '12.00';
        controll.selAccId = '123';
        controll.fetchData(); 
        controll.objreciept = objreciept1;
        Apexpages.currentPage().getParameters().put('Id',objOppor.id);
        controll.preparedata();
        controll.PrepareRecieptOptions(objPM.Property__c,objPM.Building__c);
        controll.blncheck = true;
        
        controll.Adddata();
        controll.actionDone();
        
        string strXML =  '<P_RESULT_XML><XX_SALES_LAUNCH xmlns=""><XX_RECEIPT_DATA_T><XX_RECEIPT_DATA_O><RECEIPT_BATCH_ID>5241</RECEIPT_BATCH_ID><ORG_ID>81</ORG_ID><CASH_RECEIPT_ID>19152676</CASH_RECEIPT_ID><RECEIPT_NUMBER>1234</RECEIPT_NUMBER><ORG_NAME>Emaar Properties PJSC</ORG_NAME><CURRENCY_CODE>AED</CURRENCY_CODE><AMOUNT>1234</AMOUNT><RECEIPT_DATE>2016-05-11</RECEIPT_DATE><CUSTOMER_NUMBER>231909</CUSTOMER_NUMBER><DOCUMENT_NUMBER>4038329</DOCUMENT_NUMBER><AMOUNT_IN_WORDS>Thousand two hundred thirty-four Dirhams And 00 Fils</AMOUNT_IN_WORDS><MODE_OF_PAYMENT>Cheque</MODE_OF_PAYMENT><MATURITY_DATE>2016-05-11</MATURITY_DATE><FINANCIER_NAME>NIL</FINANCIER_NAME><COMMENTS>asdf</COMMENTS><COMPANY_NAME>Emaars</COMPANY_NAME><PO_BOX>PO Box No: 9440, Downtown, Dubai,</PO_BOX><COUNTRY>U.A.E</COUNTRY><TELEPHONE>+971-4-3673333</TELEPHONE><FAX>+971-4-3673793</FAX><CREATED_BY_USER>OnlineSales</CREATED_BY_USER></XX_RECEIPT_DATA_O></XX_RECEIPT_DATA_T></XX_SALES_LAUNCH></P_RESULT_XML>';
        controll.ParseRecieptXML(strXML);
        Cm_AddReciept.ResendReciept(string.valueOf(objreciept1.id),string.valueOf(OpporProp.id));
        Cm_AddReciept.ResendReciept_button(string.valueOf(objreciept1.id),string.valueOf(OpporProp.id));
        //ResendReciept
       objreciept1.cm_Opportunity_Property__c=OpporProp.id;
        update objreciept1;
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl()); 
       
        Cm_AddReciept.ResendReciept(string.valueOf(objreciept1.id),string.valueOf(OpporProp.id));
        Cm_AddReciept.ResendReciept_button(string.valueOf(objreciept1.id),string.valueOf(OpporProp.id));
        Test.stopTest();
    }
}