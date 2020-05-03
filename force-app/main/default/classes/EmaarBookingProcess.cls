/*
    Created By : NSI/PwC
    Modification History :
********************************************************************************************************************
V.No    Date            By                  Description
====================================================================================================================
v1.1    12/9/2017       Pavithra G          To uncheck show limited fields checkbox after booking is done.
v1.2    24/Dec/2017     Ravindra Babu       Added the logic to send the Corporate Account Contact details to ORACLE.
v1.3    11/Jan/2018     Ravi                Added the logic to update the Order Source and Order Event on Opportunity Property
v1.4	30/Jan/2018		Ravi				Added the logic to pass the State if the Country is "United States"
v1.5	28/Feb/2018		Ravi				Capturing the Payment Schedule Type at time of Sales Order Creation from ORACLE
v1.6	01/Mar/2018		Ravi				EPESI-896 - Passing special charecters to ORACLE if any in Customer Name at the time of Sales Order Creation, other fields we are passing name we are not
v1.7    20/03/2018      Hari                EPESI-191 - Default color option passing to oracle in order XML and creating color option record.
********************************************************************************************************************
*/
public class EmaarBookingProcess {
    
     public static string CreateParty_SalesOrder(string stropporid ,string parentlogId,string strOrderSource,string strOrderEvent,map<string,String> mpInvHeaders){
        
        
        string selbuilding = '';
        string selUnitPosition = '';
        list<Building_Color_Option__c> lstBlocation = new list<Building_Color_Option__c>();
        list<Service_Logs__c> lstservlog = new list<Service_Logs__c>();
        integer ItotalCount = 0;
        integer ISuccessCount = 0;
        integer IFailCount = 0;
        string strMessage = '';
        string strErrors ='';
        string AccountXML ;
        
        map<String,String> countryCodes = new map<String,String>();
        Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
        list<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        //system.debug('Picklist::'+ple);
        for( Schema.PicklistEntry f : ple){
            countryCodes.put(f.getLabel(),f.getValue());
        }

        //string AccountXML,string OrderXML,string LocationID ,string locationCode,string campainID,string CampaignName,string userOracleCode,string OrgId
        list<Opportunity_Property__c> lstOpportunityProperty = [select id,name,cm_Property_Inventory__r.Location_Code__c,cm_Property_Inventory__r.payment_Header_id__c,cm_Property_Inventory__r.Building_Location__c,Campaign_Price__c,
                                                                cm_Property_Inventory__r.Standard_Cost__c,cm_Opportunity__c,cm_Property_Inventory__r.CurrencyISOCode,cm_Property_Inventory__r.VAT_Amount__c,cm_Property_Inventory__r.VAT_Rate__c,cm_Property_Inventory__r.Total_Amount__c,
                                                                cm_Property_Inventory__r.Unit_Position__c,cm_Property_Inventory__r.Selling_Price__c,cm_Opportunity__r.campaign.Type,cm_Opportunity__r.cm_Payment_Mode__c,
                                                                cm_Property_Inventory__r.Location__c,cm_Property_Inventory__r.Location__r.Location_ID__c,cm_Property_Inventory__r.Location__r.Location_Code__c,
                                                                cm_Opportunity__r.campaign.Eloqua_ID__c,cm_Opportunity__r.campaign.Name,cm_Property_Inventory__r.Org_ID__c,Building__c,
                                                                cm_Opportunity__r.Is_from_Broker_App__c,cm_Opportunity__r.Is_From_Customer_Direct__c,
                                                                cm_Opportunity__r.em_UTM_Medium__c,cm_Opportunity__r.em_UTM_Source__c,cm_Opportunity__r.Digital_ID__c,cm_Opportunity__r.em_UTM_Campaign__c,
                                                                Campaign_Id__c, Campaign_Map_Id__c,
                                                                cm_Opportunity__r.Lead_Channel__c, cm_Opportunity__r.Lead_Conversion_Date__c, cm_Opportunity__r.Lead_Converted_By__c, 
                                                                cm_Opportunity__r.Lead_Created_Date_Time__c, cm_Opportunity__r.Lead_Id__c, cm_Opportunity__r.LeadSource, cm_Opportunity__r.Sales_Admin_Approved_by__r.Name,
                                                                cm_Opportunity__r.Id
                                                                //ADeel (select id,Name,Opportunity_Property__c,Sales_Option__c,Sales_Option__r.Facade_Option__c,Sales_Option__r.Color_Option__c,Sales_Option__r.Name, Sales_Option__r.Sales_Option_ID__c,Is_Active__c from  
                                                                //Sales_Option_Master__r where Confirmed__c = true and Is_Active__c = true )
                                                                from Opportunity_Property__c where cm_Opportunity__c=:stropporid and Sales_Order__c = null];
        list<Opportunity> lstoppordata = [select id,AccountId,em_UTM_Medium__c,em_UTM_Source__c,Digital_ID__c,em_UTM_Campaign__c,cm_party_type__c,cm_Contact__r.cm_Mobile_Country_Code__c,Referral__c,Referral__r.name,Referral__r.cm_Resource_Id__c,
                                        cm_Contact__r.cm_Mobile_Number__c,cm_Contact__r.MobilePhone,cm_contact__r.Email,cm_contact__r.cm_Nationality__c, cm_Agency_Name__r.name,cm_Agency_Name__r.cm_Resource_Id__c  from Opportunity where id=:stropporid ];
        // user objuser = [select id,cm_User_Code__c from user where id=:userinfo.getuserid()];
        
        /************************Custom settings verify for LR wavier Percentage*****************************************/
        map<string,integer> MapbuildingLR = new map<string,integer>();
        /* Adeel - Removing discounts */
        /*
        list<LR_Discount_Settings__c> LRCS = LR_Discount_Settings__c.getall().values();
        for(LR_Discount_Settings__c objLRCS:LRCS){
                if(objLRCS.LR_Discount__c!=null && objLRCS.Active__c == true)
                    MapbuildingLR.put(objLRCS.Building_Name__c , integer.valueof(objLRCS.LR_Discount__c));
        }
        */
        //system.debug('***********MapbuildingLR'+MapbuildingLR);
        /*************V1.7******EPESI-191***********COLOR OPTIONS************************************************/
        
        if(lstOpportunityProperty!=null && lstOpportunityProperty.size() >0){
            if(lstOpportunityProperty[0].cm_Property_Inventory__r.Building_Location__c!=null)
                selbuilding = lstOpportunityProperty[0].cm_Property_Inventory__r.Building_Location__c;
            if(lstOpportunityProperty[0].cm_Property_Inventory__r.Unit_Position__c!=null)
                selUnitPosition = lstOpportunityProperty[0].cm_Property_Inventory__r.Unit_Position__c; 
        }
        system.debug('*****selbuilding*******'+selbuilding);
        system.debug('*****selUnitPosition*******'+selUnitPosition);
        string strColorOptionKey = '';
        if(selbuilding != '' && selbuilding != null ){
            strColorOptionKey = selbuilding+'###';
        } 
        if(selUnitPosition != '' && selUnitPosition != null ){
            strColorOptionKey = strColorOptionKey+selUnitPosition;
        }
        system.debug('*****strColorOptionKey*******'+strColorOptionKey);
        /* Adeel - removing building color option */
        /*
        for(Building_Color_Option__c bco: [Select id,key__c, Unique_key__c, Default_option__c, SALES_OPTION__c,SALES_OPTION__r.Sales_Option_ID__c, Active__c, Building__c from Building_Color_Option__c where Building__c = : selBuilding and Active__c = true and Default_option__c = true limit 1]){
            if(bco.key__c == strColorOptionKey)
                lstBlocation.add(bco);
        }
        */
        system.debug('*****lstBlocation*******'+lstBlocation);
        /*******V1.7********EPESI-191***********************END*************************************************/
        list<Account> lstAccounts2Update = new list<Account>();
        list<Opportunity> lstOpps2Update = new list<Opportunity>();
        list<Opportunity_Property__c> lstInvs2Update = new list<Opportunity_Property__c>(); 
        
        string oppContactMobile = '';
        string oppContactEmail = '';
        string oppContactNationality = ''; 
        string oppContactMobCountryCode = '';
        Account objAccount = new Account();
        
        //v1.5
        string[] SOnPST = new string[]{'',''};
        
        //v1.5
        map<Id,Contact> mapOrgContacts = new map<Id,Contact>();
        
         if(!lstoppordata.isEmpty() && lstoppordata[0].AccountId != null ){ 
                objAccount = [select id,Name,BillingCountryCode,PersonTitle,firstName,lastName,middleName,cm_Nationality__pc,cm_Passport_Number__pc,
                            cm_Passport_Expiry_Date__pc,BillingCity,BillingStreet,Billingcountry,BillingState,billingpostalcode,cm_Gender__pc,phone,cm_P_O_Box__c,
                            Party_Id__c,Salutation,cm_Mobile_Country_Code__pc,cm_Phone_Country_Code__c,isPersonAccount,cm_Birthdate__pc,
                            cm_National_ID_Expiry_Date__pc,cm_Visa_Expiry_Date__pc,cm_Passport_Issue_Date__pc,cm_Place_Of_Birth__pc, cm_National_ID_No__pc, cm_Date_of_Incorporation__c,
                            PersonMobilePhone,PersonEmail,PersonBirthdate,cm_Country_Of_Incorporation__c,Email__c, //ns_Country_of_Residence__pc,
                            cm_Trade_License_Expiry_Date__c,cm_Trade_License_Number__c,Parent_Account__c,Parent_Account__r.Party_Id__c,Emirate__c,VAT_Registration_No__c,
                            //v2.0
                            ShippingStreet,ShippingCity,Shipping_P_O_Box__c,ShippingCountry,Shipping_Mobile_Number__c,Shipping_Mobile_Country_Code__c,Visa_No__pc,Visa_Issue_Date__pc,ShippingState,
                            Corporate_Email__c,Corporate_Phone__c,Corporate_Phone_Country_Code__c, //Adeel ns_Country_of_Residence__c
                                (select Id,FirstName,LastName,Salutation,MiddleName,Name,cm_Nationality__c,cm_Birthdate__c,cm_Passport_Number__c,cm_Passport_Expiry_Date__c,
                                Visa_No__c,cm_Visa_Expiry_Date__c,cm_National_ID_No__c,cm_National_ID_Expiry_Date__c, cm_Gender__c,Party_Contact_Id__c,
                                MailingCity,Mailingstreet,Mailingstate,MailingCountry,Mailingpostalcode,Email,Title,cm_Place_Of_Birth__c,MobilePhone,cm_P_O_Box__c,cm_Mobile_Country_Code__c
                                from Contacts where Is_Deleted__c = false AND Party_Contact_Id__c = null)
                            from Account where Id=:lstoppordata[0].AccountId];
                                    
            //oppContactMobile =  lstoppordata[0].cm_Contact__r.cm_mobile_number__c;
            oppContactMobile =  lstoppordata[0].cm_Contact__r.MobilePhone;
            oppContactEmail = lstoppordata[0].cm_Contact__r.Email;
            oppContactNationality = lstoppordata[0].cm_Contact__r.cm_Nationality__c;
            oppContactMobCountryCode = lstoppordata[0].cm_Contact__r.cm_Mobile_Country_Code__c;
         }
         
         list<Joint_Owner__c> lstJointOwners = [Select id,cm_joint_owner__r.Salutation, cm_joint_owner__r.Party_Id__c, cm_joint_owner__r.BillingCountryCode,
                        cm_joint_owner__c,cm_joint_owner__r.Name, cm_joint_owner__r.PersonTitle,
                        cm_joint_owner__r.firstName,cm_joint_owner__r.lastName, cm_joint_owner__r.middleName,cm_joint_owner__r.cm_P_O_Box__c,
                        cm_joint_owner__r.cm_Nationality__pc, cm_joint_owner__r.cm_Passport_Number__pc,
                        cm_joint_owner__r.BillingCity,cm_joint_owner__r.cm_National_ID_No__pc,
                        cm_joint_owner__r.BillingStreet,cm_joint_owner__r.Billingcountry,cm_joint_owner__r.cm_National_ID_Expiry_Date__pc,
                        cm_joint_owner__r.cm_Visa_Expiry_Date__pc, cm_joint_owner__r.cm_Passport_Issue_Date__pc,
                        cm_joint_owner__r.cm_Place_Of_Birth__pc, cm_joint_owner__r.BillingState, cm_joint_owner__r.cm_Birthdate__pc, cm_joint_owner__r.cm_Passport_Expiry_Date__pc,
                        cm_joint_owner__r.billingpostalcode, cm_joint_owner__r.cm_Gender__pc,cm_joint_owner__r.phone,
                        cm_joint_owner__r.cm_Mobile_Country_Code__pc, cm_joint_owner__r.PersonEmail,cm_joint_owner__r.isPersonAccount,
                        cm_joint_owner__r.cm_Phone_Country_Code__c, cm_joint_owner__r.PersonMobilephone,cm_joint_owner__r.cm_Country_Of_Incorporation__c, //Adeel cm_joint_owner__r.ns_Country_of_Residence__pc,
                        cm_joint_owner__r.cm_Trade_License_Expiry_Date__c,cm_joint_owner__r.cm_Trade_License_Number__c,cm_joint_owner__r.cm_Date_of_Incorporation__c,
                        cm_joint_owner__r.Parent_Account__c,cm_joint_owner__r.Parent_Account__r.Party_Id__c,
                        cm_joint_owner__r.PersonBirthdate, cm_joint_owner__r.Emirate__c, cm_Joint_Owner__r.VAT_Registration_No__c  from Joint_Owner__c where cm_Joint_Owner__c <> :objaccount.Id AND cm_Related_Opportunity__c =: stropporid];
         
         ItotalCount = lstOpportunityProperty.size();
         string strAccountRTType = '';
         if(!objAccount.isPersonAccount){
            strAccountRTType = 'ORGANIZATION';
         }
         else{
            strAccountRTType = 'PERSON';
         }
        
         string resourceName = '';
         string resourceId = ''; 
         //modified by Hari to support Referrer
         if(lstoppordata!=null && lstoppordata.size() >0 && lstoppordata[0].cm_Agency_Name__c!=null){
            resourceName =   lstoppordata[0].cm_Agency_Name__c != null ? lstoppordata[0].cm_Agency_Name__r.Name :  '';
            if(resourceName!=''){
                resourceName = resourceName.replaceAll('&','amp;');
            }
            resourceId =   lstoppordata[0].cm_Agency_Name__c != null ? lstoppordata[0].cm_Agency_Name__r.cm_Resource_Id__c : '';
         }
        if(lstoppordata!=null && lstoppordata.size() >0 &&  lstoppordata[0].Referral__c!=null){
            resourceName =   lstoppordata[0].Referral__r != null ? lstoppordata[0].Referral__r.Name :  '';
            if(resourceName!=''){
                resourceName = resourceName.replaceAll('&','amp;');
            }
            resourceId =   lstoppordata[0].Referral__r != null ? lstoppordata[0].Referral__r.cm_Resource_Id__c : '';
        }
        
         
        User userRec = [Select id,cm_Oracle_Username__c, cm_Oracle_User_Id__c from User where Id =: UserInfo.getUserId()];
        string UserName = userRec.cm_Oracle_Username__c;
        
        
        map<string,Id> mpJointOwners = new map<String,Id>();   
        map<id,string>mapAcc = new map<id,string>(); 
        
        integer LRDISCOUNTVal = 0;
        
        string locationCode = '';
        Boolean isFromBrokerApp = false;
        
        for(Opportunity_Property__c OppoPro:lstOpportunityProperty){
            
            //added by Ravi v1.4
            isFromBrokerApp = (OppoPro.cm_Opportunity__r.Is_from_Broker_App__c || OppoPro.cm_Opportunity__r.Is_From_Customer_Direct__c);
            
                /***************************************Account XML**********************************/
            if(lstoppordata!=null && lstoppordata[0].AccountId!=null ){
                
                String monthName=''; 
                string Day ;
                integer year;
                
                
                integer phonecountryCode = objAccount.cm_Phone_Country_Code__c != null ? integer.valueOf(objAccount.cm_Phone_Country_Code__c.split(':')[1].trim()):0;
                //system.debug('>>>>>>>>>>'+objAccount.PersonMobilephone+'>>>>>>>>>>>'+objAccount.Phone);
                string PhoneArea = objAccount.Phone != null ? objAccount.Phone.substring(0,2):'';
                string phoneNum = objAccount.Phone != null ? objAccount.Phone.substring(2,objAccount.Phone.length()):'';
                
                integer mobilecountryCode =0;
                string mobileArea = '';
                string mobileNum = '';
                string nationality = '';
                string countryOfResidence = '';
                if(objAccount.isPersonAccount){
                    mobileArea = objAccount.PersonMobilephone != null ? objAccount.PersonMobilephone.substring(0,2):'';
                    mobileNum = objAccount.PersonMobilephone != null ? objAccount.PersonMobilephone.substring(2,objAccount.PersonMobilephone.length()):'';
                    nationality = objAccount.cm_Nationality__pc != null ? (countryCodes.containsKey(objAccount.cm_Nationality__pc)?countryCodes.get(objAccount.cm_Nationality__pc):''):'';
                    mobilecountryCode = objAccount.cm_Mobile_Country_Code__pc != null ? integer.valueof(objAccount.cm_Mobile_Country_Code__pc.split(':')[1].trim()):0;
                    countryOfResidence = '';
                }
                else{
                    //v1.2
                    oppContactMobile = objAccount.Corporate_Phone__c != null ? objAccount.Corporate_Phone__c : oppContactMobile;
                    oppContactMobCountryCode = objAccount.Corporate_Phone_Country_Code__c != null ? objAccount.Corporate_Phone_Country_Code__c : oppContactMobCountryCode; //v1.2
                    
                    
                    mobileArea = oppContactMobile != null ? oppContactMobile.substring(0,2):'';
                    mobileNum = oppContactMobile != null ? oppContactMobile.substring(2,oppContactMobile.length()):'';
                    countryOfResidence = 'UAE'; //Adeel countryCodes.containsKey(objAccount.ns_Country_of_Residence__pc)?countryCodes.get(objAccount.ns_Country_of_Residence__pc):'';
                    nationality = oppContactNationality != null ? (countryCodes.containsKey(oppContactNationality)?countryCodes.get(oppContactNationality):''):'';
                    mobilecountryCode =  oppContactMobCountryCode != null ? integer.valueof(oppContactMobCountryCode.split(':')[1].trim()):0 ;
                }
                //system.debug(mobileArea+'>>>>>>>>>>'+mobileNum+'>>>>>>>>>>>'+phoneNum+'>>>>>>>>'+PhoneArea);
                string nationalityId = objAccount.cm_National_ID_No__pc != null ? objAccount.cm_National_ID_No__pc:'';
                string placeofBirth = objAccount.cm_Place_Of_Birth__pc != null ? objAccount.cm_Place_Of_Birth__pc:'';
                string passportId = objAccount.cm_Passport_Number__pc != null ? objAccount.cm_Passport_Number__pc:'';
                string gender = objAccount.cm_Gender__pc == null ? '' : objAccount.cm_Gender__pc;
                string middleName = objAccount.MiddleName != null?objAccount.MiddleName:'';
                string strTitle = '';
                if(objAccount.Salutation !=null){
                    if(objAccount.Salutation == 'HE'){
                        strTitle = 'H.E.';
                    }else if (objAccount.Salutation == 'HH'){
                        if(gender == 'Male')
                            strTitle = 'H.H.SHEIKH';
                        else if(gender == 'Female')
                            strTitle = 'H.H.SHEIKHA';
                    }else{
                        strTitle = objAccount.Salutation.toUpperCase();
                    }
                }
                //string title = objAccount.Salutation != null ? objAccount.Salutation.toUpperCase():'';
                string title = strTitle;
                //string incorpCountry = objAccount.cm_Country_Of_Incorporation__c != null ? objAccount.cm_Country_Of_Incorporation__c : '';
                string incorpCountry = countryCodes.containsKey(objAccount.cm_Country_Of_Incorporation__c) ? countryCodes.get(objAccount.cm_Country_Of_Incorporation__c) : '';
                string tradeLicenseNo = objAccount.cm_Trade_License_Number__c != null ? objAccount.cm_Trade_License_Number__c : '';
                //string partyId = objAccount.Party_Id__c == null ? (mapAcc.get(objAccount.id) == null ? '' : mapAcc.get(objAccount.id)) : objAccount.Party_Id__c;
                //v1.8
                string partyId = objAccount.Parent_Account__r.Party_Id__c != null ? (objAccount.Parent_Account__r.Party_Id__c) : objAccount.Party_Id__c;
                
                
                //string billingState = objAccount.billingState != null ?'-'+objAccount.billingState:'.'; 
                string street = objAccount.BillingStreet != null? CM_EmaarUtils.formtStringValue(objAccount.BillingStreet):'.';
                string city = objAccount.BillingCity != null? CM_EmaarUtils.formtStringValue(objAccount.BillingCity):'.';
                string state = objAccount.BillingState != null? CM_EmaarUtils.formtStringValue(objAccount.BillingState):'.';
                string countryCode = objAccount.BillingCountry != null? countryCodes.get(objAccount.Billingcountry):'AE';
                string country = objAccount.BillingCountry != null? CM_EmaarUtils.formtStringValue(objAccount.BillingCountry):'AE';
                
                //v1.7
                /*street = CM_EmaarUtils.formtStringValue(street);
                city =  CM_EmaarUtils.formtStringValue(city);
                state =  CM_EmaarUtils.formtStringValue(state);
                country =  CM_EmaarUtils.formtStringValue(country);
                *///End
                
                string nationalExpiryDate  ='';
                if(objAccount.cm_National_ID_Expiry_Date__pc != null){
                    DateTime d = objAccount.cm_National_ID_Expiry_Date__pc;
                    monthName= d.format('MMM');
                    
                    Day= string.valueof(d.day());
                    if(integer.valueof(day) < 10)
                    day= '0' + day;
                    
                    year= d.year();
                    nationalExpiryDate  = Day+'-'+monthName+'-'+year;
                }
                
                string incorpDate  ='';
                if(objAccount.cm_Date_of_Incorporation__c != null){
                    DateTime d = objAccount.cm_Date_of_Incorporation__c;
                    monthName= d.format('MMM');
                    
                    Day= string.valueof(d.day());
                    if(integer.valueof(day) < 10)
                    day= '0' + day;
                    
                    year= d.year();
                    incorpDate  = Day+'-'+monthName+'-'+year;
                }
                
                string tradeLicenseExpDate='';
                if(objAccount.cm_Trade_License_Expiry_Date__c!=null){
                    DateTime d = objAccount.cm_Trade_License_Expiry_Date__c;
                    monthName= d.format('MMM');
                    
                    Day= string.valueof(d.day());
                    if(integer.valueof(day) < 10)
                    day= '0' + day;
                    
                    year= d.year();
                    tradeLicenseExpDate  = Day+'-'+monthName+'-'+year;
                }
                
                
                string visaExpiryDate  ='';
                if(objAccount.cm_Visa_Expiry_Date__pc != null){
                    DateTime d = objAccount.cm_Visa_Expiry_Date__pc;
                    monthName= d.format('MMM');
                    
                    Day= string.valueof(d.day());
                    if(integer.valueof(day) < 10)
                    day = '0' + day;
                    
                    year = d.year();
                    visaExpiryDate = Day+'-'+monthName+'-'+year;
                }
                
                string passportIssueDate  ='';
                if(objAccount.cm_Passport_Issue_Date__pc != null){
                    DateTime d = objAccount.cm_Passport_Issue_Date__pc;
                    monthName= d.format('MMM');
                    
                    Day= string.valueof(d.day());
                    if(integer.valueof(day) < 10)
                    day= '0' + day;
                    
                    year= d.year();
                    passportIssueDate = Day+'-'+monthName+'-'+year;
                }
                
                string Birthdate  ='';
                if(objAccount.cm_Birthdate__pc!=null){
                    DateTime d = objAccount.cm_Birthdate__pc;
                    monthName= d.format('MMM');
                    
                    Day= string.valueof(d.day());
                    if(integer.valueof(day) < 10)
                    day= '0' + day;
                    
                    year= d.year();
                    Birthdate  = Day+'-'+monthName+'-'+year;
                }
                
                string passportExpiryDate='';
                if(objAccount.cm_Passport_Expiry_Date__pc!=null){
                    DateTime d = objAccount.cm_Passport_Expiry_Date__pc;
                    monthName= d.format('MMM');
                    
                    Day= string.valueof(d.day());
                    if(integer.valueof(day) < 10)
                    day= '0' + day;
                    
                    year= d.year();
                    passportExpiryDate  = Day+'-'+monthName+'-'+year;
                }

                integer phoneCount = 0;
                if(objAccount.isPersonAccount && objAccount.PersonmobilePhone != null){
                    if(partyId == null || partyId == '')
                        phoneCount ++;
                }else if(objAccount.isPersonAccount == false && objAccount.Corporate_Phone__c != null){//if(mobileNum != null)
                    phoneCount ++;
                }else if(mobileNum != null)
                    phoneCount ++;
                    
                if(objAccount.Phone != null)
                    phoneCount ++;
                
                
                integer emailCount = 0;
                if(objAccount.PersonEmail != null)
                    emailCount++;
                else if(objAccount.isPersonAccount == false && objAccount.Corporate_Email__c != null ){ ////added by Ravi //v1.2 objAccount.Email__c != null || oppContactEmail != null
                    emailCount++;
                    oppContactEmail = objAccount.Corporate_Email__c;
                }
                if(objAccount.Email__c != null){
                    emailCount++;
                }
                
                AccountXML = '<XX_PARTY_INFO>';
                AccountXML = AccountXML+'<XX_PARTY_DETAILS>';
                AccountXML = AccountXML+'<PARTY>';
                AccountXML = AccountXML+'<P_TITLE>'+title+'</P_TITLE>';//'+objAccount.PersonTitle+'
                AccountXML = AccountXML+'<P_DESIGNATION/>';
                AccountXML = AccountXML+'<P_GLOBAL_PARTY_ID/>';
                AccountXML = AccountXML+'<P_PARTY_ID>'+partyId+'</P_PARTY_ID>';
                AccountXML = AccountXML+'<P_PARTY_TYPE>'+strAccountRTType +'</P_PARTY_TYPE>';
                AccountXML = AccountXML+'<P_FIRST_NAME>'+CM_EmaarUtils.formtStringValue(objAccount.FirstName)+'</P_FIRST_NAME>'; //v1.6
                AccountXML = AccountXML+'<P_MIDDLE_NAME>'+CM_EmaarUtils.formtStringValue(middleName)+'</P_MIDDLE_NAME>';
                AccountXML = AccountXML+'<P_LAST_NAME>'+CM_EmaarUtils.formtStringValue(objAccount.LastName)+'</P_LAST_NAME>';
                AccountXML = AccountXML+'<P_FULL_NAME>'+CM_EmaarUtils.formtStringValue(objAccount.Name)+'</P_FULL_NAME>';                   
                AccountXML = AccountXML+'<P_NATIONALITY>'+nationality+'</P_NATIONALITY>';//'+objAccount.cm_Nationality__pc+'
                AccountXML = AccountXML+'<P_PLACE_OF_BIRTH>'+CM_EmaarUtils.formtStringValue(placeofBirth)+'</P_PLACE_OF_BIRTH>';
                AccountXML = AccountXML+'<P_NATIONAL_ID>'+nationalityId+'</P_NATIONAL_ID>';
                AccountXML = AccountXML+'<P_NATIONAL_ID_EXPIRY>'+nationalExpiryDate+'</P_NATIONAL_ID_EXPIRY>';
                //Not useing ORACLE as per Abdullah AccountXML = AccountXML+'<P_VISA_EXPIRY_DATE>'+visaExpiryDate+'</P_VISA_EXPIRY_DATE>';
                if(objAccount.isPersonAccount){
                    AccountXML = AccountXML+'<P_ID_TYPE>PASSPORT</P_ID_TYPE>';//'+objAccount.cm_Passport_Number__pc+'
                    AccountXML = AccountXML+'<P_ID>'+passportId+'</P_ID>';
                    AccountXML = AccountXML+'<P_ID_EXPIRY_DATE>'+passportExpiryDate+'</P_ID_EXPIRY_DATE>';//'+expdate+'
                    
                    AccountXML = AccountXML+'<VISA_NUMBER>'+objAccount.Visa_No__pc+'</VISA_NUMBER>';
                    AccountXML = AccountXML+'<VISA_ISSUE>'+CM_EmaarUtils.formatORACLEDate(objAccount.Visa_Issue_Date__pc)+'</VISA_ISSUE>';
                    AccountXML = AccountXML+'<VISA_EXPIRY>'+CM_EmaarUtils.formatORACLEDate(objAccount.cm_Visa_Expiry_Date__pc)+'</VISA_EXPIRY>';
                    
                }else{
                    AccountXML = AccountXML+'<P_ID_TYPE>TRADE_LICENSE</P_ID_TYPE>';//'+objAccount.cm_Passport_Number__pc+'
                    AccountXML = AccountXML+'<P_ID>'+tradeLicenseNo+'</P_ID>';//'+objAccount.cm_Passport_Number__pc+'
                    AccountXML = AccountXML+'<P_ID_EXPIRY_DATE>'+tradeLicenseExpDate+'</P_ID_EXPIRY_DATE>';
                } 
                
                
                //v1.7
                string postalcode = objAccount.Billingpostalcode != null ? CM_EmaarUtils.formtStringValue(objAccount.Billingpostalcode) : '';
                //postalcode =  CM_EmaarUtils.formtStringValue(postalcode);
                string pobox = objAccount.cm_P_O_Box__c != null ? CM_EmaarUtils.formtStringValue(objAccount.cm_P_O_Box__c) : '';
                //pobox =  CM_EmaarUtils.formtStringValue(pobox);
                //End
    
                AccountXML = AccountXML+'<P_ID_ISSUE_DATE>'+passportIssueDate+'</P_ID_ISSUE_DATE>';
                AccountXML = AccountXML+'<P_DOB>'+Birthdate+'</P_DOB>';//'+Birthdate+'
                AccountXML = AccountXML+'<P_AGE_GROUP></P_AGE_GROUP>';
                AccountXML = AccountXML+'<P_AVG_MONTHLY_INCOME></P_AVG_MONTHLY_INCOME>';            
                AccountXML = AccountXML+'<P_ADDRESS1>'+street+'</P_ADDRESS1><P_ADDRESS2/>';
                AccountXML = AccountXML+'<P_POBOX>'+pobox+'</P_POBOX>';//objAccount.cm_P_O_Box__c
                AccountXML = AccountXML+'<P_CITY>'+city+'-'+state+'</P_CITY>';//
                AccountXML = AccountXML+'<P_POSTAL_CODE>'+postalcode+'</P_POSTAL_CODE>';//'+objAccount.Billingpostalcode+'objAccount.Billingpostalcode
                AccountXML = AccountXML+'<P_COUNTRY>'+countrycode+'</P_COUNTRY>';
                AccountXML = AccountXML+'<P_LOCATION_ID>'+OppoPro.cm_Property_Inventory__r.location__r.Location_Id__c+'</P_LOCATION_ID>';
                //v1.4
                AccountXML += '<P_STATE>'+(objAccount.BillingState != null ? objAccount.BillingState : (objAccount.BillingCountry == 'United States' ? 'NY' : ''))+'</P_STATE>';
                /*if(objAccount.BillingCountry == 'United States'){
                	AccountXML += '<P_STATE>'+(objAccount.BillingState != null ? objAccount.BillingState : 'NY')+'</P_STATE>';
                }else
                	AccountXML += '<P_STATE>'+(objAccount.BillingState != null ? objAccount.BillingState : '')+'</P_STATE>';
                */
                
                //v2.0
                AccountXML = AccountXML+'<SHIPPING_COUNTRY>'+(countryCodes.containsKey(objAccount.ShippingCountry) ? countryCodes.get(objAccount.ShippingCountry) : '')+'</SHIPPING_COUNTRY>';
                AccountXML = AccountXML+'<SHIPPING_STREET>'+CM_EmaarUtils.formtStringValue(objAccount.ShippingStreet)+'</SHIPPING_STREET>';
                AccountXML = AccountXML+'<SHIPPING_CITY>'+CM_EmaarUtils.formtStringValue(objAccount.ShippingCity)+'</SHIPPING_CITY>';
                
                //v1.4
                AccountXML += '<SHIPPING_STATE>'+(objAccount.ShippingState != null ? objAccount.ShippingState : (objAccount.ShippingCountry == 'United States' ? 'NY' : ''))+'</SHIPPING_STATE>';
                /*if(objAccount.ShippingCountry == 'United States'){
                	AccountXML += '<SHIPPING__STATE>'+(objAccount.ShippingState != null ? objAccount.ShippingState : 'NY')+'</SHIPPING__STATE>';
                }else
                	AccountXML = AccountXML+'<SHIPPING_STATE></SHIPPING_STATE>';
                */
                AccountXML = AccountXML+'<SHIPPING_POSTAL_CODE></SHIPPING_POSTAL_CODE>';
                AccountXML = AccountXML+'<SHIPPING_PO_BOX>'+CM_EmaarUtils.formtStringValue(objAccount.Shipping_P_O_Box__c)+'</SHIPPING_PO_BOX>';
                if(objAccount.Shipping_Mobile_Number__c != null){
                    phoneCount ++;
                }
                //end of v2.0
                
                //v1.6
                if(partyId != null && partyId != ''){
                    //phoneCount = 0;
                    EmailCount = 0;
                }
                
                AccountXML = AccountXML+'<P_PHONE_COUNT>'+phoneCount+'</P_PHONE_COUNT>';
                AccountXML = AccountXML+'<P_EMAIL_COUNT>'+EmailCount+'</P_EMAIL_COUNT>';
                AccountXML = AccountXML+'<P_GENDER>'+objAccount.cm_Gender__pc+'</P_GENDER>';//'+gender+'
                AccountXML = AccountXML+'<P_DATE_OF_INCORPORATION>'+incorpDate+'</P_DATE_OF_INCORPORATION>';
                AccountXML = AccountXML+'<P_COUNTRY_OF_INCORPORATION>'+incorpCountry+'</P_COUNTRY_OF_INCORPORATION>';
                AccountXML = AccountXML+'<P_TRADE_LICENSE_EXPIRY_DATE>'+tradeLicenseExpDate+'</P_TRADE_LICENSE_EXPIRY_DATE>';
                AccountXML = AccountXML+'<P_INCORPORATION_AUTHORITY/>';
                AccountXML = AccountXML+'<P_COUNTRY_OF_RESIDENCE>'+countryOfResidence+'</P_COUNTRY_OF_RESIDENCE>';
            
                //v1.5
                Integer iC = 0;
                if(objAccount.isPersonAccount == false && objAccount.Contacts != null && !objAccount.Contacts.isEmpty()){
                    iC++;
                }
                AccountXML = AccountXML+'<P_CONTACT_PERSON_COUNT>'+iC+'</P_CONTACT_PERSON_COUNT>';
                //end of v1.5
                
                AccountXML = AccountXML+'</PARTY>';
                AccountXML = AccountXML+'<PHONE_DETAILS>';
                
                //v1.6
                if(partyId == null || partyId == '')
                    AccountXML = AccountXML+'<PHONE_DETAIL><P_CONTACT_POINT_TYPE>PHONE</P_CONTACT_POINT_TYPE><P_PHONE_LINE_TYPE>MOBILE</P_PHONE_LINE_TYPE><P_PHONE_COUNTRY_CODE>'+mobilecountryCode+'</P_PHONE_COUNTRY_CODE><P_PHONE_AREA_CODE>'+mobileArea+'</P_PHONE_AREA_CODE><P_PHONE_NUMBER>'+mobileNum+'</P_PHONE_NUMBER></PHONE_DETAIL>';
            
                if(phoneNum != null && phoneNum != '')
                    AccountXML = AccountXML+'<PHONE_DETAIL><P_CONTACT_POINT_TYPE>PHONE</P_CONTACT_POINT_TYPE><P_PHONE_LINE_TYPE>GEN</P_PHONE_LINE_TYPE><P_PHONE_COUNTRY_CODE>'+phonecountryCode+'</P_PHONE_COUNTRY_CODE><P_PHONE_AREA_CODE>'+phoneArea+'</P_PHONE_AREA_CODE><P_PHONE_NUMBER>'+phoneNum+'</P_PHONE_NUMBER></PHONE_DETAIL>';
                
                //v2.0
                if(objAccount.Shipping_Mobile_Number__c != null && objAccount.Shipping_Mobile_Number__c != ''){
                    Integer shipCC = objAccount.Shipping_Mobile_Country_Code__c != null ? integer.valueOf(objAccount.Shipping_Mobile_Country_Code__c.split(':')[1].trim()):0;
                    string shipArea = objAccount.Shipping_Mobile_Number__c != null ? objAccount.Shipping_Mobile_Number__c.substring(0,2):'';
                    string shipNo = objAccount.Shipping_Mobile_Number__c != null ? objAccount.Shipping_Mobile_Number__c.substring(2,objAccount.Shipping_Mobile_Number__c.length()):'';
                    AccountXML = AccountXML+'<PHONE_DETAIL><P_CONTACT_POINT_TYPE>PHONE</P_CONTACT_POINT_TYPE><P_PHONE_LINE_TYPE>GEN</P_PHONE_LINE_TYPE><P_PHONE_COUNTRY_CODE>'+shipCC+'</P_PHONE_COUNTRY_CODE><P_PHONE_AREA_CODE>'+shipArea+'</P_PHONE_AREA_CODE><P_PHONE_NUMBER>'+shipNo+'</P_PHONE_NUMBER></PHONE_DETAIL>';
                }
                //end of v2.0
                
                AccountXML = AccountXML+'</PHONE_DETAILS>';
                
                if(EmailCount>0){
                    if(objAccount.isPersonAccount)
                        AccountXML = AccountXML+'<EMAIL_DETAILS><EMAIL_DETAIL><P_CONTACT_POINT_TYPE>EMAIL</P_CONTACT_POINT_TYPE><P_EMAIL_ADDRESS>'+objAccount.PersonEmail+'</P_EMAIL_ADDRESS></EMAIL_DETAIL></EMAIL_DETAILS>';
                    else
                        AccountXML = AccountXML+'<EMAIL_DETAILS><EMAIL_DETAIL><P_CONTACT_POINT_TYPE>EMAIL</P_CONTACT_POINT_TYPE><P_EMAIL_ADDRESS>'+oppContactEmail+'</P_EMAIL_ADDRESS></EMAIL_DETAIL></EMAIL_DETAILS>';
                        //AccountXML = AccountXML+'<EMAIL_DETAILS><EMAIL_DETAIL><P_CONTACT_POINT_TYPE>EMAIL</P_CONTACT_POINT_TYPE><P_EMAIL_ADDRESS>'+objAccount.Email__c+'</P_EMAIL_ADDRESS></EMAIL_DETAIL></EMAIL_DETAILS>';
                        // commented and added above line AccountXML = AccountXML+'<EMAIL_DETAILS><EMAIL_DETAIL><P_CONTACT_POINT_TYPE>EMAIL</P_CONTACT_POINT_TYPE><P_EMAIL_ADDRESS>'+oppContactEmail+'</P_EMAIL_ADDRESS></EMAIL_DETAIL></EMAIL_DETAILS>';
                }
                    
                /******************************VAT CHANGES************************************************/
                
                if(objAccount.Emirate__c!=null)
                    AccountXML = AccountXML+'<P_VAT_EMIRATE>'+objAccount.Emirate__c+'</P_VAT_EMIRATE>';
                else
                   AccountXML = AccountXML+'<P_VAT_EMIRATE></P_VAT_EMIRATE>';
                   
                if(objAccount.VAT_Registration_No__c!=null)
                    AccountXML = AccountXML+'<P_VAT_REGNUMBER>'+objAccount.VAT_Registration_No__c+'</P_VAT_REGNUMBER>';
                else
                   AccountXML = AccountXML+'<P_VAT_REGNUMBER></P_VAT_REGNUMBER>';
                   
                /******************************VAT CHANGES************************************************/
                
                AccountXML = AccountXML+'</XX_PARTY_DETAILS>';
                
                if(lstJointOwners.isEmpty())
                    AccountXML = AccountXML+'<XX_JOINT_OWNERS/>';
                else{
                    AccountXML = AccountXML+'<XX_JOINT_OWNERS>';
                    for(Joint_Owner__c own:lstJointOwners){
                        
                        if(own.cm_joint_owner__r.isPersonAccount)
                            strAccountRTType = 'PERSON';
                        else
                            strAccountRTType = 'ORGANIZATION';
                        
                        mobilecountryCode = String.isNotBlank(own.cm_joint_owner__r.cm_Mobile_Country_Code__pc) && own.cm_joint_owner__r.cm_Mobile_Country_Code__pc.split(':').size() > 1 ? integer.valueof(own.cm_joint_owner__r.cm_Mobile_Country_Code__pc.split(':')[1].trim()):0;
                        phonecountryCode = String.isNotBlank(own.cm_joint_owner__r.cm_Phone_Country_Code__c)  && own.cm_joint_owner__r.cm_Phone_Country_Code__c.split(':').size() > 1 ? integer.valueof(own.cm_joint_owner__r.cm_Phone_Country_Code__c.split(':')[1].trim()):0;
                        
                        //system.debug('>>>>>>>>>>'+own.cm_joint_owner__r.PersonMobilephone+'>>>>>>>>>>>'+own.cm_joint_owner__r.Phone);
                        
                        mobileArea = own.cm_joint_owner__r.PersonMobilephone != null ? own.cm_joint_owner__r.PersonMobilephone.substring(0,2):'';
                        PhoneArea = own.cm_joint_owner__r.Phone != null ? own.cm_joint_owner__r.Phone.substring(0,2):'';
                        mobileNum = own.cm_joint_owner__r.PersonMobilephone != null ? own.cm_joint_owner__r.PersonMobilephone.substring(2,own.cm_joint_owner__r.PersonMobilephone.length()):'';
                        phoneNum = own.cm_joint_owner__r.Phone != null ? own.cm_joint_owner__r.Phone.substring(2,own.cm_joint_owner__r.Phone.length()):'';
                        countryOfResidence = 'UAE'; //Adeel countryCodes.containsKey(own.cm_joint_owner__r.ns_Country_of_Residence__pc)?countryCodes.get(own.cm_joint_owner__r.ns_Country_of_Residence__pc):'';
                        //incorpCountry = own.cm_joint_owner__r.cm_Country_Of_Incorporation__c != null ? own.cm_joint_owner__r.cm_Country_Of_Incorporation__c : '';
                        incorpCountry = countryCodes.containsKey(own.cm_joint_owner__r.cm_Country_Of_Incorporation__c)?countryCodes.get(own.cm_joint_owner__r.cm_Country_Of_Incorporation__c):'';
                        tradeLicenseNo = own.cm_joint_owner__r.cm_Trade_License_Number__c != null ? own.cm_joint_owner__r.cm_Trade_License_Number__c : '';   
                        
                        //partyId = own.cm_joint_owner__r.party_Id__c == null?'':own.cm_joint_owner__r.party_Id__c;
                        //v1.8
                        partyId = own.cm_joint_owner__r.Parent_Account__r.Party_Id__c != null ? own.cm_joint_owner__r.Parent_Account__r.Party_Id__c : own.cm_joint_owner__r.party_Id__c;
                        partyId = partyId != null ? '' : partyId;
                        
                        title = own.cm_joint_owner__r.Salutation != null ? own.cm_joint_owner__r.Salutation.toUpperCase():'';
                        passportId = own.cm_joint_owner__r.cm_Passport_Number__pc != null ? own.cm_joint_owner__r.cm_Passport_Number__pc:'';
                        gender = own.cm_joint_owner__r.cm_Gender__pc == null ? '' : own.cm_joint_owner__r.cm_Gender__pc;
                        nationality = own.cm_joint_owner__r.cm_Nationality__pc != null ? (countryCodes.containsKey(own.cm_joint_owner__r.cm_Nationality__pc) ? countryCodes.get(own.cm_joint_owner__r.cm_Nationality__pc):''):'';
                        nationalityId = own.cm_joint_owner__r.cm_Nationality__pc != null ? own.cm_joint_owner__r.cm_National_ID_No__pc:'';
                        placeofBirth = own.cm_joint_owner__r.cm_Place_Of_Birth__pc != null ? own.cm_joint_owner__r.cm_Place_Of_Birth__pc:'';
                        
                        /*v2.0 billingState = objAccount.billingState != null ?'-'+objAccount.billingState:'.'; 
                        street = objAccount.BillingStreet != null? objAccount.BillingStreet:'.';
                        city = objAccount.BillingCity != null? objAccount.BillingCity:'.';
                        state = objAccount.BillingState != null? objAccount.BillingState:'.';
                        countryCode = objAccount.BillingCountry != null? countryCodes.get(objAccount.Billingcountry):'AE';
                        country = objAccount.BillingCountry != null? objAccount.BillingCountry:'AE';
                        */
                        //v2.0
                        //billingState = own.cm_joint_owner__r.billingState != null ?'-'+own.cm_joint_owner__r.billingState:'.'; 
                        street = own.cm_joint_owner__r.BillingStreet != null? CM_EmaarUtils.formtStringValue(own.cm_joint_owner__r.BillingStreet):'.';
                        city = own.cm_joint_owner__r.BillingCity != null? CM_EmaarUtils.formtStringValue(own.cm_joint_owner__r.BillingCity):'.';
                        state = own.cm_joint_owner__r.BillingState != null? CM_EmaarUtils.formtStringValue(own.cm_joint_owner__r.BillingState):'.';
                        countryCode = own.cm_joint_owner__r.BillingCountry != null? countryCodes.get(own.cm_joint_owner__r.Billingcountry):'AE';
                        country = own.cm_joint_owner__r.BillingCountry != null? CM_EmaarUtils.formtStringValue(own.cm_joint_owner__r.BillingCountry):'AE';
                        
                        //v1.7
                        /*street  = CM_EmaarUtils.formtStringValue(street);
                        city  = CM_EmaarUtils.formtStringValue(city); 
                        state  = CM_EmaarUtils.formtStringValue(state); 
                        country = CM_EmaarUtils.formtStringValue(country); 
                        *///End
                                
                        phoneCount = 0;
                        if(own.cm_joint_owner__r.isPersonAccount && own.cm_joint_owner__r.PersonMobilephone != null)
                            phoneCount ++;
                        if(own.cm_joint_owner__r.Phone != null)
                            phoneCount ++;
                        
                        emailcount = 0;
                        if(own.cm_joint_owner__r.PersonEmail != null)
                            emailcount++;
                            
                        
                        
                        birthdate  ='';
                        if(own.cm_joint_owner__r.cm_Birthdate__pc!=null){
                            DateTime d = own.cm_joint_owner__r.cm_Birthdate__pc;
                            monthName= d.format('MMM');
                            
                            Day= string.valueof(d.day());
                            if(integer.valueof(day) < 10)
                            day= '0' + day;
                            
                            year= d.year();
                            Birthdate  = Day+'-'+monthName+'-'+year;
                        }
                        
                        passportExpiryDate='';
                        if(own.cm_joint_owner__r.cm_Passport_Expiry_Date__pc!=null){
                            DateTime d = own.cm_joint_owner__r.cm_Passport_Expiry_Date__pc;
                            monthName= d.format('MMM');
                            
                            Day= string.valueof(d.day());
                            if(integer.valueof(day) < 10)
                            day= '0' + day;
                            
                            year= d.year();
                            passportExpiryDate  = Day+'-'+monthName+'-'+year;
                        }
                        
                        
                        nationalExpiryDate  ='';
                        if(own.cm_joint_owner__r.cm_National_ID_Expiry_Date__pc != null){
                            DateTime d = own.cm_joint_owner__r.cm_National_ID_Expiry_Date__pc;
                            monthName= d.format('MMM');
                            
                            Day= string.valueof(d.day());
                            if(integer.valueof(day) < 10)
                            day= '0' + day;
                            
                            year= d.year();
                            nationalExpiryDate  = Day+'-'+monthName+'-'+year;
                        }
                        
                        
                        visaExpiryDate  ='';
                        if(own.cm_joint_owner__r.cm_Visa_Expiry_Date__pc != null){
                            DateTime d = own.cm_joint_owner__r.cm_Visa_Expiry_Date__pc;
                            monthName= d.format('MMM');
                            
                            Day= string.valueof(d.day());
                            if(integer.valueof(day) < 10)
                            day= '0' + day;
                            
                            year= d.year();
                            visaExpiryDate = Day+'-'+monthName+'-'+year;
                        }
                        
                        passportIssueDate  ='';
                        if(own.cm_joint_owner__r.cm_Passport_Issue_Date__pc != null){
                            DateTime d = own.cm_joint_owner__r.cm_Passport_Issue_Date__pc;
                            monthName= d.format('MMM');
                            
                            Day= string.valueof(d.day());
                            if(integer.valueof(day) < 10)
                            day= '0' + day;
                            
                            year= d.year();
                            passportIssueDate = Day+'-'+monthName+'-'+year;
                        }
                        
                        incorpDate  ='';
                        if(own.cm_joint_owner__r.cm_Date_of_Incorporation__c != null){
                            DateTime d = own.cm_joint_owner__r.cm_Date_of_Incorporation__c;
                            monthName= d.format('MMM');
                            
                            Day= string.valueof(d.day());
                            if(integer.valueof(day) < 10)
                            day= '0' + day;
                            
                            year= d.year();
                            incorpDate  = Day+'-'+monthName+'-'+year;
                        }
                        
                        tradeLicenseExpDate='';
                        if(own.cm_joint_owner__r.cm_Trade_License_Expiry_Date__c!=null){
                            DateTime d = own.cm_joint_owner__r.cm_Trade_License_Expiry_Date__c;
                            monthName= d.format('MMM');
                            
                            Day= string.valueof(d.day());
                            if(integer.valueof(day) < 10)
                            day= '0' + day;
                            
                            year= d.year();
                            tradeLicenseExpDate  = Day+'-'+monthName+'-'+year;
                        }
                        
                        postalcode = own.cm_joint_owner__r.Billingpostalcode;
                        postalcode = CM_EmaarUtils.formtStringValue(postalcode); 
                        
                        pobox = own.cm_joint_owner__r.cm_P_O_Box__c;
                        pobox = CM_EmaarUtils.formtStringValue(pobox);
                                
                        AccountXML = AccountXML+'<XX_JOINT_OWNER>';
                        AccountXML = AccountXML+'<PARTY>';
                        AccountXML = AccountXML+'<P_TITLE>'+title+'</P_TITLE>';//'+objAccount.PersonTitle+'
                        AccountXML = AccountXML+'<P_DESIGNATION/><P_GLOBAL_PARTY_ID/>';
                        AccountXML = AccountXML+'<P_PARTY_ID>'+partyId+'</P_PARTY_ID>';                 
                        AccountXML = AccountXML+'<P_PARTY_TYPE>'+strAccountRTType+'</P_PARTY_TYPE>';
                        AccountXML = AccountXML+'<P_FIRST_NAME>'+CM_EmaarUtils.formtStringValue(own.cm_joint_owner__r.FirstName)+'</P_FIRST_NAME>';
                        AccountXML = AccountXML+'<P_MIDDLE_NAME>'+CM_EmaarUtils.formtStringValue(own.cm_joint_owner__r.MiddleName)+'</P_MIDDLE_NAME>';
                        AccountXML = AccountXML+'<P_LAST_NAME>'+CM_EmaarUtils.formtStringValue(own.cm_joint_owner__r.LastName)+'</P_LAST_NAME>';
                        AccountXML = AccountXML+'<P_FULL_NAME>'+CM_EmaarUtils.formtStringValue(own.cm_joint_owner__r.Name)+'</P_FULL_NAME>';
                        AccountXML = AccountXML+'<P_NATIONALITY>'+nationality+'</P_NATIONALITY>';//'+objAccount.cm_Nationality__pc+'
                        AccountXML = AccountXML+'<P_PLACE_OF_BIRTH>'+CM_EmaarUtils.formtStringValue(placeofBirth)+'</P_PLACE_OF_BIRTH>';
                        AccountXML = AccountXML+'<P_NATIONAL_ID>'+nationalityId+'</P_NATIONAL_ID>';
                        AccountXML = AccountXML+'<P_NATIONAL_ID_EXPIRY>'+nationalExpiryDate+'</P_NATIONAL_ID_EXPIRY>';
                        AccountXML = AccountXML+'<P_VISA_EXPIRY_DATE>'+visaExpiryDate+'</P_VISA_EXPIRY_DATE>';                  
                        AccountXML = AccountXML+'<P_ID_TYPE>PASSPORT</P_ID_TYPE>';
                        AccountXML = AccountXML+'<P_ID>'+passportId+'</P_ID>';//'+objAccount.cm_Passport_Number__pc+'
                        AccountXML = AccountXML+'<P_ID_EXPIRY_DATE>'+passportExpiryDate+'</P_ID_EXPIRY_DATE>';//'+expdate+'
                        AccountXML = AccountXML+'<P_ID_ISSUE_DATE>'+passportIssueDate+'</P_ID_ISSUE_DATE>';
                        AccountXML = AccountXML+'<P_DOB>'+birthdate+'</P_DOB>';//'+Birthdate+'
                        AccountXML = AccountXML+'<P_AGE_GROUP></P_AGE_GROUP>';
                        AccountXML = AccountXML+'<P_AVG_MONTHLY_INCOME></P_AVG_MONTHLY_INCOME>';
                        AccountXML = AccountXML+'<P_ADDRESS1>'+street+'</P_ADDRESS1><P_ADDRESS2/>';
                        AccountXML = AccountXML+'<P_POBOX>'+pobox+'</P_POBOX>';//own.cm_joint_owner__r.cm_P_O_Box__c;'+objAccount.Billingpostalcode+'
                        AccountXML = AccountXML+'<P_CITY>'+city+' - '+state+'</P_CITY>';//'+objAccount.BillingCity+'
                        AccountXML = AccountXML+'<P_POSTAL_CODE>'+postalcode+'</P_POSTAL_CODE>';//own.cm_joint_owner__r.Billingpostalcode;'+objAccount.Billingpostalcode+'
                        
                        AccountXML += '<P_STATE>'+(own.cm_joint_owner__r.BillingState != null ? own.cm_joint_owner__r.BillingState : (own.cm_joint_owner__r.BillingCountry == 'United States' ? 'NY' : ''))+'</P_STATE>';
                        
                        AccountXML = AccountXML+'<P_COUNTRY>'+countryCode+'</P_COUNTRY>';
                        AccountXML = AccountXML+'<P_LOCATION_ID>'+OppoPro.cm_Property_Inventory__r.location__r.Location_Id__c+'</P_LOCATION_ID>';
                        AccountXML = AccountXML+'<P_PHONE_COUNT>'+phoneCount+'</P_PHONE_COUNT>';
                        AccountXML = AccountXML+'<P_EMAIL_COUNT>'+emailCount+'</P_EMAIL_COUNT>';
                        AccountXML = AccountXML+'<P_GENDER>'+own.cm_joint_owner__r.cm_Gender__pc+'</P_GENDER>';//'+gender+'
                        AccountXML = AccountXML+'<P_DATE_OF_INCORPORATION>'+incorpDate+'</P_DATE_OF_INCORPORATION>';
                        AccountXML = AccountXML+'<P_COUNTRY_OF_INCORPORATION>'+incorpCountry+'</P_COUNTRY_OF_INCORPORATION>';
                        AccountXML = AccountXML+'<P_TRADE_LICENSE_EXPIRY_DATE>'+tradeLicenseExpDate+'</P_TRADE_LICENSE_EXPIRY_DATE>';
                        AccountXML = AccountXML+'<P_TRADE_LICENSE_NUMBER>'+tradeLicenseNo+'</P_TRADE_LICENSE_NUMBER>';
                        AccountXML = AccountXML+'<P_INCORPORATION_AUTHORITY/>';
                        AccountXML = AccountXML+'<P_COUNTRY_OF_RESIDENCE>'+countryOfResidence+'</P_COUNTRY_OF_RESIDENCE>';
                        AccountXML = AccountXML+'</PARTY>';
                        
                        AccountXML = AccountXML+'<PHONE_DETAILS>';
                
                        if(own.cm_joint_owner__r.isPersonAccount)
                        AccountXML = AccountXML+'<PHONE_DETAIL><P_CONTACT_POINT_TYPE>PHONE</P_CONTACT_POINT_TYPE><P_PHONE_LINE_TYPE>MOBILE</P_PHONE_LINE_TYPE><P_PHONE_COUNTRY_CODE>'+mobilecountryCode+'</P_PHONE_COUNTRY_CODE><P_PHONE_AREA_CODE>'+mobileArea+'</P_PHONE_AREA_CODE><P_PHONE_NUMBER>'+mobileNum+'</P_PHONE_NUMBER></PHONE_DETAIL>';
                        
                        if(phoneNum != null && phoneNum != '')
                        AccountXML = AccountXML+'<PHONE_DETAIL><P_CONTACT_POINT_TYPE>PHONE</P_CONTACT_POINT_TYPE><P_PHONE_LINE_TYPE>GEN</P_PHONE_LINE_TYPE><P_PHONE_COUNTRY_CODE>'+phonecountryCode+'</P_PHONE_COUNTRY_CODE><P_PHONE_AREA_CODE>'+phoneArea+'</P_PHONE_AREA_CODE><P_PHONE_NUMBER>'+phoneNum+'</P_PHONE_NUMBER></PHONE_DETAIL>';
                        
                        AccountXML = AccountXML+'</PHONE_DETAILS>';
                        
                        if(emailCount > 0)
                        AccountXML = AccountXML+'<EMAIL_DETAILS><EMAIL_DETAIL><P_CONTACT_POINT_TYPE>EMAIL</P_CONTACT_POINT_TYPE><P_EMAIL_ADDRESS>'+own.cm_joint_owner__r.PersonEmail+'</P_EMAIL_ADDRESS></EMAIL_DETAIL></EMAIL_DETAILS>';
                        
                        /******************************VAT CHANGES************************************************/
                        if(own.cm_joint_owner__r.Emirate__c!=null)
                            AccountXML = AccountXML+'<P_VAT_EMIRATE>'+own.cm_joint_owner__r.Emirate__c+'</P_VAT_EMIRATE>';
                        else
                           AccountXML = AccountXML+'<P_VAT_EMIRATE></P_VAT_EMIRATE>';
                           
                        if(own.cm_joint_owner__r.VAT_Registration_No__c!=null)
                            AccountXML = AccountXML+'<P_VAT_REGNUMBER>'+own.cm_joint_owner__r.VAT_Registration_No__c+'</P_VAT_REGNUMBER>';
                        else
                           AccountXML = AccountXML+'<P_VAT_REGNUMBER></P_VAT_REGNUMBER>';
                        /******************************VAT CHANGES************************************************/
                
                        
                        AccountXML = AccountXML+'</XX_JOINT_OWNER>';
                        
                        string key = '';
                        if(own.cm_joint_owner__r.isPersonAccount)
                            key = own.cm_joint_owner__r.firstName+'###'+own.cm_joint_owner__r.LastName;
                        else
                            key = own.cm_joint_owner__r.Name;
                        //mpJointOwners.put(key,own.cm_joint_owner__c);
                        //v1.8
                        mpJointOwners.put(key,( own.cm_joint_owner__r.Parent_Account__c != null ? own.cm_joint_owner__r.Parent_Account__c : own.cm_joint_owner__c));
                    }
                    AccountXML = AccountXML+'</XX_JOINT_OWNERS>';
                }
                
                //v1.5
                if(objAccount != null && objAccount.isPersonAccount == false && objAccount.Contacts != null && !objAccount.Contacts.isEmpty()){
                    AccountXML += '<ORG_CONTACT_PERSON>';
                    
                    for(Contact objCon : objAccount.Contacts){
                        AccountXML += '<ORG_CONTACT_DETAILS>';
                        AccountXML += '<CONTACT_PERSON>';
                            title = objCon.Salutation != null ? objCon.Salutation.toUpperCase() : '';
                            
                            if(objCon.Salutation == 'HE'){
                                    title = 'H.E.';
                                }else if (objCon.Salutation == 'HH'){
                                    if(objCon.cm_Gender__c == 'Male')
                                        title = 'H.H.SHEIKH';
                                    else if(objCon.cm_Gender__c == 'Female')
                                        title = 'H.H.SHEIKHA';
                                }
                                                    
                                AccountXML += '<P_TITLE>'+title+'</P_TITLE>';
                                AccountXML += '<P_DESIGNATION/>';
                                AccountXML += '<P_GLOBAL_PARTY_ID/>';
                                AccountXML += '<P_FIRST_NAME>'+CM_EmaarUtils.formtStringValue(objCon.FirstName)+'</P_FIRST_NAME>';
                                AccountXML += '<P_MIDDLE_NAME>'+CM_EmaarUtils.formtStringValue(objCon.MiddleName)+'</P_MIDDLE_NAME>';
                                AccountXML += '<P_LAST_NAME>'+CM_EmaarUtils.formtStringValue(objCon.LastName)+'</P_LAST_NAME>';
                                AccountXML += '<P_FULL_NAME>'+CM_EmaarUtils.formtStringValue(objCon.Name)+'</P_FULL_NAME>';
                                AccountXML += '<P_NATIONALITY>'+((objCon.cm_Nationality__c != null && countryCodes.containsKey(objCon.cm_Nationality__c)) ? countryCodes.get(objCon.cm_Nationality__c) : '')+'</P_NATIONALITY>';
                                AccountXML += '<P_DOB>'+CM_EmaarUtils.formatORACLEDate(objCon.cm_Birthdate__c)+'</P_DOB>';
                                AccountXML += '<P_COUNTRY_OF_RESIDENCE></P_COUNTRY_OF_RESIDENCE>';
                                AccountXML += '<P_PASSPORT_NUMBER>'+(objCon.cm_Passport_Number__c != null ? objCon.cm_Passport_Number__c : '')+'</P_PASSPORT_NUMBER>';
                                AccountXML += '<P_PASSPORT_EXPIRY>'+CM_EmaarUtils.formatORACLEDate(objCon.cm_Passport_Expiry_Date__c)+'</P_PASSPORT_EXPIRY>';
                                AccountXML += '<P_VISA_NUMBER>'+objCon.Visa_No__c+'</P_VISA_NUMBER>';
                                AccountXML += '<P_VISA_EXPIRY></P_VISA_EXPIRY>';
                                AccountXML += '<P_NATIONAL_ID>'+objCon.cm_National_ID_No__c+'</P_NATIONAL_ID>';
                                AccountXML += '<P_NATIONAL_ID_EXPIRY>'+CM_EmaarUtils.formatORACLEDate(objCon.cm_National_ID_Expiry_Date__c)+'</P_NATIONAL_ID_EXPIRY>';
                                AccountXML += '<P_ADDRESS1>'+(objCon.MailingStreet != null ? CM_EmaarUtils.formtStringValue(objCon.MailingStreet) : '.' )+'</P_ADDRESS1>';
                                AccountXML += '<P_ADDRESS2/>';
                                AccountXML += '<P_POBOX>'+(objCon.cm_P_O_Box__c != null ? objCon.cm_P_O_Box__c : '' )+'</P_POBOX>';
                                AccountXML += '<P_CITY>'+(objCon.MailingCity != null ? CM_EmaarUtils.formtStringValue(objCon.MailingCity) : '.' )+'</P_CITY>';
                                AccountXML += '<P_COUNTRY>'+(objCon.MailingCountry != null && countryCodes.containsKey(objCon.MailingCountry) ? countryCodes.get(objCon.MailingCountry) : 'AE')+'</P_COUNTRY>';
                                AccountXML += '<P_GENDER>'+objCon.cm_Gender__c+'</P_GENDER>';
                                AccountXML += '<P_POSTAL_CODE>'+objCon.MailingPostalCode+'</P_POSTAL_CODE>';
                                AccountXML += '<P_SF_CONTACT_ID>'+objCon.Id+'</P_SF_CONTACT_ID>';
                                
                                phoneCount = 0;
                                emailcount = 0;
                                
                                if(objCon.MobilePhone != null)
                                    phoneCount++;   
                                if(objCon.Email != null)
                                    emailcount++;
                                
                                AccountXML += '<P_PHONE_COUNT>'+phoneCount+'</P_PHONE_COUNT>';
                                AccountXML += '<P_EMAIL_COUNT>'+emailcount+'</P_EMAIL_COUNT>';
                                AccountXML += '</CONTACT_PERSON>';
                                
                                if(phoneCount > 0){
                                    AccountXML += '<CONTACT_PHONE_DETAILS>';
                                    AccountXML += '<PHONE_DETAIL>';
                                        AccountXML += '<P_CONTACT_POINT_TYPE>PHONE</P_CONTACT_POINT_TYPE>';
                                        AccountXML += '<P_PHONE_LINE_TYPE>MOBILE</P_PHONE_LINE_TYPE>';
                                        
                                        mobileArea = objCon.MobilePhone != null ? objCon.MobilePhone.substring(0,2) : '';
                                        mobileNum = objCon.MobilePhone != null ? objCon.MobilePhone.substring(2,objCon.MobilePhone.length()) : '';
                                        integer iCode = objCon.cm_Mobile_Country_Code__c != null ? integer.valueOf(objCon.cm_Mobile_Country_Code__c.split(':')[1].trim()):0;
                                        
                                        AccountXML += '<P_PHONE_COUNTRY_CODE>'+iCode+'</P_PHONE_COUNTRY_CODE>';
                                        AccountXML += '<P_PHONE_AREA_CODE>'+mobileArea+'</P_PHONE_AREA_CODE>';
                                        AccountXML += '<P_PHONE_NUMBER>'+mobileNum+'</P_PHONE_NUMBER>';
                                    AccountXML += '</PHONE_DETAIL>';
                                    AccountXML += '</CONTACT_PHONE_DETAILS>';
                                }
                                if(emailcount > 0){
                                    AccountXML += '<CONTACT_EMAIL_DETAILS>';
                                    AccountXML += '<EMAIL_DETAIL>';
                                        AccountXML += '<P_CONTACT_POINT_TYPE>EMAIL</P_CONTACT_POINT_TYPE>';
                                        AccountXML += '<P_EMAIL_ADDRESS>'+objCon.Email+'</P_EMAIL_ADDRESS>';
                                    AccountXML += '</EMAIL_DETAIL>';
                                    AccountXML += '</CONTACT_EMAIL_DETAILS>';
                                }
                        AccountXML += '</ORG_CONTACT_DETAILS>';
                    }
                                    
                    AccountXML += '</ORG_CONTACT_PERSON>';
                }
                
                AccountXML = AccountXML+'</XX_PARTY_INFO>';
            }
                
            //system.debug('>>>>>>>>>>>>>>>>>>>>>'+AccountXML);
            AccountXML = AccountXML.replaceAll('null','').trim();
            //Adeel Debugging AccountXML
            System.debug('@@AccountXML'+AccountXML);

            /***************************ORDER XML BUILD******************************************/
            string OrderXML = '<XX_ORDER_INFO><XX_ORDER_DETAILS><ORDER>';
            OrderXML = OrderXML+'<LOCATION_ID>'+OppoPro.cm_Property_Inventory__r.location__r.Location_Id__c+'</LOCATION_ID>';
            
            //string strDate = system.today().day()+'-'+system.today().month()+'-'+system.today().year();
            DateTime d = system.now();
            String monthName= d.format('MMM');
            integer Day= d.day();
            integer year= d.year();
            string strdate = Day+'-'+monthName+'-'+year;

            //Adeel, Adding lead conversion date
            string leadConversionDate  ='';
            if(OppoPro.cm_Opportunity__r.Lead_Conversion_Date__c != null){
                DateTime dt = OppoPro.cm_Opportunity__r.Lead_Conversion_Date__c;
                String monthNamet= dt.format('MMM');
                
                String Dayt= string.valueof(d.day());
                if(integer.valueof(dayt) < 10)
                dayt = '0' + dayt;
                
                Integer yeart = dt.year();
                leadConversionDate = Dayt+'-'+monthNamet+'-'+yeart;
            }

            
            OrderXML = OrderXML+'<ORDER_DATE>'+strDate+'</ORDER_DATE>';
            OrderXML = OrderXML+'<PURCHASE_DATE>'+strDate+'</PURCHASE_DATE>';
            OrderXML = OrderXML+'<SELLING_PRICE>'+OppoPro.Campaign_Price__c+'</SELLING_PRICE>';
            OrderXML = OrderXML+'<DISCOUNT></DISCOUNT>';
            OrderXML = OrderXML+'<OPTIONS_AMOUNT>0.00</OPTIONS_AMOUNT>';
            OrderXML = OrderXML+'<NET_AMOUNT>'+OppoPro.Campaign_Price__c+'</NET_AMOUNT>';
            //Adeel - OrderXML = OrderXML+'<ORDER_EVENT>'+strOrderEvent+'</ORDER_EVENT>';//'+OppoPro.cm_Opportunity__r.Order_Event__c+'
            //Adeel - OrderXML = OrderXML+'<ORDER_SOURCE>'+strOrderSource+'</ORDER_SOURCE>'; //+OppoPro.cm_Opportunity__r.Order_Source__c+
            //Adeel Passing Tempo Sales - Hard-coded TODO: Need to update
            OrderXML = OrderXML+'<ORDER_EVENT>Tempo Sales</ORDER_EVENT>';
            OrderXML = OrderXML+'<ORDER_SOURCE>Public</ORDER_SOURCE>'; 

            OrderXML = OrderXML+'<RESOURCE_MAIL>'+UserInfo.getUserEmail()+'</RESOURCE_MAIL>';
            //Adeel - Commenting schedule header
            if(mpInvHeaders.containskey(OppoPro.cm_Property_Inventory__c))
                OrderXML = OrderXML+'<SCHEDULE_HEADER_ID>'+mpInvHeaders.get(OppoPro.cm_Property_Inventory__c)+'</SCHEDULE_HEADER_ID>';
            else
                OrderXML = OrderXML+'<SCHEDULE_HEADER_ID>'+OppoPro.cm_Property_Inventory__r.payment_Header_id__c+'</SCHEDULE_HEADER_ID>';
            OrderXML = OrderXML+'<EXCHANGE_RATE>1.0000</EXCHANGE_RATE>';
            OrderXML = OrderXML+'<EXCHANGE_RATE_TYPE></EXCHANGE_RATE_TYPE>';
            OrderXML = OrderXML+'<UNIT_CURRENCY>'+OppoPro.cm_Property_Inventory__r.CurrencyISOCode+'</UNIT_CURRENCY>';
            OrderXML = OrderXML+'<TRANSACTIONAL_CURRENCY>AED</TRANSACTIONAL_CURRENCY>';
            OrderXML = OrderXML+'<PREFERRED_NET_AMOUNT>'+OppoPro.cm_Property_Inventory__r.Selling_Price__c+'</PREFERRED_NET_AMOUNT>';
            OrderXML = OrderXML+'<TRANSACTIONAL_NET_AMOUNT></TRANSACTIONAL_NET_AMOUNT>';
            OrderXML = OrderXML+'<FUNCTIONAL_CURRENCY>AED</FUNCTIONAL_CURRENCY>';
            OrderXML = OrderXML+'<UNIT_SELLING_PRICE>'+OppoPro.cm_Property_Inventory__r.Selling_Price__c+'</UNIT_SELLING_PRICE>';
            OrderXML = OrderXML+'<UNIT_OPTION_MAP_ID>0</UNIT_OPTION_MAP_ID>';
            
            map<String,Mobile_Configurations__c> mpSettings = Mobile_Configurations__c.getAll();
            string genCampaignId = mpSettings.get('Configuration').Tempo_Campaign_ID__c;
            
            string CampaignId = OppoPro.cm_Opportunity__r.campaignId== null ? genCampaignId:OppoPro.cm_Opportunity__r.campaignId;
            //TODO: Adeel - Harcoding campaignId and Unit Campaign Map Id
            /*
            if(OppoPro.cm_Opportunity__c!=null && OppoPro.cm_Opportunity__r.campaignid==null)
            OrderXML = OrderXML+'<CAMPAIGN_ID>'+CampaignId+'</CAMPAIGN_ID>';
            
            OrderXML = OrderXML+'<UNIT_CAMPAIGN_MAP_ID>0</UNIT_CAMPAIGN_MAP_ID>';
            */
            OrderXML = OrderXML+'<CAMPAIGN_ID>'+oppoPro.Campaign_Id__c+'</CAMPAIGN_ID>';
            OrderXML = OrderXML+'<UNIT_CAMPAIGN_MAP_ID>'+oppoPro.Campaign_Map_Id__c+'</UNIT_CAMPAIGN_MAP_ID>';


            if(OppoPro.cm_Opportunity__r.Is_from_Broker_App__c){
                OrderXML = OrderXML+'<SALES_AGENT_NAME>Broker Direct</SALES_AGENT_NAME>';
                OrderXML = OrderXML+'<SALES_AGENT_ID>'+System.Label.Broker_Resource_Id+'</SALES_AGENT_ID>';
            }
            else{   
                OrderXML = OrderXML+'<SALES_AGENT_NAME>'+resourceName+'</SALES_AGENT_NAME>';
                OrderXML = OrderXML+'<SALES_AGENT_ID>'+resourceID+'</SALES_AGENT_ID>';
            }
            
            /********************** VAT CHNAGES*****************************************************************************/
            system.debug('>>>>>>>>>>>OppoPro.cm_Property_Inventory__r.VAT_Rate__c>>>>>>>>>>'+OppoPro.cm_Property_Inventory__r.VAT_Rate__c);
            system.debug('>>>>>>>>>OppoPro.cm_Property_Inventory__r.VAT_Rate__c>>>>>>>>>>>>'+OppoPro.cm_Property_Inventory__r.VAT_Amount__c);
            if(OppoPro.cm_Property_Inventory__r.VAT_Rate__c!=null){
                OrderXML = OrderXML+'<VAT_PERCENTAGE>'+OppoPro.cm_Property_Inventory__r.VAT_Rate__c+'</VAT_PERCENTAGE>';
            }else{
                OrderXML = OrderXML+'<VAT_PERCENTAGE></VAT_PERCENTAGE>';
            }
            
            if(OppoPro.cm_Property_Inventory__r.VAT_Amount__c!=null){
                OrderXML = OrderXML+'<VAT_AMOUNT>'+OppoPro.cm_Property_Inventory__r.VAT_Amount__c+'</VAT_AMOUNT>';
            }else{
                OrderXML = OrderXML+'<VAT_AMOUNT></VAT_AMOUNT>';
            }
            
            OrderXML = OrderXML+'<SALES_ADMIN_EMAIL></SALES_ADMIN_EMAIL>';
            OrderXML = OrderXML+'<CREATION_SOURCE>SALESFORCE_APP</CREATION_SOURCE>';
            OrderXML = OrderXML+'<MODE_OF_PAYMENT></MODE_OF_PAYMENT>';
            OrderXML = OrderXML+'<USER_NAME>'+UserName+'</USER_NAME>';
            OrderXML = OrderXML+'<OPPORTUNITY>'+stropporid+'</OPPORTUNITY>';
            
            if(OppoPro.cm_Opportunity__r.Is_from_Broker_App__c){
                OrderXML = OrderXML+'<OPPORTUNITY>'+stropporid+'</OPPORTUNITY>';
            }

            /******** Adeel, Adding Lead and Opportunity Information ***********/
            OrderXML = OrderXML+'<LEAD_ID>'+OppoPro.cm_Opportunity__r.Lead_Id__c+'</LEAD_ID>';
            OrderXML = OrderXML+'<LEAD_CONVERTED_BY>'+OppoPro.cm_Opportunity__r.Lead_Converted_By__c+'</LEAD_CONVERTED_BY>';
            OrderXML = OrderXML+'<LEAD_CONVERSION_DATE>'+leadConversionDate+'</LEAD_CONVERSION_DATE>';
            OrderXML = OrderXML+'<LEAD_SOURCE>'+OppoPro.cm_Opportunity__r.LeadSource+'</LEAD_SOURCE>';
            OrderXML = OrderXML+'<LEAD_CHANNEL>'+OppoPro.cm_Opportunity__r.Lead_Channel__c+'</LEAD_CHANNEL>';
            OrderXML = OrderXML+'<OPPORTUNITY_ID>'+OppoPro.cm_Opportunity__r.Id+'</OPPORTUNITY_ID>';
            if(OppoPro.cm_Opportunity__r.Sales_Admin_Approved_by__r != null){
                OrderXML = OrderXML+'<OPPORTUNITY_APPROVED_BY>'+OppoPro.cm_Opportunity__r.Sales_Admin_Approved_by__r.Name+'</OPPORTUNITY_APPROVED_BY>';                
            }else{
                OrderXML = OrderXML+'<OPPORTUNITY_APPROVED_BY></OPPORTUNITY_APPROVED_BY>';                                
            }
            /******** @END: Adeel, Adding Lead and Opportunity Information ***********/

            
            /*************Digital Transaction Details*************************************/
            OrderXML = OrderXML+'<DIGITAL_TRANSACTION_ID>'+OppoPro.cm_Opportunity__r.Digital_ID__c+'</DIGITAL_TRANSACTION_ID>';
            OrderXML = OrderXML+'<UTM_SOURCE>'+OppoPro.cm_Opportunity__r.em_UTM_Source__c+'</UTM_SOURCE>';
            OrderXML = OrderXML+'<UTM_CAMPAIGN>'+OppoPro.cm_Opportunity__r.em_UTM_Campaign__c+'</UTM_CAMPAIGN>';
            OrderXML = OrderXML+'<UTM_MEDIUM>'+OppoPro.cm_Opportunity__r.em_UTM_Medium__c+'</UTM_MEDIUM>';
            /*******************************END*******************************************/
            OrderXML = OrderXML+'</ORDER></XX_ORDER_DETAILS>';
            
            //***************v1.9*********************
            /************************V1.7****************************************/
            string ColorOptionXML = '<XX_COLOROPTION_DETAILS>';
            if(lstBlocation.size() ==0){
                ColorOptionXML = ColorOptionXML+'</XX_COLOROPTION_DETAILS>';
            }else if(lstBlocation.size() > 0){
                for(Building_Color_Option__c objBOC:lstBlocation){
                    ColorOptionXML = ColorOptionXML+'<COLOR_OPTIONS>';
                    //Adeel ColorOptionXML = ColorOptionXML+'<SALES_OPTION_ID>'+objBOC.Sales_Option__r.Sales_Option_ID__c+'</SALES_OPTION_ID>';
                    ColorOptionXML = ColorOptionXML+'</COLOR_OPTIONS>';
                }
                ColorOptionXML = ColorOptionXML+'</XX_COLOROPTION_DETAILS>';
            }
            
            OrderXML = OrderXML+ColorOptionXML;
            /****************************END*************************************/
            OrderXML = OrderXML+'</XX_ORDER_INFO>';
            
            OrderXML = OrderXML.replaceAll('null','').trim();

            System.debug('@@orderXML'+OrderXML);

            /***********************************END****************************************************************/
            string locationID = OppoPro.cm_Property_Inventory__r.Location__r.Location_ID__c;
            locationCode = OppoPro.cm_Property_Inventory__r.Location__r.Location_Code__c;
          // string CampaignId = OppoPro.cm_Opportunity__r.campaign.Eloqua_ID__c== null ? '999999999':OppoPro.cm_Opportunity__r.campaign.Eloqua_ID__c;
            string Campaignname = OppoPro.cm_Opportunity__r.campaign.Name == null ? 'General Inventory':OppoPro.cm_Opportunity__r.campaign.Name;
            decimal OrgId = OppoPro.cm_Property_Inventory__r.Org_ID__c ;
            string UserOracleId = '';//objuser.cm_User_Code__c ; 
            
            emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresponse = new  emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
            objresponse = EmaarWebServiceUtils.executeCreateSalesOrder(AccountXML,OrderXML,locationID,locationCode,CampaignId,Campaignname,UserOracleId,OrgId);
            
            if(objresponse.status != 'ERROR'){
                
                if(objresponse.ErrorMessage != null && !objresponse.ErrorMessage.contains('Sales Order Created')){
                    strMessage = objresponse.ErrorMessage+' - '+locationCode; 
                    string partyNumber = CM_EmaarUtils.getValueFromXMLString(objresponse.resultXML,'PARTY_NUMBER');
                    
                    lstAccounts2Update.add(
                        new Account(
                            Id = (objAccount.Parent_Account__c != null ? objAccount.Parent_Account__c : objAccount.Id),//v1.8 
                            Party_Id__c = objresponse.resultVar3, 
                            em_party_number__c = partyNumber
                        )
                    );
                }else{
                    ISuccessCount = ISuccessCount+1;
                    
                    string parentPartyNo = '';
                    string parentPartyId = '';
                    DOM.Document xmlDOC = new DOM.Document();
                    xmlDOC.load(objresponse.resultXML);
                    DOM.XMLNode rootElement = xmlDOC.getRootElement();
                    map<string,Account> mpAcc = new map<string,Account>();
                    for(Dom.XMLNode child1: rootElement.getChildElements()){
                        for(Dom.XMLNode child2: child1.getChildElements()){
                            //system.debug('>>>>>>>>>>>>>>>>>>'+child2.getName());
                            if(child2.getName()=='PARTY_NUMBER')
                                parentPartyNo = child2.getText();
                            if(child2.getName()=='PARTY_ID')
                                parentPartyId = child2.getText(); 
                            
                            //system.debug('>>>>>>>>>>>>>>>>>>'+child2.getName());
                            if(child2.getName() == 'JOINT_OWNER'){ //v1.5 - added the condition for JOINT Owners 
                                for(Dom.XMLNode child3: child2.getChildElements()){
                                    //system.debug('>>>>>>>>>>>>>>>>>>'+child3.getChildElements());  
                                    //system.debug('>>>>>>>>>>>>>>>>>>'+child3.getName());   
                                    string partyName = '';
                                    string partyId = '';
                                    string partyNo = '';
                                    string partytype = '';
                                    string partyfirst = '';
                                    string partylast = '';
                                    for(Dom.XMLNode child4: child3.getChildElements()){
                                        //system.debug('>>>>>>>>>>>>>>>>>>'+child4.getName());
                                        for(Dom.XMLNode child5: child4.getChildElements()){
                                            //system.debug('>>>>>>>>>>>>>>>>>>'+child5.getName()+'>>>>>>>>>>>>>>>>>>>>>>>>'+child5.getText());  
                                            
                                            if(child5.getName() == 'PARTY_ID')
                                                partyId = child5.getText();
                                            
                                            if(child5.getName() == 'PARTY_NUMBER')
                                                partyNo = child5.getText(); 
                                            
                                            if(child5.getName()=='PARTY_NAME'){
                                                partyName = child5.getText();
                                            }
                                            
                                            if(child5.getName()=='PARTY_TYPE'){
                                                partytype = child5.getText();
                                            }
                                            
                                            if(child5.getName()=='PERSON_FIRST_NAME'){
                                                partyfirst = child5.getText();
                                            }
                                            
                                            if(child5.getName()=='PERSON_LAST_NAME'){
                                                partylast = child5.getText();
                                            }
                                        }
                                    }
                                    string key = '';
                                    if(PartyType=='PERSON')
                                        key = partyfirst+'###'+partylast;
                                    else 
                                        key = partyName;
                                    
                                    //system.debug('>>>>PartyType>>>>>>'+PartyType+'>>>>>partyName>>>>>>>'+partyName+'>>>>>partyfirst>>>>>>'+partyfirst+'>>>>>>>partylast>>>>>>>>>>>'+partylast+'>>>>partyId>>>>>>'+partyId+'>>>>>>partyNo>>>>>>>'+partyNo);    
                                    if(mpJointOwners.containsKey(key))
                                        mpAcc.put(partyId, new Account(Id= mpJointOwners.get(key),Party_Id__c = partyId, em_Party_Number__c = partyNo));
                                }
                            }else if(child2.getName() == 'CONTACT_PERSON_INFO'){
                                for(Dom.XMLNode child3: child2.getChildElements()){ // get the CONTACT_INFO tags
                                    string conId,oraId;
                                    for(Dom.XMLNode child4: child3.getChildElements()){ // get the PARTY_ID, SF_ID tags
                                        if(child4.getName() == 'CONTACT_PARTY_ID'){
                                            oraId = child4.getText();
                                        }
                                        if(child4.getName() == 'SF_CONTACT_ID'){
                                            conId = child4.getText();
                                        }
                                    }
                                    if(conId != null && oraId != null){
                                        mapOrgContacts.put(conId,new Contact(Id=conId,Party_Contact_Id__c=oraId));
                                    }
                                }
                            }
                        }
                        mpAcc.put(parentPartyId,
                            new Account(
                                Id = (objAccount.Parent_Account__c != null ? objAccount.Parent_Account__c : objAccount.Id),//v1.8 
                                Party_Id__c = parentPartyId, 
                                em_party_number__c = parentPartyNo
                            )
                        );
                    }
                    
                    system.debug('>>>>>>>>>>mpAcc>>>>>>>>>>>>'+mpAcc);
                    
                    if(!mpAcc.isEmpty())
                        update mpAcc.values();
                    
                    //v1.5
                    if(!mapOrgContacts.isEmpty())
                        update mapOrgContacts.values();
                    /*
                    if(mapAcc.get(objAccount.Id) == null){
                        string partyNumber = CM_EmaarUtils.getValueFromXMLString(objresponse.resultXML,'PARTY_NUMBER');
                        lstAccounts2Update.add(new Account(Id = objAccount.Id, Party_Id__c = objresponse.resultVar3,  ns_party_number__c = partyNumber));
                        mapAcc.put(objAccount.Id,objresponse.resultVar3);
                    }
                    */
                    OppoPro.cm_Account_Number__c=objresponse.resultVar1;
                    //v1.5
                    SOnPST = EmaarBookingProcess.SalesOrderPaymentType(objresponse.resultVar2);
                    OppoPro.Sales_Order__c = SOnPST[0];//objresponse.resultVar2;
                    oppoPro.cm_Order_status__c = 'Booked';
                    oppoPro.cm_Order_Date__c = System.today();
                    
                    //v1.3
                    oppoPro.Order_Events__c = strOrderEvent ; 
                    oppoPro.Order_Source__c = strOrderSource;
                    
                    /***************VAT CHANGES****************
                    1. Populate VAT RATE / VAT AMOUNT on Opportunity Property
                    ******************END********************/
                    oppoPro.VAT_Amount__c=OppoPro.cm_Property_Inventory__r.VAT_Amount__c;
                    oppoPro.VAT_RATE__c= OppoPro.cm_Property_Inventory__r.VAT_RATE__c;
                    oppoPro.Total_Amount__c= OppoPro.cm_Property_Inventory__r.Total_Amount__c;
                    /******************END*****************************/
                    lstInvs2Update.add(OppoPro);

                }
                
            }
            else{
                strErrors = 'Unit: '+locationCode+'; Error Message: '+objresponse.ErrorMessage;
                if(strMessage == '')
                    strMessage = strErrors;
                else
                    strMessage = strMessage+', '+strErrors;
                
                strErrors = strErrors+'/n units are blocked and please contact admin.';
                
                IFailCount = IFailCount+1;
            }
            
            string orgIdval ='';
            if(OrgId!=null)
                orgIdval = string.valueof(OrgId);
            system.debug('objresponse.ResultXML is : '+objresponse.ResultXML);
            Service_Logs__c objlog = CM_EmaarUtils.CreateLOg('Sales Order Creation',stropporid,OppoPro.id,objresponse.ErrorMessage,objresponse.status, objresponse.ResultXML,OrderXML,AccountXML,locationID,locationCode,CampaignId,Campaignname,UserOracleId,orgIdval,parentlogId);
            objlog.Response__c = (objlog.Response__c != null ) ? objlog.Response__c+objresponse+'' : objresponse+'';
            objlog.Error_Message__c = objlog.Error_Message__c+'-'+ objresponse.resultVar3 +'-'+objresponse.resultVar2;
            lstservlog.add(objlog);
            /************LR BUILDING CHECK*****************/
            //system.debug('********oppoPro.Building__c'+oppoPro.Building__c);
            //system.debug('********MapbuildingLR'+MapbuildingLR);
            if(oppoPro.Building__c!=null && MapbuildingLR!=null && MapbuildingLR.get(oppoPro.Building__c)!=null){
                LRDISCOUNTVal = MapbuildingLR.get(oppoPro.Building__c);
            }
            //system.debug('********LRDISCOUNTVal'+LRDISCOUNTVal); 
            /*****************************/
        }
        
        if(strMessage == '')
            strMessage = 'success';
        
        //system.debug('>>>>>>>>>>'+strMessage);   
        if(!strMessage.contains('Sales Order Created')){
            if(!lstAccounts2Update.isEmpty())
                update lstAccounts2Update;
        }
        if(strMessage == 'success'){
            //system.debug('>>>>>>>>>lstInvs2Update>>>>>>>>>>>>>>'+lstInvs2Update);  
            opportunity objoppor = new opportunity(id=stropporid);
            //Added by Charan to populate the Location Code as Opportunity Name
            if(locationCode != null && locationCode != ''){
                //v1.4
                if(isFromBrokerApp)
                    objoppor.Name = locationCode;
                objoppor.Inventory_Location_code__c = locationCode;
            }
            objoppor.Order_Event__c = strOrderEvent ; 
            objoppor.Order_Source__c = strOrderSource; 
            objoppor.Property_Booked_Date__c = system.now();
            objoppor.cm_Approval_Status__c = 'Payment Processing';
            objoppor.Booking_status__c='Booked in Oracle';
            if(SOnPST[1] != '')
            	objoppor.cm_Default_Payment_Schedule_Type__c = SOnPST[1];
            
            //-------- Update Escrow Account on Opportuntiy
           /* for(Escrow_Account__c escrowAccount : [SELECT Id,Building_Code__c,Account_Type__c,In_Favour_Of__c
                                                                        FROM Escrow_Account__c 
                                                                        WHERE Building_Code__c=:lstOpportunityProperty[0].Building__c]){
                if(escrowAccount.Account_Type__c=='LR'){
                    objoppor.LR_Escrow_Account_Name__c = escrowAccount.In_Favour_Of__c ; 
                }else if(escrowAccount.Account_Type__c=='DL'){
                    objoppor.DP_Escrow_Account_Name__c = escrowAccount.In_Favour_Of__c ;
                }           
            }*/
            map<string,cm_Administrator_Settings__c> mpSettings = cm_Administrator_Settings__c.getAll();
            if(mpSettings.containsKey('ADMIN')){
                cm_Administrator_Settings__c adminSettings = mpSettings.get('ADMIN');
                    objOppor.Payment_Due_Time__c = system.now().addMinutes(integer.valueOf(adminSettings.Payment_Due_Minutes__c));
                    objOppor.Payment_Due_Time_for_Online_Sales__c = System.now().addMinutes(Integer.valueof(Label.EmaarOnlineSalesAdminNotificationMinutes)); 
            }
            //system.debug('********LRDISCOUNTVal'+LRDISCOUNTVal);
            if(LRDISCOUNTVal > 0){
                if(LRDISCOUNTVal == 2){
                    objoppor.LR_waiver__c ='2%';
                }else if(LRDISCOUNTVal == 4){
                    objoppor.LR_waiver__c ='4%';
                }
            }
            if(ISuccessCount == ItotalCount ){
                objoppor.salesOrderCheck__c = true;
            }
            
            //------- To uncheck show limited fields checkbox after booking is done.
            objoppor.cm_Show_Limited_Details__c = false ;
            update objoppor;
            
            //system.debug('>>>>>>>>>lstInvs2Update>>>>>>>>>>>>>>'+lstInvs2Update);  
            if(!lstAccounts2Update.isEmpty())
                update lstAccounts2Update;
            
            /*
            if(!lstOpps2Update.isEmpty())  
            update lstOpps2Update;
            */
            
            //system.debug('>>>>>>>>>lstInvs2Update>>>>>>>>>>>>>>'+lstInvs2Update);  
            if(!lstInvs2Update.isEmpty())
                update lstInvs2Update;   

            //Adeel, Update sales order number in opportunity
            Opportunity op = new Opportunity(Id = stropporid);
            if(Test.isRunningTest())
                op.Sales_Order_No__c = '1122';
            else    
                op.Sales_Order_No__c = lstInvs2Update[0].Sales_Order__c;
            upsert op;

           /**********V1.7*********ColorOption**************************************/
            if(lstBlocation.size() > 0 && lstInvs2Update.size () >0){
                 Sales_Option_Master__c objSM = new Sales_Option_Master__c();
                 objSM.Property_Inventory__c = lstInvs2Update[0].id;
                 //Adeel objSM.Sales_Option__c = lstBlocation[0].SALES_OPTION__c;
                 objSM.Confirmed__c = true;
                 objSM.Sync_To_Oracle__c = true;
                 objSM.Is_Active__c = true;
                 insert objSM;
            }
           /***********************************END******************************/
        }
        insert lstservlog;
		
		CM_EmaarUtils.updateLog(parentlogId,ItotalCount,ISuccessCount,IFailCount);
        
        return strMessage ;
     }

    /************************************************************************************
    Method      :  CreateParty_ExpressionOfInterest
    Params      :  opportunityId
    Description :  Method to create accountXML and calls the service to create party in oracle
    Version     :  1.0
    ************************************************************************************/ 
    public static string CreateParty_ExpressionOfInterest(string stropporid){
        string selbuilding = '';
        string selUnitPosition = '';
        list<Building_Color_Option__c> lstBlocation = new list<Building_Color_Option__c>();
        list<Service_Logs__c> lstservlog = new list<Service_Logs__c>();
        integer ItotalCount = 0;
        integer ISuccessCount = 0;
        integer IFailCount = 0;
        string strMessage = '';
        string strErrors ='';
        string AccountXML ;
        
        map<String,String> countryCodes = new map<String,String>();
        Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
        list<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        //system.debug('Picklist::'+ple);
        for( Schema.PicklistEntry f : ple){
            countryCodes.put(f.getLabel(),f.getValue());
        }
                
        list<Opportunity> lstoppordata = [select id,AccountId,em_UTM_Medium__c,em_UTM_Source__c,Digital_ID__c,em_UTM_Campaign__c,cm_party_type__c,cm_Contact__r.cm_Mobile_Country_Code__c,Referral__c,Referral__r.name,Referral__r.cm_Resource_Id__c,
                                        cm_Contact__r.cm_Mobile_Number__c,cm_Contact__r.MobilePhone,cm_contact__r.Email,cm_contact__r.cm_Nationality__c, cm_Agency_Name__r.name,cm_Agency_Name__r.cm_Resource_Id__c  from Opportunity where id=:stropporid ];
        list<Account> lstAccounts2Update = new list<Account>();
        
        string oppContactMobile = '';
        string oppContactEmail = '';
        string oppContactNationality = ''; 
        string oppContactMobCountryCode = '';
        Account objAccount = new Account();
        
        //v1.5
        string[] SOnPST = new string[]{'',''};
        
        //v1.5
        map<Id,Contact> mapOrgContacts = new map<Id,Contact>();
        
         if(!lstoppordata.isEmpty() && lstoppordata[0].AccountId != null ){ 
                objAccount = [select id,Name,BillingCountryCode,PersonTitle,firstName,lastName,middleName,cm_Nationality__pc,cm_Passport_Number__pc,
                            cm_Passport_Expiry_Date__pc,BillingCity,BillingStreet,Billingcountry,BillingState,billingpostalcode,cm_Gender__pc,phone,cm_P_O_Box__c,
                            Party_Id__c,Salutation,cm_Mobile_Country_Code__pc,cm_Phone_Country_Code__c,isPersonAccount,cm_Birthdate__pc,
                            cm_National_ID_Expiry_Date__pc,cm_Visa_Expiry_Date__pc,cm_Passport_Issue_Date__pc,cm_Place_Of_Birth__pc, cm_National_ID_No__pc, cm_Date_of_Incorporation__c,
                            PersonMobilePhone,PersonEmail,PersonBirthdate,cm_Country_Of_Incorporation__c,Email__c, //ns_Country_of_Residence__pc,
                            cm_Trade_License_Expiry_Date__c,cm_Trade_License_Number__c,Parent_Account__c,Parent_Account__r.Party_Id__c,Emirate__c,VAT_Registration_No__c,
                            //v2.0
                            ShippingStreet,ShippingCity,Shipping_P_O_Box__c,ShippingCountry,Shipping_Mobile_Number__c,Shipping_Mobile_Country_Code__c,Visa_No__pc,Visa_Issue_Date__pc,ShippingState,
                            Corporate_Email__c,Corporate_Phone__c,Corporate_Phone_Country_Code__c, //Adeel ns_Country_of_Residence__c
                                (select Id,FirstName,LastName,Salutation,MiddleName,Name,cm_Nationality__c,cm_Birthdate__c,cm_Passport_Number__c,cm_Passport_Expiry_Date__c,
                                Visa_No__c,cm_Visa_Expiry_Date__c,cm_National_ID_No__c,cm_National_ID_Expiry_Date__c, cm_Gender__c,Party_Contact_Id__c,
                                MailingCity,Mailingstreet,Mailingstate,MailingCountry,Mailingpostalcode,Email,Title,cm_Place_Of_Birth__c,MobilePhone,cm_P_O_Box__c,cm_Mobile_Country_Code__c
                                from Contacts where Is_Deleted__c = false AND Party_Contact_Id__c = null)
                            from Account where Id=:lstoppordata[0].AccountId];
            oppContactMobile =  lstoppordata[0].cm_Contact__r.MobilePhone;
            oppContactEmail = lstoppordata[0].cm_Contact__r.Email;
            oppContactNationality = lstoppordata[0].cm_Contact__r.cm_Nationality__c;
            oppContactMobCountryCode = lstoppordata[0].cm_Contact__r.cm_Mobile_Country_Code__c;
         }
         
         string strAccountRTType = '';
         if(!objAccount.isPersonAccount){
            strAccountRTType = 'ORGANIZATION';
         }
         else{
            strAccountRTType = 'PERSON';
         }
        
         string resourceName = '';
         string resourceId = ''; 
         //modified by Hari to support Referrer
         if(lstoppordata!=null && lstoppordata.size() >0 && lstoppordata[0].cm_Agency_Name__c!=null){
            resourceName =   lstoppordata[0].cm_Agency_Name__c != null ? lstoppordata[0].cm_Agency_Name__r.Name :  '';
            if(resourceName!=''){
                resourceName = resourceName.replaceAll('&','amp;');
            }
            resourceId =   lstoppordata[0].cm_Agency_Name__c != null ? lstoppordata[0].cm_Agency_Name__r.cm_Resource_Id__c : '';
         }
        if(lstoppordata!=null && lstoppordata.size() >0 &&  lstoppordata[0].Referral__c!=null){
            resourceName =   lstoppordata[0].Referral__r != null ? lstoppordata[0].Referral__r.Name :  '';
            if(resourceName!=''){
                resourceName = resourceName.replaceAll('&','amp;');
            }
            resourceId =   lstoppordata[0].Referral__r != null ? lstoppordata[0].Referral__r.cm_Resource_Id__c : '';
        }
        
         
        User userRec = [Select id,cm_Oracle_Username__c, cm_Oracle_User_Id__c from User where Id =: UserInfo.getUserId()];
        string UserName = userRec.cm_Oracle_Username__c;
        
        map<id,string>mapAcc = new map<id,string>(); 
        
        integer LRDISCOUNTVal = 0;

        if(lstoppordata!=null && lstoppordata[0].AccountId!=null ){

            String monthName=''; 
            string Day ;
            integer year;
        
                integer phonecountryCode = objAccount.cm_Phone_Country_Code__c != null ? integer.valueOf(objAccount.cm_Phone_Country_Code__c.split(':')[1].trim()):0;
                string PhoneArea = objAccount.Phone != null ? objAccount.Phone.substring(0,2):'';
                string phoneNum = objAccount.Phone != null ? objAccount.Phone.substring(2,objAccount.Phone.length()):'';
                        
                integer mobilecountryCode =0;
                string mobileArea = '';
                string mobileNum = '';
                string nationality = '';
                string countryOfResidence = '';

                if(objAccount.isPersonAccount){
                    mobileArea = objAccount.PersonMobilephone != null ? objAccount.PersonMobilephone.substring(0,2):'';
                    mobileNum = objAccount.PersonMobilephone != null ? objAccount.PersonMobilephone.substring(2,objAccount.PersonMobilephone.length()):'';
                    nationality = objAccount.cm_Nationality__pc != null ? (countryCodes.containsKey(objAccount.cm_Nationality__pc)?countryCodes.get(objAccount.cm_Nationality__pc):''):'';
                    mobilecountryCode = objAccount.cm_Mobile_Country_Code__pc != null ? integer.valueof(objAccount.cm_Mobile_Country_Code__pc.split(':')[1].trim()):0;
                    countryOfResidence = '';
                }else{
                    //v1.2
                    oppContactMobile = objAccount.Corporate_Phone__c != null ? objAccount.Corporate_Phone__c : oppContactMobile;
                    oppContactMobCountryCode = objAccount.Corporate_Phone_Country_Code__c != null ? objAccount.Corporate_Phone_Country_Code__c : oppContactMobCountryCode; //v1.2
                    
                    
                    mobileArea = oppContactMobile != null ? oppContactMobile.substring(0,2):'';
                    mobileNum = oppContactMobile != null ? oppContactMobile.substring(2,oppContactMobile.length()):'';
                    countryOfResidence = 'UAE'; //Adeel countryCodes.containsKey(objAccount.ns_Country_of_Residence__pc)?countryCodes.get(objAccount.ns_Country_of_Residence__pc):'';
                    nationality = oppContactNationality != null ? (countryCodes.containsKey(oppContactNationality)?countryCodes.get(oppContactNationality):''):'';
                    mobilecountryCode =  oppContactMobCountryCode != null ? integer.valueof(oppContactMobCountryCode.split(':')[1].trim()):0 ;
                }

                string nationalityId = objAccount.cm_National_ID_No__pc != null ? objAccount.cm_National_ID_No__pc:'';
                string placeofBirth = objAccount.cm_Place_Of_Birth__pc != null ? objAccount.cm_Place_Of_Birth__pc:'';
                string passportId = objAccount.cm_Passport_Number__pc != null ? objAccount.cm_Passport_Number__pc:'';
                string gender = objAccount.cm_Gender__pc == null ? '' : objAccount.cm_Gender__pc;
                string middleName = objAccount.MiddleName != null?objAccount.MiddleName:'';
                string strTitle = '';
                if(objAccount.Salutation !=null){
                    if(objAccount.Salutation == 'HE'){
                        strTitle = 'H.E.';
                    }else if (objAccount.Salutation == 'HH'){
                        if(gender == 'Male')
                            strTitle = 'H.H.SHEIKH';
                        else if(gender == 'Female')
                            strTitle = 'H.H.SHEIKHA';
                    }else{
                        strTitle = objAccount.Salutation.toUpperCase();
                    }
                }

                string title = strTitle;
                //string incorpCountry = objAccount.cm_Country_Of_Incorporation__c != null ? objAccount.cm_Country_Of_Incorporation__c : '';
                string incorpCountry = countryCodes.containsKey(objAccount.cm_Country_Of_Incorporation__c) ? countryCodes.get(objAccount.cm_Country_Of_Incorporation__c) : '';
                string tradeLicenseNo = objAccount.cm_Trade_License_Number__c != null ? objAccount.cm_Trade_License_Number__c : '';
                //string partyId = objAccount.Party_Id__c == null ? (mapAcc.get(objAccount.id) == null ? '' : mapAcc.get(objAccount.id)) : objAccount.Party_Id__c;
                //v1.8
                string partyId = objAccount.Parent_Account__r.Party_Id__c != null ? (objAccount.Parent_Account__r.Party_Id__c) : objAccount.Party_Id__c;
                
                
                //string billingState = objAccount.billingState != null ?'-'+objAccount.billingState:'.'; 
                string street = objAccount.BillingStreet != null? CM_EmaarUtils.formtStringValue(objAccount.BillingStreet):'.';
                string city = objAccount.BillingCity != null? CM_EmaarUtils.formtStringValue(objAccount.BillingCity):'.';
                string state = objAccount.BillingState != null? CM_EmaarUtils.formtStringValue(objAccount.BillingState):'.';
                string countryCode = objAccount.BillingCountry != null? countryCodes.get(objAccount.Billingcountry):'AE';
                string country = objAccount.BillingCountry != null? CM_EmaarUtils.formtStringValue(objAccount.BillingCountry):'AE';
                
                string nationalExpiryDate  ='';
                if(objAccount.cm_National_ID_Expiry_Date__pc != null){
                    DateTime d = objAccount.cm_National_ID_Expiry_Date__pc;
                    monthName= d.format('MMM');
                    
                    Day= string.valueof(d.day());
                    if(integer.valueof(day) < 10)
                    day= '0' + day;
                    
                    year= d.year();
                    nationalExpiryDate  = Day+'-'+monthName+'-'+year;
                }
                
                string incorpDate  ='';
                if(objAccount.cm_Date_of_Incorporation__c != null){
                    DateTime d = objAccount.cm_Date_of_Incorporation__c;
                    monthName= d.format('MMM');
                    
                    Day= string.valueof(d.day());
                    if(integer.valueof(day) < 10)
                    day= '0' + day;
                    
                    year= d.year();
                    incorpDate  = Day+'-'+monthName+'-'+year;
                }
                
                string tradeLicenseExpDate='';
                if(objAccount.cm_Trade_License_Expiry_Date__c!=null){
                    DateTime d = objAccount.cm_Trade_License_Expiry_Date__c;
                    monthName= d.format('MMM');
                    
                    Day= string.valueof(d.day());
                    if(integer.valueof(day) < 10)
                    day= '0' + day;
                    
                    year= d.year();
                    tradeLicenseExpDate  = Day+'-'+monthName+'-'+year;
                }
                
                
                string visaExpiryDate  ='';
                if(objAccount.cm_Visa_Expiry_Date__pc != null){
                    DateTime d = objAccount.cm_Visa_Expiry_Date__pc;
                    monthName= d.format('MMM');
                    
                    Day= string.valueof(d.day());
                    if(integer.valueof(day) < 10)
                    day = '0' + day;
                    
                    year = d.year();
                    visaExpiryDate = Day+'-'+monthName+'-'+year;
                }
                
                string passportIssueDate  ='';
                if(objAccount.cm_Passport_Issue_Date__pc != null){
                    DateTime d = objAccount.cm_Passport_Issue_Date__pc;
                    monthName= d.format('MMM');
                    
                    Day= string.valueof(d.day());
                    if(integer.valueof(day) < 10)
                    day= '0' + day;
                    
                    year= d.year();
                    passportIssueDate = Day+'-'+monthName+'-'+year;
                }
                
                string Birthdate  ='';
                if(objAccount.cm_Birthdate__pc!=null){
                    DateTime d = objAccount.cm_Birthdate__pc;
                    monthName= d.format('MMM');
                    
                    Day= string.valueof(d.day());
                    if(integer.valueof(day) < 10)
                    day= '0' + day;
                    
                    year= d.year();
                    Birthdate  = Day+'-'+monthName+'-'+year;
                }
                
                string passportExpiryDate='';
                if(objAccount.cm_Passport_Expiry_Date__pc!=null){
                    DateTime d = objAccount.cm_Passport_Expiry_Date__pc;
                    monthName= d.format('MMM');
                    
                    Day= string.valueof(d.day());
                    if(integer.valueof(day) < 10)
                    day= '0' + day;
                    
                    year= d.year();
                    passportExpiryDate  = Day+'-'+monthName+'-'+year;
                }
                
                integer phoneCount = 0;
                if(objAccount.isPersonAccount && objAccount.PersonmobilePhone != null){
                    if(partyId == null || partyId == '')
                        phoneCount ++;
                }else if(objAccount.isPersonAccount == false && objAccount.Corporate_Phone__c != null){//if(mobileNum != null)
                    phoneCount ++;
                }else if(mobileNum != null)
                    phoneCount ++;
                    
                if(objAccount.Phone != null)
                    phoneCount ++;
                
                
                integer emailCount = 0;
                if(objAccount.PersonEmail != null)
                    emailCount++;
                else if(objAccount.isPersonAccount == false && objAccount.Corporate_Email__c != null ){ ////added by Ravi //v1.2 objAccount.Email__c != null || oppContactEmail != null
                    emailCount++;
                    oppContactEmail = objAccount.Corporate_Email__c;
                }
                if(objAccount.Email__c != null){
                    emailCount++;
                }
                
                AccountXML = '<XX_PARTY_INFO>';
                AccountXML = AccountXML+'<XX_PARTY_DETAILS>';
                AccountXML = AccountXML+'<PARTY>';
                AccountXML = AccountXML+'<P_TITLE>'+title+'</P_TITLE>';//'+objAccount.PersonTitle+'
                AccountXML = AccountXML+'<P_DESIGNATION/>';
                AccountXML = AccountXML+'<P_GLOBAL_PARTY_ID/>';
                AccountXML = AccountXML+'<P_PARTY_ID>'+partyId+'</P_PARTY_ID>';
                AccountXML = AccountXML+'<P_PARTY_TYPE>'+strAccountRTType +'</P_PARTY_TYPE>';
                AccountXML = AccountXML+'<P_FIRST_NAME>'+CM_EmaarUtils.formtStringValue(objAccount.FirstName)+'</P_FIRST_NAME>'; //v1.6
                AccountXML = AccountXML+'<P_MIDDLE_NAME>'+CM_EmaarUtils.formtStringValue(middleName)+'</P_MIDDLE_NAME>';
                AccountXML = AccountXML+'<P_LAST_NAME>'+CM_EmaarUtils.formtStringValue(objAccount.LastName)+'</P_LAST_NAME>';
                AccountXML = AccountXML+'<P_FULL_NAME>'+CM_EmaarUtils.formtStringValue(objAccount.Name)+'</P_FULL_NAME>';                   
                AccountXML = AccountXML+'<P_NATIONALITY>'+nationality+'</P_NATIONALITY>';//'+objAccount.cm_Nationality__pc+'
                AccountXML = AccountXML+'<P_PLACE_OF_BIRTH>'+CM_EmaarUtils.formtStringValue(placeofBirth)+'</P_PLACE_OF_BIRTH>';
                AccountXML = AccountXML+'<P_NATIONAL_ID>'+nationalityId+'</P_NATIONAL_ID>';
                AccountXML = AccountXML+'<P_NATIONAL_ID_EXPIRY>'+nationalExpiryDate+'</P_NATIONAL_ID_EXPIRY>';
                if(objAccount.isPersonAccount){
                    AccountXML = AccountXML+'<P_ID_TYPE>PASSPORT</P_ID_TYPE>';//'+objAccount.cm_Passport_Number__pc+'
                    AccountXML = AccountXML+'<P_ID>'+passportId+'</P_ID>';
                    AccountXML = AccountXML+'<P_ID_EXPIRY_DATE>'+passportExpiryDate+'</P_ID_EXPIRY_DATE>';
                    AccountXML = AccountXML+'<VISA_NUMBER>'+objAccount.Visa_No__pc+'</VISA_NUMBER>';
                    AccountXML = AccountXML+'<VISA_ISSUE>'+CM_EmaarUtils.formatORACLEDate(objAccount.Visa_Issue_Date__pc)+'</VISA_ISSUE>';
                    AccountXML = AccountXML+'<VISA_EXPIRY>'+CM_EmaarUtils.formatORACLEDate(objAccount.cm_Visa_Expiry_Date__pc)+'</VISA_EXPIRY>';
                    
                }else{
                    AccountXML = AccountXML+'<P_ID_TYPE>TRADE_LICENSE</P_ID_TYPE>';//'+objAccount.cm_Passport_Number__pc+'
                    AccountXML = AccountXML+'<P_ID>'+tradeLicenseNo+'</P_ID>';//'+objAccount.cm_Passport_Number__pc+'
                    AccountXML = AccountXML+'<P_ID_EXPIRY_DATE>'+tradeLicenseExpDate+'</P_ID_EXPIRY_DATE>';
                } 
                
                
                //v1.7
                string postalcode = objAccount.Billingpostalcode != null ? CM_EmaarUtils.formtStringValue(objAccount.Billingpostalcode) : '';
                //postalcode =  CM_EmaarUtils.formtStringValue(postalcode);
                string pobox = objAccount.cm_P_O_Box__c != null ? CM_EmaarUtils.formtStringValue(objAccount.cm_P_O_Box__c) : '';
                //pobox =  CM_EmaarUtils.formtStringValue(pobox);
                //End
    
                AccountXML = AccountXML+'<P_ID_ISSUE_DATE>'+passportIssueDate+'</P_ID_ISSUE_DATE>';
                AccountXML = AccountXML+'<P_DOB>'+Birthdate+'</P_DOB>';//'+Birthdate+'
                AccountXML = AccountXML+'<P_AGE_GROUP></P_AGE_GROUP>';
                AccountXML = AccountXML+'<P_AVG_MONTHLY_INCOME></P_AVG_MONTHLY_INCOME>';            
                AccountXML = AccountXML+'<P_ADDRESS1>'+street+'</P_ADDRESS1><P_ADDRESS2/>';
                AccountXML = AccountXML+'<P_POBOX>'+pobox+'</P_POBOX>';//objAccount.cm_P_O_Box__c
                AccountXML = AccountXML+'<P_CITY>'+city+'-'+state+'</P_CITY>';//
                AccountXML = AccountXML+'<P_POSTAL_CODE>'+postalcode+'</P_POSTAL_CODE>';//'+objAccount.Billingpostalcode+'objAccount.Billingpostalcode
                AccountXML = AccountXML+'<P_COUNTRY>'+countrycode+'</P_COUNTRY>';
                AccountXML = AccountXML+'<P_LOCATION_ID></P_LOCATION_ID>';
                //v1.4
                AccountXML += '<P_STATE>'+(objAccount.BillingState != null ? objAccount.BillingState : (objAccount.BillingCountry == 'United States' ? 'NY' : ''))+'</P_STATE>';
                AccountXML = AccountXML+'<SHIPPING_COUNTRY>'+(countryCodes.containsKey(objAccount.ShippingCountry) ? countryCodes.get(objAccount.ShippingCountry) : '')+'</SHIPPING_COUNTRY>';
                AccountXML = AccountXML+'<SHIPPING_STREET>'+CM_EmaarUtils.formtStringValue(objAccount.ShippingStreet)+'</SHIPPING_STREET>';
                AccountXML = AccountXML+'<SHIPPING_CITY>'+CM_EmaarUtils.formtStringValue(objAccount.ShippingCity)+'</SHIPPING_CITY>';
                
                //v1.4
                AccountXML += '<SHIPPING_STATE>'+(objAccount.ShippingState != null ? objAccount.ShippingState : (objAccount.ShippingCountry == 'United States' ? 'NY' : ''))+'</SHIPPING_STATE>';
                
                AccountXML = AccountXML+'<SHIPPING_POSTAL_CODE></SHIPPING_POSTAL_CODE>';
                AccountXML = AccountXML+'<SHIPPING_PO_BOX>'+CM_EmaarUtils.formtStringValue(objAccount.Shipping_P_O_Box__c)+'</SHIPPING_PO_BOX>';
                if(objAccount.Shipping_Mobile_Number__c != null){
                    phoneCount ++;
                }
                //end of v2.0
                
                //v1.6
                if(partyId != null && partyId != ''){
                    //phoneCount = 0;
                    EmailCount = 0;
                }
                
                AccountXML = AccountXML+'<P_PHONE_COUNT>'+phoneCount+'</P_PHONE_COUNT>';
                AccountXML = AccountXML+'<P_EMAIL_COUNT>'+EmailCount+'</P_EMAIL_COUNT>';
                AccountXML = AccountXML+'<P_GENDER>'+objAccount.cm_Gender__pc+'</P_GENDER>';//'+gender+'
                AccountXML = AccountXML+'<P_DATE_OF_INCORPORATION>'+incorpDate+'</P_DATE_OF_INCORPORATION>';
                AccountXML = AccountXML+'<P_COUNTRY_OF_INCORPORATION>'+incorpCountry+'</P_COUNTRY_OF_INCORPORATION>';
                AccountXML = AccountXML+'<P_TRADE_LICENSE_EXPIRY_DATE>'+tradeLicenseExpDate+'</P_TRADE_LICENSE_EXPIRY_DATE>';
                AccountXML = AccountXML+'<P_INCORPORATION_AUTHORITY/>';
                AccountXML = AccountXML+'<P_COUNTRY_OF_RESIDENCE>'+countryOfResidence+'</P_COUNTRY_OF_RESIDENCE>';
            
                //v1.5
                Integer iC = 0;
                if(objAccount.isPersonAccount == false && objAccount.Contacts != null && !objAccount.Contacts.isEmpty()){
                    iC++;
                }
                AccountXML = AccountXML+'<P_CONTACT_PERSON_COUNT>'+iC+'</P_CONTACT_PERSON_COUNT>';
                //end of v1.5
                
                AccountXML = AccountXML+'</PARTY>';
                AccountXML = AccountXML+'<PHONE_DETAILS>';
                
                //v1.6
                if(partyId == null || partyId == '')
                    AccountXML = AccountXML+'<PHONE_DETAIL><P_CONTACT_POINT_TYPE>PHONE</P_CONTACT_POINT_TYPE><P_PHONE_LINE_TYPE>MOBILE</P_PHONE_LINE_TYPE><P_PHONE_COUNTRY_CODE>'+mobilecountryCode+'</P_PHONE_COUNTRY_CODE><P_PHONE_AREA_CODE>'+mobileArea+'</P_PHONE_AREA_CODE><P_PHONE_NUMBER>'+mobileNum+'</P_PHONE_NUMBER></PHONE_DETAIL>';
            
                if(phoneNum != null && phoneNum != '')
                    AccountXML = AccountXML+'<PHONE_DETAIL><P_CONTACT_POINT_TYPE>PHONE</P_CONTACT_POINT_TYPE><P_PHONE_LINE_TYPE>GEN</P_PHONE_LINE_TYPE><P_PHONE_COUNTRY_CODE>'+phonecountryCode+'</P_PHONE_COUNTRY_CODE><P_PHONE_AREA_CODE>'+phoneArea+'</P_PHONE_AREA_CODE><P_PHONE_NUMBER>'+phoneNum+'</P_PHONE_NUMBER></PHONE_DETAIL>';
                
                //v2.0
                if(objAccount.Shipping_Mobile_Number__c != null && objAccount.Shipping_Mobile_Number__c != ''){
                    Integer shipCC = objAccount.Shipping_Mobile_Country_Code__c != null ? integer.valueOf(objAccount.Shipping_Mobile_Country_Code__c.split(':')[1].trim()):0;
                    string shipArea = objAccount.Shipping_Mobile_Number__c != null ? objAccount.Shipping_Mobile_Number__c.substring(0,2):'';
                    string shipNo = objAccount.Shipping_Mobile_Number__c != null ? objAccount.Shipping_Mobile_Number__c.substring(2,objAccount.Shipping_Mobile_Number__c.length()):'';
                    AccountXML = AccountXML+'<PHONE_DETAIL><P_CONTACT_POINT_TYPE>PHONE</P_CONTACT_POINT_TYPE><P_PHONE_LINE_TYPE>GEN</P_PHONE_LINE_TYPE><P_PHONE_COUNTRY_CODE>'+shipCC+'</P_PHONE_COUNTRY_CODE><P_PHONE_AREA_CODE>'+shipArea+'</P_PHONE_AREA_CODE><P_PHONE_NUMBER>'+shipNo+'</P_PHONE_NUMBER></PHONE_DETAIL>';
                }
                //end of v2.0
                
                AccountXML = AccountXML+'</PHONE_DETAILS>';
                
                if(EmailCount>0){
                    if(objAccount.isPersonAccount)
                        AccountXML = AccountXML+'<EMAIL_DETAILS><EMAIL_DETAIL><P_CONTACT_POINT_TYPE>EMAIL</P_CONTACT_POINT_TYPE><P_EMAIL_ADDRESS>'+objAccount.PersonEmail+'</P_EMAIL_ADDRESS></EMAIL_DETAIL></EMAIL_DETAILS>';
                    else
                        AccountXML = AccountXML+'<EMAIL_DETAILS><EMAIL_DETAIL><P_CONTACT_POINT_TYPE>EMAIL</P_CONTACT_POINT_TYPE><P_EMAIL_ADDRESS>'+oppContactEmail+'</P_EMAIL_ADDRESS></EMAIL_DETAIL></EMAIL_DETAILS>';
                        //AccountXML = AccountXML+'<EMAIL_DETAILS><EMAIL_DETAIL><P_CONTACT_POINT_TYPE>EMAIL</P_CONTACT_POINT_TYPE><P_EMAIL_ADDRESS>'+objAccount.Email__c+'</P_EMAIL_ADDRESS></EMAIL_DETAIL></EMAIL_DETAILS>';
                        // commented and added above line AccountXML = AccountXML+'<EMAIL_DETAILS><EMAIL_DETAIL><P_CONTACT_POINT_TYPE>EMAIL</P_CONTACT_POINT_TYPE><P_EMAIL_ADDRESS>'+oppContactEmail+'</P_EMAIL_ADDRESS></EMAIL_DETAIL></EMAIL_DETAILS>';
                }
                    
                /******************************VAT CHANGES************************************************/
                
                if(objAccount.Emirate__c!=null)
                    AccountXML = AccountXML+'<P_VAT_EMIRATE>'+objAccount.Emirate__c+'</P_VAT_EMIRATE>';
                else
                   AccountXML = AccountXML+'<P_VAT_EMIRATE></P_VAT_EMIRATE>';
                   
                if(objAccount.VAT_Registration_No__c!=null)
                    AccountXML = AccountXML+'<P_VAT_REGNUMBER>'+objAccount.VAT_Registration_No__c+'</P_VAT_REGNUMBER>';
                else
                   AccountXML = AccountXML+'<P_VAT_REGNUMBER></P_VAT_REGNUMBER>';
                   
                /******************************VAT CHANGES************************************************/
                
                AccountXML = AccountXML+'</XX_PARTY_DETAILS>';

                AccountXML += '<XX_JOINT_OWNERS/>'; //Assuming there won't be any joint owners

                
                //v1.5
                if(objAccount != null && objAccount.isPersonAccount == false && objAccount.Contacts != null && !objAccount.Contacts.isEmpty()){
                    AccountXML += '<ORG_CONTACT_PERSON>';
                    
                    for(Contact objCon : objAccount.Contacts){
                        AccountXML += '<ORG_CONTACT_DETAILS>';
                        AccountXML += '<CONTACT_PERSON>';
                            title = objCon.Salutation != null ? objCon.Salutation.toUpperCase() : '';
                            
                            if(objCon.Salutation == 'HE'){
                                    title = 'H.E.';
                                }else if (objCon.Salutation == 'HH'){
                                    if(objCon.cm_Gender__c == 'Male')
                                        title = 'H.H.SHEIKH';
                                    else if(objCon.cm_Gender__c == 'Female')
                                        title = 'H.H.SHEIKHA';
                                }
                                                    
                                AccountXML += '<P_TITLE>'+title+'</P_TITLE>';
                                AccountXML += '<P_DESIGNATION/>';
                                AccountXML += '<P_GLOBAL_PARTY_ID/>';
                                AccountXML += '<P_FIRST_NAME>'+CM_EmaarUtils.formtStringValue(objCon.FirstName)+'</P_FIRST_NAME>';
                                AccountXML += '<P_MIDDLE_NAME>'+CM_EmaarUtils.formtStringValue(objCon.MiddleName)+'</P_MIDDLE_NAME>';
                                AccountXML += '<P_LAST_NAME>'+CM_EmaarUtils.formtStringValue(objCon.LastName)+'</P_LAST_NAME>';
                                AccountXML += '<P_FULL_NAME>'+CM_EmaarUtils.formtStringValue(objCon.Name)+'</P_FULL_NAME>';
                                AccountXML += '<P_NATIONALITY>'+((objCon.cm_Nationality__c != null && countryCodes.containsKey(objCon.cm_Nationality__c)) ? countryCodes.get(objCon.cm_Nationality__c) : '')+'</P_NATIONALITY>';
                                AccountXML += '<P_DOB>'+CM_EmaarUtils.formatORACLEDate(objCon.cm_Birthdate__c)+'</P_DOB>';
                                AccountXML += '<P_COUNTRY_OF_RESIDENCE></P_COUNTRY_OF_RESIDENCE>';
                                AccountXML += '<P_PASSPORT_NUMBER>'+(objCon.cm_Passport_Number__c != null ? objCon.cm_Passport_Number__c : '')+'</P_PASSPORT_NUMBER>';
                                AccountXML += '<P_PASSPORT_EXPIRY>'+CM_EmaarUtils.formatORACLEDate(objCon.cm_Passport_Expiry_Date__c)+'</P_PASSPORT_EXPIRY>';
                                AccountXML += '<P_VISA_NUMBER>'+objCon.Visa_No__c+'</P_VISA_NUMBER>';
                                AccountXML += '<P_VISA_EXPIRY></P_VISA_EXPIRY>';
                                AccountXML += '<P_NATIONAL_ID>'+objCon.cm_National_ID_No__c+'</P_NATIONAL_ID>';
                                AccountXML += '<P_NATIONAL_ID_EXPIRY>'+CM_EmaarUtils.formatORACLEDate(objCon.cm_National_ID_Expiry_Date__c)+'</P_NATIONAL_ID_EXPIRY>';
                                AccountXML += '<P_ADDRESS1>'+(objCon.MailingStreet != null ? CM_EmaarUtils.formtStringValue(objCon.MailingStreet) : '.' )+'</P_ADDRESS1>';
                                AccountXML += '<P_ADDRESS2/>';
                                AccountXML += '<P_POBOX>'+(objCon.cm_P_O_Box__c != null ? objCon.cm_P_O_Box__c : '' )+'</P_POBOX>';
                                AccountXML += '<P_CITY>'+(objCon.MailingCity != null ? CM_EmaarUtils.formtStringValue(objCon.MailingCity) : '.' )+'</P_CITY>';
                                AccountXML += '<P_COUNTRY>'+(objCon.MailingCountry != null && countryCodes.containsKey(objCon.MailingCountry) ? countryCodes.get(objCon.MailingCountry) : 'AE')+'</P_COUNTRY>';
                                AccountXML += '<P_GENDER>'+objCon.cm_Gender__c+'</P_GENDER>';
                                AccountXML += '<P_POSTAL_CODE>'+objCon.MailingPostalCode+'</P_POSTAL_CODE>';
                                AccountXML += '<P_SF_CONTACT_ID>'+objCon.Id+'</P_SF_CONTACT_ID>';
                                
                                phoneCount = 0;
                                emailcount = 0;
                                
                                if(objCon.MobilePhone != null)
                                    phoneCount++;   
                                if(objCon.Email != null)
                                    emailcount++;
                                
                                AccountXML += '<P_PHONE_COUNT>'+phoneCount+'</P_PHONE_COUNT>';
                                AccountXML += '<P_EMAIL_COUNT>'+emailcount+'</P_EMAIL_COUNT>';
                                AccountXML += '</CONTACT_PERSON>';
                                
                                if(phoneCount > 0){
                                    AccountXML += '<CONTACT_PHONE_DETAILS>';
                                    AccountXML += '<PHONE_DETAIL>';
                                        AccountXML += '<P_CONTACT_POINT_TYPE>PHONE</P_CONTACT_POINT_TYPE>';
                                        AccountXML += '<P_PHONE_LINE_TYPE>MOBILE</P_PHONE_LINE_TYPE>';
                                        
                                        mobileArea = objCon.MobilePhone != null ? objCon.MobilePhone.substring(0,2) : '';
                                        mobileNum = objCon.MobilePhone != null ? objCon.MobilePhone.substring(2,objCon.MobilePhone.length()) : '';
                                        integer iCode = objCon.cm_Mobile_Country_Code__c != null ? integer.valueOf(objCon.cm_Mobile_Country_Code__c.split(':')[1].trim()):0;
                                        
                                        AccountXML += '<P_PHONE_COUNTRY_CODE>'+iCode+'</P_PHONE_COUNTRY_CODE>';
                                        AccountXML += '<P_PHONE_AREA_CODE>'+mobileArea+'</P_PHONE_AREA_CODE>';
                                        AccountXML += '<P_PHONE_NUMBER>'+mobileNum+'</P_PHONE_NUMBER>';
                                    AccountXML += '</PHONE_DETAIL>';
                                    AccountXML += '</CONTACT_PHONE_DETAILS>';
                                }
                                if(emailcount > 0){
                                    AccountXML += '<CONTACT_EMAIL_DETAILS>';
                                    AccountXML += '<EMAIL_DETAIL>';
                                        AccountXML += '<P_CONTACT_POINT_TYPE>EMAIL</P_CONTACT_POINT_TYPE>';
                                        AccountXML += '<P_EMAIL_ADDRESS>'+objCon.Email+'</P_EMAIL_ADDRESS>';
                                    AccountXML += '</EMAIL_DETAIL>';
                                    AccountXML += '</CONTACT_EMAIL_DETAILS>';
                                }
                        AccountXML += '</ORG_CONTACT_DETAILS>';
                    }
                                    
                    AccountXML += '</ORG_CONTACT_PERSON>';
                }
                
                AccountXML = AccountXML+'</XX_PARTY_INFO>';
            }
            AccountXML = AccountXML.replaceAll('null','').trim();

            decimal OrgId; 
            string UserOracleId = '';//objuser.cm_User_Code__c ; 

            emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresponse = new  emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
            objresponse = EmaarWebServiceUtils.executeCreateExpressionOfInterest(AccountXML,OrgId);
            //If party successfully created
            if(objresponse.status == 'SUCCESS'){
                EmaarWebserviceUtils.isUpdated = true;
                objAccount.Party_Id__c = CM_EmaarUtils.getValueFromXMLString(objresponse.resultXML,'PARTY_ID');
                objAccount.em_party_number__c = CM_EmaarUtils.getValueFromXMLString(objresponse.resultXML,'PARTY_NUMBER');
                update objAccount;
                EmaarWebserviceUtils.isUpdated = false;
                return CM_EmaarUtils.getValueFromXMLString(objresponse.resultXML,'ACCOUNT_NUMBER');
            }
            return objresponse.status;
     }
     
     //v1.5
     public static string[] SalesOrderPaymentType(string resultVar2){
     	string[] sSOPTs = new string[]{'',''};
     	if(resultVar2 != null && resultVar2 != ''){
     		if(resultVar2.contains('-')){
     			sSOPTs[0] = resultVar2.split('-')[0];
     			sSOPTs[1] = resultVar2.split('-')[1];
     			if(sSOPTs[1] != null && sSOPTs[1].trim() == 'STANDARD'){
     				sSOPTs[1] = 'Standard';
     			}
     		}else
     			sSOPTs[0] = resultVar2;
     	}
     	return sSOPTs;
     }
     
}