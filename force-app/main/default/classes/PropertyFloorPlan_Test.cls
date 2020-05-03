@isTest 
public class PropertyFloorPlan_Test {
 static testMethod void doTest() {
       
        
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonEmail ='test@gmail.com';
        objAccount.PersonMobilePhone ='5678903456';
        insert objAccount;
        
        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount.id;
        insert objOppor;
     
        
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        objLoc.Location_Code__c= 'UAE';
        objLoc.Building__c='UAE';
        insert objLoc;  
        
        Location__c objLo = TestDataFactory.CreateLocation('U');
        insert objLo;  
     
       
        Property_Inventory__c objProINV = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV.Instance__c = '123456';
        objProINV.Unit_Position__c='test';
        objProINV.Building__c=objLoc.id;
        objProINV.location__C = objLoc.id;
        insert objProINV;
     
        Property_Inventory__c objProIN = TestDataFactory.CreatePropertyInventory(objLo.id);
        objProIN.Instance__c = '123756';
        insert objProIN;
        
        Unit_Models__c um=TestDataFactory.CreateUnitModel();
        um.Type__c='test';
        insert um;
           
          string before = 'Testing base 64 encode';            
          Blob beforeblob = Blob.valueOf(before);        
         //Insert contentdocument data
          ContentVersion cv = new ContentVersion();
          cv.PathOnClient ='test';  
          cv.title ='Google.com';      
          cv.Property_Inventory__c = objProINV.id; 
          cv.cm_Building__c = objLoc.id; 
          cv.cm_is_Floor_plan__c = true;         
          cv.VersionData =beforeblob;
          cv.Unit_Model__c=um.id;     
          insert cv;
          
          ContentVersion cv1 = new ContentVersion();
          cv1.title ='Google.com'; 
          cv1.PathOnClient ='test';       
          cv1.Property_Inventory__c = objProINV.id; 
          cv1.cm_Building__c = objLoc.id; 
          cv1.cm_is_Floor_plan__c = true;         
          cv1.VersionData =beforeblob;
          //cv1.Unit_Model__c=um.id;     
          insert cv1;
          
          ContentVersion cv2 = new ContentVersion();
          cv2.title ='Google.com'; 
          cv2.PathOnClient ='test';       
          cv2.Property_Inventory__c = objProINV.id; 
          cv2.cm_Building__c = objLoc.id; 
          cv2.cm_is_Floor_plan__c = true;         
          cv2.VersionData =beforeblob;
          //cv2.Unit_Model__c=um.id;     
          insert cv2; 
         
         
 
        Attachment attach = new Attachment();     
        attach.Name = 'Unit Test Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = objOppor.id;
        Insert attach;
        
      
         test.starttest();
            ApexPages.StandardController sc = new ApexPages.StandardController(objOppor);
            PropertyFloorPlan objController = new PropertyFloorPlan(sc);
            PropertyFloorPlan.CreateContentAttachment(objProINV.id);
            PropertyFloorPlan.deleteContentAttachment(objProINV.id);
        

        
        test.stopTest();
    }
   
    
    
}