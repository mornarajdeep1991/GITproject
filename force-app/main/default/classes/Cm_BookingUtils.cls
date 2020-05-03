/*
	 Author : Haribabu / Charan
	 Date :  
	 Description :
	 Modification History :
	 
1.1 Charan - Added Alert for Broker App when a unit is reserved cancelled.
1.2 HARI VATCHNAGES CLEAROT VAT VALUES ONCE UNIT GOT CANCELLED.
v1.3	Ravi	27/Mar/2018	Added the logic to Cancel the Online Sales Booking if the payment was not made with in an hour as per JIRA# EPESI-970
v1.4	Ravi	27/Mar/2018	Added the logic to send the order number during closed lost secondary contact details sync  JIRA# EPESI-1461
*/
global class Cm_BookingUtils{
	
	//v1.3
	public static Boolean isUpdateOpportunity = true;
	  
	@future(callout=true)
	public static void ApproveAdminRejection(Id oppId, string processName){
		string msg = Cm_BookingUtils.cancelSalesOrder(oppId,processName);
	} 
	
	public static string cancelSalesOrder(string strOportunityId,string ProcessName) { 
		string strMessage = '';
		try{
		
			list<Service_Logs__c> lstLogs = new list<Service_Logs__c>();
			list<Task> lstTasks = new list<Task>();
			set<id> setIds = new set<id>();
			Service_Logs__c objlog  = new Service_Logs__c ();
			
			//V1.1
			Opportunity opp = [Select id, Account.Name, stageName, is_from_broker_App__c, is_from_Customer_direct__c, cm_Reason_of_Rejection__c, cm_approval_Comments__c, Booking_status__c, cm_Approval_Status__c,cm_Remarks__c, cm_Agency_name__c, cm_sales_person__c from Opportunity where id=:strOportunityId];
			//Opportunity opp = [Select id, cm_Reason_of_Rejection__c, Booking_status__c, cm_Approval_Status__c,cm_Remarks__c from Opportunity where id=:strOportunityId];
			string remarks = '';
			
			if(opp.cm_Approval_Status__c == 'Rejection approved by Sales Manager' || opp.cm_Approval_Status__c == 'Rejected by Admin'){
				remarks = opp.cm_Reason_of_Rejection__c+' - '+opp.cm_Remarks__c;
			}
			//Approval Process Comments
			string strApprovalComments = '';
			list<ProcessInstance> lstProcessInstance = [SELECT TargetObjectId, ( SELECT Id, StepStatus, Comments FROM Steps ORDER BY CreatedDate DESC LIMIT 1 ) FROM ProcessInstance where TargetObjectId=:strOportunityId];
			if(lstProcessInstance!=null && lstProcessInstance.size() >0){
				if(lstProcessInstance[0].Steps!=null && lstProcessInstance[0].Steps.size() >0){
						strApprovalComments = lstProcessInstance[0].Steps[0].comments;
				}
			}
				system.debug('****Approval Process*****strApprovalComments'+strApprovalComments);
				if(strApprovalComments == ''){
					strApprovalComments = remarks;
				}

				System.debug('>>>>>>>>>remarks>>>>>>>>>>>>>'+remarks);
				list<Opportunity_Property__c> lstOpporunityProperty = [select id,Name,cm_Opportunity__c,cm_Opportunity__r.cm_approval_status__c, cm_Property_Inventory__c,cm_Inventory_Location_Code__c,Sales_Order__c, 
																						cm_Inventory_Location_ID__c,cm_Account_Number__c,VAT_Amount__c,VAT_RATE__C,Total_Amount__c,cm_Selling_Price__c,cm_Property_Inventory__r.Property_Type__c,cm_Property_Inventory__r.Blocked_Type__c,cm_Property_Inventory__r.Block_Reason__c from Opportunity_Property__c 
																						where cm_Opportunity__c =:strOportunityId];
				list<Opportunity_Property__c> lstOppProp = new list<Opportunity_Property__c>();
				
				Profile prof = [Select id from profile where name='System Administrator'];
				
				//V1.1
				List<Notification__c> lstAlerts = new List<Notification__c>();
				//v1.4
				map<string,string> mapSalesOrders = new map<string,string>();
				
				for(Opportunity_Property__c obj:lstOpporunityProperty){ 
					
					if(opp.Booking_status__c=='Booked in Oracle'){
						mapSalesOrders.put(obj.cm_Opportunity__c,obj.Sales_Order__c);
						//Order Update
						emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objOrderResponse = new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
						if(!test.isRunningTest()){
							objOrderResponse = EmaarWebServiceUtils.executePropertyStatusUpdate(obj.Sales_Order__c, obj.cm_Inventory_Location_ID__c,'BOOKED_CANCELLED','','','',strApprovalComments );
						}else{
							objOrderResponse.status = 'SUCCESS';
						}
						if(objOrderResponse.status == 'ERROR'){
							objlog = CreateLOg('Sales Order Cancellation Process - Order Update',strOportunityId,obj.id,objOrderResponse.ErrorMessage,objOrderResponse.status, objOrderResponse.ResultXML,'','','','','','','','','');
							objlog.Request__c = 'Sales Order :'+obj.Sales_Order__c+',Location ID:'+obj.cm_Inventory_Location_ID__c+', Status :BOOKED_CANCELLED,Remarks:'+strApprovalComments ;
							objlog.Log_Type__c = 'ERROR';
							lstLogs.add(objlog);
							
							Task tObj = new Task();
							tObj.WhatId = obj.Id;
							tObj.OwnerId = UserInfo.getUserId();
							tObj.subject = 'Order Cancellation failed to update in Oracle';
							tobj.Description = objOrderResponse.ErrorMessage;
							lstTasks.add(tObj);
						}
						else{
							objlog = CreateLOg('Sales Order Cancellation Process - Order Update',strOportunityId,obj.id,objOrderResponse.ErrorMessage,objOrderResponse.status,objOrderResponse.ResultXML,'','','','','','','','','');
							objlog.Request__c = 'Sales Order :'+obj.Sales_Order__c+',Location ID:'+obj.cm_Inventory_Location_ID__c+', Status :BOOKED_CANCELLED, Remarks'+strApprovalComments ;
							objlog.Log_Type__c = 'SUCCESS';
							lstLogs.add(objlog);
							
							obj.Sales_Order__c = '';
							obj.cm_Account_Number__c = '';
							obj.cm_Order_Status__c = null;
							obj.cm_order_Date__c = null;  
							//obj.cm_order_Status__c='BOOKED CANCELLED';
							obj.cm_order_Status__c = obj.cm_opportunity__r.cm_Approval_status__c == 'Payment Processing' ? 'PREBOOKING_CANCELLED' : 'BOOKED_CANCELLED';
							obj.Booking_Cancellation_Date__c = system.now();
							/***1.2*****VAT CHNAGES******************/
							obj.VAT_Amount__c = null;
							obj.VAT_RATE__C = null;
							obj.Total_Amount__c = null;
							/************END**********************/
							lstOppProp.add(obj);
							
							setIds.add(obj.cm_Property_Inventory__c);
						}
					}
					else{
							
						obj.Sales_Order__c = '';
						obj.cm_Account_Number__c = '';
						obj.cm_Order_Status__c = null;
						obj.cm_order_Date__c = null;  
						//obj.cm_order_Status__c='BOOKED CANCELLED';
						obj.cm_order_Status__c = obj.cm_opportunity__r.cm_Approval_status__c == 'Payment Processing' ? 'PREBOOKING_CANCELLED' : 'BOOKED_CANCELLED';
						obj.Booking_Cancellation_Date__c = system.now();
						/***1.2*****VAT CHNAGES******************/
						obj.VAT_Amount__c = null;
						obj.VAT_RATE__C = null;
						obj.Total_Amount__c = null;
						/************END**********************/
						lstOppProp.add(obj);
						
						setIds.add(obj.cm_Property_Inventory__c);
					}
				
					//V1.1
					if(opp.is_from_broker_App__c || opp.is_from_Customer_direct__c){
						System.debug('>>>>>>strApprovalComments>>>>>>>>>>>>>>'+opp.cm_approval_Comments__c+'>>>>>>>ProcessName>>>>>>>>>'+ProcessName);
						string message = '';
						//The purchase of <Position_ID> with <Customer_Name_Lastname> has been cancelled due to <Salesforce message from List of Values>. Please contact Emaar for further details. 
						if(opp.is_from_Customer_direct__c)
							message = 'The purchase of '+obj.cm_Inventory_Location_Code__c+' with '+opp.Account.Name+' has been cancelled due to '+ProcessName+'. Please contact Emaar for further details.';
						else
							message = 'The purchase of '+obj.cm_Inventory_Location_Code__c+' with '+opp.Account.Name+' has been cancelled due to '+opp.cm_approval_Comments__c+'. Please contact Emaar for further details.';
							//message = 'Booking of unit '+obj.cm_Inventory_Location_Code__c+' has been rejected due to '+opp.cm_approval_Comments__c;
						//Adeel - lstAlerts.add(RestServiceUtility.createNotification(opp.cm_Sales_person__c,opp.Id,opp.cm_agency_name__c,true, false,message));
					}
					
				}
				
				if(!lstOppProp.isEmpty()){
					//v1.3
					Cm_BookingUtils.isUpdateOpportunity = false;
					update lstOppProp;
				}
				//V1.1
				if(!lstAlerts.isEmpty())
					insert lstAlerts;
				
				if(!lstlogs.isEmpty())
					insert lstLogs;
		
			if(setIds!=null && setIds.size() > 0){
				list<Property_Inventory__c> lstprodata = [select id,cm_Sys_opportunity__c, name, Is_Bulk__c, Property_Status__c from Property_Inventory__c where ID IN:setIds and cm_Sys_opportunity__c=:strOportunityId];
				if(lstprodata!=null && lstprodata.size() >0){
					for(Property_Inventory__c objINV:lstprodata){
						objINV.Property_Status__c = 'Available';
						objInv.Release_Date_Time__c = System.Now();
						//objINV.Property_type__c = 'Blocked';
						objINV.payment_confirmation__C = false;
						objInv.cm_Sys_opportunity__c = null;
						objInv.cm_cancelled_at_booking_stage__c = true; 
						//Added on 13/07 as per discussion with Anas
						//Added this logic again on 06/09 as discussed with Anas
						//if(objInv.Is_Bulk__c && opp.stageName == 'Payment Processing')
							//objInv.Is_Bulk__c = false;	 
					}
					update lstprodata;
				}
			}
			if(lstOpporunityProperty.size() == lstOppProp.size() && strOportunityId!=null && strOportunityId!=''){
				Opportunity objOpportunity = new Opportunity(id=strOportunityId);
				objOpportunity.Property_Booked_Date__c = null;
				objOpportunity.cm_Booking_Cancellation_Time__c = null;
				objOpportunity.Booking_status__c = null;
				objOpportunity.Name = opp.Account.Name+'-'+string.valueof(System.Today().format());
				if(ProcessName == 'Approval Rejection'){
					objOpportunity.stageName ='Closed Lost';
					objOpportunity.cm_Approval_Status__c = 'Rejection approved by Sales Manager';
					//Adeel - cm_OpportunityTriggerUtility.isClosedAlready = true;
				}else{
					objOpportunity.cm_Approval_Status__c = '';
					
					//v1.3 - added the condition for Online Sales
					if(ProcessName != 'Online Sales - Auto Cancellation'){
						if(opp.Is_from_Broker_App__c || opp.Is_from_Customer_Direct__c){
							objOpportunity.recordtypeId=  CM_EmaarUtils.GetRecordTypeIdByDeveloperName('Opportunity','Generating_Sales_Offer'); 
							objOpportunity.stageName = 'Closed Lost';
						}
						else{
							objOpportunity.recordtypeId=  CM_EmaarUtils.GetRecordTypeIdByDeveloperName('Opportunity','Generating_Sales_Offer');
							objOpportunity.stageName = 'Generating Sales Offer'; 
						}
					}
					
					objOpportunity.cm_Is_Payment_done__c = false;
					objOpportunity.cm_status__c = '';
					// Added to clear the values which are populated with workflow on opportunity.
					objOpportunity.Sales_Order_No__c = '';
					objOpportunity.Order_Date__c = null;
					objOpportunity.Inventory_Location_Code__c = '';
					objOpportunity.No_of_Bedrooms__c = '';
					System.debug('>>>>>>>>>>Scheduled>>>>>>>>'+System.isScheduled());
					if(userInfo.getProfileId()==prof.Id)
						objOpportunity.Booking_Cancellation_Reason__c = 'Order was cancelled due to'+System.Label.BookingCancellationtime+' minutes expiration.';
					else
						objOpportunity.Booking_Cancellation_Reason__c = 'Cancelled by Property Advisor.';
					
					//v1.3
					if(ProcessName == 'Online Sales - Auto Cancellation'){
						objOpportunity.Booking_Cancellation_Reason__c = 'Online Sales - No Receipt created'; // this value being used in email alert to notify the sales team
						objOpportunity.cm_Remarks__c = 'Online Sales - Payment was not made within an hour of Booking';
						objOpportunity.StageName ='Closed Lost';
						objOpportunity.CloseDate = system.today();
						objOpportunity.recordtypeId=  CM_EmaarUtils.GetRecordTypeIdByDeveloperName('Opportunity','Closed_Lost');
					}//end of v1.3
				}
				//v1.4
				if(mapSalesOrders.containsKey(objOpportunity.Id))
					objOpportunity.Closed_Lost_Order_Number__c = mapSalesOrders.get(objOpportunity.Id);
				update objOpportunity;
			}
			
			if(lstOpporunityProperty.size() == lstOppProp.size())
				strMessage = 'Success';
			
		}catch(exception ex){
			strMessage =  ex.getMessage();
			Service_Logs__c objlog = CreateLOg('Sales Order Cancellation Process - Order Update',strOportunityId,'',strMessage,'','','','','','','','','','','');
			objlog.Log_Type__c = 'ERROR';
			insert objlog;
		}
		
		return strMessage;
	 }

	 /*
		 Method Name : CreateLOg
		 Description : This method is used to create the service log
	*/
	 public static Service_Logs__c CreateLOg(string ProcessName,String OppID,String OpporProperty,String ErrorMessage,String status,String responseXML,String OrderXML,String AccountXML,String locationID,string locationCode,string CampaignId ,string Campaignname,string UserOracleId,string OrgId,string parentID){
		 Service_Logs__c serlog = new Service_Logs__c();
		 serlog.Process_Name__c = ProcessName;
		 serlog.Process_Time__c = system.now();
		 serlog.Log_Type__c  = status;
		 if(OppID != '')
		 serlog.Opportunity__c = OppID;
		 if(parentID!='')
		 serlog.Parent_log__c = parentID;
		 serlog.AccountXML__c = AccountXML;
		 serlog.OrderXML__c = OrderXML;
		 serlog.Response__c = responseXML;
		 serlog.Error_Message__c = ErrorMessage;
		 if(locationID != '')
		 serlog.locationID__c = locationID;
		 serlog.locationCode__c = locationCode;
		 if(CampaignId != '')
		 serlog.CampaignId__c = CampaignId ;
		 serlog.Campaignname__c = Campaignname;
		 serlog.UserOracleId__c = UserOracleId;
		 if(OrgId!=null)
		 serlog.OrgId__c = string.valueof(OrgId);
		 if(OpporProperty != '' && OpporProperty.contains('PROINV-')){
			list<string> lst = OpporProperty.split('-');
			if(lst.size() > 1 && lst[1]!=null)
				serlog.Property_Inventory__c = lst[1]; 
		 }else if(OpporProperty != '' && (!OpporProperty.contains('PROINV'))){
			serlog.Opportunity_Property__c = OpporProperty; 
		 }
		 return serlog;
	 }
}