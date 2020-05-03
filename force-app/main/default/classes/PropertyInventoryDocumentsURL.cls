Public without sharing class PropertyInventoryDocumentsURL{

    @future
    public static void getURL(list<Id> lstPI){
        try{
        Map<string,set<Id>> mpContentKeyCVIds = new Map<string,set<Id>>();
        Map<Id,contentversion> mpcvIDCV = new Map<Id,contentversion>();
        set<Id> stCVids = new set<Id>();
        Map<id,ContentDistribution> mpCVIDContDistr = new Map<id,ContentDistribution>();
        Map<string,string> mpContentKeyURL = new Map<string,string>();
        Map<string,string> mpContentVersionURL = new Map<string,string>();
        List<Property_Inventory__c> lstPropInToupdatewithblank = new List<Property_Inventory__c>();
        //get all Property Inventory
        Map<id,Property_Inventory__c> mpPI = new Map<id,Property_Inventory__c>();
        
        set<string> stcontentKeys = new set<string>();
        for(Property_Inventory__c pi: [Select id,Document_URLs__c,Content_Key__c,Building_Name__c,Unit_Position__c from Property_Inventory__c where Id in: lstPI]){
            if(pi.Building_Name__c != null && pi.Unit_Position__c != null){
                stcontentKeys.add(pi.Building_Name__c+'###'+pi.Unit_Position__c);
            }
            if(pi.Building_Name__c != null){
                stcontentKeys.add(pi.Building_Name__c+'###');
            } 
            mpPI.put(pi.id,PI);
        }
        
        System.debug('>>>>>>>>>>>mpPI>>>>>>>>>>>>>>'+mpPI);
        System.debug('>>>>>>>>>>>stcontentKeys>>>>>>>>>>>>>>'+stcontentKeys);
        //based on the property inventory keys get Content Versions
        list<contentversion> lstContVer = new list<contentversion>();
            if(!Test.isRunningTest()){
                lstContVer = [select id, title, Property_Inventory__c,cm_Content_Key__c from contentversion where cm_Content_Key__c in: stcontentKeys and PublishStatus = 'P' and islatest=true];
            }
            else{
                lstContVer = [select id, title, Property_Inventory__c,cm_Content_Key__c from contentversion where cm_Content_Key__c in: stcontentKeys];
            }
            System.debug('>>>>>>>>>>>lstContVer>>>>>>>>>>>>>>'+lstContVer);
        
        //form the map of content version id and content key along with their respective content versions
        if(lstContVer != null && !lstContVer.isempty()){
            for(contentversion cv : lstContVer){
                if(mpContentKeyCVIds.containskey(cv.cm_Content_Key__c)){
                    set<Id> cvids = mpContentKeyCVIds.get(cv.cm_Content_Key__c);
                    cvids.add(cv.id);
                    mpContentKeyCVIds.put(cv.cm_Content_Key__c,cvids);
                }
                else{
                    set<Id> cvids = new set<id>();
                    cvids.add(cv.id);
                    mpContentKeyCVIds.put(cv.cm_Content_Key__c,cvids);
                }
                stCVids.add(cv.id);
                mpcvIDCV.put(cv.id,cv);
            }
        }
        else{
            lstPropInToupdatewithblank.add(mpPI.values());
        }
        
        system.debug('stCVids--> '+stCVids);
        system.debug('>>>>>>>mpContentKeyCVIds--> '+mpContentKeyCVIds);
        //content distributions based on content versions
        if(stCVids != null && !stCVids.isempty()){
            list<ContentDistribution> lstcontDistr = [select id,Name,ContentVersionId,DistributionPublicUrl from ContentDistribution where ContentVersionId in : stCVids];
            if(lstcontDistr != null && !lstcontDistr.isempty()){
                for(ContentDistribution cd : lstcontDistr){
                    mpCVIDContDistr.put(cd.ContentVersionId,cd);
                }
            }
        }
        
        system.debug('mpContentKeyCVIds--> '+mpContentKeyCVIds);
        system.debug('mpCVIDContDistr--> '+mpCVIDContDistr);
        system.debug('mpcvIDCV--> '+mpcvIDCV);
        
        //update property inventory along with their respective associated content distribution (DistributionPublicUrl)
        if(mpContentKeyCVIds != null && !mpContentKeyCVIds.isempty() && mpCVIDContDistr != null && !mpCVIDContDistr.isempty()){
             for(string ctKey : mpContentKeyCVIds.keyset()){
                 system.debug('ctKey--> '+ctKey);
                 string strURL = '';
                 string siteURL = '';
                 if(mpContentKeyCVIds.get(ctKey) != null && !mpContentKeyCVIds.get(ctKey).isempty()){
                     system.debug('mpContentKeyCVIds.get(ctKey)--> '+mpContentKeyCVIds.get(ctKey));
                     for(id cvID : mpContentKeyCVIds.get(ctKey)){
                         system.debug('cvID--> '+cvID); 
                         if(mpCVIDContDistr!=null && mpCVIDContDistr.get(cvID)!=null && (mpCVIDContDistr.get(cvID).DistributionPublicUrl == null ||  mpCVIDContDistr.get(cvID).DistributionPublicUrl == '')){
                             strURL = strURL+'';
                         }
                         else{
                             if(mpcvIDCV.get(cvID)!=null && mpCVIDContDistr!=null && mpCVIDContDistr.get(cvID)!=null){
                                 strURL = strURL + mpcvIDCV.get(cvID).title+'#'+mpCVIDContDistr.get(cvID).DistributionPublicUrl + ';';
                             }
                         }
                         siteURL+='/sfc/servlet.shepherd/version/download/'+cvID+'?asPDF=false###';
                     }
                     mpContentKeyURL.put(ctKey,strURL);
                     siteUrl = siteUrl.trim();
                     System.debug('>>>>>>>>>siteUrl>>>>>>>'+siteUrl);
                     mpContentVersionURL.put(ctKey,siteURL);
                 }
                 
             }
         }
         system.debug('mpContentKeyURL--> '+mpContentKeyURL);
		 system.debug('mpContentVersionURL--> '+mpContentVersionURL);
		 
         if(lstPropInToupdatewithblank != null && !lstPropInToupdatewithblank.isempty()){
             for(Property_Inventory__c piId : lstPropInToupdatewithblank){
                 piId.Document_URLs__c='';
                 piId.Content_site_URL__c = '';
             }
             update lstPropInToupdatewithblank;
         }
         
         boolean toupdate = false;
         if(mpContentKeyURL != null && !mpContentKeyURL.isempty()){
             for(Property_Inventory__c PI : mpPI.values()){
                 PI.Document_URLs__c = '';
                 if(pi.Building_Name__c != null && pi.Unit_Position__c != null){
                     PI.Document_URLs__c = mpContentKeyURL.get(pi.Building_Name__c+'###'+pi.Unit_Position__c);
                     pi.Content_site_URL__c = mpContentVersionURL.get(pi.Building_Name__c+'###'+pi.Unit_Position__c);
                     toupdate = true;
                 }
                 if(pi.Building_Name__c != null){
                     PI.Document_URLs__c = PI.Document_URLs__c + mpContentKeyURL.get(pi.Building_Name__c+'###');
                      pi.Content_site_URL__c = pi.Content_site_URL__c+mpContentVersionURL.get(pi.Building_Name__c+'###');
                     toupdate = true;
                 }
             }
         }
         
         if(toupdate){
             update mpPI.values();
         }
     
        }
		catch(exception ex){
		}
    }
}