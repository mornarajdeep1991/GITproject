/************************************************************************************
* Name              : EGY_AddReceiptController                                                
* Description       : Class for lightning component EGY_AddReceipt to generate and adding receipt to offer.                                           
* Created Date      : 14/05/2018                                                     
* Created By        : Adeel Ahmad  (4C)    
* Jira/Req By       :                                                                                                                                           
************************************************************************************/
public with sharing class EGY_AddReceiptController {
	//Method to initiaize the receipt record which is going to be inserted.
	@AuraEnabled
	public static Reciepts__c initReceipt(Id opId){
		Reciepts__c r = new Reciepts__c();
		r.cm_Opportunity_Property__c = opId;
		r.Currency__c = 'EGP';
		r.Exchange_Rate__c = 1.00;
		r.Reciept_Date__c = Date.today();
		return r;
	}

	//Method to get opportunity property (offer) info
	@AuraEnabled
	public static Opportunity_Property__c getOpportunityPropertyInfo(Id opId){
		Opportunity_Property__c op = [SELECT id, cm_Inventory_Location_Code__c, Building__c, cm_Opportunity__c FROM Opportunity_Property__c WHERE Id = :opId];
		return op;
	}

	//Method to get receipt for any opportunity property id
	@AuraEnabled
	public static LIST<Reciepts__c> getAddedReceipts(Id opId){
		LIST<Reciepts__c> receipts = [select id,name,cm_Opportunity_Property__c,cm_Location_ID__c, Payment_Mode__c,Cheque_Number__c,
										cm_Location_Code__c, Amount__c,Comments__c,Currency__c,Exchange_Rate__c,Installment_Details__c,cm_Paid_by__c,
										Purpose__c,Reciept_Date__c,Reciept_Number__c,Reciept_Payment_Mode__c, Sales_Office__c 
										FROM Reciepts__c 
										WHERE cm_Opportunity_Property__c=:opId];
		return receipts;
	}

	/* Method to get the filter options */
    @AuraEnabled
    public static Map<String, String> fetchFieldOptions(string filter, string building){
        Map<String, String> fieldOptions = new Map<String, String>();
        fieldOptions.put('', '--None--');

        if(filter == 'PaymentMethod'){
        	System.debug('@@building='+building);
	        list<Payment_Methods__c> lst = [select id,Property__c,Building__c,Receipt_Method__c from Payment_Methods__c where Building__c=:building ];
	        for(Payment_Methods__c objPayM : lst){
	           string value = objPayM.Receipt_Method__c.escapeHtml3();
	           fieldOptions.put(value,value);
	        }
	        return fieldOptions;
        }

        if(filter == 'Installment_Details__c'){
        	Schema.DescribeFieldResult fieldResult = Reciepts__c.Installment_Details__c.getDescribe();
			list<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for( Schema.PicklistEntry f : ple){
				if(f.getValue() != 'NA'){
				    fieldOptions.put(f.getLabel(),f.getValue());
				}
			}
        }

        if(filter == 'Currency__c'){
        	Schema.DescribeFieldResult fieldResult = Reciepts__c.Currency__c.getDescribe();
			list<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for( Schema.PicklistEntry f : ple){
				if(f.getValue() != 'NA'){
				    fieldOptions.put(f.getLabel(),f.getValue());
				}
			}
        }

        if(filter == 'cm_Paid_By__c'){
        	Schema.DescribeFieldResult fieldResult = Reciepts__c.cm_Paid_By__c.getDescribe();
			list<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for( Schema.PicklistEntry f : ple){
				if(f.getValue() != 'NA'){
				    fieldOptions.put(f.getLabel(),f.getValue());
				}
			}
        }

        if(filter == 'Payment_Mode__c'){
        	Schema.DescribeFieldResult fieldResult = Reciepts__c.Payment_Mode__c.getDescribe();
			list<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for( Schema.PicklistEntry f : ple){
				if(f.getValue() != 'NA'){
				    fieldOptions.put(f.getLabel(),f.getValue());
				}
			}
        }

        if(filter == 'Financier_Name__c'){
        	Schema.DescribeFieldResult fieldResult = Reciepts__c.Financier_Name__c.getDescribe();
			list<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for( Schema.PicklistEntry f : ple){
				if(f.getValue() != 'NA'){
				    fieldOptions.put(f.getLabel(),f.getValue());
				}
			}
        }

        if(filter == 'Purpose__c'){
        	Schema.DescribeFieldResult fieldResult = Reciepts__c.Purpose__c.getDescribe();
			list<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for( Schema.PicklistEntry f : ple){
				if(f.getValue() != 'NA'){
				    fieldOptions.put(f.getLabel(),f.getValue());
				}
			}
        }

        if(filter == 'Sales_Office__c'){
        	Schema.DescribeFieldResult fieldResult = Reciepts__c.Sales_Office__c.getDescribe();
			list<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for( Schema.PicklistEntry f : ple){
				if(f.getValue() != 'NA'){
				    fieldOptions.put(f.getLabel(),f.getValue());
				}
			}        	
        }

        return fieldOptions;
    }

    //method to add receipt, call the service and update the receipt id on receipt
    @AuraEnabled
    public static String createAndAddReceipt(Reciepts__c recp, Id opId){
    	System.debug('@@recp'+recp);
    	String msg = '';
    	emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objResponse = new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
    	try{
	        if(!Test.isRunningTest()){
	             objResponse = EmaarWebServiceUtils.executePerformConcurrentAction_GETRECIEPT(recp, opId);
	        }else{
	            objResponse.status = 'SUCCESS';
	            string strXML =  '<P_RESULT_XML><XX_SALES_LAUNCH xmlns=""><XX_RECEIPT_DATA_T><XX_RECEIPT_DATA_O><RECEIPT_BATCH_ID>5241</RECEIPT_BATCH_ID><ORG_ID>81</ORG_ID><CASH_RECEIPT_ID>19152676</CASH_RECEIPT_ID><RECEIPT_NUMBER>1234</RECEIPT_NUMBER><ORG_NAME>Emaar Development PJSC</ORG_NAME><CURRENCY_CODE>AED</CURRENCY_CODE><AMOUNT>1234</AMOUNT><RECEIPT_DATE>2016-05-11</RECEIPT_DATE><CUSTOMER_NUMBER>231909</CUSTOMER_NUMBER><DOCUMENT_NUMBER>4038329</DOCUMENT_NUMBER><AMOUNT_IN_WORDS>Thousand two hundred thirty-four Dirhams And 00 Fils</AMOUNT_IN_WORDS><MODE_OF_PAYMENT>Cheque</MODE_OF_PAYMENT><MATURITY_DATE>2016-05-11</MATURITY_DATE><FINANCIER_NAME>NIL</FINANCIER_NAME><COMMENTS>asdf</COMMENTS><COMPANY_NAME>Emaars</COMPANY_NAME><PO_BOX>PO Box No: 9440, Downtown, Dubai,</PO_BOX><COUNTRY>U.A.E</COUNTRY><TELEPHONE>+971-4-3673333</TELEPHONE><FAX>+971-4-3673793</FAX><CREATED_BY_USER>OnlineSales</CREATED_BY_USER></XX_RECEIPT_DATA_O></XX_RECEIPT_DATA_T></XX_SALES_LAUNCH></P_RESULT_XML>';
	            objResponse.resultXML = strXML;
	        }
	        if(objResponse.status=='ERROR'){
	        	msg = objResponse.ErrorMessage;
	        }else{
	            system.debug('***objResponse'+objResponse.resultXML);
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

	            //recp.Opportunity__c = strOpporId;
	            recp.Received_by__c = userinfo.getUserId();
	            //objReciept.CurrencyISOCode = objReciept.Currency__c;
	            //System.debug('>>>>>>>After>>>>>>>>>>'+objReciept.Maturity_Date__c+'>>>>>>>>>>>>>>>>>>'+objReciept.Gl_date__c);
	            insert recp;    		
	            msg = 'SUCCESS';
    		}
    	}catch(Exception e){
    		msg = 'Error! ' + e.getMessage();
    	}
    	return msg;
    }


}