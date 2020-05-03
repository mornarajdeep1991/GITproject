/**
 * @who     : Sri vijitha (sri.mutyala@weare4c.com)
 * @when    : 13/03/2019
 * @what    : Controller for the upload document functionality for the specific account id passed in the URL
 */

public without sharing class BrokerDocumentsController{

    public List<Document__c> docLists{get;set;}
    public Integer supportId {get; set;}
    public List<wrapperUpload> wrapperUploadList{get;set;}
    private Id recordId {get; set;}
    public String relatedRecordName {get; set;}
    
    public BrokerDocumentsController(){
        recordId = ApexPages.currentPage().getParameters().get('id');
        wrapperUploadList = new List<wrapperUpload>();
        docLists();
    }

    public void docLists(){    
        if(recordId != null){
           String query = 'SELECT id,Account__c, Contact__c, Account__r.Name, Contact__r.Name, Name__c,Accepted__c,'+
               			  'Rejection_Reason__c,Pending_Broker_Document_Resubmission__c,SendMail__c,Receipt_Status__c,'+
               			  '(SELECT Id, Name, ParentId  FROM Attachments order by createddate desc limit 1)'+
               			  'FROM Document__c';
           String whereClause = ' WHERE ';
           if(String.valueOf(recordId).startsWith('001')){
                whereClause += ' Account__r.id =:recordId AND Contact__c = null';
               	relatedRecordName = [SELECT Id, Name FROM Account WHERE Id=:recordId].Name;
           }else{
               whereClause += ' Contact__r.Id =:recordId ';
               relatedRecordName = [SELECT Id, Name FROM Contact WHERE Id=:recordId].Name;
           }
           query += whereClause;
           for(Document__c suportDocu : Database.query(query)){       
               wrapperUpload newObj = new wrapperUpload();
               newObj.supportObj = suportDocu;
               newObj.Attachment = new Attachment();
               if(suportDocu.Attachments.size()>0){
                   newObj.Attachment = suportDocu.Attachments;
                   newObj.Attachment.body = null;
               }
               DocumentWrapper wrp = new DocumentWrapper();
               wrp.Accepted = suportDocu.Accepted__c;
               wrp.Name = suportDocu.Name__c;
               wrp.Rejection_Reason = suportDocu.Rejection_Reason__c;
               wrp.Pending_Broker_Document_Resubmission = suportDocu.Pending_Broker_Document_Resubmission__c;
               wrp.SendMail = suportDocu.SendMail__c;
               wrp.Receipt_Status = suportDocu.Receipt_Status__c;
               if(suportDocu.Attachments.size() > 0){
                wrp.AttachmentName = suportDocu.Attachments[0].Name;
                wrp.AttachmentId = suportDocu.Attachments[0].Id;
               }
               newObj.documentWrp = wrp;

               wrapperUploadList.add(newObj);
           } 
        }
      } 
      
     public PageReference upload(){
        PageReference pr;
        List<Document__c> sdocList = new List<Document__c>();
        List<Attachment> attachmentList = new List<Attachment>();     
        wrapperUpload docLists = wrapperUploadList[supportId];        
        List<Attachment> attList = [Select ID, ParentID, body, Name from Attachment Where parentID =: docLists.supportObj.id and id != :docLists.Attachment.id];
        
        if(attList.size()>0){
            delete attList;
        }
                
        if(docLists.Attachment.body != null){
            if(docLists.Attachment.parentId == null){
                docLists.Attachment.parentId = docLists.supportObj.id;
            }
            docLists.supportObj.SendMail__c = true;
            docLists.supportObj.Accepted__c = null;
            docLists.supportObj.Rejection_Reason__c = null;
            docLists.supportObj.Receipt_Status__c = 'Yes';
            docLists.supportObj.Pending_Broker_Document_Resubmission__c = false;
            attachmentList.add(docLists.Attachment);
            sdocList.add(docLists.supportObj);
        }
       
       if(attachmentList.size()>0){
           try{
               upsert attachmentList;
               upsert sdocList;
               wrapperUploadList[supportId].Attachment.body = null;                      
               pr = Page.BrokerDocuments;
               pr.getParameters().put('Id', recordId);
               pr.setRedirect(true);
           }catch(exception e) {
               ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment: '+e));
               pr = null;
           }
       }
       return pr;
    }
    
    public class wrapperUpload{
        public Document__c supportObj{get;set;}
        public Attachment Attachment{get;set;}
        public DocumentWrapper documentWrp {get; set;}
    }

    public class DocumentWrapper{
      public Id documentId {get; set;}
      public String Name {get; set;}
      public String Accepted {get; set;}
      public String Rejection_Reason {get; set;}
      public Boolean Pending_Broker_Document_Resubmission {get; set;}
      public Boolean SendMail {get; set;}
      public String Receipt_Status {get; set;}
      public String AttachmentName {get; set;}
      public Id AttachmentId {get; set;}
    }
}