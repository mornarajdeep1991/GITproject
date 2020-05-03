/***********************************************************************************************
* Name              : Batch_SwitchQueueMembers_Test                                                 
* Description       : Test class for Batch_SwitchQueueMembers                                             
* Created Date      : 17/04/2018                                                    
* Created By        : Divya Chary (divya.chary@were4c.com)    
* Jira/Req By       :                                                                                                                                         
* ----------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
* 1.0       Divya       17/04/2018  Created                              
************************************************************************************************/
@isTest
public class Batch_SwitchQueueMembers_Test{
static testMethod void deactivateQueueMemberMethod(){
       //Create Sales Office
       EGY_Sales_Office__c oSalesOffice= new EGY_Sales_Office__c();
       oSalesOffice.EGY_Sales_Office_Name__c='Divya';
       oSalesOffice.EGY_Department__c='Sales Office';
       oSalesOffice.EGY_Region__c='Egypt';
       insert oSalesOffice;
       
       //Insert a User
       User oUser = TestUtil.createUser(false);
       oUser.Assignment_Group_Active__c=True;
       insert oUser;
       
       //Insert a User
       User oUser1 = TestUtil.createUser(false);
       oUser1.Assignment_Group_Active__c=True;
       insert oUser1;
       
       //Insert a Group Member
       Assignment_Groups__c oGroup= new Assignment_Groups__c();
       oGroup.EGY_Sales_Office__c=oSalesOffice.Id;
       oGroup.User__c=oUser.Id;
       oGroup.Active__c='True';
       insert oGroup;
       
       //Insert a Group Member
       Assignment_Groups__c oGroup1= new Assignment_Groups__c();
       oGroup1.EGY_Sales_Office__c=oSalesOffice.Id;
       oGroup1.User__c=oUser1.Id;
       oGroup1.Active__c='False';
       insert oGroup1;
       
       //Insert an Absence
       EGY_Absence__c oAbs= new EGY_Absence__c();
       oAbs.EGY_User__c=oUser.Id;
       oAbs.EGY_Absence_Start__c=System.Today();
       oAbs.EGY_Absence_End__c=System.Today();
       insert oAbs;
       
       //Insert an Absence
       EGY_Absence__c oAbs2= new EGY_Absence__c();
       oAbs2.EGY_User__c=oUser1.Id;
       oAbs2.EGY_Absence_Start__c=System.Today()-1;
       oAbs2.EGY_Absence_End__c=System.Today()-1;
       insert oAbs2;
       
       Test.StartTest();
            Batch_SwitchQueueMembers switchQueueMembers= new Batch_SwitchQueueMembers();
            database.executebatch(switchQueueMembers,100);
        Test.stopTest(); 
   }
}