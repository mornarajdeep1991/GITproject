/*****************************************/
/**
*  @Who     Rajnish Kumar <rajnishkumar393@gmail.com>
*  @When    04/06/2018
*  @What    Test Class for : PropertyInventoryDocumentsURL
*/
/****************************************/
@isTest
private class PropertyInventoryDocumentsURL_Test{

    @testsetup
    static void setData(){
        TestClassUtilitySetUpContentObj.setupData();
    }
    
    static testMethod void propInvDocURLtest() {      
        Test.Starttest();
        Location__c lc = new Location__c();
        lc.Building__c = 'Build';
        lc.Attribute_Category__c = 'B';
        lc.Location_Code__c = 'Build';
        insert lc;
        
        Property_Inventory__c objPropInv = new Property_Inventory__c();
        objPropInv.Document_URLs__c = '';
        objPropInv.Location__c = lc.id;
        objPropInv.Unit_Position__c  = 'UnitPos';
        objPropInv.Instance__c = 'testInstance';
        insert objPropInv;
        
        contentversion cv = [select id,title,cm_Content_Key__c from contentversion where Title = 'testCV'];
        cv.Property_Inventory__c = objPropInv.id;
        cv.cm_Building__c = lc.id;
        upsert cv;
        
        PropertyInventoryDocumentsURL.getURL(new list<id>{objPropInv.id});
        
        Test.stoptest();   
    }
    
    
    static testMethod void propInvDocURLtest1() {      
        Test.Starttest();
        Location__c lc = new Location__c();
        lc.Building__c = 'Build';
        lc.Attribute_Category__c = 'B';
        lc.Location_Code__c = 'Build';
        insert lc;
        
        Property_Inventory__c objPropInv = new Property_Inventory__c();
        objPropInv.Document_URLs__c = '';
        objPropInv.Location__c = lc.id;
        objPropInv.Unit_Position__c  = 'UnitPos';
        objPropInv.Instance__c = 'testInstance';
        insert objPropInv;
        
        PropertyInventoryDocumentsURL.getURL(new list<id>{objPropInv.id});
        
        Test.stoptest();   
    }
   
    static testMethod void propInvDocURLtest2() {      
        Test.Starttest();
        Location__c lc = new Location__c();
        lc.Building__c = 'Build';
        lc.Attribute_Category__c = 'B';
        lc.Location_Code__c = 'Build';
        insert lc;
        
        Unit_Models__c um = new Unit_Models__c();
        insert um;
        
        Property_Inventory__c objPropInv = new Property_Inventory__c();
        objPropInv.Document_URLs__c = '';
        objPropInv.Location__c = lc.id;
        objPropInv.Unit_Position__c  = 'UnitPos';
        objPropInv.Instance__c = 'testInstance';
        insert objPropInv;
        
        contentversion cv = [select id,title from contentversion where Title = 'testCV'];
        cv.Property_Inventory__c = objPropInv.id;
        cv.cm_Building__c = lc.id;
        cv.Unit_Model__c = um.id;
        update cv;
        ContentDistribution ContDist = New ContentDistribution();
        ContDist.Name = 'test';
        ContDist.ContentVersionId = cv.Id;
        insert ContDist;
        
        apexPages.currentPage().getParameters().put('id',ContDist.id);
        
        PropertyInventoryDocumentsURL.getURL(new list<id>{objPropInv.id});
        Test.stoptest();   
    }
}