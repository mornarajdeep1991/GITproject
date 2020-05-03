/*
    Author : Haribabu ,NSI
    Date : March 31st ,2016 
    Description :
    Modification History :
v1.1	Ravi		15/Mar/2018		Capturing the Payment Schedule Type at time of Sales Order Creation from ORACLE    
V1.2    Hari        27/Mar/2018     sending default color options in the order xml to oracle
*/
global class MultipleUnits_CreateSalesOrder{ 
    public static string CreateParty_SalesOrder(string stropporid ,string parentlogId,string strOrderSource,string strOrderEvent,Map<string,String> mpInvHeaders){
     map<string,Building_Color_Option__c> mapColorOptions = new map<string,Building_Color_Option__c>();
     list<Service_Logs__c> lstservlog = new list<Service_Logs__c>();
     integer ItotalCount = 0;
     integer ISuccessCount = 0;
     integer IFailCount = 0;
     string strMessage = '';
     string strErrors ='';
     string AccountXML ;
     string strErrorMsg='';
    Map<String,String> countryCodes = new Map<String,String>();
    Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    System.debug('Picklist::'+ple);
    for( Schema.PicklistEntry f : ple){
        countryCodes.put(f.getLabel(),f.getValue());
    }
            
     //string AccountXML,string OrderXML,string LocationID ,string locationCode,string campainID,string CampaignName,string userOracleCode,string OrgId
     list<Opportunity_Property__c> lstOpportunityProperty = [select id,name,cm_Property_Inventory__r.Location_Code__c,cm_Property_Inventory__r.payment_Header_id__c,cm_Property_Inventory__r.Building_Location__c,cm_Property_Inventory__r.Unit_Position__c,
                                                             cm_Property_Inventory__r.Standard_Cost__c,cm_Opportunity__c,cm_Property_Inventory__r.CurrencyISOCode,cm_Property_Inventory__r.VAT_Amount__c,cm_Property_Inventory__r.VAT_Rate__c,cm_Property_Inventory__r.Total_Amount__c,
                                                             cm_Property_Inventory__r.Selling_Price__c,cm_Opportunity__r.campaign.Type,cm_Opportunity__r.cm_Payment_Mode__c,
                                                             cm_Property_Inventory__r.Location__c,cm_Property_Inventory__r.Location__r.Location_ID__c,cm_Property_Inventory__r.Location__r.Location_Code__c,
                                                             cm_Opportunity__r.campaign.Eloqua_ID__c,cm_Opportunity__r.campaign.Name,cm_Property_Inventory__r.Org_ID__c,Building__c,
                                                             cm_Opportunity__r.em_UTM_Medium__c,cm_Opportunity__r.em_UTM_Source__c,cm_Opportunity__r.Digital_ID__c,cm_Opportunity__r.em_UTM_Campaign__c,
                                                             cm_Opportunity__r.Lead_Channel__c, cm_Opportunity__r.Lead_Conversion_Date__c, cm_Opportunity__r.Lead_Converted_By__c, 
                                                             cm_Opportunity__r.Lead_Created_Date_Time__c, cm_Opportunity__r.Lead_Id__c, cm_Opportunity__r.LeadSource, cm_Opportunity__r.Sales_Admin_Approved_by__r.Name,
                                                             cm_Opportunity__r.Id
                                                             from Opportunity_Property__c where cm_Opportunity__c=:stropporid and Sales_Order__c = null];
     list<Opportunity> lstoppordata = [select id,AccountId,cm_party_type__c,cm_Contact__r.cm_Mobile_Country_Code__c,Referral__c,Referral__r.name,Referral__r.cm_Resource_Id__c,
                                     cm_Contact__r.cm_Mobile_Number__c,cm_contact__r.Email,cm_contact__r.cm_Nationality__c, cm_Agency_Name__r.name,cm_Agency_Name__r.cm_Resource_Id__c  from Opportunity where id=:stropporid ];
    // user objuser = [select id,cm_User_Code__c from user where id=:userinfo.getuserid()];
     
     /************************Custom settings verify for LR wavier Percentage*****************************************/
     map<string,integer> MapbuildingLR = new map<string,integer>();
     /*
     Adeel, discounts settings
     List<LR_Discount_Settings__c> LRCS = LR_Discount_Settings__c.getall().values();
     for(LR_Discount_Settings__c objLRCS:LRCS){
            if(objLRCS.LR_Discount__c!=null && objLRCS.Active__c == true)
                MapbuildingLR.put(objLRCS.Building_Name__c , integer.valueof(objLRCS.LR_Discount__c));
     }
     */
     system.debug('***********MapbuildingLR'+MapbuildingLR);
     /****************************************************************************************************************/
     /*************V1.2******EPESI-191***********COLOR OPTIONS************************************************/
        map<string,string> MapBColorOptions = new map<string,string>();
        set<string>setBlocations = new set<string>();
        for(Opportunity_Property__c objprop:lstOpportunityProperty){
            string selbuilding = '';
            string selUnitPosition= '';
            if(objprop.cm_Property_Inventory__r.Building_Location__c!=null)
                selbuilding = lstOpportunityProperty[0].cm_Property_Inventory__r.Building_Location__c;
            if(objprop.cm_Property_Inventory__r.Unit_Position__c!=null)
                selUnitPosition = lstOpportunityProperty[0].cm_Property_Inventory__r.Unit_Position__c; 
            system.debug('*****selbuilding*******'+selbuilding);
            system.debug('*****selUnitPosition*******'+selUnitPosition);
            string strColorOptionKey = '';
            if(selbuilding != '' && selbuilding != null ){
                setBlocations.add(selbuilding);
                strColorOptionKey = selbuilding+'###';
            } 
            if(selUnitPosition != '' && selUnitPosition != null ){
                strColorOptionKey = strColorOptionKey+selUnitPosition;
            }
            system.debug('*****strColorOptionKey*******'+strColorOptionKey);
            MapBColorOptions.put(objprop.id,strColorOptionKey);
        }
        system.debug('*****MapBColorOptions*******'+MapBColorOptions);
        /*
        Adeel, commenting color options
        for(Building_Color_Option__c bco: [Select id, key__c,Unique_key__c, Default_option__c, SALES_OPTION__c,SALES_OPTION__r.Sales_Option_ID__c, Active__c, Building__c from Building_Color_Option__c where Building__c IN:setBlocations and Active__c = true and Default_option__c = true and key__c IN:MapBColorOptions.keyset()]){
                mapColorOptions.put(bco.key__c,bco);
        }
        */
        system.debug('*****MapBColorOptions*******'+MapBColorOptions);
        /*******V1.2********EPESI-191***********************END*************************************************/
     
     List<Account> lstAccounts2Update = new List<Account>();
     List<Opportunity> lstOpps2Update = new List<Opportunity>();
     List<Opportunity_Property__c> lstInvs2Update = new List<Opportunity_Property__c>(); 
     
     string oppContactMobile = '';
     string oppContactEmail = '';
     string oppContactNationality = '';
     string oppContactMobCountryCode = '';
     Account objAccount = new Account();
     
     //v1.1
     string[] SOnPST = new string[]{'',''};
     
      if(!lstoppordata.isEmpty() && lstoppordata[0].AccountId != null ){ 
         objAccount = [select id,Name,BillingCountryCode,PersonTitle,firstName,lastName,middleName,cm_Nationality__pc,cm_Passport_Number__pc,
                  cm_Passport_Expiry_Date__pc,BillingCity,BillingStreet,Billingcountry,BillingState,billingpostalcode,cm_Gender__pc,phone,cm_P_O_Box__c,
                  Party_Id__c,Salutation,cm_Mobile_Country_Code__pc,cm_Phone_Country_Code__c,isPersonAccount,cm_Birthdate__pc,Emirate__c,VAT_Registration_No__c,
                  cm_National_ID_Expiry_Date__pc,cm_Visa_Expiry_Date__pc,cm_Passport_Issue_Date__pc,cm_Place_Of_Birth__pc, cm_National_ID_No__pc, cm_Date_of_Incorporation__c,
                  PersonMobilePhone,PersonEmail,PersonBirthdate,cm_Country_Of_Incorporation__c,//Adeel-ns_Country_of_Residence__pc,
                  cm_Trade_License_Expiry_Date__c,cm_Trade_License_Number__c from account where id=:lstoppordata[0].AccountId];  
        oppContactMobile =  lstoppordata[0].cm_Contact__r.cm_mobile_number__c;
        oppContactEmail = lstoppordata[0].cm_Contact__r.Email;
        oppContactNationality = lstoppordata[0].cm_Contact__r.cm_Nationality__c;
        oppContactMobCountryCode = lstoppordata[0].cm_Contact__r.cm_Mobile_Country_Code__c;
      }
      
      List<Joint_Owner__c> lstJointOwners = [Select id,cm_joint_owner__r.Salutation, cm_joint_owner__r.Party_Id__c, cm_joint_owner__r.BillingCountryCode,
                  cm_joint_owner__c,cm_joint_owner__r.Name, cm_joint_owner__r.PersonTitle,
                  cm_joint_owner__r.firstName,cm_joint_owner__r.lastName, cm_joint_owner__r.middleName,cm_joint_owner__r.cm_P_O_Box__c,
                  cm_joint_owner__r.cm_Nationality__pc, cm_joint_owner__r.cm_Passport_Number__pc,
                  cm_joint_owner__r.BillingCity,cm_joint_owner__r.cm_National_ID_No__pc,
                  cm_joint_owner__r.BillingStreet,cm_joint_owner__r.Billingcountry,cm_joint_owner__r.cm_National_ID_Expiry_Date__pc,
                  cm_joint_owner__r.cm_Visa_Expiry_Date__pc, cm_joint_owner__r.cm_Passport_Issue_Date__pc,
                  cm_joint_owner__r.cm_Place_Of_Birth__pc, cm_joint_owner__r.BillingState, cm_joint_owner__r.cm_Birthdate__pc, cm_joint_owner__r.cm_Passport_Expiry_Date__pc,
                  cm_joint_owner__r.billingpostalcode, cm_joint_owner__r.cm_Gender__pc,cm_joint_owner__r.phone,
                  cm_joint_owner__r.cm_Mobile_Country_Code__pc, cm_joint_owner__r.PersonEmail,cm_joint_owner__r.isPersonAccount,
                  cm_joint_owner__r.cm_Phone_Country_Code__c, cm_joint_owner__r.PersonMobilephone,cm_joint_owner__r.cm_Country_Of_Incorporation__c,//Adeel - cm_joint_owner__r.ns_Country_of_Residence__pc,
                  cm_joint_owner__r.cm_Trade_License_Expiry_Date__c,cm_joint_owner__r.cm_Trade_License_Number__c,cm_joint_owner__r.cm_Date_of_Incorporation__c,
                  cm_joint_owner__r.PersonBirthdate ,cm_joint_owner__r.Emirate__c, cm_Joint_Owner__r.VAT_Registration_No__c from Joint_Owner__c where cm_Related_Opportunity__c =: stropporid AND cm_Joint_Owner__c <> :objaccount.Id];
      
      ItotalCount = lstOpportunityProperty.size();
      string strAccountRTType = '';
      if(!objAccount.isPersonAccount){
        strAccountRTType = 'ORGANIZATION';
      }
      else{
        strAccountRTType = 'PERSON';
      }
     
      
      string resourceName;
      string resourceId; 
      if(lstoppordata[0].cm_Agency_Name__c!=null){
          resourceName =   lstoppordata[0].cm_Agency_Name__c != null ? lstoppordata[0].cm_Agency_Name__r.Name :  '';
          if(resourceName!=''){
             resourceName = resourceName.replaceAll('&','amp;');
          }
          resourceId =   lstoppordata[0].cm_Agency_Name__c != null ? lstoppordata[0].cm_Agency_Name__r.cm_Resource_Id__c : '';
      }
     if(lstoppordata[0].Referral__c!=null){
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
     set<Id> inventoryIds = new set<Id>();
      Map<string,Account> mpAcc = new Map<string,Account>();
      map<string,string> mpJAcc = new map<string,string>();
     for(Opportunity_Property__c OppoPro:lstOpportunityProperty){

         /***************************************Account XML**********************************/
        if(lstoppordata!=null && lstoppordata[0].AccountId!=null ){
             
            String monthName=''; 
            string Day ;
            integer year;
            
            
            integer phonecountryCode = objAccount.cm_Phone_Country_Code__c != null ? integer.valueOf(objAccount.cm_Phone_Country_Code__c.split(':')[1].trim()):0;
            System.debug('>>>>>>>>>>'+objAccount.PersonMobilephone+'>>>>>>>>>>>'+objAccount.Phone);
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
                mobileArea = oppContactMobile != null ? oppContactMobile.substring(0,2):'';
                mobileNum = oppContactMobile != null ? oppContactMobile.substring(2,oppContactMobile.length()):'';
                //Adeel, countryOfResidence = countryCodes.containsKey(objAccount.ns_Country_of_Residence__pc)?countryCodes.get(objAccount.ns_Country_of_Residence__pc):'';
                nationality = oppContactNationality != null ? (countryCodes.containsKey(oppContactNationality)?countryCodes.get(oppContactNationality):''):'';
                mobilecountryCode = oppContactMobCountryCode != null ? integer.valueof(oppContactMobCountryCode.split(':')[1].trim()):0;
            }
            System.debug(mobileArea+'>>>>>>>>>>'+mobileNum+'>>>>>>>>>>>'+phoneNum+'>>>>>>>>'+PhoneArea);
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
            string incorpCountry = objAccount.cm_Country_Of_Incorporation__c != null ? objAccount.cm_Country_Of_Incorporation__c : '';
            string tradeLicenseNo = objAccount.cm_Trade_License_Number__c != null ? objAccount.cm_Trade_License_Number__c : '';
            string partyId = objAccount.Party_Id__c == null ? (mapAcc.get(objAccount.id) == null ? '' : mapAcc.get(objAccount.id)) : objAccount.Party_Id__c;
            
            
              string billingState = objAccount.billingState != null ?'-'+objAccount.billingState:'.'; 
              string street = objAccount.BillingStreet != null? objAccount.BillingStreet:'.';
              string city = objAccount.BillingCity != null? objAccount.BillingCity:'.';
              string state = objAccount.BillingState != null? objAccount.BillingState:'.';
              string countryCode = objAccount.BillingCountry != null? countryCodes.get(objAccount.Billingcountry):'AE';
              string country = objAccount.BillingCountry != null? objAccount.BillingCountry:'AE';
    
            
            System.debug('>>>>>>>>>>>>>partyId>>>>>>>>>>>>>>>>'+partyId);
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
            if(objAccount.isPersonAccount && objAccount.PersonmobilePhone != null)
                phoneCount ++;
            if(objAccount.Phone != null)
                phoneCount ++;
            
            integer emailCount = 0;
            if(objAccount.PersonEmail != null)
            emailCount++;   
            
            
           
            AccountXML = '<XX_PARTY_INFO>';
            AccountXML = AccountXML+'<XX_PARTY_DETAILS>';
            AccountXML = AccountXML+'<PARTY>';
            AccountXML = AccountXML+'<P_TITLE>'+title+'</P_TITLE>';//'+objAccount.PersonTitle+'
            AccountXML = AccountXML+'<P_DESIGNATION/>';
            AccountXML = AccountXML+'<P_GLOBAL_PARTY_ID/>';
            AccountXML = AccountXML+'<P_PARTY_ID>'+partyId+'</P_PARTY_ID>';
            AccountXML = AccountXML+'<P_PARTY_TYPE>'+strAccountRTType +'</P_PARTY_TYPE>';
            AccountXML = AccountXML+'<P_FIRST_NAME>'+objAccount.FirstName+'</P_FIRST_NAME>';
            AccountXML = AccountXML+'<P_MIDDLE_NAME>'+middleName+'</P_MIDDLE_NAME>';
            AccountXML = AccountXML+'<P_LAST_NAME>'+objAccount.LastName+'</P_LAST_NAME>';
            AccountXML = AccountXML+'<P_FULL_NAME>'+objAccount.Name+'</P_FULL_NAME>';                    
            AccountXML = AccountXML+'<P_NATIONALITY>'+nationality+'</P_NATIONALITY>';//'+objAccount.cm_Nationality__pc+'
            AccountXML = AccountXML+'<P_PLACE_OF_BIRTH>'+placeofBirth+'</P_PLACE_OF_BIRTH>';
            AccountXML = AccountXML+'<P_NATIONAL_ID>'+nationalityId+'</P_NATIONAL_ID>';
            AccountXML = AccountXML+'<P_NATIONAL_ID_EXPIRY>'+nationalExpiryDate+'</P_NATIONAL_ID_EXPIRY>';
            AccountXML = AccountXML+'<P_VISA_EXPIRY_DATE>'+visaExpiryDate+'</P_VISA_EXPIRY_DATE>';
            if(objAccount.isPersonAccount){
                AccountXML = AccountXML+'<P_ID_TYPE>PASSPORT</P_ID_TYPE>';//'+objAccount.cm_Passport_Number__pc+'
                AccountXML = AccountXML+'<P_ID>'+passportId+'</P_ID>';
                AccountXML = AccountXML+'<P_ID_EXPIRY_DATE>'+passportExpiryDate+'</P_ID_EXPIRY_DATE>';//'+expdate+'
            }else{
                AccountXML = AccountXML+'<P_ID_TYPE>TRADE_LICENSE</P_ID_TYPE>';//'+objAccount.cm_Passport_Number__pc+'
                AccountXML = AccountXML+'<P_ID>'+tradeLicenseNo+'</P_ID>';//'+objAccount.cm_Passport_Number__pc+'
                AccountXML = AccountXML+'<P_ID_EXPIRY_DATE>'+tradeLicenseExpDate+'</P_ID_EXPIRY_DATE>';
            } 

            AccountXML = AccountXML+'<P_ID_ISSUE_DATE>'+passportIssueDate+'</P_ID_ISSUE_DATE>';
            AccountXML = AccountXML+'<P_DOB>'+Birthdate+'</P_DOB>';//'+Birthdate+'
            AccountXML = AccountXML+'<P_AGE_GROUP></P_AGE_GROUP>';
            AccountXML = AccountXML+'<P_AVG_MONTHLY_INCOME></P_AVG_MONTHLY_INCOME>';            
            AccountXML = AccountXML+'<P_ADDRESS1>'+street+'</P_ADDRESS1><P_ADDRESS2/>';
            AccountXML = AccountXML+'<P_POBOX>'+objAccount.cm_P_O_Box__c+'</P_POBOX>';//
            AccountXML = AccountXML+'<P_CITY>'+city+'-'+state+'</P_CITY>';//
            AccountXML = AccountXML+'<P_POSTAL_CODE>'+objAccount.Billingpostalcode+'</P_POSTAL_CODE>';//'+objAccount.Billingpostalcode+'
            AccountXML = AccountXML+'<P_COUNTRY>'+countrycode+'</P_COUNTRY>';
            AccountXML = AccountXML+'<P_LOCATION_ID>'+OppoPro.cm_Property_Inventory__r.location__r.Location_Id__c+'</P_LOCATION_ID>';
            AccountXML = AccountXML+'<P_PHONE_COUNT>'+phoneCount+'</P_PHONE_COUNT>';
            AccountXML = AccountXML+'<P_EMAIL_COUNT>'+EmailCount+'</P_EMAIL_COUNT>';
            AccountXML = AccountXML+'<P_GENDER>'+objAccount.cm_Gender__pc+'</P_GENDER>';//'+gender+'
            AccountXML = AccountXML+'<P_DATE_OF_INCORPORATION>'+incorpDate+'</P_DATE_OF_INCORPORATION>';
            AccountXML = AccountXML+'<P_COUNTRY_OF_INCORPORATION>'+incorpCountry+'</P_COUNTRY_OF_INCORPORATION>';
            AccountXML = AccountXML+'<P_TRADE_LICENSE_EXPIRY_DATE>'+tradeLicenseExpDate+'</P_TRADE_LICENSE_EXPIRY_DATE>';
            AccountXML = AccountXML+'<P_INCORPORATION_AUTHORITY/>';
            AccountXML = AccountXML+'<P_COUNTRY_OF_RESIDENCE>'+countryOfResidence+'</P_COUNTRY_OF_RESIDENCE>';
            AccountXML = AccountXML+'</PARTY>';
            AccountXML = AccountXML+'<PHONE_DETAILS>';
            
            AccountXML = AccountXML+'<PHONE_DETAIL><P_CONTACT_POINT_TYPE>PHONE</P_CONTACT_POINT_TYPE><P_PHONE_LINE_TYPE>MOBILE</P_PHONE_LINE_TYPE><P_PHONE_COUNTRY_CODE>'+mobilecountryCode+'</P_PHONE_COUNTRY_CODE><P_PHONE_AREA_CODE>'+mobileArea+'</P_PHONE_AREA_CODE><P_PHONE_NUMBER>'+mobileNum+'</P_PHONE_NUMBER></PHONE_DETAIL>';
        
            if(phoneNum != null && phoneNum != '0')
            AccountXML = AccountXML+'<PHONE_DETAIL><P_CONTACT_POINT_TYPE>PHONE</P_CONTACT_POINT_TYPE><P_PHONE_LINE_TYPE>GEN</P_PHONE_LINE_TYPE><P_PHONE_COUNTRY_CODE>'+phonecountryCode+'</P_PHONE_COUNTRY_CODE><P_PHONE_AREA_CODE>'+phoneArea+'</P_PHONE_AREA_CODE><P_PHONE_NUMBER>'+phoneNum+'</P_PHONE_NUMBER></PHONE_DETAIL>';
            
            AccountXML = AccountXML+'</PHONE_DETAILS>';
            
            if(EmailCount>0){
                if(objAccount.isPersonAccount)
                AccountXML = AccountXML+'<EMAIL_DETAILS><EMAIL_DETAIL><P_CONTACT_POINT_TYPE>EMAIL</P_CONTACT_POINT_TYPE><P_EMAIL_ADDRESS>'+objAccount.PersonEmail+'</P_EMAIL_ADDRESS></EMAIL_DETAIL></EMAIL_DETAILS>';
                else
                AccountXML = AccountXML+'<EMAIL_DETAILS><EMAIL_DETAIL><P_CONTACT_POINT_TYPE>EMAIL</P_CONTACT_POINT_TYPE><P_EMAIL_ADDRESS>'+oppContactEmail+'</P_EMAIL_ADDRESS></EMAIL_DETAIL></EMAIL_DETAILS>';
            }   
            AccountXML = AccountXML+'</XX_PARTY_DETAILS>';
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
            if(lstJointOwners.isEmpty())
                AccountXML = AccountXML+'<XX_JOINT_OWNERS/>';
            else{   
                AccountXML = AccountXML+'<XX_JOINT_OWNERS>';
                for(Joint_Owner__c own:lstJointOwners){
                    
                    if(own.cm_joint_owner__r.isPersonAccount)
                        strAccountRTType = 'PERSON';
                    else
                        strAccountRTType = 'ORGANIZATION';
                    
                    
                    mobilecountryCode = own.cm_joint_owner__r.cm_Mobile_Country_Code__pc != null ? integer.valueof(own.cm_joint_owner__r.cm_Mobile_Country_Code__pc.split(':')[1].trim()):0;
                    phonecountryCode = own.cm_joint_owner__r.cm_Phone_Country_Code__c != null ? integer.valueof(own.cm_joint_owner__r.cm_Phone_Country_Code__c.split(':')[1].trim()):0;
                    
                    System.debug('>>>>>>>>>>'+own.cm_joint_owner__r.PersonMobilephone+'>>>>>>>>>>>'+own.cm_joint_owner__r.Phone);
                    
                    mobileArea = own.cm_joint_owner__r.PersonMobilephone != null ? own.cm_joint_owner__r.PersonMobilephone.substring(0,2):'';
                    PhoneArea = own.cm_joint_owner__r.Phone != null ? own.cm_joint_owner__r.Phone.substring(0,2):'';
                    mobileNum = own.cm_joint_owner__r.PersonMobilephone != null ? own.cm_joint_owner__r.PersonMobilephone.substring(2,own.cm_joint_owner__r.PersonMobilephone.length()):'';
                    phoneNum = own.cm_joint_owner__r.Phone != null ? own.cm_joint_owner__r.Phone.substring(2,own.cm_joint_owner__r.Phone.length()):'';
                    //Adeel, countryOfResidence = countryCodes.containsKey(own.cm_joint_owner__r.ns_Country_of_Residence__pc)?countryCodes.get(own.cm_joint_owner__r.ns_Country_of_Residence__pc):'';
                    incorpCountry = own.cm_joint_owner__r.cm_Country_Of_Incorporation__c != null ? own.cm_joint_owner__r.cm_Country_Of_Incorporation__c : '';
                    tradeLicenseNo = own.cm_joint_owner__r.cm_Trade_License_Number__c != null ? own.cm_joint_owner__r.cm_Trade_License_Number__c : '';     
                    partyId = own.cm_joint_owner__r.party_Id__c == null?'':own.cm_joint_owner__r.party_Id__c;
                    title = own.cm_joint_owner__r.Salutation != null ? own.cm_joint_owner__r.Salutation.toUpperCase():'';
                    passportId = own.cm_joint_owner__r.cm_Passport_Number__pc != null ? own.cm_joint_owner__r.cm_Passport_Number__pc:'';
                    gender = own.cm_joint_owner__r.cm_Gender__pc == null ? '' : own.cm_joint_owner__r.cm_Gender__pc;
                    nationality = own.cm_joint_owner__r.cm_Nationality__pc != null ? (countryCodes.containsKey(own.cm_joint_owner__r.cm_Nationality__pc) ? countryCodes.get(own.cm_joint_owner__r.cm_Nationality__pc):''):'';
                    nationalityId = own.cm_joint_owner__r.cm_Nationality__pc != null ? own.cm_joint_owner__r.cm_National_ID_No__pc:'';
                    placeofBirth = own.cm_joint_owner__r.cm_Place_Of_Birth__pc != null ? own.cm_joint_owner__r.cm_Place_Of_Birth__pc:'';
                    
                    billingState = objAccount.billingState != null ?'-'+objAccount.billingState:'.'; 
          street = objAccount.BillingStreet != null? objAccount.BillingStreet:'.';
          city = objAccount.BillingCity != null? objAccount.BillingCity:'.';
          state = objAccount.BillingState != null? objAccount.BillingState:'.';
          countryCode = objAccount.BillingCountry != null? countryCodes.get(objAccount.Billingcountry):'AE';
          country = objAccount.BillingCountry != null? objAccount.BillingCountry:'AE';
    
                    
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
                            
                    AccountXML = AccountXML+'<XX_JOINT_OWNER>';
                    AccountXML = AccountXML+'<PARTY>';
                    AccountXML = AccountXML+'<P_TITLE>'+title+'</P_TITLE>';//'+objAccount.PersonTitle+'
                    AccountXML = AccountXML+'<P_DESIGNATION/><P_GLOBAL_PARTY_ID/>';
                    AccountXML = AccountXML+'<P_PARTY_ID>'+partyId+'</P_PARTY_ID>';                    
                    AccountXML = AccountXML+'<P_PARTY_TYPE>'+strAccountRTType+'</P_PARTY_TYPE>';
                    AccountXML = AccountXML+'<P_FIRST_NAME>'+own.cm_joint_owner__r.FirstName+'</P_FIRST_NAME>';
                    AccountXML = AccountXML+'<P_MIDDLE_NAME>'+own.cm_joint_owner__r.MiddleName+'</P_MIDDLE_NAME>';
                    AccountXML = AccountXML+'<P_LAST_NAME>'+own.cm_joint_owner__r.LastName+'</P_LAST_NAME>';
                    AccountXML = AccountXML+'<P_FULL_NAME>'+own.cm_joint_owner__r.Name+'</P_FULL_NAME>';
                    AccountXML = AccountXML+'<P_NATIONALITY>'+nationality+'</P_NATIONALITY>';//'+objAccount.cm_Nationality__pc+'
                    AccountXML = AccountXML+'<P_PLACE_OF_BIRTH>'+placeofBirth+'</P_PLACE_OF_BIRTH>';
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
                    AccountXML = AccountXML+'<P_POBOX>'+own.cm_joint_owner__r.cm_P_O_Box__c+'</P_POBOX>';//'+objAccount.Billingpostalcode+'
                    AccountXML = AccountXML+'<P_CITY>'+city+' - '+state+'</P_CITY>';//'+objAccount.BillingCity+'
                    AccountXML = AccountXML+'<P_POSTAL_CODE>'+own.cm_joint_owner__r.Billingpostalcode+'</P_POSTAL_CODE>';//'+objAccount.Billingpostalcode+'
                    
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
                    mpJointOwners.put(key,own.cm_joint_owner__c);
                }
                AccountXML = AccountXML+'</XX_JOINT_OWNERS>';
            }
            AccountXML = AccountXML+'</XX_PARTY_INFO>';
         }
         
         System.debug('>>>>>>>>>>>>>>>>>>>>>'+AccountXML);
         AccountXML = AccountXML.replaceAll('null','').trim();
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
        OrderXML = OrderXML+'<SELLING_PRICE>'+OppoPro.cm_Property_Inventory__r.Selling_Price__c+'</SELLING_PRICE>';
        OrderXML = OrderXML+'<DISCOUNT></DISCOUNT>';
        OrderXML = OrderXML+'<OPTIONS_AMOUNT>0.00</OPTIONS_AMOUNT>';
        OrderXML = OrderXML+'<NET_AMOUNT>'+OppoPro.cm_Property_Inventory__r.Selling_Price__c+'</NET_AMOUNT>';
        OrderXML = OrderXML+'<ORDER_EVENT>'+strOrderEvent+'</ORDER_EVENT>';//'+OppoPro.cm_Opportunity__r.Order_Event__c+'
        OrderXML = OrderXML+'<ORDER_SOURCE>'+strOrderSource+'</ORDER_SOURCE>'; //+OppoPro.cm_Opportunity__r.Order_Source__c+
        OrderXML = OrderXML+'<RESOURCE_MAIL>'+UserInfo.getUserEmail()+'</RESOURCE_MAIL>';
        if(mpInvHeaders.containskey(OppoPro.cm_Property_Inventory__c))
            OrderXML = OrderXML+'<SCHEDULE_HEADER_ID>'+mpInvHeaders.get(OppoPro.cm_Property_Inventory__c)+'</SCHEDULE_HEADER_ID>';
        else
            OrderXML = OrderXML+'<SCHEDULE_HEADER_ID>'+OppoPro.cm_Property_Inventory__r.payment_Header_id__c+'</SCHEDULE_HEADER_ID>';
        OrderXML = OrderXML+'<EXCHANGE_RATE>1.0000</EXCHANGE_RATE>';
        OrderXML = OrderXML+'<EXCHANGE_RATE_TYPE></EXCHANGE_RATE_TYPE>';
        OrderXML = OrderXML+'<VAT_AMOUNT></VAT_AMOUNT>';
        OrderXML = OrderXML+'<VAT_RATE_CODE></VAT_RATE_CODE>';
        OrderXML = OrderXML+'<VAT_RATE></VAT_RATE>';
        OrderXML = OrderXML+'<UNIT_CURRENCY>'+OppoPro.cm_Property_Inventory__r.CurrencyISOCode+'</UNIT_CURRENCY>';
        OrderXML = OrderXML+'<TRANSACTIONAL_CURRENCY>AED</TRANSACTIONAL_CURRENCY>';
        OrderXML = OrderXML+'<PREFERRED_NET_AMOUNT>'+OppoPro.cm_Property_Inventory__r.Selling_Price__c+'</PREFERRED_NET_AMOUNT>';
        OrderXML = OrderXML+'<TRANSACTIONAL_NET_AMOUNT></TRANSACTIONAL_NET_AMOUNT>';
        OrderXML = OrderXML+' <FUNCTIONAL_CURRENCY>AED</FUNCTIONAL_CURRENCY>';
        OrderXML = OrderXML+'<UNIT_SELLING_PRICE>'+OppoPro.cm_Property_Inventory__r.Selling_Price__c+'</UNIT_SELLING_PRICE>';
        OrderXML = OrderXML+'<UNIT_OPTION_MAP_ID>0</UNIT_OPTION_MAP_ID>';
        
        map<String,Mobile_Configurations__c> mpSettings = Mobile_Configurations__c.getAll();
        string genCampaignId = mpSettings.get('Configuration').Tempo_Campaign_ID__c;
        
        string CampaignId = OppoPro.cm_Opportunity__r.campaignId== null ? genCampaignId:OppoPro.cm_Opportunity__r.campaignId;
        if(OppoPro.cm_Opportunity__c!=null && OppoPro.cm_Opportunity__r.campaignid==null)
        OrderXML = OrderXML+'<CAMPAIGN_ID>'+CampaignId+'</CAMPAIGN_ID>';
        
        OrderXML = OrderXML+'<UNIT_CAMPAIGN_MAP_ID>0</UNIT_CAMPAIGN_MAP_ID>';   
        OrderXML = OrderXML+'<SALES_AGENT_NAME>'+resourceName+'</SALES_AGENT_NAME>';
        OrderXML = OrderXML+'<SALES_AGENT_ID>'+resourceID+'</SALES_AGENT_ID>';
        
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
        
        /**************************VAT CHNAGES***************************************************************************/
        
        
        //OrderXML = OrderXML+'<SALES_ADMIN_EMAIL>'+userinfo.getuserEmail()+'</SALES_ADMIN_EMAIL>';
        OrderXML = OrderXML+'<SALES_ADMIN_EMAIL></SALES_ADMIN_EMAIL>';
        OrderXML = OrderXML+'<CREATION_SOURCE>SALESFORCE_APP</CREATION_SOURCE>'; 
        OrderXML = OrderXML+'<MODE_OF_PAYMENT></MODE_OF_PAYMENT>';
        OrderXML = OrderXML+'<USER_NAME>'+UserName+'</USER_NAME>';
        OrderXML = OrderXML+'<OPPORTUNITY>'+stropporid+'</OPPORTUNITY>';
        
        /*************Digital Transaction Details*************************************/
        OrderXML = OrderXML+'<DIGITAL_TRANSACTION_ID>'+OppoPro.cm_Opportunity__r.Digital_ID__c+'</DIGITAL_TRANSACTION_ID>';
        OrderXML = OrderXML+'<UTM_SOURCE>'+OppoPro.cm_Opportunity__r.em_UTM_Source__c+'</UTM_SOURCE>';
        OrderXML = OrderXML+'<UTM_CAMPAIGN>'+OppoPro.cm_Opportunity__r.em_UTM_Campaign__c+'</UTM_CAMPAIGN>';
        OrderXML = OrderXML+'<UTM_MEDIUM>'+OppoPro.cm_Opportunity__r.em_UTM_Medium__c+'</UTM_MEDIUM>';
        /*******************************END*******************************************/

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

        
        OrderXML = OrderXML+'</ORDER></XX_ORDER_DETAILS>';
        
        /************************V1.2****************************************/
        string selbuilding = '';
        string selUnitPosition= '';
        if(OppoPro.cm_Property_Inventory__r.Building_Location__c!=null)
            selbuilding = OppoPro.cm_Property_Inventory__r.Building_Location__c;
        if(OppoPro.cm_Property_Inventory__r.Unit_Position__c!=null)
            selUnitPosition = OppoPro.cm_Property_Inventory__r.Unit_Position__c; 
        system.debug('*****selbuilding*******'+selbuilding);
        system.debug('*****selUnitPosition*******'+selUnitPosition);
        string strColorOptionKey = '';
        if(selbuilding != '' && selbuilding != null ){
            setBlocations.add(selbuilding);
            strColorOptionKey = selbuilding+'###';
        } 
        if(selUnitPosition != '' && selUnitPosition != null ){
            strColorOptionKey = strColorOptionKey+selUnitPosition;
        }
        system.debug('*****strColorOptionKey*******'+strColorOptionKey);
        string ColorOptionXML = '<XX_COLOROPTION_DETAILS></XX_COLOROPTION_DETAILS>';
        /* Adeel, commenting color options 
        if(mapColorOptions!=null && mapColorOptions.get(strColorOptionKey) !=null){
                
                ColorOptionXML = ColorOptionXML+'<COLOR_OPTIONS>';
                ColorOptionXML = ColorOptionXML+'<SALES_OPTION_ID>'+mapColorOptions.get(strColorOptionKey).Sales_Option__r.Sales_Option_ID__c+'</SALES_OPTION_ID>';
                ColorOptionXML = ColorOptionXML+'</COLOR_OPTIONS>';
                ColorOptionXML = ColorOptionXML+'</XX_COLOROPTION_DETAILS>';
            
        }else{
                ColorOptionXML = ColorOptionXML+'</XX_COLOROPTION_DETAILS>';
        }
        */

        OrderXML = OrderXML+ColorOptionXML;
        /****************************END*************************************/
        OrderXML = OrderXML+'</XX_ORDER_INFO>';
        
        

        System.debug('>>>>>>>>>orderXML>>>>>>>>'+orderXML);
         orderXML = orderXML.replaceAll('null','').trim();
        /***********************************END****************************************************************/
        string locationID = OppoPro.cm_Property_Inventory__r.Location__r.Location_ID__c;
        string locationCode = OppoPro.cm_Property_Inventory__r.Location__r.Location_Code__c;
       // string CampaignId = OppoPro.cm_Opportunity__r.campaign.Eloqua_ID__c== null ? '999999999':OppoPro.cm_Opportunity__r.campaign.Eloqua_ID__c;
        string Campaignname = OppoPro.cm_Opportunity__r.campaign.Name == null ? 'General Inventory':OppoPro.cm_Opportunity__r.campaign.Name;
        decimal OrgId = OppoPro.cm_Property_Inventory__r.Org_ID__c ;
        string UserOracleId = '';//objuser.cm_User_Code__c ; 
        
        emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresponse = new  emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
         if(!test.isRunningTest())
         	objresponse = EmaarWebServiceUtils.executeCreateSalesOrder(AccountXML,OrderXML,locationID,locationCode,CampaignId,Campaignname,UserOracleId,OrgId);
         else{
             objresponse.status = 'Success';
             objresponse.ErrorMessage = 'Sales Order Created';
             objresponse.ResultXML = '<?xml version="1.0" encoding="UTF-8"?>'+
             +'<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
             +'<env:Header />'+
             +'<env:Body><env:PARTY_NUMBER><env:PARTY_NUMBER1><env:PARTY_NUMBER2><env:PARTY_NUMBER3></env:PARTY_NUMBER3></env:PARTY_NUMBER2></env:PARTY_NUMBER1></env:PARTY_NUMBER><env:PARTY_ID></env:PARTY_ID>'+
             +'</env:Body>'+
        	 +'</env:Envelope>';
         }
             
        system.debug('****status'+objresponse.status);
        system.debug('****ErrorMessage'+objresponse.ErrorMessage);
        system.debug('****ErrorMessage'+objresponse.resultVar1);
        system.debug('****ErrorMessage'+objresponse.resultVar2);
        system.debug('****ResultXML'+objresponse.ResultXML);
        
        
        
        if(objresponse.status != 'ERROR'){
            if(!objresponse.ErrorMessage.contains('Sales Order Created')){
               // strMessage = objresponse.ErrorMessage+' - '+locationCode; 
                string partyNumber = CM_EmaarUtils.getValueFromXMLString(objresponse.resultXML,'PARTY_NUMBER');
                lstAccounts2Update.add(new Account(Id = objAccount.Id, Party_Id__c = objresponse.resultVar3, em_party_number__c  = partyNumber));
                mapAcc.put(objAccount.Id,objresponse.resultVar3);
                oppoPro.cm_Order_status__c = objresponse.ErrorMessage;
                lstInvs2Update.add(OppoPro);
                IFailCount = IFailCount+1;
            }
            else{
                ISuccessCount = ISuccessCount+1;
                mapAcc.put(objAccount.Id,objresponse.resultVar3);
                DOM.Document xmlDOC = new DOM.Document();
                xmlDOC.load(objresponse.resultXML);
                DOM.XMLNode rootElement = xmlDOC.getRootElement();
                
                for(Dom.XMLNode child1: rootElement.getChildElements()){
                    System.debug('>>>>>>>>>>>>>>>>>>'+child1.getName());
                    string parentPartyNo = '';
                    string parentPartyId = '';
                    for(Dom.XMLNode child2: child1.getChildElements()){
                        System.debug('>>>>>>>>>>>>>>>>>>'+child2.getName());
                        if(child2.getName()=='PARTY_NUMBER')
                          parentPartyNo = child2.getText();
                      if(child2.getName()=='PARTY_ID')
                          parentPartyId = child2.getText();
                        for(Dom.XMLNode child3: child2.getChildElements()){
                          System.debug('>>>>>>>child3>>>>>>>>>>>'+child3.getChildElements());     
                          System.debug('>>>>>>>child3>>>>>>>>>>>'+child3.getName());  
                          string partyName = '';
                          string partyId = '';
                          string partyNo = '';
                          string partytype = '';
                          string partyfirst = '';
                          string partylast = '';
                          for(Dom.XMLNode child4: child3.getChildElements()){
                              System.debug('>>>>>>>>child4>>>>>>>>>>'+child4.getName());
                              for(Dom.XMLNode child5: child4.getChildElements()){
                                  System.debug('>>>>>>>>child5>>>>>>>>>>'+child5.getName()+'>>>>>>>>>>>>>>>>>>>>>>>>'+child5.getText());  
                                  
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
                          
                          system.debug('**********KEY'+KEY);
                          system.debug('**********mpJointOwners.containsKey(key)'+mpJointOwners);
                          System.debug('>>>>PartyType>>>>>>'+PartyType+'>>>>>partyName>>>>>>>'+partyName+'>>>>>partyfirst>>>>>>'+partyfirst+'>>>>>>>partylast>>>>>>>>>>>'+partylast+'>>>>partyId>>>>>>'+partyId+'>>>>>>partyNo>>>>>>>'+partyNo);    
                          if(mpJointOwners.containsKey(key)){
                            // mpAcc.put(partyId, new Account(Id= mpJointOwners.get(key),Party_Id__c = partyId, ns_Party_Number__c = partyNo));
                             //setAccounts.add( new Account(Id= mpJointOwners.get(key),Party_Id__c = partyId, ns_Party_Number__c = partyNo));
                             mpJAcc.put(mpJointOwners.get(key),partyId+'-'+partyNo);
                          }
                        }
                    }
                    System.debug('>>>>>>>>>>'+parentPartyId+'>>>>>>>>>>>>>>>>'+parentPartyId+'>>>>>>>>>>>>>>>'+parentPartyNo);
                    mpAcc.put(parentPartyId,new Account(Id = objAccount.Id, Party_Id__c = parentPartyId, em_party_number__c  = parentPartyNo));
                    //setAccounts.add(new Account(Id = objAccount.Id, Party_Id__c = parentPartyId, ns_party_number__c = parentPartyNo));
                   
                }
                
                strErrorMsg = strErrorMsg + '\nLocation Code: ' + locationCode + '\nMessage: Booked successfully.\n';
                OppoPro.cm_Account_Number__c=objresponse.resultVar1;
                //v1.1
                SOnPST = EmaarBookingProcess.SalesOrderPaymentType(objresponse.resultVar2);
                OppoPro.Sales_Order__c = SOnPST[0];//objresponse.resultVar2;
                OppoPro.MultiBooking__c = true;
                oppoPro.cm_Order_status__c = 'Booked';
                oppoPro.cm_Order_Date__c = System.today();
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
            strErrorMsg = strErrorMsg+'\nLocation Code: '+locationCode+'\nError Message: '+objresponse.ErrorMessage+'.\n';
          //  OppoPro.cm_Account_Number__c=objresponse.resultVar1;
          // OppoPro.Sales_Order__c = objresponse.resultVar2;
            oppoPro.cm_Order_status__c = objresponse.ErrorMessage;
          //  oppoPro.cm_Order_Date__c = System.today();
          if(!objresponse.ErrorMessage.tolowercase().contains('does not exist'))
          inventoryIds.add(OppoPro.cm_Property_Inventory__c);
          
            
            lstInvs2Update.add(OppoPro);
            IFailCount = IFailCount+1;
        }
        
        string orgIdval ='';
        if(OrgId!=null)
            orgIdval = string.valueof(OrgId);
        
        Service_Logs__c objlog = CM_EmaarUtils.CreateLOg('Sales Order Creation',stropporid,OppoPro.id,objresponse.ErrorMessage,objresponse.status, objresponse.ResultXML,OrderXML,AccountXML,locationID,locationCode,CampaignId,Campaignname,UserOracleId,orgIdval,parentlogId);
        objlog.Error_Message__c = objlog.Error_Message__c+'-'+ objresponse.resultVar3 +'-'+objresponse.resultVar2;
        lstservlog.add(objlog);
        
        /************LR BUILDING CHECK*****************/
        system.debug('********oppoPro.Building__c'+oppoPro.Building__c);
        system.debug('********MapbuildingLR'+MapbuildingLR);
        if(oppoPro.Building__c!=null && MapbuildingLR!=null && MapbuildingLR.get(oppoPro.Building__c)!=null){
            LRDISCOUNTVal = MapbuildingLR.get(oppoPro.Building__c);
        }
        system.debug('********LRDISCOUNTVal'+LRDISCOUNTVal);
        /*****************************/
        
        system.debug('*******ItotalCount'+ItotalCount);
        system.debug('*******IFailCount'+IFailCount);
        system.debug('*******ISuccessCount'+ISuccessCount);
        if(ItotalCount == IFailCount){
            strMessage = 'Fail-'+strErrorMsg;    
        }else if(ISuccessCount > 0){
            strMessage = 'success-'+strErrorMsg;
        }
     }
     
     System.debug('>>>>>>>>inventoryIds>>>>>>>>>>>>'+inventoryIds);
     //Commented by Charan as discussed with Anas and Nitesh on 29th March
     //if(!inventoryIds.isEmpty())
     //  CM_EmaarUtils.blockProperties(inventoryIds);
            
     if(strMessage.contains('success')){
         System.debug('>>>>>>>>>>mpAcc>>>>>>>>>>>>'+mpAcc);
        if(!mpAcc.isEmpty()){ 
         //   list<Account> lstAc = new list<Account>();
          //  lstAc.addAll(setAccounts);
            //update lstAc;
            update mpAcc.values();
        }     
        if(!mpJAcc.isEmpty()){
            list<Account>lstJAccount = new list<Account>();
            for(string strAccId:mpJAcc.keyset()){
                Account objJAccount = new Account(id=strAccId);
                string Partydata = mpJAcc.get(strAccId);
                list<string> partydetails = Partydata.split('-');
                if(partydetails.size() >0 && partydetails[0]!=null)
                    objJAccount.party_Id__c = partydetails[0];
                if(partydetails.size() >0 && partydetails[1]!=null)
                    objJAccount.em_party_number__c  = partydetails[1];
                lstJAccount.add(objJAccount);
            }
            if(lstJAccount.size() >0){
                update lstJAccount;
            }
        }
               
         SYstem.debug('>>>>>>>>>lstInvs2Update>>>>>>>>>>>>>>'+lstInvs2Update);  
         opportunity objoppor = new opportunity(id=stropporid);
         objoppor.Order_Event__c = strOrderEvent ; 
         objoppor.Order_Source__c = strOrderSource; 
         objoppor.Property_Booked_Date__c = system.now();
         objoppor.cm_Approval_Status__c = 'Payment Processing';
         
         objoppor.Booking_status__c='Booked in Oracle';
         //v1.1
         if(SOnPST[1] != '')
        	objoppor.cm_Default_Payment_Schedule_Type__c = SOnPST[1];
         
         system.debug('********LRDISCOUNTVal'+LRDISCOUNTVal);
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
         
         
            
         SYstem.debug('>>>>>>>>>lstInvs2Update>>>>>>>>>>>>>>'+lstInvs2Update);  
         if(!lstAccounts2Update.isEmpty())
            update lstAccounts2Update;
         
         SYstem.debug('>>>>>>>>>lstInvs2Update>>>>>>>>>>>>>>'+lstInvs2Update);  
         if(!lstInvs2Update.isEmpty()){
            update lstInvs2Update;   
            //Adeel - Commenting color options
            //EmaarColorOptions.createColorOptions(lstInvs2Update,mapColorOptions);
         }
         
         insert lstservlog;
         CM_EmaarUtils.updateLog(parentlogId,ItotalCount,ISuccessCount,IFailCount);
     }
     system.debug('********123*****strMessage'+strMessage);
     return strMessage ;
    }
}