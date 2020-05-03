/***********************************************************************************************
* Name              : SalesOfficeTriggerHelper                                                 
* Description       : Helper class for triggers related to Sales Office                                            
* Created Date      : 17/04/2018                                                    
* Created By        : Divya Chary (divya.chary@were4c.com)    
* Jira/Req By       :                                                                                                                                         
* ----------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
* 1.0       Divya       17/04/2018  Created                              
************************************************************************************************/
public class SalesOfficeTriggerHelper{
    /************************************************************************************
    Method  :         createQueue Method
    Description :     Method to create a queue with the same name as the sales office and an assignment group 
                      for the second round-robin assignment of leads, 
                      and call future methods to insert Lead as a supported object for the queue, and 
                      AG Queue Member.
    Version :         1.0
    ************************************************************************************/
    public static void createQueue(List<EGY_Sales_Office__c> lstSalesOffice){
        List<Group> lstQueueInsert= new List<Group>();
        Set<Id> setSalesOfficeId = new Set<Id>();
        Set<Id> setQueueId= new Set<Id>();
        for(EGY_Sales_Office__c oOffice :lstSalesOffice){
            setSalesOfficeId.add(oOffice.Id);
            //Create a Queue
            Group oGroup = new Group();
            oGroup.Name=oOffice.EGY_Sales_Office_Name__c;
            oGroup.Type='Queue';
            lstQueueInsert.add(oGroup);
        }
        insert lstQueueInsert;
        for(Group oGroup :lstQueueInsert){
            setQueueId.add(oGroup.Id);
        }
        createQueueSObject(setQueueId,setSalesOfficeId);                    //Future method to include lead as the object
        ValidateQueueName(setSalesOfficeId);
    }
    /************************************************************************************
    Method  :         createQueueSObject Method
    Description :     Future Method to insert Lead as a supported object for the queue
    Version :         1.0
    ************************************************************************************/
    @future
    public static void createQueueSObject(Set<Id> setQueueId,Set<Id> setSalesOfficeId){
        List<QueueSObject> lstQueueObject= new List<QueueSObject>();
        for(Id oGroupId :setQueueId){
            QueuesObject oObject =new QueuesObject();
            oObject.SobjectType='Lead';
            oObject.QueueId=oGroupId;
            lstQueueObject.add(oObject);
        }
        if(lstQueueObject!=NULL && lstQueueObject.size()>0)insert lstQueueObject;
    }
    /************************************************************************************
    Method  :         ValidateQueueName Method
    Description :     Method to Stamp Queue Id on the Sales Office record
    Version :         1.0
    ************************************************************************************/
    @future
    public static void ValidateQueueName(Set<Id> setSalesOfficeId){
    //Setup Queue lookup Xref map
    //NOTE: the number of Queues supported is limited by Map size (ie. 1000)
    Map<String,Group> Queues = new Map<String,Group>();     //Queue name --> Queue
    for (Group[] q :  [SELECT Name FROM Group WHERE Type= 'Queue']) {
        for (Integer i = 0; i < q.size() ; i++) {
            Queues.put(q[i].Name, q[i]);
        }
    }
    Map<String,String> agNames = new Map<String,String> ();
    List<EGY_Sales_Office__c> lstSalesOffice =[SELECT Id,Name,QueueId__C,EGY_Sales_Office_Name__c FROM EGY_Sales_Office__c WHERE Id in:setSalesOfficeId];
    //Find Queues matching on name
    for (EGY_Sales_Office__c agq : lstSalesOffice)
    {
        if (Queues.containsKey(agq.EGY_Sales_Office_Name__c))
        {
            Id qId = Queues.get(agq.EGY_Sales_Office_Name__c).Id;
            agq.QueueId__c = qId;
        } else {
            //Error: queue not found
            agq.addError('Invalid Queue name: Queue name ' + agq.Name + ' cannot be found.');
        }   
    }
    update lstSalesOffice;
    }
    /************************************************************************************
    Method  :         DeleteSalesOfficeQueue Method
    Description :     Method to Stamp Queue Id on the Sales Office record
    Version :         1.0
    ************************************************************************************/
    @future
    public static void DeleteSalesOfficeQueue(Set<Id> setQueuId){
        List<Group> lstQueue=new List<Group>();
        //Query the Queues, and delete them
        lstQueue=[SELECT Id from Group WHERE Id in:setQueuId];
        if(lstQueue!=NULL && lstQueue.size()>0) delete lstQueue;
    }
}