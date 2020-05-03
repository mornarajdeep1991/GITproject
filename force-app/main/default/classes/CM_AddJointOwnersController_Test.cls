@isTest
private class CM_AddJointOwnersController_Test {
    private static testMethod void test() {
        Test.startTest();
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonMailingCountry ='United Arab Emirates';
        insert objAccount;
        
        Campaign objCampaign = TestDataFactory.CreateCampaign();
        insert objCampaign;

        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount.id;
        objOppor.CampaignID = objCampaign.id;
        insert objOppor;
        
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        objLoc.Location_Code__c = '14567';
        insert objLoc;
        
        Property_Inventory__c objProINV = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV.Instance__c = '123456';
        insert objProINV;
        
        Opportunity_Property__c objOP = new Opportunity_Property__c();
        objOP.cm_Opportunity__c = objOppor.Id;
        objOP.cm_Property_Inventory__c = objProINV.Id;
        objOP.Sales_Order__c = '1234567';
        //insert objOP;
        
         Opportunity objOppor1 = TestDataFactory.createOpportunity();
        objOppor1.AccountId = objAccount.id;
        objOppor1.CampaignID = objCampaign.id;
        insert objOppor1;
        
        Joint_Owner__c objJoint =  TestDataFactory.CreateJointOwner(objAccount.id,objOppor.id);
        Joint_Owner__c objJoint1 =  TestDataFactory.CreateJointOwner(objAccount.id,objOppor1.id);
        
        ApexPages.StandardController sc ;
        apexpages.currentPage().getParameters().put('Id',objOppor.id);
        Joint_Owner__c jow = new Joint_Owner__c (cm_Related_Opportunity__c=objOppor.id);
        insert jow;
        
        ApexPages.currentPage().getHeaders().put('iPhone','User-Agent'); 
        ApexPages.currentPage().getHeaders().put('User-Agent','test'); 
        
        Apexpages.currentPage().getParameters().put('Id',objOppor.Id);
        
        CM_AddJointOwnersController obj = new CM_AddJointOwnersController(SC);
        obj.opp = objOppor;
        obj.con = null;//new ApexPages.StandardSetController(sc);
        obj.PrepareData();
        obj.AddRow();
        obj.selIndex = 0;
        obj.removeRow();
        obj.saveRecords();
        obj.saveRecords_SF1();
        obj.CheckAgent();
        
        insert objOP;
        
        Account objAccountJO = TestDataFactory.createPAccount();
        objAccountJO.PersonMailingCountry ='United Arab Emirates';
        insert objAccountJO;
        
        obj = new CM_AddJointOwnersController(SC);
    obj.AddRow();
        obj.lstWrap[obj.lstWrap.size()-1].jOwn.cm_Joint_Owner__c = objAccountJO.Id;
        try{
          obj.saveRecords();
        }catch(Exception ex){}
        test.stopTest();
    }
    static testmethod void testcase2(){
        ApexPages.StandardController sc ;
                
        CM_AddJointOwnersController obj2 = new CM_AddJointOwnersController(SC);
        ApexPages.currentPage().getHeaders().put('User-Agent','iPhone');
        obj2.CheckAgent();
        
        
        //obj2.strOpporId='';
        obj2.PrepareData();
    }
}