/***********************************************************************************************
* Name              : CampaignUserTriggerHelper                                                 
* Description       : Helper class for triggers related to Campaign Users                                           
* Created Date      : 22/05/2018                                                    
* Created By        : Divya Chary (divya.chary@were4c.com)    
* Jira/Req By       :                                                                                                                                         
* ----------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
* 1.0       Divya       22/05/2018  Created                              
************************************************************************************************/
public class CampaignUserTriggerHelper{
    /************************************************************************************
    Method  :         sharePropertyInventory Method
    Description :     When a Campaign User is added, share the property inventory with the users
    Version :         1.0
    ************************************************************************************/
    public static void shareCampaign(List<Campaign_User__C> lstCampaignUser){
        //Variables
        Set<Id> setCampaignid = new Set<Id>();
        List<Campaign_Unit__c> lstCampaignUnit = new List<Campaign_Unit__c>();
        List<Property_Inventory__Share> lstPropertyShare = new List<Property_Inventory__Share>();
        map<Id,Set<Id>> mapIdVsInventory = new map<Id,Set<Id>>();
        for(Campaign_User__c oUser :lstCampaignUser){
            setCampaignid.add(oUser.cm_Campaign__c);
        }
        //Query all the Campaign Units associated with the Campaign
        lstCampaignUnit=[SELECT Id,cm_Campaign__c, cm_Property_Inventory__c FROM Campaign_Unit__c WHERE cm_Campaign__c IN:setCampaignid];
        //Loop over the Campaign Units, and create a map with the Inventory Ids
        for(Campaign_Unit__c oUnit :lstCampaignUnit){
            if(mapIdVsInventory.get(oUnit.cm_Campaign__c)!=NULL){
                Set<Id> setInventory=mapIdVsInventory.get(oUnit.cm_Campaign__c);
                setInventory.add(oUnit.cm_Property_Inventory__c);
                mapIdVsInventory.put(oUnit.cm_Campaign__c,setInventory);
            }
            else{
                Set<Id> setInventory=new Set<Id>();
                setInventory.add(oUnit.cm_Property_Inventory__c);
                mapIdVsInventory.put(oUnit.cm_Campaign__c,setInventory);
            }    
        }
        //Loop over the Campaign USERS and insert the Property Inventory Share records
        for(Campaign_User__c oUser : lstCampaignUser){
            if(mapIdVsInventory.get(oUser.cm_Campaign__c)!=NULL && mapIdVsInventory.get(oUser.cm_Campaign__c).SIZE()>0){
                for(Id iId :mapIdVsInventory.get(oUser.cm_Campaign__c)){
                    Property_Inventory__Share invShr  = new Property_Inventory__Share();
                        invShr.ParentId = iId;
                        invShr.UserOrGroupId = oUser.cm_User__c;
                        invShr.AccessLevel = 'Edit';
                        invShr.RowCause = Schema.Property_Inventory__Share.RowCause.Manual;
                        lstPropertyShare.add(invShr);     
                }
            }
        }
        if(lstPropertyShare!=NULL && lstPropertyShare.size()>0) insert lstPropertyShare;
                        
    }
    
    
    
}