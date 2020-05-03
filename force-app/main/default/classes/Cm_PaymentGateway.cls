public class Cm_PaymentGateway {
   /*******************GLOBAL Declarations*************************/  
    public boolean firstStep{get;set;}
    public boolean secondStep{get;set;}
    public boolean thirdStep{get;set;}
    
    public string selPaymentMode{get;set;}
    public decimal dCash{get;set;}
    public string strCreditcardNumber{get;set;}
    public string strSelectedOption{get;set;}
    public string strMessage{get;set;}
    public string OppoId{get;set;}
    public string selChequeOption{get;set;}
    public string selChequeTypeOption{get;set;}
    public integer iCount{get;set;}
    public string strCollectDeposit{get;set;}
    
    public string strOrderEvent{get;set;}
    public string strOrderSource{get;set;}
    
    public boolean chequeException{get; set;}
    public boolean WTException{get; set;}
    
    public Account objpersonAccount{get;set;}
    public Account objbusinessAccount{get;set;}
    public Contact objContact{get;set;}
    public boolean blnPersonAccount{get;set;}
    public list<existingPropertyWrap> lstexistingPropertyWrap{get;set;}
    public boolean blnSkip = false;
    public string strParentId = '';
    public string salesOrderstatus {get;set;}
    public boolean BlnApproval {get;set;}
    public string ImaxTime{get;set;}
    public Map<string,string> mpValues = new Map<string,String>();   
    public string DaysTohold{get;set;}
    public Opportunity objOpportunity = new Opportunity();
    public integer minuteCount {get; set;}
    public string StrCCExceptionComments{get;set;}
    public string StrWTExceptionComments{get;set;}
    public string OppName{get;set;}
    public string chqDepositmethod{get;set;}
    
    public integer iPropMaxCount{get; set;}
    
/*******************************END**********************************************/   
    /*
        Constructor : Cm_PaymentGateway
        Description : Checking any special approvals pedings or not.
                      If pending stop the process
                      if not proceed to sales order creation
    */
    public Cm_PaymentGateway(){
         chequeException = false;
         StrCCExceptionComments ='';
         DaysTohold ='';
         firstStep = true;
         secondStep = false;
         thirdStep = false;
         ImaxTime = label.cm_PaymentPageTimer;
         objpersonAccount = new Account(); 
         objContact = new Contact();
         objbusinessAccount = new Account();
         lstexistingPropertyWrap = new list<existingPropertyWrap>();
         OppoId = ApexPages.currentPage().getParameters().get('id');
         objOpportunity =  [select id,Name,Property_Booked_Date__c,campaignId ,cm_Approval_Status__c,cm_Booking_timer__c,cm_Booking_Minute_Count__c,Order_Event__c,Order_Source__c,
                                     Property_Booked_Time__c,AccountId,cm_contact__C,cm_Party_Type__c,OwnerId,cm_Sales_Person__c from opportunity where id=:OppoId];
         
        if(objOpportunity!=null && objOpportunity.id!=null){
            OppName = objOpportunity.Name;
            if(objOpportunity.campaignId != null){
                Campaign objcampaign = CM_EmaarUtils.GetCampaignAttributes(objOpportunity.campaignId);
                if(objcampaign.id!=null && objcampaign.cm_No_of_properties_customers_can_buy__c!=null){
                    iPropMaxCount = integer.valueof(objcampaign.cm_No_of_properties_customers_can_buy__c);
                }
            }
            else{
                Map<String,cm_Administrator_Settings__c> mpSettings = cm_Administrator_Settings__c.getAll(); 
                if(mpSettings.containsKey('ADMIN') && mpSettings.get('ADMIN').Temp_Campaign_Property_Count__c!=null){
                    iPropMaxCount = integer.valueof(mpSettings.get('ADMIN').Temp_Campaign_Property_Count__c); 
                }
            }
        }
         if(objOpportunity.cm_Approval_status__c == 'Payment Processing'){
            thirdStep = true;
            firstStep = false;
         }
         
         string strApprovalCheck = CM_EmaarUtils.CheckInterimApprovals(OppoId);
         strOrderSource = 'Public';
         if(objOpportunity.campaignId != null){
           Campaign camp = [Select id,type from Campaign where id=:objOpportunity.campaignId];
           strOrderEvent =  camp.type.contains('Launch')?'Launch Dubai':'Tempo';
         }
         else
           strOrderEvent ='Tempo';
           
         
             if(strApprovalCheck != 'success'){
                 BlnApproval = false;
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Some of the special approvals are still pending. Please approve or reject them before proceeding.'));
             }
             else{
                 BlnApproval = true;
                 
                 if(objOpportunity!=null && objOpportunity.id !=null){
                         if(objOpportunity.Property_Booked_Time__c!=null && objOpportunity.Property_Booked_Time__c >0)
                           iCount =  integer.valueof(objOpportunity.Property_Booked_Time__c);
                         else
                           iCount = 0;
                         if(objOpportunity.cm_Booking_timer__c!=null)
                            minuteCount = Math.round(objOpportunity.cm_Booking_timer__c * 60);
                          
                         if(objOpportunity.cm_Approval_Status__c == 'Payment Processing')
                            if(objOpportunity.cm_Booking_Minute_Count__c != null)
                                minuteCount = math.round(objOpportunity.cm_Booking_Minute_Count__c);
                           
                         // TODO:Adeel Need to save the record type info into custom settings   
                         if(objOpportunity.cm_Party_Type__c!=null && objOpportunity.cm_Party_Type__c == 'EGY_PersonAccount' && objOpportunity.AccountId!=null){
                            blnPersonAccount = true;
                            objpersonAccount = [select id,cm_National_ID_Expiry_Date__pc,cm_Birthdate__pc,cm_Passport_Number__pc,BillingStreet,BillingState,BillingCountrycode,BillingCity,BillingStatecode,BillingCountry,
                                                 BillingPostalCode,cm_Resident_Of_UAE__pc,cm_National_ID_No__pc from Account Where id=:objOpportunity.AccountId];
                         }
                         else if(objOpportunity.cm_contact__C!=null){
                             blnPersonAccount = false;
                             objContact = [select id,cm_Birthdate__c,cm_National_ID_Expiry_Date__c,cm_Passport_Number__c,cm_Resident_Of_UAE__c,MailingStreet,MailingState,MailingStatecode,MailingCountry,
                                           MailingCountrycode,MailingPostalCode,MailingCity,cm_National_ID_No__c from contact where Id=:objOpportunity.cm_contact__C];
                             objbusinessAccount = [select id,BillingStreet,cm_National_ID_Expiry_Date__pc,BillingCountrycode,BillingCity,BillingStatecode,BillingState,BillingCountry,BillingPostalCode,
                                                   cm_Date_of_Incorporation__c,cm_Country_of_Incorporation__c,cm_Trade_License_Expiry_Date__c,cm_Trade_License_Number__c 
                                                   from Account where id=:objOpportunity.AccountId];
                         }
                         if(objOpportunity.Order_Event__c!=null){
                             strOrderEvent = objOpportunity.Order_Event__c;
                         }
                         if(objOpportunity.Order_Source__c!=null){
                             strOrderSource = objOpportunity.Order_Source__c;
                         }
                 }
                 System.debug('@@objOpportunity.cm_Party_Type__c'+objOpportunity.cm_Party_Type__c);
                 System.debug('@@objOpportunity.AccountId'+objOpportunity.AccountId);
                 System.debug('@@blnPersonAccount'+blnPersonAccount);
                 PrepareExistingProperties();
            }
    }
    /*
        Method Name :PrepareExistingProperties
        Description : Preparing selected properties for the Opportunities
    
    */
    public void PrepareExistingProperties(){
        set<id> setPackageIds = new set<id>();
        map<Id,id> mapProInv = new map<Id,id>();
        lstexistingPropertyWrap = new list<existingPropertyWrap>();
        OppoId = apexpages.currentPage().getParameters().get('id');
        system.debug('******OppoId'+OppoId);
        map<Id,Id> MapPropInvIds = new map <Id,Id>();
        set<id> setInvIds = new set<Id>();
        list<Opportunity_Property__c> lstOpporPro = [select id,Name,cm_Opportunity__c,cm_Property_Inventory__c from Opportunity_Property__c where cm_Opportunity__c=:OppoId];
        for(Opportunity_Property__c objOpppro:lstOpporPro){
            setInvIds.add(objOpppro.cm_Property_Inventory__c);
            MapPropInvIds.put(objOpppro.cm_Property_Inventory__c,objOpppro.id);
        }
        string strPacakgeRecId = getRecordTypeId('Property_Inventory__c','Package');
        string strQuery = 'Select Id,recordtype.name,Location_Code__c,Total_Area__c,Saleable_Leasable_Area__c,recordtypeId,Property_Status__c,cm_Inventory_Package__c, Name,UNIT__c, Type__c,Sales_Room__c,BUILDING__c,Unit_Model__c , PROPERTY_ID__c,Status_indicator__c, PROPERTY_Code__c, Property__c, Selling_price__c FROM Property_Inventory__c where Id IN:setInvIds and RecordTypeId!=:strPacakgeRecId order by CreatedDate';
        list<Property_Inventory__c> lstExistingData = database.query(strQuery);
        integer ival = 0;
        for(Property_Inventory__c objProInv:lstExistingData){
            if(objProInv.cm_Inventory_Package__c!=null){
                setPackageIds.add(objProInv.cm_Inventory_Package__c);
            }
            mapProInv.put(objProInv.id,objProInv.id);
            existingPropertyWrap objexisting = new existingPropertyWrap();
            objexisting.objexistingPro = new Property_Inventory__c();
            objexisting.objexistingPro = objProInv;
            objexisting.indexval = ival;
            objexisting.OpporPropID = MapPropInvIds.get(objProInv.id);
            ival = ival+1;
            lstexistingPropertyWrap.add(objexisting);
        }
    }
    /*
        Method Name :getRecordTypeId
        Description : This method is used to get the record Type.
    
    */
    public Id getRecordTypeId(String objectName, String recordName){
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();  
        Schema.DescribeSObjectResult d = gd.get(objectName).getDescribe();
        return(d.getRecordTypeInfosByName().get(recordName).getRecordTypeId()); 
    }
     /*
        Method Name :OrderEvenetOptions
        Description : This method used to prepare Order event picklist values
    
    */
    public List<SelectOption> getOrderEvenetOptions(){
    List<SelectOption> options = new List<SelectOption>();
    Schema.DescribeFieldResult fieldResult = Opportunity.Order_Event__c.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       for( Schema.PicklistEntry f : ple){
          options.add(new SelectOption(f.getLabel(), f.getValue()));
       }       
       return options;
    }
     /*
        Method Name : OrderSourceOptions
        Description : This method used to prepare Order source picklist values
    
    */
    public List<SelectOption> getOrderSourceOptions(){
    List<SelectOption> options = new List<SelectOption>();
    Schema.DescribeFieldResult fieldResult = Opportunity.Order_Source__c.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       for( Schema.PicklistEntry f : ple){
          options.add(new SelectOption(f.getLabel(), f.getValue()));
       }       
       return options;
    }
    /*************NEED TO REMOVE*********************/
    public List<SelectOption> getCollectDeposit() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('','--None--'));
        options.add(new SelectOption('Yes','Yes'));
        options.add(new SelectOption('No','No'));
        return options;
    }
    /**********************END***************************/
     /*
        Method Name : PaymentModes
        Description : This method used to prepare payment mode options
    
    */
    public List<SelectOption> getPaymentModes() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('','--None--'));
        options.add(new SelectOption('Cheque','Cheque'));
        options.add(new SelectOption('Wire Transfer','Wire Transfer'));
        return options;
    }
    
    
    
    /*
        Method Name : CreditCardOptions
        Description : This method used to prepare credit card options
    
    */
    
    public string selCreditCardOption{get; set;}
    /*
    public List<SelectOption> getCreditCardOptions() { 
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));
        options.add(new SelectOption('Auto-Debit Form','Auto-Debit Form'));
        options.add(new SelectOption('Online Payment Link','Online Payment Link'));
        options.add(new SelectOption('Credit Card Machine','Credit Card Machine'));
        return options;
    }
    */
    /*
        Method Name : ChequeOptions
        Description : This method used to prepare Cheque options
    */
    
    public boolean isException{get; set;}
    public boolean showCreditOptions{get; set;}
    public boolean showDepositOptions{get; set;}
    
    public boolean showExceptionComments{get; set;}
    
    public void fetchDepositdata(){
        if(selPaymentMode != null && selPaymentMode != ''){
            showDepositOptions = true;
            
            
            Depositoptions= new List<SelectOPtion>();
            Depositoptions.add(new SelectOption('','--None--'));
            if(selPaymentMode == 'Cheque'){
                Depositoptions.add(new SelectOption('Not Applicable','Not Applicable'));
                Depositoptions.add(new SelectOption('Cash','Cash'));
                Depositoptions.add(new SelectOption('Credit card','Credit card'));
            }
            else{
                Depositoptions.add(new SelectOption('Deposit Waiver','Deposit Waiver'));
                Depositoptions.add(new SelectOption('Cash','Cash'));
                Depositoptions.add(new SelectOption('Credit card','Credit card'));
            }
        }   
    }
    public boolean showCardOptions{get; set;}
    public void fetchCreditdata(){     
        showAmount = false;
        if(selDepositOption != null && selDepositOption != ''){
            if(selDepositOption== 'Not Applicable' || selDepositOption== 'Deposit Waiver'){
                 isException = true;   
                 showCreditOptions = false;       
            }
            else{
                showAmount = true;
                showCardOptions= false;   
                showCreditOptions = true;  
                CreditCardOptions = new List<SelectOption>();
                CreditCardOptions.add(new SelectOption('','--None--'));
                if(selDepositOption == 'Credit Card'){
                    CreditCardOptions.add(new SelectOption('Auto-Debit Form','Auto-Debit Form'));
                    CreditCardOptions.add(new SelectOption('Online Payment Link','Online Payment Link'));
                    CreditCardOptions.add(new SelectOption('Credit Card Machine','Credit Card Machine'));
                    showCardOptions= true;   
                }
            }
        }
        
    
    }
    
    
    
    
    
    
    public List<SelectOption> ChequeOptions{get; set;}     
    public List<SelectOption> Depositoptions{get; set;}
    public List<SelectOption> CreditCardOptions{get; set;}     
    
    public boolean showAmount{get; set;}
    
    /*************NEED TO REMOVE*********************/
    public string selDepositOption{get; set;}
    public List<SelectOption> getDepositoptions() { 
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));
        if(selPaymentMode == 'Cash'){
            options.add(new SelectOption('Not Applicable','Not Applicable'));
            options.add(new SelectOption('Cash','Cash'));
            options.add(new SelectOption('Credit card','Credit card'));
        }
        else{
            options.add(new SelectOption('Depoist Waiver','Depoist Waiver'));
            options.add(new SelectOption('Cash','Cash'));
            options.add(new SelectOption('Credit card','Credit card'));
        }
        return options;
    }
    public List<SelectOption> getChequeDepositoptions() { 
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));
        options.add(new SelectOption('Cash','Cash'));
        options.add(new SelectOption('Credit card','Credit card'));
        return options;
    }
    /**********************END***************************/
     /*
        Method Name : AmountOptions
        Description : This method used to prepare Amount options
    
    */
    public list<SelectOption> getAmountOptions(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(System.Label.Payment_Limit,System.Label.Payment_Limit));
        options.add(new SelectOption('20000','20000'));
        options.add(new SelectOption('10000','10000'));
        options.add(new SelectOption('Waiver','Waiver'));
        return options;
    }
    /*
        Method Name : ValidateData
        Description : In step 1 , we are validating the data in the fields.
                      if it is person Account , we are validating only person Account details.
                      if it is Corporate Account , we are validating, opportunity Contact and Account informtaion
    
    */
    public pagereference ValidateData(){
        
    
        string strApprovalCheck = CM_EmaarUtils.CheckInterimApprovals(OppoId);
        if(strApprovalCheck == 'success'){
        try{
                string strMessage ='';
                string BookedPrpmsg ='';
                boolean OwnbookcCheck ;
                /* Required field check****************/
                if(blnPersonAccount == true){
                      if(objpersonAccount.id !=null){
                         if(objpersonAccount.cm_Resident_Of_UAE__pc && (objpersonAccount.cm_National_ID_No__pc == null || objpersonAccount.cm_National_ID_Expiry_Date__pc == null)){
                             ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Fatal,'Please enter National ID No. and National ID Expiry Date for UAE residents.'));
                             return null;
                         }
                         else
                         update objpersonAccount;
                      }   
                      strMessage = CM_EmaarUtils.ValidateOpportunityfields(objpersonAccount.id);
                      if(strMessage == 'success'){
                      
                                 firstStep = false;
                                 secondStep = true;
                                 thirdStep = false;
                                if(strParentId ==''){
                                    Service_Logs__c parentlog = new Service_Logs__c();
                                    parentlog.Process_Name__c = 'Sales Order Creation';
                                    parentlog.Process_Time__c = system.now();
                                    parentlog.Log_type__c  = 'Process Started';
                                    parentlog.Opportunity__c = OppoId;
                                insert parentlog;
                                strParentId = parentlog.id;
                            }
                        }
                        else{
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,strMessage));
                            return null;
                        }
                }
                else{
                     if(objContact.id == null || Account.id ==null){
                         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please provide Contact/Account details on the Opportunity to proceed.'));
                         return null;
                     }else{
                         if(objContact.id!=null)
                            if(objContact.cm_Resident_Of_UAE__c && (objContact.cm_National_ID_No__c == null || objContact.cm_National_ID_Expiry_Date__c == null)){
                                ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Fatal,'Please enter National ID No. and National ID Expiry Date for UAE residents.'));
                                return null;
                            }
                            else
                            update objContact;
                         if(objbusinessAccount.id!=null)
                            update objbusinessAccount;
                         strMessage = CM_EmaarUtils.ValidateBusinessAccountFields(objbusinessAccount.id,OppoId);
                          if(strMessage == 'success'){
                                 firstStep = false;
                                 secondStep = true;
                                 thirdStep = false;
                                if(strParentId ==''){
                                    Service_Logs__c parentlog = new Service_Logs__c();
                                    parentlog.Process_Name__c = 'Sales Order Creation';
                                    parentlog.Process_Time__c = system.now();
                                    parentlog.Log_type__c  = 'Process Started';
                                    parentlog.Opportunity__c = OppoId;
                                    insert parentlog;
                                    strParentId = parentlog.id;
                                }
                            }else{
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,strMessage));
                            }
                     }
                }
             if(objOpportunity.cm_Approval_Status__c == 'Payment Processing')
            minuteCount = math.round(objOpportunity.cm_Booking_Minute_Count__c);
            }catch(exception ex){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,ex.getMessage()));
            }
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Unable to process the request. There are pending special approvals for this Opportunity.'));
        }
        return null;
    }
    /*
        Method Name :gotoStep1
        Description : this method is used to go to STEP1
    */
    public void gotoStep1(){
         firstStep = true;
         secondStep = false;
         thirdStep = false;
    }
     /*
        Method Name :createSalesOrder
        Description : This method used to create sales Order & insert Payment Terms for the Opportunity.
    */
    public void createSalesOrder(){
        // Create sales order actions 
        // 1. Getting payment terms for the PI
        // 2. Create sales Order call - update sales order & Party Id on the Opportunity Property
        // 3. Payment Header ID on the Property Inventory
        // 4. inserting payment terms 
        // 5. Property Inventory status to Booked & Property_Booked_Time__c on opportunity.
        // 6. Timer value to page.
        try{
            system.debug('***strOrderEvent***'+strOrderEvent);
            system.debug('***strOrderSource***'+strOrderSource);
            System.debug('>>>>>>>>>>>>mpValues>>>>>>>>>>>>'+mpValues);
            list<Payment_Terms__c> lstPTdata = GeneratePaymentTermsdata(OppoId); 
            System.debug('>>>>>>>>>>>>mpValues>>>>>>>>>>>>'+mpValues);
            string strstatus;
            if(Test.isRunningTest())
            	strstatus = 'success';
            else
                strstatus = EmaarBookingProcess.CreateParty_SalesOrder(OppoId,strParentId,strOrderSource,strOrderEvent,mpValues);            
                //strstatus = 'success';
            system.debug('Sales Order DONE*******************');
          // string strstatus = 'success';
            if(strstatus == 'success'){
                 firstStep = false;
                 secondStep = false;
                 thirdStep = true;
                 system.debug('********HEADER ID****update*******');
                 Cm_PaymentTerms.updateHeaderIDonINventory(mpValues);
                 system.debug('********HEADER ID****update**DONE*****');
                 if(lstPTdata!=null && lstPTdata.size() > 0 ){
                     list<Payment_Terms__c> lstPayTerms = [select id from Payment_Terms__c where cm_Property_Inventory__c IN:mpValues.keyset()];
                     delete lstPayTerms;
                     
                    insert lstPTdata;
                 }
                 string BookedPrpmsg =  CM_EmaarUtils.ApproveProperties(OppoId);
            }else{
                 string strMessage = 'Sales order creation failed for the following units :'+strstatus+'.Please try again .';
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,strMessage));
            } 
            if(objOpportunity!=null && objOpportunity.id!=null){
                 if(objOpportunity.Property_Booked_Time__c!=null && objOpportunity.Property_Booked_Time__c >0)
                   iCount =  integer.valueof(objOpportunity.Property_Booked_Time__c);
               
                 if(iCount > 20)
                    iCount = 0;
                 
             }
             salesOrderstatus ='true';
             showCreditOptions = false;
            isException = true;
        }
        catch(exception ex){
            salesOrderstatus = 'false';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
        }
        
        
    }
    /*
        Method Name :submit
        Description : This method used capture the Payment options .
    */
    public pagereference submit(){
        
         try{
             system.debug('***selPaymentMode***'+selPaymentMode);
             system.debug('********DepositMethod'+selDepositOption);
             system.debug('********CreditCardOption'+selCreditCardOption);
             system.debug('***dCash***'+dCash);
             
             //Added by charan '30/06/2017'
             if(selPaymentMode != null && selPaymentMode != '')
             objOpportunity.cm_Payment_Mode__c = selPaymentMode;
             objOpportunity.cm_Deposit_Method__c = selDepositOption;
             objOpportunity.cm_Credit_Card_Payment_Options__c = selCreditCardOption;
             objOpportunity.cm_Deposit_Amount__c = dCash;
             objOpportunity.cm_Cheque_Exception__c = WTException;
             objOpportunity.cm_Cheque_Exception_Comments__c = StrWTExceptionComments;
             
             string advisorId = objOpportunity.OwnerId;
             system.debug('***StrCCExceptionComments***'+StrCCExceptionComments);
             string Dmethod = '';
        
             if(selDepositOption !=null && selDepositOption != ''){
                Dmethod =  selDepositOption;
             }
             system.debug('***Dmethod'+Dmethod);

             //*************CREATE POPTASK****************************************/
              if(selPaymentMode == 'Wire Transfer'){
                //Adeel string strstatus = CM_EmaarUtils.CreatePOPTASK(objOpportunity);
              }
             
             //**********************END******************************************/
             system.debug('Create Sales Order Process Completed****START*******'); 
             CM_EmaarUtils.paymentApproval(objOpportunity,selPaymentMode,Dmethod,selCreditCardOption,dCash);
             system.debug('Create Sales Order Process Completed****END*******');
              /*******CREATING SPECIAL APPROVALS IF USER SELECTED 20k,10k,Waiver OPTIONS.*****************/
             // we need to insert 2 sepacial approvals.
             // 1. when Cash is 20000
             // 2. When Cash is 10000
             // 3. when cash option is Wavier
             // 4. if user selected 'Holding / Post Dated Cheque
             // Sending email about approvals
             system.debug('SPECIAL APPROVALS****START*******'); 
             CM_EmaarUtils.CreateSpecialApprovals(dCash,objOpportunity,Dmethod,selCreditCardOption,StrCCExceptionComments);
             system.debug('SPECIAL APPROVALS****END*******'); 
             /*****************************END******************************/
             // sensing auto debit form when user selected Auto debit form 
             system.debug('AUDO DEBIT APPROVALS****START*******'); 
             if(selCreditCardOption == 'Auto-Debit Form' && dCash<decimal.valueof(System.Label.Payment_Limit)){
                //Adeel CM_EmaarUtils.sendAutoDebitEmail(objOpportunity.id);
             }
             system.debug('AUDO DEBIT APPROVALS****END*******');
             // sending user selected  payment link and amount is 37000  
             // work flow on Opportunity Payment will send an email.
             if(selCreditCardOption == 'Online Payment Link' && dCash<=decimal.valueof(System.Label.Payment_Limit)){
                CM_EmaarUtils.createPaymentRecord(dCash,objOpportunity,''); 
             }
             // inserting the opportunity team member.
             OpportunityTeamMember otm = new OpportunityTeamMember(OpportunityId=objOpportunity.Id,TeamMemberRole='Property Advisor', OpportunityAccessLevel='Edit',UserId = advisorId);
             insert otm;
             
             // Update the Property status to booked   
             //CM_EmaarUtils.UpdatePropertyInventories(objOpportunity.id);
             // Notifying admin for approval
             //CM_EmaarUtils.NotifyAdminforApproval(objOpportunity.id);
             // Notifying the finance team
             //CM_EmaarUtils.NotifyFinanceTeam(objOpportunity.id);
             
             update objOpportunity;
             
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Payment Details are submitted successfully'));
             return new pagereference('/'+objOpportunity.id);
         }
         catch(exception ex){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage())); 
             return null;
         }
    
    }
      /*
        Method Name :CancelPayment
        Description : This method used cancel the Opportunity .
                      on Cancel , Property status --> Available.
                      
    */
    
    public pagereference  CancelPayment(){
        // Cancel payment options :
        // Make properties to Available --> call to service to make available
        // Sales Order field on Opportunity Property to null;
        // Opportunity --> Booked Time field to NUll
       string strMessage = '';
       try{

            strMessage = Cm_BookingUtils.cancelSalesOrder(OppoId,'Cancel Payment');
       }
       catch(exception ex){
             strMessage =  ex.getMessage();
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,ex.getMessage()));
       }
       return null;
     }
    
  public list<Payment_Terms__c> GeneratePaymentTermsdata(string stropporid){
    system.debug('************Inside Payment Terms***********');
    list<Payment_Terms__c> lstToinsertPaymentTerms = new list<Payment_Terms__c>();
    integer iTotal = 0;
    integer isuccessCount = 0;
    integer iErrorCount = 0;
    list<Service_Logs__c> lstservlog = new list<Service_Logs__c>();
    string strParentId = '';
    string Requestbody ='';
    Opportunity opp = [Select id, cm_Default_Payment_schedule_type__c from Opportunity where id=: stropporid];
    list<Opportunity_Property__c> lstOpportunityProperty = [select id,name,cm_Property_Inventory__r.Location_Code__c,cm_Property_Inventory__r.payment_Header_id__c,
                                                             cm_Property_Inventory__r.Standard_Cost__c,cm_Opportunity__c,cm_Opportunity__r.Order_Event__c,cm_Opportunity__r.Order_Source__c,
                                                             cm_Property_Inventory__r.Selling_Price__c,cm_Opportunity__r.campaign.Type,cm_Opportunity__r.cm_Payment_Mode__c,
                                                             cm_Property_Inventory__r.Location__c,cm_Property_Inventory__r.Location__r.Location_ID__c,cm_Property_Inventory__r.Location__r.Location_Code__c,
                                                             cm_Opportunity__r.campaign.Eloqua_ID__c,cm_Opportunity__r.campaign.Name,cm_Property_Inventory__r.Org_ID__c,cm_Org_ID__c,cm_Property_Inventory__r.cm_Related_Campaign__c,cm_Property_Inventory__r.cm_Related_Campaign__r.Campaign_Number__c,
                                                             cm_Property_Inventory__r.Event_ID__c,cm_Property_Inventory__r.Schedule_Type__c,cm_Property_Inventory__r.Payment_Method__c 
                                                             from Opportunity_Property__c where cm_Opportunity__c=:stropporid and Sales_Order__c = null];
                                                             
    iTotal =  lstOpportunityProperty.size();   
    mpValues = new Map<string,String>();   
    Map<string,Id> mpLocs = new Map<string,id>();
    emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresposne ;
    for(Opportunity_Property__c objPro:lstOpportunityProperty){
        string strAmount = '';
        //mpLocs.put(objPro.cm_Property_Inventory__r.Location__r.Location_ID__c, objPro.Id);
        if(objPro.cm_Property_Inventory__r.Selling_Price__c!=null)
          strAmount = string.valueof(objPro.cm_Property_Inventory__r.Selling_Price__c);
        string location_id = objPro.cm_Property_Inventory__r.Location__r.Location_ID__c;
        string amount = strAmount;
        //string strdate = system.today().day()+'-'+system.today().month('')+''+system.today().year();
        DateTime d = datetime.now();
        String monthName= d.format('MMM');
        integer Day= d.day();
        integer year= d.year();
        string strdate = Day+'-'+monthName+'-'+year;
        string org_id = string.valueof(objPro.cm_Org_ID__c);
        string HeaderId = '';
        string PlotPrice ='';
        if(objPro.cm_Property_Inventory__r.Selling_Price__c!=null)
          PlotPrice = string.valueof(objPro.cm_Property_Inventory__r.Selling_Price__c);
        string event_id = '';
        if(objPro.cm_Property_Inventory__r.cm_Related_Campaign__c==null)
           event_id = '999999999';//string.valueof(objPro.cm_Property_Inventory__r.Event_ID__c);
        else
           event_id = objPro.cm_Property_Inventory__r.cm_Related_Campaign__r.Campaign_Number__c;
        string Schedule_type = opp.cm_Default_Payment_schedule_type__c == null ? ((objPro.cm_Property_Inventory__r.Payment_method__c != null ? objPro.cm_Property_Inventory__r.Payment_method__c : 'STANDARD')): opp.cm_Default_Payment_schedule_type__c;
       
        try{
            objresposne = EmaarWebServiceUtils.executePaymentTerms(location_id,amount,strdate,org_id,HeaderId,PlotPrice,event_id,Schedule_type);
            system.debug('****Payment TERMS****objresposne'+objresposne);
            if(objresposne.Status == 'SUCCESS'  &&  objresposne.ErrorMessage.contains('Payment Terms sent sucessfully')){
                isuccessCount = isuccessCount+1;
                list<Payment_Terms__c> lstPaymentT = parsedata(objresposne,objPro.Id,objPro.cm_Property_Inventory__c);
                lstToinsertPaymentTerms.addAll(lstPaymentT);
            }
        }catch(exception ex){
            
        }
    }
    system.debug('**********lstToinsertPaymentTerms'+lstToinsertPaymentTerms);
    return lstToinsertPaymentTerms;
  }
  public list<Payment_Terms__c> parsedata(emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresposne,string OpportunityProp,string stringPropINvId){
    list<Payment_Terms__c> lstData = new list<Payment_Terms__c>();
    if(objresposne.Status == 'SUCCESS'){
         Dom.Document doc = new Dom.Document();
         doc.load(objresposne.ResultXML);
         Dom.XMLNode ordDtls = doc.getRootElement();
         string newprice='';
         integer i = 1;
         for(Dom.XMLNode child1: ordDtls.getChildElements()){
            for(Dom.XMLNode child2: child1.getChildElements()){
                for(Dom.XMLNode child3: child2.getChildElements()){
                   Payment_Terms__c objres = new Payment_Terms__c(); 
                   if(child3.getChildElement('LOCATION_ID',null)!=null)
                        objres.Location_Id__c = child3.getChildElement('LOCATION_ID',null).getText();
                   if(child3.getChildElement('ORG_ID',null)!=null)
                        objres.Org_ID__c = child3.getChildElement('ORG_ID',null).getText();
                   if(child3.getChildElement('LOCATION_CODE',null)!=null)
                        objres.Location_Code__c = child3.getChildElement('LOCATION_CODE',null).getText();
                   if( child3.getChildElement('INST_NUMBER',null)!=null)
                        objres.Installment__c = decimal.valueof(child3.getChildElement('INST_NUMBER',null).getText());
                   if(child3.getChildElement('NET_AMOUNT',null)!=null)
                        objres.cm_Net_Amount__c = child3.getChildElement('NET_AMOUNT',null).getText();
                   if(child3.getChildElement('NET_PERCENT',null)!=null)
                        objres.cm_Net_Percent__c = child3.getChildElement('NET_PERCENT',null).getText();
                   if(child3.getChildElement('TERMDAYS',null)!=null)
                        objres.cm_Term_Days__c = child3.getChildElement('TERMDAYS',null).getText();
                   if(child3.getChildElement('TERMDATE',null)!=null)
                        objres.cm_Term_Date__c = child3.getChildElement('TERMDATE',null).getText();
                   if(child3.getChildElement('MILESTONE_NAME',null)!=null)
                       objres.cm_Milestone_Name__c = child3.getChildElement('MILESTONE_NAME',null).getText();
                   if(child3.getChildElement('MIL_PERCENTAGE',null)!=null)
                        objres.cm_Milestone_Percent__c = child3.getChildElement('MIL_PERCENTAGE',null).getText();
                   if(child3.getChildElement('SM_HEADER_ID',null)!=null){
                        objres.Header_ID__c = child3.getChildElement('SM_HEADER_ID',null).getText();
                        mpValues.put(stringPropINvId, objres.Header_ID__c);
                        System.debug('>>>>>>>>>>>>>>'+stringPropINvId+'>>>>>>>>>>>>>>>>>'+objres.Header_ID__c);
                   }if(child3.getChildElement('SCHEDULE_TYPE',null)!=null)
                        objres.cm_Schedule_Type__c = child3.getChildElement('SCHEDULE_TYPE',null).getText();
                   if(child3.getChildElement('MILESTONE_NAME_ARB',null)!=null)
                        objres.Milestone_Name_Arab__c = child3.getChildElement('MILESTONE_NAME_ARB',null).getText();
                    
                   if(child3.getChildElement('VAT_RATE',null)!=null)
                        objres.VAT_RATE__c = decimal.valueof(child3.getChildElement('VAT_RATE',null).getText());
                        
                    if(child3.getChildElement('VAT_AMOUNT',null)!=null)
                        objres.VAT_AMOUNT__c = decimal.valueof(child3.getChildElement('VAT_AMOUNT',null).getText());
                    objres.cm_Property_Inventory__c = stringPropINvId;
                    objres.Opportunity_Property__c = OpportunityProp;
                   system.debug('***************objres'+objres);
                   
                   lstData.add(objres);
                }
            }
         }
         system.debug('***lstData'+lstData);
         return lstData;
      }else{
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error,objresposne.ErrorMessage));
      }
     return null;
	}
 public Pagereference CheckAgent(){
        String userAgent = ApexPages.currentPage().getHeaders().get('User-Agent');
        system.debug('****userAgent'+userAgent);
        Pagereference objref ;
        if (userAgent!=null && userAgent!='' && (userAgent.contains('iPhone') || userAgent.contains('iPad'))){
            objref = new pagereference('/apex/cm_PaymentPage_sf1?id='+apexpages.currentPage().getParameters().get('Id'));
            objref.setRedirect(true);
            return objref;
        }
        return null;
  }
  public class existingPropertyWrap{
        public Property_Inventory__c objexistingPro{get;set;}
        public string  OpporPropID{get;set;}
        public integer indexval{get;set;}
  }
}