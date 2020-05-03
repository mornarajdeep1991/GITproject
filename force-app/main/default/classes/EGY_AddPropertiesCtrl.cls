/************************************************************************************
* Name              : EGY_AddPropertesCtrl                                                 
* Description       : Controller class for lightning component to add properties to opportunities                                          
* Created Date      :                                                     
* Created By        : Adeel Ahmad (adeel.ahmad@weare4c.com)    
* Jira/Req By       : Jira Ticket/Req Given by                                                                                                                                          
* -----------------------------------------------------------------------------------------------------------------------
* VERSION   Developer           Date            Description                                     Ticket/Reference                                                                    
* 1.0       Adeel Ahmad                         Controller class for lightning component        Jira Ticket no./                      
************************************************************************************/

public with sharing class EGY_AddPropertiesCtrl {
    /************************************************************************************
    Method      :  getOpportunityInfo
    Params      :  opportunityId
    Description :  Getting opportunity information by passing opportunity id
    Version :         1.0
    ************************************************************************************/
    @AuraEnabled
    public static Opportunity getOpportunityInfo(String oppId){
        Opportunity opp = [SELECT Id, Name, StageName, IsClosed FROM Opportunity WHERE id = :oppId ];
        return opp;
    }

    /************************************************************************************
    Method      :  fetchFieldOptions
    Params      :  filterName
    Description :  Method to get picklist values as we can't use apex:inputField in lightning components
    Version :         1.0
    ************************************************************************************/
    @AuraEnabled
    public static Map<String, String> fetchFieldOptions(string filter, String building){
        //Populating property inventory id's from campaign units, campaign users, etc
        SET<Id> propertyInventoryIds = CM_EmaarUtils.getAccessableInventoryIds();
        MAP<String, String> fieldOptions = CM_EmaarUtils.fieldsMapByQueryingFieldValue(filter, building, propertyInventoryIds);
        return fieldOptions;
    }

    /************************************************************************************
    Method      :  doSearch
    Params      :  location code, building name, unit type, unit model, bedrooms, opportunityId
    Description :  Method to perform search on property inventory based on input values
    Version :         1.0
    @Updates    : 07/10/2018 - Adeel - Added more parameters (String propertyId, String price, String campaignId) in doSearch
    ************************************************************************************/
    @AuraEnabled
    public static LIST<Property_Inventory__c> doSearch(String location_code, String buildingName, String unitType, String unitModel, String bedrooms, String propertyId, Integer minPrice, Integer maxPrice, String campaignId, String oppId, String queryFields){
        LIST<String> RTvalues = new LIST<String>(); //record type values
        list<string> lstStatusValues = new list<string>(); //Property status values
        SET<Id> setPackageIds = new SET<Id>(); //existing package ids, already added properties to opportunities

        //Getting recordTypeValues
        Id unitRecordTypeId =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        RTvalues.add(unitRecordTypeId);
        Id packageRecordTypeId =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Package').getRecordTypeId();
        RTvalues.add(packageRecordTypeId);

        //Properties status values
        lstStatusValues.add('Available');

        //Property Inventory Status
        String strStatus = 'Sale';

        //Populating property inventory id's from campaign units, campaign users, etc
        SET<Id> propertyInventoryIds = new SET<Id>();
        if(String.isBlank(campaignId)){
            propertyInventoryIds = CM_EmaarUtils.getAccessableInventoryIds();
        }else{
            propertyInventoryIds = CM_EmaarUtils.getInventoryByCampaignId(campaignId);
        }

        string strQuery = 'Select ';
        for(String s : queryFields.split(',')){
            if(s != 'Id'){
                strQuery += s + ', ';
            }
        }
        strQuery += ' Id FROM Property_Inventory__c WHERE ID IN:propertyInventoryIds  ';
        
        if(buildingName!=null && buildingName!=''){
            strQuery += ' AND Location__r.Building__c =: buildingName ' ;
        }
        if(location_code!=null && location_code!=''){
            strQuery += ' AND Location_Code__c LIKE \'%' + location_code + '%\' ' ;
        }
        if(unitModel!=null && unitModel!=''){
            strQuery += ' AND Unit_Model__c =:unitModel ' ;
        }
        if(bedrooms!=null && bedrooms != ''){
            strQuery += ' AND Sales_Rooms__c =:bedrooms ' ;
        }
        if(unitType!=null && unitType != ''){
            strQuery += ' AND Type__c =:unitType ' ;
        }

        if( minPrice != null && Integer.valueOf(minPrice) > 0 ){
            Integer minP = Integer.valueOf(minPrice);
            strQuery += ' AND Selling_Price__c >=:minP ' ;
        }
        if( maxPrice != null && Integer.valueOf(maxPrice) > 0 ){
            Integer maxP = Integer.valueOf(maxPrice);
            strQuery += ' AND Selling_Price__c <=:maxP ' ;
        }        

        if(String.isNotBlank(propertyId)){
            strQuery += ' AND Property__c=:propertyId';
        }     

        //Getting already added properties
        LIST<Property_Inventory__c> addedProperties = getAddedProperties(oppId,queryFields);

        strQuery = strQuery + ' AND Location__r.Active_End_Date__c > Today and Property_Status__c IN:lstStatusValues and Location_Code__c != null and ID not IN:addedProperties and cm_Inventory_Package__c = null and recordtypeId IN:RTvalues and Property_Type__c=:strStatus  order by Location_Code__c ASC';
        list<Property_Inventory__c> lstPropertyData = database.query(strQuery);
        return lstPropertyData;

    }

    /************************************************************************************
    Method      :  AddSelectedProperties
    Params      :  OpportunityId, comma separated list of property inventories
    Description :  Method to add property inventories agains selected opportunity.
    Version :         1.0
    ************************************************************************************/
    @AuraEnabled
    public static string AddSelectedProperties(String oppId, LIST<String> selectedPropertyInventories){
        String msg = '';
      try{
        MAP<Id, String> piRecordTypeIdToRecordTypeNameMap = new MAP<Id, String>();
        piRecordTypeIdToRecordTypeNameMap.put(Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId(), 'Unit');
        piRecordTypeIdToRecordTypeNameMap.put(Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Package').getRecordTypeId(), 'Package');
        
        SET<Id> packageIds = new SET<Id>();
        LIST<String> insertablePIIds =  selectedPropertyInventories;
        LIST<Property_Inventory__c> selectedPInventories = new LIST<Property_Inventory__c>();
        LIST<Opportunity_Property__c> insertableOppProperties = new LIST<Opportunity_Property__c>();

        for(Property_Inventory__c pi : [SELECT Id, recordTypeId, Selling_Price__c, VAT_Rate__c, VAT_Amount__c, Total_Amount__c FROM Property_Inventory__c WHERE ID IN :insertablePIIds]){
            if(piRecordTypeIdToRecordTypeNameMap.get(pi.recordTypeId) != null && piRecordTypeIdToRecordTypeNameMap.get(pi.recordTypeId) != 'Package'){
                selectedPInventories.add(pi);
            }else if(piRecordTypeIdToRecordTypeNameMap.get(pi.recordTypeId) != null && piRecordTypeIdToRecordTypeNameMap.get(pi.recordTypeId) == 'Package'){
                packageIds.add(pi.Id);
            }
        }

        if(packageIds != null && packageIds.size() > 0){
           list<Property_Inventory__c> lstPackageInventories = [Select Id,Property_Status__c,VAT_Rate__c, VAT_Amount__c, Total_Amount__c, Name,UNIT__c, recordTypeId,Type__c,Sales_Room__c,BUILDING__c,Unit_Model__c , PROPERTY_ID__c,Status_indicator__c, PROPERTY_Code__c, Property__c, Selling_price__c FROM Property_Inventory__c where cm_Inventory_Package__c IN:packageIds];
           if(lstPackageInventories!=null && lstPackageInventories.size() >0){
               selectedPInventories.addAll(lstPackageInventories);
           }
        }

        System.debug('@@selectedPInventories='+selectedPInventories);

        if(selectedPInventories != null && selectedPInventories.size() > 0){
            for(Property_Inventory__c pi : selectedPInventories){
                Opportunity_Property__c op = new Opportunity_Property__c();
                op.cm_Opportunity__c = oppId;
                op.cm_Property_Inventory__c = pi.Id;
                op.VAT_Amount__c = pi.VAT_Amount__c;
                op.VAT_RATE__c = pi.VAT_RATE__c;
                op.Total_Amount__c = pi.Total_Amount__c;
                op.Booking_Price__c = pi.Selling_Price__c;
                insertableOppProperties.add(op);
            }
        }

        System.debug('@@insertableOppProperties'+insertableOppProperties);

        if(insertableOppProperties != null && insertableOppProperties.size() > 0){
            insert insertableOppProperties;
            return 'Success';
        }
      }catch(exception ex){
          msg = 'Exception: ' + ex.getMessage();
      }
      return msg;
    }

    /************************************************************************************
    Method      :  getAddedProperties
    Params      :  OpportunityId
    Description :  Method to get property inventories agains opportunityId
    Version :         1.0
    ************************************************************************************/
    @AuraEnabled
    public static LIST<Property_Inventory__c> getAddedProperties(String oppId, String queryFields){
        LIST<Property_Inventory__c> addedPropertiesList = new LIST<Property_Inventory__c>();
        Set<id> existingPInventoriesIds = new set<Id>();        
        list<Opportunity_Property__c> lstOpporPro = [select id,Name,cm_Opportunity__c,cm_Property_Inventory__c from Opportunity_Property__c where cm_Opportunity__c=:oppId];
        for(Opportunity_Property__c objOpppro:lstOpporPro){
            existingPInventoriesIds.add(objOpppro.cm_Property_Inventory__c);
        }
        string strPacakgeRecId = getRecordTypeId('Property_Inventory__c','Package');
        String Strval = 'Blocked';
        string strQuery = 'Select ';
        for(String s : queryFields.split(',')){
            if(s != 'Id'){
                strQuery += s + ', ';
            }
        }
        strQuery += ' Id FROM Property_Inventory__c '+
                    'WHERE Id IN:existingPInventoriesIds AND RecordTypeId!=:strPacakgeRecId AND Property_Type__c!=:Strval '+
                    'ORDER BY CreatedDate';
        addedPropertiesList = database.query(strQuery);
        return addedPropertiesList;
    }

    /************************************************************************************
    Method      :  removePropertyInventory
    Params      :  OpportunityId, Property Inventory Id
    Description :  Method to remove property inventory from opportunity
    Version :         1.0
    ************************************************************************************/
    @AuraEnabled
    public static string removePropertyInventory(String oppId, String pInventoryId){
        String msg = '';
        try{
            System.debug('@@oppId='+oppId);
            System.debug('@@pInventoryId='+pInventoryId);

            LIST<Opportunity_Property__c> deleteable = [SELECT Id FROM Opportunity_Property__c WHERE cm_Opportunity__c = :oppId AND cm_Property_Inventory__c = :pInventoryId];
            delete deleteable;
            msg = 'Property has been deleted successfully.';
        }catch(Exception e){
            msg = 'Exception:' + e.getMessage();
        }
        return msg;
    }

    /************************************************************************************
    Method      :  getRecordTypeId
    Params      :  objectName, recordTypeName
    Description :  Method to get recordTypeId by object name and record type name
    Version :         1.0
    ************************************************************************************/
    public static Id getRecordTypeId(String objectName, String recordName){
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();  
        Schema.DescribeSObjectResult d = gd.get(objectName).getDescribe();
        return(d.getRecordTypeInfosByName().get(recordName).getRecordTypeId()); 
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

    /************************************************************************************
    Method      :  getUnitPaymentTerms
    Params      :  Location Code, Org Id
    Description :  Method to get the payment terms of any specific unit.
    Version     :  1.0
    ************************************************************************************/
    @AuraEnabled
    public static LIST<cm_PaymentTerms.CampaignWrap> getUnitPaymentTerms(String locationId){
        emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresposne = new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
        list<Property_inventory__c> lstproperty = [Select id, VAT_Amount__c,VAT_Rate__c, Location__r.Location_ID__c,Org_ID__c from Property_inventory__c where Location__r.Location_ID__c =: locationId];
        Id propertyInventoryId = null;
        String orgId;
        if(lstproperty.size() > 0){
            propertyInventoryId = lstproperty[0].Id;
            orgId = String.valueOf(lstproperty[0].Org_ID__c);
        }
        list<Cm_PaymentTerms.CampaignWrap> lstData = new list<Cm_PaymentTerms.CampaignWrap>();
        try{
            if(!Test.isRunningTest()){
                objresposne = EmaarWebServiceUtils.executePaymentTerms(locationId,'','',orgId,'','','','');
                System.debug('@@response='+objresposne);
                System.debug('@@objresposne.ResultXML='+objresposne.ResultXML);
                if(objresposne.Status == 'SUCCESS'  &&  objresposne.ErrorMessage=='Payment Terms sent sucessfully.'&& objresposne.ResultXML != ''){
                        lstData = Cm_PaymentTerms.parsedata(objresposne.ResultXML);
                }else{
                    System.debug('Error parsing response');
                }
            }else{
                objresposne.Status = 'SUCCESS';
                objresposne.ErrorMessage = 'Payment Terms sent sucessfully.';
                string strXML =  '<P_RESULT_XML xmlns="http://xmlns.oracle.com/pcbpel/adapter/db/APPS/XX_MOBILE_INT_PKG/PERFORM_ACTION/"> <AVAILABLE_CAMPAIGNS xmlns=""> <CAMPAIGN_HDR> <CAMPAIGN_ID>5</CAMPAIGN_ID> <CAMPAIGN_NAME>6 Year Marassi Greek</CAMPAIGN_NAME> <CAMPAIGN_DESC>6 Year pyament plan for Marassi Greek</CAMPAIGN_DESC> <CAMPAIGN_TYPE>6 years payment plan</CAMPAIGN_TYPE> <CAMPAIGN_MAP_ID>367</CAMPAIGN_MAP_ID> <CAMPAIGN_PRICE>19933888</CAMPAIGN_PRICE> <CAMPAIGN_LINES> <CAMPAIGN_LINE> <PLAN_TYPE>Payment Schedule</PLAN_TYPE> <SEQUENCE_NUM>1</SEQUENCE_NUM> <PERCENTAGE_PAYMENT>10</PERCENTAGE_PAYMENT> <INSTALLMENT>Down Payment</INSTALLMENT> <EFFECTIVE_DATE>2018-04-04</EFFECTIVE_DATE> <TERM>IMMEDIATE</TERM> <SCHEDULE_PRICE>1993388.8</SCHEDULE_PRICE> <MAINTENANCE_PRICE>0</MAINTENANCE_PRICE> </CAMPAIGN_LINE> <CAMPAIGN_LINE> <PLAN_TYPE>Payment Schedule</PLAN_TYPE> <SEQUENCE_NUM>4</SEQUENCE_NUM> <PERCENTAGE_PAYMENT>60</PERCENTAGE_PAYMENT> <INSTALLMENT>Final Payment</INSTALLMENT> <EFFECTIVE_DATE>2019-04-18</EFFECTIVE_DATE> <TERM>IMMEDIATE</TERM> <SCHEDULE_PRICE>11960332.8</SCHEDULE_PRICE> <MAINTENANCE_PRICE>0</MAINTENANCE_PRICE> </CAMPAIGN_LINE> <CAMPAIGN_LINE> <PLAN_TYPE>Maintenance Schedule</PLAN_TYPE> <SEQUENCE_NUM>3</SEQUENCE_NUM> <PERCENTAGE_PAYMENT>5</PERCENTAGE_PAYMENT> <INSTALLMENT>INSTALLMENT 3</INSTALLMENT> <EFFECTIVE_DATE>2019-02-01</EFFECTIVE_DATE> <TERM>IMMEDIATE</TERM> <SCHEDULE_PRICE>0</SCHEDULE_PRICE> <MAINTENANCE_PRICE>996694.4</MAINTENANCE_PRICE> </CAMPAIGN_LINE> <CAMPAIGN_LINE> <PLAN_TYPE>Maintenance Schedule</PLAN_TYPE> <SEQUENCE_NUM>2</SEQUENCE_NUM> <PERCENTAGE_PAYMENT>5</PERCENTAGE_PAYMENT> <INSTALLMENT>INSTALLMENT 2</INSTALLMENT> <EFFECTIVE_DATE>2018-12-01</EFFECTIVE_DATE> <TERM>IMMEDIATE</TERM> <SCHEDULE_PRICE>0</SCHEDULE_PRICE> <MAINTENANCE_PRICE>996694.4</MAINTENANCE_PRICE> </CAMPAIGN_LINE> <CAMPAIGN_LINE> <PLAN_TYPE>Payment Schedule</PLAN_TYPE> <SEQUENCE_NUM>3</SEQUENCE_NUM> <PERCENTAGE_PAYMENT>20</PERCENTAGE_PAYMENT> <INSTALLMENT>INSTALLMENT 2</INSTALLMENT> <EFFECTIVE_DATE>2018-09-26</EFFECTIVE_DATE> <TERM>IMMEDIATE</TERM> <SCHEDULE_PRICE>3986777.6</SCHEDULE_PRICE> <MAINTENANCE_PRICE>0</MAINTENANCE_PRICE> </CAMPAIGN_LINE> <CAMPAIGN_LINE> <PLAN_TYPE>Payment Schedule</PLAN_TYPE> <SEQUENCE_NUM>2</SEQUENCE_NUM> <PERCENTAGE_PAYMENT>10</PERCENTAGE_PAYMENT> <INSTALLMENT>INSTALLMENT 1</INSTALLMENT> <EFFECTIVE_DATE>2018-06-18</EFFECTIVE_DATE> <TERM>IMMEDIATE</TERM> <SCHEDULE_PRICE>1993388.8</SCHEDULE_PRICE> <MAINTENANCE_PRICE>0</MAINTENANCE_PRICE> </CAMPAIGN_LINE> <CAMPAIGN_LINE> <PLAN_TYPE>Maintenance Schedule</PLAN_TYPE> <SEQUENCE_NUM>1</SEQUENCE_NUM> <PERCENTAGE_PAYMENT>5</PERCENTAGE_PAYMENT> <INSTALLMENT>INSTALLMENT 1</INSTALLMENT> <EFFECTIVE_DATE>2018-05-01</EFFECTIVE_DATE> <TERM>IMMEDIATE</TERM> <SCHEDULE_PRICE>0</SCHEDULE_PRICE> <MAINTENANCE_PRICE>996694.4</MAINTENANCE_PRICE> </CAMPAIGN_LINE> </CAMPAIGN_LINES> </CAMPAIGN_HDR> </AVAILABLE_CAMPAIGNS> </P_RESULT_XML>';
                objresposne.ResultXML = strXML;
            }
        }catch(exception ex){
                System.debug('@@Exception='+ex.getMessage());
        }
        return lstData;
    }

    /************************************************************************************
    Method      :  UpdateUserPreference
    Params      :  Boolean
    Description :  Method to update user preferences.
    Version     :  1.0
    ************************************************************************************/
    @AuraEnabled
    public static String UpdateUserPreference(Boolean isLightning){
        String success = '';
        try{
            CM_EmaarUtils.UpdateUserPreferences(isLightning);            
        }catch(Exception e){
            success = e.getMessage();
        }
        return success;

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