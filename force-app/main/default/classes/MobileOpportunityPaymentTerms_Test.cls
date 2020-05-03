@isTest
public class MobileOpportunityPaymentTerms_Test {
    
    @isTest
    static void testMobileOpportunityPaymentTerms() {
        test.startTest();
        
        //create Opportunity
        Opportunity opp = TestDataFactory.createOpportunity();
        insert opp;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/PaymentTerms';
        req.addParameter('oppId', opp.Id);
        
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        
        MobileOpportunityPaymentTerms.httpGet();
        
        //create Opportunity_Property__c
        Location__c Loc = TestDataFactory.CreateLocation('U');
        loc.Location_Code__c = 'LOC-123-456';
        insert Loc;
        Property_Inventory__c inv = TestDataFactory.CreatePropertyInventory(Loc.Id);
        inv.recordTypeId = Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Package').getRecordTypeId();
        inv.Location__c = Loc.Id;
        inv.Instance__c = 'test';
        inv.Property_Status__c = 'Available';
        inv.Property_Type__c = 'Sale';
        insert inv;
        Opportunity_Property__c oppPro = TestDataFactory.CreateOpportunityProperty(opp.Id, inv.Id);
        insert oppPro;
        Payment_Terms__c pt = TestDataFactory.createPaymentTerms();
        pt.Opportunity_Property__c = oppPro.Id;
        insert pt;
        
        MobileOpportunityPaymentTerms.httpGet();
        
        //test post method
        MobileOpportunityPaymentTerms.SelectPaymentTermDTO spt = new MobileOpportunityPaymentTerms.SelectPaymentTermDTO();
        spt.opportunityId = opp.Id;
        spt.propertyUnitwrapList = new List<Cm_PaymentTerms.PropertyUnitwrap>();
        Cm_PaymentTerms.PropertyUnitwrap PropUnitwrap = new Cm_PaymentTerms.PropertyUnitwrap();
        PropUnitwrap.strUnitName = 'LOC-123-456';
        PropUnitwrap.HeaderId = 'headerId';
        PropUnitwrap.community = 'comm';
        PropUnitwrap.opportunityPropertyId = oppPro.Id;
        PropUnitwrap.campaignType = 'campType';
        PropUnitwrap.campaignPrice = 900;
        PropUnitwrap.lstCampaignWrap = new list<Cm_PaymentTerms.CampaignWrap>();
        Cm_PaymentTerms.CampaignWrap CampaignWrapper = new Cm_PaymentTerms.CampaignWrap();
        CampaignWrapper.CAMPAIGN_ID = 'CAMPAIGN_ID';
        CampaignWrapper.CAMPAIGN_NAME = 'CAMPAIGN_NAME';
        CampaignWrapper.CAMPAIGN_DESC = 'CAMPAIGN_DESC';
        CampaignWrapper.CAMPAIGN_TYPE = 'CAMPAIGN_TYPE';
        CampaignWrapper.CAMPAIGN_MAP_ID = 'CAMPAIGN_MAP_ID';
        CampaignWrapper.CAMPAIGN_PRICE = 800;
        CampaignWrapper.selectedTerm = True;
        CampaignWrapper.lstResponsewrap = new list<Cm_PaymentTerms.Responsewrap>();
        Cm_PaymentTerms.Responsewrap resp = new Cm_PaymentTerms.Responsewrap();
        resp.EFFECTIVE_DATE = 'EFFECTIVE_DATE';
        resp.TERM = 'TERM';
        resp.INSTALLMENT = 'TERM';
        resp.PERCENTAGE_PAYMENT ='PERCENTAGE_PAYMENT';
        resp.SEQUENCE_NUM = 90;
        resp.SCHEDULE_PRICE = 90;
        resp.MAINTENANCE_PRICE = 90;
        CampaignWrapper.lstResponsewrap.add(resp);
        
        PropUnitwrap.lstCampaignWrap.add(CampaignWrapper);
        spt.propertyUnitwrapList.add(PropUnitwrap);
        MobileOpportunityPaymentTerms.httpPost(spt);
        
        
        test.stopTest();
    }
}