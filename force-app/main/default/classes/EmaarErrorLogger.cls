/*
Created By 	: Ravindra Babu Nagaboina NSI/PwC
Description : This class will be used to log the Errors/Exceptions which will throw at run time
Modification History :
=============================================================================================================================================
V.No	Date			By					Description
=============================================================================================================================================

*/
global without sharing class EmaarErrorLogger {

	public static list<Service_Logs__c> prepareExceptionLog(list<Service_Logs__c> lstLogs, string processName, string className, string methodName,string msg, Exception ex){
		lstLogs = lstLogs != null ? lstLogs : new list<Service_Logs__c>();
		Service_Logs__c objLog = prepareLog(new Service_Logs__c(), ex.getCause()+'',ex.getLineNumber()+'', ex.getMessage(), ex.getStackTraceString(), ex.getTypeName(), processName, className, methodName,msg);
		lstLogs.add(objLog);
		return lstLogs;
	}

	public static list<Service_Logs__c> prepareExceptionLog(list<Service_Logs__c> lstLogs, string processName, string className, string methodName,string msg, DMLException ex){
		lstLogs = lstLogs != null ? lstLogs : new list<Service_Logs__c>();
		Service_Logs__c objLog = prepareLog(new Service_Logs__c(), ex.getCause()+'',ex.getLineNumber()+'', ex.getMessage(), ex.getStackTraceString(), ex.getTypeName(), processName, className, methodName,msg);
		lstLogs.add(objLog);
		return lstLogs;
	}
    
	public static list<Service_Logs__c> prepareExceptionLog(list<Service_Logs__c> lstLogs, string processName, string className, string methodName,string msg, CustomException ex){
		lstLogs = lstLogs != null ? lstLogs : new list<Service_Logs__c>();
		Service_Logs__c objLog = prepareLog(new Service_Logs__c(), ex.getCause()+'',ex.getLineNumber()+'', ex.getMessage(), ex.getStackTraceString(), ex.getTypeName(), processName, className, methodName,msg);
		lstLogs.add(objLog);
		return lstLogs;
	}

	public static Service_Logs__c prepareLog(Service_Logs__c objLog, string cause, string lineNumber, string exMessage, string stackTraceString, string typeName, string processName, string className, string methodName,string msg){
		objLog = objLog != null ? objLog : new Service_Logs__c();
		objLog.Process_Name__c = processName;
		objLog.Log_Type__c = 'ERROR';
		objLog.Error_Class_Method_Name__c = className+' - '+methodName;
		objLog.Error_Message__c = exMessage+'\n'+msg+'\nCause - '+cause+'\nStackTraceString - '+stackTraceString+'\nException Type '+typeName;
		objLog.Log_External_Id__c = system.today().format()+'-'+objLog.Error_Class_Method_Name__c+'- Line#-'+lineNumber;
		return objLog;
	}
	
	public static Service_Logs__c prepareDatabaseErrorLog(Service_Logs__c objLog, string processName, string className, string methodName, string exMessage,string msg){
		objLog = objLog != null ? objLog : new Service_Logs__c();
		objLog.Process_Name__c = processName;
		objLog.Log_Type__c = 'ERROR';
		objLog.Error_Class_Method_Name__c = className+' - '+methodName;
		objLog.Error_Message__c = exMessage+'\n'+msg;
		objLog.Log_External_Id__c = system.today().format()+'-'+objLog.Error_Class_Method_Name__c+'- Process -'+processName;
		return objLog;
	} 
	
	public static string UpsertLogs(list<Service_Logs__c> lstLogs){
		if(lstLogs != null && !lstLogs.isEmpty()){
			map<string,Service_Logs__c> mapLogs = new map<string,Service_Logs__c>();
			Datetime dt = system.now();
			Integer i = 0;
			for(Service_Logs__c objLog : lstLogs){
				objLog.Log_External_Id__c = objLog.Log_External_Id__c != null ? objLog.Log_External_Id__c : (dt.format()+'-'+i);
				mapLogs.put(objLog.Log_External_Id__c,objLog);
				i++;
			}
			upsert mapLogs.values() Log_External_Id__c;
			return 'Logs has been updated in the system';
		}else
			return 'No Logs to Update';
	}
	
}