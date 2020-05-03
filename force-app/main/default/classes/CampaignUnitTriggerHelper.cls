/***********************************************************************************************
* Name              : CampaignUnitTriggerHelper                                                 
* Description       : Helper class for triggers related to Campaign Units                                           
* Created Date      : 22/05/2018                                                    
* Created By        : Divya Chary (divya.chary@were4c.com)    
* Jira/Req By       :                                                                                                                                         
* ----------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
* 1.0       Divya       22/05/2018  Created                              
************************************************************************************************/
public class CampaignUnitTriggerHelper{
    /************************************************************************************
    Method  :         sharePropertyInventory Method
    Description :     When a Campaign User is added, share the property inventory with the users
    Version :         1.0
    ************************************************************************************/
    public static void sharePropertyInventory(List<Campaign_Unit__C> lstCampaignUnit){
        //Variables
        Set<Id> setCampaignid = new Set<Id>();
        List<Campaign_User__c> lstCampaignUser = new List<Campaign_User__c>();
        List<Property_Inventory__Share> lstPropertyShare = new List<Property_Inventory__Share>();
        map<Id,Set<Id>> mapIdVsUser = new map<Id,Set<Id>>();
        for(Campaign_Unit__c oUnit :lstCampaignUnit){
            setCampaignid.add(oUnit.cm_Campaign__c);
        }
        //Query all the Campaign Users associated with the Campaign
        lstCampaignUser=[SELECT Id,cm_User__c,cm_Campaign__c FROM Campaign_User__c WHERE cm_Campaign__c IN:setCampaignid];
        //Loop over the Campaign Users, and create a map with the User Ids
        for(Campaign_User__c oUser :lstCampaignUser){
            if(mapIdVsUser.get(oUser.cm_Campaign__c)!=NULL){
                Set<Id> setUser=mapIdVsUser.get(oUser.cm_Campaign__c);
                setUser.add(oUser.cm_User__c);
                mapIdVsUser.put(oUser.cm_Campaign__c,setUser);
            }
            else{
                Set<Id> setUser=new Set<Id>();
                setUser.add(oUser.cm_User__c);
                mapIdVsUser.put(oUser.cm_Campaign__c,setUser);
            }    
        }
        system.debug('mapIdVsUser'+mapIdVsUser);
        //Loop over the Campaign Units and insert the Property Inventory Share records
        for(Campaign_Unit__c oUnit : lstCampaignUnit){
            if(mapIdVsUser.get(oUnit.cm_Campaign__c)!=NULL && mapIdVsUser.get(oUnit.cm_Campaign__c).SIZE()>0){
                for(Id iId :mapIdVsUser.get(oUnit.cm_Campaign__c)){
                    Property_Inventory__Share invShr  = new Property_Inventory__Share();
                        invShr.ParentId = oUnit.cm_Property_Inventory__c;
                        invShr.UserOrGroupId = iId;
                        invShr.AccessLevel = 'Edit';
                        invShr.RowCause = Schema.Property_Inventory__Share.RowCause.Manual;
                        lstPropertyShare.add(invShr);     
                }
            }
        }
        //if(lstPropertyShare!=NULL && lstPropertyShare.size()>0) insert lstPropertyShare;
                        
    }
}