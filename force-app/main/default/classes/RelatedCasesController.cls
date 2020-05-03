/**
* Apex controller for lightning component 'RelatedCases'
*
* @Date: 03/15/2018
* @Author: Adeel Ahmad (Einsteam)
*
* @TestClass : Test_RelatedCasesController
*/
public class RelatedCasesController {
 	@AuraEnabled
    public static List<Case> getRelatedCases(String caseId) {
        /*
		SET<Id> caseIds = new SET<Id>();
		for(Related_Case__c c : [SELECT Related_Case1__c, Related_Case1__r.Id, Related_Case1__r.Type, Related_Case1__r.CreatedDate, 
							 Related_Case2__c, Related_Case2__r.Type, Related_Case2__r.CreatedDate 
						FROM Related_Case__c
						WHERE
						Related_Case1__c =: caseId OR Related_Case2__c =: caseId]){
			if(c.Related_Case1__c != caseId){
				caseIds.add(c.Related_Case1__c);
			}else if(c.Related_Case2__c != caseId){
				caseIds.add(c.Related_Case2__c);
			}
		}
		if(caseIds.size() > 0){
			return [SELECT Id, Type, CreatedDate, Subject,CaseNumber FROM Case WHERE Id IN :caseIds];
		}else{
	        return new LIST<Case>();
		}
		*/
        return [SELECT Id, Type, CreatedDate, Subject,CaseNumber FROM Case];
    }

    @AuraEnabled
    public static List<CaseResult> fetchCases(String searchKeyWord, String fieldName, String fieldFilterValue, String currentCaseId) {
        /*
        List < Case > returnList = new List < Case > ();
        List<CaseResult> caseSearchResults = new List<CaseResult>();
        LIST<Case> cases = new LIST<Case>();
        MAP<Id, Boolean> caseIdToRelationshipMap = new MAP<Id, Boolean>();
        if(fieldFilterValue != 'Fuzzy'){
            String filterStr = fieldFilterValue == 'Equals' ? ( fieldName + ' = :searchKeyWord ') : ( fieldName + ' Like \'%' + searchKeyWord + '%\'' );
            String query = 'Select Id, CaseNumber, Subject, Status, CreatedDate, OwnerId, Owner.Name  From Case Where ' + filterStr + ' Limit 50';            
            cases = Database.query(query);
        }else{
            String whereClause = ' Case.' + fieldName + ' Like \'%' + searchKeyWord.split(' ')[0] + '%\'';
            String soslQuery = 'FIND :searchKeyWord IN ALL FIELDS RETURNING Case(Id, CaseNumber, Subject, Status, CreatedDate, OwnerId, Owner.Name WHERE '+whereClause+')';
            cases = search.query(soslQuery)[0];
        }

        if(cases.size() > 0){
            for(Related_Case__c rc : [SELECT Id, Related_Case1__c, Related_Case2__c FROM Related_Case__c
                                      WHERE (Related_Case1__c IN :cases AND Related_Case2__c =:currentCaseId)
                                            OR (Related_Case2__c IN :cases AND Related_Case1__c =:currentCaseId)
                                            ]){
                caseIdToRelationshipMap.put(rc.Related_Case1__c, true);
                caseIdToRelationshipMap.put(rc.Related_Case2__c, true);
            }
        }

        for (Case cse: cases) {
        	if(cse.Id != currentCaseId){
	            CaseResult ar = new CaseResult();
	            ar.CaseRecord = cse;
                ar.isAlreadyMerged = false;
                if(caseIdToRelationshipMap.get(cse.Id) != null){
                    ar.isAlreadyMerged = true;                    
                }
	            returnList.add(cse);
	            CaseSearchResults.add(ar);
        	}
        }
        return CaseSearchResults;
		*/
        return new List<CaseResult>();
    }

    @AuraEnabled
    public static Boolean doMergeCases(String caseId, String relatedCaseId){
        /*
    	Related_Case__c relatedCase = new Related_Case__c();
    	relatedCase.Related_Case1__c = caseId;
    	relatedCase.Related_Case2__c = relatedCaseId;
    	insert relatedCase;
		*/
    	return true;
    }

    @AuraEnabled
    public static Boolean doDeleteRelation(String caseId, String relatedCaseId){
        /*
        LIST<Related_Case__c> relatedCase = [SELECT Id FROM Related_Case__c 
                                             WHERE 
                                             ( Related_Case1__c =:caseId AND Related_Case2__c =:relatedCaseId )
                                             OR (Related_Case2__c =:caseId AND Related_Case1__c =:relatedCaseId)];
        if(relatedCase.size() > 0){
            Delete relatedCase;
            return true;
        }
		*/
        return false;
    }

    @AuraEnabled
    public static Map<String, String> fetchFieldOptions(){
        Map<String, String> fieldOptions = new Map<String, String>();
        fieldOptions.put( '-- NONE --' , 'NONE' );
        fieldOptions.put( 'Case Number' , 'CaseNumber' );
        fieldOptions.put( 'PO Number' , 'Purchase_Order__c' );
        fieldOptions.put( 'Type' , 'Type' );
        fieldOptions.put( 'Call Number' , 'Call_Number__c' );
        return fieldOptions;
    }
    
    @AuraEnabled
    public static Map<String, String> fetchFieldFilterOptions(){
        Map<String, String> fieldOptions = new Map<String, String>();
        fieldOptions.put( 'Equals' , 'Equals' );
        fieldOptions.put( 'Contains' , 'Contains' );
        fieldOptions.put( 'Fuzzy' , 'Fuzzy' );
        return fieldOptions;
    }

    public Class CaseResult{
        
        @AuraEnabled
        public Case caseRecord {get; set;}
        
        @AuraEnabled
        public Boolean isAlreadyMerged {get; set;}
    }

    @AuraEnabled
    public static void createRecord (ContentNote nt, id PrentId){
        try{
            if(nt != null){
                insert nt;
                ContentDocument cd=[select id from ContentDocument where id=:nt.Id];
                ContentDocumentLink cdl=new ContentDocumentLink();
                cdl.ContentDocumentId=cd.id;
                cdl.LinkedEntityId=PrentId;
                cdl.ShareType='V';
                cdl.Visibility='AllUsers';
                insert cdl;
            }
        } catch (Exception ex){

        }
    }    
}