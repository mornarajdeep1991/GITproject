@isTest
private class SalesOfficeTrigger_Test {

    static testMethod void myTest1() {
    
    
         test.starttest();
         //Create Sales Office
        EGY_Sales_Office__c oSalesOffice= new EGY_Sales_Office__c();
        oSalesOffice.EGY_Sales_Office_Name__c='Divya';
        oSalesOffice.EGY_Department__c='Sales Office';
        oSalesOffice.EGY_Region__c='Egypt';
        insert oSalesOffice;
        delete oSalesOffice;
        
        //*****Create Queue 
        Group testGroup = new Group ();
        testGroup.Name = 'Divya';
        testGroup.Type = 'Queue';
        insert testGroup;
        
        
    }
    

  }