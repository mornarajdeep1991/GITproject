/***********************************************************************************************
* Name              : EGY_OpportunitySPAGenerationExt                                                 
* Description       : Extension class for EGY_OpportunitySPAGeneration                                         
* Created Date      : 02/08/2018                                                    
* Created By        : Adeel Ahmad (adeel.ahmad@were4c.com)    
* Jira/Req By       :                                                                                                                                         
* ----------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
* 1.0       Adeel       02/08/2018  Created                              
************************************************************************************************/
public with sharing class EGY_OpportunitySPAGenerationExt {
	public String msg {get; set;}
	public String redirectURL {get; set;}
	private Id oppId {get; set;}

	public EGY_OpportunitySPAGenerationExt(ApexPages.StandardController sc) {
		oppId = sc.getId();
        msg = '';
	}

	public PageReference navigateToDrawloop(){
		//As there will be only one unit added to the opportunity that is why adding limit of 1
		LIST<Property_Inventory__c> pi = [SELECT id, Drawloop_Template__c 
											FROM Property_Inventory__c
											WHERE 
											ID IN (SELECT cm_Property_Inventory__c FROM Opportunity_Property__c 
													where cm_Opportunity__c =:oppId) 
											LIMIT 1];
		if(pi != null && pi.size() > 0){
			if(String.isNotBlank(pi[0].Drawloop_Template__c)){
				redirectURL = '/apex/loop__looplus?&eid='+oppId+'&ddpIds='+pi[0].Drawloop_Template__c;
			}else{
				msg = 'Please select drawloop template on Property Inventory.';
				redirectURL = '/'+oppId;
			}
		}else{
			msg = 'No unit added to the Opportunity.';
			redirectURL = '/'+oppId;
		}
		return null;
	}
}