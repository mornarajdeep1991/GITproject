@isTest
public class OfferDeletionControlTest {
    @isTest
    static void testOne(){
        Account acc = new Account(Name = 'Test ACC');
        insert acc;
        Opportunity opp = new Opportunity(Name = 'Opp', AccountId = acc.Id, StageName = 'Pending Approval', CloseDate = date.today(), Amount = 1500);
        insert opp;
        Property_Inventory__c unit = new Property_Inventory__c();
        insert unit;
        Opportunity_Property__c offer = new Opportunity_Property__c();
        offer.cm_Opportunity__c = opp.Id;
        offer.cm_Property_Inventory__c = unit.Id;
        insert offer;
        Test.startTest();
        try{
            delete offer;            
        }catch(Exception e){
            
        }
        Test.stopTest();
    }
}