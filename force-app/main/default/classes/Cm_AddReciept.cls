global class Cm_AddReciept {
    public Reciepts__c objReciept{get;set;}
    public list<Reciepts__c> lstReciepts {get;set;}
    public string opporId = '';
    public integer ImaxCount = 0;
    public integer IExtCount = 0;
    public string selAccId{get;set;}
    public boolean blncheck = false;
    public string strOpporId = '';
    public string strParentId ='';
    public string RecieptMethod{get;set;}
    public List<SelectOption> lstRecieptPaymentMethods{get;set;}
    public string selCurrencyCode{get; set;}
    public string exchangeRate{get; set;}
    public map<string,double> CurrencyRateMap = new map<string,double>();
    
    public List<SelectOption>collectionCenters{get; set;}
    public string selCenter{get; set;}
    public map<string,string> mpCenters = new Map<String, string>();
    
    public void fetchData(){
      if(selCurrencyCode != 'AED'){
         objReciept.Exchange_rate__c = CurrencyRateMap.get(selCurrencyCode);
      }
    }
    public Cm_AddReciept(ApexPages.StandardController controller) {
        RecieptMethod = '';
        lstRecieptPaymentMethods = new List<SelectOption>();
        collectionCenters = new List<SelectOption>();
        objReciept = new Reciepts__c();
        lstReciepts = new list<Reciepts__c>();
        //objReciept.Currency__c = 'AED';
        objReciept.Reciept_Date__c = system.today();
        objReciept.Exchange_Rate__c = 1.00;
        //objReciept.CurrencyISOCode = 'AED';
        opporId = Apexpages.currentPage().getParameters().get('Id');
        if(opporId!=null && opporId!=''){
            list<Opportunity_Property__c> lst = [select id,cm_Opportunity__c,Building__c,cm_Property_Name__c from Opportunity_Property__c where id=:opporId];
            if(lst!=null && lst.size() >0){
                strOpporId = lst[0].cm_Opportunity__c;
                PrepareRecieptOptions(lst[0].cm_Property_Name__c,lst[0].Building__c);
            }
        }
        
        list<CurrencyType> CurrencyTypeList = new list<CurrencyType>([select id,ConversionRate, IsActive, DecimalPlaces,IsoCode,IsCorporate from CurrencyType]);
        
        string ActiveCurrency = '';
        for(CurrencyType cur : CurrencyTypeList){
            if(cur.IsCorporate){
                ActiveCurrency = cur.IsoCode;
            }
            else{
                CurrencyRateMap.put(cur.IsoCode,cur.ConversionRate);
            }
        }
        
        List<Collection_center__c> lstCenters = [Select id, name, Description__c from Collection_center__c];
        collectionCenters.add(new SelectOption('', '-Select a center-'));
        for(Collection_center__c cc: lstCenters){
            collectionCenters.add(new SelectOption(cc.name, cc.Description__c));
            mpCenters.put(cc.name, cc.Description__c);
        }
        collectionCenters.add(new SelectOption('', '-Select a center-')); //Adeel, Adding empty record to avoid exception
    
        preparedata(); 
    }
    public Cm_AddReciept(){}
    public void PrepareRecieptOptions(string strProperty,string strbuilding){
        system.debug('***strProperty'+strProperty);
        system.debug('***strbuilding'+strbuilding);
        lstRecieptPaymentMethods.add(new SelectOption('','--None--'));
        list<Payment_Methods__c> lst = [select id,Property__c,Building__c,Receipt_Method__c from Payment_Methods__c where Building__c=:strbuilding ];
        for(Payment_Methods__c objPayM : lst){
           string value = objPayM.Receipt_Method__c.escapeHtml3();
           lstRecieptPaymentMethods.add(new SelectOption(value ,value ));
        }
    }
    
    public void preparedata(){
        opporId = Apexpages.currentPage().getParameters().get('Id');
        list<Opportunity> lstOpp = [select id,CampaignId from Opportunity where id=:opporId];
        if(lstOpp!=null && lstOpp.size() >0 && lstOpp[0].CampaignId!=null){
                Campaign objcampaign = CM_EmaarUtils.GetCampaignAttributes(lstOpp[0].CampaignId);
                if(objcampaign!=null && objcampaign.id!=null && objcampaign.No_Of_Receipts__c!=null){
                    ImaxCount = integer.valueof(objcampaign.No_Of_Receipts__c);
                    blncheck = true;
                }
        }
        lstReciepts = [select id,name,cm_Opportunity_Property__c,cm_Location_ID__c, Payment_Mode__c,Cheque_Number__c,cm_Location_Code__c, Amount__c,Comments__c,Currency__c,Exchange_Rate__c,Installment_Details__c,cm_Paid_by__c,Purpose__c,Reciept_Date__c,Reciept_Number__c,Reciept_Payment_Mode__c from Reciepts__c where cm_Opportunity_Property__c=:opporId];
        if(lstReciepts!=null && lstReciepts.size() >0){
            IExtCount = lstReciepts.size();
        }
       
    }
    
    public void Adddata(){
        try{
            integer iTotal = IExtCount+1;
            if(iTotal >  ImaxCount && blncheck == true){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error,'You cannot add more than '+ImaxCount+' receipts to this campaign.'));
            }else{
                if(objReciept.Reciept_Number__c!=null){
                    //objReciept.Paid_by__c = selAccId;
                    //objReciept.Currency__c='AED';
                    objReciept.cm_Opportunity_Property__c = opporId;
                    objReciept.Reciept_Payment_Mode__c = RecieptMethod;
                    if(selCenter != null)
                        objReciept.Collection_center__c = selcenter;
                    
                    if(objReciept.Gl_date__c != null)
                        objReciept.Maturity_Date__c = string.valueOf(objReciept.Gl_date__c);
                        
                        
                    System.debug('>>>>>>>>>>>>>>>>>'+objReciept.Maturity_Date__c+'>>>>>>>>>>>>>>>>>>'+objReciept.Gl_date__c);
                    emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objResponse = new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
                    if(!Test.isRunningTest()){
                         objResponse = EmaarWebServiceUtils.executePerformConcurrentAction_GETRECIEPT(objReciept, opporId);
                    }else{
                        objResponse.status = 'SUCCESS';
                        string strXML =  '<P_RESULT_XML><XX_SALES_LAUNCH xmlns=""><XX_RECEIPT_DATA_T><XX_RECEIPT_DATA_O><RECEIPT_BATCH_ID>5241</RECEIPT_BATCH_ID><ORG_ID>81</ORG_ID><CASH_RECEIPT_ID>19152676</CASH_RECEIPT_ID><RECEIPT_NUMBER>1234</RECEIPT_NUMBER><ORG_NAME>Emaar Development PJSC</ORG_NAME><CURRENCY_CODE>AED</CURRENCY_CODE><AMOUNT>1234</AMOUNT><RECEIPT_DATE>2016-05-11</RECEIPT_DATE><CUSTOMER_NUMBER>231909</CUSTOMER_NUMBER><DOCUMENT_NUMBER>4038329</DOCUMENT_NUMBER><AMOUNT_IN_WORDS>Thousand two hundred thirty-four Dirhams And 00 Fils</AMOUNT_IN_WORDS><MODE_OF_PAYMENT>Cheque</MODE_OF_PAYMENT><MATURITY_DATE>2016-05-11</MATURITY_DATE><FINANCIER_NAME>NIL</FINANCIER_NAME><COMMENTS>asdf</COMMENTS><COMPANY_NAME>Emaars</COMPANY_NAME><PO_BOX>PO Box No: 9440, Downtown, Dubai,</PO_BOX><COUNTRY>U.A.E</COUNTRY><TELEPHONE>+971-4-3673333</TELEPHONE><FAX>+971-4-3673793</FAX><CREATED_BY_USER>OnlineSales</CREATED_BY_USER></XX_RECEIPT_DATA_O></XX_RECEIPT_DATA_T></XX_SALES_LAUNCH></P_RESULT_XML>';
                        objResponse.resultXML = strXML;
                    }
                    if(objResponse.status=='ERROR'){
                        ApexPages.addMEssage(new ApexPages.Message(ApexPages.Severity.Fatal,objResponse.ErrorMessage));
                    }
                    else{
                        system.debug('***objResponse'+objResponse.resultXML);
                        System.debug('>>>>>>middleBefooe>>>>>>>>>>>'+objReciept.Maturity_Date__c+'>>>>>>>>>>>>>>>>>>'+objReciept.Gl_date__c);
                        ParseRecieptXML(objResponse.resultXML);
                        System.debug('>>>>>>middle afte>>>>>>>>>>>'+objReciept.Maturity_Date__c+'>>>>>>>>>>>>>>>>>>'+objReciept.Gl_date__c);
                        objReciept.Opportunity__c = strOpporId;
                        objReciept.Received_by__c = userinfo.getUserId();
                        objReciept.CurrencyISOCode = objReciept.Currency__c;
                        if(selCenter != null)
                            objReciept.Collection_center__c = mpCenters.get(selcenter);
                        System.debug('>>>>>>>After>>>>>>>>>>'+objReciept.Maturity_Date__c+'>>>>>>>>>>>>>>>>>>'+objReciept.Gl_date__c);
                        insert objReciept;
                        ApexPages.addMEssage(new ApexPages.Message(ApexPages.Severity.info,'Receipt added successfully.'));
                        objReciept = new Reciepts__c();
                        preparedata();
                    } 
                }
                
            }
        }catch(exception ex){
            system.debug('****Exception'+ex.getMessage());
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error,ex.getMessage()+'-'+ex.getLineNumber()));
        }
    }
    
    public void ParseRecieptXML(string XMLData){

        //string RECEIPT_BATCH_ID = CM_EmaarUtils.getValueFromXMLString(XMLData,'RECEIPT_BATCH_ID');
        //string ORG_ID= CM_EmaarUtils.getValueFromXMLString(XMLData,'ORG_ID');
        objReciept.Cash_Receipt_Id__c = CM_EmaarUtils.getValueFromXMLString(XMLData,'CASH_RECEIPT_ID');
        //objReciept.Reciept_Number__c = CM_EmaarUtils.getValueFromXMLString(XMLData,'RECEIPT_NUMBER');
        //string ORG_NAME = CM_EmaarUtils.getValueFromXMLString(XMLData,'ORG_NAME');
        //string CURRENCY_CODE = CM_EmaarUtils.getValueFromXMLString(XMLData,'CURRENCY_CODE');
        //string AMOUNT = CM_EmaarUtils.getValueFromXMLString(XMLData,'AMOUNT');
        //string RECEIPT_DATE = CM_EmaarUtils.getValueFromXMLString(XMLData,'RECEIPT_DATE');
        objReciept.Customer_Number__c = CM_EmaarUtils.getValueFromXMLString(XMLData,'CUSTOMER_NUMBER');
        objReciept.Document_Number__c = CM_EmaarUtils.getValueFromXMLString(XMLData,'DOCUMENT_NUMBER');
        objReciept.Amount_in_Words__c = CM_EmaarUtils.getValueFromXMLString(XMLData,'AMOUNT_IN_WORDS');
        objReciept.Mode_Of_Payment__c = CM_EmaarUtils.getValueFromXMLString(XMLData,'MODE_OF_PAYMENT');
        //objReciept.Maturity_Date__c = CM_EmaarUtils.getValueFromXMLString(XMLData,'MATURITY_DATE');
        //string FINANCIER_NAME = CM_EmaarUtils.getValueFromXMLString(XMLData,'FINANCIER_NAME');
        //string COMMENTS = CM_EmaarUtils.getValueFromXMLString(XMLData,'COMMENTS');
        objReciept.Company_Name__c = CM_EmaarUtils.getValueFromXMLString(XMLData,'COMPANY_NAME');
        objReciept.PO_Box__c = CM_EmaarUtils.getValueFromXMLString(XMLData,'PO_BOX');
        objReciept.Country__c = CM_EmaarUtils.getValueFromXMLString(XMLData,'COUNTRY');
        objReciept.Telephone__c = CM_EmaarUtils.getValueFromXMLString(XMLData,'TELEPHONE');
        objReciept.Fax__c = CM_EmaarUtils.getValueFromXMLString(XMLData,'FAX');
        //string CREATED_BY_USER = CM_EmaarUtils.getValueFromXMLString(XMLData,'CREATED_BY_USER');
    }
    public pagereference actionDone(){
        return new pagereference('/'+opporId);
    }
    @future (callout = true)
    webservice static void ResendReciept(string recId,string OppPropID){
        string strMessage ='';
        try{
            emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objResponse = new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
            string strquery = CM_EmaarUtils.getCreatableFieldsSOQL('Reciepts__c');
            strquery = strquery+' where id=:recId';
            Reciepts__c objReciept = Database.query(strquery);
            objResponse = EmaarWebServiceUtils.executePerformConcurrentAction_GETRECIEPT(objReciept, OppPropID);
            system.debug('***********objResponse.status'+objResponse.status);
            if(objResponse.status=='ERROR'){
                strMessage = objResponse.ErrorMessage;
            }
            else{
                system.debug('***objResponse'+objResponse.resultXML);
                objReciept.Cash_Receipt_Id__c = CM_EmaarUtils.getValueFromXMLString(objResponse.resultXML,'CASH_RECEIPT_ID');
                objReciept.Customer_Number__c = CM_EmaarUtils.getValueFromXMLString(objResponse.resultXML,'CUSTOMER_NUMBER');
                objReciept.Document_Number__c = CM_EmaarUtils.getValueFromXMLString(objResponse.resultXML,'DOCUMENT_NUMBER');
                objReciept.Amount_in_Words__c = CM_EmaarUtils.getValueFromXMLString(objResponse.resultXML,'AMOUNT_IN_WORDS');
                objReciept.Mode_Of_Payment__c = CM_EmaarUtils.getValueFromXMLString(objResponse.resultXML,'MODE_OF_PAYMENT');
                objReciept.Company_Name__c = CM_EmaarUtils.getValueFromXMLString(objResponse.resultXML,'COMPANY_NAME');
                objReciept.PO_Box__c = CM_EmaarUtils.getValueFromXMLString(objResponse.resultXML,'PO_BOX');
                objReciept.Country__c = CM_EmaarUtils.getValueFromXMLString(objResponse.resultXML,'COUNTRY');
                objReciept.Telephone__c = CM_EmaarUtils.getValueFromXMLString(objResponse.resultXML,'TELEPHONE');
                objReciept.Fax__c = CM_EmaarUtils.getValueFromXMLString(objResponse.resultXML,'FAX');
                update objReciept;
                strMessage = 'success';
            } 
        }catch(exception ex){
            strMessage = ex.getMessage();
            system.debug('***********EXCEPTION'+ex.getMessage());
        }
        //return '';
    }
    webservice static string ResendReciept_button(string recId,string OppPropID){
        string strMessage ='';
        try{
            emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objResponse = new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
            string strquery = CM_EmaarUtils.getCreatableFieldsSOQL('Reciepts__c');
            strquery = strquery+' where id=:recId';
            Reciepts__c objReciept = Database.query(strquery);
            objResponse = EmaarWebServiceUtils.executePerformConcurrentAction_GETRECIEPT(objReciept, OppPropID);
            system.debug('***********objResponse.status'+objResponse.status);
            if(objResponse.status=='ERROR'){
                strMessage = objResponse.ErrorMessage;
            }
            else{
                system.debug('***objResponse'+objResponse.resultXML);
                objReciept.Cash_Receipt_Id__c = CM_EmaarUtils.getValueFromXMLString(objResponse.resultXML,'CASH_RECEIPT_ID');
                objReciept.Customer_Number__c = CM_EmaarUtils.getValueFromXMLString(objResponse.resultXML,'CUSTOMER_NUMBER');
                objReciept.Document_Number__c = CM_EmaarUtils.getValueFromXMLString(objResponse.resultXML,'DOCUMENT_NUMBER');
                objReciept.Amount_in_Words__c = CM_EmaarUtils.getValueFromXMLString(objResponse.resultXML,'AMOUNT_IN_WORDS');
                objReciept.Mode_Of_Payment__c = CM_EmaarUtils.getValueFromXMLString(objResponse.resultXML,'MODE_OF_PAYMENT');
                objReciept.Company_Name__c = CM_EmaarUtils.getValueFromXMLString(objResponse.resultXML,'COMPANY_NAME');
                objReciept.PO_Box__c = CM_EmaarUtils.getValueFromXMLString(objResponse.resultXML,'PO_BOX');
                objReciept.Country__c = CM_EmaarUtils.getValueFromXMLString(objResponse.resultXML,'COUNTRY');
                objReciept.Telephone__c = CM_EmaarUtils.getValueFromXMLString(objResponse.resultXML,'TELEPHONE');
                objReciept.Fax__c = CM_EmaarUtils.getValueFromXMLString(objResponse.resultXML,'FAX');
                update objReciept;
                strMessage = 'success';
            } 
        }catch(exception ex){
            strMessage = ex.getMessage();
            system.debug('***********EXCEPTION'+ex.getMessage());
        }
        return strMessage;
    }
}