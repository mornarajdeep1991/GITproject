public class Egy_CalculateUnitPricesInWords {
    @InvocableMethod(description = 'Calculate Worded Prices')
    public static void calculateUnitPrices(List<String> unitIds){
        // query unit getting only prices fields
        List<Opportunity_Property__c> units = [select Id, Campaign_Price__c, Booking_Price_In_Words_Arabic__c, 
                                               Booking_Price_In_Words__c, Total_Maintenance_Fee__c, Maintenance_Fee_In_Words__c,
                                               Maintenance_Fees_2Third_English__c, Maintenance_Fees_Third_English__c,
                                               Maintenance_Fee_In_Words_Arabic__c FROM Opportunity_Property__c 
                                               WHERE Id IN :unitIds];
        // calculate Arabic and English worded prices for each unit calling the helper class
        for(Opportunity_Property__c unit : units){
            if(unit.Campaign_Price__c != null){
                unit.Booking_Price_In_Words__c = Egy_NumberHelper.convert(unit.Campaign_Price__c, false);
                unit.Booking_Price_In_Words_Arabic__c = Egy_NumberHelper.convert(unit.Campaign_Price__c, true);
            }
            if(unit.Total_Maintenance_Fee__c != null){
                unit.Maintenance_Fee_In_Words__c = Egy_NumberHelper.convert(unit.Total_Maintenance_Fee__c, false);
                unit.Maintenance_Fee_In_Words_Arabic__c = Egy_NumberHelper.convert(unit.Total_Maintenance_Fee__c, true);
                unit.Maintenance_Fees_Third_English_Words__c = Egy_NumberHelper.convert(unit.Maintenance_Fees_Third_English__c , false);
                unit.Maintenance_Fees_Third_Arabic_Words__c = Egy_NumberHelper.convert(unit.Maintenance_Fees_Third_English__c , true);
                unit.Maintenance_Fees_2Third_English_Words__c = Egy_NumberHelper.convert(unit.Maintenance_Fees_2Third_English__c , false);
                unit.Maintenance_Fees_2Third_Arabic_Words__c = Egy_NumberHelper.convert(unit.Maintenance_Fees_2Third_English__c , true);
            }
        }
        // update the units in the DB
        upsert units;
    }
}