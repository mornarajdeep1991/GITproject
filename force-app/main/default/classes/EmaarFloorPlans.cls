/* Floorplan util class */
public without sharing class EmaarFloorPlans{

    public static ResponseHandler GetFloorPlans(string strOpporID,string Type) {
        system.debug('>>>>parameters>>>>'+strOpporID+'????'+type);
        ResponseHandler obj = new ResponseHandler();
            if(Type == 'GETFLOORPLAN'){
                try{
                    list<Opportunity> lstOppor = [select id,name,account.recordtypeId from Opportunity where id=:strOpporID];
                    if(lstOppor!=null && lstOppor.size() >0){
                        Pagereference pageRef = Page.cm_floorplans;
                        pageRef.getParameters().put('Id',strOpporID);
                        blob body = test.isRunningTest() ? blob.valueOf('String toBlob') : pageRef.getContent();
                        
                        Attachment att=new Attachment();
                        att.Body=body;
                        att.Name='Floor Plan-'+lstOppor[0].name+'.pdf';
                        att.parentId= strOpporID;
                        att.contentType = 'application/pdf';
                        insert att;

                        obj.attachmentID = att.id;
                        obj.success = true;
                        obj.status='success';
                        obj.strMessage  ='success';
                    }
                }catch(exception ex){
                  obj.success = false;
                  obj.status='Error';
                  obj.strMessage= ex.getmessage();
                }
            }
            if(Type == 'DELETE'){
                try{
                  map<id,string> mapinvdata = new map<id,string>();
                  list<Opportunity_Property__c>lstOpportunityProperty = [select id,cm_Property_Inventory__c,cm_Inventory_Location_Code__c from Opportunity_Property__c 
                                                                         where cm_Opportunity__c=:strOpporID];
                    
                  system.debug('ssssss'+lstOpportunityProperty);  
                  set<id> setIds = new set<id>();
                  if(lstOpportunityProperty!=null && lstOpportunityProperty.size()>0){
                     for(Opportunity_Property__c objprop:lstOpportunityProperty){
                         setIds.add(objprop.Id);
                     }
                   }
                   system.debug('***setIds'+setIds);
                   List<Attachment> attachedFiles = [select Id,parentId from Attachment where parentId IN:setIds  and name LIKE 'salesOffer%'  order By LastModifiedDate ];
                   delete attachedFiles;
                   obj.success = true;
                   obj.status='success';
                   obj.strMessage  = 'records deleted';
                }catch(exception ex){
                    obj.success = false;
                    obj.status='Error';
                    obj.strMessage  = ex.getmessage();
                }
                  
            }
            system.debug('>>>>>return>>>'+obj);
            return obj;
    }
    public class ResponseHandler {
        public Boolean success{get;set;}
        public string Status{get;set;}
        public string strMessage{get;set;}
        public string attachmentID{get;set;}
    }
}