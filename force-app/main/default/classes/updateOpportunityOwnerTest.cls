@isTest
public class updateOpportunityOwnerTest {
    public static testMethod void testOppUpdate(){
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonEmail ='test@gmail.com';
        objAccount.PersonMobilePhone ='5678903456';
        insert objAccount;
        
        
        Campaign objCampaign = TestDataFactory.CreateCampaign();
        objCampaign.type='Launch';
        insert objCampaign;
        
        
        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount.id;
        objOppor.CampaignID = objCampaign.id;
        insert objOppor;
        
        Test.startTest();
            updateOpportunityOwner obj = new updateOpportunityOwner();
            DataBase.executeBatch(obj);
        Test.stopTest();    
    }
}