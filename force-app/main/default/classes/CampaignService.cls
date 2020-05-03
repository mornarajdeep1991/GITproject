public class CampaignService {
    
    
    public static void afterUpdate(Map<Id,Campaign> newMap,Map<Id,Campaign> oldMap){
        Set<Id> campids = new Set<Id>();
        List<ExpressofInterest__c> updateEoiLst = new List<ExpressofInterest__c>();
        List<ExpressofInterest__c> updateFinalEoiLst = new List<ExpressofInterest__c>();
        Integer BLKCountIncrement = 0000;
         Integer VILCountIncrement = 0000;
          Integer APTCountIncrement = 0000;
            
        for(Id cmData : newMap.keySet()){
            
            if(newMap.get(cmData).Status != OldMap.get(cmData).Status && newMap.get(cmData).Status == 'Completed'){
                
                campids.add(cmData); 
                
            }
            
        }
        system.debug('campids'+campids);
        if(!campids.isEmpty()){
            
            List<ExpressofInterest__c> EoiBLst = [Select id,Campaign__r.Name,Bulk_number_of_Apartments__c,Registration_Number__c,Bulk_number_of_Villa__c,Total_Units__c,Queue_Type__c,CreatedDate from ExpressofInterest__c where 
                                                  Queue_Type__c='Bulk' AND Payment_Confirmation__c='Confirmed' 
                                                  AND Registration_Number__c=Null AND campaign__r.IsActive=true AND campaign__c In:campids
                                                  ORDER BY Total_Units__c DESC,Created_DateSort__c ASC]; // paymentmode transfer use created date or use receipt number order
            
            List<ExpressofInterest__c> EoiLst = [Select id,Campaign__r.Name,Queue_Type__c from ExpressofInterest__c where 
                                                 (Queue_Type__c='Villa' OR Queue_Type__c='Apartment') AND Payment_Confirmation__c='Confirmed' 
                                                 AND Registration_Number__c=Null AND campaign__r.IsActive=true AND campaign__c In:campids ORDER BY Created_DateSort__c ASC];
             system.debug('EoiBLst'+EoiBLst);
            system.debug('EoiBLst size'+EoiBLst.size());
            system.debug('EoiLst'+EoiLst);
            system.debug('EoiLst size'+EoiLst.size());
            
            if(!EoiBLst.isEmpty()){
                for(ExpressofInterest__c Eoirec : EoiBLst){
                
                    BLKCountIncrement++;
                    Eoirec.Registration_Number__c = Eoirec.Campaign__r.Name+'-BLK-'+BLKCountIncrement;
                    updateFinalEoiLst.add(Eoirec);
                }
            }
            system.debug('updateFinalEoiLst----1'+updateFinalEoiLst);
            if(!EoiLst.isEmpty()){
                
                for(ExpressofInterest__c Eoirec : EoiLst){
                    if(Eoirec.Queue_Type__c=='Villa'){
                   
                        VILCountIncrement++;
                        Eoirec.Registration_Number__c = Eoirec.Campaign__r.Name+'-VIL-'+VILCountIncrement;
                        
                    }else if(Eoirec.Queue_Type__c=='Apartment'){
                     
                        APTCountIncrement++;
                        Eoirec.Registration_Number__c = Eoirec.Campaign__r.Name+'-APT-'+APTCountIncrement;
                        
                    }
                    updateEoiLst.add(Eoirec);
                }
                system.debug('updateEoiLst'+updateEoiLst);
                
                if(!updateEoiLst.isEmpty()) updateFinalEoiLst.addall(updateEoiLst);
            }
            system.debug('updateFinalEoiLst'+updateFinalEoiLst);
            
            update updateFinalEoiLst; 
        }
    }
    
}