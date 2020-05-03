/************************************************************************************
* Name          : EGY_ManageInventoryCtrl                                                
* Description   : Controller class for lightning component EGY_ManageInventory                                             
* Created Date  : 19/05/2018                                                    
* Created By    : Adeel Ahmad  (4C)  
* Jira/Req By   :                                                                                                                                           
* -----------------------------------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
************************************************************************************/
public with sharing class EGY_ManageInventoryCtrl{  
    /************************************************************************************
    Method      :  fetchFieldOptions
    Params      :  filterName
    Description :  Method to get picklist values as we can't use apex:inputField in lightning components
    Version :         1.0
    ************************************************************************************/
    @AuraEnabled
    public static Map<String, String> fetchFieldOptions(string filter, string propertyName){
        Map<String, String> fieldOptions = new Map<String, String>();
        LIST<Campaign_User__c> userCampaigns = [SELECT cm_Campaign__c,cm_Campaign__r.name,cm_User__c FROM Campaign_User__c where cm_User__c=: UserInfo.getUserId()];
        SET<Id> campaignIds = new SET<Id>();
        SET<String> propertyStatuses = new SET<String>{'Available', 'Blocked'};

        for(Campaign_User__c objcm:userCampaigns){
            if(filter == 'CampaignsFilterOption'){
                fieldOptions.put(objcm.cm_Campaign__r.Name, objcm.cm_Campaign__c);
            }
            campaignIds.add(objcm.cm_Campaign__c);
        }
        SET<Id> propertyInventoryIds = CM_EmaarUtils.getAccessableInventoryIds();
        
        String query = 'Select Property_Name__c,Property_Type__c,Location__r.Building__c,name,Property_Status__c ,Location_Code__c,Type__c,Unit_Model__c,Sales_Rooms__c,Blocked_By_Profile__c '+ 
                        + 'FROM property_inventory__c '
                        + 'WHERE Property_Status__c IN :propertyStatuses';
        if(!Test.isRunningTest())
            query += ' AND ID IN : propertyInventoryIds ';
        
        if(String.isNotBlank(propertyName)){
            query += ' AND Property_Name__c=:propertyName';
        }                        
        LIST<Property_Inventory__c> pInventories = Database.query(query);                        

        for(property_inventory__c units:pInventories){
            if(filter == 'propertyNameFilterOption'){
                fieldOptions.put(units.Property_Name__c, units.Property_Name__c);
            }

            if(filter == 'buildingNameFilterOption'){
                fieldOptions.put(units.Location__r.Building__c, units.Location__r.Building__c);
            }

            if(filter == 'propertyTypeFilterOption'){
                fieldOptions.put(units.Type__c, units.Type__c);
            }

            if(filter == 'unitModelFilterOption'){
                fieldOptions.put(units.Unit_Model__c, units.Unit_Model__c);
            }

            if(filter == 'bedRoomsFilterOption'){
                fieldOptions.put(units.Sales_Rooms__c,units.Sales_Rooms__c);
            }
        }

        if(filter == 'statusFilterOption'){
            fieldOptions.put('Available','Available');
            fieldOptions.put('Blocked','Blocked');
        }
        return fieldOptions;
    }

    /************************************************************************************
    Method      :  doSearch
    Params      :  location code, building name, unit type, unit model, bedrooms, opportunityId
    Description :  Method to perform search on property inventory based on input values
    Version :         1.0
    ************************************************************************************/
    @AuraEnabled
    public static LIST<Property_Inventory__c> doSearch(String selectedCampaign, String propertyName, String status, String location_code, String buildingName, String propertyType, String unitModel, String bedrooms, String queryFields){

        SET<String> propertyStatuses = new SET<String>{'Available', 'Blocked'};
        SET<Id> campaignIds = new SET<Id>();
        SET<Id> propertyInventoryIds = new SET<Id>();
        if(String.isBlank(selectedCampaign) || selectedCampaign == 'All'){
            propertyInventoryIds = CM_EmaarUtils.getAccessableInventoryIds();
        }else{
            propertyInventoryIds = CM_EmaarUtils.getInventoryByCampaignId(selectedCampaign);
        }
        LIST<String> propertyBlockedTypes = new LIST<String>();
        MAP<String, String> userRole = EGY_ManageBulkInventoryCtrl.getUserRole();
        if( userRole.isEmpty() || userRole.get(UserInfo.getUserId()) != 'EGY_Development_Manager' ){
            propertyBlockedTypes.add('Corporate');
            propertyBlockedTypes.add('Development');
        }


        for(Campaign_User__c objcm:[SELECT cm_Campaign__c,cm_Campaign__r.name,cm_User__c FROM Campaign_User__c where cm_User__c=: UserInfo.getUserId()]){
            campaignIds.add(objcm.cm_Campaign__c);
        }

        string strQuery = 'Select ';
        for(String s : queryFields.split(',')){
            if(s != 'Id'){
                strQuery += s + ', ';
            }
        }
        strQuery += ' Id, cm_Blocked_By__r.Name FROM Property_Inventory__c WHERE Property_Status__c IN :propertyStatuses ';

        string strConditions = '';
        
        if(!Test.isRunningTest())
            strConditions += ' AND ID IN :propertyInventoryIds ';
        
        string blockedStatus = 'Blocked';
        string availableStatus = 'Available';
        if(propertyBlockedTypes.size() > 0){
            strConditions += ' AND ( ( Property_Status__c =:blockedStatus AND Blocked_Type__c NOT IN:propertyBlockedTypes ) OR ( Property_Status__c =:availableStatus ) ) ';
        }

        if(String.isNotBlank(propertyName)){
            strConditions += ' AND Property_Name__c =:propertyName ';
        }

        if(String.isNotBlank(status)){
            strConditions += ' AND Property_Status__c = '+'\''+ status+ '\' ';
        }

        if(String.isNotBlank(location_code)){
            strConditions += ' AND Location_Code__c LIKE \'%'+location_code+'%\' ';   
        }
        
        if(String.isNotBlank(buildingName)){
            strConditions += ' AND Location__r.Building__c LIKE \'%'+buildingName+'%\' ';   
        }

        if(String.isNotBlank(propertyType)){
            strConditions += ' AND Type__c =:propertyType ';  
        }

        if(String.isNotBlank(unitModel)){
            strConditions = ' AND Unit_Model__c =:unitModel ';
        }

        if(String.isNotBlank(bedrooms)){
            strConditions = ' AND Sales_Rooms__c =:bedrooms ';
        }

        strQuery = strQuery + strConditions +' ORDER BY LastModifiedDate DESC LIMIT 1000';

        System.debug('@@Query='+strQuery);

        list<Property_Inventory__c> pInventories = Database.query(strQuery);
        return pInventories;
    }

    @InvocableMethod(label='Auto-Unblock Unit')
    public static void unblockUnit(List<Id> unitIds){
        String unitId = unitIds[0];
        EGY_ManageInventoryCtrl.setPropertyInventoryStatus(unitId, 'Sale', '');
    }
    
    @AuraEnabled
    public static string setPropertyInventoryStatus(String pInvId, String status, String comments){
        string msg = '';
        try{
            string locationCode = '';
            for(property_inventory__c pro : [select id,Location_Code__c from Property_Inventory__c where id=:pInvId]){
                locationCode = pro.Location_Code__c;
            }
            RestServiceToUpdatePropertyType.ResponseHandler response = new RestServiceToUpdatePropertyType.ResponseHandler();
            response = RestServiceToUpdatePropertyType.UpdatePropertyType(status, pInvId, comments);                

            if(response.Success == true){
                    msg += response.Message;
            }else{
                msg += 'Error! ' + response.Message;
            }
        }catch(exception ex){
            msg = ex.getMessage();
        }
        return msg;
    }

    /************************************************************************************
    Method      :  fetchFields
    Params      :  string
    Description :  fetching fields for a particular component.
    Version     :  1.0
    ************************************************************************************/
    @AuraEnabled
    public static List<FieldSetMembersWrapper> fetchFields(String component) {
        String orgId = String.valueOf(CM_EmaarUtils.getOrgId('','',''));
        List<FieldSetMembersWrapper> flds = new List<FieldSetMembersWrapper>();
        MAP<String, String> fieldNameToFieldLabelMap = CM_EmaarUtils.getFieldNameToFieldLabelMap(orgId);
        LIST<Region_To_Fieldset_Settings__mdt> settings = [SELECT Id, Region__r.Region__c, 
                                                            Lightning_Component__c, QualifiedApiName 
                                                            FROM Region_To_Fieldset_Settings__mdt
                                                            WHERE Lightning_Component__c =: component
                                                            AND Region__c IN (SELECT Id FROM Emaar_Region__mdt WHERE Region__c =:orgId)];
        if(settings.size() > 0){
            String fieldSetName = settings[0].QualifiedApiName;
            List<Schema.FieldSetMember> fieldSetMemberList =  CM_EmaarUtils.readFieldSet(fieldSetName,'Property_Inventory__c');
            for(Schema.FieldSetMember f :fieldSetMemberList) {
                String label = f.getLabel();
                if(fieldNameToFieldLabelMap.get(f.getFieldPath()) != null){
                    label = fieldNameToFieldLabelMap.get(f.getFieldPath());
                }
                flds.add(new FieldSetMembersWrapper(label, f.getFieldPath()));
            }            
        }
        return flds;
    }

    public class FieldSetMembersWrapper{
        @AuraEnabled
        public String label { get;set; }
        @AuraEnabled
        public String name { get;set; }

        public FieldSetMembersWrapper(String label, String name) {
            this.label = label;
            this.name = name;
        }
    }

}