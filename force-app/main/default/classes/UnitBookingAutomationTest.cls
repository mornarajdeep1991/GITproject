@isTest
public class UnitBookingAutomationTest {
    @isTest
    static void testLaunch(){
        Campaign launchSales = new Campaign();
        launchSales.Name = 'Launch Sales Campaign';
        launchSales.StartDate = date.today().addDays(-5);
        launchSales.EndDate = date.today().addDays(5);
        launchSales.Type = 'Launch Sales';
        insert launchSales;
        
        Property_Inventory__c unit = new Property_Inventory__c();
        unit.cm_Related_Campaign__c = launchSales.Id;
        unit.Booking_Stage__c = 0;
        insert unit;
        Campaign_Unit__c cau = new Campaign_Unit__c();
        cau.cm_Campaign__c = launchSales.Id;
        cau.cm_Property_Inventory__c = unit.Id;
        insert cau;
        Test.startTest();
        unit.Property_Status__c = 'Blocked';
        update unit;
        Test.stopTest();     
    }
    @isTest
    static void testTempo(){
        Campaign tempoSales = new Campaign();
        tempoSales.Name = 'Tempo Sales Campaign';
        tempoSales.StartDate = date.today().addDays(-5);
        tempoSales.EndDate = date.today().addDays(5);
        tempoSales.Type = 'Tempo Sales';
        insert tempoSales;

        Property_Inventory__c unit1 = new Property_Inventory__c();
        unit1.cm_Related_Campaign__c = tempoSales.Id;
        unit1.Booking_Stage__c = 0;
        insert unit1;
        Campaign_Unit__c cau1 = new Campaign_Unit__c();
        cau1.cm_Campaign__c = tempoSales.Id;
        cau1.cm_Property_Inventory__c = unit1.Id;
        insert cau1;
        
        Property_Inventory__c unit2 = new Property_Inventory__c();
        unit2.cm_Related_Campaign__c = tempoSales.Id;
        unit2.Booking_Stage__c = 1;
        insert unit2;
        Campaign_Unit__c cau2 = new Campaign_Unit__c();
        cau2.cm_Campaign__c = tempoSales.Id;
        cau2.cm_Property_Inventory__c = unit2.Id;
        insert cau2;
        
        Property_Inventory__c unit3 = new Property_Inventory__c();
        unit3.cm_Related_Campaign__c = tempoSales.Id;
        unit3.Booking_Stage__c = 2;
        insert unit3;
        Campaign_Unit__c cau3 = new Campaign_Unit__c();
        cau3.cm_Campaign__c = tempoSales.Id;
        cau3.cm_Property_Inventory__c = unit3.Id;
        insert cau3;
        Test.startTest();
        unit1.Property_Status__c = 'Booked';
        update unit1;
        unit2.Property_Status__c = 'Booked';
        update unit2;
        unit3.Property_Status__c = 'Booked';
        update unit3;
        Test.stopTest();
    }
}