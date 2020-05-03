/**
* @who     : Sri vijitha (sri.mutyala@weare4c.com)
* @when    : 06/03/2019
* @what    : Controller for the broker onboarding functionality - account, contact and documents
*/

public without sharing class BrokerRegistrationController{
    
    public Account accountRecord{get;set;}
    public List<ContactWrapper> contactWrapperList{get;set;}
    private String accountId {get; set;} 
    public Integer currentTabId {get; set;}
   
    public Boolean canEditBasicInfo {get; set;}
    public Boolean canEditPersonnelInfo {get; set;}
    public Boolean canEditDocumentation {get; set;}
    public Decimal totalShareholding {get;set;}
    
     /* Related Documents Variables */
    public List<Document__c> docLists{get;set;}
    public Integer supportId {get; set;}
    public List<wrapperUpload> wrapperUploadList{get;set;}
    public MAP<String, LIST<wrapperUpload>> objectTitleToLISTWrapperMap {get; set;}
    
    public Integer selectedAgentIndex {get; set;}
    
    public LIST<String> userContactRoles {get; set;}
    
    private Id AGENT_REC_TYPEID = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact' AND DeveloperName = 'Broker_Agent'].Id;        
    public AccountWrapper account {get; set;}
    
 
/************************************************************************************
Constructor :   BrokerRegistrationController
Author      :   Sri vijitha (sri.mutyala@weare4c.com)
Description :   Constructor of class
Created Date:   06/03/2019
*************************************************************************************
*/
   
    public BrokerRegistrationController(){
        try{
            account = new AccountWrapper();
            //If user has already account id which is sent through email, then populate the information from saved record based on Id provided.
            if(ApexPages.currentPage().getParameters().get('id') != null){
                String encodeAccountId=  ApexPages.currentPage().getParameters().get('id');
                Blob decodeString = EncodingUtil.base64Decode(encodeAccountId);
                accountId =decodeString.toString() ;
                accountRecord = [SELECT Id, Name, cm_Country_Of_Incorporation__c , cm_Trade_License_Expiry_Date__c, Acccount_Status__c,Sole_Proprietorship_LLC__c, VAT_Registration_No__c, 
                                 cm_Date_of_Incorporation__c, cm_Trade_License_Number__c, Agency_Name__c, Address_Line_1__c, Address_Line_2__c,Site_Page_Indicator__c, ORN_No__c,   
                                 BillingStreet, BillingCity, BillingCountry, BillingPostalCode, Phone, Email__c, Short_Name__c, P_O_Box_Zip_Postal_Code__c, Shipping_country__c, 
                                 cm_Phone_Number__c, cm_Phone_Country_Code__c, Corporate_Email__c, Corporate_Phone_Country_Code__c, Corporate_Phone__c,
                                 Emirate__c, IBAN_Number__c, Swift_Code__c, Bank_Branch__c, Oracle_Account_Number__c, Bank_Name__c, isPersonAccount, Beneficiary_Name__c, Bank_Country__c, 
                                 Bank_Address__c,RERA_No__c, RERA_Card_Expiry_Date__c, cm_P_O_Box__c, Zip_Postal_Code__c FROM Account WHERE Id =:accountId];
                if(accountRecord != null){
                    setAccountRecordFromWrapper(accountRecord);
                }                                     
            }else{ 
                Id recordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'Broker_Account'].Id;        
                accountRecord = new Account();    
                accountRecord.Self_Registration__c = true;    
                accountRecord.Site_Page_Indicator__c = 1;
                accountRecord.Acccount_Status__c = 'Draft';
                accountRecord.RecordTypeId = recordTypeId;            
            }
            //Populate contacts/agents
        contactWrapperList = new LIST<ContactWrapper>();
        if(accountRecord.Id != null){
            Integer i = 1;
            for(Contact c : [SELECT Id,Title,Salutation,firstName,lastName,cm_Nationality__c,
                             Email,MobilePhone,cm_Passport_Number__c,cm_Passport_Expiry_Date__c,Shareholding__c,
                             AccountId, Job_Title__c, IsPrimaryRepresentative__c, Role__c 
                             FROM Contact WHERE AccountId =:accountRecord.Id]){
                ContactWrapper cWrp = new ContactWrapper();
                cWrp.con = c;
                cWrp.isPrimary = c.IsPrimaryRepresentative__c;
                cWrp.PassportExpiryDate = c.cm_Passport_Expiry_Date__c != null ? c.cm_Passport_Expiry_Date__c.format() : '';
                cWrp.index = i;
                LIST<String> selectedRoles = c.Role__c.split(';');
                cWrp.picklistWrp = contactRoleList(selectedRoles);
                contactWrapperList.add(cWrp);
                i++;    
            }
            if(contactWrapperList.size() == 0){
                addAgent();
            }
        }else{
            //POpulate one 1 agent
            addAgent();
        }

        objectTitleToLISTWrapperMap = new MAP<String, LIST<wrapperUpload>>();
        wrapperUploadList = new List<wrapperUpload>();
        if(accountId != null){
           docLists();                
        }
        populateEditIdentifier();

        //Getting User Contact Roles
        userContactRoles = new LIST<String>();
        Schema.DescribeSObjectResult objSchema = Contact.sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objSchema.fields.getmap();
        List<Schema.Picklistentry>fld =fieldmap.get('Role__c').getDescribe().getpicklistValues();
        for(Schema.Picklistentry pl : fld){
            userContactRoles.add(pl.getValue());
        }
        
        totalShareholding = 0.0;
        }
        catch(Exception ex){
            System.debug('****** Exception Caught :   '+ex.getMessage());
            System.debug('****** Exception Caught on line :   '+ex.getLineNumber());
        }
       
    }
    
    //Method which will set the boolean variable, enable user to edit or disallow editing of fields
    public void populateEditIdentifier(){
        try{
        canEditBasicInfo = true;
        canEditPersonnelInfo = true;
        canEditDocumentation = true;
        if(accountRecord.Site_Page_Indicator__c == 1){
            canEditBasicInfo = true;
            canEditPersonnelInfo = false;
            canEditDocumentation = false;            
        }else if(accountRecord.Site_Page_Indicator__c == 2){
            canEditBasicInfo = false;
            canEditPersonnelInfo = true;
            canEditDocumentation = false;                        
        }else if(accountRecord.Site_Page_Indicator__c == 3){
            canEditBasicInfo = false;
            canEditPersonnelInfo = false;
            canEditDocumentation = true;                        
        }
            if(String.isNotBlank(accountRecord.Acccount_Status__c) && accountRecord.Acccount_Status__c == 'Document Verification Pending'){
            canEditBasicInfo = false;
            canEditPersonnelInfo = false;
            canEditDocumentation = false;                        
        }
        } catch(Exception ex){
            System.debug('****** Exception Caught :   '+ex.getMessage());
            System.debug('****** Exception Caught on line :   '+ex.getLineNumber());
        }
        
    }
    
      
    public void docLists(){ 
        try{
        LIST<Contact> contacts = [SELECT Id FROM Contact WHERE AccountId =:accountId];
        if(accountId != null){
           String query = 'SELECT id,Account__c,Contact__c,Account__r.Name,Contact__r.Name,Name__c,Accepted__c,'+
                          'Rejection_Reason__c,Receipt_Status__c,Required_Broker_Document__c,'+
                          '(SELECT Id, Name, ParentId  FROM Attachments order by createddate desc limit 1) '+
                          'FROM Document__c WHERE Account__r.id =:accountId OR Contact__c IN:contacts';
            Integer i = 1;
           for(Document__c suportDocu : Database.query(query)){       
               wrapperUpload newObj = new wrapperUpload();
               newObj.supportObj = suportDocu;
               newObj.Attachment = new Attachment();
               if(suportDocu.Attachments.size()>0){
                   newObj.Attachment = suportDocu.Attachments;
                   newObj.Attachment.body = null;
               }
               if(suportDocu.Contact__r != null){
                   newObj.title = suportDocu.Contact__r.Name;                
                   newObj.recordId = suportDocu.Contact__r.Id;
               }else{
                   newObj.title = suportDocu.Account__r.Name; //Concatinated special character to sort the list.  
                   newObj.recordId = suportDocu.Account__r.Id;              
               }

               newObj.index = i;
               wrapperUploadList.add(newObj);
               i++;
           } 
           wrapperUploadList.sort();
        }

        for(wrapperUpload wrp : wrapperUploadList){
            LIST<wrapperUpload> wrpList = objectTitleToLISTWrapperMap.get(wrp.recordId) == null ? new LIST<wrapperUpload>() : objectTitleToLISTWrapperMap.get(wrp.recordId);
            wrpList.add(wrp);
            objectTitleToLISTWrapperMap.put(wrp.recordId, wrpList);
        }
        }
        catch(exception ex){
          system.debug('*****Exception caught'+ex.getMessage());  
          system.debug('*****Exception Line number'+ex.getLineNumber());
        }
    }

    
      public PageReference upload(){
          try{
        List<Document__c> sdocList = new List<Document__c>();
        List<Attachment> attachmentList = new List<Attachment>();     

        wrapperUpload docLists = new wrapperUpload();
        for(wrapperUpload wrp : wrapperUploadList){
            if(wrp.index == supportId){
                docLists = wrp;
                break;
            }
        }
        List<Attachment> attList = [Select ID, ParentID, body, Name from Attachment Where parentID =: docLists.supportObj.id and id != :docLists.Attachment.id];
       
        if(attList.size()>0){
            delete attList;
        }
                
        if(docLists.Attachment.body != null){
            if(docLists.Attachment.parentId == null){
                docLists.Attachment.parentId = docLists.supportObj.id;
            }
          // docLists.supportObj.SendMail__c = true;
            docLists.supportObj.Accepted__c = null;
            docLists.supportObj.Rejection_Reason__c = null;
            docLists.supportObj.Receipt_Status__c = 'Yes';
            attachmentList.add(docLists.Attachment);
            sdocList.add(docLists.supportObj);
        }
                
       
              if(attachmentList.size()>0){
                  try{
                      upsert attachmentList;
                      upsert sdocList;
                      for(wrapperUpload wrp : wrapperUploadList){
                          if(wrp.index == supportId){
                              wrp.Attachment.body = null;
                          }
                      }
                  }catch(exception e) {
                      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment: '+e));
                      return null;
                  }
              }
          }
          catch(exception ex){
              system.debug('*****Exception caught:'+ex.getMessage());
              system.debug('*****Exception Line number:'+ex.getLineNumber());
          }
          
          return null;
      } 

    
/************************************************************************************
Method      :   saveAndNext
Author      :   Sri vijitha (sri.mutyala@weare4c.com)
Description :   Method to save the account and proceed to next step based on site page indicator
Created Date:   11/03/2019
*************************************************************************************
*/
    public PageReference saveAndNext(){
        PageReference pr;
        try{
            //First insert account.
            createAccountRecordFromWrapper(account);
            
            //Setting up the owner Id
            accountRecord.OwnerId = '0051r000007gKz7';                        
            accountRecord.Site_Page_Indicator__c = 2;
            
            //populate account's custom billing country to the standard field - billing country
            //accountRecord.shippingCountry = account.selectedShipping_Country;
            //accountRecord.billingCity = account.Billing_City;
            upsert accountRecord;
            
            populateEditIdentifier();
            pr = Page.BrokerRegistration;
            String accountRecordId =accountRecord.Id;
            Blob blobData=Blob.valueOf(accountRecordId);
            String encodedAccId = EncodingUtil.base64Encode(blobData);
            pr.getParameters().put('Id',encodedAccId);
            pr.setRedirect(true);
          }catch(DmlException e){
            accountRecord.Site_Page_Indicator__c = 1;
           // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            ApexPages.addMessages(e); 
            pr = null;
        }
        return pr;
    }
    
     /************************************************************************************
    Method      :   saveAndExit
    Author      :   Sri vijitha (sri.mutyala@weare4c.com)
    Description :   Method to save the account record and send the email notification to user.
    Created Date:   13/03/2019
    *************************************************************************************
    */
    public PageReference saveAsDraft(){
        PageReference pr;
        try{
            accountRecord.Site_Page_Indicator__c = 1;
            createAccountRecordFromWrapper(account);
            
            if(accountRecord.Id == null){
            accountRecord.Saved_as_Draft__c = true;
            }
            
            upsert accountRecord;
            accountId = accountRecord.Id;
            String accountRecordId =accountRecord.Id;
            Blob blobData=Blob.valueOf(accountRecordId);
            String encodedAccId = EncodingUtil.base64Encode(blobData);
            pr = Page.BrokerRegistration;
            pr.getParameters().put('Id',encodedAccId );
            pr.setRedirect(true);
            /* TODO: Send email alert to user */
        }catch(DmlException e){
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            ApexPages.addMessages(e);
            pr = null;
        }
        return pr;
    }

    /************************************************************************************
    Method      :   addAgent
    Author      :   Sri vijitha (sri.mutyala@weare4c.com)
    Description :   Method to insert new contact to contact wrapper
    Created Date:   17/03/2019
    *************************************************************************************
    */
    public void addAgent(){
        ContactWrapper cWrp = new ContactWrapper();
        cWrp.con = new Contact(RecordTypeId = AGENT_REC_TYPEID);
        cWrp.isPrimary = false;
        cWrp.index = contactWrapperList.size()+1;
        cWrp.picklistWrp = contactRoleList(new LIST<String>());
        contactWrapperList.add(cWrp);
    }
    
     private LIST<PicklistWrapper> contactRoleList(LIST<String> selectedRoles){
        LIST<PicklistWrapper> picklistValues = new List<PicklistWrapper>();    
        Schema.DescribeFieldResult fieldResult = Contact.Role__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            PicklistWrapper wrp = new PicklistWrapper();
            wrp.value = f.getLabel();
            wrp.isSelected = selectedRoles.contains(f.getValue()) ? true : false;
            String helpText = '';
            if(f.getValue() == 'Admin'){
                helpText = 'Broker_Agent_Admin_Help_Text';
            }else if(f.getValue() == 'Authorized Officer'){
                helpText = 'Broker_Agent_Authorized_Officer_Help_Text';
            }else if(f.getValue() == 'Sales'){
                helpText = 'Broker_Agent_Sales_Help_Text';
            }else if(f.getValue() == 'Owner'){
                helpText = 'Broker_Agent_Owner_Help_Text';
            }
            wrp.helpText = helpText;
            picklistValues.add(wrp);
        } 
        return picklistValues;
    }
    
    
      /************************************************************************************
    Method      :   deleteAgent
    Author      :   Sri vijitha (sri.mutyala@weare4c.com)
    Description :   Method to delete agent from wrapper list
    Created Date:   17/03/2019
    *************************************************************************************
    */
    public void deleteAgent(){
        Id agentId = null;
        LIST<ContactWrapper> remainingAgents = new LIST<ContactWrapper>();
        for(ContactWrapper wrp : contactWrapperList){
            if(wrp.index != selectedAgentIndex){
                remainingAgents.add(wrp);
            }

            if(wrp.index == selectedAgentIndex && wrp.con.Id != null){
                agentId = wrp.con.Id;
            }
        }
        contactWrapperList.clear();
        contactWrapperList.addAll(remainingAgents);
        if(agentId != null){
            LIST<Contact> deleteable = [SELECT Id FROM Contact WHERE Id=:agentId];
            DELETE deleteable;
        }
        selectedAgentIndex = null;
    }

    
    
    /************************************************************************************
    Method      :   saveAgents
    Author      :   Sri vijitha (sri.mutyala@weare4c.com)
    Description :   Method to save agents(contacts) extracted from contact's wrapper class
    Created Date:   18/03/2019
    Updated     :   Added method to check for existing email. If email already exist then show user error message and not allow to proceed.
    *************************************************************************************
    */   
    public PageReference saveAgents(){
        PageReference pr;
        LIST<Contact> contacts = new LIST<Contact>();        
        Decimal totalShareholding = 0.0;
        MAP<String, Decimal> emailToContactIndexMap = new MAP<String, Decimal>();
        Boolean emailAlreadyExist = false;

        for(ContactWrapper cWrp : contactWrapperList){
            emailToContactIndexMap.put(cWrp.con.Email, cWrp.index);
        }
        MAP<String, Boolean> emailToBooleanMap = checkExistingEmails(contactWrapperList);
        for(String s : emailToBooleanMap.keySet()){
            Boolean isEmailExist = emailToBooleanMap.get(s);
            if(isEmailExist == true){
                Decimal contactWrapperIndex = emailToContactIndexMap.get(s);
                for(ContactWrapper c : contactWrapperList){
                    if(c.index == contactWrapperIndex){
                        c.con.Email.addError('Broker_Email_Exist_Error_Message');
                        break;
                    }
                }
                emailAlreadyExist = true;
            }
        }

        for(ContactWrapper wrp : contactWrapperList){
            if(wrp.con.AccountId == null){
                wrp.con.AccountId = accountRecord.Id;
            }
            wrp.con.IsPrimaryRepresentative__c = wrp.isPrimary;
            wrp.con.Role__c = getSelectedRoles(wrp.picklistWrp);
            if(wrp.PassportExpiryDate != null){
                wrp.con.cm_Passport_Expiry_Date__c = String.isNotBlank(wrp.PassportExpiryDate) ? Date.parse(wrp.PassportExpiryDate) : null;
            }
            contacts.add(wrp.con);
            if(wrp.con.Shareholding__c != null)
                totalShareholding = totalShareholding + wrp.con.Shareholding__c;
        }

        if(emailAlreadyExist){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Broker_Email_Exist_Error_Message')); 
            pr = null;
        }else{
            try{
                if(totalShareholding == 100.00){
                    upsert contacts;
        
                    //update the status
                    accountRecord.Site_Page_Indicator__c = 3;
                    upsert accountRecord;
                    
                    docLists();
                    populateEditIdentifier();
                    pr = Page.BrokerRegistration;
                    String accountRecordId =accountRecord.Id;
                    Blob blobData=Blob.valueOf(accountRecordId);
                    String encodedAccId = EncodingUtil.base64Encode(blobData);
                    pr.getParameters().put('Id',encodedAccId );
                    pr.setRedirect(true);
                }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Contact_Shareholding')); 
                    pr = null;
                }
            }catch(DmlException e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));            
                pr = null;
            }            
        }
        return pr;
    }

    //  - Updating check for email from user to contact.
    private MAP<String, Boolean> checkExistingEmails(LIST<ContactWrapper> conWrapper){
        MAP<String, Boolean> emailToExistingBooleanMap = new MAP<String, Boolean>();
        LIST<String> inputEmailList = new LIST<String>();
        for(ContactWrapper wrp : conWrapper){
            emailToExistingBooleanMap.put(wrp.con.Email, false);
        }

        for(Contact c : [SELECT Id, Email FROM Contact WHERE Email =:emailToExistingBooleanMap.keySet() AND RecordTypeId =:AGENT_REC_TYPEID]){
            emailToExistingBooleanMap.put(c.Email, true);
        }
        return emailToExistingBooleanMap;
    }


    private String getSelectedRoles(LIST<PicklistWrapper> picklistvalues){
        String selectedRoles = '';
        for(PicklistWrapper p : picklistValues){
            if(p.isSelected == true){
                selectedRoles += p.value + ';';
            }
        }
        if(String.isNotBlank(selectedRoles)){
            selectedRoles = selectedRoles.removeEnd(';');
        }
        return selectedRoles;
    }
    
      /************************************************************************************
    Method      :   submitBroker
    Author      :   Sri vijitha (sri.mutyala@weare4c.com)
    Description :   Method to submit broker for approval
    Created Date:   18/03/2019
    *************************************************************************************
    */
    public PageReference submitBroker(){
        PageReference pr;
        try{
            accountRecord.Acccount_Status__c = 'Document Verification Pending';
            accountRecord.Site_Page_Indicator__c = 1;
            upsert accountRecord;
            
            //[05/03/2019] : To delete the documents which do not have attachments
            Map<Id,Document__c> docAccountMap = new Map<Id,Document__c>([select id, Account__c from Document__c where Account__c =: accountRecord.Id]);
                            
            List<Attachment> attachmentList = [Select ID, ParentID, body, Name from Attachment Where parentID in: docAccountMap.keySet()];
            Map<Id,Attachment> attachmentAccountMap = new Map<Id,Attachment>();
            
            for(Attachment attachRec : attachmentList){
                attachmentAccountMap.put(attachRec.parentId, attachRec);
            }
            
            List<Document__c> docToDeleteSet = new List<Document__c>();
            
            for(Document__c docRec : docAccountMap.values()){
                if(!attachmentAccountMap.containsKey(docRec.Id)){
                    docToDeleteSet.add(docRec);
                }
            }
            
            if(docToDeleteSet.size() > 0){
                delete docToDeleteSet;              
            }
            
            //
            
            pr = new PageReference('/apex/BrokerRegistration');
            String accountRecordId =accountRecord.Id;
            Blob blobData=Blob.valueOf(accountRecordId);
            String encodedAccId = EncodingUtil.base64Encode(blobData);
            pr.getParameters().put('id',encodedAccId );
            pr.getParameters().put('success', '1');
            pr.setRedirect(true);
        }catch(DmlException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));                        
            pr = null;
        }
        return pr;
    }      

    /************************************************************************************
    Method      :   navigateToTab
    Author      :   Sri vijitha (sri.mutyala@weare4c.com)
    Description :   Method which enables user to navigate between tabs
    Created Date:   19/03/2019
    *************************************************************************************
    */
    public void navigateToTab(){

    }   

    /************************************************************************************
    Class       :   searchExistingTradeLicense
    Author      :   Sri vijitha (sri.mutyala@weare4c.com)
    Description :   Remote method to find existing trade license with number that user provided.
    @Returns    :   Return 0 if account doesn't exist and 1 if account with same trade license exists.
    Created Date:   19/03/2019
    *************************************************************************************
    */
    @RemoteAction
    public static Decimal searchExistingTradeLicense(String tradeLisenceNo) {
        List<Account> accounts = [select id,cm_Trade_License_Number__c from account where cm_Trade_License_Number__c =: tradeLisenceNo];
        return accounts.size();
    }


    /************************************************************************************
    Class       :   searchShortName
    Author      :   Sri vijitha (sri.mutyala@weare4c.com)
    Description :   Remote method to find existing trade license with number that user provided.
    @Returns    :   Return 0 if account doesn't exist and 1 if account with same trade license exists.
    Created Date:   19/03/2019
    *************************************************************************************
    */
    @RemoteAction
    public static Decimal searchShortName(String agencyShortName) {
        List<Account> accounts = [select id,Short_Name__c  from account where Short_Name__c =: agencyShortName];
        return accounts.size();
    }
    
    
      /************************************************************************************
    Class       :   ContactWrapper
    Author      :   Sri vijitha (sri.mutyala@weare4c.com)
    Description :   Wrapper class for contact records.
    Created Date:   19/03/2019
    *************************************************************************************
    */
    public class ContactWrapper{
        public Contact con {get; set;}
        public Boolean isPrimary {get; set;}
        public Decimal index {get; set;}
        public String PassportExpiryDate {get; set;}
        public LIST<PicklistWrapper> picklistWrp {get; set;}
    }
    
     /************************************************************************************
    Class       :   DocumentsWrapper
    Author      :   Sri vijitha (sri.mutyala@weare4c.com)
    Description :   Wrapper class for contact records.
    Created Date:   19/03/2019
    *************************************************************************************
    */
    public class DocumentsWrapper{
        public Document__c doc{get;set;}
        public Attachment att{get;set;}
    } 
    
         
     /************************************************************************************
    Class       :   wrapperUpload
    Author      :   Sri vijitha (sri.mutyala@weare4c.com)
    Description :   Wrapper class for contact records.
    Created Date:   17/03/2019
    *************************************************************************************
    */
    public class wrapperUpload implements Comparable{
        public Document__c supportObj{get;set;}
        public Attachment Attachment{get;set;}
        public String title {get; set;}
        public Integer index {get; set;}
        public Id recordId {get; set;}
        public Integer compareTo(Object o)
        {
            wrapperUpload compareableWrp = (wrapperUpload)(o);
            
            if (this.title < compareableWrp.title) {
                return -1;
            }
            return 0;
        }
    }  

      public class PicklistWrapper {
        public String value {get;set;}
        public Boolean isSelected {get;set;}
        public String helpText {get; set;}
        public PicklistWrapper(){}

        public PicklistWrapper(String value, Boolean isSelected) {
            this.value = value;
            this.isSelected = isSelected;
        }
    }
    
      public class AccountWrapper{
        public String Name {get; set;}
        public String TradeLicenseNo {get; set;}
        public String Agency_Name {get; set;}
        public String TradeLicenseExpiryDate {get; set;}
        public LIST<selectOption> Agency_Type {get; set;}
        public String selectedAgency_Type {get; set;}
        public LIST<selectOption> CountryofIncorporation {get; set;}
        public String selectedCountryofIncorporation {get; set;}
        public LIST<SelectOption> UAE_Emirate {get; set;}
        public String selectedUAE_Emirate {get; set;}
        public String DateofIncorporation {get; set;}
        public String ORN_Number {get; set;}
        public Decimal VAT {get; set;}
        public String RERANo {get; set;}
        public String RERA_Expiry_Date {get; set;}
        public String Address1 {get; set;}
        public String Address2 {get; set;}
        public String ShortName {get; set;}
        public LIST<SelectOption> Shipping_Country {get; set;}
        public String selectedShipping_Country {get; set;}
        public LIST<SelectOption> P_O_Box_ZIP {get; set;}
        public String selectedP_O_Box_ZIP {get; set;}
        public String Billing_City {get; set;}
        public String Second_Billing_Address {get; set;}
        public String CompanyRepresentativeEmail {get; set;}
        public String CompanyRepresentativeMobile {get; set;}
        public String P_O_Box {get; set;}
        public string Zip_Postal{get;set;}
        public String PhoneNumber {get; set;}
        public String Email {get; set;}
        public String BillingPostalCode {get; set;}
        public String Beneficiary_Name {get; set;}
        public String Bank_Account_Number {get;set;}
        public String Bank_Name {get; set;}
        public String Bank_Address {get; set;}
        public String Bank_Branch {get; set;}
        public LIST<SelectOption> Bank_Country {get; set;}
        public String selectedBank_Country {get; set;}
        public String Swift_code {get; set;}
        public String IBAN_number {get; set;}
        public Decimal Site_Page_Indicator {get; set;}
        public String TaxRegistrationNumber {get; set;}
        
        public AccountWrapper(){
            Agency_Type = PopulateSelectOptions('Sole_Proprietorship_LLC__c');
            CountryofIncorporation = PopulateSelectOptions('cm_Country_Of_Incorporation__c');
            Shipping_Country = PopulateSelectOptions('Shipping_country__c');
            P_O_Box_ZIP = PopulateSelectOptions('P_O_Box_Zip_Postal_Code__c');
            UAE_Emirate = PopulateSelectOptions('Emirate__c');
            Bank_Country = PopulateSelectOptions('Bank_Country__c');
        }
        public LIST<SelectOption> PopulateSelectOptions(String fieldName){
            LIST<SelectOption> options = new LIST<SelectOption>();
            options.add(new SelectOption('','--None--'));
            DescribeSObjectResult accountDescribe = SObjectType.Account;
            accountDescribe = Schema.Account.sObjectType.getDescribe();
            Map<String, Schema.SObjectField> fieldMap = accountDescribe.fields.getmap();
            List<Schema.Picklistentry>fld =fieldmap.get(fieldName).getDescribe().getpicklistValues();
            for(Schema.Picklistentry pl : fld){
                options.add(new SelectOption(pl.getValue(),pl.getLabel()));
            }
        
            return options;
        }
        
    } 
    
    public void setAccountRecordFromWrapper(Account selectedAccount){
        try{
        account.Name = selectedAccount.Name; 
        account.TradeLicenseNo = selectedAccount.cm_Trade_License_Number__c;
        account.Agency_Name = selectedAccount.Agency_Name__c;
        account.TradeLicenseExpiryDate = selectedAccount.cm_Trade_License_Expiry_Date__c != null ? selectedAccount.cm_Trade_License_Expiry_Date__c.format() : '';
        account.selectedAgency_Type = selectedAccount.Sole_Proprietorship_LLC__c;
        account.selectedCountryofIncorporation = selectedAccount.cm_Country_Of_Incorporation__c;
        account.selectedUAE_Emirate = selectedAccount.Emirate__c;
        account.DateofIncorporation = selectedAccount.cm_Date_of_Incorporation__c!= null ? selectedAccount.cm_Date_of_Incorporation__c.format() : '';
        //account.DateofIncorporation = selectedAccount.cm_Date_of_Incorporation__c;
        account.ORN_Number = selectedAccount.ORN_No__c ;
        account.VAT = Decimal.ValueOf(selectedAccount.VAT_Registration_No__c);
        account.RERANo = selectedAccount.RERA_No__c;
        account.RERA_Expiry_Date = selectedAccount.RERA_Card_Expiry_Date__c != null ? selectedAccount.RERA_Card_Expiry_Date__c.format() : '';
        account.ShortName = selectedAccount.Short_Name__c ;
        account.Address1 = selectedAccount.Address_Line_1__c ;
        account.Address2 = selectedAccount.Address_Line_2__c ;
        account.PhoneNumber = selectedAccount.cm_Phone_Number__c ;
        account.Email = selectedAccount.Email__c ;
        //account.Billing_City = selectedAccount.BillingCity;
        account.selectedShipping_Country = selectedAccount.Shipping_country__c;
        account.selectedP_O_Box_ZIP = selectedAccount.P_O_Box_Zip_Postal_Code__c;
        
        //account.Second_Billing_Address = selectedAccount.Second_Billing_Address__c;
        //account.CompanyRepresentativeEmail = selectedAccount.CompanyRepresentativeEmail__c;
        //account.CompanyRepresentativeMobile = selectedAccount.CompanyRepresentativeMobile__c;
        
        account.Zip_Postal = selectedAccount.Zip_Postal_Code__c;
        account.P_O_Box = selectedAccount.cm_P_O_Box__c;
        account.BillingPostalCode = selectedAccount.BillingPostalCode;
        account.Beneficiary_Name = selectedAccount.Beneficiary_Name__c;
        account.Bank_Account_Number = selectedAccount.Oracle_Account_Number__c;
        account.Bank_Name = selectedAccount.Bank_Name__c;
        account.Bank_Address = selectedAccount.Bank_Address__c;
        account.Bank_Branch = selectedAccount.Bank_Branch__c;
        account.selectedBank_Country = selectedAccount.Bank_Country__c;
        account.Swift_code = selectedAccount.Swift_Code__c;
        account.IBAN_number = selectedAccount.IBAN_Number__c;
        account.Site_Page_Indicator = selectedAccount.Site_Page_Indicator__c;
       // account.TaxRegistrationNumber = String.ValueOf(selectedAccount.Tax_Registration_No__c);
        } catch(Exception ex){
            System.debug('****** Exception Caught :   '+ex.getMessage());
            System.debug('****** Exception Caught on line :   '+ex.getLineNumber());
        }
    }
       
     
    public void createAccountRecordFromWrapper(AccountWrapper acc){
        try{
        accountRecord.Name =  acc.Name; 
        accountRecord.cm_Trade_License_Number__c  =  acc.TradeLicenseNo;
        accountRecord.Agency_Name__c =  acc.Agency_Name;
        accountRecord.cm_Trade_License_Expiry_Date__c  =  String.isNotBlank(acc.TradeLicenseExpiryDate) ? Date.parse(acc.TradeLicenseExpiryDate) : null;
        accountRecord.Sole_Proprietorship_LLC__c  =  acc.selectedAgency_Type;
        accountRecord.cm_Country_Of_Incorporation__c  =  acc.selectedCountryofIncorporation;
        accountRecord.Emirate__c =  acc.selectedUAE_Emirate;
        accountRecord.cm_Date_of_Incorporation__c = String.isNotBlank(acc.DateofIncorporation) ? Date.parse(acc.DateofIncorporation) : null;
        //accountRecord.cm_Date_of_Incorporation__c = Date.ValueOf(acc.DateofIncorporation);
        accountRecord.ORN_No__c  =  acc.ORN_Number;
        accountRecord.VAT_Registration_No__c =  String.ValueOf(acc.VAT);
        accountRecord.RERA_No__c  =  acc.RERANo;
        accountRecord.RERA_Card_Expiry_Date__c =  String.isNotBlank(acc.RERA_Expiry_Date) ? Date.parse(acc.RERA_Expiry_Date) : null;
        accountRecord.Address_Line_1__c  =  acc.Address1;
        accountRecord.Address_Line_2__c  =  acc.Address2;
        accountRecord.Short_Name__c  =  acc.ShortName;
        accountRecord.BillingCity =  acc.Billing_City;
        accountRecord.Shipping_country__c  =  acc.selectedShipping_Country;
        accountRecord.P_O_Box_Zip_Postal_Code__c  =  acc.selectedP_O_Box_ZIP;         
        accountRecord.cm_P_O_Box__c  =  acc.P_O_Box;
        accountRecord.Zip_Postal_Code__c  =  acc.P_O_Box;    
        accountRecord.Email__c  =  acc.Email;
        accountRecord.cm_Phone_Number__c  =  acc.PhoneNumber;       
       
        // accountRecord.Second_Billing_Address__c =  acc.Second_Billing_Address;
        // accountRecord.CompanyRepresentativeEmail__c =  acc.CompanyRepresentativeEmail;
        // accountRecord.CompanyRepresentativeMobile__c =  acc.CompanyRepresentativeMobile;
       
        accountRecord.Beneficiary_Name__c =  acc.Beneficiary_Name;
        accountRecord.Oracle_Account_Number__c =  acc.Bank_Account_Number;
        accountRecord.Bank_Name__c =  acc.Bank_Name;
        accountRecord.Bank_Address__c =  acc.Bank_Address; 
        accountRecord.Bank_Branch__c =  acc.Bank_Branch;
        accountRecord.Bank_Country__c =  acc.selectedBank_Country;
        accountRecord.Swift_Code__c =  acc.Swift_code;
        accountRecord.IBAN_Number__c =  acc.IBAN_number;
       // accountRecord.Tax_Registration_No__c = Integer.ValueOf(acc.TaxRegistrationNumber); 
         //insert accountRecord;
        }catch(Exception ex){
            System.debug('****** Exception Caught :   '+ex.getMessage());
            System.debug('****** Exception Caught on line :   '+ex.getLineNumber());
        }
    }   
}