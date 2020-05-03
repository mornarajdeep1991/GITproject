public class cm_FloorPlans {
    public list<AttachmentURLwrap> lstAttachmentURLwrap {get;set;}
    public string imageURL{get;set;}
public void prepareContent(){
    prepareImageURL();
    string TypeVal =  apexpages.currentPage().getParameters().get('Type');
    string strOportunityId =  apexpages.currentPage().getParameters().get('Id');
    set<id> setIds = new set<id>();
    map<id,string> mapinvdata = new map<id,string>();

    if(TypeVal!=null && TypeVal=='InventoryfloorPlan'){
        setIds.add(strOportunityId);
    }else{
        string strMessage = CM_EmaarUtils.CreateContentAttachments(strOportunityId);
        if(strMessage.contains('success')){
              list<Opportunity_Property__c>lstOpportunityProperty = [select id,cm_Property_Inventory__c,cm_Inventory_Location_Code__c from Opportunity_Property__c where cm_Opportunity__c=:strOportunityId];
              if(lstOpportunityProperty!=null && lstOpportunityProperty.size()>0){
                 for(Opportunity_Property__c objprop:lstOpportunityProperty){
                     setIds.add(objprop.Id);
                     mapinvdata.put(objprop.cm_Property_Inventory__c,objprop.cm_Inventory_Location_Code__c);
                 }
               }
               system.debug('***setIds'+setIds);
                //CM_EmaarUtils.DeleteContentAttachments(strMessage);
        }
     }
     if(setIds!=null && setIds.size() >0){
           List<Attachment> attachedFiles = [select Id,parentId from Attachment where parentId IN:setIds  and name LIKE 'salesOffer%'  order By LastModifiedDate ];
           lstAttachmentURLwrap = new list<AttachmentURLwrap>();
           for(Attachment objAttachment:attachedFiles){
                AttachmentURLwrap objwrap = new AttachmentURLwrap();
                objwrap.strURL = URL.getSalesforceBaseUrl().toExternalForm() +'/servlet/servlet.FileDownload?file='+objAttachment.id;
                objwrap.strURL = objwrap.strURL.replace('visual', 'content');
                if(mapinvdata!=null && mapinvdata.get(objAttachment.parentId)!=null)
                    objwrap.Unit = mapinvdata.get(objAttachment.parentId);
                lstAttachmentURLwrap.add(objwrap);
            }
            system.debug('****lstAttachmentURLwrap'+lstAttachmentURLwrap); 
      }
}
public void prepareImageURL(){
    imageURL= CM_EmaarUtils.prepareImageURL();
   
  }
 public class AttachmentURLwrap{
     public string strURL {get;set;}
     public string Unit {get;set;}
 }
}