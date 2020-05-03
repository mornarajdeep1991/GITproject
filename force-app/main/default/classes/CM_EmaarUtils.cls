/*
    Author : Haribabu ,NSI
    Date : March 31st ,2016 
    Description :
    Modification History :
==========================================================================
V.No    Date            By                  Description    
====================================================================================================================================================
1.1     29/03/2017      Ravi                Added the logic to support Referral Special Approvals
1.2    17/05/2017    Ravi        Added the logic to prepare the payment link for Opps created by Broker App
1.3     18/05/2017      Sandeep             Generating New salesforce for new inventory
v1.4  25/05/2017    Ravi        Added the logic to prevent the name change of Opps other than Broker App Opps
v1.5  15/Oct/2017    Ravi        Added the logic to change the Order XML to send the ORAGANIZATION Information and Contact Information
v1.6  18/Oct/2017    Ravi        Changed the logic to send the Primary Contact details separatly instead of sending in ORDER Creation
                      If party is already created then do not send the Email&Phone if it's new send
v1.7  30/Oct/2017     Umair        repalce special characters from Address fields. 
v1.8  08/Jan/2018     Sandeep      Is_Released__c on unit level Ticket -EPESI-68 and Sales admin Team assignment.
v1.9    28/Jan/2018      Ravi           modified the logic to pass the correct date value to ORACLE
v2.0 21/Mar/2018    Ajaz        Modified createPaymentRecord method by adding a new parameter paymentPurpose and assign it to payment record.
v2.1    11/APR/2018     Ravi        Added the condition to assign the Online Sales Opportunity to Integration User instead of assigning to OnlineSales Admin or to Sales Admin as per Nitesh
25/07/2018 - Adeel - Added global methods for lightning components filters, field describe, etc
==========================================================================
*/
global class CM_EmaarUtils{
    
    public static string formatDate(DateTime d){
        String monthName= d.format('MMM');
        integer Day= d.day();
        integer year= d.year();
        //v1.9 string strdate = Day+'-'+monthName+'-'+year;
        string strdate = (Day < 10 ? '0'+Day : ''+Day)+'-'+monthName+'-'+year;
        return strDate; 
    }
  /*
        Method Name : getValueFromXMLString
        Description : This is used to get XML node from the XML string 
   */
    public static string getValueFromXMLString(string xmlString, string keyField){
        string valueFound = '';
        system.debug('xmlString is : '+xmlString);
        system.debug('keyField is : '+keyField);
        if(xmlString.contains('<' + keyField + '>')){
            try{
                valueFound = xmlString.substring(xmlString.indexOf('<' + keyField + '>')+keyField.length() + 2,xmlString.indexOf('</' + keyField + '>'));   
            }catch (exception e){
                system.debug('Error in getValueFromXMLString. Details: ' + e.getMessage() + ' keyfield: ' + keyfield);
            }            
        }
        return valueFound;
    }
    
     /*
        Method Name : prepareImageURL
        Description : Used to get the Logo to display on the pages
    */
    public static string prepareImageURL(){
        string imageURL='/servlet/servlet.ImageServer?id=';
        Organization org = [Select Name From Organization];
        string docName='';
        if(org.Name.contains('Emaar'))
            docName = 'EMAAR_Logo';
        else
            docName = 'Nshama_Logo';
        List<Document> lstDocument =[select Id,name from document where DeveloperName =:docName];
        if(lstDocument.size()>0)
        {
          imageURL=imageURL+lstDocument[0].id+'&oid='+userinfo.getOrganizationId();
            system.debug('imageURL is'+imageURL);
        }
        return imageURL;
    }
    
    /*
        Method Name : CreateLOg
        Description : This method is used to create the service log
   */
    public static Service_Logs__c CreateLOg(string ProcessName,String OppID,String OpporProperty,String ErrorMessage,String status,String responseXML,String OrderXML,String AccountXML,String locationID,string locationCode,string CampaignId ,string Campaignname,string UserOracleId,string OrgId,string parentID){
        Service_Logs__c serlog = new Service_Logs__c();
        serlog.Process_Name__c = ProcessName;
        serlog.Process_Time__c = system.now();
        serlog.Log_Type__c  = status;
        if(OppID != '')
        serlog.Opportunity__c = OppID;
        if(parentID!='')
        serlog.Parent_log__c = parentID;
        serlog.AccountXML__c = AccountXML;
        serlog.OrderXML__c = OrderXML;
        serlog.Response__c = responseXML;
        serlog.Error_Message__c = ErrorMessage;
        if(locationID != '')
        serlog.locationID__c = locationID;
        serlog.locationCode__c = locationCode;
        if(CampaignId != '')
        serlog.CampaignId__c = CampaignId ;
        serlog.Campaignname__c = Campaignname;
        serlog.UserOracleId__c = UserOracleId;
        if(OrgId!=null)
        serlog.OrgId__c = string.valueof(OrgId);
        if(OpporProperty != '' && OpporProperty.contains('PROINV-')){
            list<string> lst = OpporProperty.split('-');
            if(lst.size() > 1 && lst[1]!=null)
            serlog.Property_Inventory__c = lst[1]; 
        }else if(OpporProperty != '' && (!OpporProperty.contains('PROINV'))){
            serlog.Opportunity_Property__c = OpporProperty; 
        }
        return serlog;
    }
    
        /*
    Method Name : formtStringValue
     Description : Replace special characters
    */
    
     public static string formtStringValue(string str){
        //return str != null ? str : 'NULL';
         return str != null ? str.replaceAll('“','quot;').replaceAll('”','quot;').replaceAll('‘','apos').replaceAll('’','apos').replaceAll('&','amp;').replaceAll('"','quot;').replaceAll('>','gt;').replaceAll('<','lt;').replaceAll('\'','apos').replaceAll('[^a-zA-Z0-9 ,.!;@$()-_]','') : '';
      }
    
    public static string formatORACLEDate(Date dt){
    if(dt != null){
      DateTime d = dt;
      return (d.day() < 10 ? ('0'+d.day()) : d.day()+'' )+'-'+d.format('MMM')+'-'+d.year();    
    }else
      return '';
  }
  
  /* Adeel - Method that are used in opportunity approval */
  public static Campaign GetCampaignAttributes(string CampaignId){
      Campaign objCampaign = new Campaign();
      if(CampaignId!=null && CampaignId!=''){
         list<Campaign> lstCampaign = [select id,name,type,cm_Event_Payment_Method__c,Cm_Event_Type__c,cm_No_of_properties_customers_can_buy__c,
                                      No_Of_Receipts__c,cm_Payment_Schedule_Type__c,cm_Picking_SMS_enabled__c,
                                      cm_Registration_SMS_enabled__c,cm_Vendor_Name__c from Campaign where id=:CampaignId];
         if(lstCampaign!=null && lstCampaign.size() >0){
           objCampaign = lstCampaign[0];
         }
      }
      return objCampaign;
    }

    /*
        Method Name : CheckInterimApprovals
        Description : Interim Approvals check
    */  

    webservice static string CheckInterimApprovals(string strOportunityId){
        string strstatus = '';
        list<opportunity> lstOppor = [select id,Name,cm_No_Of_Mandatory_Approvals_Required__c,cm_Decision_Pending__c,cm_Approved_Requests__c from opportunity where id=:strOportunityId];
        if(lstOppor!=null && lstOppor.size() >0 && lstOppor[0].cm_No_Of_Mandatory_Approvals_Required__c >0 && lstOppor[0].cm_Decision_Pending__c ==0){
            strstatus = 'success';
        }else if(lstOppor!=null && lstOppor.size() >0 && lstOppor[0].cm_No_Of_Mandatory_Approvals_Required__c==0 && lstOppor[0].cm_Decision_Pending__c ==0){
            strstatus = 'success';
        }else{
            strstatus = 'Pending';
        }
            return strstatus;
    }

    /*
        Method Name : ValidateOpportunityfields
        Description : This method is used to validate the Person Account fields
    */
    webservice static string ValidateOpportunityfields(string AccountId){
     string strMessage = '';
     list<Account> lstAccount = [select cm_P_O_Box__c,id,Name,BillingPostalCode,cm_Birthdate__pc,cm_Resident_Of_UAE__pc,BillingSTreet,BillingCity,BillingState,billingCountry,cm_Passport_Number__pc,cm_National_ID_No__pc from Account where Id=:AccountId];
     if(lstAccount!=null && lstAccount.size() >0){
         Date DTVal =  system.today().addYears(-21);
         //system.debug('>>>>>>>>>>>>>>>>>>>>'+lstAccount[0]);
         if(lstAccount[0].cm_Birthdate__pc ==null){
             strMessage = 'Please fill all the required fields : Person Birthdate';
         }
         else if(lstAccount[0].cm_Birthdate__pc !=null && lstAccount[0].cm_Birthdate__pc >= System.today()){
            strMessage = 'Please provide a valid Date of Birth.';
         }else if(lstAccount[0].cm_Birthdate__pc !=null && lstAccount[0].cm_Birthdate__pc > DTVal ){
              strMessage = 'Age must be greater than 21 years.';
         }   
         else  if(lstAccount[0].cm_Passport_Number__pc==null){
             strMessage = 'Please fill all the required fields : Passport';
         }
         else if(lstAccount[0].cm_Resident_Of_UAE__pc ==false && ((lstAccount[0].BillingPostalCode == null && lstAccount[0].cm_P_O_Box__c == null) || lstAccount[0].BillingSTreet == null || lstAccount[0].BillingCity == null || lstAccount[0].billingCountry == null)){
             strMessage = 'Please fill all the required fields : Residence of UAE / Person Mailing Address';
         }
         else if(lstAccount[0].cm_Resident_Of_UAE__pc == true &&  lstAccount[0].cm_National_ID_No__pc == null){
             strMessage = 'Please fill all the required fields : Resident of UAE / National ID';
         }
         else{
             strMessage = 'success';
         }
     }
     return strMessage;
    }

    /*
        Method Name : ValidateBusinessAccountFields
        Description : This method is used to validate the Business Account fields
    */
    webservice static string ValidateBusinessAccountFields(string AccountId , string strOpportunity){
     string strMessage = '';
     list<Opportunity> lstOppor =[select id,cm_Contact__c,cm_Contact__r.cm_Birthdate__c,cm_Contact__r.cm_Passport_Number__c,cm_Contact__r.cm_Resident_Of_UAE__c,cm_Contact__r.MailingStreet,cm_Contact__r.MailingCity,cm_Contact__r.MailingState,cm_Contact__r.MailingPostalCode,cm_Contact__r.MailingCountry ,cm_Contact__r.cm_National_ID_No__c from Opportunity where id=:strOpportunity];
     list<Account> lstAccount = [select id,Name,cm_Date_of_Incorporation__c,cm_Country_of_Incorporation__c,cm_Trade_License_Expiry_Date__c,cm_Trade_License_Number__c,cm_Passport_Number__pc,cm_National_ID_No__pc from Account where Id=:AccountId];
     if(lstAccount!=null && lstAccount.size() >0){
         if(lstAccount[0].cm_Date_of_Incorporation__c == null){
              strMessage = 'Please fill all the required fields : Date of Incorporation';
         }else if(lstAccount[0].cm_Country_of_Incorporation__c == null){
              strMessage = 'Please fill all the required fields : Country of Incorporation';
         }else if(lstAccount[0].cm_Trade_License_Expiry_Date__c == null){
              strMessage = 'Please fill all the required fields : Trade License Expiry Date';
         }else if(lstAccount[0].cm_Trade_License_Number__c ==null){
              strMessage = 'Please fill all the required fields : Trade License Number';
         }
         if(lstOppor!=null && lstOppor.size() >0){
             if(lstOppor[0].cm_Contact__c!=null){
                 Date DTVal =  system.today().addYears(-21);
                 if(lstOppor[0].cm_Contact__r.cm_Birthdate__c ==null){
                     strMessage = 'Please fill all the required fields: Person Birthdate';
                 }else if(lstOppor[0].cm_Contact__r.cm_Birthdate__c !=null && lstOppor[0].cm_Contact__r.cm_Birthdate__c >= System.today()){
                    strMessage = 'Please fill all the required fields : Please provide a valid Date of Birth.';
                 }else  if(lstOppor[0].cm_Contact__r.cm_Passport_Number__c==null){
                     strMessage = 'Please fill all the required fields : Passport';
                 }else if(lstOppor[0].cm_Contact__r.cm_Resident_Of_UAE__c ==false && lstOppor[0].cm_Contact__r.MailingStreet == null && lstOppor[0].cm_Contact__r.MailingCity == null && lstOppor[0].cm_Contact__r.MailingState == null && lstOppor[0].cm_Contact__r.MailingCountry == null){
                     strMessage = 'Please fill all the required fields : Residence of UAE / Person Mailing Address';
                 }else if(lstOppor[0].cm_Contact__r.cm_Resident_Of_UAE__c == true &&  lstOppor[0].cm_Contact__r.cm_National_ID_No__c == null){
                     strMessage = 'Please fill all the required fields : Resident of UAE / National ID';
                 }else{
                     strMessage = 'success';
                 }
             }
             else
                strMessage = 'No Contact record found';
         }
         
     }
     return strMessage;
    }

    /*
        Method Name : ApproveProperties
        Description :  for Submit for Approval - Update the Property Inventory status to Booked
    */
    webservice static String ApproveProperties(string strOpportunityId){
        string strMessage = '';
    try{
        set<id> setIds = new set<id>();
        string strunits ='';
        list<Opportunity_Property__c> lstOpporunityProperty = [select id,Name,cm_Opportunity__c,cm_Property_Inventory__c,cm_Property_Inventory__r.Location_Code__c from Opportunity_Property__c where cm_Opportunity__c =:strOpportunityId and Sales_Order__c!=null];
        for(Opportunity_Property__c obj:lstOpporunityProperty){
            setIds.add(obj.cm_Property_Inventory__c);
            strunits = strunits+','+obj.cm_Property_Inventory__r.Location_Code__c;
        }
        if(setIds!=null && setIds.size() > 0){
            list<Property_Inventory__c> lstprodata = [select id,name,Property_Status__c from Property_Inventory__c where ID IN:setIds and Property_Status__c = 'Available' ];
            if(lstprodata!=null && lstprodata.size() >0){
                for(Property_Inventory__c objINV:lstprodata){
                    objINV.Property_Status__c = 'Booked';
                    objINV.Booked_Time__c = system.now();
                    objINV.Cm_SYS_Opportunity__c = strOpportunityId;
                }
               update lstprodata;
               strMessage =  'success';
            }else{
                strMessage = 'Selected units '+ strunits +' are already booked';
            }
        }
    }
    catch(exception ex){
        strMessage =  ex.getMessage();
    }
        return strMessage;
    }

    /*
        Method Name : updateLog
        Description : This method is used to update the Parent service log with success / fail/ total cound and status.
   */
    public static void updateLog(string parentlogId,integer ItotalCount,integer ISuccessCount,integer IFailCount){
        if(parentlogId!=null && parentlogId!=''){
             Service_Logs__c Parentserlog = new Service_Logs__c(id=parentlogId);
             Parentserlog.Total_Count__c = ItotalCount;
             Parentserlog.Success_Count__c = ISuccessCount;
             Parentserlog.Error_Count__c = IFailCount;
             Parentserlog.Log_Type__c = 'Completed';
             update Parentserlog;
        }
    }

     /*
        Method Name : createParentLog
        Description : This method is used to create the Parent service log
    */
    public static string createParentLog(string OppoId,string ProcessName){
        Service_Logs__c parentlog = new Service_Logs__c();
        parentlog.Process_Name__c = ProcessName;
        parentlog.Process_Time__c = system.now();
        parentlog.Log_type__c  = 'Process Started';
        if(OppoId!=null && OppoId!='')
        parentlog.Opportunity__c = OppoId;
        insert parentlog;
        return parentlog.id;
    }

    /*
        Method Name : CreateSpecialApprovals
        Description : This method is used to create special approvals when payment process is done based on the user options
    */
    public static string CreateSpecialApprovals(decimal dcash,Opportunity objOpportunity,string DepositMethod,string strSelCreditCardOption,string strComments){
        try{
        //system.debug('>>>>>>>>>> manager of PA is UTILS' + objOpportunity.cm_Sales_Executive_Manager__c);  
           
             //system.debug('*********inside Approval dcash '+dcash);
             //system.debug('*********inside Approval objOpportunity '+objOpportunity);
             //system.debug('*********inside Approval DepositMethod '+DepositMethod);
             //system.debug('*********inside Approval strSelCreditCardOption '+strSelCreditCardOption);
             
             list<string> lstApprovalTypes = new list<string>();
             //lstApprovalTypes.add('Others');
             lstApprovalTypes.add('Credit Card Exception - Less than 37K up to 20K');
             lstApprovalTypes.add('Credit Card Exception - Less than 20k');
             lstApprovalTypes.add('Cash - No Payment');
             lstApprovalTypes.add('Credit Card Exception - No Payment');
             lstApprovalTypes.add('Cash - Less than 37K up to 20K');
             lstApprovalTypes.add('Cash - Less than 20k');
             lstApprovalTypes.add('Change of Payment Plan');
             lstApprovalTypes.add('Others');
            
             lstApprovalTypes.add('Deposit Exception');
             lstApprovalTypes.add('Discount in Cash Deposit');
             lstApprovalTypes.add('Discount in Credit Card Deposit');
             lstApprovalTypes.add('Wire Transfer Deposit Waiver');
             //1.1
             lstApprovalTypes.add('Referral Special Approval');
             string ReferralName;
             
             string strCodes = '';
             string strBuildingName = '';
             list<Opportunity_Property__c> lstopp = [Select id, Building__c,cm_Inventory_Location_Code__c,cm_Opportunity__r.Referral__c,cm_Opportunity__r.Referral__r.Name from Opportunity_Property__c where cm_Opportunity__c =: objOpportunity.id];
             if(lstopp!=null && lstopp.size() >0){
                 for(Opportunity_Property__c obj:lstopp){
                     if(strCodes == ''){
                         strCodes = obj.cm_Inventory_Location_Code__c;
                     }else{
                         strCodes = strCodes+','+obj.cm_Inventory_Location_Code__c;
                     }
                    //v1.1
                    ReferralName = obj.cm_Opportunity__r.Referral__r.Name;
                 }
             }
             // Assiging Building Name. 
             if(lstopp!=null && lstopp.size() >0){
                strBuildingName =  lstopp[0].Building__c;
             }
             // Custom settings to define project default amount settings.
             // Verify default amount in custom settings
             // If record exists then consider default amount from CS
             
             Map<string,decimal> mapCSdata = new map<string,decimal>();
             /*
             Adeel - DepositAmountSetting
             Map<String,Deposit_Amount_Settings__c> DepositSettings = Deposit_Amount_Settings__c.getAll();
             for(Deposit_Amount_Settings__c obj:DepositSettings.values()){
                 mapCSdata.put(obj.Building_Name__c,obj.Minimum_Approved_Deposit_Amount__c);
             }
             */
             //system.debug('*******mapCSdata'+mapCSdata);

             List<cm_Interim_Approvals__c> lstInterim = new List<cm_Interim_Approvals__c>();
             list<cm_Interim_Approval_Type__c> lstApprovals = [select id,name from cm_Interim_Approval_Type__c where name IN :lstApprovalTypes];
             map<string,id> MapApprovalData = new Map<string,Id>();
             for(cm_Interim_Approval_Type__c objApptype:lstApprovals){
                 MapApprovalData.put(objApptype.Name,objApptype.Id);
             }
             //system.debug('*******MapApprovalData'+MapApprovalData);
             
             List<cm_Interim_Approvals__c> lstExisting = [Select id,Approval_Status__c from cm_Interim_Approvals__c where cm_Interim_Approval_Type__c =: MapApprovalData.get('Referral Special Approval')     
                                                             and cm_Opportunity__c=:objOpportunity.Id];    
             boolean createReferrer = false;    
             integer rejectedCount = 0;    
             if(!lstExisting.isEmpty()){    
                 for(cm_Interim_Approvals__c app: lstExisting ){    
                     if(app.Approval_Status__c.contains('Rejected'))    
                         rejectedCount++;    
                 }     
             }    
                 
             if(lstExisting.size() == rejectedCount)    
                 createReferrer = true;
             
             //if((dcash == 'Waiver') && MapApprovalData.get('Change of Payment Plan')!=null ){
             //     lstInterim.add(new cm_Interim_Approvals__c(cm_Opportunity__c = objOpportunity.id, cm_Interim_Approval_Type__c = MapApprovalData.get('Change of Payment Plan'),cm_Comments__c= 'Customer Payment Option is :'+dcash,Assign_To__c= objOpportunity.cm_Sales_Executive_Manager__c,cm_Selected_Units_New__c =strCodes));    
             //}
            
             if((strComments!=null && strComments!='') && MapApprovalData.get('Others')!=null ){
                  lstInterim.add(new cm_Interim_Approvals__c(cm_Opportunity__c = objOpportunity.id,Submit_for_Approval__c = true, cm_Interim_Approval_Type__c = MapApprovalData.get('Others'),cm_Comments__c= strComments,Assign_To__c= objOpportunity.cm_Sales_Executive_Manager__c,cm_Selected_Units_New__c =strCodes));    
             }
            

          /*   if(DepositMethod== 'Cash' && dcash == 'Waiver' && MapApprovalData.get('Cash - No Payment')!=null ){
                  lstInterim.add(new cm_Interim_Approvals__c(cm_Opportunity__c = objOpportunity.id, cm_Interim_Approval_Type__c = MapApprovalData.get('Cash - No Payment'),cm_Comments__c= 'Customer Payment Option is :'+dcash,Assign_To__c= objOpportunity.cm_Sales_Executive_Manager__c,cm_Selected_Units_New__c =strCodes));    
             }
             if(DepositMethod== 'Credit card' && dcash == 'Waiver' && MapApprovalData.get('Credit Card Exception - No Payment')!=null ){
                  lstInterim.add(new cm_Interim_Approvals__c(cm_Opportunity__c = objOpportunity.id, cm_Interim_Approval_Type__c = MapApprovalData.get('Credit Card Exception - No Payment'),cm_Comments__c= 'Customer Payment Option is :'+dcash,Assign_To__c= objOpportunity.cm_Sales_Executive_Manager__c,cm_Selected_Units_New__c =strCodes ));    
             } */
             
             String paymentMode = objOpportunity.cm_Payment_Mode__c;
             
             /*if(paymentMode != null && paymentMode == 'Wire Transfer' && MapApprovalData.get('Wire Transfer Deposit Waiver')!=null ){
                  lstInterim.add(new cm_Interim_Approvals__c(cm_Opportunity__c = objOpportunity.id, cm_Interim_Approval_Type__c = MapApprovalData.get('Wire Transfer Deposit Waiver'),cm_Comments__c= 'Waiving Full Wire Transfer Deposit',Assign_To__c= objOpportunity.cm_Sales_Executive_Manager__c,Payment_Option__c = strSelCreditCardOption,cm_Selected_Units_New__c =strCodes ));    
             }
             else if (paymentMode == 'Cheque') {
                 
             }
             else*/
             if((DepositMethod== 'Deposit Waiver'  || DepositMethod =='No Deposit') && paymentMode != null && paymentMode == 'Wire Transfer' && MapApprovalData.get('Wire Transfer Deposit Waiver')!=null){
                  lstInterim.add(new cm_Interim_Approvals__c(cm_Opportunity__c = objOpportunity.id,Submit_for_Approval__c = true, cm_Interim_Approval_Type__c = MapApprovalData.get('Wire Transfer Deposit Waiver'),cm_Comments__c= 'Waiving Full Wire Transfer Deposit',Assign_To__c= objOpportunity.cm_Sales_Executive_Manager__c,Payment_Option__c = strSelCreditCardOption,cm_Selected_Units_New__c =strCodes ));    
             }
             
             else if(strBuildingName!='' && mapCSdata.get(strBuildingName) ==null && DepositMethod== 'Credit card' && dcash != null && mapCSdata!=null && mapCSdata.get('Default')!=null && dcash < mapCSdata.get('Default')  && MapApprovalData.get('Deposit Exception')!=null){
                  lstInterim.add(new cm_Interim_Approvals__c(cm_Opportunity__c = objOpportunity.id,Submit_for_Approval__c = true, cm_Interim_Approval_Type__c = MapApprovalData.get('Deposit Exception'),cm_Comments__c= 'Credit Card Deposit Amount is: '+dcash,Assign_To__c= objOpportunity.cm_Sales_Executive_Manager__c,Payment_Option__c = strSelCreditCardOption,cm_Selected_Units_New__c =strCodes ));    
             }
             /*if(DepositMethod== 'Credit card' && dcash == '10000' && MapApprovalData.get('Credit Card Exception - Less than 20k')!=null){
                  lstInterim.add(new cm_Interim_Approvals__c(cm_Opportunity__c = objOpportunity.id, cm_Interim_Approval_Type__c = MapApprovalData.get('Credit Card Exception - Less than 20k'),cm_Comments__c= 'Customer Payment Amount is :'+dcash,Assign_To__c= objOpportunity.cm_Sales_Executive_Manager__c,Payment_Option__c = strSelCreditCardOption,cm_Selected_Units_New__c =strCodes));    
             }*/
             else if(strBuildingName!='' && mapCSdata.get(strBuildingName) ==null && DepositMethod== 'Cash' && dcash != null &&  mapCSdata!=null && mapCSdata.get('Default')!=null && dcash < mapCSdata.get('Default') && MapApprovalData.get('Deposit Exception')!=null){
                  lstInterim.add(new cm_Interim_Approvals__c(cm_Opportunity__c = objOpportunity.id, Submit_for_Approval__c = true,cm_Interim_Approval_Type__c = MapApprovalData.get('Deposit Exception'),cm_Comments__c= 'Cash Deposit Amount is: '+dcash,Assign_To__c= objOpportunity.cm_Sales_Executive_Manager__c,Payment_Option__c = strSelCreditCardOption,cm_Selected_Units_New__c =strCodes ));    
             }
             /*if(DepositMethod== 'Cash' && dcash == '10000' && MapApprovalData.get('Cash - Less than 20k')!=null){
                  lstInterim.add(new cm_Interim_Approvals__c(cm_Opportunity__c = objOpportunity.id, cm_Interim_Approval_Type__c = MapApprovalData.get('Cash - Less than 20k'),cm_Comments__c= 'Customer Payment Amount is :'+dcash,Assign_To__c= objOpportunity.cm_Sales_Executive_Manager__c,Payment_Option__c = strSelCreditCardOption,cm_Selected_Units_New__c =strCodes ));    
             }*/
             else if(strBuildingName!='' && mapCSdata.get(strBuildingName) !=null){
                 If((DepositMethod== 'Cash' || DepositMethod== 'Credit card' )&& dcash != null && dcash < mapCSdata.get(strBuildingName)  && MapApprovalData.get('Deposit Exception')!=null){
                     lstInterim.add(new cm_Interim_Approvals__c(cm_Opportunity__c = objOpportunity.id, Submit_for_Approval__c = true, cm_Interim_Approval_Type__c = MapApprovalData.get('Deposit Exception'),cm_Comments__c= 'Deposit Amount is: '+dcash,Assign_To__c= objOpportunity.cm_Sales_Executive_Manager__c,Payment_Option__c = strSelCreditCardOption,cm_Selected_Units_New__c =strCodes ));
                 }
             }
            
             //1.1
             if(createReferrer == true && MapApprovalData.get('Referral Special Approval') != null && ReferralName != null){
                //Create the Special Approval for Sales Operations Team (Kenny & Teo)
                /*Id OwnerId;
                for(QueueSobject objQ : [select QueueId from QueueSobject where sObjectType = 'cm_Interim_Approvals__c' AND Queue.DeveloperName = '']){
                    OwnerId = objQ.QueueId;
                }*/
                lstInterim.add(new cm_Interim_Approvals__c(cm_Opportunity__c = objOpportunity.id,Submit_for_Approval__c = true, cm_Interim_Approval_Type__c = MapApprovalData.get('Referral Special Approval'),Payment_Option__c = strSelCreditCardOption,cm_Selected_Units_New__c =strCodes,cm_Comments__c= 'Referrer Name: '+ReferralName));
                
             }
             
             insert lstInterim;
             //system.debug('*********lstInterim'+lstInterim);
             string msg = '';
             if(lstInterim!=null && lstInterim.size() >0){
                //msg = CM_EmaarUtils.sendEmail(objOpportunity.id,'submit');  // send email about special approvals
             }
             return 'success';
        }catch(exception ex){
             return ex.getMessage();
        }
        //return null;
    }

    /*
        Method Name : getRecordTypeId
        Description : This method is used to get the record type Id
    */
    webservice static Id getRecordTypeId(String objectName, String recordName){
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();  
        Schema.DescribeSObjectResult d = gd.get(objectName).getDescribe();
        return(d.getRecordTypeInfosByName().get(recordName).getRecordTypeId()); 
    }

    public static id GetRecordTypeIdByDeveloperName(string objectAPIName, string DeveloperName){
        id recordtypeid = null;
        list<recordtype> recordTypeList = new list<recordtype>([select id from recordtype where sobjecttype =:objectAPIName and developername =:DeveloperName limit 1]);
        if(recordTypeList != null && recordTypeList.size() >0)
            recordtypeid = recordTypeList[0].id;
        return recordtypeid;
    }
    

    /*
     v1.8 added Is_Released__c in query and if condition. -Sandeep
    Method Name : paymentApproval
    Description : This method is used to update the Opportunity and send emails to finance Team and Update Inventory to Booked status
    */
    webservice static String paymentApproval(Opportunity objOpportunity, string selPaymentMode, string DepositMethod, string selChequeOption, decimal dCash) {

        try {
            string advisorId = objOpportunity.OwnerId;

            //Added by Charan on 30/06/2017
            if (selPaymentMode != null && selPaymentMode != '')
                objOpportunity.cm_Payment_Mode__c = selPaymentMode;
            if (DepositMethod != null && DepositMethod != '')
                objOpportunity.cm_Deposit_Method__c = DepositMethod;

            if (selChequeOption != null && selChequeOption != '')
                objOpportunity.Payment_Options__c = selChequeOption;

            if (dCash != null && dCash > 0)
                objOpportunity.cm_Deposit_Amount__c = dCash;

            list<Opportunity_Property__c>lstOPPProp ;
            if (objOpportunity.id != null) {
                lstOPPProp = [select id, Name, cm_Property_Inventory__r.cm_Related_Campaign__c,
                                                           cm_Property_Inventory__r.cm_Related_Campaign__r.Is_release_launch_Campaign__c,cm_Property_Inventory__r.Is_Released__c from Opportunity_Property__c where cm_Opportunity__c =: objOpportunity.id];//v1.8
            }
            //v2.1 - added the condition below
            if(lstOPPProp != null && lstOPPProp.size() >0 && lstOPPProp[0].cm_Property_Inventory__r.cm_Related_Campaign__c!=null 
                && (lstOPPProp[0].cm_Property_Inventory__r.cm_Related_Campaign__r.Is_release_launch_Campaign__c == true || lstOPPProp[0].cm_Property_Inventory__r.Is_Released__c == true ) 
                && objOpportunity.Is_From_Online_Sales__c == false ) {//v1.8
                
                // Assign opportunity ro Admin Group.
                map < String, Mobile_Configurations__c > mpConfigs = Mobile_Configurations__c.getAll();
                list < user > lstAdminUser = [select id, Name, Email from user where username =: mpConfigs.get('Configuration').cm_Sales_Admin_Username__c];
                if (lstAdminUser != null && lstAdminUser.size() > 0) {
                    objOpportunity.ownerId = lstAdminUser[0].id;
                }
                
            }else if(objOpportunity.Is_From_Online_Sales__c == false){
                if (objOpportunity.Is_From_Customer_Direct__c) { 
                    string OwnerId = SalesAdminAssignment.GetNextOwnerId_CustomerDirect();
                    if (OwnerId != null)
                        objOpportunity.ownerId = OwnerId;
                } else if (objOpportunity.Is_From_Broker_App__c) {
                    string OwnerId = SalesAdminAssignment.GetNextOwnerId_BrokerDirect();
                    if (OwnerId != null)
                        objOpportunity.ownerId = OwnerId;
                }/*v2.1 - Owner Assignment will be done from Payment Confirmation screen
                else if (objOpportunity.Is_From_Online_Sales__c) {
                    string OwnerId = Label.EmaarOnlineSalesOwnerId;
                    if (OwnerId != null)
                        objOpportunity.ownerId = OwnerId;
                }end of v2.1*/ else { 
                    string strOwnerId = '';
                    system.debug('**********strOwnerId'+strOwnerId);
                    if (strOwnerId == '') {
                        system.debug('*****DefaultCheck*****strOwnerId'+strOwnerId);
                        strOwnerId = SalesAdminAssignment.AssignDefaultAdmin(advisorId);
                        system.debug('*****DefaultCheck*****strOwnerId'+strOwnerId);
                        if(strOwnerId!='' && strOwnerId!=null)
                            objOpportunity.ownerId = strOwnerId;
                    }
                    if (strOwnerId == '') {
                        system.debug('*****7daysCheck*****strOwnerId'+strOwnerId);
                        strOwnerId = SalesAdminAssignment.Check_Last_7_Days(objOpportunity.AccountId);
                        system.debug('*****7daysCheck*****strOwnerId'+strOwnerId);
                        if(strOwnerId!='' && strOwnerId!=null)
                            objOpportunity.ownerId = strOwnerId;
                    } 
                    if (strOwnerId == '') {
                       /* if (objOpportunity.Property_Advisor_Location__c == 'Dubai Hills') {
                            system.debug('*****Dubai Hills*****strOwnerId');
                            objOpportunity.ownerId = label.Dubai_Hills_Sales_Admin;
                            system.debug('*****Dubai Hills*****strOwnerId'+objOpportunity.ownerId);
                        } else if (objOpportunity.Property_Advisor_Location__c == 'Abu Dhabi') {
                            system.debug('*****abu dhabi*****strOwnerId');
                            objOpportunity.ownerId = label.Abudhabi_Sales_Admin;
                            system.debug('*****abu dhabi*****strOwnerId'+objOpportunity.ownerId);
                        } else {
                            objOpportunity.ownerId = SalesAdminAssignment.GetNextOwnerId();
                        }*/
                        //v1.8 start
                        map<string,id> teamSalesAdmin = new map<string,id>(); 
                        for(Configuration__c con : [select Sales_Admin__c,Team__c from Configuration__c where recordtype.developername='SE_to_Sales_Admin_Auto_Assignment' and Sales_Admin__c!=null and Team__c!=null]){
                            teamSalesAdmin.put(con.team__c,con.Sales_Admin__c);
                        }
                        if (objOpportunity.Bundle_ID__c == null) {
                            /*if (objOpportunity.Advisor_Location__c == 'Dubai Hills') {
                                objOpportunity.ownerId = label.Dubai_Hills_Sales_Admin;
                            } else if (objOpportunity.Advisor_Location__c == 'Abu Dhabi') {
                                objOpportunity.ownerId = label.Abudhabi_Sales_Admin;
                            } else {
                                objOpportunity.ownerId = SalesAdminAssignment.GetNextOwnerId();
                            }*/
                            //v1.8
                            if (teamSalesAdmin.containsKey(objOpportunity.Advisor_Location__c)) {
                                objOpportunity.ownerId = SalesAdminAssignment.TeamDefaultAssignment(objOpportunity.Advisor_Location__c);
                            } else {
                                objOpportunity.ownerId = SalesAdminAssignment.GetNextOwnerId();
                            }
                            //v1.8 
                        } else {
                            list < Opportunity > lstOPP = [select id, OwnerId, cm_Approval_Status__c, stageName from Opportunity where Bundle_ID__c =: objOpportunity.Bundle_ID__c and ID !=: objOpportunity.Id and Bundle_ID__c != null];
                            string Next_OwnerId = '';
                            for (Opportunity objOPP_MB: lstOPP) {
                                if (objOPP_MB.cm_Approval_Status__c == 'Pending with Admin' && objOPP_MB.stageName == 'Pending Approval' && Next_OwnerId == '') {
                                    Next_OwnerId = objOPP_MB.OwnerId;
                                }
                            }
                            if (lstOPP != null && lstOPP.size() > 0 && Next_OwnerId != '') {
                                objOpportunity.ownerId = Next_OwnerId;
                            } else {
                                /*if (objOpportunity.Advisor_Location__c == 'Dubai Hills') {
                                    objOpportunity.ownerId = label.Dubai_Hills_Sales_Admin;
                                } else if (objOpportunity.Advisor_Location__c == 'Abu Dhabi') {
                                    objOpportunity.ownerId = label.Abudhabi_Sales_Admin;
                                } else {
                                    objOpportunity.ownerId = SalesAdminAssignment.GetNextOwnerId();
                                }*///v1.8 
                                if (teamSalesAdmin.containsKey(objOpportunity.Advisor_Location__c)) {
                                    objOpportunity.ownerId = SalesAdminAssignment.TeamDefaultAssignment(objOpportunity.Advisor_Location__c);
                                } else {
                                    objOpportunity.ownerId = SalesAdminAssignment.GetNextOwnerId();
                                }
                                //v1.8 
                            }
                        }
                    }
                }
            }
            // Change the record type to Pending with Admin.
            objOpportunity.recordTypeId = getRecordTypeId('Opportunity', 'Pending Admin Approval');
            objOpportunity.cm_Approval_Status__c = 'Pending with Admin';
            objOpportunity.stageName = 'Pending Approval';
            objOpportunity.Cm_is_Payment_done__c = true;
            System.debug('Before....objOpportunity'+objOpportunity);
            update objOpportunity; 
            System.debug('After....objOpportunity'+objOpportunity);
            UpdatePropertyInventories(objOpportunity.id);
            // CM_EmaarUtils.NotifyAdminforApproval(objOpportunity.id);
            //CM_EmaarUtils.NotifyFinanceTeam(objOpportunity.id);

            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('VV Error -->'+e.getMessage());
            return e.getMessage();
        }
    }

    /*
        Method Name : UpdatePropertyInventories
        Description : This method is used to update the Property inventories
    */
    webservice static void UpdatePropertyInventories(string strID){
        System.debug('VV Inside UpdatePropertyInventories');
         list<Opportunity_Property__c> lstOpportunityProperty = [select id,name,cm_Property_Inventory__c,cm_Opportunity__c from Opportunity_Property__c where cm_Opportunity__c=:strID];
         //system.debug('****lstOpportunityProperty'+lstOpportunityProperty);
         set<id> setProInv = new set<id>();
         for(Opportunity_Property__c objProINV:lstOpportunityProperty){
             setProInv.add(objProINV.cm_Property_Inventory__c); 
         }
         list<Property_Inventory__c> lstProInv = [select id,Payment_Confirmation__c from Property_Inventory__c where ID IN:setProInv ];
         for(Property_Inventory__c objProInV:lstProInv){
             objProInV.Payment_Confirmation__c = true;
         }
         //system.debug('****lstProInv'+lstProInv);
         System.debug('Update lstProInv...');
         update lstProInv;
    }

    /*
        Method Name : createPaymentRecord
        Description : This methid is used to create Opportunity Payment record
    */
    public static string createPaymentRecord(decimal dcash,Opportunity objOpportunity, String paymentPurpose){
    // v2.0 - EPESI-628 : Added paymentPurpose parameter to method definition and assigned it to Payment record.
    Opportunity_Payment__c objPayment = new Opportunity_Payment__c();
        objPayment.Opportunity__c = objOpportunity.id;
        //objPayment.URL__c = paymentURL;
        objPayment.Amount__c = dCash;
        objPayment.Contact__c = objOpportunity.cm_contact__c ;
        objPayment.Status__c = 'Email Sent to Customer';
        objPayment.Payment_Purpose__c = paymentPurpose;
        insert objPayment;
        
        //1.2 - Querying on Opportunity Payment to check whether the Opportunity is created by Broker App
        Boolean isBApp = false;
        // VV
        String strLocationCode = '';
        for(Opportunity objOpp : [select Id,cm_Sales_Person__c,cm_Sales_Person__r.ContactId,Is_From_Broker_App__c,Is_From_Customer_Direct__c,(Select Id,cm_Inventory_Location_Code__c from Opportunity_Properties__r limit 1) from Opportunity where Id=:objOpportunity.Id]){
          if(objOpp.Is_From_Broker_App__c || objOpp.Is_From_Customer_Direct__c)
            isBApp = true;
            
           // VV
           if(objOpp.Opportunity_Properties__r.size()>0){
                strLocationCode = objOpp.Opportunity_Properties__r[0].cm_Inventory_Location_Code__c;
           }
        }//end of 1.2
        
        //string paymentURL = isBApp ? CM_PaymentUtils.BrokerAppGenerateSFLink(objPayment.Id) : CM_PaymentUtils.GenerateSFLink(objPayment.id);
        string paymentURL = isBApp ? '' : CM_PaymentUtils.GenerateSFLink(objPayment.id);
        
        objPayment.URL__c = paymentURL;
        objPayment.Payment_Link_Expiry_Date__c = isBApp ? null : CM_PaymentUtils.GenerateExpiryDate();
        objPayment.Location_Code__c = strLocationCode; 
        update objPayment; 
        return 'success';
    }

    /* 
        Method Name : getOrgIdtoRegionName
        Description : This method is used to get the region name if oracle org id passed
    */
    public static MAP<Decimal, String> getOrgIdToRegionNameMapping(){
        MAP<Decimal, String> orgIdToRegionNameMap = new MAP<Decimal, String>();
        for(Org_Settings__c setting : [SELECT id, Oracle_Org_Id__c, Region__c FROM Org_Settings__c]){
            orgIdToRegionNameMap.put(setting.Oracle_Org_Id__c, setting.Region__c);
        }
        return orgIdToRegionNameMap;
    }

    /*
        Method Name : GetSessionID
        Description : This method is used to session ID for the Particular User
    */
    public static string GetSessionID(boolean isTest){

        string bodyToSendLogin;
        string outCallResultLogin;
        string sessionID;
        string userName = ''; 
        string password = '';
        string loginURL ='';
        
        /* Adeel - Commenting this one */
        /*
        list<Drawloop_user_settings__mdt> PGList = new list<Drawloop_user_settings__mdt> ([select id,Login_URL__c,Password__c,User_ID__c,User_Name__c  from Drawloop_user_settings__mdt  limit 1]);
        if(PGList.size() > 0){
            loginURL = PGList[0].Login_URL__c;
            userName = PGList[0].User_Name__c; 
            password = PGList[0].Password__c;
        }
        */
        
        //This beginning piece of XML can be re-used for the subsequent calls
        string SOAP_START  = '<?xml version="1.0" encoding="utf-8"?><env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"><env:Body><n1:login xmlns:n1="urn:partner.soap.sforce.com"><n1:username>';
        bodyToSendLogin = SOAP_START + userName + '</n1:username><n1:password>' + password + '</n1:password></n1:login></env:Body></env:Envelope>';
        
        outCallResultLogin = makeHTTPCall(loginURL,bodyToSendLogin);
        //system.debug('outCallResultLogin Output: ' + outCallResultLogin);   
        
        sessionID = getValueFromXMLString(outCallResultLogin, 'sessionId');
        //system.debug('sessionID -> '+ sessionID);
        return sessionID;
    }

    /*
        Method Name : makeHTTPCall
        Description : 
    */
    public static string makeHTTPCall(string endPoint, string soapBody){
        Http hLLogin = new Http();
        HttpRequest reqLLogin = new HttpRequest();
        reqLLogin.setTimeout(60000);
        reqLLogin.setEndpoint(endPoint);  
        reqLLogin.setMethod('POST');
        reqLLogin.setHeader('SFDC_STACK_DEPTH', '1');
        reqLLogin.setHeader('SOAPAction','login'); 
        //reqLLogin.setHeader('User-Agent', 'SFDC-Callout/22.0');
        reqLLogin.setHeader('Accept','text/xml');  
        reqLLogin.setHeader('Content-type','text/xml');    
        reqLLogin.setHeader('charset','UTF-8'); 
        //system.debug('Request: ' + reqLLogin);
        System.debug('VV soapBody --->'+soapBody);
        reqLLogin.setBody(soapBody);    
        HttpResponse resLLogin = hLLogin.send(reqLLogin);
        string outCallResultLogin2 = '';
        outCallResultLogin2 = resLLogin.getBody();
        return outCallResultLogin2;
    }

    /*
        Method Name : GenerateSalesOffer
        Description : Used to Generate  Sales Offer
    */
    webservice static String GenerateSalesOffer(string strOpportunityId){
        string strResponse = '';
        try{
            Pagereference pageRef = Page.CM_salesoffer;
            pageRef.getParameters().put('Id',strOpportunityId);
            
            blob body = test.isRunningTest() ? blob.valueOf('String toBlob') : pageRef.getContent();

            Opportunity opp = [Select id, name from opportunity where Id =: strOpportunityId];

            ContentVersion contentVersion = new ContentVersion(
              Title = 'Sales Offer',
              PathOnClient = 'Sales Offer - '+opp.Name+'.pdf',
              VersionData = body,
              Opportunity__c = strOpportunityId,
              IsMajorVersion = true
            );
            insert contentVersion;    

            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument ORDER BY Id DESC LIMIT 1];

            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = opp.Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;

            /*
            Attachment att=new Attachment();
            att.Body=body;
            att.Name='Sales Offer - '+opp.Name+'.pdf';
            att.parentId= strOpportunityId;
            insert att;
            */
            strResponse = 'success-'+documents[0].id;
        }
        catch(exception ex){
            strResponse = ex.getMessage();
        }   
        return strResponse;
    }
        
    /*
        Method Name : CreateContentAttachments
        Description : This method is used to create Content Attchments
    */
    webservice static string CreateContentAttachments(string strOportunityId){
    string strMessage = '';
    try{
        set<Id> setPROIN = new set<Id>();
        list<Opportunity_Property__c> lstOpporunityProperty = [select id,Name,cm_Opportunity__c,cm_Property_Inventory__c,cm_Property_Inventory__r.cm_Building__c,cm_Property_Inventory__r.Unit_Position__c from Opportunity_Property__c where cm_Opportunity__c =:strOportunityId];
        //system.debug('>>>>>>>>>lstOpporunityProperty>>>>>>>>>>>>'+lstOpporunityProperty);
        Map<string,Opportunity_Property__c> mpOpps = new map<string,Opportunity_Property__c>();
        if(lstOpporunityProperty!=null && lstOpporunityProperty.size()>0){
        for(Opportunity_Property__c objprop:lstOpporunityProperty){
             mpOpps.put(objprop.cm_Property_Inventory__r.cm_Building__c+'###'+objprop.cm_Property_Inventory__r.Unit_Position__c, objprop);
             //mpOpps.put(objprop.cm_Property_Inventory__r.cm_Building__c+'###', objprop); //Adeel, commenting this one
             setPROIN.add(objprop.cm_Property_Inventory__c);
        }
        //system.debug('>>>>>>>>>>>>>>>>>>>'+mpOpps);
        
        /****************1********FLOOR PLANS***************************************/
        list<ContentVersion> lstCV = [select id,FileType,FileExtension,Title,versionData,cm_Building__c,cm_Content_Key__c from contentVersion where islatest=true and cm_Content_Key__c =: mpOpps.keyset() and cm_is_Floor_plan__c = true];
        Map<string,list<ContentVersion>> mpVersions = new Map<String,List<ContentVersion>>();
        for(ContentVersion cv: lstCV){
          if(!mpVersions.containsKey(cv.cm_Content_Key__c))
              mpVersions.put(cv.cm_Content_Key__c, new List<ContentVersion>{cv});
            else{
              List<ContentVersion> lstCVExisting= mpVersions.get(cv.cm_Content_Key__c);
              lstCVExisting.add(cv);
              mpVersions.put(cv.cm_Content_Key__c, lstCVExisting);
            }
            
        }
        //system.debug('***1******mpVersions'+mpVersions);
        
        /********************************END****************************************/
        
        /*************PROPERTY INVENTORY Related Content*****************************/
        list<ContentVersion> lstPICV = [select id,FileType,FileExtension,Title,versionData,cm_Building__c,cm_Content_Key__c,Property_Inventory__c from contentVersion where islatest=true 
                        and Property_Inventory__c IN:setPROIN order by lastmodifiedDate asc];
        Map<ID,ContentVersion> mpPIVersionData= new Map<ID,ContentVersion>(); 
        for(ContentVersion cv: lstPICV){
            mpPIVersionData.put(cv.Property_Inventory__c, cv);
        } 
        //system.debug('***2***mpPIVersionData'+mpPIVersionData);
        /****************************END***********************************************/
        //system.debug('>>>>>>>>>>>>>>>>>>>'+lstCV);
        list<Attachment> lstToinsert = new list<Attachment>();
        for(Opportunity_Property__c objprop:lstOpporunityProperty){
              string key = objprop.cm_Property_Inventory__r.cm_Building__c+'###'+objprop.cm_Property_Inventory__r.Unit_Position__c;
              string key1 = objprop.cm_Property_Inventory__r.cm_Building__c+'###';
              //system.debug('Key For Content ' + key);
              //system.debug('Key for Content ' + key1);
              if(mpVersions.containsKey(key)){
                  for(ContentVersion cv : mpVersions.get(key)){
                    Attachment att = new attachment(name='salesOffer'+'.'+cv.FileExtension,body = cv.versionData, parentId=objProp.Id);
                    lstToinsert.add(att);
                  }
              }
              else if (mpVersions.containsKey(key1)) {
                  for(ContentVersion cv : mpVersions.get(key1)){
                    Attachment att = new attachment(name='salesOffer'+'.'+cv.FileExtension,body = cv.versionData, parentId=objProp.Id);
                    lstToinsert.add(att);
                  }
              }
              if(mpPIVersionData!=null && mpPIVersionData.get(objProp.cm_Property_Inventory__c)!=null){
                  ContentVersion cv = mpPIVersionData.get(objProp.cm_Property_Inventory__c);
                  Attachment att = new attachment(name='salesOffer'+'.'+cv.FileExtension,body = cv.versionData, parentId=objProp.Id);
                  lstToinsert.add(att);
              }
         }
        system.debug('***lstToinsert'+lstToinsert);
        insert lstToinsert;
        string Ids ='';
         
                for(Attachment obj:lstToinsert){
                     Ids = obj.id+';'+Ids ;
                }
                strMessage = 'success-'+Ids;
           
        }
        else{
            strMessage = 'No Properties are added to the selected Opportunity';
        }       
        }catch(exception ex){
            strMessage = ex.getMessage();
        }
        return strMessage;
    }
    
    
    
    /*
        Method Name : DeleteContentAttachments
        Description : This method is used to Delete the content attachment
    */
    webservice static string DeleteContentAttachments(string strIds){
        string strMessage = '';
        try{
            if(strIds != null && strIds.indexOf('-') > -1){
                list<string>lst1 =  strIds.split('-');
                list<string> lst2 = lst1[1].split(';');
                list<Attachment> lstAttachment = [select id from Attachment where id IN:lst2];
                delete lstAttachment;
                strMessage = 'success';
            }
        }catch(exception ex){
            strMessage = ex.getMessage();
        }
        return strMessage;
    }

     /*
      Method Name : getCreatableFieldsSOQL
      Descriptiond : This method used to construct the Opportunity SOQL.
    */
    public static string getCreatableFieldsSOQL(string objectName){
        String selects = '';
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
               // if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
              //  }
            }
        }
        // contruction of SOQL
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
        // return constrcucted query
        return 'SELECT ' + selects + ' FROM ' + objectName ;
         
    }

    /* 
        Method Name : getAccessableInventoryIds
        Description : Method to get the property inventories based on user's campaign
    */
    public static SET<Id> getAccessableInventoryIds(){
        SET<Id> propertyInventoryIds = new SET<Id>();
        SET<Id> campaignIds = new SET<Id>();
        for(Campaign_User__c cUser: [SELECT Id, cm_Campaign__r.Id FROM Campaign_User__c WHERE cm_Campaign__r.Status = 'In Progress' AND cm_User__c =:Userinfo.getUserId()]){
            campaignIds.add(cUser.cm_Campaign__r.Id);    
        }
        System.debug('@@campaignIds='+campaignIds+'UserId='+Userinfo.getUserId());
        for(Campaign_Unit__c cUnit : [SELECT Id, cm_Property_Inventory__r.Id FROM Campaign_Unit__c WHERE cm_Campaign__c IN :campaignIds]){
            propertyInventoryIds.add(cUnit.cm_Property_Inventory__r.Id);
        }
        return propertyInventoryIds;
    }

    /* 
        Method Name : getAccessableInventoryIds
        Description : Method to get the property inventories based on selected campaign
    */
    public static SET<Id> getInventoryByCampaignId(Id campaignId){
         SET<Id> propertyInventoryIds = new SET<Id>();
         for(Campaign_Unit__c cUnit : [SELECT Id, cm_Property_Inventory__r.Id FROM Campaign_Unit__c WHERE cm_Campaign__c = :campaignId]){
            propertyInventoryIds.add(cUnit.cm_Property_Inventory__r.Id);
        }
        return propertyInventoryIds;
    }

    /* 
        Method Name : getAccessableInventoryIds
        Description : Method to get the property inventories based on selected campaigns, semi colon separated list
    */
    public static SET<Id> getInventoryByCampaignIds(String campaignIds){
         LIST<String> campIds = campaignIds.split(';');
         SET<Id> propertyInventoryIds = new SET<Id>();
         for(Campaign_Unit__c cUnit : [SELECT Id, cm_Property_Inventory__r.Id FROM Campaign_Unit__c WHERE cm_Campaign__c IN :campIds]){
            propertyInventoryIds.add(cUnit.cm_Property_Inventory__r.Id);
        }
        return propertyInventoryIds;
    }

    /* 
        Method Name : getOrgId
        Description : Method to get org id based on following parameters
        If opportuntity id is provided, then check for property inventory id to get org id
        If opportunity property id is provided, then check for property inventory to get org id
        If property inventory id is provided, then check for same record to get the org id
        If nothing is provided, check the user to get org id
    */    
    public static decimal getOrgId(String opportunityId, String opportunityPropertyId, String propertyInventoryId){
        Decimal orgId;
        if(String.isNotBlank(opportunityId)){
            orgId = [SELECT Id, cm_Property_Inventory__r.Org_ID__c FROM Opportunity_Property__c WHERE cm_Opportunity__c =:opportunityId][0].cm_Property_Inventory__r.Org_ID__c;
        }

        if(String.isNotBlank(opportunityPropertyId)){
            orgId = [SELECT Id, cm_Property_Inventory__r.Org_ID__c FROM Opportunity_Property__c WHERE Id =:opportunityPropertyId].cm_Property_Inventory__r.Org_ID__c;
        }

        if(String.isNotBlank(propertyInventoryId)){
            orgId = [SELECT Id, Org_ID__c FROM Property_Inventory__c WHERE Id =: propertyInventoryId].Org_ID__c;
        }

        //if all three are blanks, then populate the org id from user's record
        if(String.isBlank(opportunityId) && String.isBlank(opportunityPropertyId) && string.isBlank(propertyInventoryId)){
            User u = [SELECT Id, Oracle_Org_Name__c FROM User WHERE Id =: UserInfo.getUserId()];
            if(u != null){
                orgId = Decimal.valueOf(u.Oracle_Org_Name__c);
            }
        }
        return orgId;
    }

    /* Method to convert english number to arabic */
    public static string convertStringToArabicNumber(String amount){
        String amountInArabic = amount;
        amountInArabic = amountInArabic.replace('0', '٠');
        amountInArabic = amountInArabic.replace('1', '١');
        amountInArabic = amountInArabic.replace('2', '٢');
        amountInArabic = amountInArabic.replace('3', '٣');
        amountInArabic = amountInArabic.replace('4', '٤');
        amountInArabic = amountInArabic.replace('5', '٥');
        amountInArabic = amountInArabic.replace('6', '٦');
        amountInArabic = amountInArabic.replace('7', '٧');
        amountInArabic = amountInArabic.replace('8', '٨');
        amountInArabic = amountInArabic.replace('9', '٩');
        amountInArabic = amountInArabic.replace('.', '٫');
        Integer stringLength = amountInArabic.split('٫')[0].length();
        String suffix = amountInArabic.split('٫').size() > 1 ? '.' + amountInArabic.split('٫')[1] : '';
        if(stringLength == 5 ){
            amountInArabic = amountInArabic.substring(0, 2) + '٬' + amountInArabic.substring(2);
        }else if(stringLength == 6){
            amountInArabic = amountInArabic.substring(0, 3) + '٬' + amountInArabic.substring(3);            
        }else if(stringLength == 7){
            amountInArabic = amountInArabic.substring(0, 1) + '٬' + amountInArabic.substring(1, 4) + '٬' + amountInArabic.substring(4);            
        }else if(stringLength == 8){
            amountInArabic = amountInArabic.substring(0, 2) + '٬' + amountInArabic.substring(2, 5) + '٬' + amountInArabic.substring(5);            
        }else if(stringLength == 9){
            amountInArabic = amountInArabic.substring(0, 3) + '٬' + amountInArabic.substring(3, 6) + '٬' + amountInArabic.substring(6);            
        }else if(stringLength == 10){
            amountInArabic = amountInArabic.substring(0, 1) + '٬' + amountInArabic.substring(1, 4) + '٬' + amountInArabic.substring(4,7) + '٬' + amountInArabic.substring(7);            
        }else if(stringLength == 11){
            amountInArabic = amountInArabic.substring(0, 2) + '٬' + amountInArabic.substring(2, 5) + '٬' + amountInArabic.substring(5,8) + '٬' + amountInArabic.substring(8);            
        }else if(stringLength == 12){
            amountInArabic = amountInArabic.substring(0, 3) + '٬' + amountInArabic.substring(3, 6) + '٬' + amountInArabic.substring(6,9) + '٬' + amountInArabic.substring(9);            
        }
        
        /*if(String.isNotBlank(suffix)){
            //amountInArabic = amountInArabic + suffix;
            amountInArabic = amountInArabic.substring(0, amountInArabic.lastIndexOf('٫'));
            amountInArabic += suffix;
        }*/
        return amountInArabic;
    }

    /* 
        Method Name : fieldsMapByQueryingFieldResult
        Description : Method to get the map of field values by querying to get the data
        Date        : 25/07/2018
        Author      : Adeel Ahmad (4C)
    */    
    public static MAP<String, String> fieldsMapByQueryingFieldValue(String filter, String building, Set<Id> propertyInventoryIds){
        Map<String, String> fieldOptions = new Map<String, String>();
        List<AggregateResult> result = new List<AggregateResult>();
        if(filter == 'buildingsFilterOption'){
            result = [Select Location__r.Building__c res,count(id) from Property_Inventory__c where ID IN:propertyInventoryIds AND (Property_Status__c='Available' or Property_Status__c='') and Property_Type__c='Sale' and Location__r.Building__c != null group by Location__r.Building__c];         
        }

        if(filter == 'unitTypeFilterOption'){
            if(String.isBlank(building))
                result = [Select Type__c res,count(id) from Property_Inventory__c where ID IN:propertyInventoryIds AND (Property_Status__c='Available' or Property_Status__c='') and Property_Type__c='Sale' and Type__c != null group by Type__c];
            else
                result = [Select Type__c res,count(id) from Property_Inventory__c where ID IN:propertyInventoryIds AND Building_Name__c =:building AND (Property_Status__c='Available' or Property_Status__c='') and Property_Type__c='Sale' and Type__c != null group by Type__c];
        }

        if(filter == 'unitModelFilterOption'){
            if(String.isBlank(building))
                result = [Select Unit_Model__c res,count(id) from Property_Inventory__c where ID IN:propertyInventoryIds AND (Property_Status__c='Available' or Property_Status__c='') and Property_Type__c='Sale' and Unit_Model__c != null group by Unit_Model__c];
            else
                result = [Select Unit_Model__c res,count(id) from Property_Inventory__c where ID IN:propertyInventoryIds AND Building_Name__c =:building AND (Property_Status__c='Available' or Property_Status__c='') and Property_Type__c='Sale' and Unit_Model__c != null group by Unit_Model__c];                
        }

        if(filter == 'bedroomsFilterOption'){
            if(String.isBlank(building))
                result = [Select Sales_Rooms__c res,count(id) from Property_Inventory__c where ID IN:propertyInventoryIds AND (Property_Status__c='Available' or Property_Status__c='')  and Property_Type__c='Sale' and Sales_Rooms__c != null group by Sales_Rooms__c];
            else
                result = [Select Sales_Rooms__c res,count(id) from Property_Inventory__c where ID IN:propertyInventoryIds AND Building_Name__c =:building AND (Property_Status__c='Available' or Property_Status__c='')  and Property_Type__c='Sale' and Sales_Rooms__c != null group by Sales_Rooms__c];
        }

        if(filter == 'projectsFilterOption'){
            for(Property__c ar: [Select id, name,Property_Name__c from Property__c where Property_Name__c!=null and Active_Property__c = true order by Property_Name__c]){
                fieldOptions.put(ar.Property_Name__c, ar.Id);
            }
        }

        if(filter == 'CampaignsFilterOption'){
            LIST<Campaign_User__c> userCampaigns = [SELECT cm_Campaign__c,cm_Campaign__r.name,cm_User__c FROM Campaign_User__c where cm_User__c=: UserInfo.getUserId()];
            for(Campaign_User__c objcm:userCampaigns){
                fieldOptions.put(objcm.cm_Campaign__r.Name, objcm.cm_Campaign__c);
            }
        }

        for(AggregateResult ar: result){
            fieldOptions.put(string.valueOf(ar.get('res')),string.valueOf(ar.get('res')));
        } 


        return fieldOptions;
    }

    /* 
        Method Name : readFieldSet
        Description : Method to get fieldsets members
        Date        : 07/08/2018
        Author      : Adeel Ahmad (4C)
    */    
    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName){
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();

        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);

        return fieldSetObj.getFields(); 
    }  

    /* 
        Method Name : getFieldNameToFieldLabelMap
        Description : Method to get field label by field name from custom metadata settings.
        Date        : 07/08/2018
        Author      : Adeel Ahmad (4C)
    */    
    public static MAP<String, String> getFieldNameToFieldLabelMap(String orgId){
        MAP<String, String> resultMap = new MAP<String, String>();
        LIST<Field_Label_Translations__mdt> fldLabels = [SELECT Id, DeveloperName, Label, Field_Name__c, Region__r.Region__c 
                                                         FROM Field_Label_Translations__mdt 
                                                         WHERE 
                                                         Region__c IN (SELECT Id FROM Emaar_Region__mdt WHERE Region__c =:orgId) ];
        for(Field_Label_Translations__mdt setting : fldLabels){
            resultMap.put(setting.Field_Name__c, setting.Label);
        }                                                         
        return resultMap;
    }

    /* 
        Method Name : getFieldNameToFieldLabelMap
        Description : Update user field that always redirect to lightning
        Date        : 07/08/2018
        Author      : Adeel Ahmad (4C)
    */  
    public static void UpdateUserPreferences(Boolean isLightning){
        User u = [SELECT Id, UserPreferencesLightningExperiencePreferred FROM user WHERE id = :UserInfo.getUserId() ];
        u.UserPreferencesLightningExperiencePreferred = isLightning;
        update u;
    }


}