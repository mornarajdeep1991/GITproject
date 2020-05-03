/*
	Created By : Ravindra Babu Nagaboina
	Description : Used to queue the Queable Job to update the ProcessInstanceWorkItems
*/
public with sharing class PrimaryContactSyncOracleQueueable implements Queueable, Database.AllowsCallouts{
    
    public set<Id> setOppIds = new set<Id>();
    
    public PrimaryContactSyncOracleQueueable(set<Id> oppIds){
    	setOppIds = oppIds;
    }
    
    public void execute(QueueableContext context) {
		system.debug('setOppIds '+setOppIds);
		cm_OpportunityTriggerUtility.syncPrimaryContactDetails(setOppIds);
	}
}