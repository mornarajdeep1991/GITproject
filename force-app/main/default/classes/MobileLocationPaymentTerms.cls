/************************************************************************************
* Name              : MobileLocationPaymentTerms
* Description       : A Rest webservice to convert a Lead into an Account.
* Created Date      : 28/11/2018
* Created By        : 4C
* Jira/Req By       :                                                                                                                                           
************************************************************************************/
@RestResource(urlMapping='/LocationPaymentTerms')
global class MobileLocationPaymentTerms {
    
    @HttpGet
    global static void httpGet() {
        system.debug('## MobileLocationPaymentTerms HTTP Get Started');
        
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        
        //Get Location Code from the Request URI
        String propertyInventoryId = request.params.get('pInventoryId');
        list<Property_inventory__c> lstproperty = [SELECT ID, Location__r.Location_ID__c FROM Property_Inventory__c WHERE Id = :propertyInventoryId];
        
        String locationId = '';
        for (Property_inventory__c inventory : lstproperty) {
            locationId = inventory.Location__r.Location_ID__c;
        }
        
        List<Cm_PaymentTerms.CampaignWrap> campaignWrapList = EGY_AddPropertiesCtrl.getUnitPaymentTerms(locationId);
        
        response.addHeader('content-type', 'application/json');        
        response.responseBody = Blob.valueOf(JSON.serialize(campaignWrapList));
        response.statusCode = 200;
    }
    
}