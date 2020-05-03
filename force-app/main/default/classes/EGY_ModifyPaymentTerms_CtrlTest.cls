@isTest
public class EGY_ModifyPaymentTerms_CtrlTest {
    @testSetup
    static void prepareTestData(){
        Account client = TestDataFactory.createPAccount();
        insert client;
        Opportunity opp1 = TestDataFactory.CreateOpportunity();
        opp1.AccountId = client.Id;
        insert opp1;
        Property_Inventory__c unit = new Property_Inventory__c();
        insert unit;
        Opportunity_Property__c offer = new Opportunity_Property__c(Booking_Price__c = 1500000, cm_Opportunity__c = opp1.Id, cm_Property_Inventory__c = unit.Id);
        insert offer;
        Payment_Terms__c term1 = new Payment_Terms__c(cm_Property_Inventory__c = unit.Id, Opportunity_Property__c = offer.Id);
        term1.Name = '8-year';
        term1.cm_Schedule_Type__c = 'INSTALLMENT 1';
        term1.Installment__c = 1;
        term1.cm_Net_Percent__c = '15';
        term1.Installment_Amount__c = 15000;
        term1.Maintnance_Price__c = 0;
        term1.cm_Term_Date__c = String.valueOf(date.today());
        insert term1;
        
    }
    @isTest
    static void testGetPaymentTerms(){
        Test.startTest();
        List<EGY_PaymentTermWrapper> terms = EGY_ModifyPaymentTerms_Ctrl.getPaymentTerms([select id from Opportunity].Id);
        Test.stopTest();
        System.assert(terms.size() == 1);
    }
    @isTest
    static void testSaveSpecialTerms(){
        cm_Interim_Approval_Type__c approvaltype = new cm_Interim_Approval_Type__c(name = Label.Special_Terms_Approval_Type);
        insert approvaltype;
        Test.startTest();
        EGY_PaymentTermWrapper te = new EGY_PaymentTermWrapper('Test Name', 'INSTALLMENT 1', 3.5, 10000, Date.today(), false);
        List<EGY_PaymentTermWrapper> terms = new List<EGY_PaymentTermWrapper>();
        terms.add(te);
        EGY_ModifyPaymentTerms_Ctrl.saveSpecialTerms(JSON.serialize(terms), [select id from Opportunity].Id, [select id from Opportunity_Property__c].Id,
                                                     'Discount', '2.5', '4.5', '500000', 'Employee Discount', [select id from Property_Inventory__c].Id, true
                                                    );        
        Test.stopTest();
    }
    @isTest
    static void testGetOpportunityUnits(){
        Test.startTest();
        List<Opportunity_Property__c> units = EGY_ModifyPaymentTerms_Ctrl.getOpportunityUnits([select id from Opportunity].Id);
        Test.stopTest();
        System.assert(units.size() == 1);
    }
}