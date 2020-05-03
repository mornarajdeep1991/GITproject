/**
* Apex controller for lightning component 'Notes'
*
* @Date: 09/12/2018
* @Author: Adeel Ahmad (adeel.ahmad@weare4c.com)
*
* @TestClass : NotesControllerTest
*/
public class NotesController {
    @AuraEnabled
    public static LIST<ContentNote> getContentNotes(String objId){
        LIST<ContentNote> contentNotes = new LIST<ContentNote>();
        LIST<Id> contentDocumentIds = new LIST<Id>();
        for(ContentDocumentLink cdl : [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId =:objId]){
            contentDocumentIds.add(cdl.ContentDocumentId);
        }

        if(contentDocumentIds.size() > 0){
            contentNotes = [SELECT Id, Title, FileType, TextPreview, IsDeleted, Content,CreatedById, CreatedDate,CreatedBy.Name 
                            FROM ContentNote
                            WHERE FileType = 'SNOTE' AND Id IN:contentDocumentIds ORDER BY Id DESC ];
        }
        return contentNotes;
    }

    @AuraEnabled
    public static NoteWrapper getContentNoteDetails(Id recordId){
        NoteWrapper nWrapper = new NoteWrapper();
        nWrapper.cn  = [SELECT Id, Title, TextPreview, Content,CreatedById, CreatedDate,CreatedBy.Name 
                FROM ContentNote WHERE Id =:recordId];
        nWrapper.noteBody = nWrapper.cn.Content.toString();
        return nWrapper;

    }

    public class NoteWrapper{
        @AuraEnabled
        public ContentNote cn {get; set;}

        @AuraEnabled
        public String noteBody {get; set;}
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