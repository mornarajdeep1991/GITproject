/***********************************************************************************************
* Name              : TestUtil                                                 
* Description       : Utility Class for Test Classes                                            
* Created Date      : 17/04/2018                                                    
* Created By        : Divya Chary (divya.chary@were4c.com)    
* Jira/Req By       :                                                                                                                                         
* ----------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
* 1.0       Divya       17/04/2018  Created                              
************************************************************************************************/
@isTest
public class TestUtil {
    /************************************************************************************
    Method  :         createPersonAccount Method
    Description :     Method to create a person account
    Version :         1.0
    ************************************************************************************/
    public static Account createPersonAccount(Boolean doInsert, String recordTypeName){
        Account acc = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeName).getRecordtypeId(),
            FirstName = 'First',
            LastName = 'Last',
            PersonMailingStreet = 'Street',
            PersonMailingPostalCode = 'PostCode',
            PersonMailingCity = 'City',
            PersonEmail = 'test@test.com',
            PersonHomePhone = '07777777777',
            PersonMobilePhone = '07777777777'
        );
        if(doInsert) insert acc;
        return acc;
    }
    
    /************************************************************************************
    Method  :         createAccount Method
    Description :     Method to create a Business account
    Version :         1.0
    ************************************************************************************/
    public static Account createAccount(Boolean doInsert, String recordTypeName){
        Account acc = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeName).getRecordtypeId(),
            Name = 'Name'
        );
        
        if(doInsert) insert acc;
        
        return acc;
    }
    
    /************************************************************************************
    Method  :         createContact Method
    Description :     Method to create a Contact
    Version :         1.0
    ************************************************************************************/
    public static Contact createContact(Boolean doInsert, Id accountId){
        Contact con = new Contact(           
            FirstName = 'Name',
            LastName = 'Name',
            Email = 'test@test.com',
            AccountId = accountId
        );
        if(doInsert) insert con;
        return con;
    }
    /************************************************************************************
    Method  :         createUser Method
    Description :     Method to create a User
    Version :         1.0
    ************************************************************************************/
    public static User createUser(Boolean doInsert){
        
        User u = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
             LastName = 'last',
             Email = 'puser000@emaar.com',
             Username = 'puser000@emaar.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US',
             Oracle_Org_Name__c = '127'
        );
        if(doInsert) insert u;
        return u;
    }
    /************************************************************************************
    Method  :         creatingUser Method
    Description :     Method to create a User for different profile
    Version :         1.0
    ************************************************************************************/
    public static User creatingUser(Boolean doInsert,String profilName){
    
    String profileNam = '%'+profilName+'%';
        
        User u = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name Like : profileNam limit 1].Id,
             LastName = 'last',
             Email = 'puser000@emaar.com',
             Username = 'puser000@emaar.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US'
             
        );
        if(doInsert) insert u;
        return u;
    }
    
}