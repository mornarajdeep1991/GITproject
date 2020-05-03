/*
    Author : Prachi Sinha
    Date :
    Description:
    Modification History :
    *************************************************************
    Vesion               Author             Date                      Description
    V 1.0                prachi           9th May 2018              Page from Dubai sandbox

*/
public with sharing class CM_GenerateSalesOffer {
public list<Opportunity_Property__c> lstOpportunityProperty{get;set;}
public list<Cm_PaymentTerms.CampaignWrap> lstResponsewrapdata{get;set;}
public list<Cm_PaymentTerms.PropertyUnitwrap> lstPropertyUnitwrap{get;set;}
public list<UnitPaymentTerms> lstUnitPaymentTerms{get;set;}
public list<AttachmentURLwrap> lstAttachmentURLwrap{get;set;}
public list<PropertyDiscountwrap> lstPropertyDiscountwrap{get;set;}
public string fileId{get;set;}
public date DTval{get;set;}
public string strOpporId = '';
public String imageURL{get;set;}
public opportunity objopportunity{get;set;}
public Account objAccount{get;set;}
public map<string,string> mpValues = new map<string,string>();
public boolean blnStatus{get;set;}
public MAP<Id, LIST<Payment_Terms__c>> oPropertyIdToPaymentTermsMap {get; set;}

public CM_GenerateSalesOffer(){
    lstPropertyDiscountwrap = new list<PropertyDiscountwrap>();
    lstUnitPaymentTerms = new list<UnitPaymentTerms>();
    lstOpportunityProperty = new list<Opportunity_Property__c>();
    string strAccountId = '';
    DTval = system.today();
    strOpporId = apexpages.currentpage().getparameters().get('id');
    
    list<opportunity> lstOpportunity = [select id,name,Account.name, cm_Sales_Person__r.Name,cm_Sales_Person__c,cm_Sales_Executive_Manager__c from opportunity where id=:strOpporId];
    if(lstOpportunity!=null && lstOpportunity.size()>0){
        objopportunity = lstOpportunity[0];
        if(lstOpportunity[0].AccountId!=null)
            strAccountId = lstOpportunity[0].AccountId;
    }
    map<id,string> mapinvdata = new map<id,string>();
    lstOpportunityProperty = [select id,name,cm_Inventory_Location_Code__c,cm_Property_Inventory__r.community__c,cm_Property_Inventory__r.Applicable_Fees_to_Dubai_Land_Department__c,cm_Property_Inventory__c,cm_Property_Inventory__r.Type__c,cm_Property_Inventory__r.Property__r.Property_Name__c,cm_Property_Inventory__r.name,cm_Property_Inventory__r.Property__r.name,cm_Property_Inventory__r.Unit__c,cm_Property_Inventory__r.Building__c,cm_Property_Inventory__r.Unit_type__C,cm_Property_Inventory__r.Unit_Model__C,cm_Property_Inventory__r.Sales_Rooms__c,cm_Property_Inventory__r.Total_Area__c,cm_Property_Inventory__r.Selling_Price__c,cm_Property_Inventory__r.Plot_Area_Sq_Ft__c from Opportunity_Property__c where cm_Opportunity__c=:strOpporId];
    for(Opportunity_Property__c objProp:lstOpportunityProperty){
        //PropertyDiscountwrap objwrap = new PropertyDiscountwrap();
       // objwrap.locationCode = objProp.cm_Inventory_Location_Code__c;
      //  objwrap.dPrice = objProp.cm_Property_Inventory__r.Applicable_Fees_to_Dubai_Land_Department__c;
      //  lstPropertyDiscountwrap.add(objwrap);
      if(objProp.cm_Property_Inventory__r.Type__c == 'Townhouse' || objProp.cm_Property_Inventory__r.Type__c == 'Villa'){
          blnStatus = true;
      }
    }
    set<id> setIds = new set<id>();
     if(lstOpportunityProperty!=null && lstOpportunityProperty.size()>0){
         for(Opportunity_Property__c objprop:lstOpportunityProperty){
             setIds.add(objprop.Id);
             mapinvdata.put(objprop.cm_Property_Inventory__c,objprop.cm_Inventory_Location_Code__c);
         }
     }
     system.debug('***setIds'+setIds);
    List<Attachment> attachedFiles = [select Id,parentId from Attachment where parentId IN:setIds  and name LIKE 'salesOffer%'  order By LastModifiedDate ];
   lstAttachmentURLwrap = new list<AttachmentURLwrap>();
   for(Attachment objAttachment:attachedFiles){
        AttachmentURLwrap objwrap = new AttachmentURLwrap();
        objwrap.strURL = URL.getSalesforceBaseUrl().toExternalForm() +'/servlet/servlet.FileDownload?file='+objAttachment.id;
        objwrap.strURL = objwrap.strURL.replace('visual', 'content');
        if(mapinvdata!=null && mapinvdata.get(objAttachment.parentId)!=null)
            objwrap.Unit = mapinvdata.get(objAttachment.parentId);
        lstAttachmentURLwrap.add(objwrap);
    }
    system.debug('****lstAttachmentURLwrap'+lstAttachmentURLwrap);
    if(lstOpportunityProperty!=null && lstOpportunityProperty.size()>0){
         PreparePaymentTerms(strOpporId);
     }
    prepareImageURL();

    oPropertyIdToPaymentTermsMap = new MAP<Id, LIST<Payment_Terms__c>>();
    for(Opportunity_Property__c oProperty : [SELECT Id FROM Opportunity_Property__c WHERE cm_Opportunity__c=:stropporid]){
      oPropertyIdToPaymentTermsMap.put(oProperty.Id, new LIST<Payment_Terms__c>());
    }
    //getting payment terms

    for(Payment_Terms__c pTerms : [SELECT Id, Opportunity_Property__c, Installment__c, Term_Date__c, Term__c, cm_Schedule_Type__c, cm_Net_Percent__c, cm_Term_Date__c, Installment_Amount__c, Maintnance_Price__c
                                  FROM Payment_Terms__c WHERE Opportunity_Property__c IN :oPropertyIdToPaymentTermsMap.keyset() ]){
      if(oPropertyIdToPaymentTermsMap.containsKey(pTerms.Opportunity_Property__c)){
        LIST<Payment_Terms__c> listTerms = oPropertyIdToPaymentTermsMap.get(pTerms.Opportunity_Property__c);
        listTerms.add(pTerms);
        oPropertyIdToPaymentTermsMap.put(pTerms.Opportunity_Property__c, listTerms);
      }
    }


}
/* Added by - Nara. EPESI-862 & EPESI-975 */ 
public String VATRateCodeTextValue;
public void PreparePaymentTerms(string strID){
    
    lstResponsewrapdata = new list<Cm_PaymentTerms.CampaignWrap>();
    lstPropertyUnitwrap = new list<Cm_PaymentTerms.PropertyUnitwrap>(); 
    VATRateCodeTextValue = '';
    try{
        
        
    lstUnitPaymentTerms = new list<UnitPaymentTerms>();
    string stropporid = strID;
    list<Opportunity_Property__c> lstOpportunityProperty = [select id,name,Campaign_Type__c,Campaign_Price__c,cm_Property_Inventory__r.Location_Code__c,cm_Property_Inventory__r.payment_Header_id__c,
                                                             cm_Property_Inventory__r.Standard_Cost__c,cm_Opportunity__c,cm_Opportunity__r.Order_Event__c,cm_Opportunity__r.Order_Source__c,
                                                             cm_Property_Inventory__r.Selling_Price__c,cm_Opportunity__r.campaign.Type,cm_Opportunity__r.cm_Payment_Mode__c,
                                                             cm_Property_Inventory__r.Location__c,cm_Property_Inventory__r.Location__r.Location_ID__c,cm_Property_Inventory__r.Location__r.Location_Code__c,
                                                             cm_Opportunity__r.campaign.Eloqua_Id__c,cm_Opportunity__r.campaign.Name,cm_Property_Inventory__r.Org_ID__c,cm_Org_ID__c,VAT_Rate_Code_Text__c,
                                                             cm_Property_Inventory__r.community__c,cm_Property_Inventory__r.Event_ID__c,cm_Property_Inventory__r.cm_Related_Campaign__c,cm_Property_Inventory__r.Schedule_Type__c,cm_Property_Inventory__r.Payment_method__c,cm_Property_Inventory__r.cm_Related_Campaign__r.Campaign_Number__c
                                                              from Opportunity_Property__c where cm_Opportunity__c=:stropporid];
   
   
    // Suggested code changes                                                         
    Opportunity opp = [Select id, cm_Default_Payment_schedule_type__c from Opportunity where id=: stropporid];
    // END**********************
    Map<string,string> mpValues = new Map<string,String>();   
    Map<string,Id> mpLocs = new Map<string,id>();
    for(Opportunity_Property__c objPro:lstOpportunityProperty){
        // Added by VV
        if(objPro.VAT_Rate_Code_Text__c != NULL){
            VATRateCodeTextValue = objPro.VAT_Rate_Code_Text__c;
        }
        
        string strAmount = '';
        //mpLocs.put(objPro.cm_Property_Inventory__r.Location__r.Location_ID__c, objPro.Id);
        if(objPro.cm_Property_Inventory__r.Selling_Price__c!=null)
          strAmount = string.valueof(objPro.cm_Property_Inventory__r.Selling_Price__c);
        string location_id = objPro.cm_Property_Inventory__r.Location__r.Location_ID__c;
        string location_code = objPro.cm_Property_Inventory__r.Location__r.Location_Code__c;
        string amount = strAmount;
        //string strdate = system.today().day()+'-'+system.today().month('')+''+system.today().year();
        DateTime d = datetime.now();
        String monthName= d.format('MMM');
        integer Day= d.day();
        integer year= d.year();
        string strdate = Day+'-'+monthName+'-'+year;
        string org_id = '';
        if(objPro.cm_Property_Inventory__r.Org_ID__c!=null)
            org_id = string.valueof(objPro.cm_Property_Inventory__r.Org_ID__c);
        string HeaderId = '';
        string PlotPrice ='';
        if(objPro.cm_Property_Inventory__r.Selling_Price__c!=null)
          PlotPrice = string.valueof(objPro.cm_Property_Inventory__r.Selling_Price__c);
        string event_id = '';
        if(objPro.cm_Property_Inventory__r.cm_Related_Campaign__c == null)
           event_id = '999999999';//string.valueof(objPro.cm_Property_Inventory__r.Event_ID__c);
        else
           event_id = objPro.cm_Property_Inventory__r.cm_Related_Campaign__r.Campaign_Number__c;    
        
        string Schedule_type;
        
        if (opp != null) {
                
            if (opp.cm_Default_Payment_Schedule_Type__c == null || opp.cm_Default_Payment_Schedule_Type__c == 'Standard') {
                
                if (objPro.cm_Property_inventory__r.Payment_method__c != null) {
                    Schedule_type = objPro.cm_Property_Inventory__r.Payment_Method__c;
                }
                else {
                    Schedule_type = 'STANDARD';
                }
            }
            else 
                Schedule_type  = opp.cm_Default_Payment_Schedule_Type__c;
        }
        else {
            Schedule_type = objPro.cm_Property_Inventory__r.Payment_method__c != null ? objPro.cm_Property_Inventory__r.Payment_method__c : 'STANDARD';
        } 
        
        system.debug('schedule_type -> ' + schedule_type);
        emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresposne = new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
        if(!Test.isRunningTest()){
            objresposne = EmaarWebServiceUtils.executePaymentTerms(location_id,amount,strdate,org_id,HeaderId,PlotPrice,event_id,Schedule_type);
        }else{
            objresposne.Status = 'SUCCESS';
            objresposne.ErrorMessage = 'Payment Terms sent sucessfully.';
            string strXML =  '<P_RESULT_XML xmlns="http://xmlns.oracle.com/pcbpel/adapter/db/APPS/XX_MOBILE_INT_PKG/PERFORM_ACTION/"> <AVAILABLE_CAMPAIGNS xmlns=""> <CAMPAIGN_HDR> <CAMPAIGN_ID>5</CAMPAIGN_ID> <CAMPAIGN_NAME>6 Year Marassi Greek</CAMPAIGN_NAME> <CAMPAIGN_DESC>6 Year pyament plan for Marassi Greek</CAMPAIGN_DESC> <CAMPAIGN_TYPE>6 years payment plan</CAMPAIGN_TYPE> <CAMPAIGN_MAP_ID>367</CAMPAIGN_MAP_ID> <CAMPAIGN_PRICE>19933888</CAMPAIGN_PRICE> <CAMPAIGN_LINES> <CAMPAIGN_LINE> <PLAN_TYPE>Payment Schedule</PLAN_TYPE> <SEQUENCE_NUM>1</SEQUENCE_NUM> <PERCENTAGE_PAYMENT>10</PERCENTAGE_PAYMENT> <INSTALLMENT>Down Payment</INSTALLMENT> <EFFECTIVE_DATE>2018-04-04</EFFECTIVE_DATE> <TERM>IMMEDIATE</TERM> <SCHEDULE_PRICE>1993388.8</SCHEDULE_PRICE> <MAINTENANCE_PRICE>0</MAINTENANCE_PRICE> </CAMPAIGN_LINE> <CAMPAIGN_LINE> <PLAN_TYPE>Payment Schedule</PLAN_TYPE> <SEQUENCE_NUM>4</SEQUENCE_NUM> <PERCENTAGE_PAYMENT>60</PERCENTAGE_PAYMENT> <INSTALLMENT>Final Payment</INSTALLMENT> <EFFECTIVE_DATE>2019-04-18</EFFECTIVE_DATE> <TERM>IMMEDIATE</TERM> <SCHEDULE_PRICE>11960332.8</SCHEDULE_PRICE> <MAINTENANCE_PRICE>0</MAINTENANCE_PRICE> </CAMPAIGN_LINE> <CAMPAIGN_LINE> <PLAN_TYPE>Maintenance Schedule</PLAN_TYPE> <SEQUENCE_NUM>3</SEQUENCE_NUM> <PERCENTAGE_PAYMENT>5</PERCENTAGE_PAYMENT> <INSTALLMENT>INSTALLMENT 3</INSTALLMENT> <EFFECTIVE_DATE>2019-02-01</EFFECTIVE_DATE> <TERM>IMMEDIATE</TERM> <SCHEDULE_PRICE>0</SCHEDULE_PRICE> <MAINTENANCE_PRICE>996694.4</MAINTENANCE_PRICE> </CAMPAIGN_LINE> <CAMPAIGN_LINE> <PLAN_TYPE>Maintenance Schedule</PLAN_TYPE> <SEQUENCE_NUM>2</SEQUENCE_NUM> <PERCENTAGE_PAYMENT>5</PERCENTAGE_PAYMENT> <INSTALLMENT>INSTALLMENT 2</INSTALLMENT> <EFFECTIVE_DATE>2018-12-01</EFFECTIVE_DATE> <TERM>IMMEDIATE</TERM> <SCHEDULE_PRICE>0</SCHEDULE_PRICE> <MAINTENANCE_PRICE>996694.4</MAINTENANCE_PRICE> </CAMPAIGN_LINE> <CAMPAIGN_LINE> <PLAN_TYPE>Payment Schedule</PLAN_TYPE> <SEQUENCE_NUM>3</SEQUENCE_NUM> <PERCENTAGE_PAYMENT>20</PERCENTAGE_PAYMENT> <INSTALLMENT>INSTALLMENT 2</INSTALLMENT> <EFFECTIVE_DATE>2018-09-26</EFFECTIVE_DATE> <TERM>IMMEDIATE</TERM> <SCHEDULE_PRICE>3986777.6</SCHEDULE_PRICE> <MAINTENANCE_PRICE>0</MAINTENANCE_PRICE> </CAMPAIGN_LINE> <CAMPAIGN_LINE> <PLAN_TYPE>Payment Schedule</PLAN_TYPE> <SEQUENCE_NUM>2</SEQUENCE_NUM> <PERCENTAGE_PAYMENT>10</PERCENTAGE_PAYMENT> <INSTALLMENT>INSTALLMENT 1</INSTALLMENT> <EFFECTIVE_DATE>2018-06-18</EFFECTIVE_DATE> <TERM>IMMEDIATE</TERM> <SCHEDULE_PRICE>1993388.8</SCHEDULE_PRICE> <MAINTENANCE_PRICE>0</MAINTENANCE_PRICE> </CAMPAIGN_LINE> <CAMPAIGN_LINE> <PLAN_TYPE>Maintenance Schedule</PLAN_TYPE> <SEQUENCE_NUM>1</SEQUENCE_NUM> <PERCENTAGE_PAYMENT>5</PERCENTAGE_PAYMENT> <INSTALLMENT>INSTALLMENT 1</INSTALLMENT> <EFFECTIVE_DATE>2018-05-01</EFFECTIVE_DATE> <TERM>IMMEDIATE</TERM> <SCHEDULE_PRICE>0</SCHEDULE_PRICE> <MAINTENANCE_PRICE>996694.4</MAINTENANCE_PRICE> </CAMPAIGN_LINE> </CAMPAIGN_LINES> </CAMPAIGN_HDR> </AVAILABLE_CAMPAIGNS> </P_RESULT_XML>';
            objresposne.ResultXML = strXML;
        }
        system.debug('******objresposne'+objresposne);

        if(objresposne.Status == 'SUCCESS' && objresposne.ErrorMessage=='Payment Terms sent sucessfully.'){
            if(objresposne.ResultXML!=null && objresposne.ResultXML!=''){
                lstResponsewrapdata = Cm_PaymentTerms.parsedata(objresposne.ResultXML);
                if(lstResponsewrapdata!=null && lstResponsewrapdata.size() >0){
                    system.debug('******lstResponsewrapdata'+lstResponsewrapdata);
                    Cm_PaymentTerms.PropertyUnitwrap objwrap = new Cm_PaymentTerms.PropertyUnitwrap();
                    objwrap.strUnitName = location_code;
                    objwrap.HeaderId = lstResponsewrapdata[0].CAMPAIGN_ID;
                    objwrap.opportunityPropertyId = objPro.Id;
                    objwrap.community = objPro.cm_Property_Inventory__r.Community__c;
                    //Adeel - adding campaing wrap here...
                    objwrap.lstCampaignWrap = new list<Cm_PaymentTerms.CampaignWrap>();
                    objwrap.lstCampaignWrap = lstResponsewrapdata;
                    objwrap.campaignType = objPro.Campaign_Type__c;
                    objwrap.campaignPrice = objPro.Campaign_Price__c;
                    lstPropertyUnitwrap.add(objwrap);
                    //lstUnitPaymentTerms.add(objwrap);
                    mpValues.put(objPro.cm_Property_Inventory__c, objwrap.HeaderId);
                }
            }
        }
    }
    
    
    system.debug('>>>>>>>mpValues>>>>>>>>>'+mpValues);
    /*if(!mpValues.isEmpty()){
      List<Property_Inventory__c> lstInv = new List<Property_Inventory__c>();
      for(string s: mpValues.keyset()){
        lstInv.add(new Property_Inventory__c(Id=s,payment_Header_id__c=mpValues.get(s)));
      }
      
      if(!lstInv.isEmpty())
        update lstInv;
    }*/
    
    }catch(exception ex){
        system.debug('*******Exception'+ex.getMessage());
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error,ex.getMessage()));
    }
}
public void prepareImageURL(){
    imageURL= CM_EmaarUtils.prepareImageURL();
   
  }
 public class AttachmentURLwrap{
     public string strURL {get;set;}
     public string Unit {get;set;}
 }
 public class UnitPaymentTerms{
     public string strUnit {get;set;}
     public string community{get; set;}
     public list<Responsewrap> lstResponsewrap {get;set;}
 }
 public class Responsewrap{
    public string LOCATION_ID{get;set;}
    public string ORG_ID{get;set;}
    public string LOCATION_CODE{get;set;}
    public string INST_NUMBER{get;set;}
    public decimal NET_AMOUNT{get;set;}
    public string NET_PERCENT{get;set;}
    public string TERMDAYS{get;set;}
    public string TERMDATE{get;set;}
    public string MILESTONE_NAME{get;set;}
    public string MIL_PERCENTAGE{get;set;}
    public string SM_HEADER_ID{get;set;}
    public string SCHEDULE_TYPE{get;set;}
    public string MILESTONE_NAME_ARB{get;set;}
    public string VAT_RATE{get;set;}
    public decimal VAT_AMOUNT{get;set;}
    public decimal TOTAL_AMOUNT{get;set;}
    // Added by VV
    public String VAT_RATE_CODE_TEXT{get;set;}
}


public class PropertyDiscountwrap{
    public string locationCode{get;set;}
    public decimal dPrice{get;set;}
}

}