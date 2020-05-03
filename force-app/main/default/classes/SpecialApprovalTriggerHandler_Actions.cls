/************************************************************************************
* Name              : SpecialApprovalTriggerHandler_Actions                                                
* Description       : Helper Class to handle Special Approvals                                           
* Created Date      : 22/05/2018                                                     
* Created By        : Divya Chary (4C)    
* Jira/Req By       :                                                                                                                                           
************************************************************************************/
public class SpecialApprovalTriggerHandler_Actions { 
     
    Private static map<Id,User> UserDetails_map = null;
    Private static map<id,cm_Interim_Approval_Type__c> mapApprovalTypes = null; 
    Private static map<id,User> mpPropertyAdvisors = null;
    Private static Map<Id,Opportunity> OpportunityData_map;
    
    /************************************************************************************************
    * Method Name           : BeforeInsert_Actions                                                   *
    * Created By            : Divya Chary                                                               * 
    ************************************************************************************************/
    public static void Execute_BeforeInsertActions(list<cm_Interim_Approvals__c> lstSPData){
         set<id> setOpporIds = new set<id>(); 
         for(cm_Interim_Approvals__c objSPA:lstSPData){
              if(objSPA.cm_Opportunity__c!=null){  
                    setOpporIds.add(objSPA.cm_Opportunity__c);
              }   
         }
         map<Id,Opportunity> mapOppData = getOpportunityData_map(setOpporIds);
         system.debug('**123***mapOppData'+mapOppData);
         integer DaysToHold = 0;
         for(cm_Interim_Approvals__c  objPP:lstSPData){
                if(getUserDetails_map().get(mapOppData.get(objPP.cm_Opportunity__c).cm_Sales_Person__c)!=null){
                    objPP.PA_Manager__c = getUserDetails_map().get(mapOppData.get(objPP.cm_Opportunity__c).cm_Sales_Person__c).managerId;
                }  
                if(objPP.cm_Opportunity__c!=null && mapOppData.get(objPP.cm_Opportunity__c)!=null){ 
                    objPP.Opportunity_Owner__c = mapOppData.get(objPP.cm_Opportunity__c).ownerId;
                }
                
                if(objPP.Special_Approval_Type__c == 'Holding DP / LR'){
                    for(Opportunity_Property__c oppProp: mapOppData.get(objPP.cm_Opportunity__c).Opportunity_Properties__r){
                        if(oppProp.cm_Order_Date__c!=null && objPP.Date_to_Hold__c!=null){
                            objPP.No_of_Approvals_Required__c = getNumberofApprovalsRequired(oppProp.cm_Order_Date__c,objPP.Date_to_Hold__c);
                            DaysToHold = getDaysToHold(oppProp.cm_Order_Date__c,objPP.Date_to_Hold__c);
                        }
                    }
                }
                if(objPP.Special_Approval_Type__c == 'Holding DP / LR'){
                    if(objPP.cm_Interim_Approval_Type__c!=null && getspecialApprovalTypes().get(objPP.cm_Interim_Approval_Type__c)!=null){
                        if(objPP.cm_Opportunity__c!=null && mapOppData.get(objPP.cm_Opportunity__c)!=null && mapOppData.get(objPP.cm_Opportunity__c).cm_Sales_Person__c!=null){
                            if(getUserDetails_map().get(mapOppData.get(objPP.cm_Opportunity__c).cm_Sales_Person__c)!=null){
                                 objPP.Next_Approver__c = getUserDetails_map().get(mapOppData.get(objPP.cm_Opportunity__c).cm_Sales_Person__c).managerId;
                                 objPP.Second_Level_Approver__c = label.Finance_User; 
                            }
                        }
                    }
                    /*if(objPP.Special_Approval_Type__c == 'Holding DP / LR'){
                          if(objPP.No_of_Approvals_Required__c > 1 && (DaysToHold >=7 && DaysToHold <= 31)){
                              objPP.Second_Level_Approver__c = label.Finance_User; 
                          }
                          if(objPP.No_of_Approvals_Required__c > 1 && (DaysToHold >31 && DaysToHold <= 60)){
                            objPP.Second_Level_Approver__c = label.CCO_User_Special_Approval;
                          }
                    }*/
                    
                } 
                else{
                    if(objPP.cm_Interim_Approval_Type__c!=null && getspecialApprovalTypes().get(objPP.cm_Interim_Approval_Type__c)!=null){
                        if(objPP.cm_Opportunity__c!=null && mapOppData.get(objPP.cm_Opportunity__c)!=null && mapOppData.get(objPP.cm_Opportunity__c).cm_Sales_Person__c!=null){
                            if(getUserDetails_map().get(mapOppData.get(objPP.cm_Opportunity__c).cm_Sales_Person__c)!=null){
                                 objPP.Next_Approver__c = getUserDetails_map().get(mapOppData.get(objPP.cm_Opportunity__c).cm_Sales_Person__c).managerId;
                                 objPP.Second_Level_Approver__c = label.Finance_User;
                                 //objPP.Second_Level_Approver__c = label.CCO_User_Special_Approval; 
                            }
                        }
                    }
                }
                if(objPP.Next_Approver__c!=null){
                    objPP.Assign_To__c = objPP.Next_Approver__c;
                    objPP.First_Level_Approver__c = objPP.Next_Approver__c;
                    objPP.Approval_URL__c = getEmailURLs(objPP.Assign_To__c,'Approve','');
                    objPP.Rejection_URL__c = getEmailURLs(objPP.Assign_To__c,'Reject','');
                    objPP.Info_URL__c = getEmailURLs(objPP.Assign_To__c,'Info','');
                }
        }
    }
    /************************************************************************************************
    * Method Name           : Execute_AfterInsertActions                                                   *
    * Created By            : Haribabu                                                                * 
    ************************************************************************************************/
    public static void Execute_AfterInsertActions(map<id, Sobject> mapSpecialApprovals){
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
        Approval.ProcessResult[] processResults = null;
        for(Sobject  objApprovalData:mapSpecialApprovals.values()){
            cm_Interim_Approvals__c objApproval = (cm_Interim_Approvals__c) objApprovalData;
            if(objApproval.Special_Approval__c == null){
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setComments(objApproval.cm_comments__c);
                    req1.setObjectId(objApproval.id); 
                    requests.add(req1);
            } 
        }
        if(requests!=null && requests.size () >0){
          try {
                processResults = Approval.process(requests, true);
          }catch (System.DmlException ex) {
          }
        }
    }
    /************************************************************************************************
    * Method Name           : Execute_BeforeUpdateActions                                                   *
    * Created By            : Divya                                                                * 
    ************************************************************************************************/
    public static void Execute_BeforeUpdateActions(map<id, Sobject> mapSpecialApprovals,map<id, Sobject> mapOLDSpecialApprovals){
        for(Sobject  objApprovalData:mapSpecialApprovals.values()){
            cm_Interim_Approvals__c objApproval = (cm_Interim_Approvals__c) objApprovalData;
            cm_Interim_Approvals__c objApprovalOLD = (cm_Interim_Approvals__c) mapOLDSpecialApprovals.get(objApproval.id);
            if(objApproval.Approval_Status__c !=objApprovalOLD.Approval_Status__c && objApproval.Approval_Status__c!='Submitted for Approval' && (objApproval.cm_Decision__c !='Approved' && objApproval.cm_Decision__c !='Rejected')){
                if(objApproval.Special_Approval__c == null && objApproval.cm_Interim_Approval_Type__c!=null && getspecialApprovalTypes().get(objApproval.cm_Interim_Approval_Type__c)!=null){
                      string Next_appId = SpecialApprovalTRGHandlerUtils.Get_NextApproverId(mapSpecialApprovals,getspecialApprovalTypes().get(objApproval.cm_Interim_Approval_Type__c).Name,objApproval.Approval_Status__c);
                      if(Next_appId!='' && Next_appId!=null){
                        objApproval.Next_Approver__c = Next_appId;
                        objApproval.Assign_To__c = objApproval.Next_Approver__c;
                      }
                }
            }
        }
    }
    /************************************************************************************************
    * Method Name           : Execute_AfterUpdateActions                                              *
    * Created By            : Divya                                                                * 
    ***********************************************************************************************/
    public static void Execute_AfterUpdateActions(map<id, Sobject> mapSpecialApprovals,map<id, Sobject> mapOLDSpecialApprovals){
        for(Sobject  objApprovalData:mapSpecialApprovals.values()){
            cm_Interim_Approvals__c objApproval = (cm_Interim_Approvals__c) objApprovalData;
            cm_Interim_Approvals__c objApprovalOLD = (cm_Interim_Approvals__c) mapOLDSpecialApprovals.get(objApproval.id);
            if(objApproval.Approval_Status__c !=objApprovalOLD.Approval_Status__c){
                //SpecialApprovalTRGHandlerUtils.Approve_LRWaiver(mapSpecialApprovals,mapOLDSpecialApprovals);
                //SpecialApprovalTRGHandlerUtils.Update_PaymentHoldingDate_Opportunity(mapSpecialApprovals,mapOLDSpecialApprovals);
                SpecialApprovalTRGHandlerUtils.Update_ChildRecords(mapSpecialApprovals, mapOLDSpecialApprovals);
            }
            if(objApproval.cm_Decision__c !=objApprovalOLD.cm_Decision__c){
                SpecialApprovalTRGHandlerUtils.Manage_PaymentTerms(mapSpecialApprovals, mapOLDSpecialApprovals);
            }
        }
    }
    /************************************************************************************************
    * Method Name           : Execute_AfterDeleteActions                                              *
    * Created By            : Divya                                                                * 
    ***********************************************************************************************/
    public static void Execute_AfterDeleteActions(Map<Id, SObject> mapOLDSpecialApprovals){
        set<Id> setParentids = new set<Id>();
        for(sObject objSPA:mapOLDSpecialApprovals.values()){
            cm_Interim_Approvals__c objApprovalOLD = (cm_Interim_Approvals__c) mapOLDSpecialApprovals.get(objSPA.id);
            setParentids.add(objApprovalOLD.id);
        }
        list<cm_Interim_Approvals__c> relatedSPAToupdate = [select id from cm_Interim_Approvals__c where Special_Approval__c IN:setParentids];
        if(!relatedSPAToupdate.isEmpty()){
            delete relatedSPAToupdate;
        }
    }

/****************************************************GENERIC METHODS*******************************************************************/    
    /************************************************************************************************
    * Method Name   : getEmailURLs                                                                   *
    * Created By            : Divya Chary                                                               * 
    * Dynamically prepare the URLS 
    ************************************************************************************************/
    public static string getEmailURLs(string ApproverID,string type,string pageName){
        pageName = pageName!=null && pageName!='' ? pageName : 'EmailApproval';
        string BaseURL = URL.getSalesforceBaseUrl().toExternalForm() ;
        string strURL = BaseURL+'/apex/'+pageName+'?type='+type+'&uid='+ApproverID+'&rid=';
        return strURL;
    }
    /************************************************************************************************
    * Method Name           : getNumberofApprovalsRequired                                           *
    * Created By            : Divya Chary                                                               * 
    ************************************************************************************************/
    public static integer getNumberofApprovalsRequired(Date OrderDate,Date DatetoHold){
          integer Approvals_Required = 0;
          Date DTVAL = OrderDate;
          Date PPDTVal = DatetoHold;
          Integer numberDaysDue = DTVAL.daysBetween(PPDTVal);
          system.debug('*******numberDaysDue'+numberDaysDue);
          if(numberDaysDue > 7){
              Approvals_Required = 2;
          }else{
              Approvals_Required = 1;
          }
          return Approvals_Required;
    }
    /************************************************************************************************
    * Method Name           : DaysToHold                                           *
    * Created By            : Divya                                                               * 
    ************************************************************************************************/
    public static integer getDaysToHold(Date OrderDate,Date DatetoHold){
          Date DTVAL = OrderDate;
          Date PPDTVal = DatetoHold;
          Integer numberDaysDue = DTVAL.daysBetween(PPDTVal);
          return numberDaysDue;
    }
    /************************************************************************************************
    * Method Name           : getmpOwners                                                            *
    * Created By            : Divya                                                               * 
    ************************************************************************************************/
    public static map<Id,User> getUserDetails_map(){
         if(UserDetails_map == null) {
            UserDetails_map = new map<Id,User>([select Id,Name,UserName,UserRole.Name,ManagerId,Manager.Name from User where ContactId = null and isActive = true limit 1000]);
         }
         return UserDetails_map;
    }
    /************************************************************************************************
    * Method Name           : getspecialApprovalTypes                                                            *
    * Created By            : Divya                                                               * 
    ************************************************************************************************/
    public static map<id,cm_Interim_Approval_Type__c> getspecialApprovalTypes(){
         if(mapApprovalTypes == null) {
            mapApprovalTypes  = new map<id,cm_Interim_Approval_Type__c>([Select id, Days_to_Hold__c,name,cm_Approving_Authority_1__c,cm_Approving_Authority_2__c,cm_Action_By__c from cm_Interim_Approval_Type__c limit 1000]);
         }
         return mapApprovalTypes;
    }
    /************************************************************************************************
    * Method Name           : getPropertyAdvisors                                                    *
    * Created By            : Divya                                                               * 
    ************************************************************************************************/
    public static map<Id,User> getMpPropertyAdvisors(){
         if(mpPropertyAdvisors == null) {
            mpPropertyAdvisors  = new map<Id,User>([Select id,managerId,cm_user_code__c,cm_team_code__c from User where profile.name like '%Property%' and isActive=true ]);
         }
         return mpPropertyAdvisors;
    }
    /************************************************************************************************
    * Method Name           : getOpportunityData_map                                                 *
    * Created By            : Divya                                                               * 
    ************************************************************************************************/
    public static map<Id,Opportunity> getOpportunityData_map(set<id> setOpporIds){
         if(OpportunityData_map == null) {
            OpportunityData_map = new map<Id,Opportunity>([select id,cm_Sales_Person__c,cm_Days_to_Hold_Cheque__c,ownerId,(select id,cm_Order_Date__c from Opportunity_Properties__r) from Opportunity where id IN:setOpporIds]);
         } 
         return OpportunityData_map;
    }
/***********************************************************END**************************************************************************************/
}