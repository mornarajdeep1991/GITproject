/***********************************************************************************************
* Name              : Batch_SwitchQueueMembers                                                 
* Description       : Daily Batch Class used to de-activate queue members when they are absent.                                            
* Created Date      : 17/04/2018                                                    
* Created By        : Divya Chary (divya.chary@were4c.com)    
* Jira/Req By       : Req Given by Usama                                                                                                                                         
* ----------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
* 1.0       Divya       17/04/2018  Createde                              
************************************************************************************************/

global class Batch_SwitchQueueMembers implements Database.Batchable<sObject>,Schedulable{
     global void execute(SchedulableContext sc){
        Batch_SwitchQueueMembers switchQueueMembers= new Batch_SwitchQueueMembers();
        database.executebatch(switchQueueMembers,100);
    }
    /************************************************************************************
    Method  :         Start Method
    Description :     Method to Query the List of Absences
    Version :         1.0
    ************************************************************************************/
    global Database.querylocator start(Database.BatchableContext BC){
        Date dToday= System.Today();
        Date dYesterday= System.Today()-1;
        String query='select id,EGY_Absence_Start__c,EGY_Absence_End__c,EGY_User__c FROM EGY_Absence__c WHERE EGY_Absence_Start__c=:dToday OR EGY_Absence_End__c=:dYesterday';

        System.debug('@@dToday='+dToday);
        System.debug('@@dYesterday='+dYesterday);
        System.debug('@@query='+query);


        return Database.getQueryLocator(query);
    }
    /************************************************************************************
    Method  :         Execute Method
    Description :     Method to Query the List of Queue Members where the Absence is to be 
                      addressed, and update the same
    Version :         1.0
    ************************************************************************************/
    global void execute(Database.BatchableContext BC, List<EGY_Absence__c> scope){
         /*********************Variables*****************************/
         Set<Id> setUserId= new Set<Id>();
         Set<Id> setUserIdDeactivate = new Set<Id>();
         Set<Id> setUserActivate= new Set<Id>();
         Date dToday= System.Today();
         Date dYesterday= System.Today()-1;
         List<Assignment_Groups__c> lstQueueMember = new List<Assignment_Groups__c>();

         System.debug('@@scope='+scope);

         /***********************************************************/  
         for(EGY_Absence__c oAbs :scope){
             setUserId.add(oAbs.EGY_User__c);                            //Fetch all the corresponding users
             if(oAbs.EGY_Absence_Start__c==dToday){
                 setUserIdDeactivate.add(oAbs.EGY_User__c);    
             }
             else if(oAbs.EGY_Absence_End__c==dYesterday){
                 setUserActivate.add(oAbs.EGY_User__c);    
             }                                                                   
         } 


         lstQueueMember=[SELECT Id,Active__c,User__c FROM Assignment_Groups__c WHERE User__c in:setUserId];      //Fetch all the group members
         for(Assignment_Groups__c oMember :lstQueueMember){
             if(setUserIdDeactivate.contains(oMember.User__c)){
                 oMember.Active__c='False';
             }
             else if(setUserActivate.contains(oMember.User__c)){
                 oMember.Active__c='True';
             }
         }
         update lstQueueMember;
    }
    /************************************************************************************
    Method  :         Finish Method
    Description :     Finish Method for the batch class 
    Version :         1.0
    ************************************************************************************/
    public void finish(Database.BatchableContext bc){
        
    }
}