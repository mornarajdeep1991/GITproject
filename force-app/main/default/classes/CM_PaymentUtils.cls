/*
* Modification History :
v1.1    Ravi        25/Sep/2017     Added the logic to encrypt the payment id when generating the link
v1.2    Ravi        26/Mar/2018     Added a generic method to return the Active Payment Gateway Setting record
v1.2 Pavithra 04/04/2018     Logic change for Receipt payment method
*/
global without sharing class CM_PaymentUtils{

    public static string GeneratePaymentLink(string ObjectId,string OrderName,string AmountToPay) {
        list<Payment_Gateway_Setting__mdt> PGList = new list<Payment_Gateway_Setting__mdt> ([select id,Access_Code__c,Merchant_Id__c,Return_URL__c,Secure_Secret__c,URL__c,active__c  from Payment_Gateway_Setting__mdt where active__c = true limit 1]);
       // list<Payment_Gateway_Setting__mdt> PGList = new list<Payment_Gateway_Setting__mdt>();
        if(PGList.size() > 0 && string.isnotblank(ObjectId) && string.isnotblank(AmountToPay)){
            Payment_Gateway_Setting__mdt setting = PGList[0];
            Map<String,String> mpValues = new Map<String,String>();
            mpValues.put('vpc_AccessCode',setting.Access_Code__c);
            mpValues.put('vpc_Amount',AmountToPay+ '00');
            mpValues.put('vpc_Command','pay');
            mpValues.put('vpc_Currency','AED');
            mpValues.put('vpc_Locale','en');
            mpValues.put('vpc_MerchTxnRef', ObjectId); 
            mpValues.put('vpc_Merchant',setting.Merchant_Id__c);
            mpValues.put('vpc_OrderInfo', OrderName.abbreviate(30));
            //mpValues.put('vpc_ReturnURL', setting.Return_URL__c.removeEnd('?')+ '?id='+ ObjectId);
            mpValues.put('vpc_ReturnURL', setting.Return_URL__c.removeEnd('?')+ '?il=0');
            mpValues.put('vpc_Version','1');
    
            //string str = setting.Secure_Secret__c;
            string str = '';
            for(String s: mpValues.Keyset()){
                str = str + s + '=' +mpValues.get(s) + '&';
            }
            str = str.removeEnd('&');
            system.debug('hashstring = '+ str);
            
            string hashKey = CreateSHA256Signature(str,setting.Secure_Secret__c);
            mpValues.put('vpc_SecureHash', hashKey);
            mpValues.put('vpc_SecureHashType','SHA256');
            string url = setting.URL__c.endsWith('?')? setting.URL__c : setting.URL__c + '?' ;

            for(string s: mpValues.Keyset()){
               url+= s+ '=' + EncodingUtil.urlEncode(mpValues.get(s),'UTF-8') + '&';
            }
            url = url.removeEnd('&');
            return url;
        }
        return '';
    }
    /*
    public static string  GeneratePaymentValidationLink(string ObjectId,string TransNo){
        list<Payment_Gateway_Setting__mdt> PGList = new list<Payment_Gateway_Setting__mdt> ([select id,Access_Code__c,Merchant_Id__c,Return_URL__c,Secure_Secret__c,URL__c,active__c,Operator_ID__c,Password__c,AMA_Transaction_URL__c from Payment_Gateway_Setting__mdt where active__c = true limit 1]);
        if(PGList.size() > 0 && string.isnotblank(ObjectId)){
            
            Payment_Gateway_Setting__mdt setting = PGList[0];
            string urlResult = setting.AMA_Transaction_URL__c;
            Map<String,String> mpValues = new Map<String,String>();
            mpValues.put('vpc_Command','queryDR');
            mpValues.put('vpc_AccessCode',setting.Access_Code__c);
            mpValues.put('vpc_Merchant',setting.Merchant_Id__c);
            mpValues.put('vpc_Locale','en');
            mpValues.put('vpc_TransNo',TransNo);
            mpValues.put('vpc_User',setting.Operator_ID__c);
            mpValues.put('vpc_Password',setting.Password__c);
            mpValues.put('vpc_MerchTxnRef', ObjectId);
            mpValues.put('vpc_Version','1');
             
            mpValues.put('vpc_ReturnURL', setting.Return_URL__c.endsWith('?')? setting.Return_URL__c: setting.Return_URL__c+ '?id='+ ObjectId);
            string str = setting.Secure_Secret__c;
            for(String s: mpValues.Keyset()){
                str = str+mpValues.get(s);
            }
            string hashKey = CreateMD5Signature(str);
            mpValues.put('vpc_SecureHash', hashKey);
            string url = urlResult .endsWith('?')? urlResult  : urlResult + '?' ;
            integer i = 0;
            for(string s: mpValues.Keyset()){
               if(i==0)
                   url+=s+'='+EncodingUtil.urlEncode(mpValues.get(s),'UTF-8');
               else
                   url+='&'+s+'='+EncodingUtil.urlEncode(mpValues.get(s),'UTF-8');
               i++;
            }
            return url;
        }
        return '';
    }*/
    
    public static string GenerateSFLink(string ObjectId) {
        //v1.1
        //return GenerateSFLink() + '&id='+ObjectId ;
        return GenerateSFLink() + '&i1='+EncodingUtil.URLEncode(CreateEncryptedData(ObjectId),'UTF-8') ;
    }
    
    public static void ResendPaymentLink(string ObjectId){
        
        list<Opportunity_Payment__c> ListOfPay = new list<Opportunity_Payment__c>([select id ,status__c,Opportunity__c,Opportunity__r.cm_Sales_Person__r.ContactId,Opportunity__r.Is_From_Broker_App__c,Opportunity__r.Is_From_Customer_Direct__c from Opportunity_Payment__c where id =:ObjectId limit 1]);
        if(ListOfPay.size()>0 && (ListOfPay[0].status__c == 'New' || ListOfPay[0].status__c =='Email Sent to Customer' ||ListOfPay[0].status__c =='Payment link Resent'||ListOfPay[0].status__c =='Rejected')){
            Opportunity_Payment__c objPayment = ListOfPay[0];
            if(objPayment.Opportunity__r.Is_From_Broker_App__c || objpayment.Opportunity__r.Is_From_Customer_Direct__c){
                objPayment.URL__c = CM_PaymentUtils.BrokerAppGenerateSFLink(objPayment.Id);
                objPayment.Payment_Link_Generated__c = system.now();
            }else   
                objPayment.URL__c = CM_PaymentUtils.GenerateSFLink(ObjectId);
            objPayment.status__c = 'Payment link Resent';
            objPayment.Payment_Link_Expiry_Date__c = GenerateExpiryDate();
            update objPayment;
        } 
    }
    
    public static string GenerateSFLink(){
        list<Payment_Gateway_Setting__mdt> PGList = new list<Payment_Gateway_Setting__mdt> ([select id,Access_Code__c,Merchant_Id__c,Return_URL__c,Secure_Secret__c,URL__c,active__c,WS_Broker_App_URL__c  from Payment_Gateway_Setting__mdt where active__c = true limit 1]);
        if(PGList.size() > 0){
            Payment_Gateway_Setting__mdt setting = PGList[0];
            String myDate = string.valueOf(system.now());
            string params = 'data='+ encodingUtil.URLEncode(CreateEncryptedData(myDate),'UTF-8');
            string url = setting.Return_URL__c.endsWith('?')? setting.Return_URL__c + params : setting.Return_URL__c+ '?'+ params ;
            return url;
        }
        return '';
    }
    
    public static string BrokerAppGenerateSFLink(string OId){
        list<Payment_Gateway_Setting__mdt> PGList = new list<Payment_Gateway_Setting__mdt> ([select id,Access_Code__c,Merchant_Id__c,Return_URL__c,Secure_Secret__c,URL__c,active__c,WS_Broker_App_URL__c  from Payment_Gateway_Setting__mdt where active__c = true limit 1]);
        if(PGList.size() > 0){
            Payment_Gateway_Setting__mdt setting = PGList[0];
            String myDate = string.valueOf(system.now());
            string params = 'data='+ encodingUtil.URLEncode(CreateEncryptedData(myDate),'UTF-8');
            params += '&id='+EncodingUtil.URLEncode(CreateEncryptedData(OId),'UTF-8');
            string url = setting.WS_Broker_App_URL__c.endsWith('?')? setting.WS_Broker_App_URL__c + params : setting.WS_Broker_App_URL__c+ '?'+ params ;
            return url;
        }
        return '';
    }
    
    public static datetime GenerateExpiryDate(){
        list<Payment_Gateway_Setting__mdt> PGList = new list<Payment_Gateway_Setting__mdt> ([select id,Time_Out_Hours__c  from Payment_Gateway_Setting__mdt where active__c = true limit 1]);
        if(PGList.size() > 0){
            Payment_Gateway_Setting__mdt setting = PGList[0];
            datetime myDate = system.now().addhours(integer.valueof(setting.Time_Out_Hours__c));
            return myDate;
        }
        return null;
    }
    
    /*
    @future
    public static void UpdatePaymentToApprovedFromGateway(string id,string CardNum,string vpc_Card,string vpc_AuthorizeId,string vpc_BatchNo,
                                                        string vpc_TransactionNo,string vpc_AcqResponseCode,string RRN,string Merchant_Id,
                                                        string vpc_OrderInfo,string vpc_TxnResponseCode,string vpc_SecureHash,string vpc_SecureHashType){
        list<Opportunity_Payment__c> payList = new list<Opportunity_Payment__c>([select id,Status__c  from Opportunity_Payment__c where id = :id limit 1]);
        if(payList.size()>0 && payList[0].Status__c != 'Approved' && payList[0].Status__c != 'Rejected'){
            system.debug(' future Payment Status '+payList[0].Status__c);
            Opportunity_Payment__c prop = payList[0];
            prop.Status__c = 'Gateway Payment Approved';
            prop.vpc_CardNum__c = CardNum;
            prop.vpc_Card__c = vpc_Card;
            prop.vpc_AuthorizeId__c = vpc_AuthorizeId;
            prop.vpc_BatchNo__c = vpc_BatchNo;
            prop.vpc_TransactionNo__c = vpc_TransactionNo;
            prop.vpc_AcqResponseCode__c =vpc_AcqResponseCode;
            prop.RRN__c = RRN;
            prop.Merchant_Id__c = Merchant_Id;
            prop.vpc_OrderInfo__c = vpc_OrderInfo;
            prop.vpc_TxnResponseCode__c= vpc_TxnResponseCode;
            prop.vpc_SecureHash__c = vpc_SecureHash;
            prop.vpc_SecureHashType__c = vpc_SecureHashType;
            update prop;
        }
    }
    */
    
    public static boolean ValidateSFLink(string data){
        list<Payment_Gateway_Setting__mdt> PGList = new list<Payment_Gateway_Setting__mdt> ([select id,Time_Out_Hours__c  from Payment_Gateway_Setting__mdt where active__c = true limit 1]);
        if(PGList.size() > 0){
            Payment_Gateway_Setting__mdt setting = PGList[0];
            integer timeout = integer.valueOF(setting.Time_Out_Hours__c);
            system.debug(timeout);
            if(timeout != null && timeout > 0){
                system.debug('ValidateSFLink --->>'+data);
                string result = CM_PaymentUtils.CreateDecryptedData(data);
                Datetime startDate = datetime.valueOf(result);
                Datetime endDate = system.now();
                integer intDays =  startDate.Date().daysBetween(endDate.Date());
                decimal decHours = ((endDate.getTime())/1000/60/60) - ((startDate.getTime())/1000/60/60);
                system.debug('intDays  --->> '+ intDays  + ' ,decHours --->> ' + decHours + ' ,decHours --->> '+ timeout);
                if(intDays == 0 && decHours <= timeout){
                    system.debug('ValidateSFLink --->> Link Is Valid ');
                    return true;
                }
            } 
        }
        system.debug('ValidateSFLink --->> Link Not Valid ');
        return false;
    }
    
    public static boolean ValidatePaymentLink(map<string,string> params){
    
        string hash ='';
        string dataToValidate = '';
        
        
        Set<string> mapkeys = params.keyset();
        List<String> li=new List<String>();
        li.addAll(mapkeys);
        
        for (Integer i = 0; i < li.size(); i++) {
            system.debug('Index [' + i + ']: ' + li[i]);
        }
        
        for(string key: params.keyset()){
            system.debug('Key --->>> '+key);
            system.debug('Value --->>> '+params.get(key));
            if(key != 'vpc_SecureHash' && key != 'vpc_SecureHashType' && (key.startsWith('vpc_')|| key.startsWith('user_'))){
                dataToValidate += key + '=' + params.get(key) + '&';
            }
        }
        dataToValidate = dataToValidate.removeEnd('&');
        
        hash = params.get('vpc_SecureHash');
        
        system.debug('dataToValidate --->>> '+dataToValidate);
        string test =  EncodingUtil.urlEncode(dataToValidate,'UTF-8');
        
        
        list<Payment_Gateway_Setting__mdt> PGList = new list<Payment_Gateway_Setting__mdt> ([select id,Access_Code__c,Merchant_Id__c,Return_URL__c,Secure_Secret__c,URL__c,active__c  from Payment_Gateway_Setting__mdt where active__c = true limit 1]);
        if(PGList.size() > 0 ){
            Payment_Gateway_Setting__mdt setting = PGList[0];
            string secureKey = setting.Secure_Secret__c;
            
            string hashKey = CreateSHA256Signature(dataToValidate,secureKey);
            
            system.debug('payment response params -> '+ hash );
            
            system.debug('Generated Hash from system -> '+ hashKey );
            
            string hashKey2 = CreateSHA256Signature(test,secureKey);
            
            
            system.debug('Generated Hash2 from system -> '+ hashKey2);
            
            if(hashKey == hash )
                return true;
        }
        
        return false;
    }
    
    public static string CreateSHA256Signature(string str,string key) {
        Blob targetBlob = Blob.valueOf(str);
        Blob privateKeyBlob = EncodingUtil.convertFromHex(key);

        Blob hash = crypto.generateMac('HmacSHA256', targetBlob , privateKeyBlob);
        string result = EncodingUtil.convertToHex(hash).toUpperCase();        
        return result;
    }
    
    public static string CreateMD5Signature(string str) {
        Blob targetBlob = Blob.valueOf(str);
        Blob hash = Crypto.generateDigest('MD5', targetBlob);
        string result= EncodingUtil.convertToHex(hash);        
        return result.toUpperCase();
    }
    
    public static string CreateEncryptedData(string str) {
        Blob key = Blob.valueOf('EmaarPaymentLink');
        Blob encryptedData = Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(str));
        return EncodingUtil.base64Encode(encryptedData);
    }
    
    public static string CreateDecryptedData(string str){
        Blob key = Blob.valueOf('EmaarPaymentLink');
        Blob data = null;
        try{
            data  = EncodingUtil.base64Decode(str);
            system.debug('First try to decode url');
        }
        catch(exception ex){
            data  = EncodingUtil.base64Decode(encodingUtil.urlDecode(str, 'UTF-8'));
            system.debug('Second try to decode url');
        }
        
        Blob decryptedBlob = Crypto.decryptWithManagedIV('AES128', key, data);
        system.debug('Result ->> '+decryptedBlob.toString());
        return decryptedBlob.toString();
    }
    
    webservice static string createReciept(ID OppPaymentID){
        try{
            if(OppPaymentID != null){
                Reciepts__c temp = new Reciepts__c();
                list<Opportunity_Payment__c> OppPaymentlist = new list<Opportunity_Payment__c>([select id,Receipt_Number__c,Opportunity__c,
                                                                                                Is_Read_Only__c, Status__c,Amount__c
                                                                                                from Opportunity_Payment__c 
                                                                                                where id= :OppPaymentID]);
                Opportunity_Payment__c OppPayment = OppPaymentlist.size() > 0? OppPaymentlist[0] : null;
                if(OppPayment != null && OppPayment.Status__c == 'Gateway Payment Approved' && OppPayment.Is_Read_Only__c == false){
                    list<opportunity> opplist = new list<opportunity>([select id,name,account.name,amount,cm_Is_Payment_done__c,CurrencyIsoCode,cm_Approval_Status__c,(select id, name,cm_Property_Name__c, cm_Selling_Price__c,cm_Inventory_Location_Code__c,CurrencyIsoCode,Building__c from Opportunity_Properties__r) from opportunity where id =:OppPayment.Opportunity__c limit 1]);
                    opportunity opp = opplist.size() > 0? opplist[0] : null;
                    
                    string strOPPProperty = opp.Opportunity_Properties__r[0].id;
                    string locationcode = opp.Opportunity_Properties__r[0].cm_Inventory_Location_Code__c;
                    if(strOPPProperty != null && locationcode != null){
                        temp.Installment_Details__c = 'Deposit';
                        temp.Currency__c = 'AED';
                        temp.Opportunity__c =  OppPayment.Opportunity__c;
                        temp.Amount__c = OppPayment.Amount__c;
                        temp.Reciept_Number__c = OppPayment.Receipt_Number__c;
                        temp.cm_Paid_By__c = 'Cash';
                        temp.Payment_Mode__c = 'Credit Card';
                        temp.Reciept_Date__c = system.today();
                        temp.Purpose__c = 'Booking Fees';
                        temp.Comments__c = 'Booking Fees towards '+locationcode;
                        temp.cm_Opportunity_Property__c = strOPPProperty;
                        list<Payment_Methods__c> lst = [select id,Property__c,Building__c,Receipt_Method__c from Payment_Methods__c where Building__c=:opp.Opportunity_Properties__r[0].Building__c ];
                        for(Payment_Methods__c objPayM : lst){
                           if(objPayM.Receipt_Method__c!=null && objPayM.Receipt_Method__c.contains('Escrow')){
                               //Adeel temp.Reciept_Payment_Mode__c = objPayM.Receipt_Method__c;
                           }
                        }
                        if(temp.Reciept_Payment_Mode__c == ''){
                            temp.Reciept_Payment_Mode__c = 'Credit Card MB';
                        }
                        //temp.Reciept_Payment_Mode__c = 'Credit Card MB';
                        system.debug('*******temp'+temp);
                        emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objResponse = EmaarWebServiceUtils.executePerformConcurrentAction_GETRECIEPT(temp,strOPPProperty);
                        if(objResponse.status=='ERROR'){
                            oppPayment.Receipt_Generation_Failed__c = true;
                            system.debug('Payment Done by the customer but receipt generation faild');
                            return 'Error When generated a new Reciept in Oracle please contant your administrator';
                        }
                        else{
                            system.debug('***objResponse'+objResponse.resultXML);
                            Reciepts__c objREC = CM_PaymentUtils.ParseRecieptXML(objResponse.resultXML,temp);
                            objREC.Opportunity__c = opp.id;
                            objREC.Received_by__c = userinfo.getUserId();
                            insert objREC;
                            oppPayment.Is_Read_Only__c = true;
                            update oppPayment;
                            system.debug('Payment done by the customer & receipt has been generated');
                            return 'receipt has been generated';
                        } 
                    }
                    
                }
            }
            return 'Invalid Opportunity payment id';
        }catch(exception ex){
            return ex.getMessage();
        } 
    }
    
    public static Reciepts__c ParseRecieptXML(string XMLData,Reciepts__c objReciet){

        //string RECEIPT_BATCH_ID = CM_EmaarUtils.getValueFromXMLString(XMLData,'RECEIPT_BATCH_ID');
        //string ORG_ID= CM_EmaarUtils.getValueFromXMLString(XMLData,'ORG_ID');
        objReciet.Cash_Receipt_Id__c = CM_EmaarUtils.getValueFromXMLString(XMLData,'CASH_RECEIPT_ID');
        //string RECEIPT_NUMBER = CM_EmaarUtils.getValueFromXMLString(XMLData,'RECEIPT_NUMBER');
        //string ORG_NAME = CM_EmaarUtils.getValueFromXMLString(XMLData,'ORG_NAME');
        //string CURRENCY_CODE = CM_EmaarUtils.getValueFromXMLString(XMLData,'CURRENCY_CODE');
        //string AMOUNT = CM_EmaarUtils.getValueFromXMLString(XMLData,'AMOUNT');
        //string RECEIPT_DATE = CM_EmaarUtils.getValueFromXMLString(XMLData,'RECEIPT_DATE');
        objReciet.Customer_Number__c = CM_EmaarUtils.getValueFromXMLString(XMLData,'CUSTOMER_NUMBER');
        objReciet.Document_Number__c = CM_EmaarUtils.getValueFromXMLString(XMLData,'DOCUMENT_NUMBER');
        objReciet.Amount_in_Words__c = CM_EmaarUtils.getValueFromXMLString(XMLData,'AMOUNT_IN_WORDS');
        objReciet.Mode_Of_Payment__c = CM_EmaarUtils.getValueFromXMLString(XMLData,'MODE_OF_PAYMENT');
        objReciet.Maturity_Date__c = CM_EmaarUtils.getValueFromXMLString(XMLData,'MATURITY_DATE');
        //string FINANCIER_NAME = CM_EmaarUtils.getValueFromXMLString(XMLData,'FINANCIER_NAME');
        //string COMMENTS = CM_EmaarUtils.getValueFromXMLString(XMLData,'COMMENTS');
        objReciet.Company_Name__c = CM_EmaarUtils.getValueFromXMLString(XMLData,'COMPANY_NAME');
        objReciet.PO_Box__c = CM_EmaarUtils.getValueFromXMLString(XMLData,'PO_BOX');
        objReciet.Country__c = CM_EmaarUtils.getValueFromXMLString(XMLData,'COUNTRY');
        objReciet.Telephone__c = CM_EmaarUtils.getValueFromXMLString(XMLData,'TELEPHONE');
        objReciet.Fax__c = CM_EmaarUtils.getValueFromXMLString(XMLData,'FAX');
        //string CREATED_BY_USER = CM_EmaarUtils.getValueFromXMLString(XMLData,'CREATED_BY_USER');
        return objReciet;
    } 
    
    public static Time GetElapsedTime(Time startTime, Time endTime)
    {
        if(startTime == null || endTime == null)
            return Time.newInstance(0, 0, 0, 0);
    
        Integer elapsedHours = endTime.hour() - startTime.hour();
        Integer elapsedMinutes = endTime.minute() - startTime.minute();
        Integer elapsedSeconds = endTime.second() - startTime.second();
        Integer elapsedMiliseconds = endTime.millisecond() - startTime.millisecond();
        
        return Time.newInstance(elapsedHours, elapsedMinutes, elapsedSeconds, elapsedMiliseconds);
    }
    
    public static Time GetElapsedTime(DateTime startDate, DateTime endDate)
    {
         if(startDate == null || endDate == null)
             return Time.newInstance(0, 0, 0, 0);
         return GetElapsedTime(startDate.time(), endDate.time());
    }
    
    public static Integer GetSecondsElapsed(Time startTime, Time endTime)
    {
        return GetElapsedTime(startTime, endTime).second();
    }
    
    public static Integer GetHoursElapsed(DateTime startTime, DateTime endTime)
    {
        return GetElapsedTime(startTime, endTime).hour();
    }
    
    //v1.2
    /*
        Description : This method will return the Active Payment Gateway Setting record
    */
    public static Payment_Gateway_Setting__mdt getPaymentSettings(){
        Payment_Gateway_Setting__mdt GatewaySettings = new Payment_Gateway_Setting__mdt();
        //Adeel
        //for(Payment_Gateway_Setting__mdt obj : [select id,Access_Code__c,Merchant_Id__c,Return_URL__c,Secure_Secret__c,URL__c,Active__c,AMA_Password__c,AMA_Username__c,Query_DR_Command__c,Query_DR_URL__c from Payment_Gateway_Setting__mdt where active__c = true limit 1]){
        //  GatewaySettings = obj;
        //}
        return GatewaySettings;
    }

}