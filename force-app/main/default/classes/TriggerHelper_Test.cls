@isTest

private class TriggerHelper_Test{
     static testMethod void testActivities(){
        //Create a User
        Profile p = [SELECT Id FROM Profile WHERE Name='Property Advisor']; 
        User u = new User(Alias = 'standt', Email='standarduser@emaaregypt.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id,IsActive=True, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='tandarduser@emaaregypt.com');
        insert u;
        system.runas(u){
         //Assign Case with out any Assignment Groups
            Lead c1 = new Lead (LastName='Test',Company='Test',Email='abc@xyz.com');  
            insert c1;
            
            //Insert a task
            Task t = new Task();
            t.OwnerId = u.id;
            t.Subject='Donni';
            t.Status='Completed';
            t.Priority='Normal';
            insert t;
            
            //Try deleting the task
            try{
                delete t;
            }catch(exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.Task_Deletion) ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
        }   
     }
     static testMethod void testNotes(){
        //Create a User
        Profile p = [SELECT Id FROM Profile WHERE Name='Property Advisor']; 
        User u = new User(Alias = 'standt', Email='standarduser@emaaregypt.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id,IsActive=True, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='tandarduser@emaaregypt.com');
        insert u;
        system.runas(u){
            ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
            );
        insert contentVersionInsert;
 
            // Test INSERT
            ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert.Id LIMIT 1];
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            System.assertEquals(documents.size(), 1);
     
            // Test DELETE
            documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            try{
                delete documents;
            }catch(exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.Note_Deletion) ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
        }   
     }
}