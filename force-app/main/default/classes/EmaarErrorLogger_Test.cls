@isTest
public with sharing class EmaarErrorLogger_Test {
    
    @isTest
    public static void myTest(){
      list<Service_Logs__c> lstLogs = new list<Service_Logs__c>();
      try{
        integer i=1/0;
      }catch(Exception ex){
        lstLogs = EmaarErrorLogger.prepareExceptionLog(lstLogs, 'Test Class', 'EmaarErrorLoggerTest', 'myTest','Test Class Code Ocerage', ex);  
      }
      
      try{
        insert new Contact();
      }catch(DMLException ex){
        lstLogs = EmaarErrorLogger.prepareExceptionLog(lstLogs, 'Test Class', 'EmaarErrorLoggerTest', 'myTest','Test Class Code Ocerage', ex);  
      }
      
      try{
        throw new CustomException('CustomException : Test Class Code Coverage');
      }catch(CustomException ex){
        lstLogs = EmaarErrorLogger.prepareExceptionLog(lstLogs, 'Test Class', 'EmaarErrorLoggerTest', 'myTest','Test Class Code Ocerage', ex);  
      }
      
      lstLogs.add(EmaarErrorLogger.prepareDatabaseErrorLog(null, 'Test Class Coverage', 'EmaarErrorLoggerTest', 'myTest', 'Error Message','Error Message'));
      
      EmaarErrorLogger.UpsertLogs(lstLogs);
      
      EmaarErrorLogger.UpsertLogs(null);
    }
}