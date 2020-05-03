/***********************************************************************************************
* Name              : AbsenceTriggerHandler                                                 
* Description       : Trigger handler for AbsenceTrigger                
* Created Date      : 17/12/2018                                                    
* Created By        : Adeel Ahmad (adeel.ahmad@were4c.com)   
* Jira/Req By       :                                                                                                                                         
* ----------------------------------------------------------------------------------------------
**/
public with sharing class AbsenceTriggerHandler {
	public static void afterInsert(LIST<EGY_Absence__c> newList){
		LIST<EGY_Absence__c> updateables = new LIST<EGY_Absence__c>();
		for(EGY_Absence__c abs : newList){
			if(abs.Active__c == true){
				updateables.add(abs);
			}
		}
		if(updateables.size() > 0){
			updateGroupMember(updateables, 'False');
		}
	}

	public static void afterUpdate(LIST<EGY_Absence__c> newList){
		LIST<EGY_Absence__c> activated = new LIST<EGY_Absence__c>();
		LIST<EGY_Absence__c> deActivated = new LIST<EGY_Absence__c>();
		for(EGY_Absence__c abs : newList){
			if(abs.Active__c == true){
				activated.add(abs);
			}

			if(abs.Active__c == false){
				deActivated.add(abs);
			}
		}

		if(activated.size() > 0){
			updateGroupMember(activated, 'False');
		}

		if(deActivated.size() > 0){
			updateGroupMember(deActivated, 'True');
		}
	}

	// If absence status is active, then enable group member user
	public static void beforeDelete(LIST<EGY_Absence__c> newList){
		LIST<EGY_Absence__c> updateables = new LIST<EGY_Absence__c>();
		for(EGY_Absence__c abs : newList){
			if(abs.Active__c == true){
				updateables.add(abs);
			}
		}
		if(updateables.size() > 0){
			updateGroupMember(updateables, 'True');
		}
	}

	public static void updateGroupMember(LIST<EGY_Absence__c> newList, String status){
		MAP<Id, String> userIdToStatus = new MAP<Id, String>();
		for(EGY_Absence__c abs : newList){
			userIdToStatus.put(abs.EGY_User__c, status);
		}

		LIST<Assignment_Groups__c> groupMembers = [SELECT Id,Active__c,Status__c, User_Active__c, User__c 
													FROM Assignment_Groups__c
													WHERE User__c IN:userIdToStatus.keySet()];
		if(groupMembers.size() > 0){
			for(Assignment_Groups__c gm : groupMembers){
				gm.Active__c = userIdToStatus.get(gm.User__c);
			}
			upsert groupMembers;			
		}
	}
}