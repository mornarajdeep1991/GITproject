@isTest 
public class EGY_AddCampaignUnitsController_Test {
    static testMethod void doTest() {
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonEmail ='test@gmail.com';
        objAccount.PersonMobilePhone ='5678903456';
        insert objAccount;
        
        Contact objContact = TestDataFactory.createContact();
        objContact.MobilePhone=null;
        objContact.Email=null;
        objContact.MailingStreet=null;
        insert objContact;
        
        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount.id;
        objOppor.cm_Contact__c=objContact.Id;
        insert objOppor;
        
        //Creating campaign
        Campaign objCampaign = TestDataFactory.CreateCampaign(); 
        insert objCampaign;
        
        test.starttest();
        EGY_AddCampaignUnitsController oController = new EGY_AddCampaignUnitsController();
        
        MAP<String, String> buildingsFilterOptionFld = EGY_AddCampaignUnitsController.fetchFieldOptions('buildingsFilterOption');
        MAP<String, String> unitTypeFilterOptionFld = EGY_AddCampaignUnitsController.fetchFieldOptions('unitTypeFilterOption');
        MAP<String, String> unitModelFilterOptionFld = EGY_AddCampaignUnitsController.fetchFieldOptions('unitModelFilterOption');
        MAP<String, String> bedroomsFilterOptionFld = EGY_AddCampaignUnitsController.fetchFieldOptions('bedroomsFilterOption');
        
        EGY_AddCampaignUnitsController.getCampaignInfo(objCampaign.id);
        
        //Perform search 
        LIST<Property_Inventory__c> searched = EGY_AddCampaignUnitsController.doSearch
            ('',
             String.valueOf(buildingsFilterOptionFld.values()).split(',')[0],
             String.valueOf(unitTypeFilterOptionFld.values()).split(',')[0],
             String.valueOf(unitModelFilterOptionFld.values()).split(',')[0],
             String.valueOf(bedroomsFilterOptionFld.values()).split(',')[0], objCampaign.id);
        
        LIST<Property_Inventory__c> searched_with_params = EGY_AddPropertiesCtrl.doSearch('','','','','','');
       // System.assert(searched_with_params.size() > 0); 
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
        EGY_AddCampaignUnitsController oController = new EGY_AddCampaignUnitsController();
        EGY_AddCampaignUnitsController.AddSelectedProperties(objCampaign.id,selectedPInventories);
        
        test.stopTest();
    }
    private static testMethod void test3() {
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
        EGY_AddCampaignUnitsController oController = new EGY_AddCampaignUnitsController();
        EGY_AddCampaignUnitsController.removePropertyInventory(objCampaign.id,objProINV1.id);
        
        test.stopTest();
    }
    private static testMethod void test4() {
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
        for(Property_Inventory__c pi : [SELECT Id, Name, recordTypeId, Selling_Price__c, VAT_Rate__c, VAT_Amount__c, Total_Amount__c FROM Property_Inventory__c WHERE ID IN :listPropertyInventories Limit 10]){
            selectedPInventories.add(pi.id);
        }
        
        test.startTest();
        EGY_AddCampaignUnitsController oController = new EGY_AddCampaignUnitsController();
        EGY_AddCampaignUnitsController.AddSelectedProperties(objCampaign.id,selectedPInventories);
        
        test.stopTest();
    }
    
}