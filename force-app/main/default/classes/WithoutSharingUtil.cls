/************************************************************************************
* Name          : WithoutSharingUtil                                                 
* Description   : Custom class to perform operations under without sharing mode
* Created Date  : 10/12/2018                                                    
* Created By    : 4C - Adeel Ahmad (adeel.ahmad@weare4c.com)
* Jira/Req By   :                                                                                                                                           
************************************************************************************/
public without sharing class WithoutSharingUtil {
	public static void upsertPropertyInventories(LIST<Property_Inventory__c> pInventories){
		upsert pInventories;
	}
}