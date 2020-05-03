/*
	Controller class for lightning component EGY_AddProperties
	Adeel Ahmad (adeel.ahmad@weare4c.com)
	Created Date : 07/05/2018
*/
public with sharing class EGY_OpptySubmitForApprovalRecirectCntrl {
	public EGY_OpptySubmitForApprovalRecirectCntrl() {
		
	}

	@AuraEnabled
	public static string getPendingSpecialApprovals(String oppId){
		string strApprovalCheck = CM_EmaarUtils.CheckInterimApprovals(oppId);
		String msg = '';
		if(strApprovalCheck != 'success'){
		 	msg = 'Error! Some of the special approvals are still pending. Please approve or reject them before proceeding.';
		}
		return msg;
	}

	@AuraEnabled
	public static string getOppInfo(String oppId){
		String msg = '';
		Opportunity opp = [SELECT id,Name,AccountId,Account.isPersonAccount,cm_contact__c FROM Opportunity WHERE id = :oppId ];
		if(opp.AccountId == null){
			msg = 'Error! Please provide Account details on the Opportunity to proceed.';
		}
		if( opp.AccountId != null && opp.Account.isPersonAccount == false && opp.cm_contact__c == null){
			msg = 'Error! Please provide Contact details on the Opportunity to proceed.';
		}
		return msg;
	}

    @AuraEnabled
    public static Boolean checkOpportunityPropertyStatus(String oppId){
        Boolean isSalesOrderGenerated = false;
        LIST<Opportunity_Property__c> oppProperty = [SELECT Id, Sales_Order__c FROM Opportunity_Property__c WHERE cm_Opportunity__c = :oppId ];
        if(oppProperty != null && oppProperty.size() > 0){
            if(String.isNotBlank(oppProperty[0].Sales_Order__c)){
                isSalesOrderGenerated = true;
            }
        }
        return isSalesOrderGenerated;
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

    @AuraEnabled
    public static string validateOpportunityFields(String oppId){
    	String msg = '';
    	String fields = '';
    	Opportunity opp = [SELECT Id, Account.isPersonAccount,Account.Phone, Account.PersonEmail, Account.BillingStreet, Account.PersonMobilePhone, Type_of_Property_Interest__c,
    					   cm_Contact__r.MobilePhone, cm_Contact__r.Email, cm_Contact__r.MailingStreet
    					   FROM Opportunity WHERE Id =:oppId];
    	if(opp.Account.isPersonAccount){
    		if(String.isBlank(opp.Account.PersonMobilePhone)){
    			fields += 'Account Mobile Number. <br />';
    		}

    		if(String.isBlank(opp.Account.PersonEmail)){
    			fields += 'Account Email Address. <br />';
    		}

    		//if(String.isBlank(opp.Account.BillingStreet)){
    		//	fields += 'Account Billing Street. <br />';	
    		//}
    	}else{
    		if(String.isBlank(opp.cm_Contact__r.MobilePhone)){
    			fields += 'Contact Phone Number. <br />';
    		}

    		if(String.isBlank(opp.cm_Contact__r.Email)){
    			fields += 'Contact Email Address. <br />';
    		}

    		if(String.isBlank(opp.cm_Contact__r.MailingStreet)){
    			//fields += 'Contact Mailing Street. <br />';	
    		}
    	}
		if(String.isBlank(opp.Type_of_Property_Interest__c)){
			fields += 'Type of Property Interest. <br />';	
		}
		if(String.isNotBlank(fields)){
			msg = 'Error! Please make sure to fill the following fields: <br />' + fields;	
		}
		return msg;
    }
}