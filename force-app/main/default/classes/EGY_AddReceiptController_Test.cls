/***********************************************************************************************
* Name              : EGY_AddReceiptController_Test                                                 
* Description       : Test class for EGY_AddReceiptController                                             
* Created Date      : 01/06/2018                                                    
* Created By        : Adeel Ahmad (adeel.ahmad@weare4c.com)    
* Jira/Req By       :                                                                                                                                         
* ----------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
* 1.0       Adeel       01/06/2018  Created                              
************************************************************************************************/
@IsTest
public class EGY_AddReceiptController_Test {
	static testMethod void Test_AddReceipt() {
		Id unitRecordTypeId =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        insert objLoc;

        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonMailingCountry ='United Arab Emirates';
        insert objAccount;
                
        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount.id;
        insert objOppor;

        Property_Inventory__c objProINV = TestDataFactory.CreatePropertyInventory(objLoc.id);
        Property_Inventory__c objProINV1 = TestDataFactory.CreatePropertyInventory(objLoc.id);
        objProINV.recordTypeId =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        objProINV.Instance__c = 'test';
        insert objProINV;
        
        Opportunity_Property__c OpporProp = TestDataFactory.CreateOpportunityProperty(objOppor.id,objProINV.id);
        insert OpporProp;
        
        Payment_Methods__c objPM =new Payment_Methods__c();
        objPM.Building__c ='build';
        objPM.Receipt_Method__c ='build';
        objPM.Property__c = 'PROP';
        insert objPM;

        Reciepts__c recp =  EGY_AddReceiptController.initReceipt(OpporProp.Id);
        System.assert(recp != null);

        Opportunity_Property__c oppropertyInfo = EGY_AddReceiptController.getOpportunityPropertyInfo(OpporProp.Id);
        System.assert(oppropertyInfo.id != null);
        
        MAP<String, String> installmentDetailsFld = EGY_AddReceiptController.fetchFieldOptions('Installment_Details__c', '');
        MAP<String, String> currencyFld = EGY_AddReceiptController.fetchFieldOptions('Currency__c', '');
        MAP<String, String> paidByFld = EGY_AddReceiptController.fetchFieldOptions('cm_Paid_By__c', '');
        MAP<String, String> paymentModeFld = EGY_AddReceiptController.fetchFieldOptions('Payment_Mode__c', '');
        MAP<String, String> financierNameFld = EGY_AddReceiptController.fetchFieldOptions('Financier_Name__c', '');
        MAP<String, String> purposeFld = EGY_AddReceiptController.fetchFieldOptions('Purpose__c', '');
        MAP<String, String> paymentMethodFld = EGY_AddReceiptController.fetchFieldOptions('PaymentMethod', 'build');
		
        recp.Installment_Details__c = String.valueOf(installmentDetailsFld.values()).split(',')[1];
        recp.Currency__c = String.valueOf(currencyFld.values()).split(',')[1];
        recp.Payment_Mode__c = String.valueOf(paymentModeFld.values()).split(',')[1];
        recp.Financier_Name__c = String.valueOf(financierNameFld.values()).split(',')[1];
        recp.Purpose__c = String.valueOf(purposeFld.values()).split(',')[1];
        
        String status = EGY_AddReceiptController.createAndAddReceipt(recp, objOppor.Id);
        System.assert(status == 'SUCCESS');
        
        LIST<Reciepts__c> addedReceipts = EGY_AddReceiptController.getAddedReceipts(OpporProp.Id);
        System.assert( addedReceipts.size() > 0);

    }
}