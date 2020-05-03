/************************************************************************************
* Name          : RestServiceToUpdatePropertyType                                                
* Description   : Rest service class to make property inventory type from block/unblock it also
                : convers the soap call to update the inventory type if it changes from salesforce                                             
* Created Date  : 20/05/2018                                                    
* Created By    : -
* Modified By   : Adeel Ahmad (4C)  
* Jira/Req By   :                                                                                                                                           
* -----------------------------------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
************************************************************************************/
@RestResource(urlMapping='/EmaarUpdatePropertyTypeWS/*')
global with sharing class RestServiceToUpdatePropertyType{
    @HttpPost
    global static ResponseHandler UpdatePropertyType(string propertyType, string inventoryId,string comments) {
        ResponseHandler obj = new ResponseHandler();
    
        
        Property_Inventory__c inv = [Select id,Location_ID__c, Property_Status__c from Property_Inventory__c where id =: inventoryId for update];
        system.debug('Property Status ' + inv.property_status__c);
        if (inv.Property_Status__c != 'Available' && propertyType == 'Blocked') {
            
            obj.Success = false;
            obj.status = 'fail';
            obj.message = inv.Property_Status__c == 'Blocked' ? 'This unit has already been blocked.' : 'This unit has already been booked.';
            return obj;
        }
        else if (inv.Property_Status__c != 'Blocked' && propertyType == 'Sale') {
            
            obj.Success = false;
            obj.status = 'fail';
            obj.message = 'This unit is not blocked. It cannot be unblocked.';
            return obj;
        }

        Map<String, cm_Integration_Settings__c> mpSettings = cm_Integration_Settings__c.getAll();
        cm_Integration_Settings__c iSettings= mpSettings.containsKey('ORACLE') ? mpSettings.get('ORACLE'): new cm_Integration_Settings__c();
    
        Map<String, User_Oracle_Settings__c> mpuserSettings = User_Oracle_Settings__c.getAll();
        User_Oracle_Settings__c iuserSettings= mpuserSettings.containsKey(UserInfo.getUserId()) ? mpuserSettings.get(UserInfo.getUserId()): new User_Oracle_Settings__c();
       
        string UserName = iuserSettings.cm_Oracle_Username__c != null? iuserSettings.cm_Oracle_Username__c : iSettings.Default_Oracle_Username__c;
        
        string PropertyXML='<XX_INVENTORY_BLOCK>';
        PropertyXML=PropertyXML+'<XX_INVENTORY_BLOCK_T>';
        
        map<String,Block_Reason_Codes__c> mpReasonCodes = Block_Reason_Codes__c.getAll();
        //string blockreasonCode =  mpReasonCodes.containsKey(blockreason) ? mpReasonCodes.get(blockreason).API_Value__c :blockreason;
        
        string blockReasonCode = '';
        
        if(propertyType!='Sale')
            blockReasonCode ='SF_MOB_BLOCK';
        
        string recordXML='';
        integer i =0; 
        
        
        RestRequest req = RestContext.request;
        Map<String, String> headers = req<>null ? req.headers : new map<string,string>();//v1.2
        
        inv.Property_Type__c = propertyType;
        if(inv.Property_Type__c == 'Sale') {
           inv.Property_Status__c = 'Available';
        }
        else if(inv.Property_Type__c == 'Blocked')
           inv.Property_Status__c = 'Blocked';
        else 
           inv.Property_Status__c = inv.Property_Status__c;
        
        string parameters = '';
        recordXML+='<XX_INVENTORY_BLOCK_O>';
        recordXML+='<USER_NAME>'+UserName+'</USER_NAME>';
        recordXML+='<SOURCE>SALESFORCE</SOURCE>';
        recordXML+='<LOCATION_ID>'+inv.Location_ID__c+'</LOCATION_ID>';
        recordXML+='<PRICE></PRICE>';
        recordXML+='<PROPERTY_TYPE>'+inv.Property_Type__c+'</PROPERTY_TYPE>';
        recordXML+='<PROPERTY_STATUS>'+inv.Property_Status__c+'</PROPERTY_STATUS>';
        recordXML+='<BLOCK_REASON_CODE>'+blockreasonCode+'</BLOCK_REASON_CODE>';
        recordXML+='<BLOCKED_REASON_REMARKS>'+comments+'</BLOCKED_REASON_REMARKS>';
        recordXML+='</XX_INVENTORY_BLOCK_O>';
        
        if(inv.Property_Status__c == 'Blocked'){
            inv.Blocked_Type__c = 'Sale';
            inv.Block_Reason__c = 'Blocked for SalesForce Mobile App';
            inv.Blocked_reason_code__c = blockreasonCode;
            inv.Block_Remarks__c = comments;
            inv.cm_Blocked_By__c = UserInfo.getUserId();
        }
        
        if(inv.Property_Type__c == 'Sale' && inv.Property_Status__c=='Available'){
            inv.Blocked_Type__c = '';
            inv.Block_Reason__c = '';
            inv.Block_Remarks__c = '';
            inv.Blocked_reason_code__c ='';
            inv.cm_Blocked_By__c = null;
        }  
        
        
        PropertyXML=PropertyXML+recordXML.trim();
        PropertyXML=PropertyXML+'</XX_INVENTORY_BLOCK_T>';
        PropertyXML=PropertyXML+'</XX_INVENTORY_BLOCK>';
        PropertyXML = PropertyXML.replaceAll('null','');
        PropertyXML = PropertyXML.trim();
        System.debug('>>>>>>>propertyXML>>>>>>>>>>>>'+propertyXML+'>>>>>>>index>>>>>>>>>'+i);
        
        
        parameters = 'Location Id:'+ inv.Location_ID__c+'/n'+'Status:'+inv.Property_Status__c+'/n';
        parameters += 'Reason Code:'+blockreasonCode+'/n'+'Remarks:'+inv.Block_Remarks__c;
        
        
        try{
        
            if(inv.Property_Type__c == 'Sale') {
            
                Boolean success = push2Oracle(propertyType, inventoryId, comments);
                
                if (success) {
                    obj.Success = true;
                    obj.status = 'success';
                    obj.message = 'Inventory Unblocked successfully';
                    RestServiceLogger.insertLog('Property Unblock', headers, null, null, inv.Id);
                    update inv;
                }
                else {
                    obj.Success = false;
                    obj.status = 'Error';
                    obj.message = 'Error blocking inventory in Oracle.';
                }
            }
            else if(inv.Property_Type__c == 'Blocked') {
                update inv;
                push2OracleAsync(propertyType, inventoryId, comments);
                obj.Success = true;
                obj.status = 'success';
                obj.message = 'Inventory blocked successfully';
                RestServiceLogger.insertLog('Property Block', headers, null, null, inv.Id);
            }
            else {
                obj.Success = true;
                obj.status = 'success';
                obj.message = 'Status Successfully updated';
            }
        }
        catch(Exception e){
            obj.Success = false;
            obj.status = 'fail';
            obj.message = e.getMessage();
        }
        
     
        
      
        return obj;
   }
   global class ResponseHandler {
        public Boolean Success {get; set;}
        public String Status {get; set;}
        public String Message {get;set;}
    }
    
    
     public static Map<string,string> parseXML(string responseXML, list<Property_Inventory__c> lstInv,string parameters){
         System.debug('>>>>>>>responseXML>>>>>>>>>'+responseXML);
        DOM.Document xmlDOC = new DOM.Document();
        xmlDOC.load(responseXML);
        DOM.XMLNode rootElement = xmlDOC.getRootElement();
        
        
        Map<string,string> mpSuccess = new Map<string,string>();
        Map<string,string> mpErrors = new Map<String,string>();
        Map<string,string> mpWholeXML = new Map<String,string>();
        for(Dom.XMLNode child1: rootElement.getChildElements()){
            for(Dom.XMLNode child2: child1.getChildElements()){
                for(Dom.XMLNode child3: child2.getChildElements()){
                    System.debug('>>>>>>>>>>>'+child3.getName());
                    string locId = '';
                    string status = '';
                    string message = '';
                    if( child3.getChildElement('LOCATION_ID',null)!=null)
                        locId = child3.getChildElement('LOCATION_ID',null).getText();
                    if( child3.getChildElement('STATUS',null)!=null)
                    	status = child3.getChildElement('STATUS',null).getText();
                    if( child3.getChildElement('MESSAGE',null)!=null)
                    	message = child3.getChildElement('MESSAGE',null).getText();
                    
                    if(status == 'ERROR'){
                        mpErrors.put(locId,message);
                    }
                    else{
                        mpSuccess.put(locId,message);  
                    }
                    
                    string msgVal = 'Location ID:'+locId+'Status:'+status+'Message:'+message;
                    mpWholeXML.put(locId,msgVal);
                }
            }
        }
        
        System.debug('>>>>>>>mpSuccess>>>>>>>>'+mpSuccess.keyset());
        if(!mpSuccess.isempty()){
            List<Property_Inventory__c> lst2Update = new list<Property_Inventory__c>();
            List<Service_Logs__c> lstLogs = new list<Service_Logs__c>();
            for(Property_Inventory__c inv: lstInv){
                if(mpSuccess.containsKey(inv.Location_ID__c)){
                    lst2Update.add(inv);                    
                    
                    Service_Logs__c objlog = new Service_Logs__c(); 
                    objlog.Request__c = parameters;
                    objlog.Response__c = mpWholeXML.get(inv.Location_ID__c);
                    objlog.Process_Time__c = system.now();
                    objlog.Process_Name__c = 'Mobile - Bulk Inventory - Update';
                    objlog.Log_Type__c = 'SUCCESS';
                    objlog.Error_Message__c = mpSuccess.get(inv.Location_ID__c);
                    objLog.Property_Inventory__c = inv.Id;
                    lstLogs.add(objLog);
                }
                
                if(mpErrors.containsKey(inv.Location_ID__c)){
                    Service_Logs__c objlog = new Service_Logs__c(); 
                    objlog.Request__c = parameters;
                    objlog.Response__c = mpWholeXML.get(inv.Location_ID__c);
                    objlog.Process_Time__c = system.now();
                    objlog.Process_Name__c = 'Mobile - Bulk Inventory - Update';
                    objlog.Log_Type__c = 'ERROR';
                    objlog.Error_Message__c = mpErrors.get(inv.Location_ID__c);
                    objLog.Property_Inventory__c = inv.Id;
                    lstLogs.add(objLog);
                }
            }
            System.debug('>>>>>>>>>lst2Update>>>>>>>>>>'+lst2Update);
            System.debug('>>>>>>>>>lstLogs>>>>>>>>>>'+lstLogs);
            if(!lst2Update.isEmpty())
                update lst2Update;
            
            if(!lstLogs.isEmpty())
                insert lstLogs;
                
            System.debug('>>>>>>>lstlogs after>>>>>>>>'+lstlogs);
        }
        return mpErrors;
    }
    
    
    public static ResponseHandler updateInventoryStatus(string propertyType, string inventoryId,string comments){
        
        ResponseHandler obj = new ResponseHandler();
        
        obj = changeInventoryStatus(propertyType, inventoryId, comments);
        
        
        return obj;
    }
    
    
    public static ResponseHandler changeInventoryStatus(string propertyType, string inventoryId,string comments){
        ResponseHandler obj = new ResponseHandler();
        Property_Inventory__c inv = [Select id,Location_ID__c, Property_Status__c from Property_Inventory__c where id =: inventoryId for update];
        system.debug('Property Status ' + inv.property_status__c);
        if (inv.Property_Status__c != 'Available' && propertyType == 'Blocked') {
            
            obj.Success = false;
            obj.status = 'fail';
            obj.message = inv.Property_Status__c == 'Blocked' ? 'This unit has already been blocked.' : 'This unit has already been booked.';
            return obj;
        }
        else if (inv.Property_Status__c != 'Blocked' && propertyType == 'Sale') {
            
            obj.Success = false;
            obj.status = 'fail';
            obj.message = 'This unit is not blocked. It cannot be unblocked.';
            return obj;
        }
        else{
        
            inv.Property_Type__c = propertyType;
            if(inv.Property_Type__c == 'Sale')
               inv.Property_Status__c = 'Available';
            else if(inv.Property_Type__c == 'Blocked')
               inv.Property_Status__c = 'Blocked';
            else 
               inv.Property_Status__c = inv.Property_Status__c;
               
               
            if(inv.Property_Status__c == 'Blocked'){
                inv.Blocked_Type__c = 'Sale';
                inv.Block_Reason__c = 'Blocked for SalesForce Mobile App';
                inv.Blocked_reason_code__c = 'SF_MOB_BLOCK';
                inv.Block_Remarks__c = comments;
                inv.cm_Blocked_By__c = UserInfo.getUserId();
            }
            
            if(inv.Property_Type__c == 'Sale' && inv.Property_Status__c=='Available'){
                inv.Blocked_Type__c = '';
                inv.Block_Reason__c = '';
                inv.Block_Remarks__c = '';
                inv.Blocked_reason_code__c ='';
                inv.cm_Blocked_By__c = null;
            }
            
            update inv;     
        }
        
        return obj;
    }
    
    @future(callout=true)
    public static void push2OracleAsync(string propertyType, string inventoryId,string comments) {
    
       RestServiceToUpdatePropertyType.push2Oracle(propertyType, inventoryId, comments); 
    }
    
    public static boolean push2Oracle(string propertyType, string inventoryId,string comments){
    
        ResponseHandler obj = new ResponseHandler();
        
        Property_Inventory__c inv = [Select id,Location_ID__c, Property_Status__c, Property_Type__c, Block_Remarks__c from Property_Inventory__c where id =: inventoryId for update];
        system.debug('Property Status ' + inv.property_status__c);
        
        inv.Property_Type__c = propertyType;
        if(inv.Property_Type__c == 'Sale')
           inv.Property_Status__c = 'Available';
        else if(inv.Property_Type__c == 'Blocked')
           inv.Property_Status__c = 'Blocked';
        else 
           inv.Property_Status__c = inv.Property_Status__c;
           
           
        if(inv.Property_Status__c == 'Blocked'){
            inv.Blocked_Type__c = 'Sale';
            inv.Block_Reason__c = 'Blocked for SalesForce Mobile App';
            inv.Blocked_reason_code__c = 'SF_MOB_BLOCK';
            inv.Block_Remarks__c = comments;
            inv.cm_Blocked_By__c = UserInfo.getUserId();
        }
        
        if(inv.Property_Type__c == 'Sale' && inv.Property_Status__c=='Available'){
            inv.Blocked_Type__c = '';
            inv.Block_Reason__c = '';
            inv.Block_Remarks__c = '';
            inv.Blocked_reason_code__c ='';
            inv.cm_Blocked_By__c = null;
        }
            
        string PropertyXML='<XX_INVENTORY_BLOCK>';
        PropertyXML=PropertyXML+'<XX_INVENTORY_BLOCK_T>';

        Map<String, cm_Integration_Settings__c> mpSettings = cm_Integration_Settings__c.getAll();
        cm_Integration_Settings__c iSettings= mpSettings.containsKey('ORACLE') ? mpSettings.get('ORACLE'): new cm_Integration_Settings__c();
    
        Map<String, User_Oracle_Settings__c> mpuserSettings = User_Oracle_Settings__c.getAll();
        User_Oracle_Settings__c iuserSettings= mpuserSettings.containsKey(UserInfo.getUserId()) ? mpuserSettings.get(UserInfo.getUserId()): new User_Oracle_Settings__c();
       
        string UserName = iuserSettings.cm_Oracle_Username__c != null? iuserSettings.cm_Oracle_Username__c : iSettings.Default_Oracle_Username__c;
        

        string blockreasoncode='';
        if(PropertyType != 'Sale')
            blockreasonCode = 'SF_MOB_BLOCK';
        
        string recordXML, parameters='';
        recordXML+='<XX_INVENTORY_BLOCK_O>';
        recordXML+='<USER_NAME>'+UserName+'</USER_NAME>';
        recordXML+='<SOURCE>SALESFORCE</SOURCE>';
        recordXML+='<LOCATION_ID>'+inv.Location_ID__c+'</LOCATION_ID>';
        recordXML+='<PRICE></PRICE>';
        recordXML+='<PROPERTY_TYPE>'+inv.Property_Type__c+'</PROPERTY_TYPE>';
        recordXML+='<PROPERTY_STATUS>'+inv.Property_Status__c+'</PROPERTY_STATUS>';
        recordXML+='<BLOCK_REASON_CODE>'+blockreasonCode+'</BLOCK_REASON_CODE>';
        recordXML+='<BLOCKED_REASON_REMARKS>'+comments+'</BLOCKED_REASON_REMARKS>';
        recordXML+='</XX_INVENTORY_BLOCK_O>';
        
        PropertyXML=PropertyXML+recordXML.trim();
        PropertyXML=PropertyXML+'</XX_INVENTORY_BLOCK_T>';
        PropertyXML=PropertyXML+'</XX_INVENTORY_BLOCK>';
        PropertyXML = PropertyXML.replaceAll('null','');
        PropertyXML = PropertyXML.trim();
        
        
        parameters = 'Location Id:'+ inv.Location_ID__c+'/n'+'Status:'+inv.Property_Status__c+'/n';
        parameters += 'Reason Code:'+blockreasonCode+'/n'+'Remarks:'+inv.Block_Remarks__c;
        
               
        emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element eleRes = EmaarWebServiceUtils.UpdatePropertyBulk(PropertyXML);
        System.debug('>>>>>>>>>>>>>>>>>>'+eleRes);
        System.debug('>>>>>Result XML>>>>>>>>>>>>>'+eleRes.resultXML);
        
        
        
        if(eleRes.status=='SUCCESS'){
            Map<string,string> mpErrors = RestServiceToUpdatePropertyType.parseXML(eleRes.resultXML,new List<Property_Inventory__c>{inv},parameters);
            if (mpErrors != null) {
                for (String key : mpErrors.keySet()) {
                    return false;
                } 
                
                return true;
            }
            
            return true;
        }
        else
            return false;   
       
    }
}