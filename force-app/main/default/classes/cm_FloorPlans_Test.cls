@istest
public class cm_FloorPlans_Test {
    static testmethod void testcase1(){
        Opportunity objOppor1 = TestDataFactory.createOpportunity();
        objOppor1.cm_Sales_Person__c = Userinfo.getUserId();        
        insert objOppor1;
        
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        insert objLoc;
        
        Property_Inventory__c objProINV = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV.Instance__c = '123456';
        insert objProINV;
        
        Opportunity_Property__c objOP = new Opportunity_Property__c();
        objOP.cm_Opportunity__c = objOppor1.Id;
        objOP.cm_Property_Inventory__c = objProINV.id;
        insert objOP;
        
        cm_Integration_Settings__c objIS = new cm_Integration_Settings__c(Name='ORACLE',cm_SOA_key__c='SADA',cm_AES_Key__c='SDA',cm_UD_ID__c='DAA',cm_Username__c='ASDA');
        insert objIS;
        
        apexpages.currentPage().getParameters().put('id',objOppor1.id);
        
        Attachment attach=new Attachment();     
      attach.Name='salesOffer';
      Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
      attach.body=bodyBlob;
        attach.parentId=objOppor1.id;
        insert attach;
        
        Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl());
        Test.startTest(); 
            CM_EmaarUtils.CreateContentAttachments(objOppor1.Id);
      test.stopTest();
        cm_FloorPlans cm = new cm_FloorPlans();
        cm.prepareContent();
        apexpages.currentPage().getParameters().put('Type','InventoryfloorPlan');
        cm.prepareContent();
    }
}