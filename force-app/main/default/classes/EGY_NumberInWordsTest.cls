@isTest
public class EGY_NumberInWordsTest {
	@isTest
    static void testNumberConversionToWords(){
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'Generating Sales Offer', AccountId = acc.Id, Amount = 1500, CloseDate = Date.today());
        insert opp;
        Property_Inventory__c property = new Property_Inventory__c();
        insert property;
        Opportunity_Property__c unit = new Opportunity_Property__c();
        unit.cm_Opportunity__c = opp.Id;
        unit.cm_Property_Inventory__c = property.Id;
        unit.Booking_Price__c = 1123456789;
        unit.Campaign_Price__c = 1123456789;
        unit.Total_Maintenance_Fee__c = 1123456789;
        Test.startTest();
        insert unit;
        List<Id> unitId = new List<Id>();
        unitId.add(unit.Id);
        Egy_CalculateUnitPricesInWords.calculateUnitPrices(unitId);
        Test.stopTest();
    }    
}