@isTest 
private class EG_LeadAssignmentComponentCtrl_Test {
    static testMethod void doTest() {
    
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
       
       List<User> lstUser = new List<User>();
       lstUser.add(oUser);
       
       EG_LeadAssignmentComponentCtrl oController= new EG_LeadAssignmentComponentCtrl();
       EG_LeadAssignmentComponentCtrl.getLeadAssignmentThreshold();
       EG_LeadAssignmentComponentCtrl.getSalesOffices();
       EG_LeadAssignmentComponentCtrl.getGroupMembers();
       EG_LeadAssignmentComponentCtrl.getupdatedGroupMem('Divya');
       //EG_LeadAssignmentComponentCtrl.updateLeadQuota('100');
       EG_LeadAssignmentComponentCtrl.deleteUserById(oGroup.Id);
       EG_LeadAssignmentComponentCtrl.saveGroupMembers(lstUser,'Divya');
       EG_LeadAssignmentComponentCtrl.fetchFieldOptions('regionOptions');
       EG_LeadAssignmentComponentCtrl.createRecord('Vijitha',100,'All Gulf');
       EG_LeadAssignmentComponentCtrl.fetchLookUpValues('last','User',lstUser);
    }
}