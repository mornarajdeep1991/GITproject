/*************************************************************************************************
* Name                  :  Morna Rajdeep                                                            *
* Description           :  CampaignTriggerHandler                                                       *
*                                                                                                *
* Created By            :                                                                        *               
* Created Date          :     10/02/2020                                                                   *   
* Last Modified Date    :                                                                        *
* Last Modified By      :                                                                        * 
*                                                                                                * 
/*************************************************************************************************/
public class ExpressofInterestTriggerHandler implements ITriggerHandler 
{
  public static Boolean TriggerDisabled = false;
  /*
    Checks to see if the trigger has been disabled. For example, you could check a custom setting here.
    In this example, a static property is used to disable the trigger.
    In a unit test, you could use AccountTriggerHandler.TriggerDisabled = true to completely disable the trigger.
  */
  public Boolean IsDisabled()
  {
    return TriggerDisabled;
  }
  public void BeforeInsert(List<SObject> newItems) 
  {
  
  }  
  public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
  {
      
  }
  public void BeforeDelete(Map<Id, SObject> oldItems) 
  {
      
  }
  public void AfterInsert(Map<Id, SObject> newItems) 
  {
      
  }
  public void AfterUpdate(Map<Id,SObject> newItems,Map<Id,SObject> oldItems)
  {
     
     ExpressofInterestService.afterUpdate((Map<Id,ExpressofInterest__c>)newItems,(Map<Id,ExpressofInterest__c>)oldItems);
  }
  public void AfterDelete(Map<Id,SObject> oldItems) 
  {
     
  }
  public void AfterUndelete(Map<Id, SObject> oldItems)
  {
      
  }
}