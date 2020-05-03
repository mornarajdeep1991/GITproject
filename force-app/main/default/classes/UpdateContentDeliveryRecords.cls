/*
	Created By : Ravindra Babu Nagaboina
	Description : Used to queue the Queable Job to update the ProcessInstanceWorkItems
*/
public without sharing class UpdateContentDeliveryRecords implements Queueable{

    public list<ContentDistribution> lstContentDistributions = new list<ContentDistribution>();
	
	public UpdateContentDeliveryRecords(list<ContentDistribution> lst){
		lstContentDistributions = lst;
	}
	
	public void execute(QueueableContext context) {
		try{
			if(lstContentDistributions != null && !lstContentDistributions.isEmpty())
				insert lstContentDistributions;
		}catch(Exception ex){
			system.debug('Exception is : '+ex.getMessage());
		}
	}
}