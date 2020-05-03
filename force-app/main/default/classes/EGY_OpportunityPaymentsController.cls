/************************************************************************************
* Name              : EGY_OpportunityPaymentsController                                                 
* Description       : Controller class for lightning component EGY_OpportunityPayments                                          
* Created Date      : 08/05/2018                                                    
* Created By        : Adeel Ahmad (adeel.ahmad@weare4c.com)    
* Jira/Req By       : Jira Ticket/Req Given by                                                                                                                                          
* -----------------------------------------------------------------------------------------------------------------------
* VERSION   Developer           Date            Description                                                             Ticket/Reference                                                                    
* 1.0       Adeel Ahmad         08/05/2018      Controller class for lightning component EGY_OpportunityPayments        Jira Ticket no./                      
************************************************************************************/
public with sharing class EGY_OpportunityPaymentsController {

    /************************************************************************************
    Method      :  getOpportunityInfo
    Params      :  opportunityId
    Description :  Getting opportunity information by passing opportunity id
    Version :         1.0
    ************************************************************************************/
	//Method to get the opportunity info
	@AuraEnabled
    public static Opportunity getOpportunityInfo(String oppId){
        Opportunity opp = [SELECT id,Name,Property_Booked_Date__c,campaignId ,cm_Approval_Status__c,
                           cm_Booking_timer__c,cm_Booking_Minute_Count__c,Order_Event__c,Order_Source__c,
                           Unit_Availability_Checked__c, Booking_Form_Filled__c,
                           Property_Booked_Time__c,AccountId, Account.IsPersonAccount,cm_contact__c,
                           cm_Party_Type__c,OwnerId,cm_Sales_Person__c FROM Opportunity WHERE id = :oppId ];
        return opp;
    }

    /************************************************************************************
    Method      :  fetchFieldOptions
    Params      :  opportunityId
    Description :  Method to get picklist values as we can't use apex:inputField in lightning components
    Version :         1.0
    ************************************************************************************/
    @AuraEnabled
    public static Map<String, String> fetchFieldOptions(string filter){
        Map<String, String> fieldOptions = new Map<String, String>();
        //fieldOptions.put('', '--None--');
        if(filter == 'state'){
            Schema.DescribeFieldResult stateFieldResult = User.statecode.getDescribe();
            List<Schema.PicklistEntry> stateple = stateFieldResult.getPicklistValues();
            for( Schema.PicklistEntry f : stateple){
                fieldOptions.put(f.getLabel(), f.getValue());
            }
        }

        if(filter == 'country'){
            Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
            list<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry f : ple){
                fieldOptions.put(f.getLabel(), f.getValue());
            }            
        }

        if(filter == 'CountryCodes'){
            Schema.DescribeFieldResult fieldResult = Account.Corporate_Phone_Country_Code__c.getDescribe();
            list<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry f : ple){
                fieldOptions.put(f.getLabel(), f.getValue());
            }     
        }

        if(filter == 'Country Of Incorporation'){
            Schema.DescribeFieldResult fieldResult = Account.cm_Country_Of_Incorporation__c.getDescribe();
            list<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry f : ple){
                fieldOptions.put(f.getLabel(), f.getValue());
            }
        }

        if(filter == 'Order_Source__c'){
            Schema.DescribeFieldResult fieldResult = Opportunity.Order_Source__c.getDescribe();
            list<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry f : ple){
                fieldOptions.put(f.getLabel(), f.getValue());
            }   
        }

        if(filter == 'Order_Event__c'){
            Schema.DescribeFieldResult fieldResult = Opportunity.Order_Event__c.getDescribe();
            list<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry f : ple){
                fieldOptions.put(f.getLabel(), f.getValue());
            }   
        }

        if(filter == 'PaymentModes'){
            fieldOptions.put('Cheque','Cheque');
            fieldOptions.put('Wire Transfer','Wire Transfer');
            fieldOptions.put('Visa','Visa');
        }

        if(filter == 'ChequeDeositMethods'){
            fieldOptions.put('Not Applicable','Not Applicable');
            fieldOptions.put('Cash','Cash');
            //fieldOptions.put('Credit card','Credit card');
        }

        if(filter == 'WireTransferDepositMethods'){
            fieldOptions.put('Deposit Waiver','Deposit Waiver');
            fieldOptions.put('Cash','Cash');
            //fieldOptions.put('Credit card','Credit card');
        }

        if(filter == 'CreditCardOptions'){
            fieldOptions.put('Auto-Debit Form','Auto-Debit Form');
            fieldOptions.put('Online Payment Link','Online Payment Link');
            fieldOptions.put('Credit Card Machine','Credit Card Machine');
        }
        return fieldOptions;
    }

    //Method to get account info
    /************************************************************************************
    Method      :  getAccountInfo
    Params      :  AccountId, Party_Type__c, OpportunityContactId
    Description :  method to get account info
    Version     :  1.0
    ************************************************************************************/
    @AuraEnabled
    public static Account getAccountInfo(String accountId, String party_type, String oppContactId){
        LIST<Account> account = new LIST<Account>();
        if(party_type != '' && party_type == 'EGY_PersonAccount'){
            account = [SELECT id, cm_National_ID_Expiry_Date__pc,cm_Birthdate__pc,cm_Passport_Number__pc,BillingStreet,BillingState,BillingCountrycode,BillingCity,BillingStatecode,BillingCountry,
                            BillingPostalCode,cm_Resident_Of_UAE__pc,cm_National_ID_No__pc from Account Where id=:accountId LIMIT 1];             
        }else{
            account = [select id,BillingStreet,cm_National_ID_Expiry_Date__pc,BillingCountrycode,BillingCity,BillingStatecode,BillingState,BillingCountry,BillingPostalCode,
                                                   cm_Date_of_Incorporation__c,cm_Country_of_Incorporation__c,cm_Trade_License_Expiry_Date__c,cm_Trade_License_Number__c 
                                                   from Account where id=:accountId LIMIT 1];
        }
        if(account.size() > 0){
            return account[0];
        }else{
            return new Account();
        }
    }

    /************************************************************************************
    Method      :  getContactInfo
    Params      :  Party_Type__c, OpportunityContactId
    Description :  Gretting contact information associated to opportunity
    Version     :  1.0
    ************************************************************************************/
    @AuraEnabled
    public static Contact getContactInfo(String party_type, String oppContactId){
        LIST<Contact> contact = new LIST<Contact>();
        if(party_type != 'EGY_PersonAccount' && oppContactId != ''){
            contact = [SELECT id,cm_Birthdate__c,cm_National_ID_Expiry_Date__c,cm_Passport_Number__c,cm_Resident_Of_UAE__c,MailingStreet,MailingState,MailingStatecode,MailingCountry,
                            MailingCountrycode,MailingPostalCode,MailingCity,cm_National_ID_No__c from contact where Id=:oppContactId];
        }
        if(contact.size() > 0){
            return contact[0];            
        }else{
            return new Contact();
        }

    }

    //
    /************************************************************************************
    Method      :  getAddedProperties
    Params      :  OpportunityId
    Description :  Method to get the property inventories that has been added to opportunity.
    Version     :  1.0
    ************************************************************************************/
    @AuraEnabled
    public static LIST<Property_Inventory__c> getAddedProperties(String oppId){
        LIST<Property_Inventory__c> addedPropertiesList = new LIST<Property_Inventory__c>();
        Set<id> existingPInventoriesIds = new set<Id>();        
        list<Opportunity_Property__c> lstOpporPro = [select id,Name,cm_Opportunity__c,cm_Property_Inventory__c from Opportunity_Property__c where cm_Opportunity__c=:oppId];
        for(Opportunity_Property__c objOpppro:lstOpporPro){
            existingPInventoriesIds.add(objOpppro.cm_Property_Inventory__c);
        }
        string strPacakgeRecId = getRecordTypeId('Property_Inventory__c','Package');
        String Strval = 'Blocked';
        string strQuery = 'Select Id,recordtype.name,VAT_Rate__c,Total_Amount__c,VAT_Amount__c,Location__r.Building__c,Location_Code__c,Total_Area__c,Sales_Rooms__c,Saleable_Leasable_Area__c,recordtypeId,Property_Status__c,cm_Inventory_Package__c, Name,UNIT__c, Type__c,Sales_Room__c,BUILDING__c,Unit_Model__c , PROPERTY_ID__c,Status_indicator__c, PROPERTY_Code__c, Property__c, Selling_price__c FROM Property_Inventory__c where Id IN:existingPInventoriesIds and RecordTypeId!=:strPacakgeRecId and Property_Type__c!=:Strval  order by CreatedDate';
        addedPropertiesList = database.query(strQuery);
        return addedPropertiesList;
    }

    /************************************************************************************
    Method      :  upsertPersonAccount
    Params      :  AccountObject, OpportunityId
    Description :  Method to upsert person account
    Version     :  1.0
    ************************************************************************************/
    @AuraEnabled
    public static string upsertPersonAccount(Account acc, String oppId){
        string msg = '';
        try{
            if(acc.BillingCountryCode == '' || acc.BillingCountryCode == '--None--'){
                acc.BillingCountryCode = null;
            }
            System.debug('@@acc='+acc);
            EmaarWebserviceUtils.isUpdated = true;
            upsert acc;
            EmaarWebserviceUtils.isUpdated = false;
            Service_Logs__c parentlog = new Service_Logs__c();
            parentlog.Process_Name__c = 'Sales Order Creation';
            parentlog.Process_Time__c = system.now();
            parentlog.Log_type__c  = 'Process Started';
            parentlog.Opportunity__c = oppId;
            insert parentlog;

            msg  = 'Success';
        }catch(DmlException e){
            msg = 'Exception: '+e.getMessage();
        }
        return msg;
    }

    /************************************************************************************
    Method      :  upsertBusinessAccount
    Params      :  AccountObject, OpportunityId
    Description :  Method to upsert business account
    Version     :  1.0
    ************************************************************************************/
    @AuraEnabled
    public static string upsertBusinessAccount(Account acc, String oppId){
        string msg = '';
        try{
            EmaarWebserviceUtils.isUpdated = true;
            upsert acc;
            EmaarWebserviceUtils.isUpdated = false;
            Service_Logs__c parentlog = new Service_Logs__c();
            parentlog.Process_Name__c = 'Sales Order Creation';
            parentlog.Process_Time__c = system.now();
            parentlog.Log_type__c  = 'Process Started';
            parentlog.Opportunity__c = oppId;
            insert parentlog;

            msg  = 'Success';
        }catch(DmlException e){
            msg = 'Exception: '+e.getMessage();
        }
        return msg;
    }

    //
    /************************************************************************************
    Method      :  upsertOpptyContact
    Params      :  ContactObject
    Description :  Method to upsert contact associated to opportunity.
    Version     :  1.0
    ************************************************************************************/
    @AuraEnabled
    public static string upsertOpptyContact(Contact con){
        string msg = '';
        try{
            upsert con;
            msg  = 'Success';
        }catch(DmlException e){
            msg = 'Exception: '+e.getMessage();
        }
        return msg;
    }

    /************************************************************************************
    Method      :  createSalesOrder
    Params      :  opportunityId
    Description :  Cancel Salesorder associated to opportunity
    Version     :  1.0
************************************************************************************/
    @AuraEnabled
    public static string createSalesOrder(String oppId){
        String strOrderSource;
        String strOrderEvent;
        String strParentId;
        String strstatus;
        Opportunity oppInfo = [SELECT Id, Order_Event__c, Order_Source__c FROM Opportunity WHERE Id =: oppId];
        map<string,cm_Administrator_Settings__c> mpSettings = cm_Administrator_Settings__c.getAll();
        cm_Administrator_Settings__c settings = new cm_Administrator_Settings__c();
        if(mpSettings.containsKey('ADMIN')){
            settings = mpSettings.get('ADMIN');
        }
        
        if(String.isBlank(oppInfo.Order_Event__c)){
            strOrderEvent = settings.Default_Order_Event__c;
        }else{
            strOrderEvent = oppInfo.Order_Event__c;
        }
        
        if(String.isBlank(oppInfo.Order_Source__c)){
            strOrderSource = settings.Default_Order_Source__c;
        }else{
            strOrderSource = oppInfo.Order_Source__c;
        }
        Map<String, String> mpValues = new MAP<String, String>();
        LIST<Service_Logs__c> sLog = [SELECT Id FROM Service_Logs__c WHERE Opportunity__c =: oppId ORDER BY ID DESC LIMIT 1];
        if(sLog != null && sLog.size() > 0){
            strParentId = sLog[0].Id;
        }
        //Spliting opportunity for each of opportunity property
        LIST<Opportunity_Property__c> opportunityProperties = [SELECT Id, cm_Property_Inventory__c FROM Opportunity_Property__c WHERE cm_Opportunity__c =:oppId];
        //if there are multiple properties, split the opportunity with all related lists
        if(opportunityProperties.size() > 1){
            strstatus = MultipleUnits_CreateSalesOrder.CreateParty_SalesOrder(oppId,strParentId,strOrderSource,strOrderEvent,mpValues);
            // string strstatus = 'success';
            if(strstatus.contains('success')){
                string BookedPrpmsg =  CM_EmaarUtils.ApproveProperties(oppId);
                string successfull_orders = '';
                for(Opportunity_Property__c opc : [SELECT Id, Sales_Order__c, cm_Inventory_Location_Code__c FROM Opportunity_Property__c WHERE cm_Opportunity__c =:oppId]){
                    if(String.isNotBlank(opc.Sales_Order__c)){
                        successfull_orders += opc.cm_Inventory_Location_Code__c + ',';
                    }
                }
                if(successfull_orders != ''){
                    successfull_orders = successfull_orders.removeEnd(',');
                }
                string strMessage = multipleunitsBooking.createMultipleOpportunities(oppId);
                if(strMessage == 'success'){
                    strMessage = 'success!' + successfull_orders;
                    return strMessage;
                }else{
                    return 'Error! ' + strMessage;
                }
            }else{
                return 'Error! ' + strstatus;
            } 
        }else{
            strstatus = EmaarBookingProcess.CreateParty_SalesOrder(oppId,strParentId,strOrderSource,strOrderEvent,mpValues);
            if(strstatus == 'success'){
                string BookedPrpmsg =  CM_EmaarUtils.ApproveProperties(oppId);
                //ADeel : update opportunity status to pending approval after booking
                if(BookedPrpmsg == 'success'){
                    Opportunity opp = new Opportunity(Id = oppId);
                    opp.StageName = 'Pending Approval';
                    update opp;
                }
                return BookedPrpmsg;
            }
        }
        return strstatus;
    }
    
    @AuraEnabled
    public static void saveBookedByRole(String oppId, Opportunity opp){
        upsert opp;
    }
    
    /************************************************************************************
    Method      :  cancelSalesBooking
    Params      :  opportunityId
    Description :  Method to cancel sales booking agains opportunity.
    Version     :  1.0
    ************************************************************************************/
    @AuraEnabled
    public static string cancelSalesBooking(String oppId){
        String msg = '';
        try{
            msg = Cm_BookingUtils.cancelSalesOrder(oppId,'Cancel Payment');
        }catch(Exception e){
            msg = 'Exception: ' + e.getMessage();
        }
        return msg;
    }

    /************************************************************************************
    Method      :  submit
    Params      :  opportunityId, PaymentMode, DepositMethod, CreditCardOption, Amount, Exception, ExceptionComments
    Description :  Book the apportunity.
    Version     :  1.0
    ************************************************************************************/
    @AuraEnabled
    public static string submit(String oppId, String paymentMode, String depositMethod, String creditCardOption, Decimal amount, Boolean exc, String exceptionComments ){
        String msg = '';
        try{
            Opportunity opp = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :oppId];
            opp.cm_Payment_Mode__c = paymentMode;
            opp.cm_Deposit_Method__c = depositMethod;
            opp.cm_Credit_Card_Payment_Options__c = creditCardOption;
            opp.cm_Deposit_Amount__c = amount;
            opp.cm_Cheque_Exception__c = exc;
            opp.cm_Cheque_Exception_Comments__c = exceptionComments;

            string advisorId = opp.OwnerId;

            CM_EmaarUtils.paymentApproval(opp,paymentMode,depositMethod,creditCardOption,amount);

            CM_EmaarUtils.CreateSpecialApprovals(amount,opp,depositMethod,creditCardOption,exceptionComments);

            if(creditCardOption == 'Online Payment Link' && amount<=decimal.valueof(System.Label.Payment_Limit)){
                CM_EmaarUtils.createPaymentRecord(amount,opp,''); 
            }

            // inserting the opportunity team member.
            OpportunityTeamMember otm = new OpportunityTeamMember(OpportunityId=opp.Id,TeamMemberRole='Property Advisor', OpportunityAccessLevel='Edit',UserId = advisorId);
            insert otm;

            opp.cm_Approval_Status__c = 'Pending With Admin';
            update opp;    
            
            msg = 'Success';        
        }catch(Exception e){
            msg = 'Exception: ' + e.getMessage();
        }
        return msg;
    }

    @AuraEnabled
    public static string upsertOpportunity(String oppId, Opportunity opp){
        string msg = '';
        try{
            upsert opp;
        }catch(Exception e){
            msg = 'Exception: ' + e.getMessage();
        }
        return msg;
    }

    /************************************************************************************
    Method      :  validateOpportunityProperties
    Params      :  OpportunityId
    Description :  Validating campaingId and CampaignMapId against opportunity properties.
    Version     :  1.0
    ************************************************************************************/
    @AuraEnabled
    public static string validateOpportunityProperties(string oppId){
        string msg = '';
        for(Opportunity_Property__c op : [SELECT Id, Campaign_Id__c, Campaign_Map_Id__c, Location_Code_display__c FROM Opportunity_Property__c WHERE cm_Opportunity__c =:oppId]){
            if(String.isBlank(op.Campaign_Id__c) || String.isBlank(op.Campaign_Map_Id__c)){
                msg += 'Payment terms campaign missing for location ' + op.Location_Code_display__c + '. <br />';
            }
        }
        return msg;
    }

    /************************************************************************************
    Method      :  getRecordTypeId
    Params      :  objectName, recordTypeName
    Description :  Method to get record type id
    Version     :  1.0
    ************************************************************************************/
    public static Id getRecordTypeId(String objectName, String recordName){
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();  
        Schema.DescribeSObjectResult d = gd.get(objectName).getDescribe();
        return(d.getRecordTypeInfosByName().get(recordName).getRecordTypeId()); 
    }
}