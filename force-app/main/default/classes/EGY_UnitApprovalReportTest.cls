@isTest
public class EGY_UnitApprovalReportTest {
    @isTest
    static void testOne(){
        Account acc = new Account(Name ='Test Acc');
        insert acc;
        Opportunity opp = new Opportunity(Name = 'Test Opp', AccountId = acc.Id, StageName='Generating Sales Offer', CloseDate = Date.today());
        insert opp;
        cm_Interim_Approval_Type__c approvalType = new cm_Interim_Approval_Type__c();
        approvalType.Name = 'Change of Payment Plan';
        insert approvalType;
        cm_Interim_Approvals__c aproval = new cm_Interim_Approvals__c();
        aproval.cm_Opportunity__c = opp.Id;
        aproval.cm_Interim_Approval_Type__c = approvalType.Id;
        insert aproval;
        /*Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(aproval.id);
        req1.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(req1);*/
        Test.startTest();
        EGY_UnitApprovalReport cont = new EGY_UnitApprovalReport();
        Test.stopTest();
    }
}