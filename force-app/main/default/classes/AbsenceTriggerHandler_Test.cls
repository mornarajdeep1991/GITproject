/***********************************************************************************************
* Name              : AbsenceTriggerHandler_Test                                                 
* Description       : Test class for AbsenceTriggerHandler                                             
* Created Date      : 18/12/2018                                                    
* Created By        : Adeel Ahmad (adeel.ahmad@were4c.com)    
* Jira/Req By       :                                                                                                                                         
* ----------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
************************************************************************************************/
@isTest
public with sharing class AbsenceTriggerHandler_Test {
    public static testmethod void TestInsert(){
        EGY_Sales_Office__c sOffice = new EGY_Sales_Office__c();
        sOffice.EGY_Sales_Office_Name__c = 'Egypt Office';
        insert sOffice;
        
        Assignment_Groups__c ag = new Assignment_Groups__c();
        ag.Active__c = 'True';
        ag.User__c = UserInfo.getUserId();
        ag.EGY_Sales_Office__c = sOffice.Id;
        insert ag;
            
        EGY_Absence__c abs = new EGY_Absence__c();
        abs.EGY_User__c = UserInfo.getUserId();
        abs.EGY_Absence_Start__c = Date.today().addDays(-3);
        abs.EGY_Absence_End__c = Date.today().addDays(3);        
		insert abs;
    }

    public static testmethod void TestUpdate(){
        EGY_Absence__c abs = new EGY_Absence__c();
        abs.EGY_User__c = UserInfo.getUserId();
        abs.EGY_Absence_Start__c = Date.today().addDays(-3);
        abs.EGY_Absence_End__c = Date.today().addDays(3);        
		insert abs;
        
        abs.EGY_Absence_End__c = Date.today().addDays(-2);
        update abs;
    }

    public static testmethod void TestDelete(){
        EGY_Absence__c abs = new EGY_Absence__c();
        abs.EGY_User__c = UserInfo.getUserId();
        abs.EGY_Absence_Start__c = Date.today().addDays(-3);
        abs.EGY_Absence_End__c = Date.today().addDays(3);        
		insert abs;
        
        Delete [SELECT id FROM EGY_Absence__c WHERE Id=:abs.Id];
    }    
}