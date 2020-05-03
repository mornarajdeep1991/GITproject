/*************************************************************************************************
* Name                  :  Divya Chary                                                            *
* Description           :  SpecialApprovalTriggerHandler                                                       *
*                                                                                                *
* Created By            :                                                                        *               
* Created Date          :                                                                        *   
* Last Modified Date    :                                                                        *
* Last Modified By      :                                                                        * 
*                                                                                                * 
/*************************************************************************************************/
public class SpecialApprovalTriggerHandler implements ITriggerHandler 
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
    SpecialApprovalTriggerHandler_Actions.Execute_BeforeInsertActions(newItems);  
  }  
  public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
  {
      SpecialApprovalTriggerHandler_Actions.Execute_BeforeUpdateActions(newItems,oldItems);
  }
  public void BeforeDelete(Map<Id, SObject> oldItems) 
  {
      
  }
  public void AfterInsert(Map<Id, SObject> newItems) 
  {
      SpecialApprovalTriggerHandler_Actions.Execute_AfterInsertActions(newItems);
  }
  public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems)
  {
      SpecialApprovalTriggerHandler_Actions.Execute_AfterUpdateActions(newItems,oldItems);
  }
  public void AfterDelete(Map<Id, SObject> oldItems) 
  {
      SpecialApprovalTriggerHandler_Actions.Execute_AfterDeleteActions(oldItems);
  }
  public void AfterUndelete(Map<Id, SObject> oldItems)
  {
      
  }
}