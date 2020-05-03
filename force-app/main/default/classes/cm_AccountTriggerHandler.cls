/*
  Author : Adeel Ahmad (adeel.ahmad@weare4c.com)
  Description : Account Trigger Handler
  Date : 04/24/2018
  Modification History :
  VNo     Date        By              Description
  ===============================================================================================================
  V1.0    24-04-2018  Adeel        	  Update party in oracle
*/
public class cm_AccountTriggerHandler {
    /*
     method name :PARTY_UPDATE_ORACLE
     Description:
     Send Party Updates to Oracle.
 	*/
    public static void PARTY_UPDATE_ORACLE(list<Account> listNew,map<Id,Account> OldMap){
            

            EmaarWebserviceUtils.isUpdated = true;  
            list<string> lstAPIfields = new list<string>();
            map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            map <String, Schema.SObjectField> fieldMap = schemaMap.get('Account').getDescribe().fields.getMap();
            for(Schema.SObjectField sfield : fieldMap.Values()){
                schema.describefieldresult dfield = sfield.getDescribe();
                if(dfield.isUpdateable()){
                    lstAPIfields.add(dfield.getname());
                }
            }
            system.debug('****lstAPIfields'+lstAPIfields);
            map<String,String> countryCodes = new map<String,String>();
            Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
            list<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            System.debug('Picklist::'+ple);
            for( Schema.PicklistEntry f : ple){
                countryCodes.put(f.getLabel(),f.getValue());
            }
            boolean ischanged = false;
            string changeXML='';
            list<Service_logs__c> lstLogs = new list<Service_logs__c>();
            
            set<string> setNameAddressFields = new set<string>{
                'name','persontitle', 'cm_mobile_country_code__pc', 'cm_phone_country_code__c', 
                'billingstreet', 'billingcity', 'billingstate', 'billingcountry','billingpostalcode', 'billingcountrycode', 'cm_p_o_box__c',
                'shippingstreet', 'shippingcity', 'shippingstate', 'shippingcountry','shippingpostalcode', 'shippingcountrycode', 'p_o_box__c',
                'cm_city_arabic__c',
                'cm_street_arabic__c','shipping_city_arabic__c','shipping_p_o_box__c','shipping_address_same_as_billing_address__c','shipping_street_arabic__c'
            };
            
            for(Account objAcc:listNew){
            	system.debug('### '+objAcc.cm_Is_Agent__c);
            	system.debug('### '+objAcc.Record_Type_Name__c);
            	//v1.8 - added the condition    
                if(objAcc.cm_Is_Agent__c == false && objAcc.Record_Type_Name__c != 'Referral_Account' && objAcc.Record_Type_Name__c != 'Agency_Account'){
                    ischanged = false;      
                    string actualfields = '';
                            string changedfields = '';
                   	System.debug('AA:Party_Id__c='+objacc.Party_Id__c);
                    System.debug('AA:Parent_Account__c='+objAcc.Parent_Account__c);
                    if(objacc.Party_Id__c != null && objAcc.Parent_Account__c == null ){ //v1.6 added Parent Account condition
                            changeXML = '<PARTY>';
                            changeXML += '<PARTY_ID__c>'+objacc.Party_Id__c+'</PARTY_ID__c>';
                            if(objAcc.isPersonAccount){
                                changeXML += '<PARTY_TYPE>PERSON</PARTY_TYPE>';
                                changeXML += '<FirstName>'+formtStringValue(objAcc.FirstName)+'</FirstName>';
                                changeXML += '<MiddleName>'+formtStringValueWithBlank(objAcc.MiddleName)+'</MiddleName>';
                                changeXML += '<LastName>'+formtStringValue(objAcc.LastName)+'</LastName>';
                            }else{
                                changeXML += '<PARTY_TYPE>ORGANIZATION</PARTY_TYPE>';
                                changeXML += '<cm_Company_Name__pc>'+formtStringValue(objAcc.Name)+'</cm_Company_Name__pc>';
                            }
                            sobject sobjNew = objAcc;
                            sobject sobjOld = OldMap.get(objAcc.id);

                            //Adeel 07/05/2018 - added updated information, phone and email
                            list<string> c_codes  = new LIST<String>();
                            if(objAcc.isPersonAccount){
                                if(sobjNew.get('PersonEmail') != sobjOld.get('PersonEmail')){
                                    //changeXML += '<PersonEmail>'+sobjNew.get('PersonEmail')+'</PersonEmail>'; //Adeel, commenting this out as it was sending two emails tags
                                }
                                String personalPhoneCountryCode = sobjNew.get('cm_Phone_Country_Code__c') != null ? String.valueOf(sobjNew.get('cm_Phone_Country_Code__c')).split(': ')[1] : '';
                                if(sobjNew.get('Phone') != sobjOld.get('Phone')){
                                    changeXML += '<PHONE_COUNTRY_CODE>'+personalPhoneCountryCode+'</PHONE_COUNTRY_CODE>';
                                    changeXML += '<cm_Phone_Number__c>'+sobjNew.get('Phone')+'</cm_Phone_Number__c>';
                                }
                            }else{
                                if(sobjNew.get('Corporate_Email__c') != sobjOld.get('Corporate_Email__c')){
                                    //changeXML += '<PersonEmail>'+sobjNew.get('Corporate_Email__c')+'</PersonEmail>'; //Adeel, don't need to update person email for corporate account
                                }
                                String corporatePhoneCountryCode = sobjNew.get('Corporate_Phone_Country_Code__c') != null ? String.valueOf(sobjNew.get('Corporate_Phone_Country_Code__c')).split(': ')[1] : '';
                                if(sobjNew.get('Corporate_Phone__c') != sobjOld.get('Corporate_Phone__c')){
                                    changeXML += '<PHONE_COUNTRY_CODE>'+corporatePhoneCountryCode+'</PHONE_COUNTRY_CODE>';
                                    changeXML += '<cm_Phone_Number__c>'+sobjNew.get('Corporate_Phone__c')+'</cm_Phone_Number__c>';
                                }
                            }


                            if(sobjNew.get('BillingStreet')!=sobjOld.get('BillingStreet') || sobjNew.get('BillingCity')!=sobjOld.get('BillingCity') 
                                || sobjNew.get('BillingState')!=sobjOld.get('BillingState') || sobjNew.get('BillingCountry')!=sobjOld.get('BillingCountry')
                                    || sobjNew.get('BillingPostalCode')!=sobjOld.get('BillingPostalCode') || sobjNew.get('BillingPostalCode')!=sobjOld.get('BillingPostalCode') 
                                    || sobjNew.get('cm_P_O_Box__c')!=sobjOld.get('cm_P_O_Box__c')
                                ){
                                    ischanged = true;
                                    System.debug('BillingStreet '+sobjNew.get('BillingStreet'));
                                    string BillingStreet = formtStringValue(string.valueOf(sobjNew.get('BillingStreet')));
                                    string BillingCity = formtStringValue(string.valueOf(sobjNew.get('BillingCity')));
                                    string BillingState = formtStringValue(string.valueOf(sobjNew.get('BillingStateCode')));
                                    string BillingPostalCode = formtStringValue(string.valueOf(sobjNew.get('BillingPostalCode')));
                                    string BillingCountry = formtStringValue(string.valueOf(sobjNew.get('BillingCountry')));
                                    
                                    changeXML += '<BillingStreet>'+((BillingStreet!=null && BillingStreet != '') ?BillingStreet.replaceAll('&','amp;'):'')+'</BillingStreet>';
                                    changeXML += '<BillingCity>'+((BillingCity!=null && BillingCity != '') ?BillingCity.replaceAll('&','amp;'):'')+'</BillingCity>';
                                    changeXML += '<BillingState>'+((BillingState!=null && BillingState != '') ?BillingState.replaceAll('&','amp;'):'')+'</BillingState>';
                                    if(BillingCountry != null && countrycodes.containsKey(BillingCountry))
                                            changeXML += '<BillingCountryCode>'+countryCodes.get(BillingCountry)+'</BillingCountryCode>'; 
                                    changeXML += '<BillingPostalCode>'+sobjNew.get('BillingPostalCode')+'</BillingPostalCode>';
                                    changeXML += '<cm_P_O_Box__c>'+formtStringValue(string.valueof(sobjNew.get('cm_P_O_Box__c')))+'</cm_P_O_Box__c>';
                            }
                            if(sobjNew.get('ShippingStreet')!=sobjOld.get('ShippingStreet') || sobjNew.get('ShippingCity')!=sobjOld.get('ShippingCity') 
                                || sobjNew.get('ShippingState')!=sobjOld.get('ShippingState') || sobjNew.get('ShippingCountry')!=sobjOld.get('ShippingCountry')
                                    || sobjNew.get('ShippingPostalCode')!=sobjOld.get('ShippingPostalCode') || sobjNew.get('ShippingPostalCode')!=sobjOld.get('ShippingPostalCode') 
                                    || sobjNew.get('Shipping_P_O_Box__c')!=sobjOld.get('Shipping_P_O_Box__c')
                                ){
                                    ischanged = true;
                                    string ShippingStreet = formtStringValue(string.valueOf(sobjNew.get('ShippingStreet')));
                                    string ShippingCity = formtStringValue(string.valueOf(sobjNew.get('ShippingCity')));
                                    string ShippingState = formtStringValue(string.valueOf(sobjNew.get('ShippingState')));
                                    string ShippingPostalCode = formtStringValue(string.valueOf(sobjNew.get('ShippingPostalCode')));
                                    string ShippingCountry = formtStringValue(string.valueOf(sobjNew.get('ShippingCountry')));
                                    
                                    changeXML += '<ShippingStreet>'+((ShippingStreet!=null && ShippingStreet != '') ?ShippingStreet.replaceAll('&','amp;'):'')+'</ShippingStreet>';
                                    changeXML += '<ShippingCity>'+((ShippingCity!=null && ShippingCity != '') ?ShippingCity.replaceAll('&','amp;'):'')+'</ShippingCity>';
                                    changeXML += '<ShippingState>'+((ShippingState!=null && ShippingState != '') ?ShippingState.replaceAll('&','amp;'):'')+'</ShippingState>';
                                    if(ShippingCountry != null && countrycodes.containsKey(ShippingCountry))
                                            changeXML += '<ShippingCountryCode>'+countryCodes.get(ShippingCountry)+'</ShippingCountryCode>'; 
                                    changeXML += '<ShippingPostalCode>'+sobjNew.get('ShippingPostalCode')+'</ShippingPostalCode>';
                                    changeXML += '<P_O_Box__c>'+formtStringValue(string.valueof(sobjNew.get('Shipping_P_O_Box__c')))+'</P_O_Box__c>';
                            }
                            
                            for(string strfield:lstAPIfields){
                                actualfields+=strField+',';
                                System.debug('>>>>>>>>strField>>>>>>>'+strField);
                                /*if(strField != 'Name' && strField != 'PersonTitle' && strField != 'cm_Mobile_Country_Code__pc' && strField != 'cm_Phone_Country_Code__c'
                                    && strField != 'BillingStreet' && strField != 'BillingCity' && strField != 'BillingState' && strField != 'BillingCountry'
                                    && strField != 'BillingPostalCode' && strField != 'BillingCountryCode' && strField != 'cm_P_O_Box__c'
                                )*/
                                if(setNameAddressFields.contains(strField.toLowerCase()) == false){
                                    if(sobjNew.get(strfield)!=sobjOld.get(strfield)){
                                        changedfields+=strfield+',';
                                        ischanged = true;
                                        if(strField == 'PersonMobilePhone'){
                                            if(objAcc.No_of_Pending_Approval_Closed_Won_Opt__c == 0){ //v1.2
                                                if(sobjNew.get(strfield) != null){
                                                    string countryCode = string.valueOf(sobjNew.get('cm_Mobile_Country_Code__pc'));
                                                    if(countrycode != null && countrycode.contains(': ')){
                                                        list<string> codes = countryCode.split(': ');
                                                        System.debug('>>>>codes>>>>>>>>>>'+codes);
                                                        System.debug('>>>>>countrycode>>>>>>>>>'+countryCodes.containsKey(codes[0]));
                                                        System.debug('>>>>>countrycodes>>>>>>>>>'+countryCodes);
                                                                                                            
                                                        if(!codes.isEmpty() && countryCodes.containsKey(codes[0])){
                                                            //changeXML += '<MOBILE_COUNTRY_NAME>'+countryCodes.get(codes[0])+'</MOBILE_COUNTRY_NAME>'; 
                                                            changeXML += '<MOBILE_COUNTRY_CODE>'+integer.valueOf(codes[1])+'</MOBILE_COUNTRY_CODE>'; 
                                                            changeXML += '<PersonMobilePhone>'+formtStringValue(string.valueof(sobjNew.get(strField)))+'</PersonMobilePhone>';              
                                                            System.debug('>>inside>>>>>'+changeXML);
                                                        }
                                                        System.debug('>>>outside>>>>'+changeXML);
                                                            
                                                    }
                                                }
                                            }
                                        }else if(strField == 'Phone'){
                                            if(sobjNew.get(strfield) != null){                                              
                                                string countryCode = string.valueOf(sobjNew.get('cm_Phone_Country_Code__c'));
                                                if(countrycode != null && countrycode.contains(': ')){
                                                    list<string> codes = countryCode.split(': ');
                                                    if(!codes.isEmpty() && countryCodes.containsKey(codes[0])){
                                                        //changeXML += '<PHONE_COUNTRY_NAME>'+countryCodes.get(codes[0])+'</PHONE_COUNTRY_NAME>'; 
                                                        //changeXML += '<PHONE_COUNTRY_CODE>'+integer.valueOf(codes[1])+'</PHONE_COUNTRY_CODE>'; v1.2
                                                        changeXML += '<cm_Phone_Country_Code__c>'+integer.valueOf(codes[1])+'</cm_Phone_Country_Code__c>';       
                                                        changeXML += '<Phone>'+formtStringValue(string.valueOf(sobjNew.get(strField)))+'</Phone>';       
                                                    }
                                                }
                                            }
                                        }
                                        else if(strField == 'City_of_Incorporation__c'){
                                            changeXML += '<cm_City_Of_Incorporation__c>'+formtStringValue(string.valueOf(sobjNew.get(strfield)))+'</cm_City_Of_Incorporation__c>';
                                        }
                                        else if(strField=='cm_Country_Of_Incorporation__c' || strField == 'cm_Nationality__pc' || strField == 'cm_Place_Of_Birth__pc' || strField == 'ns_Country_of_Residence__pc'){
                                            if(string.valueOf(sobjNew.get(strfield)) != null && countrycodes.containsKey(string.valueOf(sobjNew.get(strfield))))
                                                changeXML += '<'+strField+'>'+countryCodes.get(string.valueOf(sobjNew.get(strfield)))+'</'+strField+'>'; 
                                            else if(sobjNew.get(strfield) == null || sobjNew.get(strfield) == 'Null'){
                                                changeXML += '<'+strField+'>'+formtStringValue(string.valueOf(sobjNew.get(strfield)))+'</'+strField+'>'; 
                                            }
                                        }
                                        else if(strField == 'cm_Date_of_Incorporation__c' || strField == 'cm_Trade_License_Expiry_Date__c' || strField == 'cm_Passport_Expiry_Date__pc' || strField == 'cm_Visa_Expiry_Date__pc' || strField == 'cm_National_ID_Expiry_Date__pc' || strField == 'cm_Passport_Issue_Date__pc' || strField == 'cm_Birthdate__pc'){
                                            if(sobjNew.get(strfield) != null){
                                                DateTime value = Date.valueOf(sobjNew.get(strfield));
                                                changeXML += '<'+strField+'>'+cm_EmaarUtils.formatDate(value)+'</'+strField+'>'; 
                                            }else{
                                                changeXML += '<'+strField+'>'+formtStringValue(null)+'</'+strField+'>'; 
                                            }
                                        }
                                        else if(strField == 'Salutation'){
                                            changeXML += '<PersonTitle>'+formtStringValue(string.valueof(sobjNew.get(strfield)))+'</PersonTitle>'; 
                                        }else if(strfield == 'PersonEmail' ){ //v1.2
                                            if(objAcc.No_of_Pending_Approval_Closed_Won_Opt__c == 0){
                                                changeXML += '<'+strfield+'>'+formtStringValue(string.valueof(sobjNew.get(strfield)))+'</'+strfield+'>';
                                            }
                                        }else{
                                            System.debug('>>>>>Field>>>>>>>>>'+strfield+'>>>>>>>>>>New>>>>>>>>>'+sobjNew.get(strfield)+'>>>>>>>>Old>>>>>>>>'+sobjold.get(strfield));
                                            if(strfield!='Name' && strfield!='FirstName' && strfield!='Middlename' && strfield!='LastName'){
                                                changeXML += '<'+strfield+'>'+formtStringValueWithBlank(string.valueof(sobjNew.get(strfield)))+'</'+strfield+'>';
                                            }
                                        }
                                }
                            }
                        }
                    /* if(!objAcc.isPersonAccount && objAcc.Name != OldMap.get(objAcc.id).Name){
                            changeXML += '<Name>'+objAcc.Name+'</Name>';            
                        }*/
                        
                        changeXML += '</PARTY>';

                        changeXML = changeXML.replace('null','');
                        changeXML = changeXML.trim();   
                        System.debug('@@changeXML='+changeXML);
                        System.debug('>>>>>>isChanged>>>>>>>>>>'+isChanged);
                        
                        Service_logs__c logs = new service_logs__c();
                        logs.Account__c = objAcc.id;
                        logs.Response__c = changeXML;
                        logs.Log_Type__c='Debug';
                        lstLogs.add(logs);
                        
                        if(isChanged) 
                            EmaarWebServiceUtils.mpAccountXML.put(objAcc.id,changeXML);
                    }
                }
                else{
                    //  if(objAcc.Is_Frozen__c != true){
                            //04/24/2018 - Adeel@4C
                            /*
                    		if(objAcc.Supplier_ID__c != null){//v1.7if(objAcc.Party_Id__c!=null)
                                if(System.IsBatch() == false && System.isFuture() == false){ 
                                    System.debug('>>>>>>UPDATE CALL>>>>>>>>>>');
                                    AgencyUtility.updateHTTPSupplier(objAcc.Id);
                                }
                            }
							*/
                    //
                }
                System.debug('>>>>>>mpAccountXML>>>>>>>>>>'+EmaarWebServiceUtils.mpAccountXML);
                if(!EmaarWebServiceUtils.mpAccountXML.isEmpty()){
                    for(Id recId : EmaarWebServiceUtils.mpAccountXML.keyset()){
                        System.debug('>>>>>>>>>>>>>recId>>>>>>>>>>'+recId);
                        EmaarWebServiceUtils.callUpdatePartyService(EmaarWebServiceUtils.mpAccountXML.get(recId), recId);   
                    }
                }
            }
            
    }
    public static string formtStringValue(string str){
     //return str != null ? str : 'NULL';
        //return str != null ? str.replaceAll('&','amp;').replaceAll('"','quot;').replaceAll('>','gt;').replaceAll('<','lt;').replaceAll('\'','apos').replaceAll('[^a-zA-Z0-9 ,.!;@$()]','') : 'NULL';
        return str != null ? str.replaceAll('“','quot;').replaceAll('”','quot;').replaceAll('‘','apos').replaceAll('’','apos').replaceAll('&','amp;').replaceAll('"','quot;').replaceAll('>','gt;').replaceAll('<','lt;').replaceAll('\'','apos').replaceAll('[^a-zA-Z0-9 ,.!;@$()-_]','') : 'NULL';
    }
    
    public static string formtStringValueWithBlank(string str){
		return str != null ? str.replaceAll('“','quot;').replaceAll('”','quot;').replaceAll('‘','apos').replaceAll('’','apos').replaceAll('&','amp;').replaceAll('"','quot;').replaceAll('>','gt;').replaceAll('<','lt;').replaceAll('\'','apos').replaceAll('[^a-zA-Z0-9 ,.!;@$()-_]','') : '';
    }
}