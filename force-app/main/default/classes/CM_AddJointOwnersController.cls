public class CM_AddJointOwnersController{
    public Opportunity opp{get; set;}
    public integer selIndex{get; set;}
    public List<BuyerWrapper> lstwrap{get; set;}
    public string strOpporId ='';
    public string selectedId {get;set;}
    public ApexPages.StandardSetController con{get; set;}
    public List<Opportunity> lstOpp = new List<Opportunity>();
    public List<Opportunity_Property__c> lstPro = new List<Opportunity_Property__c>();
    
    public CM_AddJointOwnersController(ApexPages.StandardController sc){
        strOpporId = apexpages.currentPage().getParameters().get('Id');
        lstwrap = new List<BuyerWrapper>();
        lstOpp =[select AccountId from opportunity where id=:strOpporId];
        lstPro = [Select id, cm_opportunity__c,cm_opportunity__r.Account.party_Id__c, Sales_Order__c from Opportunity_Property__c where cm_Opportunity__c in: lstOpp];
        PrepareData();
    }
    
    // Method to prepare data
    public void PrepareData(){
       lstwrap = new List<BuyerWrapper>(); 
        list<Joint_Owner__c> lstJoiintOwners = [select id,name,cm_Joint_Owner__c,cm_Joint_Owner__r.Name,cm_Nationality__c,cm_Phone__c,
                                                cm_Preferred_Language__c,cm_Related_Opportunity__c,Country__c,Passport_Number__c from Joint_Owner__c where cm_Related_Opportunity__c=:strOpporId order by createddate];
        if(lstJoiintOwners!=null && lstJoiintOwners.size() >0){
            integer i = 0;
            for(Joint_Owner__c objJoint:lstJoiintOwners){
               BuyerWrapper objBuyerWrapper = new BuyerWrapper();
               objBuyerWrapper.jOwn = objJoint;
               objBuyerWrapper.strAccountName = objJoint.cm_Joint_Owner__r.Name;
               objBuyerWrapper.strNationality = objJoint.cm_Nationality__c;
               objBuyerWrapper.strAccountPhone = objJoint.cm_Phone__c;
               objBuyerWrapper.strLanguage = objJoint.cm_Preferred_Language__c;
               objBuyerWrapper.strBillingCountry = objJoint.Country__c;
               objBuyerWrapper.strPassportNo = objJoint.Passport_Number__c;
               objBuyerWrapper.index = i;
               lstwrap.add(objBuyerWrapper);
               i = i+1;
            }
        }else{
              BuyerWrapper objBuyerWrapper = new BuyerWrapper();
              objBuyerWrapper.jOwn = new Joint_Owner__c();
              objBuyerWrapper.jOwn.cm_Related_Opportunity__c = strOpporId;
              objBuyerWrapper.index = 0;
              lstwrap.add(objBuyerWrapper);
        }
    }
    
    // Method to add a row
    public void AddRow(){
          BuyerWrapper objBuyerWrapper = new BuyerWrapper();
          objBuyerWrapper.jOwn = new Joint_Owner__c();
          objBuyerWrapper.jOwn.cm_Related_Opportunity__c = strOpporId;
          objBuyerWrapper.index = lstwrap.size();
          lstwrap.add(objBuyerWrapper);
    }
    
    // Method to remmove a row
    public void removeRow(){
        system.debug('*******selIndex'+selIndex);
        if(selIndex != null){
            if(lstwrap[selIndex].jOwn.id!=null){
                string selId = lstwrap[selIndex].jOwn.id;
                
                joint_Owner__c jOwn = [Select id, Party_ID__c from joint_Owner__c where Id =: selId];
                if(!lstPro.isEmpty() && lstPro[0].Sales_Order__c != null){
           //       emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element resp = EmaarWebServiceUtils.updateJointOwnerService(lstPro[0].Id, lstPro[0].Sales_order__c,'DELETE',lstpro[0].cm_opportunity__r.Account.party_Id__c,jOwn.party_Id__c);
            //      if(resp.status != 'SUCCESS')
              //      ApexPages.AddMessage(new ApexPages.Message(ApexPages.severity.Fatal,resp.ErrorMessage));
                
                
              //    if(!EmaarWebServiceUtils.lstLogs2Insert.isEmpty())
              //  insert EmaarWebServiceUtils.lstlogs2Insert;
                }
                if(!ApexPages.hasMessages()){
                   delete jOwn;
                  lstwrap.remove(selIndex);
                List<BuyerWrapper> lstclone= lstwrap.clone();
                lstwrap = new List<BuyerWrapper>();
                integer i = 0;
                for(BuyerWrapper bw: lstClone){
                    bw.index = i;
                    lstwrap.add(bw);
                    i++;
                }
                }
            }
            
        }
    }
    // Method to saving the records.
    public void saveRecords(){
        Map<id,Id>mapJointOwners = new Map<id,Id>();
        strOpporId = apexpages.currentPage().getParameters().get('Id');
         
        List<Joint_Owner__c> lstdata = [select id,cm_Joint_Owner__c from Joint_Owner__c where cm_Related_Opportunity__c=:strOpporId];
        for(Joint_Owner__c objjont:lstdata){
            mapJointOwners.put(objjont.cm_Joint_Owner__c,objjont.cm_Joint_Owner__c);
        }
        system.debug('*******mapJointOwners'+mapJointOwners);
        set<id> setAccIds = new set<id>();
        for(BuyerWrapper bw: lstWrap){
            setAccIds.add(bw.jOwn.cm_Joint_Owner__c);
        }
        
        //v1.2 Map<Id,Account> mpAccounts = new Map<Id,Account>([Select id, cm_Legally_blocked__c,party_Id__c from Account where id in: setAccIds]);
        //v1.2
        map<Id,Account> mpAccounts = new map<Id,Account>([Select Id,Name,cm_Legally_blocked__c,Party_Id__c,isPersonAccount,recordTypeId,cm_Phone_Country_Code__c,Phone,PersonMobilephone,cm_Mobile_Country_Code__pc,
            cm_Nationality__pc,cm_National_ID_No__pc,cm_Place_Of_Birth__pc,cm_Passport_Number__pc,cm_Gender__pc,MiddleName,Salutation,cm_Country_Of_Incorporation__c,City_of_Incorporation__c,cm_Trade_License_Number__c,
            billingState,BillingStreet,BillingCity,BillingCountry,cm_National_ID_Expiry_Date__pc,cm_Date_of_Incorporation__c,cm_Trade_License_Expiry_Date__c,cm_Visa_Expiry_Date__pc,cm_Passport_Issue_Date__pc,
            cm_Birthdate__pc,cm_Passport_Expiry_Date__pc,PersonEmail,FirstName,LastName,cm_P_O_Box__c,Billingpostalcode,Visa_No__pc,Visa_Issue_Date__pc,Emirate__c,VAT_Registration_No__c
            from Account where Id IN : setAccIds]);
        
        map<Id,Account> mapAccountToUpdate = new map<Id,Account>();
        
        List<Joint_Owner__c> lstOwners = new List<Joint_Owner__c>();
        boolean blnduplicate = false;
        
        list<Account> lstAccounts2Process = new List<Account>();
        for(BuyerWrapper bw: lstWrap){
            system.debug('********AccoutID Val'+bw.jOwn.cm_Joint_Owner__c);
            if(bw.jOwn.cm_Joint_Owner__c == lstOpp[0].AccountId){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'You can not add Opportunity Account as Joint Account.')); 
            }
            else{
              System.debug('>>>>>>>>>>>>else>>>>>>>>>>>>');  
                if(mpAccounts.containsKey(bw.jOwn.cm_Joint_Owner__c) && mpAccounts.get(bw.jOwn.cm_Joint_Owner__c).cm_Legally_blocked__c == false ){
                    System.debug('>>>>>>>>>>>>before>>>>>>>>>>>>');
                    if(bw.jOwn.cm_Joint_Owner__c!= null && bw.jOwn.id!=null && mapJointOwners.get(bw.jOwn.cm_Joint_Owner__c) == null){
                        lstOwners.add(bw.jOwn);
                    }
                    else if(bw.jOwn.cm_Joint_Owner__c!= null && bw.jOwn.Id==null && mapJointOwners.get(bw.jOwn.cm_Joint_Owner__c) == null){
                        lstOwners.add(bw.jOwn);
                    }
                    else if(bw.jOwn.cm_Joint_Owner__c!= null && bw.jOwn.id ==null && mapJointOwners.get(bw.jOwn.cm_Joint_Owner__c) != null){
                        blnduplicate = true;
                        break;
                    }
                    System.debug('>>>>>>>>>>>>after>>>>>>>>>>>>');  
                }
                else{
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'Selected Account is legally blocked'));
                   // return null;
                }
           }
           
           if(mpAccounts.containsKey(bw.jOwn.cm_Joint_Owner__c)){
               lstAccounts2Process.add(mpAccounts.get(bw.jOwn.cm_Joint_Owner__c));
           }
        }
        
        System.debug('>>>>>>>>blnduplicate>>>>>>>>>>>>>>>>'+blnduplicate);
        System.debug('>>>>>>>>lstAccounts2Process>>>>>>>>>>>>>>>>'+lstAccounts2Process);
        if(blnduplicate == true)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Selected Joint Owner already added to Opportunity .'));
        if(blnduplicate ==false){
          System.debug('>>>>>>>>blnduplicate - false>>>>>>>>>>>>>>>>');
          System.debug('>>>>>>>>lstPro>>>>>>>>>>>>>>>>'+lstPro);
          System.debug('>>>>>>>>lstAccounts2Process>>>>>>>>>>>>>>>>'+lstAccounts2Process);
          if(!lstPro.isEmpty() && lstPro[0].Sales_Order__c != null){
            for(Account acc: lstAccounts2Process){
              System.debug('>>>>>>Party ID>>>>>>>>>>>>'+acc.party_Id__c);
              if(acc.party_Id__c != null){
               // emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element resp = EmaarWebServiceUtils.updateJointOwnerService(lstPro[0].Id, lstPro[0].Sales_order__c,'INSERT',lstpro[0].cm_opportunity__r.Account.party_Id__c,acc.party_Id__c);  
               // if(resp.status != 'SUCCESS')
                //  ApexPages.AddMessage(new ApexPages.Message(ApexPages.severity.Fatal,resp.ErrorMessage));
              
              }
              else{
                // v1.2 - Create Party for Joint Owner in ORACLE instead of throwing an error
                //v1.2 ApexPages.AddMessage(new ApexPages.Message(ApexPages.severity.Fatal,'No Party ID found on the selected joint owner. Please contact your System Administrator.'));
                
     /*           String partyXML = EmaarWebServiceUtils.createPartyXML(acc);
                        emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element createPartyResponse = EmaarWebServiceUtils.createORACLEPartyService(partyXML, acc.Id);
                        
                        if (createPartyResponse.Status != 'SUCCESS' && createPartyResponse.Status != ''){
                           //return createPartyResponse.ErrorMessage;
                           ApexPages.AddMessage(new ApexPages.Message(ApexPages.severity.Fatal,createPartyResponse.ErrorMessage));
                        }
                acc.Party_Id__c = createPartyResponse.resultVar3;
                        acc.em_Party_Number__c = CM_EmaarUtils.getValueFromXMLString(createPartyResponse.resultXML,'PARTY_NUMBER');
                
                mapAccountToUpdate.put(acc.Id,new Account(Id=acc.Id,Party_Id__c = acc.Party_Id__c, em_Party_Number__c=acc.em_Party_Number__c));
                
                emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element resp = EmaarWebServiceUtils.updateJointOwnerService(lstPro[0].Id, lstPro[0].Sales_order__c,'INSERT',lstpro[0].cm_opportunity__r.Account.party_Id__c,acc.party_Id__c);  
                if(resp.status != 'SUCCESS')
                  ApexPages.AddMessage(new ApexPages.Message(ApexPages.severity.Fatal,resp.ErrorMessage));    */
                
              }
            }
            
          //  if(!EmaarWebServiceUtils.lstLogs2Insert.isEmpty())
          //    insert EmaarWebServiceUtils.lstlogs2Insert;
          }
          if(!Apexpages.hasMessages()){
            //v1.2
        if(!mapAccountToUpdate.isEmpty())
          update mapAccountToUpdate.values(); //end of v1.2
            if(!lstOwners.isEmpty())
                  upsert lstOwners;
              PrepareData();    
          }
            
        }
        //return new Pagereference('/'+opp.id);
    }
    
    // Method to saving the records.
    public void saveRecords_SF1(){
        system.debug('***selectedId***'+selectedId);
        Map<id,Id>mapJointOwners = new Map<id,Id>();
        strOpporId = apexpages.currentPage().getParameters().get('Id');
        List<Joint_Owner__c> lstdata = [select id,cm_Joint_Owner__c from Joint_Owner__c where cm_Related_Opportunity__c=:strOpporId and cm_Joint_Owner__c =:selectedId];
        if(lstdata!=null && lstdata.size() >0){
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Selected Joint Owner is already added to Opportunity .'));
        }
        else{
        Joint_Owner__c obj = new Joint_Owner__c();
            obj.cm_Related_Opportunity__c = strOpporId;
            obj.cm_Joint_Owner__c = selectedId;
            insert obj;
            PrepareData();
        }
    }
    
    // wrapper class
    public class BuyerWrapper{
        public Joint_Owner__c jOwn{get; set;}
        public integer index{get; set;}
        public string strAccountName{get; set;}
        public string strAccountPhone{get; set;}
        public string strLanguage{get; set;}
        public string strNationality{get; set;}
        public String strBillingCountry{get;set;}//v1.1
        public String strPassportNo{get;set;}//v1.1
    }
    
    public Pagereference CheckAgent(){
        String userAgent = ApexPages.currentPage().getHeaders().get('User-Agent');
        system.debug('****userAgent'+userAgent);
        Pagereference objref ;
        if (userAgent!=null && userAgent!='' && userAgent.contains('iPhone')){
            objref = new pagereference('/apex/cm_AddJointOwners_sf1?id='+apexpages.currentPage().getParameters().get('Id'));
            objref.setRedirect(true);
            return objref;
        }
        return null;
        
    }
}