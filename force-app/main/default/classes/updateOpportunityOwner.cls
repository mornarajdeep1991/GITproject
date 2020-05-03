global class updateOpportunityOwner implements Database.Batchable<sObject>, Schedulable {
	String query;
    // Execute method for the schedulable Interface
    global void execute(SchedulableContext sc) {
		// schedule the batch job
        database.executebatch(this);
	}
    
    // Bachable interface start method
    global Database.QueryLocator start(Database.BatchableContext BC) {
        string uId = userInfo.getUserId();
        query = 'SELECT id, Account.OwnerId '+
                'FROM Opportunity WHERE OwnerId =:uId ';
        return Database.getQueryLocator(query);
    }

    // Batchable interface execute method
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        LIST<Opportunity> updateables = (LIST<Opportunity>)scope;
        for(Opportunity a:updateables){
            a.OwnerId = a.Account.OwnerId;
            a.cm_Sales_Person__c  = a.Account.OwnerId;
        }

        if(updateables.size() > 0){
            try {
                Database.SaveResult[] srList = Database.update(updateables,false);
            }catch (Exception e){
                System.debug('Error updating Opportunity.' + e);
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {}
}