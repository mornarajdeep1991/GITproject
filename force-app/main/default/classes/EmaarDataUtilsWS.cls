/************************************************************************************
* Name      : EmaarDataUtilsWS                                                 
* Description       : This class is used to generate WSDL to fetch data from SOA to Salesforce; taken from Dubai sandbox                                             
* Created Date  : 11/04/2018                                                    
* Created By        : Prachi Sinha  (4C)  
* Jira/Req By       :                                                                                                                                           
* -----------------------------------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
* 1.0       Name        Date                Description     Jira Ticket no./                      
************************************************************************************/

global class EmaarDataUtilsWS{

    /************************************************************************************
    Method  :         upsertPersonAccount
    Description :     to upsert the person account details based on cm_Customer_Number__c
    Version :         1.0
    *************************************************************************************
    */  
    webservice static list< EmaarDataUtilsWS.Resposewrap>  upsertPersonAccount(List<Account> lst){

        list<SOA_Date_Stage__c> lstDataStage = new list<SOA_Date_Stage__c>();
        list<EmaarDataUtilsWS.Resposewrap> lstResponsewrap = new list<EmaarDataUtilsWS.Resposewrap>();
        Schema.SObjectField f = Account.Fields.cm_Customer_Number__c;
        
        RecordType rec = [Select id from RecordTYpe where sobjectType='Account' and name='EGY Person Account'];
        for(Account acc : lst){
            acc.RecordTypeId = rec.Id;
        }
        
        Database.UpsertResult res;
        integer i=0;
        for(Account objacc:lst){
            res = database.upsert(objacc,f,false);
            string strObjectData = objacc+'';
            string status = '';
            string strMessage = ''; 
            integer iOracleSeq = integer.valueof(objacc.Oracle_seq_number__c);
            if(res.isSuccess()){
                  status = 'Success';
                  strMessage = 'Success';
            }else{
                   status = 'Error';
                   for(Database.Error err : res.getErrors()) {
               strMessage  = 'Status Code :'+err.getStatusCode() + ', Error Message : ' + err.getMessage()+', Fields:'+err.getFields();           
                   }
            }
            EmaarDataUtilsWS.Resposewrap objwrap = new EmaarDataUtilsWS.Resposewrap();
            objwrap.SOAObject = strObjectData;
            objwrap.ErrorMessage = strMessage;
            objwrap.Status = status;
            objwrap.iSeq = iOracleSeq;
            lstResponsewrap.add(objwrap);
            system.debug('****lstResponsewrap'+lstResponsewrap.size());
            lstDataStage.add(CreateDATAStage(strObjectData,status,strMessage,'Person Account Sync -Process','',''));
            i = i+1;
        }
        //insert lstDataStage;
        return lstResponsewrap;
    }
    
    /************************************************************************************
    Method  :         upsertBusinessAccount
    Description :     to upsert the business account details based on cm_Customer_Number__c
    Version :         1.0
    *************************************************************************************
    */ 
    webservice static list<EmaarDataUtilsWS.Resposewrap> upsertBusinessAccount(List<Account> lst){
        list<SOA_Date_Stage__c> lstDataStage = new list<SOA_Date_Stage__c>();
        list<EmaarDataUtilsWS.Resposewrap> lstResponsewrap = new list<EmaarDataUtilsWS.Resposewrap>();
        Schema.SObjectField f = Account.Fields.cm_Customer_Number__c;
        
        RecordType rec = [Select id from RecordTYpe where sobjectType='Account' and name='EGY Corporate Account'];
        for(Account acc : lst){
            acc.RecordTypeId = rec.Id;
        }
        
        Database.UpsertResult res;
        integer i=0;
        for(Account objacc:lst){
            res = database.upsert(objacc,f,false);
            string strObjectData = objacc+'';
            string status = '';
            string strMessage = ''; 
            integer iOracleSeq = integer.valueof(objacc.Oracle_seq_number__c);
            if(res.isSuccess()){
                  status = 'Success';
                  strMessage = 'Success';
            }else{
                   status = 'Error';
                   for(Database.Error err : res.getErrors()) {
               strMessage  = 'Status Code :'+err.getStatusCode() + ', Error Message : ' + err.getMessage()+', Fields:'+err.getFields();           
                   }
            }
            EmaarDataUtilsWS.Resposewrap objwrap = new EmaarDataUtilsWS.Resposewrap();
            objwrap.SOAObject = strObjectData;
            objwrap.ErrorMessage = strMessage;
            objwrap.Status = status;
            objwrap.iSeq = iOracleSeq;
            lstResponsewrap.add(objwrap);
            system.debug('****lstResponsewrap'+lstResponsewrap.size());
            lstDataStage.add(CreateDATAStage(strObjectData,status,strMessage,'Business Account Sync -Process','',''));
            i = i+1;
        }
        //insert lstDataStage;
        return lstResponsewrap;
    }
    
    /************************************************************************************
    Method  :         upsertAccounts
    Description :     to upsert the account details based on Party_ID__c
    Version :         1.0
    *************************************************************************************
    */ 
    webservice static list<EmaarDataUtilsWS.Resposewrap>  upsertAccounts(List<Account> lst){
        list<SOA_Date_Stage__c> lstDataStage = new list<SOA_Date_Stage__c>();
        list<EmaarDataUtilsWS.Resposewrap> lstResponsewrap = new list<EmaarDataUtilsWS.Resposewrap>();
        RecordType PersonAccRec = [Select id from RecordTYpe where sobjectType='Account' and name='EGY Person Account'];
        RecordType OrgAccRec = [Select id from RecordTYpe where sobjectType='Account' and name='EGY Corporate Account'];
        for(Account acc : lst){
            if(acc.Party_Type__c == 'PERSON')
                acc.RecordTypeId = PersonAccRec.Id;
            else
                acc.RecordTypeId = OrgAccRec.Id;
        }
        if(!lst.isEmpty()){
            Schema.SObjectField f = Account.Fields.Party_ID__c;
            Database.UpsertResult res;
            integer i=0;
            for(Account objacc:lst){
                res = database.upsert(objacc,f,false);
                string strObjectData = objacc+'';
                string status = '';
                string strMessage = '';
                integer iOracleSeq = integer.valueof(objacc.Oracle_seq_number__c);
                if(res.isSuccess()){
                      status = 'Success';
                      strMessage = 'Success';
                }else{
                       status = 'Error';
                       for(Database.Error err : res.getErrors()) {
                   strMessage  = 'Status Code :'+err.getStatusCode() + ', Error Message : ' + err.getMessage()+', Fields:'+err.getFields();           
                       }
                }
                EmaarDataUtilsWS.Resposewrap objwrap = new EmaarDataUtilsWS.Resposewrap();
                objwrap.SOAObject = strObjectData;
                objwrap.ErrorMessage = strMessage;
                objwrap.Status = status;
                objwrap.iSeq = iOracleSeq;
                lstResponsewrap.add(objwrap);
                system.debug('****lstResponsewrap'+lstResponsewrap.size());
                lstDataStage.add(CreateDATAStage(strObjectData,status,strMessage,'Account Sync -Process','',''));
                i = i+1;
            }
        }
        //insert lstDataStage;
        return  lstResponsewrap;
        
    }
   
    /************************************************************************************
    Method  :         upsertContact
    Description :     to upsert the contact details based on cm_Contact_Key__c
    Version :         1.0
    *************************************************************************************
    */  
    webservice static list<EmaarDataUtilsWS.Resposewrap> upsertContact(List<ContactWrapper> lstWrap){
        list<EmaarDataUtilsWS.Resposewrap> lstResponsewrap = new list<EmaarDataUtilsWS.Resposewrap>();
        integer i = 0;
        list<SOA_Date_Stage__c> lstDataStage = new list<SOA_Date_Stage__c>();
        List<Contact> lstCons = new List<Contact>();
        for(ContactWrapper cw: lstWrap){
            if(cw.AccountId != null){
                for(Contact con: cw.lstContacts){
                    con.AccountId = cw.AccountId;
                    lstCons.add(con);
                }
            }
        } 
        if(!lstcons.isEmpty()){
            Schema.SObjectField f = Contact.Fields.cm_Contact_Key__c;
            Database.UpsertResult res;
            for(contact objCon:lstcons){
                res = database.upsert(objCon,f,false);
                string strObjectData = objCon+'';
                string status = '';
                string strMessage = ''; 
                //integer iOracleSeq = integer.valueof(objacc.Oracle_seq_number__c);
                if(res.isSuccess()){
                      status = 'Success';
                      strMessage = 'Success';
                }else{
                       status = 'Error';
                       for(Database.Error err : res.getErrors()) {
                   strMessage  = 'Status Code :'+err.getStatusCode() + ', Error Message : ' + err.getMessage()+', Fields:'+err.getFields();           
                       }
                }
                EmaarDataUtilsWS.Resposewrap objwrap = new EmaarDataUtilsWS.Resposewrap();
                objwrap.SOAObject = strObjectData;
                objwrap.ErrorMessage = strMessage;
                objwrap.Status = status;
                objwrap.iSeq = i;
                lstResponsewrap.add(objwrap);
                system.debug('****lstResponsewrap'+lstResponsewrap.size());
                lstDataStage.add(CreateDATAStage(strObjectData,status,strMessage,'Contact Sync -Process','',''));
                i = i+1;
            }
        }
        //insert lstDataStage;
        return  lstResponsewrap;
    }

    /************************************************************************************
    Method  :         upsertProperty
    Description :     to upsert the properties details based on Property_ID__c
    Version :         1.0
    *************************************************************************************
    */   
    webservice static List<EmaarDataUtilsWS.Resposewrap> upsertProperty(List<Property__c> lst){

        list<EmaarDataUtilsWS.Resposewrap> lstResponsewrap = new list<EmaarDataUtilsWS.Resposewrap>();
        Schema.SObjectField f = Property__c.Fields.Property_ID__c;

        list<SOA_Date_Stage__c> lstDataStage = new list<SOA_Date_Stage__c>();
        map<integer,Property__c>  mapStagingData = new map<integer,Property__c>();
        integer i = 0;
        for(Property__c pi: lst){
            pi.Last_Update_Login__c = null;
            mapStagingData.put(i,pi);
            i = i+1;
        }
         
        list<Database.UpsertResult> res = database.upsert(mapStagingData.values(),f,false);
        
        integer icount = 0;
        for(Database.UpsertResult objres :res ){
            string strObjectData = '';
            string status = '';
            string strMessage = ''; 
            string iOracleSeq = '';
            if(objres.isSuccess()){
                status = 'Success';
                strMessage = 'Success';
            }else{
               status = 'Error';
               for(Database.Error err : objres.getErrors()) {
                  strMessage  = 'Status Code :'+err.getStatusCode() + ', Error Message : ' + err.getMessage()+', Fields:'+err.getFields();           
               }
            }
            if(mapStagingData.get(icount)!=null){
                 strObjectData = mapStagingData.get(icount)+'';
            }
            EmaarDataUtilsWS.Resposewrap objwrap = new EmaarDataUtilsWS.Resposewrap();
            if(mapStagingData.get(icount)!=null){
                objwrap.SOAObject = mapStagingData.get(icount).Property_ID__c;
                iOracleSeq = string.valueof(mapStagingData.get(icount).Oracle_seq_number__c);
            }
            objwrap.ErrorMessage = strMessage;
            objwrap.Status = status;
            if(iOracleSeq <> null)
                objwrap.iSeq = integer.valueof(iOracleSeq);
            lstResponsewrap.add(objwrap);
            system.debug('****lstResponsewrap'+lstResponsewrap.size());
            lstDataStage.add(CreateDATAStage(strObjectData,status,strMessage,'Property Sync - Process','',''));
            icount = icount+1;
        }
        //insert lstDataStage;
        system.debug('*****TEST***'+lstDataStage);
        return lstResponsewrap; 

    }

    /************************************************************************************
    Method  :         upsertLocation
    Description :     to upsert the location details based on Location_ID__c
    Version :         1.0
    *************************************************************************************
    */
    webservice static list<EmaarDataUtilsWS.Resposewrap> upsertLocation(List<Location__c> lst){
        list<EmaarDataUtilsWS.Resposewrap> lstResponsewrap = new list<EmaarDataUtilsWS.Resposewrap>();
        Schema.SObjectField f = Location__c.Fields.Location_ID__c;

        list<SOA_Date_Stage__c> lstDataStage = new list<SOA_Date_Stage__c>();
        map<integer,Location__c>  mapStagingData = new map<integer,Location__c>();
        integer i = 0;
        for(Location__c pi: lst){
            if(pi.Active_End_Date__c!=null){
                 DateTime DTVal =  pi.Active_End_Date__c;
                 integer iyearval = DTVal.year();
                 system.debug('***iyearval'+iyearval);
                 if(iyearval > 4000){
                      iyearval = 4000;
                 }
                 DateTime d = DateTime.newInstance(iyearval,DTVal.month(),DTVal.day());
                 pi.Active_End_Date__c  = d;
            }
            mapStagingData.put(i,pi);
            i = i+1;
        }
         
        list<Database.UpsertResult> res = database.upsert(mapStagingData.values(),f,false);
        
        integer icount = 0;
        for(Database.UpsertResult objres :res ){
            string strObjectData = '';
            string status = '';
            string strMessage = ''; 
            string iOracleSeq = '';
            if(objres.isSuccess()){
                status = 'Success';
                strMessage = 'Success';
            }else{
               status = 'Error';
               for(Database.Error err : objres.getErrors()) {
                  strMessage  = 'Status Code :'+err.getStatusCode() + ', Error Message : ' + err.getMessage()+', Fields:'+err.getFields();           
               }
            }
            if(mapStagingData.get(icount)!=null){
                 strObjectData = mapStagingData.get(icount)+'';
            }
            EmaarDataUtilsWS.Resposewrap objwrap = new EmaarDataUtilsWS.Resposewrap();
            if(mapStagingData.get(icount)!=null){
                objwrap.SOAObject = mapStagingData.get(icount).Location_ID__c;
                iOracleSeq = string.valueof(mapStagingData.get(icount).Oracle_seq_number__c);
            }
            objwrap.ErrorMessage = strMessage;
            objwrap.Status = status;
            objwrap.iSeq = integer.valueof(iOracleSeq);
            lstResponsewrap.add(objwrap);
            system.debug('****lstResponsewrap'+lstResponsewrap.size());
            lstDataStage.add(CreateDATAStage(strObjectData,status,strMessage,'Location Sync -Process','',''));
            icount = icount+1;
        }
        //insert lstDataStage;
        system.debug('*****TEST***'+lstDataStage);
        return lstResponsewrap; 
    }

    /************************************************************************************
    Method  :         upsertOrders
    Description :     to upsert the orders details based on Sales_Order__c
    Version :         1.0
    *************************************************************************************
    */
    webservice static list<EmaarDataUtilsWS.Resposewrap> upsertOrders(List<Opportunity_Property__c> lstOPPProperties){
        system.debug('******lstOPPProperties***PROCESS RECORDS'+lstOPPProperties.size());
        System.debug('@@@@lstOPPProperties='+lstOPPProperties);
        list<EmaarDataUtilsWS.Resposewrap> lstResponsewrap = new list<EmaarDataUtilsWS.Resposewrap>();
        Schema.SObjectField f = Opportunity_Property__c.Fields.Sales_Order__c;
        list<SOA_Date_Stage__c> lstDataStage =  new list<SOA_Date_Stage__c>();
        integer i = 0;
        Set<String> orderIds = new set<string>();
        map<integer,Opportunity_Property__c>  mapStagingData = new map<integer,Opportunity_Property__c>();
        for(Opportunity_Property__c ow: lstOPPProperties){
            orderIds.add(ow.Sales_Order__c);
        }
        
        Map<string,Opportunity_Property__c> mpInv = new Map<string,Opportunity_Property__c>();
        MAP<String, Id> orderIdToPInventoryMap = new MAP<String, Id>();
        LIST<Property_Inventory__c> updateableInventories = new LIST<Property_Inventory__c>();


        for(Opportunity_Property__c oi: [Select id,Sales_Order__c,cm_Property_Inventory__c,cm_Order_Status__c, cm_Property_Inventory__r.Id from Opportunity_Property__c where Sales_Order__c in:orderIds]){
            mpInv.put(oi.Sales_Order__c, oi);
            orderIdToPInventoryMap.put(oi.Sales_Order__c, oi.cm_Property_Inventory__r.Id);
        }

        list<Opportunity_Property__c> lstoppToupdate = new list<Opportunity_Property__c>();
        for(Opportunity_Property__c objprop:lstOPPProperties){
            if(mpInv.get(objprop.Sales_Order__c) ==null){
                EmaarDataUtilsWS.Resposewrap objwrap = new EmaarDataUtilsWS.Resposewrap();
                objwrap.SOAObject = objprop+'';
                objwrap.ErrorMessage = 'No record with the sales order:'+ objprop.Sales_Order__c;
                objwrap.Status = 'Error';
                objwrap.iSeq = integer.valueof(objprop.Oracle_seq_number__c);
                lstResponsewrap.add(objwrap);
                lstDataStage.add(CreateDATAStage(objwrap.SOAObject,objwrap.Status,objwrap.ErrorMessage,'Order Sync - Process','',''));
            }else{
                 Opportunity_Property__c oOpporProp = mpInv.get(objprop.Sales_Order__c);
                 oOpporProp.cm_Order_Status__c = objprop.cm_Order_Status__c;
                 oOpporProp.Sales_Order__c  = objprop.Sales_Order__c;
                 oOpporProp.Oracle_seq_number__c = objprop.Oracle_seq_number__c;
                 mapStagingData.put(i,oOpporProp);
                 i = i +1;
                 lstoppToupdate.add(oOpporProp);
            }

            if(orderIdToPInventoryMap.get(objprop.Sales_Order__c) != null){
                Property_Inventory__c pInv = new Property_Inventory__c(Id = orderIdToPInventoryMap.get(objprop.Sales_Order__c));
                if(objprop.cm_Order_Status__c == 'SOLD'){
                    pInv.Property_Status__c = 'Sold';
                }else if(objprop.cm_Order_Status__c == 'CANCELLED'){
                    pInv.Property_Status__c = 'Available';
                }
                updateableInventories.add(pInv);
            }
        }
        if(updateableInventories != null && updateableInventories.size() > 0){
            list<Database.SaveResult> res = Database.update(updateableInventories);
        }

        system.debug('******lstoppToupdate'+lstoppToupdate.size());
        if(lstoppToupdate!=null && lstoppToupdate.size() >0){ 
            list<Database.SaveResult> res = Database.update(mapStagingData.values());
            integer icount = 0;
            for(Database.SaveResult objres :res ){
                string strObjectData = '';
                string status = '';
                string strMessage = ''; 
                if(objres.isSuccess()){
                    status = 'Success';
                    strMessage = 'Success';
                }else{
                   status = 'Error';
                   for(Database.Error err : objres.getErrors()) {
                      strMessage  = 'Status Code :'+err.getStatusCode() + ', Error Message : ' + err.getMessage()+', Fields:'+err.getFields();           
                   }
                }
                if(mapStagingData.get(icount)!=null){
                     strObjectData = mapStagingData.get(icount)+'';
                }
                EmaarDataUtilsWS.Resposewrap objwrap = new EmaarDataUtilsWS.Resposewrap();
                string iOracleSeq = '';
                if(mapStagingData.get(icount)!=null){
                    objwrap.SOAObject = mapStagingData.get(icount).Sales_Order__c;
                    iOracleSeq = string.valueof(mapStagingData.get(icount).Oracle_seq_number__c);
                }    
                objwrap.ErrorMessage = strMessage;
                objwrap.Status = status;
                objwrap.iSeq = integer.valueof(iOracleSeq);
                lstResponsewrap.add(objwrap);
                system.debug('****lstResponsewrap'+lstResponsewrap.size());
                lstDataStage.add(CreateDATAStage(strObjectData,status,strMessage,'Order Sync - Process','',''));
                icount = icount+1;
            }
            //if(lstDataStage!=null && lstDataStage.size() >0)
             //insert lstDataStage;
        }
        return lstResponsewrap;
        
    }

    /************************************************************************************
    Method  :         upsertInventory
    Description :     to upsert the Inventory details based on Location_ID__c
    Version :         1.0
    *************************************************************************************
    */
    webservice static list<EmaarDataUtilsWS.Resposewrap> upsertInventory(List<Property_Inventory__c> lst){
        
        SOA_Date_Stage__c objSoa = new SOA_Date_Stage__c();
        objsoa.Process_Name__c = 'Property Inventory Process';
        objsoa.Process_Time__c = system.now();
        //insert objsoa;
        
        list<Block_Reason_Codes__c> lstBlockData = [select id,API_Value__c,Block_Type__c,Name from Block_Reason_Codes__c limit 100];
        map<string,Block_Reason_Codes__c>  mapReasonCodes =  new map<string,Block_Reason_Codes__c>();
        for(Block_Reason_Codes__c obj:lstBlockData){
            mapReasonCodes.put(obj.API_Value__c,obj);
        }
        
        system.debug('***lst.size()'+lst.size());
        
        list<EmaarDataUtilsWS.Resposewrap> lstResponsewrap = new list<EmaarDataUtilsWS.Resposewrap>();
        map<integer,Property_Inventory__c> mapStagingData = new map<integer,Property_Inventory__c>();

        integer i = 0;
        set<string> setPLIDS = new set <string>();
        map<string,string> MapUniqueKeys = new map<string,string>();
        
        for(Property_Inventory__c pi: lst){
            setPLIDS.add(pi.Location_Id__c);
            mapStagingData.put(i,pi);
            i = i+1;
        }
        /********Unique Check logic*************************/
        map<string,Property_Inventory__c>  mapUniquedata = new map<string,Property_Inventory__c>();
        list<Property_Inventory__c> lstPropinv = [select id,name,Location_ID__c,Oracle_seq_number__c from Property_Inventory__c where Location_ID__c IN:setPLIDS];
        for(Property_Inventory__c objPropINV:lstPropinv){
            mapUniquedata.put(objPropINV.Location_ID__c,objPropINV);
        }
        system.debug('******mapUniquedata'+mapUniquedata);
        /*************END***********************************/
        system.debug('********setPLIDS'+setPLIDS);
        map<string,string> locmapdata = new map<string,string>();
        for(Location__c loc : [Select id,Location_Id__c,Building__c  from Location__c where Location_Id__c in: setPLIDS]){
            locmapdata.put(loc.Location_Id__c, loc.Location_Id__c);
        }
        Schema.SObjectField f = Property_Inventory__c.Fields.Location_ID__c;
        list<SOA_Date_Stage__c> lstDataStage =  new list<SOA_Date_Stage__c>();
        list<Property_Inventory__c> lstToinventoryUpdate = new list<Property_Inventory__c>();
        for(Property_Inventory__c pi: lst){
            if((mapUniquedata.get(pi.Location_Id__c)==null ) || (mapUniquedata.get(pi.Location_Id__c)!=null && mapUniquedata.get(pi.Location_Id__c).Oracle_seq_number__c == null) || (pi.Oracle_seq_number__c!=null && mapUniquedata.get(pi.Location_Id__c)!=null && mapUniquedata.get(pi.Location_Id__c).Oracle_seq_number__c!=null &&  pi.Oracle_seq_number__c > mapUniquedata.get(pi.Location_Id__c).Oracle_seq_number__c )){
                if(locmapdata!=null && locmapdata.get(pi.Location_Id__c)!=null){
                    if(pi.Blocked_Reason_Code__c!=null && mapReasonCodes.get(pi.Blocked_Reason_Code__c)!=null){
                        if(pi.Block_Reason__c == null || pi.Block_Reason__c== '')
                           pi.Block_Reason__c = mapReasonCodes.get(pi.Blocked_Reason_Code__c).Name;
                        if(pi.Blocked_Type__c == null || pi.Blocked_Type__c == '')
                           pi.Blocked_Type__c = mapReasonCodes.get(pi.Blocked_Reason_Code__c).Block_Type__c;
                    }else if(pi.Blocked_Reason_Code__c == null || pi.Blocked_Reason_Code__c == '' ||  pi.Blocked_Reason_Code__c == ' '){
                        pi.Block_Reason__c = '';
                        pi.Blocked_Type__c = '';
                    }
                    lstToinventoryUpdate.add(pi);
                }else{
                    EmaarDataUtilsWS.Resposewrap objwrap = new EmaarDataUtilsWS.Resposewrap();
                    objwrap.SOAObject = pi.Location_ID__c;
                    objwrap.iSeq =integer.valueof(pi.Oracle_seq_number__c);
                    objwrap.ErrorMessage = 'Location Missing';
                    lstResponsewrap.add(objwrap);
                    lstDataStage.add(CreateDATAStage(pi+'','ERROR',objwrap.ErrorMessage,'Property Inventory Sync - Process','',''));
    
                }
            }
            if(pi.Oracle_seq_number__c!=null && mapUniquedata.get(pi.Location_Id__c)!=null && mapUniquedata.get(pi.Location_Id__c).Oracle_seq_number__c!=null &&  pi.Oracle_seq_number__c < mapUniquedata.get(pi.Location_Id__c).Oracle_seq_number__c ){
                EmaarDataUtilsWS.Resposewrap objwrap = new EmaarDataUtilsWS.Resposewrap();
                objwrap.SOAObject = pi.Location_ID__c;
                objwrap.iSeq =integer.valueof(pi.Oracle_seq_number__c);
                objwrap.ErrorMessage = 'OLD VERSION DATA';
                lstResponsewrap.add(objwrap);
                lstDataStage.add(CreateDATAStage(pi+'','',objwrap.ErrorMessage,'Property Inventory - Process','',''));
            }
        }
        system.debug('********lstToinventoryUpdate'+lstToinventoryUpdate);
        list<Database.UpsertResult> res = database.upsert(lstToinventoryUpdate,f,false);
       
        integer icount = 0;
        for(Database.UpsertResult objres :res ){
            EmaarDataUtilsWS.Resposewrap objwrap = new EmaarDataUtilsWS.Resposewrap();
            string strObjectData = '';
            string status = '';
            string strMessage = ''; 
            string iOracleSeq = '';
            string strRECID = '';
            if(objres.isSuccess()){
                status = 'Success';
                strMessage = 'Success';
                strRECID=objres.getId();
            }else{
               status = 'Error';
               for(Database.Error err : objres.getErrors()) {
                  strMessage  = 'Status Code :'+err.getStatusCode() + ', Error Message : ' + err.getMessage()+', Fields:'+err.getFields();           
               }
            }
            if(mapStagingData.get(icount)!=null){
                 strObjectData = mapStagingData.get(icount)+'';
            }
           
            if(mapStagingData.get(icount)!=null){
                objwrap.SOAObject = mapStagingData.get(icount).Location_ID__c;
                iOracleSeq = string.valueof(mapStagingData.get(icount).Oracle_seq_number__c);
            }
            objwrap.ErrorMessage = strMessage;
            objwrap.Status = status;
            if(iOracleSeq != null)
            objwrap.iSeq = integer.valueof(iOracleSeq);
            lstResponsewrap.add(objwrap);
            system.debug('****lstResponsewrap'+lstResponsewrap.size());
            lstDataStage.add(CreateDATAStage(strObjectData,status,strMessage,'Property Inventory Sync -Process',objsoa.id,strRECID));
            icount = icount+1;
        }
        //insert lstDataStage;
        system.debug('*****TEST***'+lstDataStage);
        System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>'+Limits.getDMLStatements());
        System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>'+Limits.getDMLRows());
        System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>'+Limits.getQueries());
        return lstResponsewrap;
    }
  
    /************************************************************************************
    WrapperClass  :   ContactWrapper
    Description :     request wrapper for contact details
    Version :         1.0
    *************************************************************************************
    */
    global class ContactWrapper{
        webservice string accountId;
        webservice List<Contact> lstContacts;
        webservice integer iOracleseq;
    }
    
    /************************************************************************************
    WrapperClass  :   CreateDATAStage
    Description :     request wrapper for SOA Exception details
    Version :         1.0
    *************************************************************************************
    */
    public static SOA_Date_Stage__c CreateDATAStage(string strOBJData,string status,string strMessage,string processName,string parentlogid,string PIID){
        SOA_Date_Stage__c objData =new SOA_Date_Stage__c();
        objData.Exception__c = strMessage;
        objData.Status__c = status;
        objData.SOA_Data__c = strOBJData;
        objData.Process_Time__c = system.now();
        objData.Process_Name__c = processName;
        if(parentlogid!='' && parentlogid!=null)
        objData.Parent_Log__c = parentlogid;
        if(PIID!='' && PIID!=null)
        objData.Property_Inventory__c = PIID;
        return objData;
    }
   
    /************************************************************************************
    WrapperClass  :   Resposewrap
    Description :     wrapper for response
    Version :         1.0
    *************************************************************************************
    */
    global class Resposewrap{
       webservice string SOAObject {get;set;}
       webservice string ErrorMessage {get;set;}
       webservice string Status {get;set;}
       webservice integer iSeq {get;set;}
    }
    
    /************************************************************************************
    WrapperClass  :   OrderWrapper
    Description :     request wrapper for order
    Version :         1.0
    *************************************************************************************
    */
    global class OrderWrapper{
        webservice string OrderId;
        webservice string status;
    } 
  
}