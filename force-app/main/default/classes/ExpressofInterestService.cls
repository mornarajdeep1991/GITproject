public class ExpressofInterestService {
    
    public static void afterUpdate(Map<Id,ExpressofInterest__c> newMap,Map<Id,ExpressofInterest__c> oldMap){
        system.debug('inside after update');
        for(Id eoi : newMap.keyset()){
            system.debug('eoi'+eoi);
            system.debug('newMap.get(eoi).Registration_Number__c'+newMap.get(eoi).Receipt_Number__c);
            if(String.isNotBlank(newMap.get(eoi).Receipt_Number__c) && newMap.get(eoi).Receipt_Number__c != oldMap.get(eoi).Receipt_Number__c){
                
                system.debug('eoi');
               docall(eoi);
                
                
            }
            
        }
        
    }
@future(callout=true)
    public static void docall(Id eoi){
        system.debug('call before EOI');
          EOISearch.callReceiptService(eoi);
             
    }
}