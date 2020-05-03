/************************************************************************************
* Name              : EGY_AddEOIController                                                
* Description       : Class for lightning component EGY_AddExpressionOfInterest to generate and adding receipt to opportunity.                                           
* Created Date      : 15/05/2018                                                     
* Created By        : Adeel Ahmad  (4C)    
* Jira/Req By       :                                                                                                                                           
************************************************************************************/
public with sharing class EGY_AddEOIController {
	//Method to initiaize the receipt record which is going to be inserted.
	@AuraEnabled
	public static Reciepts__c initReceipt(Id opId){
		Reciepts__c r = new Reciepts__c();
		r.Opportunity__c = opId;
		r.Currency__c = 'EGP';
		r.Exchange_Rate__c = 1.00;
		r.Reciept_Date__c = Date.today();
		return r;
	}

	//Method to get opportunity property (offer) info
	@AuraEnabled
	public static Opportunity getOpportunityInfo(Id opId){
		Opportunity opp = [SELECT id, Name FROM Opportunity WHERE Id = :opId];
		return opp;
	}

	/* Method to get the filter options */
    @AuraEnabled
    public static Map<String, String> fetchFieldOptions(string filter, string building){
        Map<String, String> fieldOptions = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult;
        fieldOptions.put('', '--None--');

        if(filter == 'Installment_Details__c'){
        	fieldResult = Reciepts__c.Installment_Details__c.getDescribe();
        }

        if(filter == 'Currency__c'){
        	fieldResult = Reciepts__c.Currency__c.getDescribe();
        }

        if(filter == 'cm_Paid_By__c'){
        	fieldResult = Reciepts__c.cm_Paid_By__c.getDescribe();
        }

        if(filter == 'Payment_Mode__c'){
        	fieldResult = Reciepts__c.Payment_Mode__c.getDescribe();
        }

        if(filter == 'Financier_Name__c'){
        	fieldResult = Reciepts__c.Financier_Name__c.getDescribe();
        }

        if(filter == 'Purpose__c'){
        	fieldResult = Reciepts__c.Purpose__c.getDescribe();
        }

        if(filter == 'Sales_Office__c'){
            fieldResult = Reciepts__c.Sales_Office__c.getDescribe();
        }

        if(filter == 'PaymentMethod'){
	        list<Payment_Methods__c> lst = [select id,Receipt_Method__c from Payment_Methods__c where Expression_Of_Interest__c=true ];
	        for(Payment_Methods__c objPayM : lst){
	           string value = objPayM.Receipt_Method__c.escapeHtml3().replace('&', '');
	           fieldOptions.put(value,value);
	        }
    	}else{
			list<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for( Schema.PicklistEntry f : ple){
				if(f.getValue() != 'NA'){
				    fieldOptions.put(f.getLabel(),f.getValue());
				}
			}
    	}
        return fieldOptions;
    }

    //method to create receipt and expression of interest
    @AuraEnabled
    public static String createReceiptAndAddEOI(Reciepts__c recp, Id opId){
    	String msg = '';
    	//First create party in oracle for expression of interest
        String resp = '';
        if(!Test.isRunningTest()){
           resp = EmaarBookingProcess.CreateParty_ExpressionOfInterest(opId);
        }else{
            resp = '1122'; //Customer number for test class
        }
    	//if party gets created, make expression of request call
    	if(resp != 'ERROR'){
    		//it will returns the customer number which is going to be sent in receipt call.
    		recp.Type__c = 'Expression of Interest';
    		insert recp;
    		getReceiptForEOI(recp.Id, resp);
    	}else{
    		msg = 'Error! Can not create party in oracle.';
    	}
    	return msg;
    }

    @future (callout = true)
    public static void getReceiptForEOI(Id receiptId, String customerNumber){
    	String msg = '';
    	emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objResponse = new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
    	try{
    		Integer orgId = 127;
    		Reciepts__c recp = [SELECT ConnectionReceivedId, ConnectionSentId, Account_Email__c, Account_Name__c, Amount__c, Amount_in_Words__c, 
    						Cash_Receipt_Id__c, Cheque_Number__c, Collection_Center__c, Company_Name__c, Comments__c, Country__c, Customer_Number__c, 
    						Currency__c, Document_Number__c, Drawn_on_Bank__c, Exchange_Rate__c, Fax__c, Financier_Name__c, GL_Date__c, Installment_Details__c, 
    						Is_From_Online_Sales__c, Maturity_Date__c, Maturity_Date_display__c, Mode_Of_Payment__c, Moved_to_Oracle__c, No_of_Bedrooms__c, 
    						Opportunity__c, Org_Name__c, PO_Box__c, Payment_Mode__c, Purpose__c, REJECTION_REASON__c, Receipt_Amount__c, Receipt_Method__c, 
    						Receipt_STATUS__c, Received_by__c, Reciept_Date__c, Reciept_Number__c, Reciept_Payment_Mode__c, Reversal_Date__c, Sales_Admin_Email__c, 
    						Telephone__c, Total_Amount__c, Unit_No__c, cm_Account_Name__c, cm_KeyToSend__c, cm_Location_Code__c, cm_Location_ID__c, cm_Opportunity_Property__c, 
    						cm_Paid_By__c, Cheque_Receipt_Approval__c, Opportunity_Payment__c, Status__c, Type__c, Sales_Office__c 
    						FROM Reciepts__c
    						WHERE Id =:receiptId];
            if(!Test.isRunningTest()){
                objResponse = EmaarWebServiceUtils.executePerformConcurrentAction_GETRECIEPT_EOI(recp,customerNumber,orgId);
            }else{
                objResponse.status = 'SUCCESS';
                string strXML =  '<P_RESULT_XML><XX_SALES_LAUNCH xmlns=""><XX_RECEIPT_DATA_T><XX_RECEIPT_DATA_O><RECEIPT_BATCH_ID>5241</RECEIPT_BATCH_ID><ORG_ID>81</ORG_ID><CASH_RECEIPT_ID>19152676</CASH_RECEIPT_ID><RECEIPT_NUMBER>1234</RECEIPT_NUMBER><ORG_NAME>Emaar Development PJSC</ORG_NAME><CURRENCY_CODE>AED</CURRENCY_CODE><AMOUNT>1234</AMOUNT><RECEIPT_DATE>2016-05-11</RECEIPT_DATE><CUSTOMER_NUMBER>231909</CUSTOMER_NUMBER><DOCUMENT_NUMBER>4038329</DOCUMENT_NUMBER><AMOUNT_IN_WORDS>Thousand two hundred thirty-four Dirhams And 00 Fils</AMOUNT_IN_WORDS><MODE_OF_PAYMENT>Cheque</MODE_OF_PAYMENT><MATURITY_DATE>2016-05-11</MATURITY_DATE><FINANCIER_NAME>NIL</FINANCIER_NAME><COMMENTS>asdf</COMMENTS><COMPANY_NAME>Emaars</COMPANY_NAME><PO_BOX>PO Box No: 9440, Downtown, Dubai,</PO_BOX><COUNTRY>U.A.E</COUNTRY><TELEPHONE>+971-4-3673333</TELEPHONE><FAX>+971-4-3673793</FAX><CREATED_BY_USER>OnlineSales</CREATED_BY_USER></XX_RECEIPT_DATA_O></XX_RECEIPT_DATA_T></XX_SALES_LAUNCH></P_RESULT_XML>';
                objResponse.resultXML = strXML;
            }


	        if(objResponse.status=='ERROR'){
	        	msg = objResponse.ErrorMessage;
	        }else{
		        recp.Cash_Receipt_Id__c = CM_EmaarUtils.getValueFromXMLString(objResponse.resultXML,'CASH_RECEIPT_ID');
		        recp.Customer_Number__c = CM_EmaarUtils.getValueFromXMLString(objResponse.resultXML,'CUSTOMER_NUMBER');
		        recp.Document_Number__c = CM_EmaarUtils.getValueFromXMLString(objResponse.resultXML,'DOCUMENT_NUMBER');
		        recp.Amount_in_Words__c = CM_EmaarUtils.getValueFromXMLString(objResponse.resultXML,'AMOUNT_IN_WORDS');
		        recp.Mode_Of_Payment__c = CM_EmaarUtils.getValueFromXMLString(objResponse.resultXML,'MODE_OF_PAYMENT');
		        recp.Company_Name__c = CM_EmaarUtils.getValueFromXMLString(objResponse.resultXML,'COMPANY_NAME');
		        recp.PO_Box__c = CM_EmaarUtils.getValueFromXMLString(objResponse.resultXML,'PO_BOX');
		        recp.Country__c = CM_EmaarUtils.getValueFromXMLString(objResponse.resultXML,'COUNTRY');
		        recp.Telephone__c = CM_EmaarUtils.getValueFromXMLString(objResponse.resultXML,'TELEPHONE');
		        recp.Fax__c = CM_EmaarUtils.getValueFromXMLString(objResponse.resultXML,'FAX');

	            recp.Received_by__c = userinfo.getUserId();
	            System.debug('@@future:recp'+recp);
	            upsert recp;    		

	            //Update opportunity
	            Opportunity updateableOpp = [SELECT Id FROM Opportunity WHERE Id =: recp.Opportunity__c];
	            updateableOpp.Expression_of_Interest__c = true;
	            upsert updateableOpp;
	            msg = 'SUCCESS';   			
			}
		}catch(Exception e){
			Reciepts__c recp = [SELECT Id FROM Reciepts__c WHERE Id =:receiptId];
			delete recp;
			msg = 'Error! ' + e.getMessage();
		}
    	//return msg;
    }

}