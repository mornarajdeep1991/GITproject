/**
 * The controller for the custom aura component to generate SPAs
*/
public class EGY_GenerateSPA_CustomController {
    
    @AuraEnabled
    public static Opportunity getOpportunity(String oppId){
        List<Opportunity> opps = [select Id, Name from Opportunity where Id = :oppId];
        return (opps.size() > 0)? opps[0] : null;
    }
    
    @AuraEnabled
    public static List<Contact> getContacts(String accountId){
        return [select Id, Name from Contact where AccountId = :accountId];
    }
    
    @AuraEnabled
    public static List<Loop__DDP_Integration_Option__c> getDeliveryOptions(String packageId){
        return [select Id, Name from Loop__DDP_Integration_Option__c where Loop__DDP__c = :packageId];
    }
    
    @AuraEnabled
    public static List<Loop__DDP_File__c> getDocumentNames(String packageId){
        return [select Id, Loop__Section_Label__c, Loop__Order__c 
                from Loop__DDP_File__c where Loop__DDP__c = :packageId
                order by Loop__Order__c ASC
               ];
    }
    
    @AuraEnabled
    public static void generateSPA(String oppId, String deliveryMethodId, String packageId, String documentName) {
        update new Opportunity(Id = oppId, Template_Name__c = documentName);
        RestDrawloopServiceCls.generateDocument(oppId, packageId, documentName, deliveryMethodId);
    }
    
    @AuraEnabled
    public static List<Opportunity_Property__c> getUnitData(String oppId){
        return [select Id, cm_Opportunity__r.AccountId, cm_Property_Inventory__r.Drawloop_Template__c
                from Opportunity_Property__c WHERE cm_Opportunity__c = :oppId LIMIT 1 
               ];
    }
}