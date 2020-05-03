@isTest
public class EGY_GenerateSPA_CustomControllerTest {
    @isTest
    static void testOne(){
        Account acc = new Account(Name = 'Test ACC',Converted_From_Lead__c=true);
        insert acc;
        Opportunity opp = new Opportunity();

        opp.StageName = 'Generating Sales Offer';
        opp.AccountId = acc.Id;
        opp.CloseDate = Date.today();
        opp.Name = 'Test Opp';
        insert opp; 
        Test.setMock(HttpCalloutMock.class, new LoginCalloutMock());
        Test.startTest();
        EGY_GenerateSPA_CustomController.getContacts(acc.Id);
        EGY_GenerateSPA_CustomController.getDeliveryOptions('');
        EGY_GenerateSPA_CustomController.getDocumentNames('');
        EGY_GenerateSPA_CustomController.getOpportunity('');
        EGY_GenerateSPA_CustomController.generateSPA(opp.Id, '', '', '');
        Test.stopTest();
    }
     static testmethod void testtwo(){
        Account acc = new Account(Name = 'Test ACC',Converted_From_Lead__c=true);
        insert acc;
        Opportunity opp = new Opportunity();

        opp.StageName = 'Generating Sales Offer';
        opp.AccountId = acc.Id;
        opp.CloseDate = Date.today();
        opp.Name = 'Test Opp';
        insert opp; 
          Test.setMock(HttpCalloutMock.class, new LoginCalloutMock());
           Test.startTest();
    GenerateRegistrationDocumentCls.doAction(opp.Id);
         Test.stopTest();
}
}