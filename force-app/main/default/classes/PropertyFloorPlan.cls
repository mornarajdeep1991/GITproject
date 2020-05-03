public with sharing class PropertyFloorPlan {
    public PropertyFloorPlan(ApexPages.StandardController sc){
        
    }
  @RemoteAction
   public static string CreateContentAttachment(string PropInvId) {
        string strMessage = '';
        try{
            map<string,string> mpOpps = new map<string,string>(); 
            list<Property_Inventory__c> lstPropData = [select id,name,cm_Building__c,Unit_Position__c, Location_Code__c from Property_Inventory__c where id=:PropInvId];
            if(lstPropData!=null && lstPropData.size() >0){
                  
                   List<Attachment> attachedFiles = [select Id,parentId from Attachment where parentId =:PropInvId  and name LIKE 'salesOffer%'  order By LastModifiedDate ];
                   if(attachedFiles!=null && attachedFiles.size() >0){
                       delete attachedFiles;
                   }
                
                    string strKEY  = lstPropData[0].cm_Building__c+'###'+lstPropData[0].Unit_Position__c ;
                    string strKEY1  = lstPropData[0].cm_Building__c+'###';
                    mpOpps.put(strKEY,strKEY);
                    mpOpps.put(strKEY1,strKEY1);

                    /* Old 
                    string strKEY  = lstPropData[0].cm_Building__c+'###'+lstPropData[0].Unit_Position__c ;
                    //string strKEY1  = lstPropData[0].cm_Building__c+'###';  //Adeel - Removing key1
                    //string strKEY1  = lstPropData[0].Location_Code__c+'###'; //Adeel-Updated with location code
                    mpOpps.put(strKEY,strKEY);
                    //mpOpps.put(strKEY1,strKEY1);
                    System.debug('>>>>>>>>>>>>>>>>>>>'+mpOpps); */
                    
                    /****************1********FLOOR PLANS***************************************/                
                
                	system.debug(mpOpps);
                    system.debug([select id,FileType,FileExtension,Title,versionData,cm_Building__c,cm_Content_Key__c from contentVersion ]);
                    list<ContentVersion> lstCV = [select id,FileType,FileExtension,Title,versionData,cm_Building__c,cm_Content_Key__c from contentVersion where islatest=true and cm_Content_Key__c in: mpOpps.keyset() and cm_is_Floor_plan__c = true order by lastmodifiedDate asc];
                    Map<string,list<ContentVersion>> mpVersions = new Map<String,List<ContentVersion>>();
                    for(ContentVersion cv: lstCV){
                      if(!mpVersions.containsKey(cv.cm_Content_Key__c))
                          mpVersions.put(cv.cm_Content_Key__c, new List<ContentVersion>{cv});
                        else{
                          List<ContentVersion> lstCVExisting= mpVersions.get(cv.cm_Content_Key__c);
                          lstCVExisting.add(cv);
                          mpVersions.put(cv.cm_Content_Key__c, lstCVExisting);
                        }
                        
                    }
                    system.debug('***1******mpVersions'+mpVersions);
                    /********************************END****************************************/
                    
                    /*************PROPERTY INVENTORY Related Content*****************************/
                    list<ContentVersion> lstPICV = [select id,FileType,FileExtension,Title,versionData,cm_Building__c,Location_Code__c,cm_Content_Key__c,Property_Inventory__c from contentVersion where islatest=true and Property_Inventory__c =:PropInvId];
                    Map<ID,ContentVersion> mpPIVersionData= new Map<ID,ContentVersion>();
                    for(ContentVersion cv: lstPICV){
                        mpPIVersionData.put(cv.Property_Inventory__c, cv);
                    } 
                    system.debug('***2***mpPIVersionData'+mpPIVersionData);
                    /****************************END***********************************************/
                    
                    System.debug('>>>>>>>>>>>>>>>>>>>'+lstCV);
                    list<Attachment> lstToinsert = new list<Attachment>();
                    for(Property_Inventory__c objprop:lstPropData){
                          string key = objprop.cm_Building__c+'###'+objprop.Unit_Position__c;
                          string key1 = objprop.cm_Building__c+'###';
                          //string key1 = objprop.Location_Code__c+'###'; //Adeel - updatied building with location code
                          system.debug('Key For Content ' + key);
                          system.debug('Key for Content ' + key1);
                          if(mpVersions.containsKey(key)){
                              for(ContentVersion cv: mpVersions.get(key)){
                                Attachment att = new attachment(name='salesOffer'+'.'+cv.FileExtension,body = cv.versionData, parentId=objProp.Id);
                                lstToinsert.add(att);
                              }
                          }
                          else if (mpVersions.containsKey(key1)) {
                              for(ContentVersion cv: mpVersions.get(key1)){
                                Attachment att = new attachment(name='salesOffer'+'.'+cv.FileExtension,body = cv.versionData, parentId=objProp.Id);
                                lstToinsert.add(att);
                              }
                          }
                          if(mpPIVersionData!=null && mpPIVersionData.get(objProp.id)!=null){
                              ContentVersion cv = mpPIVersionData.get(objProp.id);
                              Attachment att = new attachment(name='salesOffer'+'.'+cv.FileExtension,body = cv.versionData, parentId=objProp.Id);
                              lstToinsert.add(att);
                          }
                     }
                    system.debug('***lstToinsert'+lstToinsert);
                    insert lstToinsert;
                    string Ids ='';
              for(Attachment obj:lstToinsert){
                   Ids = obj.id+';'+Ids ;
              }
              if(lstToinsert.size() >0)
                 strMessage = 'success-'+Ids;
              else
                 strMessage = 'Floor Plan not found ';
            }    
        }catch(exception ex){
           strMessage = ex.getMessage(); 
        }
        return strMessage;
    }
    
    @RemoteAction
    public static string deleteContentAttachment(string idval) {
          string str = CM_EmaarUtils.DeleteContentAttachments(idval);
          return str;
    }
}