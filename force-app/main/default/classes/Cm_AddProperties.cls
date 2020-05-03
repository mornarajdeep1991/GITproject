/*
    Author : Haribabu Amudalapalli
    Name : CM_PropertySearch
    Date :
    Description:
    Modification History :
    *************************************************************
    Vesion        Author             Date           Description
    v1.0          Ajaz               15 Apr 2018    EPESI-1361 : Changes related to VAT amount and VAT % not getting captured at opp property.
*/
public without sharing class Cm_AddProperties { 
    public list<Property_Inventory__c> lstPropertyData{get;set;}

    public set<id> setPackageIds =new set<id>();
    public List<SelectOption> lstProjectNames{get;set;}
    public List<SelectOption> lstBuildingName{get;set;}
    public List<SelectOption> lstUnitTypes{get;set;}
    public List<SelectOption> lstUnitModels{get;set;}
    public List<SelectOption> lstBedrooms{get;set;}
    
    public List<SelectOption> lstCampaigns{get;set;}
    public string selectedCampaign{get; set;}
    
    public string selectedLocationCode{get;set;}
    public string selectedBuildingName{get;set;}
    public string selectedUnitType{get;set;}
    public string selectedUnitModel{get;set;}
    public string selectedNoofBedrooms{get;set;}

    public string imageURL{get;set;}
    public integer selIndex{get;set;}
    public list<PropertyWrap> lstPropertyWrap{get;set;}
    public list<existingPropertyWrap> lstexistingPropertyWrap{get;set;}
    public string strOpporId {get;set;}
    public map<id,Id> mapProInv = new map<Id,id>();
    set<Id> setCampaignunits = new set<Id>();
    set<Id> setActiveCampaignunits = new set<Id>();
    public integer iMaxCount = 0;
    public integer iExistingCount = 0;
    public list<string> RTvalues = new list<string>();
    public boolean blnAttributeCheck {get;set;}
    public string strOppName{get;set;}
    public Cm_AddProperties(){
        strOpporId = apexpages.currentPage().getParameters().get('id');
        list<opportunity> lstOppo = [select id,Name from Opportunity where id=:strOpporId];
        strOppName = lstOppo[0].Name;
        blnAttributeCheck = false;
       
        lstexistingPropertyWrap = new list<existingPropertyWrap>();
        lstPropertyWrap = new list<PropertyWrap>();
        
        lstPropertyData = new list<Property_Inventory__c>();
        lstProjectNames = new List<SelectOption>();
        lstBuildingName = new List<SelectOption>();
        lstUnitTypes = new List<SelectOption>();
        lstUnitModels = new List<SelectOption>();
        lstBedrooms = new List<SelectOption>();
        
        lstCampaigns = new list<SelectOption>();
        
        Id unitRecordTypeId =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        RTvalues.add(unitRecordTypeId);
        Id packageRecordTypeId =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Package').getRecordTypeId();
        RTvalues.add(packageRecordTypeId);
        PrepareCampiagnUnits();
        PrepareFilters();
        PrepareExistingProperties();
        DoSearch();
    }
    
    string OppCampId = '';
    public string LaunchCampId {get; set;} 
    set<Id> campaignIds = new set<Id>();
    public void PrepareCampiagnUnits(){
        string strCampaignID = '';
        LaunchCampId = '';
        list<opportunity> lstOpportunity = [select id,CampaignId,Name from Opportunity where id=:strOpporId];
        if(lstOpportunity!=null && lstOpportunity.size() >0 && lstOpportunity[0].CampaignId!=null){
            strCampaignID = lstOpportunity[0].CampaignId;
            Campaign objcampaign = CM_EmaarUtils.GetCampaignAttributes(strCampaignID);
            OppCampId = objcampaign.Id;
            if(objCampaign.Type!=null && objCampaign.Type.contains('Launch'))
                LaunchCampId = objcampaign.Id;
            if(objcampaign.id!=null && objcampaign.cm_No_of_properties_customers_can_buy__c!=null){
                blnAttributeCheck = true;
                iMaxCount = integer.valueof(objcampaign.cm_No_of_properties_customers_can_buy__c);
            }
        }else{
             Map<String,cm_Administrator_Settings__c> mpSettings = cm_Administrator_Settings__c.getAll(); 
             if(mpSettings.containsKey('ADMIN') && mpSettings.get('ADMIN').Temp_Campaign_Property_Count__c!=null)
                iMaxCount = integer.valueof(mpSettings.get('ADMIN').Temp_Campaign_Property_Count__c); 
                blnAttributeCheck = true;
        }
        
        lstCampaigns.add(new SelectOption('', '--Select a Campaign--'));
        for(Campaign_User__c cm: [Select id,cm_Campaign__c,cm_Campaign__r.name,cm_User__c,cm_Campaign__r.Type from Campaign_User__c where cm_User__c =: UserInfo.getUserId()]){
            if(cm.cm_Campaign__r.Type != null && !cm.cm_Campaign__r.Type.contains('Launch')){
                lstCampaigns.add(new SelectOption(cm.cm_Campaign__c, cm.cm_Campaign__r.name));
                
                campaignIds.add(cm.cm_Campaign__c);
            }
        }
        
        if(strCampaignID!='' && strCampaignID!=null){
            for(Campaign_Unit__c objCamapignUnit:[select id,Name,cm_Property_Inventory__c from Campaign_Unit__c where cm_Campaign__c =:strCampaignID]){
              
                setCampaignunits.add(objCamapignUnit.cm_Property_Inventory__c);
            }
        }
        else{
            set<id> setActivecampaignids = new set<id>(); 
            for(campaign objcampaign:[select id,name from campaign where IsActive= true and (NOT Type like'%Launch%')]){
                setActivecampaignids.add(objcampaign.id);
            }
            for(Campaign_Unit__c objCamapignUnit:[select id,Name,cm_Property_Inventory__c from Campaign_Unit__c where cm_Campaign__c IN:setActivecampaignids]){
                setActiveCampaignunits.add(objCamapignUnit.cm_Property_Inventory__c);
            }
        }
        system.debug('*********iMaxCount'+iMaxCount);
        system.debug('*********setActiveCampaignunits'+setActiveCampaignunits);
        system.debug('*********campaignIds'+campaignIds);
    }
    
    public void PrepareFilters(){
        List<AggregateResult> lstPosAggr = [Select Unit_Model__c pos,count(id) from Property_Inventory__c where (Property_Status__c='Available' or Property_Status__c='') and Property_Type__c='Sale' and Unit_Model__c != null group by Unit_Model__c];
        lstUnitModels.add(new SelectOption('','--None--'));
        for(AggregateResult ar: lstPosAggr){ 
            lstUnitModels.add(new SelectOption(string.valueOf(ar.get('pos')),string.valueOf(ar.get('pos'))));
        }       
        
        lstUnitTypes = new List<SelectOption>();
        lstUnitTypes.add(new SelectOption('','--None--'));
        List<AggregateResult> lstTYpeAggr = [Select Type__c pos,count(id) from Property_Inventory__c where (Property_Status__c='Available' or Property_Status__c='') and Property_Type__c='Sale' and Type__c != null group by Type__c];
        for(AggregateResult ar: lstTYpeAggr){
            lstUnitTypes.add(new SelectOption(string.valueOf(ar.get('pos')),string.valueOf(ar.get('pos'))));
        }
        
        lstBedrooms = new List<SelectOption>();
        lstBedrooms.add(new SelectOption('','--None--'));
        List<AggregateResult> lstBedAggr = [Select Sales_Rooms__c br,count(id) from Property_Inventory__c where (Property_Status__c='Available' or Property_Status__c='')  and Property_Type__c='Sale' and Sales_Rooms__c != null group by Sales_Rooms__c];
        for(AggregateResult ar: lstBedAggr){
            lstBedrooms.add(new SelectOption(string.valueOf(ar.get('br')),string.valueOf(ar.get('br'))));
        }
        
        lstBuildingName = new List<SelectOption>();
        lstBuildingName.add(new SelectOption('','--None--'));
        List<AggregateResult> lstBuildAggr = [Select Location__r.Building__c br,count(id) from Property_Inventory__c where (Property_Status__c='Available' or Property_Status__c='') and Property_Type__c='Sale' and Location__r.Building__c != null group by Location__r.Building__c];
        for(AggregateResult ar: lstBuildAggr){
            lstBuildingName.add(new SelectOption(string.valueOf(ar.get('br')),string.valueOf(ar.get('br'))));
        }
    }
    public void PrepareExistingProperties(){
        setPackageIds = new set<id>();
        mapProInv = new map<Id,id>();
        lstexistingPropertyWrap = new list<existingPropertyWrap>();
        strOpporId = apexpages.currentPage().getParameters().get('id');
        system.debug('******strOpporId'+strOpporId);
        map<Id,Id> MapPropInvIds = new map <Id,Id>();
        set<id> setInvIds = new set<Id>();
        list<Opportunity_Property__c> lstOpporPro = [select id,Name,cm_Opportunity__c,cm_Property_Inventory__c from Opportunity_Property__c where cm_Opportunity__c=:strOpporId];
        for(Opportunity_Property__c objOpppro:lstOpporPro){
            setInvIds.add(objOpppro.cm_Property_Inventory__c);
            MapPropInvIds.put(objOpppro.cm_Property_Inventory__c,objOpppro.id);
        }
        string strPacakgeRecId = getRecordTypeId('Property_Inventory__c','Package');
        STRING Strval = 'Blocked';
        // v1.0 Added VAT_Rate__c, Total_Amount__c and VAT_Amount__c to below SOQL query
        string strQuery = 'Select Id,recordtype.name,VAT_Rate__c,Total_Amount__c,VAT_Amount__c,Location__r.Building__c,Location_Code__c,Total_Area__c,Sales_Rooms__c,Saleable_Leasable_Area__c,recordtypeId,Property_Status__c,cm_Inventory_Package__c, Name,UNIT__c, Type__c,Sales_Room__c,BUILDING__c,Unit_Model__c , PROPERTY_ID__c,Status_indicator__c, PROPERTY_Code__c, Property__c, Selling_price__c FROM Property_Inventory__c where Id IN:setInvIds and RecordTypeId!=:strPacakgeRecId and Property_Type__c!=:Strval  order by CreatedDate';
        list<Property_Inventory__c> lstExistingData = database.query(strQuery);
        iExistingCount = lstExistingData.size();
        integer ival = 0;
        for(Property_Inventory__c objProInv:lstExistingData){
            if(objProInv.cm_Inventory_Package__c!=null){
                setPackageIds.add(objProInv.cm_Inventory_Package__c);
            }
            mapProInv.put(objProInv.id,objProInv.id);
            existingPropertyWrap objexisting = new existingPropertyWrap();
            objexisting.objexistingPro = new Property_Inventory__c();
            objexisting.objexistingPro = objProInv;
            objexisting.indexval = ival;
            objexisting.OpporPropID = MapPropInvIds.get(objProInv.id);
            ival = ival+1;
            lstexistingPropertyWrap.add(objexisting);
        }
      DoSearch();
    }
    public void DoSearch(){
        try{
            map<String,Mobile_Configurations__c> mpSettings = Mobile_Configurations__c.getAll();
            string genCampaignId = mpSettings.containsKey('Configuration') ? mpSettings.get('Configuration').Tempo_Campaign_ID__c : '';
            System.debug('>>>>>>>>>>>>>>>>>>'+genCampaignId+'>>>>>>>>>>>>>>'+OppCampId );
            string CampaignCheckId = OppCampId == '' ? genCampaignId : OppCampId ;
            
            list<string> lstStatusValues = new list<string>();
            //lstStatusValues.add('Booked');
            lstStatusValues.add('Available');
            lstPropertyWrap = new list<PropertyWrap>();
            // v1.0 Added VAT_Rate__c, Total_Amount__c and VAT_Amount__c to below SOQL query
            string strQuery = 'Select Id,recordtype.name,VAT_Rate__c,Total_Amount__c,VAT_Amount__c,Location__r.Building__c,Location_Code__c ,Sales_Rooms__c,Saleable_Leasable_Area__c,Total_Area__c ,Property_Status__c, Name,UNIT__c, recordTypeId,Type__c,Sales_Room__c,BUILDING__c,Unit_Model__c , PROPERTY_ID__c,Status_indicator__c, PROPERTY_Code__c, Property__c, Selling_price__c FROM Property_Inventory__c ';
            
            string strConditions = '';
            
            if(selectedBuildingName!=null && selectedBuildingName!=''){
                strConditions =  strConditions +'Location__r.Building__c =: selectedBuildingName  and ' ;
            }
            if(selectedLocationCode!=null && selectedLocationCode!=''){
                strConditions =  strConditions +'Location_Code__c LIKE \'%' + selectedLocationCode + '%\'  and ' ;
            }
            if(selectedUnitModel!=null && selectedUnitModel!=''){
                strConditions =  strConditions +'Unit_Model__c =:selectedUnitModel  and ' ;
            }
            if(selectedNoofBedrooms!=null){
                strConditions =  strConditions +'Sales_Rooms__c =:selectedNoofBedrooms  and ' ;
            }
            if(selectedUnitType!=null){
                strConditions =  strConditions +'Type__c =:selectedUnitType  and ' ;
            }
            
            
            if(selectedCampaign != ''&& selectedCampaign != null){
                strConditions =  strConditions +'cm_related_campaign__c=:selectedCampaign and ' ;
            }
            else if(LaunchCampId != ''){
                strConditions =  strConditions +'cm_related_campaign__c=:LaunchCampId and ' ;
            }
            else{
                strConditions =  strConditions +'cm_related_campaign__c in:campaignIds  and ' ;
            }
            system.debug('********strConditions'+strConditions);
            

            if(setCampaignunits!=null && setCampaignunits.size() >0 )
                strConditions = strConditions+' ID IN:setCampaignunits and ';
            else if(setActiveCampaignunits!=null && setActiveCampaignunits.size() >0 )
                strConditions = strConditions+' ID NOT IN:setActiveCampaignunits and ';
                
            system.debug('********strConditions'+strConditions);
            string strStatus = 'Sale';
            System.debug('>>>>>>>>>CampaignCheckId>>>>>>>>>>>>>'+CampaignCheckId);
            strQuery = strQuery+' where '+strConditions +' Location__r.Active_End_Date__c > Today and Property_Status__c IN:lstStatusValues and Location_Code__c != null and ID not IN:setPackageIds and cm_Inventory_Package__c = null and recordtypeId IN:RTvalues and Property_Type__c=:strStatus  order by Name ';
            
            //strQuery = 'Select Id,recordtype.name,VAT_Rate__c,Total_Amount__c,VAT_Amount__c,Location__r.Building__c,Location_Code__c ,Sales_Rooms__c,Saleable_Leasable_Area__c,Total_Area__c ,Property_Status__c, Name,UNIT__c, recordTypeId,Type__c,Sales_Room__c,BUILDING__c,Unit_Model__c , PROPERTY_ID__c,Status_indicator__c, PROPERTY_Code__c, Property__c, Selling_price__c FROM Property_Inventory__c';

            system.debug('*****strQuery*final***'+strQuery);
            lstPropertyData = database.query(strQuery);
            if(lstPropertyData!=null && lstPropertyData.size() >0){
                for(Property_Inventory__c objProINV:lstPropertyData){
                    if(mapProInv!=null && mapProInv.get(objProINV.id) == null){
                        PropertyWrap objPropertyWrap = new PropertyWrap();
                        objPropertyWrap.objPro = new Property_Inventory__c();
                        objPropertyWrap.objPro = objProINV;
                        objPropertyWrap.blnChecked = false;
                        lstPropertyWrap.add(objPropertyWrap);
                    }
                }
            }
            
            if(lstPropertyData!=null && lstPropertyData.size() == 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'No Records found'));
            }
        }catch(exception ex){
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error,ex.getMessage()));
        }
    }
     // Method to remmove a row
    public void removeRow(){
        try{
            system.debug('*******selIndex'+selIndex);
            if(selIndex != null){
                if(lstexistingPropertyWrap[selIndex].OpporPropID!=null){
                    string selId = lstexistingPropertyWrap[selIndex].OpporPropID;
                    delete [select id from Opportunity_Property__c where id=:selId];
                }
                lstexistingPropertyWrap.remove(selIndex);
                List<existingPropertyWrap> lstclone= lstexistingPropertyWrap.clone();
                lstexistingPropertyWrap = new List<existingPropertyWrap>();
                integer i = 0;
                for(existingPropertyWrap bw: lstClone){
                    bw.indexval = i;
                    lstexistingPropertyWrap.add(bw);
                    i++;
                }
                PrepareExistingProperties();
            }
        }catch(exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
        }
    }
    /*Method which checks if the Package Property or Not*/   
    @RemoteAction
    public static string PackagePropetyCheck(string strID) {
         string strMessage = '';
         system.debug('***strID'+strID);
         list<Opportunity_Property__c> lstOpporProp = [select id,Name,Package_ID__c from Opportunity_Property__c where id=:strID and Package_ID__c!=null];
         if(lstOpporProp!=null && lstOpporProp.size() >0 && lstOpporProp[0].Package_ID__c!=null){
           string strPackageId = lstOpporProp[0].Package_ID__c;
           list<Property_Inventory__c> lstPI = [select id,Location_code__c from Property_Inventory__c where cm_Inventory_Package__c=:strPackageId];
           for(Property_Inventory__c objPI:lstPI){
              if(strMessage == ''){
                strMessage = objPI.Location_code__c;
              }else{
                strMessage = strMessage+','+objPI.Location_code__c;
              }
           }
           strMessage = strMessage+'$$$'+strPackageId;
         }else{
            strMessage = 'success';
         }
         return strMessage;
    }
     @RemoteAction
    public static string DeletePackageUnits(string PackageId) {
        string strmessage = '';
        try{
            list<Opportunity_Property__c> lstOpporProp = [select id,Name,Package_ID__c from Opportunity_Property__c where Package_ID__c=:PackageId];
            if(lstOpporProp!=null && lstOpporProp.size() >0){
                delete lstOpporProp;
                strmessage = 'success';
            }
        }catch(exception ex){
           strmessage = ex.getMessage();
        }
        return strmessage;
    }
     // Method to remmove a row
    public void AddSelectedProperties(){
      try{
       setPackageIds = new set<id>();
       list<Property_Inventory__c> lstSelected = new list<Property_Inventory__c>();
       list<Property_Inventory__c> lstPackages = new list<Property_Inventory__c>();
       system.debug('***PropertyWrap'+lstPropertyWrap);
       for(PropertyWrap objwrap:lstPropertyWrap){
           if(objwrap.blnChecked == true && objwrap.objPro.recordTypeId != getRecordTypeId('Property_Inventory__c','Package')){
               lstSelected.add(objwrap.objPro);
           }
           if(objwrap.blnChecked == true && objwrap.objPro.recordTypeId == getRecordTypeId('Property_Inventory__c','Package')){
               setPackageIds.add(objwrap.objPro.id);
               lstPackages.add(objwrap.objPro);
           }
       }
       list<Opportunity_Property__c> lstOpporProp = new list<Opportunity_Property__c>();
       if(setPackageIds!=null && setPackageIds.size() >0){
           // v1.0 Added VAT_Rate__c, Total_Amount__c and VAT_Amount__c to below SOQL query
           list<Property_Inventory__c> lstPackageInventories = [Select Id,Property_Status__c,VAT_Rate__c, VAT_Amount__c, Total_Amount__c, Name,UNIT__c, recordTypeId,Type__c,Sales_Room__c,BUILDING__c,Unit_Model__c , PROPERTY_ID__c,Status_indicator__c, PROPERTY_Code__c, Property__c, Selling_price__c FROM Property_Inventory__c where cm_Inventory_Package__c IN:setPackageIds];
           if(lstPackageInventories!=null && lstPackageInventories.size() >0){
               lstSelected.addAll(lstPackageInventories);
           }
       }
       Integer INewCount = lstSelected.size();
       lstSelected.addAll(lstPackages);
       integer Itotal = INewCount + iExistingCount;
       system.debug('***iMaxCount'+iMaxCount);
       system.debug('***INewCount'+INewCount);
       system.debug('***iExistingCount'+iExistingCount);
       system.debug('***Itotal'+Itotal);
           if(lstSelected!=null && lstSelected.size() >0){
               boolean blnduplicate = false;
               string strName = '';
               for(Property_Inventory__c objProINV:lstSelected){
                   if(mapProInv.get(objProINV.id) ==null){
                       Opportunity_Property__c objOpporProp = new Opportunity_Property__c();
                       objOpporProp.cm_Opportunity__c = strOpporId;
                       objOpporProp.cm_Property_Inventory__c = objProINV.id;
                       // v1.0 Vat changes starts here
                        objOpporProp.VAT_Amount__c = objProINV.VAT_Amount__c;
                        objOpporProp.VAT_RATE__c = objProINV.VAT_RATE__c;
                        objOpporProp.Total_Amount__c = objProINV.Total_Amount__c;
                       // v1.0 vat changes ends here
                       lstOpporProp.add(objOpporProp);
                   }else{
                       strName =  'Building: '+objProINV.BUILDING__c+'- Unit: '+objProINV.unit__c;
                       blnduplicate = true;
                       break;
                   }
               }
               if(blnduplicate == false){
                   if(lstOpporProp!=null && lstOpporProp.size() >0){
                       insert lstOpporProp;
                       PrepareExistingProperties();
                       for(PropertyWrap objwrap:lstPropertyWrap){
                           if(objwrap.blnChecked == true){
                               objwrap.blnChecked =false;
                           }
                       }
                   }
               }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'The selected property '+strName+' is already added to the Opportunity'));
               }
           }
       
      }catch(exception ex){
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
      }
    }
    public class PropertyWrap{
        public Property_Inventory__c objPro{get;set;}
        public boolean blnChecked{get;set;} 
    }
    public class existingPropertyWrap{
        public Property_Inventory__c objexistingPro{get;set;}
        public string  OpporPropID{get;set;}
        public integer indexval{get;set;}
    }
    public Id getRecordTypeId(String objectName, String recordName){
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();  
        Schema.DescribeSObjectResult d = gd.get(objectName).getDescribe();
        return(d.getRecordTypeInfosByName().get(recordName).getRecordTypeId()); 
    }
    public Pagereference CheckAgent(){
        String userAgent = ApexPages.currentPage().getHeaders().get('User-Agent');
        system.debug('****userAgent'+userAgent);
        Pagereference objref ;
        if (userAgent!=null && userAgent!='' && (userAgent.contains('iPhone') || userAgent.contains('iPad'))){
            objref = new pagereference('/apex/cm_addProperties_sf1?id='+apexpages.currentPage().getParameters().get('Id'));
            objref.setRedirect(true);
            return objref;
        }
        return null;
    }
}