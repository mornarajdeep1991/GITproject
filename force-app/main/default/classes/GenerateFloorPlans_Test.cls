@IsTest
public class GenerateFloorPlans_Test {

     public static testMethod void coverMethods()
    {
      Account objAccount = new Account();
      objAccount.Name = 'Test Account';
     // objAccount.RecordTypeId = RecordTypeId;
      objAccount.BillingCity = 'Dubai';
      objAccount.BillingCountry = 'United Arab Emirates';
      objAccount.BillingStreet = 'Down Town Area';
      objAccount.cm_Date_of_Incorporation__c = system.today().addYears(-1);
      objAccount.cm_Trade_License_Expiry_Date__c = system.today().addYears(2);
      objAccount.Shipping_Mobile_Number__c = '521234567';
      objAccount.Shipping_Mobile_Country_Code__c = 'India: 0091';
      objAccount.VAT_Registration_No__c = '98765456';
      insert objAccount;
      Campaign objCampaign = TestDataFactory.CreateCampaign();
      insert objCampaign; 
      
      Opportunity objOppor = TestDataFactory.createOpportunity();
      objOppor.AccountId = objAccount.id;
      objOppor.CampaignID = objCampaign.id;
      objOppor.cm_Sales_Person__c = Userinfo.getUserId();   
      objOppor.cm_Agency_Name__c = objAccount.id;
      insert objOppor;
    
      Test.startTest();
      ApexPages.StandardController sc = new ApexPages.StandardController(objOppor);
      GenerateFloorPlans GenerateFloorPlansObj=new GenerateFloorPlans(sc);
      GenerateFloorPlansObj.oppId=objOppor.id; 
      GenerateFloorPlans.CreateDOC(GenerateFloorPlansObj.oppId);
      Test.stopTest();
    }
    
    public static testMethod void coverMethods1()
    { 
          Account objAccount = new Account();
      objAccount.Name = 'Test Account';
     // objAccount.RecordTypeId = RecordTypeId;
      objAccount.BillingCity = 'Dubai';
      objAccount.BillingCountry = 'United Arab Emirates';
      objAccount.BillingStreet = 'Down Town Area';
      objAccount.cm_Date_of_Incorporation__c = system.today().addYears(-1);
      objAccount.cm_Trade_License_Expiry_Date__c = system.today().addYears(2);
      objAccount.Shipping_Mobile_Number__c = '521234567';
      objAccount.Shipping_Mobile_Country_Code__c = 'India: 0091';
      objAccount.VAT_Registration_No__c = '98765456';
      insert objAccount;
      Campaign objCampaign = TestDataFactory.CreateCampaign();
      insert objCampaign; 
      
      Opportunity objOppor = TestDataFactory.createOpportunity();
      objOppor.AccountId = objAccount.id;
      objOppor.CampaignID = objCampaign.id;
      objOppor.cm_Sales_Person__c = Userinfo.getUserId();   
      objOppor.cm_Agency_Name__c = objAccount.id;
      insert objOppor;
        
        Property_Inventory__c objProperty_Inventory = new Property_Inventory__c();
        objProperty_Inventory.Active_End_Date_Time__c = system.today().addDays(30);
        objProperty_Inventory.Active_Start_Date_Time__c = system.today();
        objProperty_Inventory.Address__c = 'Dubai';
        objProperty_Inventory.Bath_Rooms__c = '2';
        objProperty_Inventory.Building__c = 'Emaar';
        objProperty_Inventory.Building_Code__c = '1234';
        objProperty_Inventory.City__c = 'Dubai';
       // objProperty_Inventory.Location_ID__c = objLocation.id;
        objProperty_Inventory.Sales_Rooms__c = '2 BedRooms';
        objProperty_Inventory.Type__c = 'Villa';
        objProperty_Inventory.Unit_Model__c = 'Type 2E';
        objProperty_Inventory.Property_Status__c = 'Available';
        objProperty_Inventory.selling_price__c = 2000000; 
        insert objProperty_Inventory;
        
        Opportunity_Property__c objOpportunity_Property = new Opportunity_Property__c();
        objOpportunity_Property.cm_Opportunity__c = objOppor.id;
        objOpportunity_Property.cm_Property_Inventory__c = objProperty_Inventory.id;
        insert objOpportunity_Property;    
      
     Test.startTest();
        try{
     GenerateFloorPlans.CreateDOC('test');
     GenerateFloorPlans.CreateDOC(objOppor.id);
       
      
        }
        catch(exception ex){
     GenerateFloorPlans.CreateDOC(objOppor.id);

     system.assertEquals(ex.getMessage(),'false');
        }
     Test.stopTest();
    }
    
}