/************************************************************************************
* Name              : LeadAssignmentUtility                                                 
* Description       : Class to assign the leads to respective queues based on the current sales office quota                                            
* Created Date      : 17/04/2018                                                     
* Created By        : Prachi Sinha  (4C)    
* Jira/Req By       :                                                                                                                                          
* -----------------------------------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
* 1.0       Name        Date                Description     Jira Ticket no./   
1.1          Divya       29/4/2018  Added cs.EGY_Assignment_Rule__c=True
************************************************************************************/

global with sharing class LeadAssignmentUtility{
        
    /************************************************************************************
    Method  :         assignLeadToQueue
    Description :         Description
    Version :         1.0
    ***********************************************************************************/
    
    Webservice static void assignLeadToQueue(Id leadId){
        
        /*********************Variables*****************************/
        Id salesOfficeToAssignId;
        List<EGY_Sales_Office_Quota__c> salesOfficeQuotaToupdateList = new List<EGY_Sales_Office_Quota__c>();
        /***********************************************************/
        
        //fetch all the sales office quota with their respective sales office and last lead assigned details
        List<EGY_Sales_Office_Quota__c> salesOfficeList = [select id, EGY_Sales_Office__c, EGY_Number_of_Leads_Allowed__c, EGY_Number_of_Leads_Assigned__c,
                            EGY_Lead_Quota__c, EGY_Last_Assigned_Time__c from EGY_Sales_Office_Quota__c 
                            order by EGY_Last_Assigned_Time__c ASC];
                                    
        //iterate over all the sales office quota records
        for(EGY_Sales_Office_Quota__c officeQuota : salesOfficeList){           
            //check if this sales office has reached its threshold
            if(officeQuota.EGY_Number_of_Leads_Assigned__c >= officeQuota.EGY_Number_of_Leads_Allowed__c){
                continue;
            }
            else{
                salesOfficeToAssignId = officeQuota.EGY_Sales_Office__c;
                officeQuota.EGY_Number_of_Leads_Assigned__c = officeQuota.EGY_Number_of_Leads_Assigned__c + 1;
                officeQuota.EGY_Last_Assigned_Time__c = system.now();
                salesOfficeQuotaToupdateList.add(officeQuota);
                break;
            }
        } 
        
        //update the sales office quota
        if(salesOfficeQuotaToupdateList.size() > 0){
            update salesOfficeQuotaToupdateList;
        }
        
        if(salesOfficeToAssignId != null){
            EGY_Sales_Office__c salesOfficeToAssign = [select id, EGY_Sales_Office_Name__c from EGY_Sales_Office__c where id =: salesOfficeToAssignId];                 
                
            List<Group> groupToAssignList = [select Id from Group where Name =: salesOfficeToAssign.EGY_Sales_Office_Name__c and Type = 'Queue'];  
            
            if(groupToAssignList.size() > 0){
                Lead leadRecord = [select id,EGY_Assignment_Rule__c,ownerId from lead where id =: leadId];
                leadRecord.ownerId = groupToAssignList[0].Id;
                leadRecord.EGY_Assignment_Rule__c=True;
                //update the owner of the lead record   
                update leadRecord;
            } 
        }                   
    }
}