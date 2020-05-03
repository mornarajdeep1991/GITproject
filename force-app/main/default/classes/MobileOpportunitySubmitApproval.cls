@RestResource(urlMapping='/SubmitApproval/*')
global class MobileOpportunitySubmitApproval {

    @HttpGet
    global static void httpGet() {
        system.debug('## MobileOpportunitySubmitApproval HTTP GET Started');
        
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        
        String oppId = request.params.get('oppId');
        
        //Check Opportunity Property Status
        Boolean oppPropertyStatus = EGY_OpptySubmitForApprovalRecirectCntrl.checkOpportunityPropertyStatus(oppId);
        if (oppPropertyStatus) {
            List<String> messagesList = new List<String>();
            messagesList.add('Sales order has already been generated for selected opportunity.');
            returnGetFail(response, messagesList);
            return;
        }
        
        //Get Pending Special Approvals
        String pendingSpecialApprovals = EGY_OpptySubmitForApprovalRecirectCntrl.getPendingSpecialApprovals(oppId);
        if (!String.isBlank(pendingSpecialApprovals)) {
            List<String> messagesList = new List<String>();
            messagesList.add(pendingSpecialApprovals);
            returnGetFail(response, messagesList);
            return;
        }
        
        //Validate Opportunity Fields
        String validateOpportunityFields = EGY_OpptySubmitForApprovalRecirectCntrl.validateOpportunityFields(oppId);
        if (validateOpportunityFields.containsIgnoreCase('Error')) {
            List<String> messagesList = new List<String>();
            messagesList.add(validateOpportunityFields);
            returnGetFail(response, messagesList);
            return;
        }
        
        //Validate Account And Contact
        String validateAccountAndContact = EGY_OpptySubmitForApprovalRecirectCntrl.getOppInfo(oppId);
        if (!String.isBlank(validateAccountAndContact)) {
            List<String> messagesList = new List<String>();
            messagesList.add(validateAccountAndContact);
            returnGetFail(response, messagesList);
            return;
        }
        
        //Validate Opportunity Properties
        String validateOpportunityPropertiesCampaign = EGY_OpptySubmitForApprovalRecirectCntrl.validateOpportunityProperties(oppId);
        if (!String.isBlank(validateOpportunityPropertiesCampaign)) {
            List<String> messagesList = new List<String>();
            messagesList.addAll(validateOpportunityPropertiesCampaign.split('<br />'));
            returnGetFail(response, messagesList);
            return;
        }
        
        String validateOpportunityProperties = EGY_OpportunityPaymentsController.validateOpportunityProperties(oppId);
        if (!String.isBlank(validateOpportunityProperties)) {
            List<String> messagesList = new List<String>();
            messagesList.addAll(validateOpportunityProperties.split('<br />'));
            returnGetFail(response, messagesList);
            return;
        }
        
        List<Property_Inventory__c> propertyInventoryList = EGY_OpportunityPaymentsController.getAddedProperties(oppId);
        if (propertyInventoryList.size() == 0) {
            List<String> messagesList = new List<String>();
            messagesList.add('Please add properties to opportunity to proceed.');
            returnGetFail(response, messagesList);
            return;
        }
        
        Opportunity opportunityInfo = EGY_OpportunityPaymentsController.getOpportunityInfo(oppId);
        Boolean isPersonAccount = false;
        if(opportunityInfo.cm_Party_Type__c != '' 
           && opportunityInfo.cm_Party_Type__c == 'EGY_PersonAccount' 
           && opportunityInfo.AccountId != null) 
        {
            isPersonAccount = true;
        }
        
        String accountId = opportunityInfo.AccountId;
        String party_type = opportunityInfo.cm_Party_Type__c;
        String contactId = opportunityInfo.cm_Contact__c != null ? String.valueOf(opportunityInfo.cm_Contact__c) : '';
        
        if(!IsPersonAccount&& contactId == '') {
            List<String> messagesList = new List<String>();
            messagesList.add('Please provide Contact/Account details on the Opportunity to proceed.');
            returnGetFail(response, messagesList);
            return;
        }
        
        
        Account accountInfo = EGY_OpportunityPaymentsController.getAccountInfo(accountId, party_type, contactId);
        
        Contact contactInfo = new Contact();
        if(contactId != '' && party_type != 'EGY_PersonAccount'){
            contactInfo = EGY_OpportunityPaymentsController.getContactInfo(party_type, contactId);
        }
        
        
        Map<String, String> paymentModesValuesMap = EGY_OpportunityPaymentsController.fetchFieldOptions('PaymentModes');
        List<PicklistLabelValue> paymentModesValues = generatePicklistFromMap(paymentModesValuesMap);
        
        Map<String, String> chequeDeositMethodsValuesMap = EGY_OpportunityPaymentsController.fetchFieldOptions('ChequeDeositMethods');
        List<PicklistLabelValue> chequeDeositMethodsValues = generatePicklistFromMap(chequeDeositMethodsValuesMap);
        
        Map<String, String> wireTransferDepositMethodsValuesMap = EGY_OpportunityPaymentsController.fetchFieldOptions('WireTransferDepositMethods');
        List<PicklistLabelValue> wireTransferDepositMethodsValues = generatePicklistFromMap(wireTransferDepositMethodsValuesMap);
        
        Map<String, String> creditCardOptionsValuesMap = EGY_OpportunityPaymentsController.fetchFieldOptions('CreditCardOptions');
        List<PicklistLabelValue> creditCardOptionsValues = generatePicklistFromMap(creditCardOptionsValuesMap);
        
        returnGetSuccess(response, isPersonAccount, accountInfo, contactInfo, propertyInventoryList.size(), paymentModesValues, chequeDeositMethodsValues, wireTransferDepositMethodsValues, creditCardOptionsValues);
    }
    
    @HttpPost
    global static void httpPost(SubmitForApprovalPostRequestDTO submitApprovalDTO) {
        system.debug('## MobileOpportunitySubmitApproval HTTP POST Started');
        
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        
        String requestType = request.requestURI.substring(request.requestURI.lastIndexOf('/') + 1);
        
        if (requestType.equalsIgnoreCase('UpdateAccountContact')) {
            updateAccountContact(response, submitApprovalDTO);
        } else if (requestType.equalsIgnoreCase('CreateSalesOrder')) {
            createSalesOrder(response, submitApprovalDTO);
        } else if (requestType.equalsIgnoreCase('submitOpportunity')) {
            submitOpportunity(response, submitApprovalDTO);
        } else if (requestType.equalsIgnoreCase('cancelBooking')) {
            cancelBooking(response, submitApprovalDTO);
        }
        
    }
    
    private static List<PicklistLabelValue> generatePicklistFromMap(Map<String, String> valuesMap) {
        List<PicklistLabelValue> returnList = new List<PicklistLabelValue>();
        
        for (String key : valuesMap.keySet()) {
            String value = valuesMap.get(key);
            
            returnList.add(new PicklistLabelValue(key, value));
        }
        
        return returnList;
    }
    
    private static void updateAccountContact(RestResponse response, SubmitForApprovalPostRequestDTO submitApprovalDTO) {
        try {
            update submitApprovalDTO.accountInfo;
            
            if (!submitApprovalDTO.isPersonAccount) {
                update submitApprovalDTO.contactInfo;
            }
            
            returnPostSuccess(response, new List<String>());
            return;
            
        } catch (Exception ex) {
            List<String> messagesList = new List<String>();
            messagesList.add('An error occurred.');
            returnPostFail(response, messagesList);
            return;
        }
        
    }
    
    private static void createSalesOrder(RestResponse response, SubmitForApprovalPostRequestDTO submitApprovalDTO) {
        
        String salesOrderResponse = EGY_OpportunityPaymentsController.createSalesOrder(submitApprovalDTO.opportunityId);
        if(salesOrderResponse.containsIgnoreCase('success')) {
            List<String> messagesList = new List<String>();
            messagesList.add('Salesorder has been successfully created.');
            returnPostSuccess(response, messagesList);
            return;
        } else {
            List<String> messagesList = new List<String>();
            messagesList.add(salesOrderResponse);
            returnPostFail(response, messagesList);
            return;
        }
    }
    
    private static void cancelBooking(RestResponse response, SubmitForApprovalPostRequestDTO submitApprovalDTO) {
        String cancelSalesBooking = EGY_OpportunityPaymentsController.cancelSalesBooking(submitApprovalDTO.opportunityId);
        
        if (cancelSalesBooking.equalsIgnoreCase('Success')) {
            List<String> messagesList = new List<String>();
            messagesList.add('Salesorder has been successfully cancelled.');
            returnPostSuccess(response, messagesList);
            return;
        } else {
            List<String> messagesList = new List<String>();
            messagesList.add(cancelSalesBooking);
            returnPostFail(response, messagesList);
            return;
        }
    }
    
    private static void submitOpportunity(RestResponse response, SubmitForApprovalPostRequestDTO submitApprovalDTO) {
        String submitResult = EGY_OpportunityPaymentsController.submit(submitApprovalDTO.opportunityId, submitApprovalDTO.paymentMode, submitApprovalDTO.depositMethod, submitApprovalDTO.creditCardOption, submitApprovalDTO.amount, submitApprovalDTO.exc, submitApprovalDTO.exceptionComments);
        
        if (submitResult.equalsIgnoreCase('Success')) {
            List<String> messagesList = new List<String>();
            returnPostSuccess(response, messagesList);
            return;
        } else {
            List<String> messagesList = new List<String>();
            messagesList.add(submitResult);
            returnPostFail(response, messagesList);
            return;
        }
    }
    
    private static void returnGetFail(RestResponse response, List<String> messages) {
        SubmitForApprovalGetResponseDTO responseDTO = new SubmitForApprovalGetResponseDTO(false);
        responseDTO.messageList = messages;
        
        response.addHeader('content-type', 'application/json');        
        response.responseBody = Blob.valueOf(JSON.serialize(responseDTO));
        response.statusCode = 200;
    }
    
    private static void returnGetSuccess(RestResponse response, Boolean isPersonAccount, Account accountInfo, Contact contactInfo, Integer unitsSize, List<PicklistLabelValue> paymentModesValues, List<PicklistLabelValue> chequeDeositMethodsValues, List<PicklistLabelValue> wireTransferDepositMethodsValues, List<PicklistLabelValue> creditCardOptionsValues) {
        SubmitForApprovalGetResponseDTO responseDTO = new SubmitForApprovalGetResponseDTO(true);
        responseDTO.accountInfo = accountInfo;
        responseDTO.contactInfo = contactInfo;
        responseDTO.isPersonAccount = isPersonAccount;
        responseDTO.showOrderPage = (unitsSize == 1);
        responseDTO.paymentModesValues = paymentModesValues;
        responseDTO.chequeDeositMethodsValues = chequeDeositMethodsValues;
        responseDTO.wireTransferDepositMethodsValues = wireTransferDepositMethodsValues;
        responseDTO.creditCardOptionsValues = creditCardOptionsValues;
        
        response.addHeader('content-type', 'application/json');        
        response.responseBody = Blob.valueOf(JSON.serialize(responseDTO));
        response.statusCode = 200;
    }
    
    private static void returnPostFail(RestResponse response, List<String> messages) {
        SubmitForApprovalPostResponseDTO responseDTO = new SubmitForApprovalPostResponseDTO(false);
        responseDTO.messageList = messages;
        
        response.addHeader('content-type', 'application/json');        
        response.responseBody = Blob.valueOf(JSON.serialize(responseDTO));
        response.statusCode = 200;
    }
    
    private static void returnPostSuccess(RestResponse response, List<String> messages) {
        SubmitForApprovalPostResponseDTO responseDTO = new SubmitForApprovalPostResponseDTO(true);
        responseDTO.messageList = messages;
        
        response.addHeader('content-type', 'application/json');        
        response.responseBody = Blob.valueOf(JSON.serialize(responseDTO));
        response.statusCode = 200;
    }
    
    public class SubmitForApprovalGetResponseDTO {
        public List<String> messageList {get; set;}
        public Boolean isSuccess {get; set;}
        public Account accountInfo {get; set;}
        public Contact contactInfo {get; set;}
        public Boolean isPersonAccount {get; set;}
        public Boolean showOrderPage {get; set;}
        public List<PicklistLabelValue> paymentModesValues {get; set;}
        public List<PicklistLabelValue> chequeDeositMethodsValues {get; set;}
        public List<PicklistLabelValue> wireTransferDepositMethodsValues {get; set;}
        public List<PicklistLabelValue> creditCardOptionsValues {get; set;}
        
        
        public SubmitForApprovalGetResponseDTO() {
            messageList = new List<String>();
            isSuccess = false;
            accountInfo = new Account();
            contactInfo = new Contact();
            isPersonAccount = false;
            showOrderPage = false;
            paymentModesValues = new List<PicklistLabelValue>();
            chequeDeositMethodsValues = new List<PicklistLabelValue>();
            wireTransferDepositMethodsValues = new List<PicklistLabelValue>();
            creditCardOptionsValues = new List<PicklistLabelValue>();
        }
        
        public SubmitForApprovalGetResponseDTO(Boolean success) {
            messageList = new List<String>();
            isSuccess = success;
            accountInfo = new Account();
            contactInfo = new Contact();
            isPersonAccount = false;
            showOrderPage = false;
            paymentModesValues = new List<PicklistLabelValue>();
            chequeDeositMethodsValues = new List<PicklistLabelValue>();
            wireTransferDepositMethodsValues = new List<PicklistLabelValue>();
            creditCardOptionsValues = new List<PicklistLabelValue>();
        }
    }
    
    global class SubmitForApprovalPostRequestDTO {
        public Account accountInfo {get; set;}
        public Contact contactInfo {get; set;}
        public Boolean isPersonAccount {get; set;}
        public String opportunityId {get; set;}
        public String paymentMode {get; set;}
        public String depositMethod {get; set;}
        public String creditCardOption {get; set;}
        public Decimal amount {get; set;}
        public Boolean exc {get; set;}
        public String exceptionComments {get; set;}
    }
    
    public class SubmitForApprovalPostResponseDTO {
        public List<String> messageList {get; set;}
        public Boolean isSuccess {get; set;}
        
        public SubmitForApprovalPostResponseDTO(Boolean success) {
            messageList = new List<String>();
            isSuccess = success;
        }
    }
    
    global class PicklistLabelValue {
        public String label {get; set;}
        public String value {get; set;}
        
        global PicklistLabelValue(String labelStr, String valueStr) {
            label = labelStr;
            value = valueStr;
        }
    }
}