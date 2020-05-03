/************************************************************************************
* Name          : EGY_ManageBulkInventoryCtrl                                                
* Description   : Controller class for lightning component EGY_ManageInventory                                             
* Created Date  : 27/05/2018                                                    
* Created By    : Adeel Ahmad  (4C)  
* Jira/Req By   :                                                                                                                                           
* -----------------------------------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
************************************************************************************/
public with sharing class EGY_ManageBulkInventoryCtrl{  
    /************************************************************************************
    Method      :  fetchFieldOptions
    Params      :  filterName
    Description :  Method to get picklist values as we can't use apex:inputField in lightning components
    Version :         1.0
    ************************************************************************************/
    @AuraEnabled
    public static Map<String, String> fetchFieldOptions(string filter, string selectedProperties, string selectedCampaigns, String selectedBuilding){
        String attributeCategory = 'U';
        Map<String, String> fieldOptions = new Map<String, String>();
        LIST<Campaign_User__c> userCampaigns = [SELECT cm_Campaign__c,cm_Campaign__r.name,cm_User__c FROM Campaign_User__c where cm_User__c=: UserInfo.getUserId()];
        SET<Id> campaignIds = new SET<Id>();
        SET<String> propertyStatuses = new SET<String>{'Available', 'Blocked'};
        SET<Id> propertyInventoryIds = CM_EmaarUtils.getAccessableInventoryIds();

        if(filter == 'CampaignsFilterOption'){
            fieldOptions.put('--All--', '');
        }        
        for(Campaign_User__c objcm:userCampaigns){
            if(filter == 'CampaignsFilterOption' || filter == 'campaignSelect'){
                fieldOptions.put(objcm.cm_Campaign__r.Name, objcm.cm_Campaign__c);
            }
            campaignIds.add(objcm.cm_Campaign__c);
        }

        //Property Names
        if(filter == 'propertyNameFilterOption'){
            fieldOptions.put('--All--', '');
            for(Property__c ar: [Select id, name,Property_Name__c from Property__c where Property_Name__c!=null and Active_Property__c = true order by Property_Name__c]){
                fieldOptions.put(ar.Property_Name__c, ar.Id);
            }
        }

        String query = 'Select Property_Name__c,Property_Type__c,Location__r.Building__c,name,Property_Status__c ,Location_Code__c,Type__c,Unit_Model__c,Type_Confirm__c,Sales_Rooms__c,Blocked_By_Profile__c '+ 
                        + 'FROM property_inventory__c '
                        + 'WHERE Attribute_Category__c =:attributeCategory AND Property_Status__c IN :propertyStatuses';
        if(String.isNotBlank(selectedProperties)){
            LIST<String> selectedPList = selectedProperties.split(';');
            query += ' AND Property__c IN :selectedPList ';
        }
        //query += ' AND ID IN:propertyInventoryIds ';
                         
        LIST<Property_Inventory__c> pInventories = Database.query(query);                        

        for(property_inventory__c units:pInventories){
            

            if(filter == 'buildingNameFilterOption'){
                fieldOptions.put(units.Location__r.Building__c, units.Location__r.Building__c);
            }

            if(filter == 'unitTypeFilterOption'){
                fieldOptions.put(units.Type__c, units.Type__c);
            }

            if(filter == 'unitModelFilterOption'){
                fieldOptions.put(units.Unit_Model__c, units.Unit_Model__c);
            }
            
             if(filter == 'confirmTypeFilterOption'){
                fieldOptions.put(units.Type_Confirm__c, units.Type_Confirm__c);
                
            }

            if(filter == 'bedRoomsFilterOption'){
                fieldOptions.put(units.Sales_Rooms__c,units.Sales_Rooms__c);
            }
        }

        return fieldOptions;
    }

    /* Method to get dependent picklists */
    @AuraEnabled  
    public static Map<String,List<String>> getDependentOptionsImpl(string objApiName , string contrfieldApiName , string depfieldApiName){
        String profileName = [Select Name from Profile where Id = :Userinfo.getProfileId()].Name;

        system.debug(objApiName + '##' + contrfieldApiName + '###' + depfieldApiName);
           
        String objectName = objApiName.toLowerCase();
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
            //get the string to sobject global map
        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
        
        System.debug('@@objGlobalMap='+objGlobalMap);

        if (!Schema.getGlobalDescribe().containsKey(objectName)){
            System.debug('OBJNAME NOT FOUND --.> ' + objectName);
            return null;
         }
        
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        if (objType==null){
            return objResults;
        }
        Bitset bitSetObj = new Bitset();
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        //Check if picklist values exist
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            System.debug('FIELD NOT FOUND --.> ' + controllingField + ' OR ' + dependentField);
            return objResults;     
        }
        
        List<Schema.PicklistEntry> contrEntries = objFieldMap.get(controllingField).getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> depEntries = new LIST<Schema.PicklistEntry>();
        MAP<String, String> userRole = EGY_ManageBulkInventoryCtrl.getUserRole();

        if(depfieldApiName == 'Blocked_Type__c'){
            for(Schema.PicklistEntry pEntry : objFieldMap.get(dependentField).getDescribe().getPicklistValues()){
                if(pEntry.getValue() != 'Corporate' && pEntry.getValue() != 'Development'){
                    depEntries.add(pEntry);
                }else if( ( pEntry.getValue() == 'Corporate' || pEntry.getValue() == 'Development' ) && ( ( !userRole.isEmpty() && userRole.get(UserInfo.getUserId()) == 'EGY_Development_Manager' ) || ( profileName == 'System Administrator' ))){
                    depEntries.add(pEntry);
                }
            }
        }else{
            depEntries = objFieldMap.get(dependentField).getDescribe().getPicklistValues();
        }

        System.debug('@@adeel='+depEntries);

         objFieldMap = null;
        List<Integer> controllingIndexes = new List<Integer>();
        for(Integer contrIndex=0; contrIndex<contrEntries.size(); contrIndex++){            
            Schema.PicklistEntry ctrlentry = contrEntries[contrIndex];
            String label = ctrlentry.getLabel();
            objResults.put(label,new List<String>());
            controllingIndexes.add(contrIndex);
        }
        List<Schema.PicklistEntry> objEntries = new List<Schema.PicklistEntry>();
        List<PicklistEntryWrapper> objJsonEntries = new List<PicklistEntryWrapper>();
        for(Integer dependentIndex=0; dependentIndex<depEntries.size(); dependentIndex++){            
               Schema.PicklistEntry depentry = depEntries[dependentIndex];
               objEntries.add(depentry);
        } 
        objJsonEntries = (List<PicklistEntryWrapper>)JSON.deserialize(JSON.serialize(objEntries), List<PicklistEntryWrapper>.class);
        List<Integer> indexes;
        for (PicklistEntryWrapper objJson : objJsonEntries){
            if (objJson.validFor==null || objJson.validFor==''){
                continue;
            }
            indexes = bitSetObj.testBits(objJson.validFor,controllingIndexes);
            for (Integer idx : indexes){                
                String contrLabel = contrEntries[idx].getLabel();
                objResults.get(contrLabel).add(objJson.label);
            }
        }
        objEntries = null;
        objJsonEntries = null;
        system.debug('objResults--->' + objResults);
        return objResults;
    }

    /************************************************************************************
    Method      :  doSearch
    Params      :  location code, building name, unit type, unit model, bedrooms, opportunityId
    Description :  Method to perform search on property inventory based on input values
    Params      :  property name, campaign, location_code, building, unit model, unit type, bedroom, property type, block type, block reason
    Version :         1.0
    ************************************************************************************/
    @AuraEnabled
    public static LIST<Property_Inventory__c> doSearch(String selectedProperties, String selectedCampaigns, String location_code, String buildingName, String unitModel, String unitType, String confirmType, String bedrooms, String propertyType, String blockType, String blockReason, String queryFields){
        System.debug('params = ');
        System.debug('@@selectedProperties'+selectedProperties);
        System.debug('@@selectedCampaigns'+selectedCampaigns);
        System.debug('@@location_code'+location_code);
        System.debug('@@buildingName'+buildingName);
        System.debug('@@unitModel'+unitModel);
        System.debug('@@unitType'+unitType);
        System.debug('@@confirmType'+confirmType);
        System.debug('@@bedrooms'+bedrooms);
        System.debug('@@propertyType'+propertyType);
        System.debug('@@blockType'+blockType);
        System.debug('@@blockReason'+blockReason);
        System.debug('@@ params ends @@');

        LIST<String> propertyBlockedTypes = new LIST<String>();
        MAP<String, String> userRole = EGY_ManageBulkInventoryCtrl.getUserRole();
        String profileName = [Select Name from Profile where Id = :Userinfo.getProfileId()].Name;

        if(  ( userRole.isEmpty() || userRole.get(UserInfo.getUserId()) != 'EGY_Development_Manager' ) && profileName != 'System Administrator' ){
            propertyBlockedTypes.add('Corporate');
            propertyBlockedTypes.add('Development');
        }

        SET<String> propertyStatuses = new SET<String>();
        if(String.isBlank(propertyType) || propertyType == '--- None ---'){
            propertyStatuses.add('Available');
            propertyStatuses.add('Blocked');
        }else{
            if(propertyType == 'Sale'){
                propertyStatuses.add('Available');                
            }else{
                propertyStatuses.add(propertyType);
            }
        }
        //only inventories with attribute U needs to be display
        String attributeCategory = 'U';
        SET<Id> campaignIds = new SET<Id>();
        for(Campaign_User__c objcm:[SELECT cm_Campaign__c,cm_Campaign__r.name,cm_User__c FROM Campaign_User__c where cm_User__c=: UserInfo.getUserId()]){
            campaignIds.add(objcm.cm_Campaign__c);
        }
        SET<Id> propertyInventoryIds = new SET<Id>();

        string strQuery = 'Select ';
        for(String s : queryFields.split(',')){
            if(s != 'Id' && s != 'Location_ID__c'){
                strQuery += s + ', ';
            }
        }
        strQuery += ' Id, cm_Related_Campaign__r.Name, cm_Blocked_By__r.name, Location_ID__c FROM property_inventory__c where Attribute_Category__c =:attributeCategory AND Property_Status__c IN :propertyStatuses ';
        

        string strConditions = '';
        string blockedStatus = 'Blocked';
        string availableStatus = 'Available';
        if(propertyBlockedTypes.size() > 0){
            System.debug('@@HERE@@'+propertyBlockedTypes);
            strConditions += ' AND ( ( Property_Status__c =:blockedStatus AND Blocked_Type__c NOT IN:propertyBlockedTypes ) OR ( Property_Status__c =:availableStatus ) ) ';
        }
        
        if(String.isNotBlank(selectedCampaigns) && selectedCampaigns != 'All'){
            LIST<String> selectedCampaignsIds = selectedCampaigns.split(';');
            System.debug('ADEEL:selectedCampaignsIds'+selectedCampaignsIds);
            strConditions += ' AND cm_Related_Campaign__c IN:selectedCampaignsIds ';
        }

        if(String.isNotBlank(selectedProperties) && selectedProperties != 'All'){
            LIST<String> selectedPropertiesIds = selectedProperties.split(';');
            strConditions += ' AND Property__c =:selectedPropertiesIds ';
        }

        if(String.isNotBlank(location_code)){
            strConditions += ' AND Location_Code__c LIKE \'%'+location_code+'%\' ';   
        }
        
        if(String.isNotBlank(buildingName)){
            strConditions += ' AND Location__r.Building__c =:buildingName ';   
        }

        if(String.isNotBlank(propertyType)){
            //strConditions += ' AND Property_Status__c =:propertyType ';  
        }

        if(String.isNotBlank(unitModel)){
            strConditions += ' AND Unit_Model__c =:unitModel ';
        }
        
        if(String.isNotBlank(confirmType)){
            strConditions += ' AND Type_Confirm__c =:confirmType ';
        }else if(String.isBlank(confirmType)){
            
             strConditions += ' AND Type_Confirm__c IN(\'Y\',\'N\',\'\')';
        }

        if(String.isNotBlank(bedrooms)){
            strConditions += ' AND Sales_Rooms__c =:bedrooms ';
        }

        if(String.isNotBlank(blockType) && blockType != '--- None ---'){
            strConditions += ' AND Blocked_Type__c =:blockType ';
        }

        if(String.isNotBlank(blockReason) && blockReason != '--- None ---'){
            strConditions += ' AND Block_Reason__c =:blockReason ';            
        }

        strQuery = strQuery + strConditions +' ORDER BY LastModifiedDate DESC LIMIT 10000';
        System.debug('@@propertyStatuses='+propertyStatuses);
        System.debug('@@Query='+strQuery);

        list<Property_Inventory__c> pInventories = Database.query(strQuery);
        return pInventories;
    }

    @AuraEnabled
    public static string updateProperties(LIST<Property_Inventory__c> propertyInventories, String selectedCampaign, String propertyType, Boolean isReleased, String blockType, String blockReason, String remarks){
        string msg = '';
        System.debug('@@propertyInventories'+propertyInventories);
        System.debug('@@selectedCampaign='+selectedCampaign);
        try{            
            String UserName = UserInfo.getName(); 
            map<String,Block_Reason_Codes__c> mpReasonCodes = Block_Reason_Codes__c.getAll();
            string blockreasonCode =  mpReasonCodes.containsKey(blockReason) ? mpReasonCodes.get(blockReason).API_Value__c :blockReason;
            LIST<Property_Inventory__c> updateables = new LIST<Property_Inventory__c>();
            LIST<Property_Inventory__c> finalListToUpdate = new LIST<Property_Inventory__c>();
            //Call webservice only if property inventory status updates

            Boolean callWebService = true;
            if(propertyType == '--- None ---'){
                callWebService = false;
            }

            string recordXML='';
            Integer i = 0;
            LIST<LIST<Property_Inventory__c>> finalPIList = new LIST<LIST<Property_Inventory__c>>();
            LIST<Property_Inventory__c> lstMiddleWrap = new LIST<Property_Inventory__c>();
            MAP<Id, Property_Inventory__c> invIdToInvMap = new MAP<Id, Property_Inventory__c>();
            for(Property_Inventory__c pi : propertyInventories){
                if(lstMiddleWrap.size()==Integer.valueOf(system.label.Inventory_batch_Limit)){
                    finalPIList.add(lstMiddleWrap);
                    lstMiddleWrap = new List<Property_Inventory__c>();
                }
                lstMiddleWrap.add(pi);
                invIdToInvMap.put(pi.Id, pi);
           }


           if(!lstMiddleWrap.isEmpty())
                finalPIList.add(lstMiddleWrap);

           System.debug('@@finalPIList'+finalPIList);

           string PropertyXML= '';
            List<Service_Logs__c> lstLogs = new List<Service_Logs__c>();
            string errorMessage='';
            if(callWebService){
                for(List<Property_Inventory__c> piWrap: finalPIList){
                    PropertyXML='<XX_INVENTORY_BLOCK>';
                    PropertyXML+='<XX_INVENTORY_BLOCK_T>';
                    recordXML = '';
                    for(Property_Inventory__c pi: piWrap){
                        System.debug('@@pi='+pi);
                        Property_Inventory__c pw = new Property_Inventory__c(Id = pi.Id);
                        pw.Property_Type__c = propertyType; 
                        if(propertyType == 'Sale')
                            pw.Property_Status__c = 'Available';
                        else if(propertyType == 'Blocked')
                           pw.Property_Status__c = 'Blocked';
                        else 
                          pw.Property_Status__c = propertyType;
                        pw.Location_ID__c = pi.Location_ID__c;

                        string parameters = '';
                        recordXML+='<XX_INVENTORY_BLOCK_O>';
                        recordXML+='<USER_NAME>'+UserName+'</USER_NAME>';
                        recordXML+='<SOURCE>SALESFORCE</SOURCE>';
                        recordXML+='<LOCATION_ID>'+pi.Location_ID__c+'</LOCATION_ID>';
                        recordXML+='<PRICE></PRICE>';
                        recordXML+='<PROPERTY_TYPE>'+pw.Property_Type__c+'</PROPERTY_TYPE>';
                        recordXML+='<PROPERTY_STATUS>'+pw.Property_Status__c+'</PROPERTY_STATUS>';
                        recordXML+='<BLOCK_REASON_CODE>'+blockreasonCode+'</BLOCK_REASON_CODE>';
                        recordXML+='<BLOCKED_REASON_REMARKS>'+remarks+'</BLOCKED_REASON_REMARKS>';
                        recordXML+='</XX_INVENTORY_BLOCK_O>';

                        if(String.isNotBlank(selectedCampaign)){
                            pw.cm_Related_Campaign__c = selectedCampaign;
                        }else{
                            //pw.cm_Related_Campaign__c = null;                        
                        }
                            
                        pw.Blocked_Type__c = blockType;
                        pw.Block_Reason__c = blockReason;
                        pw.Block_Remarks__c = remarks;
                        pw.Blocked_reason_code__c = blockreasonCode;
                        pw.Is_Released__c = isReleased;

                        if(propertyType == 'Blocked'){
                            pw.cm_Blocked_by__c = UserInfo.getUserId();
                            pw.cm_Blocked_Date__c = system.today();
                        }else{                            
                          if(propertyType == 'Sale'){
                              pw.Blocked_Type__c = '';
                              pw.Block_Reason__c = '';
                              pw.Block_Remarks__c = '';
                              pw.Blocked_reason_code__c ='';
                              pw.cm_Blocked_by__c = null;
                              pw.cm_Blocked_Date__c = null;
                          }
                        }
                        updateables.add(pw);
                    }
                    system.debug('updateables'+updateables);
                    
                    if(recordXmL != ''){
                      PropertyXML=PropertyXML+recordXML.trim();
                      PropertyXML=PropertyXML+'</XX_INVENTORY_BLOCK_T>';
                      PropertyXML=PropertyXML+'</XX_INVENTORY_BLOCK>';
                      PropertyXML = PropertyXML.replaceAll('null','');
                      PropertyXML = PropertyXML.trim();
                      System.debug('>>>>>>>propertyXML>>>>>>>>>>>>'+propertyXML+'>>>>>>>index>>>>>>>>>'+i);
                      
                      Service_Logs__c objlog = new Service_Logs__c(); 
                      objlog.Request__c = propertyXML;
                      //objlog.Response__c = mpWholeXML.get(inv.Location_ID__c);
                      objlog.Process_Time__c = system.now();
                      objlog.Process_Name__c = 'Bulk Inventory - Update';
                      objlog.Log_Type__c = 'DEBUG';
                      //objlog.Error_Message__c = mpErrors.get(inv.Location_ID__c); 
                      //objLog.Property_Inventory__c = inv.Id;
                      lstLogs.add(objLog);
                      
                      
                      emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element eleRes = new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
                        if(!Test.isRunningTest()){
                            eleRes = EmaarWebServiceUtils.UpdatePropertyBulk(PropertyXML);                        
                        }else{
                            eleRes.status = 'SUCCESS';
                            String xml = '<P_RESULT_XML xmlns="http://xmlns.oracle.com/pcbpel/adapter/db/APPS/XX_MOBILE_INT_PKG/PERFORM_ACTION/"> <XX_INVENTORY_BLOCK xmlns=""> <XX_INVENTORY_BLOCK_T> <XX_INVENTORY_BLOCK_O> <LOCATION_ID>380740</LOCATION_ID> <STATUS>SUCCESS</STATUS> <MESSAGE/> </XX_INVENTORY_BLOCK_O> </XX_INVENTORY_BLOCK_T> </XX_INVENTORY_BLOCK> </P_RESULT_XML>';
                            eleRes.resultXML = xml;
                        }
                      System.debug('@@@eleRes'+eleRes);
                      if(eleRes.status=='SUCCESS'){
                        //Parsing response and get the individual response from resulting call
                        DOM.Document xmlDOC = new DOM.Document();
                        xmlDOC.load(eleRes.resultXML);
                        DOM.XMLNode rootElement = xmlDOC.getRootElement();
                        System.debug('@@rootElement'+rootElement);
                        
                        Map<string,string> mpSuccess = new Map<string,string>();
                        Map<string,string> mpErrors = new Map<String,string>();
                        Map<string,string> mpWholeXML = new Map<String,string>();
                        for(Dom.XMLNode child1: rootElement.getChildElements()){
                            for(Dom.XMLNode child2: child1.getChildElements()){
                                for(Dom.XMLNode child3: child2.getChildElements()){
                                    System.debug('>>>>>>>>>>>'+child3.getName());
                                    string locId = child3.getChildElement('LOCATION_ID',null).getText();
                                    string status = child3.getChildElement('STATUS',null).getText();
                                    string message = child3.getChildElement('MESSAGE',null).getText();
                                    
                                    if(status == 'ERROR'){
                                        mpErrors.put(locId,message);
                                    }
                                    else{
                                        mpSuccess.put(locId,message);  
                                    }
                                    
                                    string msgVal = 'Location ID:'+locId+'Status:'+status+'Message:'+message;
                                    mpWholeXML.put(locId,msgVal);
                                }
                            }
                        }
                        
                        if(!mpSuccess.isempty()){
                            
                            for(Property_Inventory__c inv: updateables){
                                if(mpSuccess.containsKey(inv.Location_ID__c)){
                                    System.debug('@@successfully updated'+inv.Location_ID__c);
                                    finalListToUpdate.add(inv);                    
                                    
                                    Service_Logs__c success_log = new Service_Logs__c(); 
                                    success_log.Response__c = mpWholeXML.get(inv.Location_ID__c);
                                    success_log.Process_Time__c = system.now();
                                    success_log.Process_Name__c = 'Bulk Inventory - Update';
                                    success_log.Log_Type__c = 'SUCCESS';
                                    success_log.Error_Message__c = mpSuccess.get(inv.Location_ID__c);
                                    success_log.Property_Inventory__c = inv.Id;
                                    lstLogs.add(success_log);
                                }
                                
                                if(mpErrors.containsKey(inv.Location_ID__c)){
                                    Service_Logs__c error_log = new Service_Logs__c(); 
                                    error_log.Response__c = mpWholeXML.get(inv.Location_ID__c);
                                    error_log.Process_Time__c = system.now();
                                    error_log.Process_Name__c = 'Bulk Inventory - Update';
                                    error_log.Log_Type__c = 'ERROR';
                                    error_log.Error_Message__c = mpErrors.get(inv.Location_ID__c);
                                    error_log.Property_Inventory__c = inv.Id;
                                    lstLogs.add(error_log);
                                }
                            }
                        }
                        for(String str: mpErrors.keyset()){
                            msg += 'Error! ' + mpErrors.get(str) + '<br />';
                        }
                      }
                      else{
                         msg += 'Error! ' + eleRes.errorMessage;
                      } 
                    }
                }
            } //Only if something needs to be updated from service call.
            System.debug('@@finalListToUpdate'+finalListToUpdate);
            if(callWebService == false){
                for(Property_Inventory__c pi : propertyInventories){
                    Property_Inventory__c pic = new Property_Inventory__c(Id = pi.Id);
                    if(String.isNotBlank(selectedCampaign)){
                        pic.cm_Related_Campaign__c = selectedCampaign;
                    }else{
                        //pic.cm_Related_Campaign__c = null;                        
                    }
                    finalListToUpdate.add(pic);
                }                
            }
            if(finalListToUpdate.size() > 0){
                //upsert finalListToUpdate;
               	WithoutSharingUtil.upsertPropertyInventories(finalListToUpdate);
                msg = 'Success! Property Inventories has been successfully updated.';
            }
            if(!lstLogs.isEmpty())
                insert lstLogs;

        }catch(Exception e){
            msg = 'Error! ' + e.getMessage();
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
                system.debug('label'+label);
                if(fieldNameToFieldLabelMap.get(f.getFieldPath()) != null){
             
                    label = fieldNameToFieldLabelMap.get(f.getFieldPath());
                    system.debug('label in if'+label);
                }
                flds.add(new FieldSetMembersWrapper(label, f.getFieldPath()));
            }            
        }
        system.debug('flds'+flds);
        return flds;
    }

    /************************************************************************************
    Method      :  removeCampaign
    Params      :  LIST< Property_Inventory__c>
    Description :  remove campaign from selected items
    Version     :  1.0
    ************************************************************************************/
    @AuraEnabled
    public static string removeCampaignFromInventories(LIST<Property_Inventory__c> selectedProperties){
        string msg = '';
        try{            
            LIST<Property_Inventory__c> updateables = new LIST<Property_Inventory__c>();
            for(Property_Inventory__c pi : selectedProperties){
                Property_Inventory__c pic = new Property_Inventory__c(Id = pi.Id);
                pic.cm_Related_Campaign__c = null;                        
                updateables.add(pic);
            }                
            if(updateables.size() > 0){
                WithoutSharingUtil.upsertPropertyInventories(updateables); //upsert updateables;
                msg = 'Success! Property Inventories has been successfully updated.';
            }
        }catch(Exception e){
            msg = 'Error! ' + e.getMessage();
        }
        return msg;        
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

    public class PicklistEntryWrapper{
        public PicklistEntryWrapper(){}
        public String label {get;set;}
        public String validFor {get;set;}
    }

    //Method to get logged in user role
    public static MAP<String, String> getUserRole(){
        String uRoleId = UserInfo.getUserRoleId();
        MAP<String, String> userIdToRoleMap = new MAP<String, String>();
        if(uRoleId != null){
            UserRole role = [SELECT Id, DeveloperName FROM UserRole WHERE Id =:uRoleId];
            userIdToRoleMap.put(UserInfo.getUserId(), role.DeveloperName);
        }
        return userIdToRoleMap;
    }
   
}