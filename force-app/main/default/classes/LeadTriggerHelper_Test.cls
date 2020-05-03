/***********************************************************************************************
* Name              : LeadTriggerHelper_Test                                                 
* Description       : Test class for Round Robin Assignment Package installed                                           
* Created Date      : 17/04/2018                                                    
* Created By        : Divya Chary (divya.chary@were4c.com)    
* Jira/Req By       :                                                                                                                                         
* ----------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
* 1.0       Divya       17/04/2018  Created                              
************************************************************************************************/
@isTest
private class LeadTriggerHelper_Test {
/************************************************************************************
    Method  :         myTest1
    Description :     Round Robin Assignment of leads
    Version :         1.0
    ************************************************************************************/
    static testMethod void myTest1() {
        // This code runs as the system user
        User u1;
        try{
            u1 = [select Id from User WHERE IsActive=True AND Profile.Name = 'System Administrator'  LIMIT 1];
        } catch (QueryException qe){
            
            List<User> users = [SELECT Id, Profile.PermissionsModifyAllData FROM User WHERE IsActive = true LIMIT 1000];
            
            for(User u : users){
                if(u.Profile.PermissionsModifyAllData = true){
                    u1 = u;
                    break;
                }
            }
        }
        System.debug(u1);
        //*****Create Queue 
        Group testGroup = new Group ();
        testGroup.Name = 'TestQueue';
        testGroup.Type = 'Queue';
        insert testGroup;
        
        QueueSObject testQueue = new QueueSObject();
        testQueue.QueueId = testGroup.id;
        testQueue.SObjectType = 'Lead';
        insert testQueue;
        
        // Second Queue       
        Group testGroup2 = new Group ();
        testGroup2.Name = 'TestQueue2';
        testGroup2.Type = 'Queue';
        insert testGroup2;
        
        QueueSObject testQueue2 = new QueueSObject();
        testQueue2.QueueId = testGroup2.id;
        testQueue2.SObjectType = 'Lead';
        insert testQueue2;
        
        
        test.starttest();
        
        //Run test
        System.runAs(u1){
            //Assign Case with out any Assignment Groups
            Lead c1 = new Lead (LastName='Test',Company='Test',Email='abc@xyz.com', EGY_TempOwnerId__c =testGroup2.id, OwnerID=u1.id); //tempOwnerID__c=testGroup2.id,  
            insert c1;
            update c1;
            
            
            //Create Assignment Group
            Assignment_Group_Name__c ag1 = new Assignment_Group_Name__c (Name='TestAG', Type__c = 'Lead');
            insert ag1;
            
            
            //Add bad queue name
            Assignment_Group_Queues__c agqBad = new Assignment_Group_Queues__c(name='Bad Queue',Assignment_Group_Name__c = ag1.id );
            
            try {
                insert agqBad; 
            } catch (DmlException e){
                System.assert(e.getMessage().contains('CUSTOM_VALIDATION_EXCEPTION'), e.getMessage()); 
                
            } //catch
        }
        test.stoptest();
        
    }
    /************************************************************************************
    Method  :         myTest2
    Description :     Round Robin Assignment of leads
    Version :         1.0
    ************************************************************************************/
    static testMethod void myTest2() {
        
        // This code runs as the system user
        
        User u1;
        
        try{
            u1 = [select Id from User WHERE IsActive=True AND Profile.Name = 'System Administrator'  LIMIT 1];
        } catch (QueryException qe){
            
            List<User> users = [SELECT Id, Profile.PermissionsModifyAllData FROM User WHERE IsActive = true LIMIT 1000];
            
            for(User u : users){
                if(u.Profile.PermissionsModifyAllData = true){
                    u1 = u;
                    break;
                }
            }
            
        }
        
        System.debug(u1);
        
        //*****Create Queue 
        
        Group testGroup = new Group ();
        testGroup.Name = 'TestQueue';
        testGroup.Type = 'Queue';
        insert testGroup;
        
        QueueSObject testQueue = new QueueSObject();
        testQueue.QueueId = testGroup.id;
        testQueue.SObjectType = 'Lead';
        insert testQueue;
        
        // Second Queue       
        Group testGroup2 = new Group ();
        testGroup2.Name = 'TestQueue2';
        testGroup2.Type = 'Queue';
        insert testGroup2;
        
        QueueSObject testQueue2 = new QueueSObject();
        testQueue2.QueueId = testGroup2.id;
        testQueue2.SObjectType = 'Lead';
        insert testQueue2;
        
        
        test.starttest();
        
        //Run test
        
        System.runAs(u1){
            //Create Sales Office
            EGY_Sales_Office__c oSalesOffice= new EGY_Sales_Office__c();
            oSalesOffice.EGY_Sales_Office_Name__c='Divya';
            oSalesOffice.EGY_Department__c='Sales Office';
            oSalesOffice.EGY_Region__c='Egypt';
            insert oSalesOffice;
            //Create Assignment Group
            Assignment_Group_Name__c ag1 = new Assignment_Group_Name__c (Name='TestAG', Type__c = 'Lead');
            insert ag1;        
            
            //Add Good Queue to Assignment Group
            Assignment_Group_Queues__c agq1 = new Assignment_Group_Queues__c(name=testGroup.Name ,Assignment_Group_Name__c = ag1.id );
            insert agq1;
            
            
            //Add User to Assignment Groups Users
            Assignment_Groups__c agu1 = new Assignment_Groups__c (User__c = u1.id,EGY_Sales_Office__c=oSalesOffice.Id, Active__c='True', Group_Name__c = ag1.id, Last_Assignment__c = datetime.valueOf('2009-01-01 21:13:24') );
            insert agu1;
            
            Lead c2 = new Lead (LastName='Test',Company='Test', EGY_TempOwnerId__c =testGroup2.id , OwnerID=testGroup.id); //Set owner ID to Queue
            insert c2;
            update c2;        
        }
        test.stoptest();
        
    }
    
    /************************************************************************************
    Method  :         myTest3
    Description :     Round Robin Assignment of leads
    Version :         1.0
    ************************************************************************************/
    static testMethod void myTest3() {
        // This code runs as the system user
        User u1;
        try{
            u1 = [select Id from User WHERE IsActive=True AND Profile.Name = 'System Administrator'  LIMIT 1];
        } catch (QueryException qe){
            List<User> users = [SELECT Id, Profile.PermissionsModifyAllData FROM User WHERE IsActive = true LIMIT 1000];
            for(User u : users){
                if(u.Profile.PermissionsModifyAllData = true){
                    u1 = u;
                    break;
                }
            }
        }
        test.starttest();
        //Create Sales Office
        EGY_Sales_Office__c oSalesOffice= new EGY_Sales_Office__c();
        oSalesOffice.EGY_Sales_Office_Name__c='Divya';
        oSalesOffice.EGY_Department__c='Sales Office';
        oSalesOffice.EGY_Region__c='Egypt';
        insert oSalesOffice;
        
        //Query Queue
        Group testGroup= [SELECT Id from GROUP WHERE Name=:'Divya' LIMIT 1];
        test.stoptest();
        //Run test        
        System.runAs(u1){ 
            //Create Assignment Group
            Assignment_Group_Name__c ag1 = new Assignment_Group_Name__c (Name='TestAG', Type__c = 'Lead');
            insert ag1;        
            
            //Add User to Assignment Groups Users
            Assignment_Groups__c agu1 = new Assignment_Groups__c (User__c = u1.id,EGY_Sales_Office__c=oSalesOffice.Id, Active__c='True', Group_Name__c = ag1.id, Last_Assignment__c = datetime.valueOf('2009-01-01 21:13:24') );
            insert agu1;      
            
            Lead c3 = new Lead (LastName='Test',Company='Test', OwnerID=u1.id); //Set owner ID to Queue
            insert c3;
            Lead oLead=[SELECT Id,OwnerId from Lead WHERE Id=: c3.id];
            oLead.OwnerId=testGroup.Id;
            update oLead;
        }
    }
    /************************************************************************************
    Method  :         myTest4
    Description :     Round Robin Assignment of leads
    Version :         1.0
    ************************************************************************************/
    static testMethod void myTest4() {
        
        // This code runs as the system user
        
        User u1;
        
        try{
            u1 = [select Id from User WHERE IsActive=True AND Profile.Name = 'System Administrator'  LIMIT 1];
        } catch (QueryException qe){
            
            List<User> users = [SELECT Id, Profile.PermissionsModifyAllData FROM User WHERE IsActive = true LIMIT 1000];
            
            for(User u : users){
                if(u.Profile.PermissionsModifyAllData = true){
                    u1 = u;
                    break;
                }
            }
            
        }
        
        System.debug(u1);
        
        //*****Create Queue 
        
        Group testGroup = new Group ();
        testGroup.Name = 'TestQueue';
        testGroup.Type = 'Queue';
        insert testGroup;
        
        QueueSObject testQueue = new QueueSObject();
        testQueue.QueueId = testGroup.id;
        testQueue.SObjectType = 'Lead';
        insert testQueue;
        
        
        test.starttest();
        
        //Run test
        System.runAs(u1){
            //Create Assignment Group
            Assignment_Group_Name__c ag1 = new Assignment_Group_Name__c (Name='TestAG', Type__c = 'Lead');
            insert ag1;        
            
            //Test for AG-Queues already assigned to another Assignment Group
            Assignment_Group_Queues__c agq2 = new Assignment_Group_Queues__c(name=testGroup.Name,Assignment_Group_Name__c = ag1.id );
            try {
                insert agq2;
            } catch (DmlException e){
                System.assert(e.getMessage().contains('CUSTOM_VALIDATION_EXCEPTION'), e.getMessage()); 
            } //catch
        }
        test.stoptest();
        
    }
}