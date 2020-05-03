/*****************************************/
/**
*  @Who     Rajnish Kumar <rajnishkumar393@gmail.com>
*  @When    07/06/2018
*  @What    Test Class for : MultipleUnits_CreateSalesOrder
*/
/****************************************/
@istest
public class MultipleUnits_CreateSalesOrder_Test {
    static testmethod void testcase1(){
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        insert objLoc;
        
        Property_Inventory__c objProINV = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV.Instance__c = '123456';
        insert objProINV;
        
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonMailingCountry ='United Arab Emirates';
        objAccount.Salutation='HE';
        objAccount.cm_National_ID_Expiry_Date__pc=system.today();
        objAccount.cm_Date_of_Incorporation__c=system.today();
        objAccount.cm_Trade_License_Expiry_Date__c=system.today();
        objAccount.cm_Visa_Expiry_Date__pc=system.today();
        objAccount.cm_Passport_Issue_Date__pc=system.today();
        objAccount.cm_Birthdate__pc=system.today();
        objAccount.cm_Passport_Expiry_Date__pc=system.today();
        objAccount.cm_Visa_Expiry_Date__pc=system.today();
        //objAccount.cm_joint_owner__c=
        //own.cm_joint_owner__r.cm_Passport_Expiry_Date__pc
        insert objAccount;
        
        Campaign objCampaign = TestDataFactory.CreateCampaign();
            insert objCampaign;
    
    //User UserDetails = [Select accountid from user where accountid!=null limit 1 ]; 
        
    Opportunity objOppor1 = TestDataFactory.createOpportunity();
        objOppor1.AccountId = objAccount.id;
        objOppor1.CampaignID = objCampaign.id;        
        //objOppor1.cm_Agency_Name__c=objAccount.id;
        objOppor1.Referral__c=objAccount.id;
        //objOppor1.cm_Agency_Name__c = UserDetails.accountid;
        insert objOppor1;
        
        Opportunity objOP = TestDataFactory.createOpportunity();
            objOP.AccountId = objAccount.id;
            objOP.CampaignID = objCampaign.id;        
            //objOP.cm_Agency_Name__c=objAccount.id;
            objOP.Referral__c=objAccount.id;
            insert objOP;
        
        Opportunity_Property__c objOPp = new Opportunity_Property__c();
            objOPp.cm_Opportunity__c = objOppor1.Id;
            objOPp.cm_Property_Inventory__c = objProINV.id;
            objOPp.cm_Order_Status__c = 'Booked';
            objOPp.Is_Package_Unit__c = true;
            objOpp.Sales_Order__c = null;
            insert objOPp;
        
        Mobile_Configurations__c mc = new Mobile_Configurations__c();
            mc.name='Configuration';
            mc.Tempo_Campaign_ID__c = objCampaign.id;
            mc.cm_Sales_Admin_Username__c=UserInfo.getuserName();
            insert mc;
        
        Joint_Owner__c objJoint =  TestDataFactory.CreateJointOwner(objAccount.id,objOppor1.id);
            insert objJoint;
        Map<string,String> mpInvHeaders = new Map<string,String>();
        
        try{
            Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl());
            emaarServicesComCreatesrbpelprocessVTest.CalloutType = 'Payment Terms Creation';
            MultipleUnits_CreateSalesOrder.CreateParty_SalesOrder(string.valueOf(objOppor1.id), 'parentlogId', 'strOrderSource', 'strOrderEvent', mpInvHeaders);
                objOppor1.AccountId = null;
                update objOppor1;
            MultipleUnits_CreateSalesOrder.CreateParty_SalesOrder(string.valueOf(objOppor1.id), 'parentlogId', 'strOrderSource', 'strOrderEvent', mpInvHeaders);
        }catch(exception ex){}
    }
    /*
    static testmethod void testcase2(){
        Location__c objLoc = TestDataFactory.CreateLocation('U');
           insert objLoc;
        
        Property_Inventory__c objProINV = TestDataFactory.CreatePropertyInventory(objLoc.id);
            objProINV.Instance__c = '123456';
            insert objProINV;
        
        Account objAccount = TestDataFactory.createPAccount();
            objAccount.PersonMailingCountry ='United Arab Emirates';
            objAccount.Salutation='HH';
            objAccount.cm_National_ID_Expiry_Date__pc=system.today();
            objAccount.cm_Date_of_Incorporation__c=system.today();
            objAccount.cm_Trade_License_Expiry_Date__c=system.today();
            objAccount.cm_Visa_Expiry_Date__pc=system.today();
            objAccount.cm_Passport_Issue_Date__pc=system.today();
            objAccount.cm_Birthdate__pc=system.today();
            objAccount.cm_Passport_Expiry_Date__pc=system.today();
            objAccount.cm_Visa_Expiry_Date__pc=system.today();
            //objAccount.cm_joint_owner__c=
            //own.cm_joint_owner__r.cm_Passport_Expiry_Date__pc
            insert objAccount;
        
        Campaign objCampaign = TestDataFactory.CreateCampaign();
            insert objCampaign;
    
       //User UserDetails = [Select accountid from user where accountid!=null limit 1 ]; 
        
       Opportunity objOppor1 = TestDataFactory.createOpportunity();
          objOppor1.AccountId = objAccount.id;
          objOppor1.CampaignID = objCampaign.id;        
          //objOppor1.cm_Agency_Name__c=objAccount.id;
          //objOppor1.Referral__c=objAccount.id;
          //objOppor1.cm_Agency_Name__c = UserDetails.accountid;
          insert objOppor1;
        
        Opportunity objOP = TestDataFactory.createOpportunity();
            objOP.AccountId = objAccount.id;
            objOP.CampaignID = objCampaign.id;        
            //objOP.cm_Agency_Name__c=objAccount.id;
            //objOP.Referral__c=objAccount.id;
            insert objOP;
            
        //Joint_Owner__c objJoint =  TestDataFactory.CreateJointOwner(objAccount.id,objOppor1.id);
            //insert objJoint;
        Map<string,String> mpInvHeaders = new Map<string,String>();
        
        try{
            Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl());
            //emaarServicesComCreatesrbpelprocessVTest.CalloutType = 'Payment Terms Creation';
            
            MultipleUnits_CreateSalesOrder.CreateParty_SalesOrder(string.valueOf(objOppor1.id), 'parentlogId', 'strOrderSource', 'strOrderEvent', mpInvHeaders);
                objOppor1.AccountId = null;
                update objOppor1;
            MultipleUnits_CreateSalesOrder.CreateParty_SalesOrder(string.valueOf(objOppor1.id), 'parentlogId', 'strOrderSource', 'strOrderEvent', mpInvHeaders);
           
        }catch(exception ex){}
   }*/
    /*
        static testmethod void testcase3(){
            Location__c objLoc = TestDataFactory.CreateLocation('U');
                insert objLoc;
            
            Property_Inventory__c objProINV = TestDataFactory.CreatePropertyInventory(objLoc.id);
                objProINV.Instance__c = '123456';
                insert objProINV;
            
            Account objAccount = TestDataFactory.createPAccount();
                objAccount.PersonMailingCountry ='United Arab Emirates';
                objAccount.Salutation='HH';
                objAccount.cm_National_ID_Expiry_Date__pc=system.today();
                objAccount.cm_Date_of_Incorporation__c=system.today();
                objAccount.cm_Trade_License_Expiry_Date__c=system.today();
                objAccount.cm_Visa_Expiry_Date__pc=system.today();
                objAccount.cm_Passport_Issue_Date__pc=system.today();
                objAccount.cm_Birthdate__pc=system.today();
                objAccount.cm_Passport_Expiry_Date__pc=system.today();
                objAccount.cm_Visa_Expiry_Date__pc=system.today();
                //objAccount.cm_joint_owner__c=
                //own.cm_joint_owner__r.cm_Passport_Expiry_Date__pc
                insert objAccount;
            
            Campaign objCampaign = TestDataFactory.CreateCampaign();
                insert objCampaign;
        
            //User UserDetails = [Select accountid from user where accountid!=null limit 1 ]; 
            
            Opportunity objOppor1 = TestDataFactory.createOpportunity();
                objOppor1.AccountId = objAccount.id;
                objOppor1.CampaignID = objCampaign.id;        
                //objOppor1.cm_Agency_Name__c=objAccount.id;
                //objOppor1.Referral__c=objAccount.id;
                //objOppor1.cm_Agency_Name__c = UserDetails.accountid;
                insert objOppor1;
            
            Opportunity objOP = TestDataFactory.createOpportunity();
                objOP.AccountId = objAccount.id;
                objOP.CampaignID = objCampaign.id;        
                //objOP.cm_Agency_Name__c=objAccount.id;
                //objOP.Referral__c=objAccount.id;
                insert objOP;
                
            //Joint_Owner__c objJoint =  TestDataFactory.CreateJointOwner(objAccount.id,objOppor1.id);
                //insert objJoint;
            Map<string,String> mpInvHeaders = new Map<string,String>();
            
            
                Test.setMock(WebServiceMock.class, new emaarServicesComCreatesrbpelprocessVTest.WebServiceMockImpl());
                //emaarServicesComCreatesrbpelprocessVTest.CalloutType = 'Payment Terms Creation';
                
                MultipleUnits_CreateSalesOrder.CreateParty_SalesOrder(string.valueOf(objOppor1.id), 'parentlogId', 'strOrderSource', 'strOrderEvent', mpInvHeaders);
                objOppor1.AccountId = null;
                
                update objOppor1;
                
                MultipleUnits_CreateSalesOrder.CreateParty_SalesOrder(string.valueOf(objOppor1.id), 'parentlogId', 'strOrderSource', 'strOrderEvent', mpInvHeaders);
               
            }catch(exception ex){}
    
            }*/
}