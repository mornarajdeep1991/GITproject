/*
Test Class for : Content
*/
@isTest
public class TestClassUtilitySetUpContentObj {
    
    @testSetup public static void setupData() {
        try{            
            ContentVersion content=new ContentVersion(); 
            content.Title='testCV'; 
            content.PathOnClient='/' + content.Title + '.jpg'; 
            Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
            content.VersionData=bodyBlob; 
            //content.LinkedEntityId=sub.id;
            content.origin = 'H';
            content.Make_Public__c = true;
            insert content;
        }
        catch(exception ex){
            system.debug('Exception -->'+ ex.getMessage());
        }
    }
}