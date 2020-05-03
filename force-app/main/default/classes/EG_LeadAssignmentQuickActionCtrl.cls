/************************************************************************************
* Name              : EG_LeadAssignmentQuickActionCtrl                                                 
* Description       : Class to assign the leads to respective queues based on the current sales office quota                                            
* Created Date      : 24/04/2018                                                     
* Created By        : Adeel Ahmad  (4C)    
* Jira/Req By       :                                                                                                                                          
* -----------------------------------------------------------------------------------------------------------------------
* VERSION   Developer       Date            Description                             Ticket/Reference                                                                    
* 1.1       Divya Chary     02/05/2018      added EGY_Assignment_Rule__c=true              
* 1.2       Adeel Ahmad     16/05/2018      Returning the sales office assignment message
*1.3        Divya Chary     20/05/2018      Adding logic to include assignment for other Gulf Regions
************************************************************************************/
public with sharing class EG_LeadAssignmentQuickActionCtrl {
    private Id leadId {get; set;}
    public String assignedQueueName {get; set;}

    public EG_LeadAssignmentQuickActionCtrl(ApexPages.StandardController sc){
        leadId = sc.getId();
    }

    public PageReference assignLeadToQueue(){
        /*********************Variables*****************************/
        Id salesOfficeToAssignId;
        List<EGY_Sales_Office_Quota__c> salesOfficeQuotaToupdateList = new List<EGY_Sales_Office_Quota__c>();
        String sGulfCountries= System.Label.All_Other_Gulf_Regions;
        String sGulfRegion=System.Label.Gulf_Region;
        List<String> listGulfCountries = sGulfCountries.split(',');
        Set<String> lstGulfCountries=new Set<String>();
        lstGulfCountries.addAll(listGulfCountries);
        Boolean bGulf=false;
        system.debug('lstGulfCountries'+lstGulfCountries);
        /***********************************************************/
        //Query the Lead Record
        Lead leadRecord = [select id,Mobile_Country_Code__c,EGY_Assignment_Rule__c,ownerId from lead where id =: leadId];
        List<EGY_Sales_Office_Quota__c> salesOfficeList= new List<EGY_Sales_Office_Quota__c>();
        //Check if the mobile number on the Lead is in the gulf
        String sCountryCode=leadRecord.Mobile_Country_Code__c.trim();
        for(String sStr :lstGulfCountries){
            system.debug('sStr.trim()'+sStr.trim()+'sCountryCode'+sCountryCode.trim());
            if(sStr.trim()==sCountryCode){
                bGulf=true;
                break;
            }
        }

        System.debug('@@bGulf='+bGulf);
        if(bGulf){
            salesOfficeList = [SELECT id, EGY_Sales_Office__c, EGY_Sales_Office__r.EGY_Sales_Office_Name__c, EGY_Sales_Office__r.EGY_Region__c, EGY_Number_of_Leads_Allowed__c, EGY_Number_of_Leads_Assigned__c,
                                EGY_Lead_Quota__c, EGY_Last_Assigned_Time__c FROM EGY_Sales_Office_Quota__c WHERE EGY_Sales_Office__r.EGY_Region__c=:sGulfRegion
                                ORDER BY EGY_Last_Assigned_Time__c ASC];    
        }
        else{
        //fetch all the sales office quota with their respective sales office and last lead assigned details
            salesOfficeList = [select id, EGY_Sales_Office__c, EGY_Sales_Office__r.EGY_Sales_Office_Name__c, EGY_Sales_Office__r.EGY_Region__c, EGY_Number_of_Leads_Allowed__c, EGY_Number_of_Leads_Assigned__c,
                                EGY_Lead_Quota__c, EGY_Last_Assigned_Time__c from EGY_Sales_Office_Quota__c WHERE EGY_Sales_Office__r.EGY_Region__c!=:sGulfRegion
                                order by EGY_Last_Assigned_Time__c ASC];
        }                            

        /*
        MAP<String,LIST<User>> salesofficeToPresentUsers = new MAP<String,LIST<User>>();
        for(EGY_Sales_Office_Quota__c officeQuota : salesOfficeList){           
            salesofficeToPresentUsers.put(officeQuota.EGY_Sales_Office__r.EGY_Sales_Office_Name__c, new LIST<User>());
        }        

        LIST<GroupMember> groupMembers = [SELECT Id,GroupId,UserOrGroupId FROM GroupMember WHERE GroupId IN (SELECT Id FROM Group WHERE Name IN:salesofficeToPresentUsers.keyset()) ];
        MAP<Id,Boolean> userIdToAbsense = new MAP<Id,Boolean>();
        for(GroupMember gm : groupMembers){
            userIdToAbsense.put(gm.UserOrGroupId,false);
        }

        for(EGY_Absence__c absense : [SELECT Id,EGY_User__c,EGY_Absence_Start__c,EGY_Absence_End__c 
                                        FROM EGY_Absence__c 
                                        WHERE EGY_User__c IN:userIdToAbsense.keyset() AND 
                                              EGY_Absence_Start__c >= :Date.today() AND 
                                              EGY_Absence_End__c <= :Date.today() ]){
            userIdToAbsense.put(absense.EGY_User__c,true);
        }

        for(Group g : [SELECT Id,Name FROM Group WHERE Name IN:salesofficeToPresentUsers.keyset()]){

        }
        */

        //Adeel here//


        //iterate over all the sales office quota records
        for(EGY_Sales_Office_Quota__c officeQuota : salesOfficeList){           
            //check if this sales office has reached its threshold
            if(officeQuota.EGY_Number_of_Leads_Assigned__c >= officeQuota.EGY_Number_of_Leads_Allowed__c){
                continue;
            }else{

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
                
            List<Group> groupToAssignList = [select Id, Name from Group where Name =: salesOfficeToAssign.EGY_Sales_Office_Name__c and Type = 'Queue'];  
            
            if(groupToAssignList.size() > 0){
                leadRecord.ownerId = groupToAssignList[0].Id;
                leadRecord.EGY_Assignment_Rule__c=True;
                // 17/12/2018 - Adeel, Temp commenting the lead update for testing
                //update leadRecord;
                assignedQueueName = [SELECT Owner.Name FROM Lead WHERE Id =: leadId].Owner.Name;
            } 
        }else{
            //If all of the sales offices has fully allocated, then reset the counter and assign to one
            LIST<EGY_Sales_Office_Quota__c> allSalesQuota = [SELECT Id, EGY_Number_of_Leads_Assigned__c, EGY_Last_Assigned_Time__c
                                                             FROM EGY_Sales_Office_Quota__c];
            for(EGY_Sales_Office_Quota__c soq : allSalesQuota){
                soq.EGY_Number_of_Leads_Assigned__c = 0;
                soq.EGY_Last_Assigned_Time__c = null;
            }
            //reset sales quota and recall the function.
            if(allSalesQuota != null && allSalesQuota.size() > 0){
                upsert allSalesQuota;
                assignLeadToQueue();
            }                                                
        }                   
        return null;
    }

}