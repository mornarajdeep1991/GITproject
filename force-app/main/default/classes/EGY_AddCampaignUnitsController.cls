/************************************************************************************
* Name              : EGY_AddCampaignUnitsController                                                 
* Description       : Controller class for lightning component to link Property Inventory to Campaign                                          
* Created Date      :                                                     
* Created By        : Divya (divya.chary@weare4c.com)    
* Jira/Req By       : Jira Ticket/Req Given by                                                                                                                                          
* -----------------------------------------------------------------------------------------------------------------------
* VERSION   Developer           Date            Description                                     Ticket/Reference                                                                    
* 1.0       Divya                         Controller class for lightning component        Jira Ticket no./                      
************************************************************************************/

public with sharing class EGY_AddCampaignUnitsController{
    /************************************************************************************
    Method      :  getCampaignInfo
    Params      :  campaignId
    Description :  Getting Campaign Information by passing the Campaign Id
    Version :         1.0
    ************************************************************************************/
    @AuraEnabled
    public static Campaign getCampaignInfo(String campaignId){
        Campaign oCamp = [SELECT Id, Name FROM Campaign WHERE id = :campaignId];
        return oCamp;
    }

    /************************************************************************************
    Method      :  fetchFieldOptions
    Params      :  filterName
    Description :  Method to get picklist values as we can't use apex:inputField in lightning components
    Version :         1.0
    ************************************************************************************/
    @AuraEnabled
    public static Map<String, String> fetchFieldOptions(string filter){
        Map<String, String> fieldOptions = new Map<String, String>();
        //fieldOptions.put('', '--None--');
        if(filter == 'buildingsFilterOption'){
            List<AggregateResult> lstBuildAggr = [Select Location__r.Building__c br,count(id) from Property_Inventory__c where (Property_Status__c='Available' or Property_Status__c='') and Property_Type__c='Sale' and Location__r.Building__c != null group by Location__r.Building__c];
            for(AggregateResult ar: lstBuildAggr){
                fieldOptions.put( string.valueOf(ar.get('br')) , string.valueOf(ar.get('br')) );
            }            
        }

        if(filter == 'unitTypeFilterOption'){
            List<AggregateResult> lstTYpeAggr = [Select Type__c pos,count(id) from Property_Inventory__c where (Property_Status__c='Available' or Property_Status__c='') and Property_Type__c='Sale' and Type__c != null group by Type__c];
            for(AggregateResult ar: lstTYpeAggr){
                fieldOptions.put(string.valueOf(ar.get('pos')),string.valueOf(ar.get('pos')));
            }            
        }

        if(filter == 'unitModelFilterOption'){
            List<AggregateResult> lstPosAggr = [Select Unit_Model__c pos,count(id) from Property_Inventory__c where (Property_Status__c='Available' or Property_Status__c='') and Property_Type__c='Sale' and Unit_Model__c != null group by Unit_Model__c];
            for(AggregateResult ar: lstPosAggr){ 
                fieldOptions.put(string.valueOf(ar.get('pos')),string.valueOf(ar.get('pos')));
            }            
        }

        if(filter == 'bedroomsFilterOption'){
            List<AggregateResult> lstBedAggr = [Select Sales_Rooms__c br,count(id) from Property_Inventory__c where (Property_Status__c='Available' or Property_Status__c='')  and Property_Type__c='Sale' and Sales_Rooms__c != null group by Sales_Rooms__c];
            for(AggregateResult ar: lstBedAggr){
                fieldOptions.put(string.valueOf(ar.get('br')),string.valueOf(ar.get('br')));
            }         
        }
        return fieldOptions;
    }

    /************************************************************************************
    Method      :  doSearch
    Params      :  location code, building name, unit type, unit model, bedrooms, CampaignId
    Description :  Method to perform search on property inventory based on input values
    Version :         1.0
    ************************************************************************************/
    @AuraEnabled
    public static LIST<Property_Inventory__c> doSearch(String location_code, String buildingName, String unitType, String unitModel, String bedrooms, String campaignId){
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

        //Campaign Stuff
        String selectedCampaign=campaignId;
        String OppCampId=campaignId;
        
        //getting custom setting values
        map<String,Mobile_Configurations__c> mpSettings = Mobile_Configurations__c.getAll();
        string genCampaignId = mpSettings.containsKey('Configuration') ? mpSettings.get('Configuration').Tempo_Campaign_ID__c : '';
        string CampaignCheckId = OppCampId == '' ? genCampaignId : OppCampId ;

        /*
        */
        string strQuery = 'Select Id,recordtype.name,VAT_Rate__c,Total_Amount__c,VAT_Amount__c,Location__r.Building__c,Location_Code__c ,Sales_Rooms__c,Saleable_Leasable_Area__c,Total_Area__c ,Property_Status__c, Name,UNIT__c, recordTypeId,Type__c,Sales_Room__c,BUILDING__c,Unit_Model__c , PROPERTY_ID__c,Status_indicator__c, PROPERTY_Code__c, Property__c, Selling_price__c FROM Property_Inventory__c ';
        
        string strConditions = '';
        
        if(buildingName!=null && buildingName!=''){
            strConditions =  strConditions +'Location__r.Building__c =: buildingName  and ' ;
        }
        if(location_code!=null && location_code!=''){
            strConditions =  strConditions +'Location_Code__c LIKE \'%' + location_code + '%\'  and ' ;
        }
        if(unitModel!=null && unitModel!=''){
            strConditions =  strConditions +'Unit_Model__c =:unitModel  and ' ;
        }
        if(bedrooms!=null && bedrooms != ''){
            strConditions =  strConditions +'Sales_Rooms__c =:bedrooms  and ' ;
        }
        if(unitType!=null && unitType != ''){
            strConditions =  strConditions +'Type__c =:unitType  and ' ;
        }
        //Getting already added properties
        LIST<Property_Inventory__c> addedProperties = getAddedProperties(campaignId);

        strQuery = strQuery+' where '+strConditions +' Location__r.Active_End_Date__c > Today and Property_Status__c IN:lstStatusValues and Location_Code__c != null and ID not IN:addedProperties and cm_Inventory_Package__c = null and recordtypeId IN:RTvalues and Property_Type__c=:strStatus  order by Name';

        list<Property_Inventory__c> lstPropertyData = database.query(strQuery);
        return lstPropertyData;

    }

    /************************************************************************************
    Method      :  AddSelectedProperties
    Params      :  Campaignid, comma separated list of property inventories
    Description :  Method to add property inventories agains selected campaign.
    Version :         1.0
    ************************************************************************************/
    @AuraEnabled
    public static string AddSelectedProperties(String campaignId, LIST<String> selectedPropertyInventories){
        String msg = '';
      try{
        MAP<Id, String> piRecordTypeIdToRecordTypeNameMap = new MAP<Id, String>();
        piRecordTypeIdToRecordTypeNameMap.put(Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId(), 'Unit');
        piRecordTypeIdToRecordTypeNameMap.put(Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Package').getRecordTypeId(), 'Package');
        
        SET<Id> packageIds = new SET<Id>();
        LIST<String> insertablePIIds =  selectedPropertyInventories;
        LIST<Property_Inventory__c> selectedPInventories = new LIST<Property_Inventory__c>();
        LIST<Campaign_Unit__C> lstCampaignUnits = new LIST<Campaign_Unit__C>();

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

        if(selectedPInventories != null && selectedPInventories.size() > 0){
            for(Property_Inventory__c pi : selectedPInventories){
                Campaign_Unit__C oCampaignUnit = new Campaign_Unit__C();
                oCampaignUnit.cm_Campaign__c = campaignId;
                oCampaignUnit.cm_Property_Inventory__c = pi.id;
                lstCampaignUnits.add(oCampaignUnit);
            }
        }
        if(lstCampaignUnits != null && lstCampaignUnits.size() > 0){
            system.debug('Reached here!');
            insert lstCampaignUnits;
            return 'Success';
        }
      }catch(exception ex){
          msg = 'Exception: ' + ex.getMessage();
          system.debug('Here!!!!!!');
      }
      return msg;
    }

    /************************************************************************************
    Method      :  getAddedProperties
    Params      :  OpportunityId
    Description :  Method to get property inventories against CampaignId
    Version :         1.0
    ************************************************************************************/
    @AuraEnabled
    public static LIST<Property_Inventory__c> getAddedProperties(String campaignId){
        LIST<Property_Inventory__c> addedPropertiesList = new LIST<Property_Inventory__c>();
        Set<id> existingPInventoriesIds = new set<Id>();        
        list<Campaign_Unit__c> lstOpporPro = [select id,Name,cm_Campaign__c,cm_Property_Inventory__c from Campaign_Unit__c where cm_Campaign__c=:campaignId];
        for(Campaign_Unit__c objOpppro:lstOpporPro){
            existingPInventoriesIds.add(objOpppro.cm_Property_Inventory__c);
        }
        string strPacakgeRecId = getRecordTypeId('Property_Inventory__c','Package');
        //String Strval = 'Blocked';
        string strQuery = 'Select Id,recordtype.name,VAT_Rate__c,Total_Amount__c,VAT_Amount__c,Location__r.Building__c,Location_Code__c,Total_Area__c,Sales_Rooms__c,Saleable_Leasable_Area__c,recordtypeId,Property_Status__c,cm_Inventory_Package__c, Name,UNIT__c, Type__c,Sales_Room__c,BUILDING__c,Unit_Model__c , PROPERTY_ID__c,Status_indicator__c, PROPERTY_Code__c, Property__c, Selling_price__c FROM Property_Inventory__c where Id IN:existingPInventoriesIds and RecordTypeId!=:strPacakgeRecId order by CreatedDate';
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
    public static string removePropertyInventory(Id campaignId, Id pInventoryId){
        String msg = '';
        try{
            LIST<Campaign_Unit__c > deleteable = [SELECT Id FROM Campaign_Unit__c WHERE cm_Campaign__c  = :campaignId AND cm_Property_Inventory__c = :pInventoryId];
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

}