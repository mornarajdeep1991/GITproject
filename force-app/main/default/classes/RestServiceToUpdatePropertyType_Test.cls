@istest
public class RestServiceToUpdatePropertyType_Test {
    static testmethod void testcase1(){
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        insert objLoc;
        
        Property_Inventory__c objProINV = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV.Instance__c = '123456';
        objProINV.Property_Status__c = 'Available';
        objProINV.Property_Type__c = 'Sale';
        insert objProINV;
        
        Location__c objLoc1 = TestDataFactory.CreateLocation('P');
        insert objLoc1;
        
        Property_Inventory__c objProINV1 = TestDataFactory.CreatePropertyInventory(objLoc1.id);
        objProINV1.Instance__c = '123456123';
        objProINV1.Property_Status__c = 'Blocked';
        objProINV.Property_Type__c = 'Blocked';
        insert objProINV1;
        
        cm_Integration_Settings__c custSet = new cm_Integration_Settings__c(Name='ORACLE',cm_SOA_key__c='SADA',cm_AES_Key__c='mypassword123456',cm_UD_ID__c='DAA',cm_Username__c='ASDA');
        INSERT custSet;
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl());
        
        try{
        //emaarServicesComCreatesrbpelprocessV.DisclosureStmtDetailsResponse_element objresponse = EmaarWebServiceUtils.getDisclosureStatement('Test','Test');
        RestServiceToUpdatePropertyType.changeInventoryStatus('Sale',string.valueOf(objProINV.id),'test');
        RestServiceToUpdatePropertyType.changeInventoryStatus('Blocked',string.valueOf(objProINV1.id),'test'); 
        RestServiceToUpdatePropertyType.changeInventoryStatus('Sale',string.valueOf(objProINV.id),'test');
        RestServiceToUpdatePropertyType.changeInventoryStatus('Draft',string.valueOf(objProINV1.id),'test');
        RestServiceToUpdatePropertyType.changeInventoryStatus('Draft',string.valueOf(objProINV.id),'test');
        RestServiceToUpdatePropertyType.UpdatePropertyType('Sale',string.valueOf(objProINV1.id),'test');
        RestServiceToUpdatePropertyType.UpdatePropertyType('Blocked',string.valueOf(objProINV.id),'test');
        RestServiceToUpdatePropertyType.UpdatePropertyType('Sale',string.valueOf(objProINV.id),'test');
        RestServiceToUpdatePropertyType.UpdatePropertyType('Blocked',string.valueOf(objProINV1.id),'test');
        RestServiceToUpdatePropertyType.UpdatePropertyType('tesr',string.valueOf(objProINV1.id),'test');
        RestServiceToUpdatePropertyType.push2Oracle('Sale',string.valueOf(objProINV1.id),'test');
        RestServiceToUpdatePropertyType.push2OracleAsync('Sale',string.valueOf(objProINV1.id),'test'); 
        RestServiceToUpdatePropertyType.updateInventoryStatus('Blocked',string.valueOf(objProINV.id),'test');
        
        }catch(exception e){}
        Test.stopTest();
        
    }
}