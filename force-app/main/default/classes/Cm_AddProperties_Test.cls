/*****************************************/
/**
*  @Who     Rajnish Kumar <rajnishkumar393@gmail.com>
*  @When    04/06/2018
*  @What    Test Class for cover Cm_AddProperties
*/
/****************************************/
@isTest
private class Cm_AddProperties_Test {
    private static testMethod void test1() {
        list<Cm_AddProperties.Propertywrap> lstPropertywrap = new list<Cm_AddProperties.Propertywrap>();
        Id unitRecordTypeId =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        insert objLoc;
        
        cm_Administrator_Settings__c AdmSett = New cm_Administrator_Settings__c();
        AdmSett.Name='ADMIN';
        AdmSett.Temp_Campaign_Property_Count__c=2;
        insert AdmSett;
        
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonMailingCountry ='United Arab Emirates';
        insert objAccount;
        
        Campaign objCampaign = TestDataFactory.CreateCampaign();
        objCampaign.type='Launch';
        //objCampaign.IsActive = true;
        objCampaign.cm_No_of_properties_customers_can_buy__c ='2';
        insert objCampaign;
        
        
        
        Campaign_User__c  CampUser = TestDataFactory.CreateCampaignUser(UserInfo.getUserId(),objCampaign.id);
         //insert CampUser;
         
        
        Opportunity objOppor = TestDataFactory.createOpportunity();
        //objOppor.AccountId = objAccount.id;
        objOppor.CampaignID = objCampaign.id;
        insert objOppor;
        
        Property_Inventory__c objProINV1 = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV1.recordTypeId =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Package').getRecordTypeId();
        objProINV1.Instance__c = 'test';
        objProINV1.Property_Status__c='Available';
        objProINV1.Property_Type__c= 'Sale';
        insert objProINV1;

        /*Property_Inventory__c objPropinv= TestDataFactory.CreatePropertyInventory(objLoc.id);
        objPropinv.recordTypeId =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        objPropinv.Instance__c = 'test';
        objPropinv.Property_Status__c='Not Available';
        objPropinv.Property_Type__c= 'Sale';
        objPropinv.cm_Inventory_Package__c = objProINV1.Id;
        insert objPropinv;*/
        
        
        Opportunity_Property__c oppPro =TestDataFactory.CreateOpportunityProperty(objOppor.id,objProINV1.id);
        //oppPro.Package_ID__c = '123';
        insert oppPro;
        /*Opportunity_Property__c oppProperty =TestDataFactory.CreateOpportunityProperty(objOppor.id,objPropinv.id);
        insert oppProperty;
        */
        Campaign_unit__c CampUnit =  TestDataFactory.CreateCampaignUnits(objCampaign.id,objProINV1.id);
        insert CampUnit;
        
        //Campaign_unit__c CampUnit2 =  TestDataFactory.CreateCampaignUnits(objCampaign.id ,objProINV2.id);
        //insert CampUnit2;
        
        
        
        /*Cm_AddProperties.Propertywrap objPropertywrap = new Cm_AddProperties.Propertywrap();

        objPropertywrap.objpro = new Property_Inventory__c();
        objPropertywrap.objpro = objProINV1;
        objPropertywrap.blnChecked = true;
        lstPropertywrap.add(objPropertywrap);*/

         
        
        apexPages.currentPage().getParameters().put('id',objOppor.id);
         
        Cm_AddProperties objPsearch = new Cm_AddProperties();
        objPsearch.lstPropertywrap = lstPropertywrap;
        objPsearch.selectedBuildingName = 'Emaar';
        objPsearch.selectedLocationCode = '1234';
        objPsearch.selectedUnitModel = 'Emaar';
        objPsearch.selectedNoofBedrooms = '2';
        objPsearch.selectedUnitType = 'villa';
        
        objPsearch.lstPropertywrap = new list<Cm_AddProperties.Propertywrap>();
        objPsearch.CheckAgent();
        objPsearch.selIndex = 0;
        objPsearch.removeRow();
      
       
      
      
        Cm_AddProperties.PackagePropetyCheck(oppPro.id);
        Cm_AddProperties.DeletePackageUnits(objProINV1.id);

        Cm_AddProperties.Propertywrap objPropertywrap = new Cm_AddProperties.Propertywrap();
        objPropertywrap.objpro = new Property_Inventory__c();
        objPropertywrap.objpro = objProINV1;
        objPropertywrap.blnChecked = true;
        lstPropertywrap.add(objPropertywrap);

        objPsearch.AddSelectedProperties();
        
        
    }
    
   private static testMethod void test2() {
    
        Id unitRecordTypeId =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        insert objLoc;
        
        cm_Administrator_Settings__c AdmSett = New cm_Administrator_Settings__c();
        AdmSett.Name='ADMIN';
        AdmSett.Temp_Campaign_Property_Count__c=2;
        insert AdmSett;
        
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonMailingCountry ='United Arab Emirates';
        insert objAccount;
        
        Campaign objCampaign = TestDataFactory.CreateCampaign();
        objCampaign.type='Launch';
        //objCampaign.IsActive = true;
        objCampaign.cm_No_of_properties_customers_can_buy__c ='2';
        insert objCampaign;
        
        
        
        Campaign_User__c  CampUser = TestDataFactory.CreateCampaignUser(UserInfo.getUserId(),objCampaign.id);
         //insert CampUser;
         
        
        Opportunity objOppor = TestDataFactory.createOpportunity();
        //objOppor.AccountId = objAccount.id;
        objOppor.CampaignID = objCampaign.id;
        insert objOppor;
        
        Property_Inventory__c objProINV1 = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV1.recordTypeId =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        objProINV1.Instance__c = 'test';
        objProINV1.Property_Status__c='Available';
        objProINV1.Property_Type__c= 'Sale';
        insert objProINV1;

        
        Property_Inventory__c objPropinv = TestDataFactory.CreatePackage();
        objPropinv.recordTypeId =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        objPropinv.cm_Inventory_Package__c = objProINV1.Id;
        insert objPropinv;

        /*Property_Inventory__c objPropinv= TestDataFactory.CreatePropertyInventory(objLoc.id);
        objPropinv.recordTypeId =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        objPropinv.Instance__c = 'test';
        objPropinv.Property_Status__c='Not Available';
        objPropinv.Property_Type__c= 'Sale';
        objPropinv.cm_Inventory_Package__c = objProINV1.Id;
        insert objPropinv;
        */
        
        Opportunity_Property__c oppPro =TestDataFactory.CreateOpportunityProperty(objOppor.id,objProINV1.id);
        //oppPro.Package_ID__c = '123';
        insert oppPro;
        Opportunity_Property__c oppProperty =TestDataFactory.CreateOpportunityProperty(objOppor.id,objPropinv.id);
        insert oppProperty;
        
        Campaign_unit__c CampUnit =  TestDataFactory.CreateCampaignUnits(objCampaign.id,objProINV1.id);
        insert CampUnit;
        
        //Campaign_unit__c CampUnit2 =  TestDataFactory.CreateCampaignUnits(objCampaign.id ,objProINV2.id);
        //insert CampUnit2;
        
        
        
        Cm_AddProperties.Propertywrap objPropertywrap = new Cm_AddProperties.Propertywrap();

        /*objPropertywrap.objpro = new Property_Inventory__c();
        objPropertywrap.objpro = objProINV1;
        objPropertywrap.blnChecked = true;
        lstPropertywrap.add(objPropertywrap);*/

         
        
        apexPages.currentPage().getParameters().put('id',objOppor.id);
         
        Cm_AddProperties objPsearch = new Cm_AddProperties();
        // objPsearch.lstPropertywrap = lstPropertywrap;
        objPsearch.selectedBuildingName = 'Emaar';
        objPsearch.selectedLocationCode = '1234';
        objPsearch.selectedUnitModel = 'Emaar';
        objPsearch.selectedNoofBedrooms = '2';
        objPsearch.selectedUnitType = 'villa';
        
        objPsearch.lstPropertywrap = new list<Cm_AddProperties.Propertywrap>();
        objPsearch.CheckAgent();
        objPsearch.selIndex = 0;
        objPsearch.removeRow();
      
            
        Cm_AddProperties.PackagePropetyCheck(oppProperty.id);
        Cm_AddProperties.DeletePackageUnits(objProINV1.id);
        //objPsearch.lstPropertyWrap.blnChecked = true;

        list<Cm_AddProperties.Propertywrap> lstPropertywrap = new list<Cm_AddProperties.Propertywrap>();
        objPropertywrap.objpro = new Property_Inventory__c();
        objPropertywrap.objpro = objPropinv;
        objPropertywrap.blnChecked = true;
        lstPropertywrap.add(objPropertywrap);
        objPsearch.lstPropertywrap = lstPropertywrap;
        
        objPsearch.AddSelectedProperties();
        
        
        
    }

    private static testMethod void test3() {
    
        Id unitRecordTypeId =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        insert objLoc;
        
        cm_Administrator_Settings__c AdmSett = New cm_Administrator_Settings__c();
        AdmSett.Name='ADMIN';
        AdmSett.Temp_Campaign_Property_Count__c=2;
        insert AdmSett;
        
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonMailingCountry ='United Arab Emirates';
        insert objAccount;
        
        Campaign objCampaign = TestDataFactory.CreateCampaign();
        objCampaign.type='Launch';
        //objCampaign.IsActive = true;
        objCampaign.cm_No_of_properties_customers_can_buy__c ='2';
        insert objCampaign;
        
        
        
        Campaign_User__c  CampUser = TestDataFactory.CreateCampaignUser(UserInfo.getUserId(),objCampaign.id);
         //insert CampUser;
         
        
        Opportunity objOppor = TestDataFactory.createOpportunity();
        //objOppor.AccountId = objAccount.id;
        objOppor.CampaignID = objCampaign.id;
        insert objOppor;
        
        /*Property_Inventory__c objProINV1 = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV1.recordTypeId =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        objProINV1.Instance__c = 'test';
        objProINV1.Property_Status__c='Available';
        objProINV1.Property_Type__c= 'Sale';
        insert objProINV1;

        
        Property_Inventory__c objPropinv = TestDataFactory.CreatePackage();
        objPropinv.recordTypeId =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        objPropinv.cm_Inventory_Package__c = objProINV1.Id;
        insert objPropinv;*/

        /*Property_Inventory__c objPropinv= TestDataFactory.CreatePropertyInventory(objLoc.id);
        objPropinv.recordTypeId =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        objPropinv.Instance__c = 'test';
        objPropinv.Property_Status__c='Not Available';
        objPropinv.Property_Type__c= 'Sale';
        objPropinv.cm_Inventory_Package__c = objProINV1.Id;
        insert objPropinv;
        */
        
        /*Opportunity_Property__c oppPro =TestDataFactory.CreateOpportunityProperty(objOppor.id,objProINV1.id);
        //oppPro.Package_ID__c = '123';
        insert oppPro;
        Opportunity_Property__c oppProperty =TestDataFactory.CreateOpportunityProperty(objOppor.id,objPropinv.id);
        insert oppProperty;
        */
        /*Campaign_unit__c CampUnit =  TestDataFactory.CreateCampaignUnits(objCampaign.id,objProINV1.id);
        insert CampUnit;
        */
        //Campaign_unit__c CampUnit2 =  TestDataFactory.CreateCampaignUnits(objCampaign.id ,objProINV2.id);
        //insert CampUnit2;
        
        
        
        Cm_AddProperties.Propertywrap objPropertywrap = new Cm_AddProperties.Propertywrap();

        /*objPropertywrap.objpro = new Property_Inventory__c();
        objPropertywrap.objpro = objProINV1;
        objPropertywrap.blnChecked = true;
        lstPropertywrap.add(objPropertywrap);*/

         
        
        apexPages.currentPage().getParameters().put('id',objOppor.id);
         
        Cm_AddProperties objPsearch = new Cm_AddProperties();
        // objPsearch.lstPropertywrap = lstPropertywrap;
        objPsearch.selectedBuildingName = 'Emaar';
        objPsearch.selectedLocationCode = '1234';
        objPsearch.selectedUnitModel = 'Emaar';
        objPsearch.selectedNoofBedrooms = '2';
        objPsearch.selectedUnitType = 'villa';
        
        objPsearch.lstPropertywrap = new list<Cm_AddProperties.Propertywrap>();
        objPsearch.CheckAgent();
        objPsearch.selIndex = 0;
        objPsearch.removeRow();
      
            
        /*Cm_AddProperties.PackagePropetyCheck(oppProperty.id);
        Cm_AddProperties.DeletePackageUnits(objProINV1.id);
        *///objPsearch.lstPropertyWrap.blnChecked = true;

        list<Cm_AddProperties.Propertywrap> lstPropertywrap = new list<Cm_AddProperties.Propertywrap>();
        objPropertywrap.objpro = new Property_Inventory__c();
        //objPropertywrap.objpro = objPropinv;
        objPropertywrap.blnChecked = true;
        lstPropertywrap.add(objPropertywrap);
        objPsearch.lstPropertywrap = lstPropertywrap;
        
        objPsearch.AddSelectedProperties();
        
        
        
    }
    
}