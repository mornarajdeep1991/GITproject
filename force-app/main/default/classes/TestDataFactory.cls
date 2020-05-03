@isTest
public class TestDataFactory {
    public static Account createBAccount(){
        Account objAccount = new Account(Name='testprimary',Industry='Aerospace');
        return objAccount;
    }   
    static testmethod void testcase1(){
        
    }
    public static Account createPAccount(){
        
        Id RecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('EGY Person Account').getRecordTypeId();
        
        Account pAccount = new Account();
        pAccount.FirstName = 'SFDC';
        pAccount.LastName = 'Axel';
        pAccount.personBirthDate = Date.newInstance(1980,5,11);
        pAccount.personMailingStreet = '33 Lincoln Street';
        pAccount.personMailingCity = 'London';
        pAccount.personMailingPostalCode = 'E8 WH1';
        //pAccount.personMailingCountry = 'GB';
        pAccount.personEmail = 'axel@sales.com';
        pAccount.personHomePhone = '+44 (1234) 788145';
        pAccount.personMobilePhone = '+44 (1234) 963371';
        pAccount.PersonTitle ='Test';
        pAccount.cm_National_ID_No__pc='12345';
        pAccount.BillingStreet='Test 123'; 
        pAccount.recordTypeId = RecordTypeId;
        return pAccount;
    } 
    public static Contact createContact(){
        Contact c = new Contact(lastname='testing', firstname='apex',Email='Test@mail.com');
        return c;
    } 
     public static Payment_Terms__c createPaymentTerms(){ 
          Payment_Terms__c pt=new Payment_Terms__c();
          pt.Name='test';
          pt.Installment__c=123;
          pt.CurrencyIsoCode='EGP';
           return pt;
     } 
    Public static Opportunity CreateOpportunity(){
        Opportunity objOpportunity = new Opportunity(Name ='New mAWS Deal',
                            StageName = 'Customer Won',
                            Amount = 3000,
                            Type_of_Property_Interest__c='Store',
                            CloseDate = System.today());
         return objOpportunity;

    }
    public static Lead CreateLead(){
        Lead objLead = new Lead(Company = 'Test Lead',
                      LastName = 'Lead Last Name',LeadSource='WEB',Status='Contacted',MobilePhone='971563456678',AnnualRevenue=54000,Email='test@mail.com');
        return objLead;
    }
    public static Location__c CreateLocation(string type){
        Location__C objLocation = new Location__C();
        objLocation.Acc_Treatment_Code__c ='test';
        objLocation.Location_Code__c = 'LOC-123-456';
        objLocation.Building__c='Test Building';
        objLocation.Active_End_Date__c = system.today().addDays(20);
        objLocation.Active_Start_Date__c = system.today();
        objLocation.Address_Id__c ='123456789';
        objLocation.Assignable_Area__c = 1234;
        objLocation.Attribute_Category__c= type ;//'U';// U or B or F 
        return objLocation ;
    }
    
    public static Location__c CreateNewLocation(string type, string category, string code){
        Location__C objLocation = new Location__C();
        objLocation.Acc_Treatment_Code__c ='test';
        objLocation.Active_End_Date__c = system.today().addDays(20);
        objLocation.Active_Start_Date__c = system.today();
        objLocation.Address_Id__c ='123456789';
        objLocation.Assignable_Area__c = 1234;
        objLocation.Attribute_Category__c= type ;//'U';// U or B or F 
        objLocation.Location_ID__c = code;
        objLocation.em_Category__c = category;
        return objLocation ;
    }
    
    public static Property__c CreateProperty(string pName){
        Property__c property = new Property__c ();
        property.Active_Property__c = true;
        property.Property_Name__c = pName;
        return property;
    }    
    
    public static Property_Inventory__c CreatePropertyInventory(string locationId){
        Property_Inventory__c objProperty_Inventory = new Property_Inventory__c();
        objProperty_Inventory.Active_End_Date_Time__c = system.today().addDays(30);
        objProperty_Inventory.Active_Start_Date_Time__c = system.today();
        objProperty_Inventory.Address__c = 'Dubai';
        objProperty_Inventory.Bath_Rooms__c = '2';
        objProperty_Inventory.Building__c = 'Emaar';
        objProperty_Inventory.Building_Code__c = '1234';
        objProperty_Inventory.City__c = 'Dubai';
        objProperty_Inventory.Location_ID__c = locationId;
        objProperty_Inventory.Sales_Rooms__c = '2 BedRooms';
        objProperty_Inventory.Type__c = 'Villa';
        objProperty_Inventory.Unit_Model__c = 'Type 2E';
        objProperty_Inventory.Property_Status__c = 'Available';
        objProperty_Inventory.selling_price__c = 2000000;
        return objProperty_Inventory;
    }
    Public static Opportunity_Property__c CreateOpportunityProperty(string OpportunityId, String PropertyInvId){
        Opportunity_Property__c objOpportunity_Property = new Opportunity_Property__c();
        objOpportunity_Property.cm_Opportunity__c = OpportunityId;
        objOpportunity_Property.cm_Property_Inventory__c = PropertyInvId;
        return objOpportunity_Property;
    }
    public static Property_Inventory__c CreatePackage(){
        Property_Inventory__c objProperty_Inventory = new Property_Inventory__c();
        objProperty_Inventory.Active_End_Date_Time__c = system.today().addDays(30);
        objProperty_Inventory.Active_Start_Date_Time__c = system.today();
        objProperty_Inventory.Address__c = 'Dubai';
        objProperty_Inventory.Bath_Rooms__c = '2';
        objProperty_Inventory.Building__c = 'Emaar';
        objProperty_Inventory.Building_Code__c = '1234';
        objProperty_Inventory.City__c = 'Dubai';
        objProperty_Inventory.Location_ID__c = '11233';
        objProperty_Inventory.Sales_Room__c = '2 BedRooms';
        objProperty_Inventory.Unit_Type__c = 'Villa';
        objProperty_Inventory.Unit_Model__c = 'Type 2E';
        objProperty_Inventory.Property_Status__c = 'Available';
        return objProperty_Inventory;
    }
    public static Campaign_Attributes__c CreateCampaignAttributes(){
        Campaign_Attributes__c objCA = new Campaign_Attributes__c();
        objCA.Event_Payment_Method__c = 'Test Event Payment';
        objCA.Event_Type__c = 'Test Event';
        objCA.No_of_properties_customers_can_buy__c = '5';
        objCA.No_Of_Receipts__c = '2';
        objCA.Payment_Schedule_Type__c = 'Test Event Schedule';
        objCA.cm_Booking_Timer__c = 20;
        return objCA;
    }
    
    public static Campaign CreateCampaign(){
          Campaign c1 = new Campaign(Name='Sales Line',type='Launch',IsActive=true);
           return  c1;
    }
    
    public static Unit_Models__c CreateUnitModel(){
          Unit_Models__c um = new Unit_Models__c();
           return  um;
    }
    
    public static Joint_Owner__c CreateJointOwner(string strAccountId, string OppoId){
         Joint_Owner__c objJoint = new Joint_Owner__c();
         objJoint.cm_Joint_Owner__c =  strAccountId;
         objJoint.cm_Related_Opportunity__c =  OppoId;
         return objJoint;
    }
    
    public static Campaign_User__c CreateCampaignUser(string UserId, string CampainId){
        Campaign_User__c Us = new Campaign_User__c();
        Us.cm_Role_on_Campaign__c =  'Sales Admin';
        Us.cm_User__c =  UserId;
        us.cm_Campaign__c = CampainId;
        return Us;
    }
    
    public static Campaign_Unit__c CreateCampaignUnits(string CampaignId,string PIId){
        Campaign_Unit__c objCampaign = new Campaign_Unit__c();
        objCampaign.cm_Campaign__c = CampaignId;
        objCampaign.cm_Property_Inventory__c = PIId;
        return objCampaign;
    }
    
   
    
    public static User CreateStandardUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        //UserRole r = [Select id from userrole where name='Sales Admin'];
        User u = new User(Alias = 'standt', Email='standarduser@emaar.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@emaar.com');
        return u;
    }
    
    public static Campaign createCampaigns(){
         campaign cmp = new campaign();
        cmp.Name='test';
        cmp.CurrencyIsoCode='EGP';
        cmp.IsActive=true;
      return cmp;  
    }
    public static Account createAccount(){
       Account acc = new Account();
        acc.Name='test acc';
        acc.Corporate_Email__c='test@test.com';
        acc.Corporate_Phone_Country_Code__c='Egypt: 0020';
        acc.Corporate_Phone__c='5820400'; 
        return acc;
    }
    Public static ExpressofInterest__c createEOI(){
        ExpressofInterest__c eoi = new ExpressofInterest__c();
        eoi.Name='test';
        return eoi;
    }
    
}