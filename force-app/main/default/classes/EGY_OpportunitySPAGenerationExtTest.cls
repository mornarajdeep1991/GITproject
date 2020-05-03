/***********************************************************************************************
* Name              : EGY_OpportunitySPAGenerationExtTest                                                 
* Description       : Test class for EGY_OpportunitySPAGenerationExt                                         
* Created Date      : 14/08/2018                                                    
* Created By        : Adeel Ahmad (adeel.ahmad@were4c.com)    
* ----------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
* 1.0       Adeel       14/08/2018  Created                              
************************************************************************************************/
@isTest
public class EGY_OpportunitySPAGenerationExtTest {
    public static testMethod void testNavidation(){
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonMailingCountry ='United Arab Emirates';
        insert objAccount;
      
        Campaign objCampaign = TestDataFactory.CreateCampaign();
        insert objCampaign;
        
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        objLoc.Location_Code__c= 'UAE';
        insert objloc;
        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.CampaignID = objCampaign.id;
        objOppor.AccountId = objAccount.Id;
        
        insert objOppor;
        
        Property_Inventory__c objProINV = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV.Instance__c = 'test';
        objProINV.location__c = objloc.id;
        insert objProINV;
        
        Opportunity opp = TestDataFactory.CreateOpportunity();
        opp.AccountId = objAccount.Id;
        insert opp;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        EGY_OpportunitySPAGenerationExt spaExt = new EGY_OpportunitySPAGenerationExt(sc);
        
        PageReference pageRef = Page.EGY_OpportunitySPAGeneration;
        pageRef.getParameters().put('id', String.valueOf(opp.Id));
        Test.setCurrentPage(pageRef);
        spaExt.navigateToDrawloop();
        
        Opportunity_Property__c opProperty = TestDataFactory.CreateOpportunityProperty(opp.Id, objProINV.Id);
        insert opProperty;
       	spaExt.navigateToDrawloop();
        
        //objProINV.Drawloop_Template__c = 'a0i4E0000064PwQ';
        //update objProINV;
        //spaExt.navigateToDrawloop();

    }	
}