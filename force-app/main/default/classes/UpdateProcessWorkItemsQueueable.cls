/*
	Created By : Ravindra Babu Nagaboina
	Description : Used to queue the Queable Job to update the ProcessInstanceWorkItems
*/

//Test Class for this : SpecialApprovalDeleteControllerTest
public without sharing class UpdateProcessWorkItemsQueueable implements Queueable, Database.AllowsCallouts{
	
	public list<ProcessInstanceWorkItem> lstProcessInstanceWorkItems = new list<ProcessInstanceWorkItem>();
	public String item;
	
	public UpdateProcessWorkItemsQueueable(list<ProcessInstanceWorkItem> lst){
		lstProcessInstanceWorkItems = lst;
		//item = JSON.serialize(lstProcessInstanceWorkItems);
		item = '';
	    for(ProcessInstanceWorkItem obj : lst){
	        item += obj.Id+':'+obj.ActorId+';';
	    }
	    
	}
	
	public void execute(QueueableContext context) {
		string sessionId;
		if(!Test.isRunningTest())
		    sessionId = CM_EmaarUtils.GetSessionID(false);
	
	        Httprequest req1 = new HttpRequest();
	        req1.setMethod('POST');
	        req1.setHeader('Content-Type','application/json');
	        req1.setHeader('Authorization','Bearer '+sessionId);
	        req1.setHeader('Content-Length', '0');
	        
	        //req1.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/SpecialApprovalReassign/'+item);https://test.salesforce.com/services/Soap/u/26.0
	        req1.setEndpoint(System.Label.Special_Approval_URL+'/services/apexrest/SpecialApprovalReassign/'+item);
	        
	        Http http1 = new Http();
	        
	        if(!Test.isRunningTest())
	        HttpResponse res1 = http1.send(req1);
		
        //system.debug('res1' +  res1.getBody());
	}
}