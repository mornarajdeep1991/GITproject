public class ChangePaymentPlanWebserviceUtils {
    @future(callout = true)
    public static void SynctoOracle(string specialApprovalId,string strOppId){
        SavePoint backup;
        try{
            string requestXML = '<CAMPAIGN_HDR>';
            string LocatinCode ='';
            string propInVId ='';
            string oPPpropId ='';
            list<Opportunity_Property__c> lstOpporProperties  = [select id,LR_Waiver__c,Final_Price__c,Adjusted_Amount__c,Price__c,
                                                                 Discount_Price_Adjustment_Status__c,Percentage__c,Sales_Order__c,Project_Name__c,
                                                                 cm_Opportunity__r.Account.cm_Nationality__pc, Campaign_Id__c,
                                                                 Campaign_Type__c, Campaign_Map_Id__c, Campaign_Price__c, 
                                                                 Is_Payment_Plan_Changed__c,
                                                                 Original_Booking_Price__c,Booking_Price__c, Original_Campaign_Price__c,
                                                                 cm_Order_Status__c,LR_Waiver_New__c,cm_Inventory_Location_Code__c,
                                                                 name,cm_Opportunity__c,cm_Opportunity__r.name,
                                                                 cm_Property_Inventory__c,cm_Property_Inventory__r.Selling_Price__c,cm_Property_Inventory__r.Location_Code__c,
                                                                 cm_Property_Inventory__r.VAT_Rate__c,cm_Unit__c from Opportunity_Property__c where 
                                                                 cm_Opportunity__c=:strOppId order by cm_Order_Date__c DESC];
            
            list<Payment_Terms__c> lstPaymentTerms = [select Id, Installment__c, cm_Net_Percent__c, cm_Schedule_Type__c, cm_Term_Date__c, 
                                                      Installment_Amount__c, Maintnance_Price__c, Special_Approval__r.Discount_type__c
                                                      from Payment_Terms__c 
                                                      where  Special_Approval__c = :specialApprovalId
                                                      ORDER BY Installment__c ASC
                                                     ];
            decimal maintenancePercetage = 0;
            for(Payment_Terms__c p : lstPaymentTerms){
                if(p.Maintnance_Price__c != null && p.Maintnance_Price__c > 0){
                    maintenancePercetage += decimal.valueOf(p.cm_Net_Percent__c);
                }
            }
            requestXML += '<CAMPAIGN_ID>'+lstOpporProperties[0].Campaign_Id__c+'</CAMPAIGN_ID>';
            requestXML += '<CAMPAIGN_NAME>'+lstOpporProperties[0].Campaign_Type__c+'</CAMPAIGN_NAME>';
            requestXML += '<CAMPAIGN_TYPE>'+lstOpporProperties[0].Campaign_Type__c+'</CAMPAIGN_TYPE>';
            requestXML += '<CAMPAIGN_MAP_ID>'+lstOpporProperties[0].Campaign_Map_Id__c+'</CAMPAIGN_MAP_ID>';
            requestXML += '<CAMPAIGN_PRICE>'+lstOpporProperties[0].Campaign_Price__c+'</CAMPAIGN_PRICE>';
            requestXML += '<ORDER_NUMBER>'+lstOpporProperties[0].Sales_Order__c+'</ORDER_NUMBER>';
            requestXML += '<Is_Paymentplan_Changed>'+lstOpporProperties[0].Is_Payment_Plan_Changed__c+'</Is_Paymentplan_Changed>';
            requestXML += '<MAINTENANCE_PERCENTAGE>'+maintenancePercetage+'</MAINTENANCE_PERCENTAGE>';
            requestXML += '<EM_TERMS>A</EM_TERMS>';
            if(lstOpporProperties[0].Campaign_Price__c < lstOpporProperties[0].Original_Campaign_Price__c && lstOpporProperties[0].Original_Campaign_Price__c - lstOpporProperties[0].Campaign_Price__c > 0.01){
                //There is a discount
                decimal discountAmount = lstOpporProperties[0].Original_Campaign_Price__c - lstOpporProperties[0].Campaign_Price__c;
                requestXML += '<DISCOUNT_ADJUSTMENT>';
                requestXML += '<ADJUSTMENT_TYPE>Discount</ADJUSTMENT_TYPE>';
                requestXML += '<ADJUSTMENT_AMOUNT>'+ discountAmount + '</ADJUSTMENT_AMOUNT>';
                requestXML += '<ADJUSTMENT_STATUS>Approved</ADJUSTMENT_STATUS>';
                requestXML += '<DISCOUNT_TYPE>'+lstPaymentTerms[0].Special_Approval__r.Discount_type__c+'</DISCOUNT_TYPE>';
                requestXML += '</DISCOUNT_ADJUSTMENT>';
            }else{
                requestXML += '<DISCOUNT_ADJUSTMENT>';
                requestXML += '<ADJUSTMENT_TYPE>PRICE_ADJUSTMENT</ADJUSTMENT_TYPE>';
                requestXML += '<ADJUSTMENT_AMOUNT></ADJUSTMENT_AMOUNT>';
                requestXML += '<ADJUSTMENT_STATUS>Approved</ADJUSTMENT_STATUS>';
                requestXML += '<DISCOUNT_TYPE></DISCOUNT_TYPE>';
                requestXML += '</DISCOUNT_ADJUSTMENT>';
            }
            integer iMaaintenance = 0;
            integer iInstallment = 0;
            for(Payment_Terms__c pt : lstPaymentTerms){
                if(pt.Maintnance_Price__c > 0){
                    iMaaintenance = iMaaintenance+1;
                }else{
                    iInstallment = iInstallment+1;
                }
                string seq;
                if(pt.Maintnance_Price__c > 0){
                    seq = string.valueof(iMaaintenance);
                }else{
                    seq = string.valueof(iInstallment);
                }  
                requestXML += '<CAMPAIGN_LINE>';
                if(pt.Maintnance_Price__c == 0)
                    requestXML += '<PLAN_TYPE>Payment Schedule</PLAN_TYPE>';
                else
                    requestXML += '<PLAN_TYPE>Maintenance Schedule</PLAN_TYPE>';
                requestXML += '<SEQUENCE_NUM>'+seq +'</SEQUENCE_NUM>';
                requestXML += '<PERCENTAGE_PAYMENT>'+pt.cm_Net_Percent__c+'</PERCENTAGE_PAYMENT>';
                requestXML += '<INSTALLMENT>'+pt.cm_Schedule_Type__c+'</INSTALLMENT>';
                date termDate = Date.valueOf(pt.cm_Term_Date__c);
                requestXML += '<EFFECTIVE_DATE>'+termDate.year()+'-'+termDate.month()+'-'+termDate.day()+'</EFFECTIVE_DATE>';
                requestXML += '<TERM>IMMEDIATE</TERM>';
                requestXML += '<SCHEDULE_PRICE>'+((pt.Installment_Amount__c == 0)? '0' : String.valueOf(pt.Installment_Amount__c))+'</SCHEDULE_PRICE>';
                requestXML += '<MAINTENANCE_PRICE>'+((pt.Maintnance_Price__c == 0)? '0' : String.valueOf(pt.Maintnance_Price__c ))+'</MAINTENANCE_PRICE>';
                requestXML += '</CAMPAIGN_LINE>';
            }
            requestXML += '</CAMPAIGN_HDR>';
            list<cm_Interim_Approvals__c> lstInterimApproval = [select id,name,cm_Decision__c ,Price__c,Percentage__c,Increase_Decrease__c,Discount_Price_Adjustment__c,Adjusted_Amount__c	,LR_Wavier__c,
                                                                CreatedDate,Approval_Status__c,Special_Approval_Type__c,cm_Interim_Approval_Type__c,cm_Interim_Approval_Type__r.Name,
                                                                cm_Comments__c,cm_Selected_Units_New__c,cm_Opportunity__c,cm_Opportunity__r.name,Assign_To__c,Assign_To__r.name,cm_Selected_Units__c,
                                                                (select Id,name,Installment__c,Location_Code__c,Location_ID__c,
                                                                 Opportunity_Property__c,Org_ID__c,
                                                                 Special_Approval__c,Term_Date__c,Total_Amount__c,VAT_Amount__c,
                                                                 VAT_Rate__c from Payment_Terms__r order by Installment__c ASC)
                                                                from cm_Interim_Approvals__c 
                                                                where  Special_Approval__c = null 
                                                                and  Id=:specialApprovalId order by createdDate];
            
            system.debug('********requestXML'+requestXML);
            emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresponse = ChangePaymentPlanWebserviceUtils.WebserviceCall(requestXML,specialApprovalId);
            system.debug('******objresponse '+objresponse);
            system.debug('******objresposne.ResultXML '+objresponse.ResultXML);
            system.debug('******objresposne '+objresponse.Status);
            if(objresponse!=null && objresponse.Status!=null && objresponse.Status.toUpperCase() == 'SUCCESS'){
                backup =  Database.setSavepoint();
                //delete all existing payment terms on offers
//delete [select Id from Payment_Terms__c where Opportunity_Property__c = :lstOpporProperties[0].Id];
                //relate approved terms to their respective offers
                List<cm_Interim_Approvals__c> approvals = [select Id, Offer__c, (select Id, Maintnance_Price__c, Opportunity_Property__c from Payment_Terms__r) from cm_Interim_Approvals__c where id = :specialApprovalId];
                List<Payment_Terms__c> approvedTerms = new List<Payment_Terms__c>();
                String offerId = approvals[0].Offer__c;
                System.debug('new camp Id: '+objresponse.ResultVar1);
                update new Opportunity_Property__c(Id = offerId, Campaign_Id__c = objresponse.ResultVar1, 
                                                   Campaign_Map_Id__c = objresponse.ResultVar1 );
                UpdateOfferAttributesOppProp(lstInterimApproval[0],lstOpporProperties[0]);
                Service_Logs__c objLog = new Service_Logs__c();
                objLog.Special_Approval__c = specialApprovalId;
                objLog.OrderXML__c = requestXML;
                objLog.Log_Type__c = objresponse.Status.toUpperCase();
                objLog.Process_Name__c = 'Change - Discount / Payment Terms / Offer';
                objLog.Process_Time__c = System.now();
                Insert objLog;
            }else{
                Service_Logs__c objLog = new Service_Logs__c();
                objLog.Special_Approval__c = specialApprovalId;
                objLog.OrderXML__c = requestXML;
                objLog.Error_Message__c  = objresponse.ErrorMessage;
                objLog.Log_Type__c = objresponse.Status.toUpperCase();
                objLog.Process_Name__c = 'Change - Discount / Payment Terms / Offer';
                objLog.Process_Time__c = System.now();
                Insert objLog;
            }
        }catch(exception e){
            if(backup != null)
            	Database.rollback(backup);
            System.debug('ERROR: ' + e.getMessage()+' '+e.getLineNumber());
            Service_Logs__c objLog = new Service_Logs__c();
            objLog.Special_Approval__c = specialApprovalId;
            objLog.Error_Message__c  = e.getMessage()+' '+e.getLineNumber();
            objLog.Log_Type__c = 'Error';
            objLog.Process_Name__c = 'Change - Discount / Payment Terms / Offer';
            objLog.Process_Time__c = System.now();
            Insert objLog;
        }
    }
    
    public static void UpdateOfferAttributesOppProp(cm_Interim_Approvals__c objSPA ,Opportunity_Property__c objOppProp){
        //objOppProp.Number_of_Maintenance_Terms__c = maintenanceCount;
        //objOppProp.Total_Maintenance_Fee__c = maintenanceAmount;
        objOppProp.Discount_Price_Adjustment__c = objSPA.Discount_Price_Adjustment__c;
        objOppProp.Price__c = objSPA.Price__c;
        objOppProp.Percentage__c = objSPA.Percentage__c;
        objOppProp.Discount_Price_Adjustment_Status__c = 'Approved';
        objOppProp.Adjusted_Amount__c = objSPA.Adjusted_Amount__c;
        if(objOppProp.Original_Booking_Price__c == NULL){
            objOppProp.Original_Booking_Price__c = objOppProp.Booking_Price__c;
        }
        objOppProp.Booking_Price__c = objOppProp.Final_Price__c; 
        update objOppProp;
    }
    
    public static emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element WebserviceCall(string RequestXML, string specialApprovalId){
        
        Map<String, cm_Integration_Settings__c> mpSettings = cm_Integration_Settings__c.getAll(); 
        cm_Integration_Settings__c iSettings= mpSettings.containsKey('ORACLE') ? mpSettings.get('ORACLE'): new cm_Integration_Settings__c();
        
        emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresponse= new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
        emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt stub = new emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt();
        
        Map<String, User_Oracle_Settings__c> mpuserSettings = User_Oracle_Settings__c.getAll();
        User_Oracle_Settings__c iuserSettings= mpuserSettings.containsKey(UserInfo.getUserId()) ? mpuserSettings.get(UserInfo.getUserId()): new User_Oracle_Settings__c();
        
        string oraUserName = iuserSettings.cm_Oracle_Username__c != null? iuserSettings.cm_Oracle_Username__c : iSettings.Default_Oracle_Username__c;
        string oraUDID = iSettings.cm_UD_ID__c != null ? iSettings.cm_UD_ID__c : iSettings.Default_Oracle_User_ID__c;
        
        stub.inputHttpHeaders_x = new Map<String, String>(); 
        String key = iSettings.cm_SOA_Key__c;
        string Encoded = EncodingUtil.base64Encode(blob.valueof(key));
        //Setting a basic authentication header 
        stub.inputHttpHeaders_x.put('Authorization','Basic '+Encoded);
        stub.timeout_x = 120000;
        string UserName = iSettings.cm_Username__c;
        string UDID = iSettings.cm_UD_ID__c;
        Blob cipherText2 = cm_AES_Encryptor.encrypt('AES128', blob.valueOf(iSettings.cm_AES_Key__c), blob.valueOf(RequestXML));
        string Source = 'SALESFORCE';
        //string Action = 'PAYMENT_PLAN_UPDATE_BY_AMOUNT';
        //new action for discount
        string Action = 'XXEMR_PRICE_ADJUSTMENT_DISCOUNT';
        String AttachmentURL = ''; 
        String Param1 = EncodingUtil.convertToHex(cipherText2);
        //String Param1 = RequestXML;
        String Param2 = '';
        String Param3 = '';
        String Param4 = '';
        String Param5 =  '';
        String Param6 = '';
        String Param7 = ''; 
        String Param8 = '';
        String Param9 = '';
        String Param10 = oraUserName;
        String Param11 = '';
        String Param12 = ''; 
        String Param13 = ''; 
        String Param14 ='';
        String Param15 ='';
        String Param16 =''; 
        String Param17 ='';
        String Param18 ='';
        String Param19 = '';
        String Param20 = '';
        
        //if(!Test.isrunningTest()){
        try{
            objresponse =  stub.executePerformAction(UserName,UDID,Source,Action,AttachmentURL,Param1,Param2,Param3,Param4, Param5, Param6, Param7, Param8, Param9, Param10, Param11, Param12, Param13, Param14, Param15, Param16, Param17, Param18, Param19, Param20);
            Service_Logs__c objLog = new Service_Logs__c();
            objLog.Request__c = RequestXML;
            objLog.Response__c = objresponse+'';
            //objLog.Special_Approval__c = specialApprovalId;
            objLog.Error_Message__c  = NULL;
            objLog.Log_Type__c = 'SUCCESS';
            objLog.Process_Name__c = 'Change - Discount / Payment Terms / Offer';
            objLog.Process_Time__c = System.now();
            Insert objLog;
        }
        catch(Exception e){
            System.debug('ERROR: ' + e.getMessage()+' '+e.getLineNumber());
            Service_Logs__c objLog = new Service_Logs__c();
            objLog.Request__c = RequestXML;
            objLog.Response__c = objresponse+'';
            objLog.Special_Approval__c = specialApprovalId;
            objLog.Error_Message__c  = e.getMessage()+''+e.getLineNumber();
            objLog.Log_Type__c = 'Error';
            objLog.Process_Name__c = 'Change - Discount / Payment Terms / Offer';
            objLog.Process_Time__c = System.now();
            Insert objLog;
        } 
        //}
        system.debug('****objresponse'+objresponse);
        system.debug('****objresponse.status--->'+objresponse.status);
        system.debug('****objresponse.ErrorMessage ---->'+objresponse.ErrorMessage);
        system.debug('****objresponse.ResultXML ---->'+objresponse.ResultXML);
        
        return objresponse; 
    }
}