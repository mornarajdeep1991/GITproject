/************************************************************************************
* Name		        : EG_LeadAssignmentComponentCtrl                                                 
* Description		: This is an apex controller to EG_LeadAssignment lightning component to create Sales Offices, to add/remove users to the sales Offices                                             
* Created Date	    : 21-05-2018                                                    
* Created By		: Srivijitha    
* Jira/Req By		: Jira Ticket/Req Given by                                                                                                                                          
* -----------------------------------------------------------------------------------------------------------------------
* VERSION	Developer	    Date		Description		Ticket/Reference                                                                    
* 1.0		Srivijitha 		Date                Description		Jira Ticket no./                      
************************************************************************************/

public with sharing class EG_LeadAssignmentComponentCtrl {  

    /************************************************************************************
        Method	:         getLeadAssignmentThreshold
        Description	:     This method is to get the Lead_Assignment_Threshold on page load(on do init)
        Version	:         1.0
    ************************************************************************************/
    @AuraEnabled
    public static EGY_Lead_Assignment_Threshold__c getLeadAssignmentThreshold(){
        LIST<EGY_Lead_Assignment_Threshold__c> thresholds = [SELECT EGY_Threshold_Value__c FROM EGY_Lead_Assignment_Threshold__c LIMIT 1];
        if(thresholds.size() > 0){
            return thresholds[0];
        }else{
            return new EGY_Lead_Assignment_Threshold__c();
        }
    }
    /************************************************************************************
    Method	:         getSalesOffices
    Description	:     This method is to get the Sales Offices on page load(on do init)
    Version	:         1.0
    ************************************************************************************/
    @AuraEnabled
    public static LIST<EGY_Sales_Office__c> getSalesOffices(){
        String sGulfRegion= Label.Gulf_Region;
        LIST<EGY_Sales_Office__c> salesOffices = [SELECT Id, EGY_Sales_Office_Name__c,EGY_Count_of_Users__c,EGY_Region__c,
                                                        (SELECT Id,Name,Active__c,EGY_Sales_Office__C,Group_Name__c,User__c,User__r.Name FROM Group_Members__r),(SELECT Id,Name,EGY_Lead_Quota__c,EGY_Number_of_Leads_Assigned__c,EGY_Sales_Office__c,EGY_Sales_Office__r.EGY_Region__c FROM EMAAR_Sales_Office_Quotas__r)
                                                         FROM EGY_Sales_Office__c WHERE EGY_Department__C!='Contact Center' AND EGY_Region__c !=:sGulfRegion];
        return salesOffices;
    }
    /************************************************************************************
    Method	:         getGroupMembers
    Description	:     This method is to get the group members on page load(on do init)
    Version	:         1.0
    ************************************************************************************/
    @AuraEnabled
    public static List<Assignment_Groups__c> getGroupMembers() {
        List<Assignment_Groups__c> assignedUsersList = new List<Assignment_Groups__c>();
         for(Assignment_Groups__c asgndUsers : [SELECT Id,Name ,User__c,Status__c,Last_Assignment__c  FROM Assignment_Groups__c]){
           assignedUsersList.add(asgndUsers); 
        } 
       return assignedUsersList;
       // return [SELECT Id,Name ,Status__c,Group_Name__c,Last_Assignment__c  FROM Assignment_Groups__c];
    }
    
    /************************************************************************************
    Method	:         getupdatedGroupMem
    Description	:     This method is to update the group members
    Version	:         1.0
    ************************************************************************************/
     @AuraEnabled 
    public static List<Assignment_Groups__c> getupdatedGroupMem(String gSalesOffice){
       list<Assignment_Groups__c> grpMembers =  [select Id,Name ,User__c,Status__c,Last_Assignment__c from Assignment_Groups__c WHERE EGY_Sales_Office__r.EGY_Sales_Office_Name__c=:gSalesOffice] ;  
         system.debug('grpMembers'+grpMembers);
        return grpMembers;   
    }
      
    /************************************************************************************
    Method	:         updateLeadQuota
    Description	:     This method is to save the updated quotas on the page
    Version	:         1.0
    ************************************************************************************/
     /*  */
    @AuraEnabled
    public static string updateLeadQuota(String updatedLeadQuota){
       String s = '';
       List<EGY_Sales_Office_Quota__c> updateable = new LIST<EGY_Sales_Office_Quota__c>();
        try {
            if(String.isNotBlank(updatedLeadQuota)){
                updatedLeadQuota = updatedLeadQuota.removeEnd(';');
                for(String str2 : updatedLeadQuota.split(';')){
                    LIST<String> sfQuota = str2.split(',');
                    EGY_Sales_Office_Quota__c quota = new EGY_Sales_Office_Quota__c(Id = sfQuota[0]);
                    quota.EGY_Lead_Quota__c = Decimal.valueOf(sfQuota[1]);
                    updateable.add(quota);
                }
                if(updateable.size() > 0){
                    upsert updateable;
                }
            }
        } catch(DmlException e) {
            throw new AuraHandledException(e.getMessage());
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
		return s;    
      }
 
    /************************************************************************************
    Method	:         saveGroupMembers
    Description	:     This method is to save the users to a particular salesoffice
    Version	:         1.0
    ************************************************************************************/
    @AuraEnabled
    public static void saveGroupMembers(List<User> lstUsers, String oSalesOffice){
        List<Assignment_Groups__c> lstGroups = new List<Assignment_Groups__c>();
        //Since the name of the sales office is unique, we will query for the sales office that has the name passed via the component
        EGY_Sales_Office__c oSalesOfficeRecord =[SELECT Id from EGY_Sales_Office__c WHERE EGY_Sales_Office_Name__c=:oSalesOffice LIMIT 1];
        for(User oUser :lstUsers){
           Assignment_Groups__c oGroupMember = new Assignment_Groups__c();
           oGroupMember.User__C=oUser.Id;
           oGroupMember.EGY_Sales_Office__c= oSalesOfficeRecord.Id;
           lstGroups.add(oGroupMember); 
        }
        if(lstGroups!=NULL && lstGroups.size()>0) insert lstGroups;
    }
    /************************************************************************************
    Method	:         saveGroupMembers
    Description	:     This method is for lookup search functionality
    Version	:         1.0
    ************************************************************************************/
     @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, List<sObject> ExcludeitemsList) {
        String searchKey = '%' + searchKeyWord + '%';
        List < sObject > returnList = new List < sObject > ();
 
        List<string> lstExcludeitems = new List<string>();
        for(sObject item : ExcludeitemsList ){
            lstExcludeitems.add(item.id);
        }
        
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5 and exclude already selected records  
        String sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey AND Id NOT IN : lstExcludeitems order by createdDate DESC limit 5';
        List < sObject > lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
    
    /************************************************************************************
    Method	:         createRecord
    Description	:     This method is to create a salesOffice from the Modal
    Version	:         1.0
    ************************************************************************************/
    @AuraEnabled
    public static void createRecord (String salesoffice, Decimal leadquotafield, String regionfield){
        String sGulfRegion= Label.Gulf_Region;
        try{
            if(salesoffice != null){
                EGY_Sales_Office__c oSalesOffice= new EGY_Sales_Office__c();
                oSalesOffice.EGY_Sales_Office_Name__c =salesoffice;
                oSalesOffice.EGY_Department__c ='Sales Office';
                oSalesOffice.EGY_Region__c =regionfield;
                insert oSalesOffice;
                id salesofficeid=oSalesOffice.Id;
                //Query the Thresholds for all the existing values, and check for the value to not be greater than 100.
                List<EGY_Sales_Office_Quota__c> lstQuotas=[SELECT Id,EGY_Sales_Office__r.EGY_Region__c,EGY_Lead_Quota__c FROM EGY_Sales_Office_Quota__c WHERE EGY_Sales_Office__r.EGY_Region__c =:regionfield];
                Decimal dQuota = leadquotafield;
                if(lstQuotas!=NULL && lstQuotas.size()>0){
                    for(EGY_Sales_Office_Quota__c oQuota :lstQuotas){
                        dQuota=dQuota+oQuota.EGY_Lead_Quota__c;
                    }
                }
                system.debug('dQuota'+dQuota);
                if(dQuota!=100){
                  throw new AuraHandledException('The cumulative of all the thresholds must be 100');  
                }
                else{
                    // Add a Quota to this Sales Office.
                    EGY_Sales_Office_Quota__c SOQuota = new EGY_Sales_Office_Quota__c(
                        EGY_Lead_Quota__c=leadquotafield,
                        EGY_Sales_Office__c=salesofficeid);
                    insert SOQuota;
                }
            } 
        } catch(DmlException e) {
            throw new AuraHandledException(e.getMessage());
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
        
    }   
    /************************************************************************************
    Method	:         deleteUserById
    Description	:     This method is to delete the users for a particular salesOffice
    Version	:         1.0
    ************************************************************************************/
    @Auraenabled
    public static List<Assignment_Groups__c> deleteUserById(String userid)
    {
        System.debug('In controller deleteUserById method..');
        Assignment_Groups__c delUser=[Select Id from Assignment_Groups__c where id=:userid];
        delete delUser;
        return [SELECT Id,Name ,User__c,Status__c,Last_Assignment__c from Assignment_Groups__c];
    } 
    
   /************************************************************************************
    Method	:         fetchFieldOptions
    Description	:     This method is to get the filter options for picklist
    Version	:         1.0
    ************************************************************************************/
    @AuraEnabled
    public static Map<String, String> fetchFieldOptions(string filter){
        String sGulfRegion= Label.Gulf_Region;
        Map<String, String> fieldOptions = new Map<String, String>();
        fieldOptions.put('', '--None--');
        if(filter == 'regionOptions'){
            Schema.DescribeFieldResult regionFieldResult = EGY_Sales_Office__C.EGY_Region__c.getDescribe();
            List<Schema.PicklistEntry> regionple = regionFieldResult.getPicklistValues();
            for( Schema.PicklistEntry f : regionple){
                if(f.getLabel()!=sGulfRegion && f.getLabel()!='Pakistan')
                fieldOptions.put(f.getLabel(), f.getValue());
            }
        }
        return fieldOptions;
    }
}