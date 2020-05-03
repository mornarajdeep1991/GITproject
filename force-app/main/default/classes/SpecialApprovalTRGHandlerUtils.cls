/************************************************************************************
* Name              : SpecialApprovalTRGHandlerUtils                                                
* Description       : Utility Class for Special Approvals                                           
* Created Date      : 22/05/2018                                                     
* Created By        : Divya Chary (4C)    
* Jira/Req By       :                                                                                                                                           
************************************************************************************/ 
public class SpecialApprovalTRGHandlerUtils {
    /************************************************************************************************
    * Method Name           : Get_NextApproverId                                                      *
    * Created By            : Divya                                                                * 
    ************************************************************************************************/
    public static string Get_NextApproverId(map<id, Sobject> mapSpecialApprovals,string strType,string approvalStatus){
        
        string Next_Approver = '';
        
        if(approvalStatus == 'Approving Authority 1 Approved'){
            if(strType == 'Reservation Cancellation - Refund'){
                Next_Approver = label.CCO_User_Special_Approval;
            }else{
                for(Sobject SARecord:mapSpecialApprovals.values()){
                    cm_Interim_Approvals__c objApproval = (cm_Interim_Approvals__c) SARecord;
                    Next_Approver = objApproval.Second_Level_Approver__c;
                }
            }
        }else if(approvalStatus == 'Approving Authority 2 Approved'){
            for(Sobject SARecord:mapSpecialApprovals.values()){
                cm_Interim_Approvals__c objApproval = (cm_Interim_Approvals__c) SARecord;
                Next_Approver =  objApproval.Third_Level_Approver__c;
            }
        }else if(approvalStatus == 'Approving Authority 3 Approved'){
            for(Sobject SARecord:mapSpecialApprovals.values()){
                cm_Interim_Approvals__c objApproval = (cm_Interim_Approvals__c) SARecord;
                Next_Approver =  objApproval.Fourth_Level_Approver__c;
            }
        }else if(approvalStatus == 'Approving Authority 4 Approved'){
            for(Sobject SARecord:mapSpecialApprovals.values()){
                cm_Interim_Approvals__c objApproval = (cm_Interim_Approvals__c) SARecord;
                Next_Approver =  objApproval.Fifth_Level_Approver__c;
            }
        }
        return Next_Approver == '' ? null:Next_Approver;
    }
   
    /************************************************************************************************
    * Method Name           : Update_ChildRecords                                  *
    * Created By            : Divya                                                               * 
    ************************************************************************************************/
    public static void Update_ChildRecords(map<id, Sobject> mapSpecialApprovals,map<id, Sobject> mapOLDSpecialApprovals){
          map<Id,cm_Interim_Approvals__c> mapSPAApprovalStatus = new map<Id,cm_Interim_Approvals__c>();
          for(Sobject  objPPRecord:mapSpecialApprovals.values()){
              cm_Interim_Approvals__c objPP = (cm_Interim_Approvals__c) objPPRecord;
              cm_Interim_Approvals__c objApprovalOLD = (cm_Interim_Approvals__c) mapOLDSpecialApprovals.get(objPPRecord.id);
              if(objPP.Approval_Status__c !=objApprovalOLD.Approval_Status__c){
                  mapSPAApprovalStatus.put(objPP.Id,objPP);
              }
          }
          list<cm_Interim_Approvals__c> relatedSPAToupdate = new list<cm_Interim_Approvals__c>();
          for(cm_Interim_Approvals__c  objPP1:[select id,cm_Interim_Approval_Type__c,Date_to_Hold__c,Days_to_Hold__c,Approval_Status__c,cm_Opportunity__c,Special_Approval__c from cm_Interim_Approvals__c where Special_Approval__c!=null and  Special_Approval__c IN:mapSPAApprovalStatus.keyset()]){
              objPP1.Approval_Status__c = mapSPAApprovalStatus.get(objPP1.Special_Approval__c).Approval_Status__c;
              objPP1.cm_Decision__c = mapSPAApprovalStatus.get(objPP1.Special_Approval__c).cm_Decision__c;
              relatedSPAToupdate.add(objPP1);
          }
          if(!relatedSPAToupdate.isEmpty()){
              update relatedSPAToupdate;
          }
    }

    public static void Manage_PaymentTerms(map<Id, SObject> newRecords, map<Id, SObject> oldRecords){
        //get ids of approved special approvals
        Set<Id> approvedSpecialApprovalIds = new Set<Id>();
        Set<Id> relatedOffers = new Set<Id>();
        for(Id spId : newRecords.keyset()){
            cm_Interim_Approvals__c newRecord = (cm_Interim_Approvals__c) newRecords.get(spId);
            cm_Interim_Approvals__c oldRecord = (cm_Interim_Approvals__c) oldRecords.get(spId);
            if(newRecord.cm_Decision__c == 'Approved' && oldRecord.cm_Decision__c != 'Approved'){
                //special approval is now approved
                approvedSpecialApprovalIds.add(newRecord.Id);
                relatedOffers.add(newRecord.Offer__c);
                ChangePaymentPlanWebserviceUtils.SynctoOracle(newRecord.Id, newRecord.cm_Opportunity__c);
            }
        }
        /*
        //delete all existing payment terms on offers
        delete [select Id from Payment_Terms__c where Opportunity_Property__c in :relatedOffers];
        //relate approved terms to their respective offers
        List<cm_Interim_Approvals__c> approvals = [select Id, Offer__c, (select Id, Opportunity_Property__c from Payment_Terms__r) from cm_Interim_Approvals__c where id in :approvedSpecialApprovalIds];
        List<Payment_Terms__c> approvedTerms = new List<Payment_Terms__c>();
        for(cm_Interim_Approvals__c aproval : approvals){
            String offerId = aproval.Offer__c;
            for(Payment_Terms__c p : aproval.Payment_Terms__r){
                p.Opportunity_Property__c = offerId;
                approvedTerms.add(p);
            }
        }
        update approvedTerms;*/
    }    
}