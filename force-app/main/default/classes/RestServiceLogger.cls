public class RestServiceLogger {
    
    public Service_Logs__c log{get;set;}
    
    public RestServiceLogger(String requestType, Map<String, String> headers, Id opportunityId, Id opportunityPropertyId, Id propertyInventoryId) {
    
        if (headers != null) {
            
            log = new Service_Logs__c();

            String deviceType = headers.get('X-Device-Type');
            String devicePlatform = headers.get('X-Platform');
            String deviceModel = headers.get('X-Device-Model');
            
            log.Device_Type__c = deviceType;
            log.Device_Platform__c = devicePlatform;
            log.Device_Model__c = deviceModel;
            log.Process_Name__c = requestType;
            log.Opportunity__c = opportunityId;
            log.Opportunity_Property__c = opportunityPropertyId;
            log.Property_Inventory__c = propertyInventoryId;
            
            Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();  
            Schema.DescribeSObjectResult d = gd.get('Service_Logs__c').getDescribe();
            String recordTypeId = (d.getRecordTypeInfosByName().get('Mobile Web Service Logs').getRecordTypeId()); 
            log.RecordTypeId = recordTypeId;
        }
    }
    
    public static void insertLog(String requestType, Map<String, String> headers, Id opportunityId, Id opportunityPropertyId, Id propertyInventoryId) {
        
        RestServiceLogger logger = new RestServiceLogger(requestType, headers, opportunityId, opportunityPropertyId, propertyInventoryId);
        
        if (logger != null && logger.log != null)
            insert logger.log;
    }
}