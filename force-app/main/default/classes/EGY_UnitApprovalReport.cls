public class EGY_UnitApprovalReport {
    public Map<Id, ProcessInstance> approvalsMap {get;set;}
    public Map<Id, cm_Interim_Approvals__c> specialApprovalsMap {get;set;}
    public EGY_UnitApprovalReport(){
        approvalsMap = new Map<Id, ProcessInstance>();
        //Get ID of the change payment plan approval process
        List<ProcessDefinition> process = [select Id from ProcessDefinition 
                                           where DeveloperName = 'Special_Approval_for_Change_of_Payment1' LIMIT 1];
        if(process.size() > 0){
            //get all approvals requested on this process
            List<ProcessInstance> approvals = [Select Id, TargetObjectId, Status, CreatedById,
                                               (Select Id, Actor.FirstName, Actor.LastName, OriginalActor.FirstName,
                                                OriginalActor.LastName from Workitems 
                                                ORDER BY CreatedDate ASC, ID ASC),
                                               (Select Id, Actor.FirstName, Actor.LastName, OriginalActor.FirstName,
                                                OriginalActor.LastName, StepStatus, CreatedDate from Steps 
                                                WHERE StepStatus <> 'Started' ORDER BY CreatedDate ASC, ID ASC)
                                               from ProcessInstance
                                               where ProcessDefinitionId= :process[0].Id AND CreatedDate >= LAST_N_YEARS:3];
            if(approvals.size() > 0){
                //construct a list of special approval records ids to use insubsequent queries
                Set<Id> specialApprovalsIds = new Set<Id>();
                for(ProcessInstance ap : approvals){
                    specialApprovalsIds.add(ap.TargetObjectId);
                    approvalsMap.put(ap.TargetObjectId, ap);
                }
                specialApprovalsMap = new Map<Id, cm_Interim_Approvals__c>([select Id, Name, Offer__r.cm_Property_Inventory__r.Location_Code__c,
                                                                            cm_Interim_Approval_Type__r.Name, Discount_Type__c, Schedule_Type__c,
                                                                            Offer__r.cm_Opportunity__r.Account.Name
                                                                 from cm_Interim_Approvals__c 
                                                                 where Id IN :specialApprovalsIds]);
            }
        }
    }
}