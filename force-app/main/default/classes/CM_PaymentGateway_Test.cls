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
private class CM_PaymentGateway_Test {

    static testMethod void myUnitTest1() {
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
        objAccount.BillingPostalCode = '1234';
        insert objAccount;
        
        Campaign objCampaign = TestDataFactory.CreateCampaign();
        objCampaign.Type = 'Tempo Dubai';
        objCampaign.cm_No_of_properties_customers_can_buy__c = '5';
        insert objCampaign;

        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount.id;
        objOppor.CampaignID = objCampaign.id;
        objOppor.cm_Sales_Person__c = Userinfo.getUserId();     
        objOppor.cm_Booking_timer__c = 20;
        objOppor.Order_Event__c = 'Tempo Dubai';
        objOppor.Order_Source__c = 'PAS';
        objOppor.Property_Booked_Date__c = system.now();
        objOppor.cm_Approval_Status__c = 'Payment Processing';
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
        
        ApexPages.currentPage().getParameters().put('id',objOppor.Id);
        system.debug('objOppor.cm_Booking_timer__c is : '+objOppor.cm_Booking_timer__c);
        test.startTest();
            Cm_PaymentGateway objPG = new Cm_PaymentGateway();
            objPG.selPaymentMode = 'Cheque';
            objPG.selDepositOption = 'Credit Card';
            objPG.getOrderEvenetOptions();
            objPG.getOrderSourceOptions();
            objPG.getCollectDeposit();
            objPG.getPaymentModes();
            //objPG.getCreditCardOptions();
            //objPG.getChequeOptions();
            objPG.getChequeDepositoptions();
            objPG.getDepositoptions();
            objPG.getAmountOptions();
            objPG.ValidateData();
            objPG.gotoStep1();
            
            Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl());
            emaarServicesComCreatesrbpelprocessVTest.CalloutType = 'Payment Terms Creation';
            objPG.createSalesOrder();
            
            emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresponse= new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
            objresponse.Status = 'SUCCESS';
            objresponse.ErrorMessage = 'Payment Terms sent sucessfully';
            string resultXML = '<P_RESULT_XML xmlns="http://xmlns.oracle.com/pcbpel/adapter/db/APPS/XX_MOBILE_INT_PKG/PERFORM_ACTION/"><XX_SALES_LAUNCH xmlns=""><XX_LOC_PAYMENT_TERMS_T>';
           resultXML = resultXML+'<XX_LOC_PAYMENT_TERMS_O><LOCATION_ID>273425</LOCATION_ID><ORG_ID>898</ORG_ID><LOCATION_CODE>DE Maple-V-423</LOCATION_CODE>';
           resultXML = resultXML+'<INST_NUMBER>1</INST_NUMBER><NET_AMOUNT>207189</NET_AMOUNT><NET_PERCENT>10</NET_PERCENT><TERMDAYS>0</TERMDAYS><TERMDATE>2016-05-04</TERMDATE>';
           resultXML = resultXML+'<MILESTONE_NAME>1st Installment</MILESTONE_NAME><SM_HEADER_ID>958</SM_HEADER_ID><SCHEDULE_TYPE>STANDARD</SCHEDULE_TYPE>';
           resultXML = resultXML+'</XX_LOC_PAYMENT_TERMS_O></XX_LOC_PAYMENT_TERMS_T></XX_SALES_LAUNCH></P_RESULT_XML>';
            objresponse.ResultXML = resultXML;
            try{
                objPG.parsedata(objresponse,objOP.id, objProINV.Id);
            }
            catch(Exception es){
            
            }
            
            objPG.StrCCExceptionComments = 'Test';
            objPG.submit();
            objPG.CancelPayment();
            objPG.CheckAgent();
            objPG.fetchCreditdata();
            objPG.fetchDepositdata();
            ApexPages.currentPage().getHeaders().put('User-Agent','iPhone');
            objPG.CheckAgent();
            
            objPG.strCreditcardNumber = '';
            objPG.strSelectedOption = '';
            objPG.strMessage = '';
            objPG.selChequeOption = '';
            objPG.selChequeTypeOption = '';
            objPG.strCollectDeposit = '';
            objPG.minuteCount = 20;
            
        test.stopTest();
        
    }
}