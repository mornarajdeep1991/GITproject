@isTest
private class EGY_AddPropertiesCtrl_Test {
    private static testMethod void test() {
        list<Cm_AddProperties.Propertywrap> lstPropertywrap = new list<Cm_AddProperties.Propertywrap>();
        Id unitRecordTypeId =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        insert objLoc;
        
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonMailingCountry ='United Arab Emirates';
        insert objAccount;
        
        Campaign objCampaign = TestDataFactory.CreateCampaign();
        objCampaign.type='Launch';
        insert objCampaign;
        
        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount.id;
        objOppor.CampaignID = objCampaign.id;
        insert objOppor;
   
        Property_Inventory__c objProINV1 = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV1.recordTypeId =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        objProINV1.Instance__c = 'test';
        objProINV1.Instance__c = 'test';
        insert objProINV1;
 
        Cm_AddProperties.Propertywrap objPropertywrap = new Cm_AddProperties.Propertywrap();
        
        objPropertywrap.objpro = new Property_Inventory__c();
        objPropertywrap.objpro = objProINV1;
        objPropertywrap.blnChecked = false;
        lstPropertywrap.add(objPropertywrap);
        
        objPropertywrap = new Cm_AddProperties.Propertywrap();
        objPropertywrap.objpro = new Property_Inventory__c();
        objPropertywrap.objpro = objProINV1;
        objPropertywrap.blnChecked = true;
        lstPropertywrap.add(objPropertywrap);
        
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
        objPsearch.selIndex = 1;
        objPsearch.removeRow();
        Cm_AddProperties.PackagePropetyCheck(objProINV1.id);
        Cm_AddProperties.DeletePackageUnits(objProINV1.id);
        objPsearch.AddSelectedProperties();
        
        test.startTest();
        EGY_AddPropertiesCtrl oController = new EGY_AddPropertiesCtrl();
        EGY_AddPropertiesCtrl.getOpportunityInfo(objOppor.id);  
        
        MAP<String, String> buildingsFilterOptionFld = EGY_AddPropertiesCtrl.fetchFieldOptions('buildingsFilterOption','');
        MAP<String, String> unitTypeFilterOptionFld = EGY_AddPropertiesCtrl.fetchFieldOptions('unitTypeFilterOption','');
        MAP<String, String> unitModelFilterOptionFld = EGY_AddPropertiesCtrl.fetchFieldOptions('unitModelFilterOption','');
        MAP<String, String> bedroomsFilterOptionFld = EGY_AddPropertiesCtrl.fetchFieldOptions('bedroomsFilterOption','');
        
        
        //Perform search 
        LIST<Property_Inventory__c> searched = EGY_AddPropertiesCtrl.doSearch
            ('',
             String.valueOf(buildingsFilterOptionFld.values()).split(',')[0],
             String.valueOf(unitTypeFilterOptionFld.values()).split(',')[0],
             String.valueOf(unitModelFilterOptionFld.values()).split(',')[0],
             String.valueOf(bedroomsFilterOptionFld.values()).split(',')[0], '',0,0,'', objOppor.id, 'Id');
        
        LIST<Property_Inventory__c> searched_with_params = EGY_AddPropertiesCtrl.doSearch('','','','','','',0,0,'','', 'Id');
        EGY_AddPropertiesCtrl.getUnitPaymentTerms('LOC-123-456');
        //System.assert(searched_with_params.size() > 0);
    }
    private static testMethod void test1() {
        list<Cm_AddProperties.Propertywrap> lstPropertywrap = new list<Cm_AddProperties.Propertywrap>();
        Id unitRecordTypeId =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        insert objLoc;
        
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonMailingCountry ='United Arab Emirates';
        insert objAccount;
        
        Campaign objCampaign = TestDataFactory.CreateCampaign();
        objCampaign.type='Launch';
        insert objCampaign;
        
        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount.id;
        objOppor.CampaignID = objCampaign.id;
        insert objOppor;
        
        Property_Inventory__c objProINV1 = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV1.recordTypeId =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        objProINV1.Instance__c = 'test';
        objProINV1.Instance__c = 'test';
        insert objProINV1;
        
        
        test.startTest();
        EGY_AddPropertiesCtrl oController = new EGY_AddPropertiesCtrl(); 
        EGY_AddPropertiesCtrl.removePropertyInventory(objOppor.id,objProINV1.id);
		EGY_AddPropertiesCtrl.fetchFields('EGY_AddProperties');
		EGY_AddPropertiesCtrl.UpdateUserPreference(true);        
        test.stopTest();
    }
    
    private static testMethod void test2() {
        list<Cm_AddProperties.Propertywrap> lstPropertywrap = new list<Cm_AddProperties.Propertywrap>();
        Id unitRecordTypeId =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        insert objLoc;
        
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonMailingCountry ='United Arab Emirates';
        insert objAccount;
        
        Campaign objCampaign = TestDataFactory.CreateCampaign();
        objCampaign.type='Launch';
        insert objCampaign;
        
        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount.id;
        objOppor.CampaignID = objCampaign.id;
        insert objOppor;
        
        Property_Inventory__c objProINV1 = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV1.recordTypeId =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        objProINV1.Instance__c = 'test';
        objProINV1.Instance__c = 'test';
        insert objProINV1;
        
        LIST<Property_Inventory__c> listPropertyInventories = new LIST<Property_Inventory__c>();
        Property_Inventory__c propTnvRecord = new Property_Inventory__c();
        propTnvRecord.Org_ID__c = 127;
        propTnvRecord.cm_Related_Campaign__c = objCampaign.id;
        propTnvRecord.RecordTypeId= Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        propTnvRecord.Property_Status__c = 'Available';
        
        listPropertyInventories.add(propTnvRecord);
        insert listPropertyInventories;
        
        List<String> selectedPInventories = new List<String>();
        for(Property_Inventory__c pi : [SELECT Id, Name, recordTypeId, Selling_Price__c, VAT_Rate__c, VAT_Amount__c, Total_Amount__c FROM Property_Inventory__c WHERE ID IN :listPropertyInventories Limit 1]){
            selectedPInventories.add(pi.name);
        }
        
        test.startTest();
        EGY_AddPropertiesCtrl oController = new EGY_AddPropertiesCtrl(); 
        EGY_AddPropertiesCtrl.AddSelectedProperties(objOppor.id,selectedPInventories);
        
        test.stopTest();
    }
    private static testMethod void test3() {
        list<Cm_AddProperties.Propertywrap> lstPropertywrap = new list<Cm_AddProperties.Propertywrap>();
        Id unitRecordTypeId = Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Package').getRecordTypeId();
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        insert objLoc;
        
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonMailingCountry ='United Arab Emirates';
        insert objAccount;
        
        Campaign objCampaign = TestDataFactory.CreateCampaign();
        objCampaign.type='Launch';
        insert objCampaign;
        
        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount.id;
        objOppor.CampaignID = objCampaign.id;
        insert objOppor;
        
        Property_Inventory__c objProINV1 = TestDataFactory.CreatePropertyInventory(objLoc.id);
        Id RecordTypeIdInventory = Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        objProINV1.recordTypeId =RecordTypeIdInventory;
        objProINV1.Instance__c = 'test';
        objProINV1.Instance__c = 'test';
        insert objProINV1;
        
        /*LIST<Property_Inventory__c> listPropertyInventories = new LIST<Property_Inventory__c>();
        Property_Inventory__c propTnvRecord = new Property_Inventory__c();
        propTnvRecord.Org_ID__c = 127;
        propTnvRecord.cm_Related_Campaign__c = objCampaign.id;
        propTnvRecord.RecordTypeId= Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        propTnvRecord.Property_Status__c = 'Available';
        
        listPropertyInventories.add(propTnvRecord);
        insert listPropertyInventories; */
        
        List<String> selectedPInventories = new List<String>();
        selectedPInventories.add(objProINV1.id);
        for(Property_Inventory__c pi : [SELECT Id, Name, recordTypeId, Selling_Price__c, VAT_Rate__c, VAT_Amount__c, Total_Amount__c FROM Property_Inventory__c]){
            selectedPInventories.add(pi.recordTypeId);
        }
        system.assert(selectedPInventories!=null);
        
        test.startTest();
        EGY_AddPropertiesCtrl oController = new EGY_AddPropertiesCtrl(); 
        EGY_AddPropertiesCtrl.AddSelectedProperties(objOppor.id,selectedPInventories);
        
        test.stopTest();
    }
}