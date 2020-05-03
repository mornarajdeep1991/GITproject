public class GenerateRegistrationDocumentCls {

    @AuraEnabled
    public static void doAction(String objectID){
    	RestDrawloopServiceCls.GenerateDDP(objectID,'a0i4E000008uVLg','Registration of Expression of Interest','a0g4E00000PSkFO'); 
      //  RestDrawloopServiceCls.GenerateDDP(objectID,'a0s1r00000NThK5','Registration of Expression of Interest','a0q1r00000MukDM');
    }
}