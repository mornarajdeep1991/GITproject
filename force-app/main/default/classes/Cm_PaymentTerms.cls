public class Cm_PaymentTerms {
    
    public list<CampaignWrap> lstResponsewrapdata{get;set;}
    public list<PropertyUnitwrap> lstPropertyUnitwrap{get;set;}
    public string  stropporid{get; set;}
    public string strName{get;set;}
    public boolean blncheck{get;set;}
    public MAP<String, String> opPropertyNameToCampaignIdMap {get; set;}
    private Id oppId {get; set;}
    public string orderNumber {get;set;}
    public Cm_PaymentTerms(Apexpages.StandardController sc){
        oppId = sc.getId();
        lstPropertyUnitwrap = new list<PropertyUnitwrap>(); 
        opPropertyNameToCampaignIdMap = new MAP<String, String>();
        for(Opportunity_Property__c opProperty : [SELECT Id, Campaign_Id__c, cm_Property_Inventory__r.Location_Code__c,
                                                  Sales_Order__c
                                                  FROM Opportunity_Property__c WHERE cm_Opportunity__c =: oppId]){
            if(opProperty.Sales_Order__c != null && (orderNumber == null || orderNumber == '')){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'You cannot change the payment plan after the order has been created on Oracle.\nPlease, cancel this order and create a new one.'));    
                orderNumber = opProperty.Sales_Order__c;
            }
            if(opProperty.Campaign_Id__c != null){
                opPropertyNameToCampaignIdMap.put(opProperty.cm_Property_Inventory__r.Location_Code__c, opProperty.Campaign_Id__c);
            }
        }
    }
    
    public void ServiceCall(){
        stropporid = apexpages.currentPage().getParameters().get('id');
        GeneratePaymentTermsdata(stropporid);
    }
    
    /* Added by - Nara. EPESI-862 & EPESI-975 */ 
    public static String VATRateCodeTextValue;
    public void GeneratePaymentTermsdata(string stropporid){
        integer iTotal = 0;
        integer isuccessCount = 0;
        integer iErrorCount = 0;
        list<Service_Logs__c> lstservlog = new list<Service_Logs__c>();
        string strParentId = '';
        string Requestbody ='';
        lstPropertyUnitwrap = new list<PropertyUnitwrap>();
        lstResponsewrapdata = new list<CampaignWrap>();
        
        
        list<Opportunity_Property__c> lstOpportunityProperty = [select id,name,cm_Property_Inventory__r.Location_Code__c,cm_Property_Inventory__r.payment_Header_id__c,VAT_Rate_Code_Text__c,
                                                                cm_Property_Inventory__r.Standard_Cost__c,cm_Opportunity__c,cm_Opportunity__r.Order_Event__c,cm_Opportunity__r.Order_Source__c,
                                                                cm_Property_Inventory__r.Selling_Price__c,cm_Opportunity__r.campaign.Type,cm_Opportunity__r.cm_Payment_Mode__c,
                                                                cm_Property_Inventory__r.Location__c,cm_Property_Inventory__r.Location__r.Location_ID__c,cm_Property_Inventory__r.Location__r.Location_Code__c,
                                                                cm_Opportunity__r.campaign.Eloqua_ID__c,cm_Opportunity__r.campaign.Name,cm_Property_Inventory__r.Org_ID__c,cm_Org_ID__c,
                                                                cm_Property_Inventory__r.Event_ID__c,cm_Property_Inventory__r.Schedule_Type__c,cm_Property_Inventory__r.Payment_method__c,cm_Property_Inventory__r.cm_Related_Campaign__c,cm_Property_Inventory__r.cm_Related_Campaign__r.Campaign_Number__c
                                                                from Opportunity_Property__c where cm_Opportunity__c=:stropporid];
        // Suggested code changes                                                         
        Opportunity opp = [Select id, cm_Default_Payment_schedule_type__c from Opportunity where id=: stropporid];
        // END**********************
        iTotal =  lstOpportunityProperty.size();   
        Map<string,string> mpValues = new Map<string,String>();   
        Map<string,Id> mpLocs = new Map<string,id>();
        emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresposne = new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
        if(lstOpportunityProperty.isEmpty()){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Fatal,'Please add properties to Opportunity for viewing Payment Terms.'));
        }
        else{
            for(Opportunity_Property__c objPro:lstOpportunityProperty){
                if(objPro.VAT_Rate_Code_Text__c != NULL)
                    VATRateCodeTextValue = objPro.VAT_Rate_Code_Text__c;
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
                string org_id = string.valueof(objPro.cm_Org_ID__c);
                string HeaderId ='';
                string PlotPrice ='';
                if(objPro.cm_Property_Inventory__r.Selling_Price__c!=null)
                    PlotPrice = string.valueof(objPro.cm_Property_Inventory__r.Selling_Price__c);
                string event_id = '';
                if(objPro.cm_Property_Inventory__r.cm_Related_Campaign__c==null)
                    event_id = '999999999';//string.valueof(objPro.cm_Property_Inventory__r.Event_ID__c);
                else
                    event_id = objPro.cm_Property_Inventory__r.cm_Related_Campaign__r.Campaign_Number__c;

                string Schedule_type = '';
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

                // End...
                Requestbody = 'Location ID :'+location_id+' /n Amount '+amount+'/n StrDate :'+strdate+'/n org_id:'+org_id+' /n HeaderId:'+HeaderId+'  \n  PlotPrice :'+PlotPrice+' \n  Event Id :'+event_id+'  \n Schedule Type :'+Schedule_type ;
                //Adeel - Added for testing
                System.debug('@@Requestbody='+Requestbody);
                HeaderId = '5';

                try{
                    if(!Test.isRunningTest()){
                        objresposne = EmaarWebServiceUtils.executePaymentTerms(location_id,amount,strdate,org_id,HeaderId,PlotPrice,event_id,Schedule_type);
                    }else{
                        objresposne.Status = 'SUCCESS';
                        objresposne.ErrorMessage = 'Payment Terms sent sucessfully.';
                        string strXML =  '<P_RESULT_XML xmlns="http://xmlns.oracle.com/pcbpel/adapter/db/APPS/XX_MOBILE_INT_PKG/PERFORM_ACTION/"> <AVAILABLE_CAMPAIGNS xmlns=""> <CAMPAIGN_HDR> <CAMPAIGN_ID>5</CAMPAIGN_ID> <CAMPAIGN_NAME>6 Year Marassi Greek</CAMPAIGN_NAME> <CAMPAIGN_DESC>6 Year pyament plan for Marassi Greek</CAMPAIGN_DESC> <CAMPAIGN_TYPE>6 years payment plan</CAMPAIGN_TYPE> <CAMPAIGN_MAP_ID>367</CAMPAIGN_MAP_ID> <CAMPAIGN_PRICE>19933888</CAMPAIGN_PRICE> <CAMPAIGN_LINES> <CAMPAIGN_LINE> <PLAN_TYPE>Payment Schedule</PLAN_TYPE> <SEQUENCE_NUM>1</SEQUENCE_NUM> <PERCENTAGE_PAYMENT>10</PERCENTAGE_PAYMENT> <INSTALLMENT>Down Payment</INSTALLMENT> <EFFECTIVE_DATE>2018-04-04</EFFECTIVE_DATE> <TERM>IMMEDIATE</TERM> <SCHEDULE_PRICE>1993388.8</SCHEDULE_PRICE> <MAINTENANCE_PRICE>0</MAINTENANCE_PRICE> </CAMPAIGN_LINE> <CAMPAIGN_LINE> <PLAN_TYPE>Payment Schedule</PLAN_TYPE> <SEQUENCE_NUM>4</SEQUENCE_NUM> <PERCENTAGE_PAYMENT>60</PERCENTAGE_PAYMENT> <INSTALLMENT>Final Payment</INSTALLMENT> <EFFECTIVE_DATE>2019-04-18</EFFECTIVE_DATE> <TERM>IMMEDIATE</TERM> <SCHEDULE_PRICE>11960332.8</SCHEDULE_PRICE> <MAINTENANCE_PRICE>0</MAINTENANCE_PRICE> </CAMPAIGN_LINE> <CAMPAIGN_LINE> <PLAN_TYPE>Maintenance Schedule</PLAN_TYPE> <SEQUENCE_NUM>3</SEQUENCE_NUM> <PERCENTAGE_PAYMENT>5</PERCENTAGE_PAYMENT> <INSTALLMENT>INSTALLMENT 3</INSTALLMENT> <EFFECTIVE_DATE>2019-02-01</EFFECTIVE_DATE> <TERM>IMMEDIATE</TERM> <SCHEDULE_PRICE>0</SCHEDULE_PRICE> <MAINTENANCE_PRICE>996694.4</MAINTENANCE_PRICE> </CAMPAIGN_LINE> <CAMPAIGN_LINE> <PLAN_TYPE>Maintenance Schedule</PLAN_TYPE> <SEQUENCE_NUM>2</SEQUENCE_NUM> <PERCENTAGE_PAYMENT>5</PERCENTAGE_PAYMENT> <INSTALLMENT>INSTALLMENT 2</INSTALLMENT> <EFFECTIVE_DATE>2018-12-01</EFFECTIVE_DATE> <TERM>IMMEDIATE</TERM> <SCHEDULE_PRICE>0</SCHEDULE_PRICE> <MAINTENANCE_PRICE>996694.4</MAINTENANCE_PRICE> </CAMPAIGN_LINE> <CAMPAIGN_LINE> <PLAN_TYPE>Payment Schedule</PLAN_TYPE> <SEQUENCE_NUM>3</SEQUENCE_NUM> <PERCENTAGE_PAYMENT>20</PERCENTAGE_PAYMENT> <INSTALLMENT>INSTALLMENT 2</INSTALLMENT> <EFFECTIVE_DATE>2018-09-26</EFFECTIVE_DATE> <TERM>IMMEDIATE</TERM> <SCHEDULE_PRICE>3986777.6</SCHEDULE_PRICE> <MAINTENANCE_PRICE>0</MAINTENANCE_PRICE> </CAMPAIGN_LINE> <CAMPAIGN_LINE> <PLAN_TYPE>Payment Schedule</PLAN_TYPE> <SEQUENCE_NUM>2</SEQUENCE_NUM> <PERCENTAGE_PAYMENT>10</PERCENTAGE_PAYMENT> <INSTALLMENT>INSTALLMENT 1</INSTALLMENT> <EFFECTIVE_DATE>2018-06-18</EFFECTIVE_DATE> <TERM>IMMEDIATE</TERM> <SCHEDULE_PRICE>1993388.8</SCHEDULE_PRICE> <MAINTENANCE_PRICE>0</MAINTENANCE_PRICE> </CAMPAIGN_LINE> <CAMPAIGN_LINE> <PLAN_TYPE>Maintenance Schedule</PLAN_TYPE> <SEQUENCE_NUM>1</SEQUENCE_NUM> <PERCENTAGE_PAYMENT>5</PERCENTAGE_PAYMENT> <INSTALLMENT>INSTALLMENT 1</INSTALLMENT> <EFFECTIVE_DATE>2018-05-01</EFFECTIVE_DATE> <TERM>IMMEDIATE</TERM> <SCHEDULE_PRICE>0</SCHEDULE_PRICE> <MAINTENANCE_PRICE>996694.4</MAINTENANCE_PRICE> </CAMPAIGN_LINE> </CAMPAIGN_LINES> </CAMPAIGN_HDR> </AVAILABLE_CAMPAIGNS> </P_RESULT_XML>';
                        objresposne.ResultXML = strXML;
                    }
                    System.debug('@@LocationId='+location_id);
                    System.debug('******objresposne'+objresposne);
                    if(objresposne.Status == 'SUCCESS'  &&  objresposne.ErrorMessage=='Payment Terms sent sucessfully.'&& objresposne.ResultXML != ''){
                        isuccessCount = isuccessCount+1;
                        system.debug('*******objresposne.ResultXML'+objresposne.ResultXML);
                        if(objresposne.ResultXML!=null && objresposne.ResultXML!='')
                            lstResponsewrapdata = Cm_PaymentTerms.parsedata(objresposne.ResultXML);
                        if(lstResponsewrapdata!=null && lstResponsewrapdata.size() >0){
                            system.debug('******lstResponsewrapdata'+lstResponsewrapdata);
                            PropertyUnitwrap  objwrap = new PropertyUnitwrap();
                            objwrap.strUnitName = location_code;
                            objwrap.opportunityPropertyId = objPro.Id;
                            objwrap.HeaderId = lstResponsewrapdata[0].CAMPAIGN_ID;
                            //Adeel - adding campaing wrap here...
                            objwrap.lstCampaignWrap = new list<CampaignWrap>();
                            objwrap.lstCampaignWrap = lstResponsewrapdata;
                            for(CampaignWrap cw : objwrap.lstCampaignWrap){
                                cw.selectedTerm = false;    // Change by 4C Test Team
                                if(opPropertyNameToCampaignIdMap.get(location_code) != null && opPropertyNameToCampaignIdMap.get(location_code) == cw.CAMPAIGN_ID){
                                    cw.selectedTerm = true;
                                }
                            }
                            lstPropertyUnitwrap.add(objwrap);
                            mpValues.put(objPro.cm_Property_Inventory__c, objwrap.HeaderId);
                        }
                    }else{
                        iErrorCount = iErrorCount+1;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info,objresposne.ErrorMessage));
                    }
                    
                    //Service_Logs__c objlog = CM_EmaarUtils.CreateLOg('View Payment Terms',stropporid,objPro.id,objresposne.ErrorMessage,objresposne.status, objresposne.ResultXML,'','',location_id,'','','','',org_id,strParentId);
                    //objlog.request__C = Requestbody;
                    //lstservlog.add(objlog);
                }catch(exception ex){
                    if(strParentId == ''){
                        //strParentId = CM_EmaarUtils.createParentLog(stropporid,'View Payment Terms');
                    }
                    system.debug('*******Exception'+ex.getMessage());
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error,ex.getMessage()));
                    //Service_Logs__c objlog = CM_EmaarUtils.CreateLOg('View Payment Terms',stropporid,objPro.id,ex.getMessage(),'','','','',location_id,'','','','',org_id,strParentId);
                    //objlog.request__C = Requestbody;
                    //lstservlog.add(objlog);
                }
            }
        }

        /*
        if(lstPropertyUnitwrap!=null && lstPropertyUnitwrap.size() == 0 && iErrorCount == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error,'No Payment Terms for the selected Property Inventory.'));
        }else{
            Cm_PaymentTerms.updateHeaderIDonINventory(mpValues);
        }
        if(strParentId == ''){
            strParentId = CM_EmaarUtils.createParentLog(stropporid,'View Payment Terms');
        }
        for(Service_Logs__c obj:lstservlog){
            obj.parent_log__C = strParentId;
            
        }
        if(lstservlog.size() > 0){
            insert lstservlog; 
            CM_EmaarUtils.updateLog(strParentId,iTotal,isuccessCount,iErrorCount);        
        }
        */
        
    }
    
    public static void updateHeaderIDonINventory(map<string,string> inventoryMap){
        system.debug('****inventoryMap***'+inventoryMap);
        list<Property_Inventory__c> lstdata = new list<Property_Inventory__c>();
        for(string invId :inventoryMap.keyset()){
            Property_Inventory__c objinv = new Property_Inventory__c(id=invId);
            objinv.payment_Header_id__c = inventoryMap.get(invId);
            lstdata.add(objinv);
        }     
        system.debug('********lstData'+lstdata);
        if(!lstData.isEmpty())
            update lstData;
    }
    
    public static list<CampaignWrap> parsedata(string ResultXML){
        list<Cm_PaymentTerms.CampaignWrap> lstData = new list<Cm_PaymentTerms.CampaignWrap>();
        Dom.Document doc = new Dom.Document();
        doc.load(ResultXML);
        System.debug('@@ResultXML='+ResultXML);
        Dom.XMLNode ordDtls = doc.getRootElement();
        
        for(Dom.XMLNode child1: ordDtls.getChildElements()){
            for(Dom.XMLNode child2: child1.getChildElements()){
                Cm_PaymentTerms.CampaignWrap camp = new Cm_PaymentTerms.CampaignWrap();
                camp.CAMPAIGN_ID = child2.getChildElement('CAMPAIGN_ID',null)!=null ? child2.getChildElement('CAMPAIGN_ID',null).getText() : '';
                camp.CAMPAIGN_NAME = child2.getChildElement('CAMPAIGN_NAME',null)!=null ? child2.getChildElement('CAMPAIGN_NAME',null).getText() : '';
                camp.CAMPAIGN_DESC = child2.getChildElement('CAMPAIGN_DESC',null)!=null ? child2.getChildElement('CAMPAIGN_DESC',null).getText() : '';
                camp.CAMPAIGN_TYPE = child2.getChildElement('CAMPAIGN_TYPE',null)!=null ? child2.getChildElement('CAMPAIGN_TYPE', null).getText() : '';
                camp.CAMPAIGN_PRICE = child2.getChildElement('CAMPAIGN_PRICE', null) != null ? Decimal.valueOf(child2.getChildElement('CAMPAIGN_PRICE', null).getText()) : 0;
                camp.CAMPAIGN_MAP_ID = child2.getChildElement('CAMPAIGN_MAP_ID', null).getText();
                
                LIST<Cm_PaymentTerms.Responsewrap> res = new LIST<Cm_PaymentTerms.Responsewrap>();
                
                for(Dom.XMLNode child3: child2.getChildElements()){
                    for(Dom.XMLNode child4: child3.getChildElements()){
                        Cm_PaymentTerms.Responsewrap objres = new Cm_PaymentTerms.Responsewrap(); 
                        if( child4.getChildElement('EFFECTIVE_DATE',null)!=null)
                            objres.EFFECTIVE_DATE = child4.getChildElement('EFFECTIVE_DATE',null).getText();
                        if( child4.getChildElement('TERM',null)!=null)
                            objres.TERM = child4.getChildElement('TERM',null).getText();
                        if( child4.getChildElement('INSTALLMENT',null)!=null)
                            objres.INSTALLMENT = child4.getChildElement('INSTALLMENT',null).getText();
                        if( child4.getChildElement('PERCENTAGE_PAYMENT',null)!=null)
                            objres.PERCENTAGE_PAYMENT = child4.getChildElement('PERCENTAGE_PAYMENT',null).getText();
                        if( child4.getChildElement('SEQUENCE_NUM',null)!=null)
                            objres.SEQUENCE_NUM = Decimal.valueOf(child4.getChildElement('SEQUENCE_NUM',null).getText());
                        if( child4.getChildElement('SCHEDULE_PRICE',null)!=null)
                            objres.SCHEDULE_PRICE = Decimal.valueOf(child4.getChildElement('SCHEDULE_PRICE',null).getText());
                        if( child4.getChildElement('MAINTENANCE_PRICE',null)!=null)
                            objres.MAINTENANCE_PRICE = Decimal.valueOf(child4.getChildElement('MAINTENANCE_PRICE',null).getText());
                        res.add(objres);
                    }
                }
                res.sort();
                camp.lstResponsewrap = res;
                lstdata.add(camp);
            }
        }
        system.debug('***lstData'+lstData);
        return lstData;
    }
    
    public class PropertyUnitwrap{
        public string strUnitName{get;set;}
        public string HeaderId{get;set;}
        public String community{get;set;}
        public Id opportunityPropertyId {get; set;}
        public String campaignType {get; set;}
        public Decimal campaignPrice {get; set;}
        public list<CampaignWrap> lstCampaignWrap{get;set;}
    }
    
    public class CampaignWrap{
        public string CAMPAIGN_ID {get; set;}
        public string CAMPAIGN_NAME {get; set;}
        public string CAMPAIGN_DESC {get; set;}
        public string CAMPAIGN_TYPE {get; set;}
        public string CAMPAIGN_MAP_ID {get; set;}   
        public Decimal CAMPAIGN_PRICE {get; set;}
        public Boolean selectedTerm {get;set;}
        public list<Responsewrap> lstResponsewrap{get;set;}
    }
    
    public class Responsewrap implements Comparable{
        public string EFFECTIVE_DATE {get; set;}
        public string TERM {get; set;}
        public string INSTALLMENT {get; set;}
        public string PERCENTAGE_PAYMENT {get; set;}
        public decimal SEQUENCE_NUM {get; set;}
        public decimal SCHEDULE_PRICE {get; set;}
        public decimal MAINTENANCE_PRICE {get; set;}
        public Integer compareTo(Object o)
        {
            Responsewrap compareResponsewrap = (Responsewrap)(o);
            
            if (this.EFFECTIVE_DATE > compareResponsewrap.EFFECTIVE_DATE) {
                return 1;
            }
            return -1;
        }
    }
    
    //method to populate the selected campaign id and campaign map id on opportunity
    public pagereference submitTermSelection(){   
        
        //insert the payment term record values
        List<String> unitNameList = new List<String>();
        for(PropertyUnitwrap pwrap : lstPropertyUnitwrap){
            unitNameList.add(pwrap.strUnitName);
        }
        
        List<Opportunity_Property__c> offerList = [select id,Campaign_Id__c,Campaign_Map_Id__c,cm_Inventory_Location_Code__c, cm_Opportunity__c
                                                   from Opportunity_Property__c where cm_Opportunity__c =: stropporid and cm_Inventory_Location_Code__c in: unitNameList];
        
        List<Payment_Terms__c> paymentTermExistingList = [select id,Opportunity_Property__c from Payment_Terms__c where
                                                          Opportunity_Property__c in: offerList ];
        
        Map<Id,List<Payment_Terms__c>> offerPaymentTermMap = new Map<Id,List<Payment_Terms__c>>();  
        if(paymentTermExistingList.size() > 0){              
            for(Payment_Terms__c payTerm : paymentTermExistingList){
                if(offerPaymentTermMap.containsKey(payTerm.Opportunity_Property__c)){
                    offerPaymentTermMap.get(payTerm.Opportunity_Property__c).add(payTerm);
                }
                else{
                    offerPaymentTermMap.put(payTerm.Opportunity_Property__c, new List<Payment_Terms__c>{payTerm});
                }
            }
        }
        
        Map<String,Opportunity_Property__c> propertyOppMap = new Map<String,Opportunity_Property__c>();
        
        for(Opportunity_Property__c oProperty : offerList){
            propertyOppMap.put(oProperty.cm_Inventory_Location_Code__c, oProperty);
        }
        
        List<Opportunity_Property__c> opportunityPropertyList = new List<Opportunity_Property__c>();
        List<Payment_Terms__c> paymentTermList = new List<Payment_Terms__c>();
        List<Payment_Terms__c> paymentTermsToDeleteList = new List<Payment_Terms__c>();
        
        for(PropertyUnitwrap pwrap : lstPropertyUnitwrap){
            for(CampaignWrap cwrap : pwrap.lstCampaignWrap){
                system.debug('********select value campaign*******'+pwrap.lstCampaignWrap);
                if(cwrap.selectedTerm){
                    system.debug('**** see the selected value **** '+cwrap.CAMPAIGN_NAME+' and '+pwrap.strUnitName);
                    Opportunity_Property__c oppPropertytoUpdate = propertyOppMap.get(pwrap.strUnitName);
                    List<Payment_Terms__c> paymentTermFetchedList = new List<Payment_Terms__c>();
                    
                    if(offerPaymentTermMap.get(oppPropertytoUpdate.Id) <> null){
                        paymentTermFetchedList = offerPaymentTermMap.get(oppPropertytoUpdate.Id);
                        paymentTermsToDeleteList.addAll(paymentTermFetchedList);
                    }
                    oppPropertytoUpdate.Campaign_Id__c = cwrap.CAMPAIGN_ID;
                    oppPropertytoUpdate.Campaign_Map_Id__c = cwrap.CAMPAIGN_MAP_ID;
                    //Update the booking price
                    oppPropertytoUpdate.Booking_Price__c = cwrap.CAMPAIGN_PRICE;
                    oppPropertytoUpdate.Campaign_Price__c = cwrap.CAMPAIGN_PRICE;
                    oppPropertytoUpdate.Campaign_Type__c = cwrap.CAMPAIGN_TYPE;
                    oppPropertytoUpdate.Original_Campaign_Price__c = cwrap.CAMPAIGN_PRICE;
                    
                    Integer maintenanceTermsCount = 0;
                    Decimal maintenanceTermsTotal = 0;
                    Date maxTermsDate = Date.newInstance(1950, 1, 1);
                    for(Responsewrap resWrap : cwrap.lstResponsewrap){
                        Payment_Terms__c paymentTerm = new Payment_Terms__c();
                        paymentTerm.Opportunity_Property__c = oppPropertytoUpdate.Id;
                        paymentTerm.Name = cwrap.CAMPAIGN_TYPE;
                        paymentTerm.Term__c = resWrap.TERM;
                        paymentTerm.cm_Term_Date__c = resWrap.EFFECTIVE_DATE;
                        Date tempTermDate = Date.valueOf(resWrap.EFFECTIVE_DATE);
                        if(tempTermDate > maxTermsDate)
                            maxTermsDate = tempTermDate;
                        paymentTerm.Location_Code__c = pwrap.strUnitName;
                        paymentTerm.cm_Net_Percent__c = resWrap.PERCENTAGE_PAYMENT;
                        paymentTerm.cm_Schedule_Type__c = resWrap.INSTALLMENT;
                        paymentTerm.Installment__c = resWrap.SEQUENCE_NUM;
                        paymentTerm.Installment_Amount__c = resWrap.SCHEDULE_PRICE;
                        paymentTerm.Maintnance_Price__c = resWrap.MAINTENANCE_PRICE;
                        if(paymentTerm.Maintnance_Price__c != null && paymentTerm.Maintnance_Price__c > 0){
                            //maintenance installment
                            maintenanceTermsCount ++;
                            maintenanceTermsTotal += paymentTerm.Maintnance_Price__c;
                        }
                        paymentTermList.add(paymentTerm);
                    }
                    oppPropertytoUpdate.Original_Number_of_Terms__c = paymentTermList.size();
                    oppPropertytoUpdate.Total_Maintenance_Fee__c = maintenanceTermsTotal;
                    oppPropertytoUpdate.Number_of_Maintenance_Terms__c = maintenanceTermsCount;
                    oppPropertytoUpdate.Max_Terms_Date__c = maxTermsDate;
                    opportunityPropertyList.add(oppPropertytoUpdate);
                    
                }
            }
        }
        
        if(opportunityPropertyList.size() > 0){
            update opportunityPropertyList;
        }
        
        if(paymentTermList.size() > 0){
            insert paymentTermList;
        }
        
        if(paymentTermsToDeleteList.size() > 0){
            delete paymentTermsToDeleteList;
        }
        PageReference redirecttoOpp = new PageReference('/' + oppId);
        return redirecttoOpp;
    }
    
}