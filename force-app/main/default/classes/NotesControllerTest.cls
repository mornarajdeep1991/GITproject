/* Test Class for NotesController */
@isTest
public class NotesControllerTest {
    public static testMethod void testNotesController(){
        Account acc = new Account();
        acc.FirstName = 'Test';
        acc.LastName = 'Account For Notes';
        insert acc;
        
        ContentNote cn = new ContentNote();
        cn.Title = 'Test Note';
        cn.Content = Blob.valueOf('Test');
        
        //create record
        NotesController.createRecord(cn, acc.id);
        NotesController.getContentNoteDetails(cn.Id);
        NotesController.getContentNotes(acc.Id);
    }
}