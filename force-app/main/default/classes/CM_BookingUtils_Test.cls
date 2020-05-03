@isTest
public class CM_BookingUtils_Test {
    static testmethod void bookingutl(){
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        insert objLoc;
        
        Opportunity objOppor = TestDataFactory.createOpportunity();
        insert objOppor;
        
        Property_Inventory__c objProINV1 = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV1.recordTypeId =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        objProINV1.Instance__c = 'test';
        objProINV1.Instance__c = 'test';
        objProINV1.cm_Sys_opportunity__c = objOppor.Id;
        insert objProINV1;
        
        
        Opportunity_Property__c OpporProp = TestDataFactory.CreateOpportunityProperty(objOppor.id,objProINV1.id);
        OpporProp.Sales_Order__c = '12345';
        insert OpporProp;
        
        Cm_BookingUtils bookutl = new Cm_BookingUtils();
        Cm_BookingUtils.cancelSalesOrder(string.valueof(objOppor.id),'Approval Rejection');
        Cm_BookingUtils.ApproveAdminRejection(string.valueof(objOppor.id),'Approval Rejection');
        Cm_BookingUtils.CreateLOg('Approval Rejection', string.valueof(objOppor.id), 'PROINV-'+string.valueOf(OpporProp.id), 'ErrorMessage', 'ERROR', 'responseXML', 'OrderXML', 'AccountXML', string.valueOf(objLoc.id), 'locationCode', 'CampaignId', 'Campaignname', 'UserOracleId', 'OrgId', '');
        
        OpporProp.Sales_Order__c = '12345';
        update OpporProp;
        
        objOppor.Booking_status__c = 'Booked in Oracle';
        update objOppor;
        
        test.startTest();
          
          Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl());
          Cm_BookingUtils.cancelSalesOrder(string.valueof(objOppor.id),'Online Sales - Auto Cancellation');
        
        test.stopTest();

    }
    
}