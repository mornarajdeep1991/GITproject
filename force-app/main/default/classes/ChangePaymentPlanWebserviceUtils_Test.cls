@isTest
public class ChangePaymentPlanWebserviceUtils_Test {
    @isTest
    static void testChangePaymentWebService(){
        Account client = new Account(Name = 'Test ACC');
        insert client;
        Opportunity opp1 = new Opportunity(Name = 'Test Opp', CloseDate = date.today(), amount = 50000000, StageName = 'Generating Sales Offer');
        opp1.AccountId = client.Id;
        insert opp1;
        Property_Inventory__c unit = new Property_Inventory__c();
        insert unit;
        Opportunity_Property__c offer = new Opportunity_Property__c(Original_Campaign_Price__c = 1600000, Campaign_Price__c = 1500000, Booking_Price__c = 1500000, cm_Opportunity__c = opp1.Id, cm_Property_Inventory__c = unit.Id);
        insert offer;
        cm_Interim_Approval_Type__c approvaltype = new cm_Interim_Approval_Type__c(name = Label.Special_Terms_Approval_Type);
        insert approvaltype;
        cm_Interim_Approvals__c oppApproval = new cm_Interim_Approvals__c();
        oppApproval.cm_Opportunity__c = opp1.Id;
        oppApproval.cm_Interim_Approval_Type__c = approvalType.Id;
        oppApproval.Offer__c = offer.Id;
        insert oppApproval;
        Payment_Terms__c term1 = new Payment_Terms__c(cm_Property_Inventory__c = unit.Id, Opportunity_Property__c = offer.Id);
        term1.Name = '8-year';
        term1.cm_Schedule_Type__c = 'INSTALLMENT 1';
        term1.Installment__c = 1;
        term1.cm_Net_Percent__c = '15';
        term1.Installment_Amount__c = 15000;
        term1.Maintnance_Price__c = 0;
        term1.cm_Term_Date__c = String.valueOf(date.today());
        term1.Special_Approval__c = oppApproval.Id;
        insert term1;
        cm_Integration_Settings__c oracleConfig = new cm_Integration_Settings__c();
        oracleConfig.Name = 'ORACLE';
        oracleConfig.cm_AES_Key__c = 'mypassword123456';
        oracleConfig.cm_SOA_Key__c = '58461538';
        oracleConfig.cm_UD_ID__c = '56665';
        insert oracleConfig;
        Test.setMock(WebServiceMock.class, new ChangePaymentPlanCalloutMock());
        Test.startTest();
        ChangePaymentPlanWebserviceUtils.SynctoOracle(oppApproval.Id, opp1.Id);
        Test.stopTest();
    }
}