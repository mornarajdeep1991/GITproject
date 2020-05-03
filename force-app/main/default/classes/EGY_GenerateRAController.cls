public class EGY_GenerateRAController {
	@AuraEnabled
    public static String generateRA(String oppId){
        String packageId = Label.RA_PACKAGE_ID;
        String documentName = '';
        String deliveryMethodId = Label.RA_DELIVERY_ID;
        RestDrawloopServiceCls.generateDocument(oppId, packageId, documentName, deliveryMethodId);
        return '';
    }    
}