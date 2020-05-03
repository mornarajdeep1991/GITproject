/************************************************************************************
* Name              : MobileAppConvertLead
* Description       : A Rest webservice to convert a Lead into an Account.
* Created Date      : 06/06/2018
* Created By        : 4C
* Jira/Req By       :                                                                                                                                           
************************************************************************************/
@RestResource(urlMapping='/ConvertLead/*')
global with sharing class MobileAppConvertLead {
    
    @HttpGet
    global static void httpGet() {
        system.debug('## MobileAppConvertLead HTTP Get Started');
                
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        
        //Get Lead ID from the Request URI
        String leadId = request.requestURI.substring(request.requestURI.lastIndexOf('/') + 1);
        
        //Set Lead ID in the LeadCnvert Object
        Database.LeadConvert databaseLeadConvert = new Database.LeadConvert();
        databaseLeadConvert.setLeadId(leadId);
        
        //Get Status of Converted Leads
        List<LeadStatus> convertStatusList = new List<LeadStatus>([SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1]);
        
        if (convertStatusList.size() <= 0) {
            response.statusCode = 500;
            
            ConvertLeadResultDTO convertResultDTO = new ConvertLeadResultDTO();
            convertResultDTO.isSuccess = false;
            convertResultDTO.errorMessage = 'No Lead Converted Status Found';
            
            response.responseBody = Blob.valueOf(JSON.serialize(convertResultDTO));
            
            system.debug('## MobileAppConvertLead: No Lead Converted Status Found');
            system.debug('## MobileAppConvertLead HTTP Get Ended');
            return;
        }
        
        
        databaseLeadConvert.setConvertedStatus(convertStatusList.get(0).MasterLabel);
        Database.LeadConvertResult databaseLeadConvertResult ;
        
        try {
            databaseLeadConvertResult = Database.convertLead(databaseLeadConvert);
            
            ConvertLeadResultDTO convertResultDTO = new ConvertLeadResultDTO();
            
            convertResultDTO.accountId = databaseLeadConvertResult.getAccountId();
            convertResultDTO.contactId = databaseLeadConvertResult.getContactId();
            convertResultDTO.opportunityId = databaseLeadConvertResult.getOpportunityId();
            convertResultDTO.isSuccess = true;
            
            system.debug('## Lead Convert Success');
            system.debug('## Lead Convert Account Id: ' + databaseLeadConvertResult.getAccountId());
            system.debug('## Lead Convert Contact Id: ' + databaseLeadConvertResult.getContactId());
            system.debug('## Lead Convert Opportunity Id: ' + databaseLeadConvertResult.getOpportunityId());
            
            response.statusCode = 200;
            response.responseBody = Blob.valueOf(JSON.serialize(convertResultDTO));
            
        }
        catch(DMLException dmlEx) {
            response.statusCode = 500;
            ConvertLeadResultDTO convertResultDTO = new ConvertLeadResultDTO();
            convertResultDTO.isSuccess = false;
            convertResultDTO.errorMessage = '';
            
            for (Integer index = 0; index < dmlEx.getNumDml(); index++) {
                convertResultDTO.errorMessage += dmlEx.getDmlMessage(index) + ' ';
            }
            
            response.responseBody = Blob.valueOf(JSON.serialize(convertResultDTO));
            
            system.debug('## MobileAppConvertLead: Lead Conversion Exception');
            system.debug('## MobileAppConvertLead: DML Exception Message= ' + dmlEx.getMessage());
            system.debug('## MobileAppConvertLead: DML Exception Message= ' + dmlEx.getDmlMessage(0));
        }
        catch(exception ex) {
            response.statusCode = 500;
            ConvertLeadResultDTO convertResultDTO = new ConvertLeadResultDTO();
            convertResultDTO.isSuccess = false;
            convertResultDTO.errorMessage = ex.getMessage();
            
            response.responseBody = Blob.valueOf(JSON.serialize(convertResultDTO));
            
            system.debug('## MobileAppConvertLead: Lead Conversion Exception');
            system.debug('## MobileAppConvertLead: Exception Message= ' + ex.getMessage());
            system.debug('## MobileAppConvertLead: Exception Message= ' + ex);
            
            
        }

        system.debug('## MobileAppConvertLead HTTP Get Ended');    }
    
    global class ConvertLeadResultDTO {
        public String accountId {get; set;}
        public String contactId {get; set;}
        public String opportunityId {get; set;}
        public Boolean isSuccess {get; set;}
        public String errorMessage {get; set;}
        
        global ConvertLeadResultDTO() {
            accountId = '';
            contactId = '';
            opportunityId = '';
            isSuccess = false;
            errorMessage = '';
        }
    }
}