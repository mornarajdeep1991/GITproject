/***********************************************************************************************
* Name              : EGY_AddEOIController_Test                                                 
* Description       : Test class for EGY_AddEOIController                                             
* Created Date      : 01/06/2018                                                    
* Created By        : Adeel Ahmad (adeel.ahmad@weare4c.com)    
* Jira/Req By       :                                                                                                                                         
* ----------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
* 1.0       Adeel       01/06/2018  Created                              
************************************************************************************************/
@IsTest
public with sharing class EGY_AddEOIController_Test {
	static testMethod void Test_EGY_AddEOIController_Test() {
		Id unitRecordTypeId =Schema.SObjectType.Property_Inventory__c.getRecordTypeInfosByName().get('Unit').getRecordTypeId();
        Location__c objLoc = TestDataFactory.CreateLocation('U');
        insert objLoc;

        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonMailingCountry ='United Arab Emirates';
        insert objAccount;
                
        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount.id;
        insert objOppor;

        Payment_Methods__c objPM =new Payment_Methods__c();
        objPM.Building__c ='build';
        objPM.Receipt_Method__c ='build';
        objPM.Property__c = 'PROP';
        objPM.Expression_Of_Interest__c = true;
        insert objPM;

        Reciepts__c recp =  EGY_AddEOIController.initReceipt(objOppor.Id);
        System.assert(recp != null);
        
        Opportunity opInfo = EGY_AddEOIController.getOpportunityInfo(objOppor.Id);
        System.assert(opInfo.Id != null);

        MAP<String, String> installmentDetailsFld = EGY_AddEOIController.fetchFieldOptions('Installment_Details__c', '');
        MAP<String, String> currencyFld = EGY_AddEOIController.fetchFieldOptions('Currency__c', '');
        MAP<String, String> paidByFld = EGY_AddEOIController.fetchFieldOptions('cm_Paid_By__c', '');
        MAP<String, String> paymentModeFld = EGY_AddEOIController.fetchFieldOptions('Payment_Mode__c', '');
        MAP<String, String> financierNameFld = EGY_AddEOIController.fetchFieldOptions('Financier_Name__c', '');
        MAP<String, String> purposeFld = EGY_AddEOIController.fetchFieldOptions('Purpose__c', '');
        MAP<String, String> paymentMethodFld = EGY_AddEOIController.fetchFieldOptions('PaymentMethod', '');
		
        recp.Installment_Details__c = String.valueOf(installmentDetailsFld.values()).split(',')[1];
        recp.Currency__c = String.valueOf(currencyFld.values()).split(',')[1];
        recp.Payment_Mode__c = String.valueOf(paymentModeFld.values()).split(',')[1];
        recp.Financier_Name__c = String.valueOf(financierNameFld.values()).split(',')[1];
        recp.Purpose__c = String.valueOf(purposeFld.values()).split(',')[1];
        
        String status = EGY_AddEOIController.createReceiptAndAddEOI(recp, objOppor.Id);
        System.assert(status == ''); //If status doesn't contains error

    }
}