/*
    Author : Charan/Hari
    Name : EmaarWebServiceUtils
    Date :
    Description: WebserviceUtility for both Emaar & Nshama
    Modification History : 
    *************************************************************
Vesion	Author			Date				Description
v1.1	Ravi			16/Oct/2017			Added the logic to sync the PRimary Contact details with ORACLE when the Opportunity is closed won. 
v1.2    Umair			30/Oct/2017         repalce special characters from Address fields.
v1.3    Sandeep         10/Jan/2018         Inventory shuffling new method inventoryShuffling
v1.4	Ravi			19/Apr/2018			Added the logic for formating the Special Characters
*/

global  class EmaarWebServiceUtils {
    
    /*
		Method : executePaymentTerms
		Description : Service to get Payment Terms on Opportunity. 
		Parameters : Location Id, Amount, Date, Org Id, Header Id, Plot Price,Event Id, Schedule Type
    */
    public static emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element executePaymentTerms(string location_id,string damount,string strdate,string org_id,string sm_header_id,string plotprice,string event_id,string schedule_type){
		
		list<Property_inventory__c> lstproperty = [Select id, VAT_Amount__c,VAT_Rate__c, Location__r.Location_ID__c from Property_inventory__c where Location__r.Location_ID__c =: location_id];
		string VAT_AMOUNT='';
		string VAT_RATE='';
		if(lstproperty!=null && lstproperty.size() >0){
		    VAT_AMOUNT = string.valueof(lstproperty[0].VAT_Amount__c);
		    VAT_RATE = string.valueof(lstproperty[0].VAT_Rate__c);
		}
		
		Map<String, cm_Integration_Settings__c> mpSettings = cm_Integration_Settings__c.getAll();
		cm_Integration_Settings__c iSettings= mpSettings.containsKey('ORACLE') ? mpSettings.get('ORACLE'): new cm_Integration_Settings__c();
		
		emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresponse= new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
		emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt stub = new emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt();

        Map<String, User_Oracle_Settings__c> mpuserSettings = User_Oracle_Settings__c.getAll();
        User_Oracle_Settings__c iuserSettings= mpuserSettings.containsKey(UserInfo.getUserId()) ? mpuserSettings.get(UserInfo.getUserId()): new User_Oracle_Settings__c();
       
	//	User userRec = [Select id,cm_Oracle_Username__c, cm_Oracle_User_Id__c from User where Id =: UserInfo.getUserId()];
	
		string oraUserName = iuserSettings.cm_Oracle_Username__c != null? iuserSettings.cm_Oracle_Username__c : iSettings.Default_Oracle_Username__c;
		string oraUDID = iSettings.cm_UD_ID__c != null ? iSettings.cm_UD_ID__c : iSettings.Default_Oracle_User_ID__c;
		     
		stub.inputHttpHeaders_x = new Map<String, String>(); 
		String key = iSettings.cm_SOA_Key__c;
		string Encoded = EncodingUtil.base64Encode(blob.valueof(key));
		//Setting a basic authentication header 
		stub.inputHttpHeaders_x.put('Authorization','Basic '+Encoded);
		stub.timeout_x = 120000;
		string UserName = iSettings.cm_Username__c;
		string UDID = iSettings.cm_UD_ID__c;
		
		string Source = 'SALESFORCE';
		string Action = 'GET_UNIT_PAYMENT_TERMS';
		String AttachmentURL = '';
		String Param1 = location_id ; //'179866';
		String Param2 = damount; //'4529888.00';
		String Param3 = strdate ;//'13-Apr-2016';
		String Param4 = org_id ; //'81';
		String Param5 = sm_header_id;
		String Param6 = plotprice;
		String Param7 = ''; 
		String Param8 = schedule_type.touppercase();
		String Param9 = VAT_RATE;
		String Param10 = VAT_AMOUNT; //General Inventory'; 
		String Param11 = event_id; //250';
		String Param12 = ''; //R2 Lila-V-192';
		String Param13 = org_id; 
		String Param14 ='';
		String Param15 ='';
		String Param16 =''; // 'MTani@emaar.ae';
		String Param17 ='';
		String Param18 ='';
		String Param19 = oraUserName;
		String Param20 = oraUDID;
		objresponse =  stub.executePerformAction(UserName,UDID,Source,Action,AttachmentURL,Param1,Param2,Param3,Param4, Param5, Param6, Param7, Param8, Param9, Param10, Param11, Param12, Param13, Param14, Param15, Param16, Param17, Param18, Param19, Param20);
		system.debug('****objresponse'+objresponse);
		system.debug('****objresponse'+objresponse.status);
		system.debug('****objresponse'+objresponse.ErrorMessage);
		system.debug('****objresponse'+objresponse.ResultXML);
		return objresponse;
    }
   
   /* 
		Method : executeCreateSalesOrder
		Description : Service to Create Party & Sales Order. 
		Parameters : Account XML, Order XML, Location Id, Event Id, Campaign Id, Campaign Name, User Code, Org Id
   */
    public static emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element executeCreateSalesOrder(string AccountXML,string OrderXML,string LocationID ,string locationCode,string campaignID,string CampaignName,string userOracleCode,decimal OrgId){
		Map<String, cm_Integration_Settings__c> mpSettings = cm_Integration_Settings__c.getAll();
		cm_Integration_Settings__c iSettings= mpSettings.containsKey('ORACLE') ? mpSettings.get('ORACLE'): new cm_Integration_Settings__c();
		
		emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresponse= new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
		emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt stub = new emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt();
		stub.inputHttpHeaders_x = new Map<String, String>(); 
		
	//	user userRec = [Select id,cm_Oracle_Username__c, cm_Oracle_User_Id__c,email from User where Id =: UserInfo.getUserId()];
	
	    Map<String, User_Oracle_Settings__c> mpuserSettings = User_Oracle_Settings__c.getAll();
        User_Oracle_Settings__c iuserSettings= mpuserSettings.containsKey(UserInfo.getUserId()) ? mpuserSettings.get(UserInfo.getUserId()): new User_Oracle_Settings__c();
       
	//	User userRec = [Select id,cm_Oracle_Username__c, cm_Oracle_User_Id__c from User where Id =: UserInfo.getUserId()];
	
		string oraUserName = iuserSettings.cm_Oracle_Username__c != null? iuserSettings.cm_Oracle_Username__c : iSettings.Default_Oracle_Username__c;
		
	//	string oraUserName = userRec.cm_Oracle_Username__c != null? userRec.cm_Oracle_Username__c : iSettings.Default_Oracle_Username__c;
		string oraUDID = iSettings.cm_UD_ID__c != null ? iSettings.cm_UD_ID__c : iSettings.Default_Oracle_User_ID__c;
		
		User userRec;
		if(iuserSettings.User_Email__c == null){ // this will for broker app
			userRec = [Select id,cm_Oracle_Username__c, cm_Oracle_User_Id__c,Email from User where Id =: UserInfo.getUserId()];
		}
		Decimal userOrgId = CM_EmaarUtils.getOrgId('', '', '');
		
		
		String key = iSettings.cm_SOA_Key__c;
		string Encoded = EncodingUtil.base64Encode(blob.valueof(key));
		//Setting a basic authentication header 
		stub.inputHttpHeaders_x.put('Authorization','Basic '+Encoded);
		stub.timeout_x = 120000;
		string UserName = iSettings.cm_Username__c;
		string UDID = iSettings.cm_UD_ID__c;
		string Source = 'SALESFORCE'; // static
		string Action = 'CREATE_CUSTOMER_ACCOUNT'; // static
		String AttachmentURL = '';
		System.debug('@@AccountXML'+AccountXML);
		
		Blob cipherText = cm_AES_Encryptor.encrypt('AES128', blob.valueOf(iSettings.cm_AES_Key__c), blob.valueOf(AccountXML));
		
		String Param1 = EncodingUtil.convertToHex(cipherText).toLowerCase();
		String Param2 = 'CREATE_SALES_ORDER';
		String Param3 = LocationID; // Location ID
		
		Blob cipherText2 = cm_AES_Encryptor.encrypt('AES128', blob.valueOf(iSettings.cm_AES_Key__c), blob.valueOf(OrderXML));
		System.debug('>>>>>>>>>param4 Cipher>>>>>>>>>>>>>>>>>'+cipherText2);
		String Param4 = EncodingUtil.convertToHex(cipherText2).toLowerCase();
		System.debug('>>>>>>>>>param4>>>>>>>>>>>>>>>>>'+param4);
		String Param5 ;
		String Param6 ;
		String Param7 ;
		String Param8 ;
		String Param9 ;
		String Param10 = CampaignName;  // Campaign name-->
		String Param11 = CampaignId;  // CampaignId-->
		String Param12 = locationCode; // Location Code on location-->
		String Param13 = String.valueOf(userOrgId); 
		String Param14 ='1'; // Default Val
		String Param15 ='1'; // Default Val
		String Param16 = (iuserSettings.User_Email__c != null && iuserSettings.User_Email__c != '' ? iuserSettings.User_Email__c : userRec.email)  ; // logged in user Oracle ID //userRec.email;
		String Param17 ; 
		String Param18 ;
		String Param19 = oraUserName;
		String Param20 = oraUDID;
		objresponse =  stub.executePerformAction(UserName,UDID,Source,Action,AttachmentURL,Param1,Param2,Param3,Param4, Param5, Param6, Param7, Param8, Param9, Param10, Param11, Param12, Param13, Param14, Param15, Param16, Param17, Param18, Param19, Param20);
		system.debug('****objresponse'+objresponse.status);
		system.debug('****objresponse'+objresponse.ErrorMessage);
		system.debug('****objresponse'+objresponse.ResultXML);
		return objresponse;
    }
   
   /*
		Method : updateAsyncInventory
		Description : Service to Update Inventory from Trigger 
		Parameters : Location Id, Property Status, Selling Price, Blocked Reason, Blocked Date, Blocked Type
   */ 
    @future(callout = true)
    public static void updateAsyncInventory(string locationId, string status, string price, string blockedReason, string propType, string blockedType){
		
		Map<String, cm_Integration_Settings__c> mpSettings = cm_Integration_Settings__c.getAll();
		cm_Integration_Settings__c iSettings= mpSettings.containsKey('ORACLE') ? mpSettings.get('ORACLE'): new cm_Integration_Settings__c();
		
		emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresponse= new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
		emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt stub = new emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt();
		stub.inputHttpHeaders_x = new Map<String, String>(); 
		String key = iSettings.cm_SOA_Key__c;
		
		user userRec = [Select id,cm_Oracle_Username__c, cm_Oracle_User_Id__c from User where Id =: UserInfo.getUserId()];
		string oraUserName = userRec.cm_Oracle_Username__c != null? userRec.cm_Oracle_Username__c : iSettings.Default_Oracle_Username__c;
		string oraUDID = iSettings.cm_UD_ID__c != null ? iSettings.cm_UD_ID__c : iSettings.Default_Oracle_User_ID__c;
		Decimal orgId = CM_EmaarUtils.getOrgId('', '', '');
		
		string Encoded ='';
		if(key!=null && key!='Not Needed'){
		    Encoded = EncodingUtil.base64Encode(blob.valueof(key));
		    stub.inputHttpHeaders_x.put('Authorization','Basic '+Encoded);
		}
		
		stub.timeout_x = 120000;
		
		string UserName = iSettings.cm_Username__c;
		string UDID = iSettings.cm_UD_ID__c;
		string Source = 'SALESFORCE';
		string Action = 'UPDATE_PROP_ATTR';
		String AttachmentURL = '';
		String Param1 = locationid; //'179866';
		String Param2 = price; //'4529888.00';
		
		if(status=='Booked')
		    status = 'BOOKED_RESERVED';
		if(status=='')
		    status = 'Available';
		    
		System.debug('>>>>>>>>>Available>>>>>>>>>>>>'+status);  
		
		String Param3 = status;//'13-Apr-2016';
		String Param4 = blockedType ; //'81';
		String Param5 = blockedReason;
		String Param6 = propType;
		String Param7 = ''; 
		String Param8 = '';
		String Param9 = '';
		String Param10 = ''; //General Inventory'; 
		String Param11 = ''; //250';
		String Param12 = ''; //R2 Lila-V-192';
		String Param13 = String.valueOf(orgId); // Adeel, hardcoded org id, need to get it from location record
		String Param14 ='';
		String Param15 ='';
		String Param16 =''; // 'MTani@emaar.ae';
		String Param17 ='';
		String Param18 ='';
		String Param19 = OraUserName;
		String Param20 = oraUDID;
		objresponse =  stub.executePerformAction(UserName,UDID,Source,Action,AttachmentURL,Param1,Param2,Param3,Param4, Param5, Param6, Param7, Param8, Param9, Param10, Param11, Param12, Param13, Param14, Param15, Param16, Param17, Param18, Param19, Param20);
		system.debug('@@****objresponse'+objresponse);
		system.debug('@@****objresponse'+objresponse.status);
		
		system.debug('@@****objresponse'+objresponse.ErrorMessage);
		system.debug('@@****objresponse'+objresponse.ResultXML);
		//return objresponse;
    }
    
    /*
		Method : UpdateSyncInventory
		Description : Service to Update Inventory from Apex Classes 
		Parameters : Location Id, Property Status, Selling Price, Blocked Reason, Blocked Date, Blocked Type
    */ 
    public static emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element  updatesyncInventory(string locationId, string status, string price, string blockedReason, string propType, string blockedType){
		
		Map<String, cm_Integration_Settings__c> mpSettings = cm_Integration_Settings__c.getAll();
		cm_Integration_Settings__c iSettings= mpSettings.containsKey('ORACLE') ? mpSettings.get('ORACLE'): new cm_Integration_Settings__c();
		
		emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresponse= new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
		emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt stub = new emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt();
		stub.inputHttpHeaders_x = new Map<String, String>(); 
		
		String key = iSettings.cm_SOA_Key__c;
		Decimal orgId = CM_EmaarUtils.getOrgId('', '', '');
		
		string Encoded ='';
		if(key!=null && key!='Not Needed'){
		    Encoded = EncodingUtil.base64Encode(blob.valueof(key));
		    stub.inputHttpHeaders_x.put('Authorization','Basic '+Encoded);
		}
		
		stub.timeout_x = 120000;
		
		
		user userRec = [Select id,cm_Oracle_Username__c, cm_Oracle_User_Id__c from User where Id =: UserInfo.getUserId()];
		string oraUserName = userRec.cm_Oracle_Username__c != null? userRec.cm_Oracle_Username__c : iSettings.Default_Oracle_Username__c;
		string oraUDID = iSettings.cm_UD_ID__c != null ? iSettings.cm_UD_ID__c : iSettings.Default_Oracle_User_ID__c;
		
		
		string UserName = iSettings.cm_Username__c;
		string UDID = iSettings.cm_UD_ID__c;
		string Source = 'SALESFORCE';
		string Action = 'UPDATE_PROP_ATTR';
		String AttachmentURL = '';
		String Param1 = locationid; //'179866';
		String Param2 = price; //'4529888.00';
		
		if(status=='Booked')
		    status = 'BOOKED_RESERVED';
		if(status=='')
		    status = 'Available';
		    
		System.debug('>>>>>>>>>Available>>>>>>>>>>>>'+status);  
		
		String Param3 = status;//'13-Apr-2016';
		String Param4 = blockedType ; //'81';
		String Param5 = blockedReason;
		String Param6 = propType;
		String Param7 = ''; 
		String Param8 = '';
		String Param9 = '';
		String Param10 = ''; //General Inventory'; 
		String Param11 = ''; //250';
		String Param12 = ''; //R2 Lila-V-192';
		String Param13 = String.valueOf(orgId); // Adeel, hardcoded org id, need to get it from location record
		String Param14 ='';
		String Param15 ='';
		String Param16 =''; // 'MTani@emaar.ae';
		String Param17 ='';
		String Param18 ='';
		String Param19 = OraUserName;
		String Param20 = oraUDID;
		objresponse =  stub.executePerformAction(UserName,UDID,Source,Action,AttachmentURL,Param1,Param2,Param3,Param4, Param5, Param6, Param7, Param8, Param9, Param10, Param11, Param12, Param13, Param14, Param15, Param16, Param17, Param18, Param19, Param20);
		system.debug('****objresponse'+objresponse);
		system.debug('****objresponse'+objresponse.status);
		
		system.debug('****objresponse'+objresponse.ErrorMessage);
		system.debug('****objresponse'+objresponse.ResultXML);
		return objresponse;
    }
    
    /*
		Method : UpdateInventory
		Description : Service to Update Inventory from Apex Classes 
		Parameters : Location Id, Property Status, Selling Price, Blocked Reason, Blocked Date, Blocked Type
    */
    
    public static emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element updateInventory(string locationId, string status, string price, string blockedReason, string propType, string blockedType ){
		
		Map<String, cm_Integration_Settings__c> mpSettings = cm_Integration_Settings__c.getAll();
		cm_Integration_Settings__c iSettings= mpSettings.containsKey('ORACLE') ? mpSettings.get('ORACLE'): new cm_Integration_Settings__c();
		
		emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresponse= new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
		emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt stub = new emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt();
		stub.inputHttpHeaders_x = new Map<String, String>(); 
		String key = iSettings.cm_SOA_Key__c;
		
		string Encoded ='';
		if(key!=null && key!='Not Needed'){
		    Encoded = EncodingUtil.base64Encode(blob.valueof(key));
		    stub.inputHttpHeaders_x.put('Authorization','Basic '+Encoded);
		}
		
		user userRec = [Select id,cm_Oracle_Username__c, cm_Oracle_User_Id__c from User where Id =: UserInfo.getUserId()];
		string oraUserName = userRec.cm_Oracle_Username__c != null? userRec.cm_Oracle_Username__c : iSettings.Default_Oracle_Username__c;
		string oraUDID = iSettings.cm_UD_ID__c != null ? iSettings.cm_UD_ID__c : iSettings.Default_Oracle_User_ID__c;
		Decimal orgId = CM_EmaarUtils.getOrgId('', '', '');
		
		stub.timeout_x = 120000;
		
		string UserName = iSettings.cm_Username__c;
		string UDID = iSettings.cm_UD_ID__c;
		string Source = 'SALESFORCE';
		string Action = 'UPDATE_PROP_ATTR';
		String AttachmentURL = '';
		String Param1 = locationid; //'179866';
		String Param2 = price; //'4529888.00';
		
		if(status=='Booked')
		    status = 'BOOKED_RESERVED';
		if(status=='')
		    status = 'Available';
		    
		System.debug('>>>>>>>>>Available>>>>>>>>>>>>'+status);  
		
		String Param3 = status;//'13-Apr-2016';
		String Param4 = blockedType ; //'81';
		String Param5 = blockedReason;
		String Param6 = propType;
		String Param7 = ''; 
		String Param8 = '';
		String Param9 = '';
		String Param10 = ''; //General Inventory'; 
		String Param11 = ''; //250';
		String Param12 = ''; //R2 Lila-V-192';
		String Param13 = String.valueOf(orgId); // Adeel, hardcoded org id, need to get it from location record
		String Param14 ='';
		String Param15 ='';
		String Param16 =''; // 'MTani@emaar.ae';
		String Param17 ='';
		String Param18 ='';
		String Param19 = OraUserName;
		String Param20 = oraUDID;
		objresponse =  stub.executePerformAction(UserName,UDID,Source,Action,AttachmentURL,Param1,Param2,Param3,Param4, Param5, Param6, Param7, Param8, Param9, Param10, Param11, Param12, Param13, Param14, Param15, Param16, Param17, Param18, Param19, Param20);
		system.debug('****objresponse'+objresponse);
		system.debug('****objresponse'+objresponse.status);		
		system.debug('****objresponse'+objresponse.ErrorMessage);
		system.debug('****objresponse'+objresponse.ResultXML);
		return objresponse;
    }
      /*
		Method : ManageInventoryUpdates
		Description : Service to Update Inventory from Apex Classes 
		Parameters : Location Id, Property Status, Selling Price, Blocked Reason, Blocked Date, Blocked Type
    */
    
    public static emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element ManageInventoryUpdates(string locationId, string status, string price, string blockedReason, string propType, string blockedType,string strComments ){
		
		Map<String, cm_Integration_Settings__c> mpSettings = cm_Integration_Settings__c.getAll();
		cm_Integration_Settings__c iSettings= mpSettings.containsKey('ORACLE') ? mpSettings.get('ORACLE'): new cm_Integration_Settings__c();
		
		emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresponse= new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
		emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt stub = new emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt();
		stub.inputHttpHeaders_x = new Map<String, String>(); 
		String key = iSettings.cm_SOA_Key__c;
		
		string Encoded ='';
		if(key!=null && key!='Not Needed'){
		    Encoded = EncodingUtil.base64Encode(blob.valueof(key));
		    stub.inputHttpHeaders_x.put('Authorization','Basic '+Encoded);
		}
		
		user userRec = [Select id,cm_Oracle_Username__c, cm_Oracle_User_Id__c from User where Id =: UserInfo.getUserId()];
		string oraUserName = userRec.cm_Oracle_Username__c != null? userRec.cm_Oracle_Username__c : iSettings.Default_Oracle_Username__c;
		string oraUDID = iSettings.cm_UD_ID__c != null ? iSettings.cm_UD_ID__c : iSettings.Default_Oracle_User_ID__c;
		
		Decimal orgId = CM_EmaarUtils.getOrgId('', '', '');
		
		stub.timeout_x = 120000;
		
		string UserName = iSettings.cm_Username__c;
		string UDID = iSettings.cm_UD_ID__c;
		string Source = 'SALESFORCE';
		string Action = 'UPDATE_PROP_ATTR';
		String AttachmentURL = '';
		String Param1 = locationid; //'179866';
		String Param2 = price; //'4529888.00';
		
		if(status=='Booked')
		    status = 'BOOKED_RESERVED';
		if(status=='')
		    status = 'Available';
		    
		System.debug('>>>>>>>>>Available>>>>>>>>>>>>'+status);  
		
		String Param3 = status;//'13-Apr-2016';
		String Param4 = blockedType ; //'81';
		String Param5 = blockedReason;
		String Param6 = propType;
		String Param7 = strComments; 
		String Param8 = '';
		String Param9 = '';
		String Param10 = ''; //General Inventory'; 
		String Param11 = ''; //250';
		String Param12 = ''; //R2 Lila-V-192';
		String Param13 = String.valueOf(orgId); 
		String Param14 ='';
		String Param15 ='';
		String Param16 =''; // 'MTani@emaar.ae';
		String Param17 ='';
		String Param18 ='';
		String Param19 = OraUserName;
		String Param20 = oraUDID;
		objresponse =  stub.executePerformAction(UserName,UDID,Source,Action,AttachmentURL,Param1,Param2,Param3,Param4, Param5, Param6, Param7, Param8, Param9, Param10, Param11, Param12, Param13, Param14, Param15, Param16, Param17, Param18, Param19, Param20);
		system.debug('****objresponse'+objresponse);
		system.debug('****objresponse'+objresponse.status);		
		system.debug('****objresponse'+objresponse.ErrorMessage);
		system.debug('****objresponse'+objresponse.ResultXML);
		return objresponse;
    }
    
   /*
		Method : executePerformConcurrentAction_GETRECIEPT
		Description : Service to Create Receipts in Oracle 
		Parameters : Receipt Record, Opportunity Id
   */
   public static emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element executePerformConcurrentAction_GETRECIEPT(Reciepts__c rec,Id opporId){
		 
		 integer iTotal = 0;
		 integer isuccessCount = 0;
		 integer iErrorCount = 0;
		 list<Service_Logs__c> lstToinsert = new list<Service_Logs__c>();
		 iTotal = 1;
		system.debug('*****INSIDE********');
		Map<String, cm_Integration_Settings__c> mpSettings = cm_Integration_Settings__c.getAll();
		system.debug('***mpSettings****'+mpSettings);
		cm_Integration_Settings__c iSettings= mpSettings.containsKey('ORACLE') ? mpSettings.get('ORACLE'): new cm_Integration_Settings__c();
		Opportunity_Property__c oppProp = new Opportunity_Property__c();
		list<Opportunity_Property__c> listoppProp = [Select id, cm_Account_Number__c,Building__c, cm_Inventory_Location_Code__c, cm_Opportunity__r.campaign.Campaign_Number__c,cm_Opportunity__r.campaign.Type,cm_Opportunity__r.campaignId , cm_Org_Id__c, cm_Opportunity__r.Campaign.Name, cm_Opportunity__r.Campaign.Eloqua_ID__c, cm_Opportunity__r.cm_Token_No__c from Opportunity_Property__c where id=:opporId];
		if(listoppProp!=null && listoppProp.size() >0){
		    oppProp = listoppProp[0];
		}
		emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element  objresponse= new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
		emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt stub = new emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt();
		stub.inputHttpHeaders_x = new Map<String, String>(); 
		String key = iSettings.cm_SOA_Key__c;
		string Encoded = EncodingUtil.base64Encode(blob.valueof(key));
		//Setting a basic authentication header 
		stub.inputHttpHeaders_x.put('Authorization','Basic '+Encoded);
		stub.timeout_x = 120000;
				
		 list<CurrencyType> CurrencyTypeList = new list<CurrencyType>([select id,ConversionRate, IsActive, DecimalPlaces,IsoCode,IsCorporate from CurrencyType]);
		 map<string,double> CurrencyRateMap = new map<string,double>();
		 string ActiveCurrency = '';
		 for(CurrencyType cur : CurrencyTypeList){
		     if(cur.IsCorporate){
				 ActiveCurrency = cur.IsoCode;
		     }else{
				 CurrencyRateMap.put(cur.IsoCode,cur.ConversionRate);
		     }
		 }
		string RECEIPTXml = '<XX_RECEIPT_INFO>';
		try{
		    string UserName = iSettings.cm_Username__c;
		    string UDID = iSettings.cm_UD_ID__c;
		    string Source = 'SALESFORCE';
		    string Action = 'CREATE_RECEIPT';
		    String AttachmentURL;
		    
		    RECEIPTXml+='<XX_RECEIPT_DETAILS>';
		    RECEIPTXml+='<RECEIPT>';
		    RECEIPTXml+='<CREATED_BY_USER>'+UserInfo.getUserEmail()+'</CREATED_BY_USER>';
		    RECEIPTXml+='<CUST_ACCOUNT_NUMBER>'+oppProp.cm_Account_Number__c+'</CUST_ACCOUNT_NUMBER>';
		    RECEIPTXml+='<NO_OF_RECEIPTS>1</NO_OF_RECEIPTS>';
		    RECEIPTXml+='<ORG_ID>'+oppProp.cm_Org_Id__c+'</ORG_ID>'; //Need to populate this dynamically
		    RECEIPTXml+='<COLLECTION_CENTER>'+rec.Sales_Office__c +'</COLLECTION_CENTER>';
		    RECEIPTXml+='<RECEIPT_DATA1>';
	    	RECEIPTXml+='<RECEIPT_PAYMENT_METHOD>'+rec.Reciept_Payment_Mode__c+'</RECEIPT_PAYMENT_METHOD>';
		    RECEIPTXml+='<RECEIPT_NUMBER>'+rec.Reciept_Number__c+'</RECEIPT_NUMBER>';
		    
		    Time tm = Time.newInstance(0,0,0,0);
		    string receiptDate,maturityDate,glDate;
		    
		    DateTime dt = DateTime.newInstance(rec.Reciept_Date__c, tm);
		    string monthName = dt.format('MMM');
		    receiptDate = dt.day()+'-'+monthName+'-'+dt.year();
		    
		     
		    RECEIPTXml+='<RECEIPT_DATE>'+receiptDate+'</RECEIPT_DATE>';
		    
		    if(rec.GL_Date__c != null){
				DateTime dt2 = DateTime.newInstance(rec.GL_Date__c, Time.newInstance(0,0,0,0));
				monthName = dt2.format('MMM');
				glDate = dt2.day()+'-'+monthName+'-'+dt2.year();
				RECEIPTXml+='<MATURITY_DATE>'+glDate+'</MATURITY_DATE>';
				RECEIPTXml+='<GL_DATE>'+glDate+'</GL_DATE>';
		    }
		    RECEIPTXml+='<RECEIPT_AMOUNT>'+rec.Amount__c+'</RECEIPT_AMOUNT>';
		    RECEIPTXml+='<CURRENCY_CODE>'+rec.Currency__c+'</CURRENCY_CODE>';
		    if(rec.Currency__c != ActiveCurrency){
				RECEIPTXml+='<EXCHANGE_RATE_TYPE>User</EXCHANGE_RATE_TYPE>';
				RECEIPTXml+='<EXCHANGE_RATE>'+rec.Exchange_rate__c+'</EXCHANGE_RATE>';
				RECEIPTXml+='<EXCHANGE_DATE>'+receiptDate+'</EXCHANGE_DATE>';
		    }
				
		    RECEIPTXml+='<TYPE_OF_PAYMENT>'+rec.Payment_Mode__c+'</TYPE_OF_PAYMENT>';
		    RECEIPTXml+='<COMMENTS>'+rec.Comments__c+'</COMMENTS>';
		    RECEIPTXml+='<BALANCE_AMOUNT>0.00</BALANCE_AMOUNT>';
		    RECEIPTXml+='<PAID_BY>'+rec.cm_Paid_By__c+'</PAID_BY>';
		    RECEIPTXml+='<INSTALLMENT_DETAIL>'+rec.Installment_Details__c+'</INSTALLMENT_DETAIL>';
		    RECEIPTXml+='</RECEIPT_DATA1>';
		    RECEIPTXml+='</RECEIPT>';
		    RECEIPTXml+='</XX_RECEIPT_DETAILS>';
		    RECEIPTXml+='</XX_RECEIPT_INFO>';
				
		    RECEIPTXml = RECEIPTXml.trim();

		    System.debug('@@ReceiptXML='+RECEIPTXml);
				
		    Blob cipherText2 = cm_AES_Encryptor.encrypt('AES128', blob.valueOf(iSettings.cm_AES_Key__c), blob.valueOf(RECEIPTXml));
		    String Param1 = EncodingUtil.convertToHex(cipherText2);
		    System.debug('>>>>>>>>>param1>>>>>>>>>>>>>>'+param1);
		    
		    user userRec = [Select id,cm_Oracle_Username__c, cm_Oracle_User_Id__c from User where Id =: UserInfo.getUserId()];
		    string oraUserName = userRec.cm_Oracle_Username__c != null? userRec.cm_Oracle_Username__c : iSettings.Default_Oracle_Username__c;
		    string oraUDID = userRec.cm_Oracle_User_Id__c != null ? userRec.cm_Oracle_User_Id__c :'';
		    
		    
		    String Param2 = '';
		    String Param3 = '';
		    String Param4 = '';
		    String Param5 = '';
		    String Param6 = '';
		    String Param7 = '';
		    String Param8 = '';
		    String Param9 = '';
		    
		    map<String,Mobile_Configurations__c> mpConfigSettings = Mobile_Configurations__c.getAll();
		    string genCampaignId = mpConfigSettings.get('Configuration').Tempo_Campaign_ID__c;
		    
		    
		    String Param10 = oppProp.cm_Opportunity__r.Campaign.Name != null ? oppProp.cm_Opportunity__r.Campaign.Name : 'General Inventory'; 
		    String Param11 = oppProp.cm_Opportunity__r.CampaignId != null ? oppProp.cm_Opportunity__r.Campaign.Campaign_Number__c : '999999999' ;
		    String Param12 = oppProp.cm_Inventory_Location_Code__c;
		    String Param13 = oppProp.cm_Org_Id__c;
		    String Param14 = oppProp.cm_Opportunity__r.campaign.Type == 'Launch Sales' ? oppProp.cm_Opportunity__r.cm_Token_No__c:genCampaignId;
		    String Param15 = oppProp.cm_Account_NUmber__c;
		    String Param16 = oraUDID;
		    String Param17 = '0';
		    String Param18 = '';
		    String Param19 = OraUserName;
		    String Param20 = oraUDID;
		    
		    System.debug('>>>>>>>>>>param10>>>>>>>>>'+param10+'>>>>>>>>>>>param11>>>>>>>>'+param11+'>>>>>>>param12>>>>>>>>>>'+param12+'>>>>>>>>>param13>>>>>>>>>>>>>>'+param13+'>>>>>>param14>>>>>>>>'+param14+'>>>>>>>>>>>>>>>>>>>'+param15);
		    
		    objresponse =  stub.executePerformAction(UserName,UDID,Source,Action,AttachmentURL,Param1,Param2,Param3,Param4, Param5, Param6, Param7, Param8, Param9, Param10, Param11, Param12, Param13, Param14, Param15, Param16, Param17, Param18, Param19, Param20);
		    
		    system.debug('****objresponse'+objresponse.status);
		    system.debug('****objresponse'+objresponse.ErrorMessage);
		    system.debug('****objresponse'+objresponse.ResultXML);
		    
		    if(objresponse.status == 'SUCCESS'){		    
				rec.cm_keyToSend__c = Param10+'###'+param11+'###'+param12+'###'+param13+'###'+param14+'###'+param15+'###'+param16;
				//insert rec;
		    }
		    
		    Service_Logs__c objlog = CM_EmaarUtils.CreateLOg('Create Receipt',rec.Opportunity__c,string.valueof(rec.cm_Opportunity_Property__c),objresponse.ErrorMessage,objresponse.status, objresponse.ResultXML,'','','','','','','','','');
		    objlog.Request__c = RECEIPTXml;
		    objlog.Reciepts__c = rec.id;
		    insert objlog;
				    
		    return objresponse;
		}
		catch(Exception e){
		    Service_Logs__c objlog = CM_EmaarUtils.CreateLOg('Create Receipt',rec.Opportunity__c,string.valueof(rec.cm_Opportunity_Property__c),'','','','','','','','','','','','');
		    objLog.Error_Message__c = e.getMessage()+'- Line Number :'+e.getLineNumber();
		    objlog.Log_Type__c = 'ERROR';
		    objlog.Request__c = RECEIPTXml;
		    objlog.Reciepts__c = rec.id;
		    insert objlog;
		}
		return null;
    }
    
    /*
		Method : executePropertyStatusUpdate
		Description : Service to Update Order Status
		Parameters : SalesOrder Id on Opp Inventory, Location Id, Booking Status
    */
     public static emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element executePropertyStatusUpdate(string salesOrderId ,string unitLocationID, String BookingStatus){
		Map<String, cm_Integration_Settings__c> mpSettings = cm_Integration_Settings__c.getAll();
		cm_Integration_Settings__c iSettings= mpSettings.containsKey('ORACLE') ? mpSettings.get('ORACLE'): new cm_Integration_Settings__c();
		
		emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element  objresponse= new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
		emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt stub = new emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt();
		stub.inputHttpHeaders_x = new Map<String, String>(); 
		String key = iSettings.cm_SOA_Key__c;
		
		List<Opportunity_property__c> lstOP = [Select id, cm_Opportunity__c, cm_Opportunity__r.cm_Agency_Name__r.name, cm_Opportunity__r.cm_Agency_Name__r.cm_resource_Id__c from Opportunity_Property__c where sales_Order__c!=null and sales_Order__c=:salesOrderId];
		
		user userRec = [Select id,cm_Oracle_Username__c, cm_Oracle_User_Id__c from User where Id =: UserInfo.getUserId()];
		string oraUserName = userRec.cm_Oracle_Username__c != null? userRec.cm_Oracle_Username__c : iSettings.Default_Oracle_Username__c;
		string oraUDID = iSettings.cm_UD_ID__c != null ? iSettings.cm_UD_ID__c : iSettings.Default_Oracle_User_ID__c;
		Decimal orgId = CM_EmaarUtils.getOrgId(lstOP[0].cm_Opportunity__c, '', '');
		
		
		string Encoded = EncodingUtil.base64Encode(blob.valueof(key));
		//Setting a basic authentication header 
		stub.inputHttpHeaders_x.put('Authorization','Basic '+Encoded);
		stub.timeout_x = 120000;
		string UserName = iSettings.cm_Username__c;
		string UDID = iSettings.cm_UD_ID__c;
		string Source = 'SALESFORCE';
		string Action = 'UPDATE_ORDER_STATUS';
		String AttachmentURL;
		String Param1 = salesOrderId; // Sales order Number 
		String Param2 = unitLocationID;
		String Param3 = BookingStatus; // BOOKED_CANCELLED_RESERVED
		String Param4 = '';
		String Param5 = '';
		String Param6 = '';  
		String Param7 = 'Public';
		String Param8 = 'Tempo';
		String Param9 = '';
		String Param10 = ''; 
		String Param11 = '';
		
		String Param12 = '';
		
		if(!lstOP.isEmpty() && lstOP[0].cm_Opportunity__r.cm_Agency_Name__c != null && lstOP[0].cm_Opportunity__r.cm_Agency_Name__r.cm_resource_Id__c != null)
		Param12 = lstOP[0].cm_Opportunity__r.cm_Agency_Name__r.name;
		
		String Param13 = String.valueOf(orgId);
		//if(op.cm_Opportunity__r.cm_Agency_Name__c != null && op.cm_Opportunity__r.cm_Agency_Name__r.cm_resource_id__c != null)
		//Param13 = op.cm_Opportunity__r.cm_Agency_Name__r.cm_resource_id__c;
		String Param14 = '';
		String Param15 ='';
		String Param16 = '';
		String Param17 = '';
		String Param18 = '';
		String Param19 = OraUserName;
		String Param20 = oraUDID;

		objresponse =  stub.executePerformAction(UserName,UDID,Source,Action,AttachmentURL,Param1,Param2,Param3,Param4, Param5, Param6, Param7, Param8, Param9, Param10, Param11, Param12, Param13, Param14, Param15, Param16, Param17, Param18, Param19, Param20);
		system.debug('****objresponse'+objresponse.status);
		system.debug('****objresponse'+objresponse.ErrorMessage);
		system.debug('****objresponse'+objresponse.ResultXML);
		return objresponse;
    }
    
		   
    /*
		Method : executePropertyStatusUpdate
		Description : Service to Update Order Status
		Parameters : SalesOrder Id on Opp Inventory, Location Id, Booking Status
    */
     public static emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element executePropertyStatusUpdate(string salesOrderId ,string unitLocationID, String BookingStatus,string Ordersource,string OrderEvent){
		Map<String, cm_Integration_Settings__c> mpSettings = cm_Integration_Settings__c.getAll();
		cm_Integration_Settings__c iSettings= mpSettings.containsKey('ORACLE') ? mpSettings.get('ORACLE'): new cm_Integration_Settings__c();
		
		emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element  objresponse= new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
		emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt stub = new emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt();
		stub.inputHttpHeaders_x = new Map<String, String>(); 
		String key = iSettings.cm_SOA_Key__c;
		
		Opportunity_property__c op = [Select id, cm_Opportunity__c, cm_Opportunity__r.cm_Agency_Name__r.name, cm_Opportunity__r.cm_Agency_Name__r.cm_resource_Id__c from Opportunity_Property__c where sales_Order__c!=null and sales_Order__c=:salesOrderId];
		
		user userRec = [Select id,cm_Oracle_Username__c, cm_Oracle_User_Id__c from User where Id =: UserInfo.getUserId()];
		string oraUserName = userRec.cm_Oracle_Username__c != null? userRec.cm_Oracle_Username__c : iSettings.Default_Oracle_Username__c;
		string oraUDID = iSettings.cm_UD_ID__c != null ? iSettings.cm_UD_ID__c : iSettings.Default_Oracle_User_ID__c;
		
		Decimal orgId = CM_EmaarUtils.getOrgId(op.cm_Opportunity__c, '', '');
		
		
		string Encoded = EncodingUtil.base64Encode(blob.valueof(key));
		//Setting a basic authentication header 
		stub.inputHttpHeaders_x.put('Authorization','Basic '+Encoded);
		stub.timeout_x = 120000;
		string UserName = iSettings.cm_Username__c;
		string UDID = iSettings.cm_UD_ID__c;
		string Source = 'SALESFORCE';
		string Action = 'UPDATE_ORDER_STATUS';
		String AttachmentURL;
		String Param1 = salesOrderId; // Sales order Number 
		String Param2 = unitLocationID;
		String Param3 = BookingStatus; // BOOKED_CANCELLED_RESERVED
		String Param4 = '';
		String Param5 = '';
		String Param6 = '';  
		String Param7 = Ordersource;
		String Param8 = OrderEvent;
		String Param9 = '';
		String Param10 = ''; 
		String Param11 = '';
		String Param12 = '';
		if(op.cm_Opportunity__r.cm_Agency_Name__c != null && op.cm_Opportunity__r.cm_Agency_Name__r.name != null)
		Param12 = op.cm_Opportunity__r.cm_Agency_Name__r.name;
		
		String Param13 = String.valueOf(orgId);
		//if(op.cm_Opportunity__r.cm_Agency_Name__c != null && op.cm_Opportunity__r.cm_Agency_Name__r.cm_resource_id__c != null)
		//Param13 = op.cm_Opportunity__r.cm_Agency_Name__r.cm_resource_id__c;
		
		String Param14 = '';
		String Param15 ='';
		String Param16 = '';
		String Param17 = '';
		String Param18 = '';
		String Param19 = OraUserName;
		String Param20 = oraUDID;

		objresponse =  stub.executePerformAction(UserName,UDID,Source,Action,AttachmentURL,Param1,Param2,Param3,Param4, Param5, Param6, Param7, Param8, Param9, Param10, Param11, Param12, Param13, Param14, Param15, Param16, Param17, Param18, Param19, Param20);
		system.debug('****objresponse'+objresponse.status);
		system.debug('****objresponse'+objresponse.ErrorMessage);
		system.debug('****objresponse'+objresponse.ResultXML);
		return objresponse;
    }
     /*
		Method : executePropertyStatusUpdate
		Description : Service to Update Order Status
		Parameters : SalesOrder Id on Opp Inventory, Location Id, Booking Status
    */
     public static emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element executePropertyStatusUpdate(string salesOrderId ,string unitLocationID, String BookingStatus,string Ordersource,string OrderEvent,string LRWavier,string ApprovalComments){
		Map<String, cm_Integration_Settings__c> mpSettings = cm_Integration_Settings__c.getAll();
		cm_Integration_Settings__c iSettings= mpSettings.containsKey('ORACLE') ? mpSettings.get('ORACLE'): new cm_Integration_Settings__c();
		
		emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element  objresponse= new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
		emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt stub = new emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt();
		stub.inputHttpHeaders_x = new Map<String, String>(); 
		String key = iSettings.cm_SOA_Key__c;
		
		
		user userRec = [Select id,cm_Oracle_Username__c,Email, cm_Oracle_User_Id__c from User where Id =: UserInfo.getUserId()];
		string oraUserName = userRec.cm_Oracle_Username__c != null? userRec.cm_Oracle_Username__c : iSettings.Default_Oracle_Username__c;
		string oraUDID = iSettings.cm_UD_ID__c != null ? iSettings.cm_UD_ID__c : iSettings.Default_Oracle_User_ID__c;
		
		
		//Opportunity_property__c op = [Select id, cm_Opportunity__c, cm_Opportunity__r.cm_Agency_Name__r.name, cm_Opportunity__r.cm_Agency_Name__r.cm_resource_Id__c from Opportunity_Property__c where sales_Order__c=:salesOrderId];
		Opportunity_Property__c oppProp = [Select id,cm_Opportunity__c,cm_Opportunity__r.cm_Sales_person__c, cm_opportunity__r.cm_Payment_Mode__c,cm_Opportunity__r.cm_Agency_Name__r.name, cm_Opportunity__r.cm_Agency_Name__r.cm_resource_Id__c from Opportunity_Property__c where Sales_Order__c!=null and Sales_Order__c =: salesOrderId];
		
		String AdvisorResourceId = '';
		if(oppProp.cm_Opportunity__r.cm_Sales_person__c != null){
		    User u = [Select id,Resource_Id__c from User where Id =: oppProp.cm_Opportunity__r.cm_Sales_person__c];
		    AdvisorResourceId = u.Resource_Id__c;
		}
		
		
		string Encoded = EncodingUtil.base64Encode(blob.valueof(key));
		
		
		
		
		//Setting a basic authentication header 
		stub.inputHttpHeaders_x.put('Authorization','Basic '+Encoded);
		stub.timeout_x = 120000;
		string UserName = iSettings.cm_Username__c;
		string UDID = iSettings.cm_UD_ID__c;
		string Source = 'SALESFORCE';
		string Action = 'UPDATE_ORDER_STATUS';
		String AttachmentURL;
		String Param1 = salesOrderId; // Sales order Number 
		String Param2 = unitLocationID;
		String Param3 = BookingStatus; // BOOKED_CANCELLED_RESERVED
		String Param4 = userRec.Email;
		String Param5 = '';
		String Param6 = ApprovalComments;  
		String Param7 = Ordersource;
		String Param8 = OrderEvent;
		String Param9 = LRWavier;
		String Param10 = ''; 
		String Param11 = '';
		
		String Param12 = '';
		if(oppProp.cm_Opportunity__r.cm_Agency_Name__c != null && oppProp.cm_Opportunity__r.cm_Agency_Name__r.cm_resource_Id__c != null)
		Param12 = oppProp.cm_Opportunity__r.cm_Agency_Name__r.cm_resource_Id__c ;
		
		String Param13 = AdvisorResourceId;
		//if(oppProp.cm_Opportunity__r.cm_Agency_Name__c != null && oppProp.cm_Opportunity__r.cm_Agency_Name__r.cm_resource_id__c != null)
		//Param13 = oppProp.cm_Opportunity__r.cm_Agency_Name__r.cm_resource_id__c;
		
		String Param14 = '';
		String Param15 ='';
		String Param16 = '';
		String Param17 = '';
		String Param18 = oppProp.cm_opportunity__r.cm_Payment_Mode__c == null ? '' : oppProp.cm_opportunity__r.cm_Payment_Mode__c;
		String Param19 = OraUserName;
		String Param20 = oraUDID;

		objresponse =  stub.executePerformAction(UserName,UDID,Source,Action,AttachmentURL,Param1,Param2,Param3,Param4, Param5, Param6, Param7, Param8, Param9, Param10, Param11, Param12, Param13, Param14, Param15, Param16, Param17, Param18, Param19, Param20);
		system.debug('****objresponse'+objresponse.status);
		system.debug('****objresponse'+objresponse.ErrorMessage);
		system.debug('****objresponse'+objresponse.ResultXML);
		return objresponse;
    }

    /*
    Method to execute property status update from trigger
    */
    @future(callout=true) //string salesOrderId ,string unitLocationID, String BookingStatus,string Ordersource,string OrderEvent,string LRWavier,string ApprovalComments
    public static void callPropertyStatusUpdate(String salesOrderId,String unitLocationID,String BookingStatus,String Ordersource,String OrderEvent,String LRWavier,String ApprovalComments){
		emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element resp = EmaarWebServiceUtils.executePropertyStatusUpdate(salesOrderId,unitLocationID,BookingStatus, Ordersource,OrderEvent,LRWavier,ApprovalComments);
		if(resp.Status == 'SUCCESS'){
			Id inventoryId = [Select ID, cm_Property_Inventory__c FROM Opportunity_Property__c where Sales_Order__c =: salesOrderId].cm_Property_Inventory__c;
			if(inventoryId != null){
				Property_Inventory__c pi = new Property_Inventory__c(Id = inventoryId);
				if(BookingStatus == 'RESERVED'){
					pi.Property_Status__c = 'Reserved';
				}
				if(BookingStatus == 'CANCELLED'){
					pi.Property_Status__c = 'Available';
				}
				upsert pi;
			}
		}
    }

    public static emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element UpdatePropertyBulk(string bulkPropXML){
		Map<String, cm_Integration_Settings__c> mpSettings = cm_Integration_Settings__c.getAll();
		cm_Integration_Settings__c iSettings= mpSettings.containsKey('ORACLE') ? mpSettings.get('ORACLE'): new cm_Integration_Settings__c();
      
		emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element  objresponse= new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
		emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt stub = new emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt();
		
		stub.inputHttpHeaders_x = new Map<String, String>(); 
		String key = iSettings.cm_SOA_Key__c;
		string Encoded = EncodingUtil.base64Encode(blob.valueof(key));
		//Setting a basic authentication header 
		stub.inputHttpHeaders_x.put('Authorization','Basic '+Encoded);
		stub.timeout_x = 120000;
		
		User userRec = [Select id,cm_Oracle_Username__c, cm_Oracle_User_Id__c from User where Id =: UserInfo.getUserId()];
		string oraUserName = userRec.cm_Oracle_Username__c != null? userRec.cm_Oracle_Username__c : iSettings.Default_Oracle_Username__c;
		string oraUDID = iSettings.cm_UD_ID__c != null ? iSettings.cm_UD_ID__c : iSettings.Default_Oracle_User_ID__c;

		Decimal userOrgId = CM_EmaarUtils.getOrgId('', '', '');
		
		string UserName = iSettings.cm_Username__c;
		
		string UDID = iSettings.cm_UD_ID__c;
		string Source = 'SALESFORCE';
		string Action = 'UPDATE_BULK_PROP_ATTR';
		String AttachmentURL;
		bulkPropXML = bulkPropXML.trim();
		Blob cipherText2 = cm_AES_Encryptor.encrypt('AES128', blob.valueOf(iSettings.cm_AES_Key__c), blob.valueOf(bulkPropXML));
		String Param1 = EncodingUtil.convertToHex(cipherText2);
		//string Param1 = cipherText2;
		System.debug('>>>>>>>>>param1>>>>>>>>>>>>>>'+param1); 
		    
		String Param2 = '';
		String Param3 = '';
		String Param4 = '';
		String Param5 = '';
		String Param6 = '';
		String Param7 = '';
		String Param8 = '';
		String Param9 = '';
		String Param10 = ''; 
		String Param11 = '';
		String Param12 = '';
		String Param13 = String.valueOf(userOrgId); // Adeel, hardcoded org id, need to get it from location record
		String Param14 = '';
		String Param15 = '';
		String Param16 = '';
		String Param17 = '';
		String Param18 = '';
		String Param19 = oraUsername;
		String Param20 = oraUDID;
		
		objresponse =  stub.executePerformAction(UserName,UDID,Source,Action,AttachmentURL,Param1,Param2,Param3,Param4, Param5, Param6, Param7, Param8, Param9, Param10, Param11, Param12, Param13, Param14, Param15, Param16, Param17, Param18, Param19, Param20);
		
		system.debug('****objresponse'+objresponse.status);
		system.debug('****objresponse'+objresponse.ErrorMessage);
		system.debug('****objresponse'+objresponse.ResultXML);
		/*
		Service_Logs__c objlog = new Service_Logs__c(); 
		objlog.Request__c = bulkPropXML;
		objlog.Response__c = objresponse.ResultXML;
		objlog.Process_Name__c = 'Bulk Inventory - Update';
		objlog.Log_Type__c = objresponse.status;
		objlog.Error_Message__c = objresponse.ErrorMessage;
		insert objlog;
		*/
		return objresponse;
    }
    
    @future(callout=true)
    public static void callUpdatePartyService(string accXml, string recId){
		EmaarWebServiceUtils.UpdatePartyService(accXML,recId);
    }
    
    
    
    public static Map<id,string> mpaccountXML = new Map<id,string>();
    public static boolean isUpdated = false;  
    
    public static emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element UpdatePartyService(string partyXML, string recordId){

		Map<String, cm_Integration_Settings__c> mpSettings = cm_Integration_Settings__c.getAll();
		cm_Integration_Settings__c iSettings= mpSettings.containsKey('ORACLE') ? mpSettings.get('ORACLE'): new cm_Integration_Settings__c();
      
		emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element  objresponse= new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
		emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt stub = new emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt();

		Map<String, User_Oracle_Settings__c> mpuserSettings = User_Oracle_Settings__c.getAll();
        User_Oracle_Settings__c iuserSettings= mpuserSettings.containsKey(UserInfo.getUserId()) ? mpuserSettings.get(UserInfo.getUserId()): new User_Oracle_Settings__c();
		
		stub.inputHttpHeaders_x = new Map<String, String>(); 
		String key = iSettings.cm_SOA_Key__c;
		string Encoded = EncodingUtil.base64Encode(blob.valueof(key));
		//Setting a basic authentication header 
		stub.inputHttpHeaders_x.put('Authorization','Basic '+Encoded);
		stub.timeout_x = 120000;
		
		User userRec;
		if(iuserSettings.User_Email__c == null){ // this will for broker app
			userRec = [Select id,cm_Oracle_Username__c, cm_Oracle_User_Id__c,Email from User where Id =: UserInfo.getUserId()];
		}
		//User userRec = [Select id,cm_Oracle_Username__c, cm_Oracle_User_Id__c from User where Id =: UserInfo.getUserId()];
		string oraUserName = userRec.cm_Oracle_Username__c != null? userRec.cm_Oracle_Username__c : iSettings.Default_Oracle_Username__c;
		string oraUDID = iSettings.cm_UD_ID__c != null ? iSettings.cm_UD_ID__c : iSettings.Default_Oracle_User_ID__c;
		
		Decimal userOrgId = CM_EmaarUtils.getOrgId('', '', '');
		
		string UserName = iSettings.cm_Username__c;
		
		string UDID = iSettings.cm_UD_ID__c;
		string Source = 'SALESFORCE';
		string Action = 'UPDATE_PARTY';
		String AttachmentURL;
		partyXML = partyXML.trim();
		Blob cipherText2 = cm_AES_Encryptor.encrypt('AES128', blob.valueOf(iSettings.cm_AES_Key__c), blob.valueOf(partyXML));
		String Param1 = EncodingUtil.convertToHex(cipherText2);
		//string Param1 = cipherText2;
		System.debug('>>>>>>>>>param1>>>>>>>>>>>>>>'+param1); 
		    
		String Param2 = '';
		String Param3 = '';
		String Param4 = '';
		String Param5 = '';
		String Param6 = '';
		String Param7 = '';
		String Param8 = '';
		String Param9 = '';
		String Param10 = ''; 
		String Param11 = '';
		String Param12 = '';
		String Param13 = String.valueOf(userOrgId); // Adeel, hardcoded org id, need to get it from location record
		String Param14 = '';
		String Param15 = '';
		String Param16 = '';
		String Param17 = '';
		String Param18 = '';
		String Param19 = oraUserName;
		String Param20 = oraUDID;
		
		try{
		    objresponse =  stub.executePerformAction(Username,UDID,Source,Action,AttachmentURL,Param1,Param2,Param3,Param4, Param5, Param6, Param7, Param8, Param9, Param10, Param11, Param12, Param13, Param14, Param15, Param16, Param17, Param18, Param19, Param20);
		    
		    system.debug('****objresponse'+objresponse.status);
		    system.debug('****objresponse'+objresponse.ErrorMessage);
		    system.debug('****objresponse'+objresponse.ResultXML);
		    
		    Service_Logs__c objlog = new Service_Logs__c(); 
		    objlog.Request__c = partyXML;
		    objlog.Response__c = objresponse.ResultXML;
		    objlog.Process_Time__c = system.now();
		    objlog.Process_Name__c = 'Party - Update';
		    objlog.Log_Type__c = objresponse.status;
		    objLog.Account__c = recordId;
		    objlog.Error_Message__c = objresponse.ErrorMessage;
		    insert objlog;
		}
		catch(Exception e){
		    Service_Logs__c objlog = new Service_Logs__c(); 
		    objlog.Request__c = partyXML;
		    objlog.Response__c = e.getMessage();
		    objlog.Process_Time__c = system.now();
		    objlog.Process_Name__c = 'Party - Update';
		    objlog.Log_Type__c = 'Error';
		    objLog.Account__c = recordId;
		    objlog.Error_Message__c = e.getMessage();
		    insert objlog;
		}
		
		return objresponse;
    }
    
    public static List<Service_Logs__c> lstLogs2Insert = new List<Service_Logs__c>();
    
    public static emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element updateJointOwnerService(string recordId, string salesOrderId,string DMLAction, string primaryOwnerId, string newPartyId){
		
		Map<String, cm_Integration_Settings__c> mpSettings = cm_Integration_Settings__c.getAll();
		cm_Integration_Settings__c iSettings= mpSettings.containsKey('ORACLE') ? mpSettings.get('ORACLE'): new cm_Integration_Settings__c();
      
		emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element  objresponse= new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
		emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt stub = new emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt();
		
		stub.inputHttpHeaders_x = new Map<String, String>(); 
		String key = iSettings.cm_SOA_Key__c;
		string Encoded = EncodingUtil.base64Encode(blob.valueof(key));
		//Setting a basic authentication header 
		stub.inputHttpHeaders_x.put('Authorization','Basic '+Encoded);
		stub.timeout_x = 120000;
		
		User userRec = [Select id,cm_Oracle_Username__c, cm_Oracle_User_Id__c from User where Id =: UserInfo.getUserId()];
		string oraUserName = userRec.cm_Oracle_Username__c != null? userRec.cm_Oracle_Username__c : iSettings.Default_Oracle_Username__c;
		string oraUDID = iSettings.cm_UD_ID__c != null ? iSettings.cm_UD_ID__c : iSettings.Default_Oracle_User_ID__c;
		
		
		
		string UserName = iSettings.cm_Username__c;
		string UDID = iSettings.cm_UD_ID__c;
		string Source = 'SALESFORCE';
		string Action = 'UPDATE_JOINT_OWNER';
		String AttachmentURL;		
		String Param1 = primaryOwnerId;
		String Param2 = newPartyId;
		String Param3 = salesOrderId;
		String Param4 = DMLAction;
		String Param5 = '';
		String Param6 = '';
		String Param7 = '';
		String Param8 = '';
		String Param9 = '';
		String Param10 = ''; 
		String Param11 = '';
		String Param12 = '';
		String Param13 = '127'; // Adeel, hardcoded org id, need to get it from location record
		String Param14 = '';
		String Param15 = '';
		String Param16 = '';
		String Param17 = '';
		String Param18 = '';
		String Param19 = oraUserName;
		String Param20 = oraUDID;
		
		try{
		    objresponse =  stub.executePerformAction(UserName,UDID,Source,Action,AttachmentURL,Param1,Param2,Param3,Param4, Param5, Param6, Param7, Param8, Param9, Param10, Param11, Param12, Param13, Param14, Param15, Param16, Param17, Param18, Param19, Param20);
		    
		    system.debug('****objresponse'+objresponse.status);
		    system.debug('****objresponse'+objresponse.ErrorMessage);
		    system.debug('****objresponse'+objresponse.ResultXML);
		    
		    Service_Logs__c objlog = new Service_Logs__c(); 
		    objlog.Request__c = 'Param 1 : '+ Param1+ '\n';
		    objlog.Request__c +='Param 2 : '+ Param2+ '\n';
		    objlog.Request__c +='Param 3 : '+ Param3+ '\n';
		    objlog.Request__c +='Param 4 : '+ Param4+ '\n';
		    objlog.Response__c = objresponse.ResultXML;
		    objlog.Process_Time__c = system.now();
		    objlog.Process_Name__c = 'Joint Owner - Update';
		    objlog.Log_Type__c = objresponse.status;
		    objLog.Opportunity_Property__c = recordId;
		    objlog.Error_Message__c = objresponse.ErrorMessage;
		    lstLogs2Insert.add(objlog);
		}
		catch(Exception e){
		    Service_Logs__c objlog = new Service_Logs__c(); 
		    objlog.Request__c = 'Param 1 : '+ Param1+ '\n';
		    objlog.Request__c +='Param 2 : '+ Param2+ '\n';
		    objlog.Request__c +='Param 3 : '+ Param3+ '\n';
		    objlog.Request__c +='Param 4 : '+ Param4+ '\n';
		    objlog.Response__c = e.getMessage();
		    objlog.Process_Time__c = system.now();
		    objlog.Process_Name__c = 'Joint Owner - Update';
		    objlog.Log_Type__c = 'Error';
		    objLog.Opportunity_Property__c = recordId;
		    objlog.Error_Message__c = e.getMessage();
		    lstLogs2Insert.add(objlog);
		}
		
		return objresponse;
    }
    
    public static string createPartyXML(Account objAccount){
				    
		Map<String,String> countryCodes = new Map<String,String>();
		Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		System.debug('Picklist::'+ple);
		for( Schema.PicklistEntry f : ple){
		    countryCodes.put(f.getLabel(),f.getValue());
		}   
		
		RecordType rec = [Select id from RecordType where name='Individual Account' and sobjecttype='Account'];
		
		System.debug('>>>>>>Person Account>>>>>>>>>'+objAccount.isPersonAccount);
		string strAccountRTType = '';
		if(objAccount.recordTypeId != rec.Id)
		    strAccountRTType = 'ORGANIZATION';
		else
		    strAccountRTType = 'PERSON';
		
		String monthName=''; 
		string Day ;
		integer year;
    
		integer phonecountryCode = (objAccount.cm_Phone_Country_Code__c != '' && objAccount.cm_Phone_Country_Code__c != null) ? integer.valueOf(objAccount.cm_Phone_Country_Code__c.split(':')[1].trim()):0;
		string PhoneArea = (objAccount.Phone != '' && objAccount.Phone != null) ? objAccount.Phone.substring(0,2):'';
		string phoneNum = (objAccount.Phone != '' && objAccount.Phone != null) ? objAccount.Phone.substring(2,objAccount.Phone.length()):'';
    
		integer mobilecountryCode =0;
		string mobileArea = '';
		string mobileNum = '';
		string nationality = '';
		string countryOfResidence = '';
		if(strAccountRTType == 'PERSON' ){
		    mobileArea = (objAccount.PersonMobilephone != null && objAccount.PersonMobilephone != '') ? objAccount.PersonMobilephone.substring(0,2):'';
		    mobileNum = (objAccount.PersonMobilephone != null && objAccount.PersonMobilephone != '') ? objAccount.PersonMobilephone.substring(2,objAccount.PersonMobilephone.length()):'';
		    nationality = (objAccount.cm_Nationality__pc != null && objAccount.cm_Nationality__pc != '') ? (countryCodes.containsKey(objAccount.cm_Nationality__pc)?countryCodes.get(objAccount.cm_Nationality__pc):''):'';
		    mobilecountryCode = (objAccount.cm_Mobile_Country_Code__pc != '' && objAccount.cm_Mobile_Country_Code__pc != null) ? integer.valueof(objAccount.cm_Mobile_Country_Code__pc.split(':')[1].trim()):0;
		    countryOfResidence = '';
		}
		
		System.debug(mobileArea+'>>>>>>>>>>'+mobileNum+'>>>>>>>>>>>'+phoneNum+'>>>>>>>>'+PhoneArea);
		string nationalityId = objAccount.cm_National_ID_No__pc != null ? objAccount.cm_National_ID_No__pc:'';
		string placeofBirth = objAccount.cm_Place_Of_Birth__pc != null ? objAccount.cm_Place_Of_Birth__pc:'';
		string passportId = objAccount.cm_Passport_Number__pc != null ? objAccount.cm_Passport_Number__pc:'';
		string gender = objAccount.cm_Gender__pc == null ? '' : objAccount.cm_Gender__pc;
		string middleName = objAccount.MiddleName != null?objAccount.MiddleName:'';
		string title = objAccount.Salutation != null ? objAccount.Salutation.toUpperCase():'';
		//string incorpCountry = objAccount.cm_Country_Of_Incorporation__c != null ? objAccount.cm_Country_Of_Incorporation__c : '';
		string incorpCountry = countryCodes.containsKey(objAccount.cm_Country_Of_Incorporation__c) ? countryCodes.get(objAccount.cm_Country_Of_Incorporation__c) : '';
		//string citycorpCountry = objAccount.City_of_Incorporation__c != null ? objAccount.City_of_Incorporation__c : '';
		string tradeLicenseNo = objAccount.cm_Trade_License_Number__c != null ? objAccount.cm_Trade_License_Number__c : '';
		string partyId = objAccount.Party_Id__c;
		
		string billingState = (objAccount.billingState != null && objAccount.billingState != '' ) ? '-'+objAccount.billingState.replaceAll('&','amp;'):'.'; 
		billingState = CM_EmaarUtils.formtStringValue(billingState);
		
		string street = (objAccount.BillingStreet != null && objAccount.BillingStreet != '') ? objAccount.BillingStreet.replaceAll('&','amp;'):'.';
		street = CM_EmaarUtils.formtStringValue(street);
		
		string city = (objAccount.BillingCity != null && objAccount.BillingCity != '' ) ? objAccount.BillingCity.replaceAll('&','amp;'):'.';
		city = CM_EmaarUtils.formtStringValue(city);
		
		string state = (objAccount.BillingState != null && objAccount.BillingState != '' ) ? objAccount.BillingState.replaceAll('&','amp;'):'.';
		state = CM_EmaarUtils.formtStringValue(state);
		
		string countryCode = (objAccount.BillingCountry != null && objAccount.BillingCountry != '') ? countryCodes.get(objAccount.Billingcountry):'AE';
		
		string country = (objAccount.BillingCountry != null && objAccount.BillingCountry != '') ? objAccount.BillingCountry.replaceAll('&','amp;'):'AE';
		country = CM_EmaarUtils.formtStringValue(country);
		
		System.debug('>>>>>>>>>>>>>partyId>>>>>>>>>>>>>>>>'+partyId);
    
		//string billingState = objAccount.billingState != null ? '-'+objAccount.billingState:''; 
    
		string nationalExpiryDate  ='';
		if(objAccount.cm_National_ID_Expiry_Date__pc != null){
		    DateTime d = objAccount.cm_National_ID_Expiry_Date__pc;
		    monthName= d.format('MMM');
    
		    Day= string.valueof(d.day());
		    if(integer.valueof(day) < 10)
		    day= '0' + day;
    
		    year= d.year();
		    nationalExpiryDate  = Day+'-'+monthName+'-'+year;
		}
    
		string incorpDate  ='';
		if(objAccount.cm_Date_of_Incorporation__c != null){
		    DateTime d = objAccount.cm_Date_of_Incorporation__c;
		    monthName= d.format('MMM');
    
		    Day= string.valueof(d.day());
		    if(integer.valueof(day) < 10)
		    day= '0' + day;
    
		    year= d.year();
		    incorpDate  = Day+'-'+monthName+'-'+year;
		}
    
		string tradeLicenseExpDate='';
		if(objAccount.cm_Trade_License_Expiry_Date__c!=null){
		    DateTime d = objAccount.cm_Trade_License_Expiry_Date__c;
		    monthName= d.format('MMM');
    
		    Day= string.valueof(d.day());
		    if(integer.valueof(day) < 10)
		    day= '0' + day;
    
		    year= d.year();
		    tradeLicenseExpDate  = Day+'-'+monthName+'-'+year;
		}
    
    
		string visaExpiryDate  ='';
		if(objAccount.cm_Visa_Expiry_Date__pc != null){
		    DateTime d = objAccount.cm_Visa_Expiry_Date__pc;
		    monthName= d.format('MMM');
    
		    Day= string.valueof(d.day());
		    if(integer.valueof(day) < 10)
		    day = '0' + day;
    
		    year = d.year();
		    visaExpiryDate = Day+'-'+monthName+'-'+year;
		}
    
		string passportIssueDate  ='';
		if(objAccount.cm_Passport_Issue_Date__pc != null){
		    DateTime d = objAccount.cm_Passport_Issue_Date__pc;
		    monthName= d.format('MMM');
    
		    Day= string.valueof(d.day());
		    if(integer.valueof(day) < 10)
		    day= '0' + day;
    
		    year= d.year();
		    passportIssueDate = Day+'-'+monthName+'-'+year;
		}
    
		string Birthdate  ='';
		if(objAccount.cm_Birthdate__pc!=null){
		    DateTime d = objAccount.cm_Birthdate__pc;
		    monthName= d.format('MMM');
    
		    Day= string.valueof(d.day());
		    if(integer.valueof(day) < 10)
		    day= '0' + day;
    
		    year= d.year();
		    Birthdate  = Day+'-'+monthName+'-'+year;
		}
    
		string passportExpiryDate='';
		if(objAccount.cm_Passport_Expiry_Date__pc!=null){
		    DateTime d = objAccount.cm_Passport_Expiry_Date__pc;
		    monthName= d.format('MMM');
    
		    Day= string.valueof(d.day());
		    if(integer.valueof(day) < 10)
		    day= '0' + day;
    
		    year= d.year();
		    passportExpiryDate  = Day+'-'+monthName+'-'+year;
		}
    
		integer phoneCount = 0;
		if(objAccount.isPersonAccount && objAccount.PersonmobilePhone != null)
		    phoneCount ++;
		if(objAccount.Phone != null)
		    phoneCount ++;
    
		integer emailCount = 0;
		if(objAccount.PersonEmail != null)
		    emailCount++;   
		
		
		System.debug('>>>>>>>countryCode>>>>>>>>'+countryCode);
		System.debug('>>>>>>>BillingCountry>>>>>>>>'+objAccount.BillingCountry);
		string AccountXML = '<XX_PARTY_INFO>';
		AccountXML = AccountXML+'<XX_PARTY_DETAILS>';
		AccountXML = AccountXML+'<PARTY>';
		AccountXML = AccountXML+'<P_TITLE>'+title+'</P_TITLE>';//'+objAccount.PersonTitle+'
		AccountXML = AccountXML+'<P_DESIGNATION/>';
		AccountXML = AccountXML+'<P_GLOBAL_PARTY_ID/>';
		AccountXML = AccountXML+'<P_PARTY_ID>'+partyId+'</P_PARTY_ID>';
		AccountXML = AccountXML+'<P_PARTY_TYPE>'+strAccountRTType +'</P_PARTY_TYPE>';
		AccountXML = AccountXML+'<P_FIRST_NAME>'+CM_EmaarUtils.formtStringValue(objAccount.FirstName)+'</P_FIRST_NAME>'; //v1.4 - added CM_EmaarUtils.formtStringValue 
		AccountXML = AccountXML+'<P_MIDDLE_NAME>'+CM_EmaarUtils.formtStringValue(middleName)+'</P_MIDDLE_NAME>';
		AccountXML = AccountXML+'<P_LAST_NAME>'+CM_EmaarUtils.formtStringValue(objAccount.LastName)+'</P_LAST_NAME>';
		AccountXML = AccountXML+'<P_FULL_NAME>'+CM_EmaarUtils.formtStringValue(objAccount.Name)+'</P_FULL_NAME>';				    
		AccountXML = AccountXML+'<P_NATIONALITY>'+nationality+'</P_NATIONALITY>';//'+objAccount.cm_Nationality__pc+'
		AccountXML = AccountXML+'<P_PLACE_OF_BIRTH>'+CM_EmaarUtils.formtStringValue(placeofBirth)+'</P_PLACE_OF_BIRTH>';
		AccountXML = AccountXML+'<P_NATIONAL_ID>'+nationalityId+'</P_NATIONAL_ID>';
		AccountXML = AccountXML+'<P_NATIONAL_ID_EXPIRY>'+nationalExpiryDate+'</P_NATIONAL_ID_EXPIRY>';
		//AccountXML = AccountXML+'<P_VISA_EXPIRY_DATE>'+visaExpiryDate+'</P_VISA_EXPIRY_DATE>';
		if(objAccount.isPersonAccount){
		    AccountXML = AccountXML+'<P_ID_TYPE>PASSPORT</P_ID_TYPE>';//'+objAccount.cm_Passport_Number__pc+'
		    AccountXML = AccountXML+'<P_ID>'+passportId+'</P_ID>';
		    AccountXML = AccountXML+'<P_ID_EXPIRY_DATE>'+passportExpiryDate+'</P_ID_EXPIRY_DATE>';//'+expdate+'
		    
		    AccountXML = AccountXML+'<VISA_NUMBER>'+objAccount.Visa_No__pc+'</VISA_NUMBER>';
			AccountXML = AccountXML+'<VISA_ISSUE>'+CM_EmaarUtils.formatORACLEDate(objAccount.Visa_Issue_Date__pc)+'</VISA_ISSUE>';
			AccountXML = AccountXML+'<VISA_EXPIRY>'+CM_EmaarUtils.formatORACLEDate(objAccount.cm_Visa_Expiry_Date__pc)+'</VISA_EXPIRY>';
		    
		}
		
		 string pobox = objAccount.cm_P_O_Box__c != null ? objAccount.cm_P_O_Box__c : '';
		 pobox = CM_EmaarUtils.formtStringValue(pobox);
		 
		 string postalcode = objAccount.Billingpostalcode != null ? objAccount.Billingpostalcode : '';
		 postalcode =  CM_EmaarUtils.formtStringValue(postalcode);
		
		AccountXML = AccountXML+'<P_ID_ISSUE_DATE>'+passportIssueDate+'</P_ID_ISSUE_DATE>';
		AccountXML = AccountXML+'<P_DOB>'+Birthdate+'</P_DOB>';//'+Birthdate+'
		AccountXML = AccountXML+'<P_AGE_GROUP></P_AGE_GROUP>';
		AccountXML = AccountXML+'<P_AVG_MONTHLY_INCOME></P_AVG_MONTHLY_INCOME>';		    
		AccountXML = AccountXML+'<P_ADDRESS1>'+street+'</P_ADDRESS1><P_ADDRESS2/>';
		AccountXML = AccountXML+'<P_POBOX>'+pobox+'</P_POBOX>';//objAccount.cm_P_O_Box__c
		AccountXML = AccountXML+'<P_CITY>'+city+'-'+billingState+'</P_CITY>';//
		AccountXML = AccountXML+'<P_POSTAL_CODE>'+postalcode+'</P_POSTAL_CODE>';//'objAccount.Billingpostalcode//+objAccount.Billingpostalcode+'
		AccountXML = AccountXML+'<P_COUNTRY>'+countryCode+'</P_COUNTRY>';
		AccountXML = AccountXML+'<P_LOCATION_ID></P_LOCATION_ID>';
		AccountXML += '<P_STATE>'+(objAccount.BillingState != null ? objAccount.BillingState : (objAccount.BillingCountry == 'United States' ? 'NY' : ''))+'</P_STATE>';
		AccountXML = AccountXML+'<P_PHONE_COUNT>'+phoneCount+'</P_PHONE_COUNT>';
		AccountXML = AccountXML+'<P_EMAIL_COUNT>'+EmailCount+'</P_EMAIL_COUNT>';
		AccountXML = AccountXML+'<P_GENDER>'+objAccount.cm_Gender__pc+'</P_GENDER>';//'+gender+'
		AccountXML = AccountXML+'<P_DATE_OF_INCORPORATION>'+incorpDate+'</P_DATE_OF_INCORPORATION>';
		AccountXML = AccountXML+'<P_COUNTRY_OF_INCORPORATION>'+incorpCountry+'</P_COUNTRY_OF_INCORPORATION>';
		//AccountXML = AccountXML+'<cm_City_Of_Incorporation__c>'+citycorpCountry+'</cm_City_Of_Incorporation__c>';
		AccountXML = AccountXML+'<P_TRADE_LICENSE_EXPIRY_DATE>'+tradeLicenseExpDate+'</P_TRADE_LICENSE_EXPIRY_DATE>';
		AccountXML = AccountXML+'<P_INCORPORATION_AUTHORITY/>';
		AccountXML = AccountXML+'<P_COUNTRY_OF_RESIDENCE>'+countryOfResidence+'</P_COUNTRY_OF_RESIDENCE>';
		AccountXML = AccountXML+'</PARTY>';
		AccountXML = AccountXML+'<PHONE_DETAILS>';
    
		AccountXML = AccountXML+'<PHONE_DETAIL><P_CONTACT_POINT_TYPE>PHONE</P_CONTACT_POINT_TYPE><P_PHONE_LINE_TYPE>MOBILE</P_PHONE_LINE_TYPE><P_PHONE_COUNTRY_CODE>'+mobilecountryCode+'</P_PHONE_COUNTRY_CODE><P_PHONE_AREA_CODE>'+mobileArea+'</P_PHONE_AREA_CODE><P_PHONE_NUMBER>'+mobileNum+'</P_PHONE_NUMBER></PHONE_DETAIL>';
    
		if(phoneNum != null && phoneNum != '0')
		    AccountXML = AccountXML+'<PHONE_DETAIL><P_CONTACT_POINT_TYPE>PHONE</P_CONTACT_POINT_TYPE><P_PHONE_LINE_TYPE>GEN</P_PHONE_LINE_TYPE><P_PHONE_COUNTRY_CODE>'+phonecountryCode+'</P_PHONE_COUNTRY_CODE><P_PHONE_AREA_CODE>'+phoneArea+'</P_PHONE_AREA_CODE><P_PHONE_NUMBER>'+phoneNum+'</P_PHONE_NUMBER></PHONE_DETAIL>';
    
		AccountXML = AccountXML+'</PHONE_DETAILS>';
    
		if(EmailCount>0){
		    if(strAccountRTType == 'PERSON')
				AccountXML = AccountXML+'<EMAIL_DETAILS><EMAIL_DETAIL><P_CONTACT_POINT_TYPE>EMAIL</P_CONTACT_POINT_TYPE><P_EMAIL_ADDRESS>'+objAccount.PersonEmail+'</P_EMAIL_ADDRESS></EMAIL_DETAIL></EMAIL_DETAILS>';
		}   
		
		/*********************1.4*********VAT CHANGES************************************************/
			
			if(objAccount.Emirate__c!=null)
		        AccountXML = AccountXML+'<P_VAT_EMIRATE>'+objAccount.Emirate__c+'</P_VAT_EMIRATE>';
		    else
		       AccountXML = AccountXML+'<P_VAT_EMIRATE></P_VAT_EMIRATE>';
		       
		    if(objAccount.VAT_Registration_No__c!=null) 
		        AccountXML = AccountXML+'<P_VAT_REGNUMBER>'+objAccount.VAT_Registration_No__c+'</P_VAT_REGNUMBER>';
		    else
		       AccountXML = AccountXML+'<P_VAT_REGNUMBER></P_VAT_REGNUMBER>';
		       
			/******************************VAT CHANGES************************************************/
		
		AccountXML = AccountXML+'</XX_PARTY_DETAILS>';
		AccountXML += '<XX_JOINT_OWNERS/>';
		AccountXML += '</XX_PARTY_INFO>';
		AccountXML = AccountXML.replaceAll('null','');
		AccountXML = AccountXML.trim();
		System.debug('>>>>>>>>>accountXML>>>>>>>>>>>'+accountXML);
		return AccountXML;
    }
    
    //v1.1
	/* 
		Method : syncPrimaryContactDetails
		Description : sync the Primary Contact details with ORACLE when the Opportunity is closed won. 
		Parameters : Account XML, Order XML, Location Id, Event Id, Campaign Id, Campaign Name, User Code, Org Id
   */
    public static emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element syncPrimaryContactDetails(string AccountXML,string OrderXML,string LocationID ,string locationCode,string campaignID,string CampaignName,string userOracleCode,decimal OrgId){
		Map<String, cm_Integration_Settings__c> mpSettings = cm_Integration_Settings__c.getAll();
		cm_Integration_Settings__c iSettings= mpSettings.containsKey('ORACLE') ? mpSettings.get('ORACLE'): new cm_Integration_Settings__c();
		
		emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresponse= new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
		emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt stub = new emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt();
		stub.inputHttpHeaders_x = new Map<String, String>(); 
		
		user userRec = [Select id,cm_Oracle_Username__c, cm_Oracle_User_Id__c,email from User where Id =: UserInfo.getUserId()];
		string oraUserName = userRec.cm_Oracle_Username__c != null? userRec.cm_Oracle_Username__c : iSettings.Default_Oracle_Username__c;
		string oraUDID = iSettings.cm_UD_ID__c != null ? iSettings.cm_UD_ID__c : iSettings.Default_Oracle_User_ID__c;
		
		
		
		String key = iSettings.cm_SOA_Key__c;
		string Encoded = EncodingUtil.base64Encode(blob.valueof(key));
		//Setting a basic authentication header 
		stub.inputHttpHeaders_x.put('Authorization','Basic '+Encoded);
		stub.timeout_x = 120000;
		string UserName = iSettings.cm_Username__c;
		string UDID = iSettings.cm_UD_ID__c;
		string Source = 'SALESFORCE'; // static
		string Action = 'CREATE_SECONDARY_CONTACT'; // static
		String AttachmentURL = '';
		Blob cipherText = cm_AES_Encryptor.encrypt('AES128', blob.valueOf(iSettings.cm_AES_Key__c), blob.valueOf(AccountXML));
		
		String Param1 = EncodingUtil.convertToHex(cipherText).toLowerCase();
		String Param2;
		String Param3;
		String Param4;
		String Param5 ;
		String Param6 ;
		String Param7 ;
		String Param8 ;
		String Param9 ;
		String Param10;
		String Param11;
		String Param12;
		String Param13;
		String Param14;
		String Param15;
		String Param16;
		String Param17;
		String Param18;
		String Param19;
		String Param20;
		objresponse =  stub.executePerformAction(UserName,UDID,Source,Action,AttachmentURL,Param1,Param2,Param3,Param4, Param5, Param6, Param7, Param8, Param9, Param10, Param11, Param12, Param13, Param14, Param15, Param16, Param17, Param18, Param19, Param20);
		system.debug('****objresponse'+objresponse.status);
		system.debug('****objresponse'+objresponse.ErrorMessage);
		system.debug('****objresponse'+objresponse.ResultXML);
		return objresponse;
    }
    
    	
	/* 
		Method 		: executeExpressionOfInterestParty
		Created By 	: Adeel Ahmad (adeel.ahmad@4c.com)
		Date       	: 16/05/2018 
		Description : Service to create EOI party in oracle.
		Parameters 	: Account XML, UserOracleId, orgId
   */
    public static emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element executeCreateExpressionOfInterest(string AccountXML,decimal OrgId){
		Map<String, cm_Integration_Settings__c> mpSettings = cm_Integration_Settings__c.getAll();
		cm_Integration_Settings__c iSettings= mpSettings.containsKey('ORACLE') ? mpSettings.get('ORACLE'): new cm_Integration_Settings__c();
		
		emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresponse= new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
		emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt stub = new emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt();
		stub.inputHttpHeaders_x = new Map<String, String>(); 
			
	    Map<String, User_Oracle_Settings__c> mpuserSettings = User_Oracle_Settings__c.getAll();
        User_Oracle_Settings__c iuserSettings= mpuserSettings.containsKey(UserInfo.getUserId()) ? mpuserSettings.get(UserInfo.getUserId()): new User_Oracle_Settings__c();
       
		string oraUserName = iuserSettings.cm_Oracle_Username__c != null? iuserSettings.cm_Oracle_Username__c : iSettings.Default_Oracle_Username__c;
		
	//	string oraUserName = userRec.cm_Oracle_Username__c != null? userRec.cm_Oracle_Username__c : iSettings.Default_Oracle_Username__c;
		string oraUDID = iSettings.cm_UD_ID__c != null ? iSettings.cm_UD_ID__c : iSettings.Default_Oracle_User_ID__c;
		
		User userRec;
		if(iuserSettings.User_Email__c == null){ // this will for broker app
			userRec = [Select id,cm_Oracle_Username__c, cm_Oracle_User_Id__c,Email from User where Id =: UserInfo.getUserId()];
		}

		//Getting the org id
		Decimal userOrgId = CM_EmaarUtils.getOrgId('','','');
		
		String key = iSettings.cm_SOA_Key__c;
		string Encoded = EncodingUtil.base64Encode(blob.valueof(key));
		//Setting a basic authentication header 
		stub.inputHttpHeaders_x.put('Authorization','Basic '+Encoded);
		stub.timeout_x = 120000;
		string UserName = iSettings.cm_Username__c;
		string UDID = iSettings.cm_UD_ID__c;
		string Source = 'SALESFORCE'; // static
		string Action = 'EXPRESSION_OF_INTEREST'; // static
		String AttachmentURL = '';
		
		String Param1 = AccountXML; //EncodingUtil.convertToHex(cipherText).toLowerCase();
		String Param2 ;
		String Param3 ; // Location ID
		String Param4 ;
		String Param5 ;
		String Param6 ;
		String Param7 ;
		String Param8 ;
		String Param9 ;
		String Param10 = 'Expression Of Interest';  // Account Name
		String Param11 ;  // CampaignId-->
		String Param12 ; // Location Code on location-->
		String Param13 = String.valueOf(userOrgId); // Adeel, hardcoded org id, need to get it from location record
		String Param14 ='1'; // Default Val
		String Param15 ='1'; // Default Val
		String Param16 = ''; //TODO:need to findout why it is necessary
		String Param17 ; 
		String Param18 ;
		String Param19 = oraUserName;
		String Param20 = oraUDID;
		objresponse =  stub.executePerformAction(UserName,UDID,Source,Action,AttachmentURL,Param1,Param2,Param3,Param4, Param5, Param6, Param7, Param8, Param9, Param10, Param11, Param12, Param13, Param14, Param15, Param16, Param17, Param18, Param19, Param20);
		return objresponse;
    }

    /*
		Method : executePerformConcurrentAction_GETRECIEPT_EOI
		Description : Service to Create Receipts in Oracle for EOI
		Parameters : Receipt Record, Opportunity Id
   */
   public static emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element executePerformConcurrentAction_GETRECIEPT_EOI(Reciepts__c rec,String customerAccountNumber, Integer OrgId){
		 
		integer iTotal = 0;
		integer isuccessCount = 0;
		integer iErrorCount = 0;
		list<Service_Logs__c> lstToinsert = new list<Service_Logs__c>();
		iTotal = 1;
		system.debug('*****INSIDE********');
		Map<String, cm_Integration_Settings__c> mpSettings = cm_Integration_Settings__c.getAll();
		system.debug('***mpSettings****'+mpSettings);
		cm_Integration_Settings__c iSettings= mpSettings.containsKey('ORACLE') ? mpSettings.get('ORACLE'): new cm_Integration_Settings__c();
		//Getting the org id
		Decimal userOrgId = CM_EmaarUtils.getOrgId('','','');
		
		emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element  objresponse= new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
		emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt stub = new emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt();
		stub.inputHttpHeaders_x = new Map<String, String>(); 
		String key = iSettings.cm_SOA_Key__c;
		string Encoded = EncodingUtil.base64Encode(blob.valueof(key));
		//Setting a basic authentication header 
		stub.inputHttpHeaders_x.put('Authorization','Basic '+Encoded);
		stub.timeout_x = 120000;
				
		 list<CurrencyType> CurrencyTypeList = new list<CurrencyType>([select id,ConversionRate, IsActive, DecimalPlaces,IsoCode,IsCorporate from CurrencyType]);
		 map<string,double> CurrencyRateMap = new map<string,double>();
		 string ActiveCurrency = '';
		 for(CurrencyType cur : CurrencyTypeList){
		     if(cur.IsCorporate){
				 ActiveCurrency = cur.IsoCode;
		     }else{
				 CurrencyRateMap.put(cur.IsoCode,cur.ConversionRate);
		     }
		 }
		string RECEIPTXml = '<XX_RECEIPT_INFO>';
		try{
		    string UserName = iSettings.cm_Username__c;
		    string UDID = iSettings.cm_UD_ID__c;
		    string Source = 'SALESFORCE';
		    string Action = 'CREATE_RECEIPT_EOI';
		    String AttachmentURL;
		    
		    RECEIPTXml+='<XX_RECEIPT_DETAILS>';
		    RECEIPTXml+='<RECEIPT>';
		    RECEIPTXml+='<CREATED_BY_USER>'+UserInfo.getUserEmail()+'</CREATED_BY_USER>';
		    RECEIPTXml+='<CUST_ACCOUNT_NUMBER>'+customerAccountNumber+'</CUST_ACCOUNT_NUMBER>';
		    RECEIPTXml+='<NO_OF_RECEIPTS>1</NO_OF_RECEIPTS>';
		    RECEIPTXml+='<ORG_ID>'+userOrgId+'</ORG_ID>'; 
		    RECEIPTXml+='<COLLECTION_CENTER>'+rec.Sales_Office__c+'</COLLECTION_CENTER>';
		    RECEIPTXml+='<RECEIPT_DATA1>';
	    	RECEIPTXml+='<RECEIPT_PAYMENT_METHOD>'+rec.Reciept_Payment_Mode__c+'</RECEIPT_PAYMENT_METHOD>';
		    RECEIPTXml+='<RECEIPT_NUMBER>'+rec.Reciept_Number__c+'</RECEIPT_NUMBER>';
		    
		    Time tm = Time.newInstance(0,0,0,0);
		    string receiptDate,maturityDate,glDate;
		    
		    DateTime dt = DateTime.newInstance(rec.Reciept_Date__c, tm);
		    string monthName = dt.format('MMM');
		    receiptDate = dt.day()+'-'+monthName+'-'+dt.year();
		    
		     
		    RECEIPTXml+='<RECEIPT_DATE>'+receiptDate+'</RECEIPT_DATE>';
		    
		    if(rec.GL_Date__c != null){
				DateTime dt2 = DateTime.newInstance(rec.GL_Date__c, Time.newInstance(0,0,0,0));
				monthName = dt2.format('MMM');
				glDate = dt2.day()+'-'+monthName+'-'+dt2.year();
				RECEIPTXml+='<MATURITY_DATE>'+glDate+'</MATURITY_DATE>';
				RECEIPTXml+='<GL_DATE>'+glDate+'</GL_DATE>';
		    }
		    RECEIPTXml+='<RECEIPT_AMOUNT>'+rec.Amount__c+'</RECEIPT_AMOUNT>';
		    RECEIPTXml+='<CURRENCY_CODE>'+rec.Currency__c+'</CURRENCY_CODE>';
		    if(rec.Currency__c != ActiveCurrency){
				RECEIPTXml+='<EXCHANGE_RATE_TYPE>User</EXCHANGE_RATE_TYPE>';
				RECEIPTXml+='<EXCHANGE_RATE>'+rec.Exchange_rate__c+'</EXCHANGE_RATE>';
				RECEIPTXml+='<EXCHANGE_DATE>'+receiptDate+'</EXCHANGE_DATE>';
		    }
				
		    RECEIPTXml+='<TYPE_OF_PAYMENT>'+rec.Payment_Mode__c+'</TYPE_OF_PAYMENT>';
		    RECEIPTXml+='<COMMENTS>'+rec.Comments__c+'</COMMENTS>';
		    RECEIPTXml+='<BALANCE_AMOUNT>0.00</BALANCE_AMOUNT>';
		    RECEIPTXml+='<PAID_BY>'+rec.cm_Paid_By__c+'</PAID_BY>';
		    RECEIPTXml+='<INSTALLMENT_DETAIL>'+rec.Installment_Details__c+'</INSTALLMENT_DETAIL>';
		    RECEIPTXml+='</RECEIPT_DATA1>';
		    RECEIPTXml+='</RECEIPT>';
		    RECEIPTXml+='</XX_RECEIPT_DETAILS>';
		    RECEIPTXml+='</XX_RECEIPT_INFO>';
				
		    RECEIPTXml = RECEIPTXml.trim();

		    System.debug('@@ReceiptXML='+RECEIPTXml);
				
		    Blob cipherText2 = cm_AES_Encryptor.encrypt('AES128', blob.valueOf(iSettings.cm_AES_Key__c), blob.valueOf(RECEIPTXml));
		    String Param1 = RECEIPTXml; //EncodingUtil.convertToHex(cipherText2);
		    System.debug('>>>>>>>>>param1>>>>>>>>>>>>>>'+param1);
		    
		    user userRec = [Select id,cm_Oracle_Username__c, cm_Oracle_User_Id__c from User where Id =: UserInfo.getUserId()];
		    string oraUserName = userRec.cm_Oracle_Username__c != null? userRec.cm_Oracle_Username__c : iSettings.Default_Oracle_Username__c;
		    string oraUDID = userRec.cm_Oracle_User_Id__c != null ? userRec.cm_Oracle_User_Id__c :'';
		    
		    
		    String Param2 = '';
		    String Param3 = '';
		    String Param4 = '';
		    String Param5 = '';
		    String Param6 = '';
		    String Param7 = '';
		    String Param8 = '';
		    String Param9 = '';
		    
		    map<String,Mobile_Configurations__c> mpConfigSettings = Mobile_Configurations__c.getAll();
		    string genCampaignId = mpConfigSettings.get('Configuration').Tempo_Campaign_ID__c;
		    
		    
		    String Param10 = 'General Inventory'; 
		    String Param11 = '999999999';
		    String Param12 = '';
		    String Param13 = String.valueOf(OrgId);
		    String Param14 = genCampaignId;
		    String Param15 = customerAccountNumber;
		    String Param16 = oraUDID;
		    String Param17 = '0';
		    String Param18 = '';
		    String Param19 = OraUserName;
		    String Param20 = oraUDID;
		    
		    System.debug('>>>>>>>>>>param10>>>>>>>>>'+param10+'>>>>>>>>>>>param11>>>>>>>>'+param11+'>>>>>>>param12>>>>>>>>>>'+param12+'>>>>>>>>>param13>>>>>>>>>>>>>>'+param13+'>>>>>>param14>>>>>>>>'+param14+'>>>>>>>>>>>>>>>>>>>'+param15);
		    
		    objresponse =  stub.executePerformAction(UserName,UDID,Source,Action,AttachmentURL,Param1,Param2,Param3,Param4, Param5, Param6, Param7, Param8, Param9, Param10, Param11, Param12, Param13, Param14, Param15, Param16, Param17, Param18, Param19, Param20);
		    
		    system.debug('****objresponse'+objresponse.status);
		    system.debug('****objresponse'+objresponse.ErrorMessage);
		    system.debug('****objresponse'+objresponse.ResultXML);
		    
		    if(objresponse.status == 'SUCCESS'){		    
				rec.cm_keyToSend__c = Param10+'###'+param11+'###'+param12+'###'+param13+'###'+param14+'###'+param15+'###'+param16;
				//insert rec;
		    }
		    
		    Service_Logs__c objlog = CM_EmaarUtils.CreateLOg('Create Receipt',rec.Opportunity__c,'',objresponse.ErrorMessage,objresponse.status, objresponse.ResultXML,'','','','','','','','','');
		    objlog.Request__c = RECEIPTXml;
		    objlog.Reciepts__c = rec.id;
		    insert objlog;
				    
		    return objresponse;
		}
		catch(Exception e){
		    Service_Logs__c objlog = CM_EmaarUtils.CreateLOg('Create Receipt',rec.Opportunity__c,'','','','','','','','','','','','','');
		    objLog.Error_Message__c = e.getMessage()+'- Line Number :'+e.getLineNumber();
		    objlog.Log_Type__c = 'ERROR';
		    objlog.Request__c = RECEIPTXml;
		    objlog.Reciepts__c = rec.id;
		    insert objlog;
		}
		return null;
    }

}