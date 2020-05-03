/*
    Author : Haribabu Amudalapalli
    Date : july 18th ,2016
    Description : This class is used to create multiple opportunities and relate each property to each Opportunity. One to One relation.
    Modification History :
	v1.1  09/Jan/2018     Sandeep      Sales admin Team assignment from label to configuration__c object setting..
	v1.2  02/Mar/2018     Ajaz         Payment Purpose changes.
*/
global class multipleunitsBooking {
    /*
      Method Name : createMultipleOpportunities
      Descriptiond : Method used to create multiple opportunities .
    */
    public static string createMultipleOpportunities(string strOppId){
        string strMessage = '';
        try{
            // Query Opportunity dynamically and clone the records .
            string query = getCreatableFieldsSOQL();
            Query = Query+'  where id=:strOppId';
            system.debug('*****Query*******'+Query);
            list<Opportunity> lstOppData = database.query(Query); 
            Opportunity oppData = new Opportunity();
            if(lstOppData!=null && lstOppData.size() >0)
                oppData = lstOppData[0];
            // Query list of Opportunity Properties
            system.debug('****oppData'+oppData); 
            list<Opportunity_Property__c> lstOPPProperties = [select id,cm_Opportunity__c,Booking_Price__c,Is_Package_Unit__c,cm_Order_Status__c,cm_Property_Inventory__c,cm_Inventory_Location_Code__c, Sales_Order__c from Opportunity_Property__c  where  cm_Opportunity__c=:strOppId];
            list<Joint_Owner__c> lstJowners = [select id,cm_Related_Opportunity__c,cm_Joint_Owner__c from Joint_Owner__c  where  cm_Related_Opportunity__c=:strOppId ];
            
            list<Opportunity> lstToclonedOpps = new list<Opportunity>();
            map<id,Opportunity_Property__c>  mapOPPPropdata = new map<id,Opportunity_Property__c>(); 
            boolean packageUNits= false ;
            integer ItotalCount = lstOPPProperties.size();
            integer BookedCount = 0;
             
            String day = string.valueOf(system.now().day());
            String month = string.valueOf(system.now().month());
            String hour = string.valueOf(system.now().hour());
            String minute = string.valueOf(system.now().minute());
            String second = string.valueOf(system.now().second());
            String year = string.valueOf(system.now().year());
              
            String strTime = day+'-'+month+'-'+year+' '+hour+':'+minute+':'+second ;
            
            for(Opportunity_Property__c OppProperty:lstOPPProperties){
                 if(OppProperty.cm_Order_Status__c == 'Booked'){
                     BookedCount = BookedCount+1;
                 }
                 if(OppProperty.Is_Package_Unit__c ){
                     packageUNits = true;
                 }
            }
            for(Opportunity_Property__c objProp:lstOPPProperties){
                mapOPPPropdata.put(objProp.id,objProp);
                // Cloning the Opportunity records.
                Opportunity OpptoClone = oppData.clone(false, true);
                
                System.debug('>>>>>>>>Booking status>>>>>>>>>>>'+OpptoClone.booking_status__c);
                
                if(OpptoClone.Bundle_ID__c == null){
                    if(objProp.Is_Package_Unit__c){
                        OpptoClone.Bundle_ID__c = OpptoClone.Account.Name+'-PKG-'+strTime;
                        OpptoClone.Is_Package_Unit__c =true;
                    }else{
                        OpptoClone.Bundle_ID__c = OpptoClone.Account.Name+'-MU-'+strTime;
                        OpptoClone.Is_Package_Unit__c = false;
                    }
                }
                // Hari added
                OpptoClone.Amount = objProp.Booking_Price__c;
                if(objProp.cm_Order_Status__c == 'Booked'){ 
                	//Adeel
                    OpptoClone.stageName = 'Pending Approval';
                    OpptoClone.cm_Approval_Status__c = 'Pending with Admin';
                    //@END
                    OpptoClone.Property_Booked_Date__c = system.now();
                    if(OpptoClone.cm_Deposit_Amount__c!=null){
                        OpptoClone.cm_Deposit_Amount__c  = decimal.valueof(integer.valueof(OpptoClone.cm_Deposit_Amount__c) / integer.valueof(lstOPPProperties.size()));
                    }
                    OpptoClone.cm_status__c =  'Booked - Payment Pending';
                    if(packageUNits == true){
                        OpptoClone.cm_Approval_Status__c = '';
                    }else{
                        OpptoClone.cm_Approval_Status__c = 'Payment Processing';
                        opptoClone.booking_status__c = 'Booked in Oracle';
                    }
                    
                    /*if(packageUNits == true && BookedCount == ItotalCount)
                         OpptoClone.cm_Approval_Status__c = 'Payment Processing';
                    else if(packageUNits == false && BookedCount == ItotalCount)
                         OpptoClone.cm_Approval_Status__c = 'Payment Processing';
                    else if(packageUNits == true && BookedCount != ItotalCount)
                          OpptoClone.cm_Approval_Status__c = '';
                    else if(packageUNits == true && BookedCount != ItotalCount)
                          OpptoClone.cm_Approval_Status__c = 'Payment Processing'; */
                }else{ 
                     OpptoClone.cm_status__c =  'Verified';
                     opptoClone.booking_status__c = 'Booked in Salesforce';
                     OpptoClone.cm_Approval_Status__c = '';
                }
                OpptoClone.Name =OpptoClone.Account.Name+'-'+objProp.cm_Inventory_Location_Code__c;
                // update Oportunity Property ID on Opportunity
                OpptoClone.Opportunity_Property_ID__c = objProp.id;
                OpptoClone.Sales_Order_No__c = objProp.Sales_Order__c;
                OpptoClone.cm_Approval_Status__c = 'Pending with Admin';
                OpptoClone.Rating__c = oppData.Rating__c;
                OpptoClone.Type_of_Property_Interest__c = oppData.Type_of_Property_Interest__c;
                // Adeel here....
                //OpptoClone.Rating__c = 
                lstToclonedOpps.add(OpptoClone);
            }
            system.debug('*****lstToclonedOpps'+lstToclonedOpps);
            
            set<id> setPropInvIds = new set<Id>();
            set<id> failedPropInvIds = new set<Id>(); //Added by Anas: Capture list of all prop inv ids, successfully booked or not.
            
            if(lstToclonedOpps!=null && lstToclonedOpps.size() >0){
                insert lstToclonedOpps; // Inserting the cloned records
                
                if(lstJowners!=null && lstJowners.size() >0){
                    list<Joint_Owner__c> lstJtoinsert = new list<Joint_Owner__c>();
                    for(Opportunity cOpp:lstToclonedOpps){
                        if(cOpp.id!=null){
                            Joint_Owner__c objJowner = new Joint_Owner__c();
                            objJowner.cm_Related_Opportunity__c = cOpp.id;
                            objJowner.cm_Joint_Owner__c = lstJowners[0].cm_Joint_Owner__c;
                            lstJtoinsert.add(objJowner);
                        }
                    }   
                    if(lstJtoinsert!=null && lstJtoinsert.size() >0){
                        insert lstJtoinsert;
                    }
                    delete lstJowners;
                }
                
                system.debug('AFTER INSERT**lstToclonedOpps****'+lstToclonedOpps);
                list<Opportunity_Property__c> lstToupdate = new list<Opportunity_Property__c>();
                set<id> setCompleted = new set<Id>();
                set<id> setCompletedOP = new set<Id>();
                // Making one to one relation between Opportunity and Properties.
                Map<Id,Id> oppPropMap = new Map<Id, Id>();
             
                for(Opportunity objOppor:lstToclonedOpps){
                    system.debug('*****8objOppor.Opportunity_Property_ID__c'+objOppor.Opportunity_Property_ID__c);
                    
                    if(objOppor.Opportunity_Property_ID__c!=null && mapOPPPropdata!=null && mapOPPPropdata.get(objOppor.Opportunity_Property_ID__c)!=null){
                        
                        Opportunity_Property__c objnewprop = new Opportunity_Property__c(id=objOppor.Opportunity_Property_ID__c);
                        objnewprop.recordTypeId =  CM_EmaarUtils.getRecordTypeId('Opportunity_Property__c','Sales Order Generated');
                        objnewprop.cm_Opportunity__c = objOppor.id;
                        objnewprop.Bundle_ID__c = objOppor.Bundle_ID__c;
                        if(mapOPPPropdata!=null && mapOPPPropdata.get(objOppor.Opportunity_Property_ID__c)!=null){
                            string orderstatus = mapOPPPropdata.get(objOppor.Opportunity_Property_ID__c).cm_Order_Status__c;
                            //Added by Anas: Map Property Inv Id to the opportunity to set cm_Sys_Opportunity field on inv
                            oppPropMap.put(mapOPPPropdata.get(objOppor.Opportunity_Property_ID__c).cm_Property_Inventory__c, objOppor.Id);
                            
                            if( orderstatus!='' && orderstatus == 'Booked'){
                                
                                setPropInvIds.add(mapOPPPropdata.get(objOppor.Opportunity_Property_ID__c).cm_Property_Inventory__c);
                                objnewprop.Property_Sale_status__c = 'Completed';
                                setCompleted.add(mapOPPPropdata.get(objOppor.Opportunity_Property_ID__c).cm_Property_Inventory__c);
                                setCompletedOP.add(objnewprop.Id);
                            }else if(orderstatus!='' && orderstatus.contains('Location Code does not exist or not Available for Sale.')){
                                failedPropInvIds.add(mapOPPPropdata.get(objOppor.Opportunity_Property_ID__c).cm_Property_Inventory__c);
                                objnewprop.Property_Sale_status__c = 'Not Available';
                                objnewprop.cm_Order_status__c = '';
                            }else{
                                failedPropInvIds.add(mapOPPPropdata.get(objOppor.Opportunity_Property_ID__c).cm_Property_Inventory__c);
                                objnewprop.Property_Sale_status__c = 'Error';
                            }
                        }
                        lstToupdate.add(objnewprop);
                    }
                }
                if(setCompleted!=null && setCompleted.size() >0){
                    for(Opportunity_Property__c objOPPPrp:[select id,cm_Property_Inventory__c,Property_Sale_status__c from Opportunity_Property__c where cm_Property_Inventory__c IN:setCompleted and ID NOT IN:setCompletedOP]){
                        objOPPPrp.Property_Sale_status__c = 'Not Available';
                        lstToupdate.add(objOPPPrp);
                    }
                }
                system.debug('Opp Ids >>>> ' + oppPropMap);
                if(setPropInvIds!=null && setPropInvIds.size() >0){
                    list<Property_Inventory__c> lsttoUpdatePI = new list<Property_Inventory__c>();
                     for(id invId:setPropInvIds){
                        Property_Inventory__c objINV = new Property_Inventory__c(id=invId);
                        objINV.Property_Status__c = 'Booked';
                        objINV.Booked_Time__c = system.now();
                        
                        system.debug('Looking for ' + invId);
                        //Added by Anas: Set the sys opportunity field on inv
                        if (oppPropMap.containsKey(invId)){
                            objInv.cm_Sys_Opportunity__c = oppPropMap.get(invId);
                            system.debug('Found for ' + invId);
                        }
                        else
                            system.debug('Not Found for ' + invId);
                       // objINV.cm_Sys_Opportunity__c = ;
                        lsttoUpdatePI.add(objINV);
                    }
                    
                    system.debug(failedPropInvIds);
                    for (Id failedInvId : failedPropInvIds) {
                        
                        if (oppPropMap.containsKey(failedInvId)){
                            Property_Inventory__c objINV = new Property_Inventory__c(id=failedInvId);
                            objInv.cm_Sys_Opportunity__c = oppPropMap.get(failedInvId);
                            system.debug('Found for ' + failedInvId);
                            lsttoUpdatePI.add(objINV);
                        }
                    }
                    
                    if(lsttoUpdatePI!=null && lsttoUpdatePI.size() >0){
                        update lsttoUpdatePI;
                    }
                }
                if(lstToupdate!=null && lstToupdate.size() >0){
                    system.debug('*********INSIDE UPDATE'+lstToupdate);
                    update lstToupdate; // Update Opportunity Properties
                    delete oppData; // Delete Original Opportunity
                }
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
    public static string getCreatableFieldsSOQL(){
        string objectName = 'Opportunity';
        String selects = '';
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                selectFields.add(fd.getName());
            }
        }
        // contruction of SOQL
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            selects = selects+' Account.Name ,' ;
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
        // return constrcucted query
        return 'SELECT ' + selects + ' FROM ' + objectName ;
         
    }

  
     /*
        Method Name : MultipleBookings Check
        Description :  
    */
    webservice static String Checkmultiple(string strOpportunityId){
        string strMessage = '';
        try{
            set<id> setIds = new set<Id>();
            list<Opportunity_Property__c>lstOpporunityProperty = new list<Opportunity_Property__c>();
            lstOpporunityProperty = [select id,Is_Package_Unit__c from Opportunity_Property__c where cm_Opportunity__c =:strOpportunityId];
            if(lstOpporunityProperty!=null && lstOpporunityProperty.size() >1){
                 strMessage = 'multiple';
            }else if(lstOpporunityProperty!=null && lstOpporunityProperty.size() == 1){
                    strMessage = 'One';
            }else if(lstOpporunityProperty!=null && lstOpporunityProperty.size() == 0){
                strMessage = 'Please add properties to opportunity to proceed.';
            }
        }
        catch(exception ex){
            strMessage =  ex.getMessage();
        }
        return strMessage;
    }
        /*
        Method Name : MultipleBookings Check
        Description :  
    */
    webservice static String CheckforPackageUnits(string strOpportunityId){
        string strMessage = '';
        try{
            list<Opportunity_Property__c>lstOpporunityProperty = new list<Opportunity_Property__c>();
            lstOpporunityProperty = [select id,Is_Package_Unit__c from Opportunity_Property__c where cm_Opportunity__c =:strOpportunityId];
            if(lstOpporunityProperty!=null && lstOpporunityProperty[0].Is_Package_Unit__c)
                 strMessage = 'package';
        }
        catch(exception ex){
            strMessage =  ex.getMessage();
        }
        return strMessage;
    }
     /*
        Method Name : MultipleBookings Check
        Description :  
    */
    webservice static String PaymentProcessCheck(string strAccountId){
        string strMessage = '';
        try{
            set<id> setIds = new set<Id>();
            integer iTotal = 0;
            integer isuccess = 0;
            integer ierror = 0;
            set<string> setsuccessBundles = new set<string>();
            map<string,list<Opportunity>> mapBundleOpps = new map<string,list<Opportunity>>();
            list<Opportunity>lstOpporunity_pkg = new list<Opportunity>();
            list<Opportunity>lstOpporunity_MU = new list<Opportunity>();
            // Package units check
            lstOpporunity_pkg = [select id,stageName,Is_Package_Unit__c,Bundle_ID__c,cm_status__c from Opportunity where AccountId =:strAccountId and stagename = 'Generating Sales Offer' and Is_Package_Unit__c = true and cm_status__c!=''];
            if(lstOpporunity_pkg!=null && lstOpporunity_pkg.size() >0){
                for(Opportunity objOpportunity:lstOpporunity_pkg){
                    if(objOpportunity.Bundle_ID__c!=null){
                         if(mapBundleOpps.get(objOpportunity.Bundle_ID__c) == null){
                             list<opportunity> lstopps = new list<Opportunity>();
                             lstopps.add(objOpportunity);
                             mapBundleOpps.put(objOpportunity.Bundle_ID__c,lstopps);
                         }else{
                             list<opportunity> lstopps = mapBundleOpps.get(objOpportunity.Bundle_ID__c);
                             lstopps.add(objOpportunity);
                             mapBundleOpps.put(objOpportunity.Bundle_ID__c,lstopps);
                         }
                    }
                }
                list<Opportunity> lstToupdate = new list<Opportunity>();
                system.debug('***mapBundleOpps'+mapBundleOpps);
                for(string strkey:mapBundleOpps.keyset()){
                    system.debug('*******strkey'+strkey);
                    integer ItotalCount = mapBundleOpps.get(strkey).size();
                    integer iSuccessCount = 0;
                    for(Opportunity strOPP:mapBundleOpps.get(strkey)){
                        if(strOPP.cm_status__c == 'Booked - Payment Pending'){
                            iSuccessCount = iSuccessCount+1;
                        }
                    }
                    if(ItotalCount == iSuccessCount){ 
                       setsuccessBundles.add(strkey);
                       lstToupdate.addAll(mapBundleOpps.get(strkey));
                    }
                }
                for(opportunity opp:lstToupdate){
                    opp.cm_Approval_Status__c = 'Payment Processing';
                }
                update lstToupdate;
            }
            // Multiple Units check // normal units check
            lstOpporunity_MU = [select id,stageName,Is_Package_Unit__c,Bundle_ID__c,cm_status__c from Opportunity where AccountId =:strAccountId and stagename = 'Generating Sales Offer' and Is_Package_Unit__c = false and (cm_status__c = 'Booked - Payment Pending' or cm_status__c = 'Verified')];
            
            system.debug('******mapBundleOpps'+mapBundleOpps);
            system.debug('********lstOpporunity_MU'+lstOpporunity_MU.size());
            system.debug('********setsuccessBundles'+setsuccessBundles.size());
            system.debug('********mapBundleOpps'+mapBundleOpps.size());
            
            if(lstOpporunity_MU.size() == 0 && setsuccessBundles.size() > 0){
                strMessage = 'success';
            }else if(lstOpporunity_MU.size() > 0 && setsuccessBundles.size() == 0){
                strMessage = 'success';
            }else if(lstOpporunity_MU.size() > 0 && setsuccessBundles.size() > 0){
                strMessage = 'success';
            }else if(lstOpporunity_MU.size() == 0 && setsuccessBundles.size() ==0 && mapBundleOpps.keyset().size() == 1){
                strMessage = 'All Package units must be booked successfully to proceed with the payment. ';
            }else if(lstOpporunity_MU.size() == 0 && setsuccessBundles.size() == 0){
                strMessage = 'At least one property should be booked successfully to proceed with the payment.';
            }

        }
        catch(exception ex){
            strMessage =  ex.getMessage();
        }
        return strMessage;
    }
    
     /*
        Method Name : paymentApproval
        Description : This method is used to update the Opportunity and send emails to finance Team and Update Inventory to Booked status
    */
    webservice static String paymentApproval (list<id> setOppIds,string selPaymentMode,string DepositMethod,string selChequeOption,string strSelCreditCardOption,string DaysTohold,string dCash) {
   
     try {
         
         system.debug('**************INSIDE PAYMENT APPROVAL******setOppIds**********'+setOppIds);
         system.debug('**************INSIDE PAYMENT APPROVAL******selPaymentMode**********'+selPaymentMode);
         system.debug('**************INSIDE PAYMENT APPROVAL******DepositMethod**********'+DepositMethod);
         system.debug('**************INSIDE PAYMENT APPROVAL******selChequeOption**********'+selChequeOption);
         system.debug('**************INSIDE PAYMENT APPROVAL******strSelCreditCardOption**********'+strSelCreditCardOption);
         system.debug('**************INSIDE PAYMENT APPROVAL******DaysTohold**********'+DaysTohold);
         system.debug('**************INSIDE PAYMENT APPROVAL******dCash**********'+dCash);

         list<Opportunity> LstOppToupdate = new list<Opportunity>();
         string advisorId = userinfo.getUserId();
          // Assign opportunity ro Admin Group.
         Map<String,Mobile_Configurations__c> mpConfigs = Mobile_Configurations__c.getAll();
         list<user> lstAdminUser = [select id,Name,Email from user where username=: mpConfigs.get('Configuration').cm_Sales_Admin_Username__c];
         for(id oppId:setOppIds){
             Opportunity objOpportunity = new opportunity(id=oppId);
              objOpportunity.cm_Payment_Mode__c = selPaymentMode;
             if(DepositMethod!=null && DepositMethod!='')
                 objOpportunity.cm_Deposit_Method__c = DepositMethod;
             if(selChequeOption!=null && selChequeOption!='')
                objOpportunity.Payment_Options__c = selChequeOption;
             if(strSelCreditCardOption!=null && strSelCreditCardOption!='')
                 objOpportunity.cm_Credit_Card_Payment_Options__c = strSelCreditCardOption;
             
             if(DaysTohold!=null && DaysTohold!='')    
                objOpportunity.cm_Days_to_Hold_Cheque__c = decimal.valueof(DaysTohold);
             if(dCash!=null && dCash!='')
                objOpportunity.cm_Deposit_Amount__c = decimal.valueof(dCash);
             if(lstAdminUser!=null && lstAdminUser.size() >0){
                 objOpportunity.ownerId = lstAdminUser[0].id;
             }
             objOpportunity.recordTypeId = CM_EmaarUtils.getRecordTypeId('Opportunity','Pending Admin Approval');
             objOpportunity.cm_Approval_Status__c = 'Pending with Admin';
             objOpportunity.stageName = 'Pending Approval';
             objOpportunity.Cm_is_Payment_done__c = true;
             objOpportunity.cm_status__c = 'Verified';
             LstOppToupdate.add(objOpportunity);
         } 
         update LstOppToupdate;
         
         list<Opportunity_Property__c> lstOpportunityProperty = [select id,name,cm_Property_Inventory__c,cm_Opportunity__c from Opportunity_Property__c where cm_Opportunity__c IN:setOppIds];
         system.debug('****lstOpportunityProperty'+lstOpportunityProperty);
         set<id> setProInv = new set<id>();
         for(Opportunity_Property__c objProINV:lstOpportunityProperty){
             setProInv.add(objProINV.cm_Property_Inventory__c);
         }
         list<Property_Inventory__c> lstProInv = [select id,Payment_Confirmation__c from Property_Inventory__c where ID IN:setProInv ];
         for(Property_Inventory__c objProInV:lstProInv){
             objProInV.Payment_Confirmation__c = true;
         }
         system.debug('****lstProInv'+lstProInv);
         
         update lstProInv;
         
         return 'SUCCESS';
     }
     catch (Exception e) {
         system.debug('**********exception***'+e.getMessage());
         return e.getMessage();
     }         
    }
    
     /*
        Method Name : sendAutoDebitEmail
        Description : This method is used to send Auto debit form
    */
    webservice static void sendAutoDebitEmail(list<Opportunity> lstOPPdata,Document doc,string EmailTemplateID ) {
        //try{
            list<Messaging.SingleEmailMessage> lstEmails = new list<Messaging.SingleEmailMessage>();
            for(Opportunity OPPdata:lstOPPdata){
                if(OPPdata.Account.PersonEmail!=null){
                    Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                    attach.setContentType(doc.contentType);
                    attach.setFileName(doc.developerName+'.'+doc.type);
                    attach.setInline(false);
                    attach.Body = doc.Body;
                  
                   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                // Who you are sending the email to
                	system.debug('ReachedHere'+OPPdata.ownerid);
                   mail.setTargetObjectId(OPPdata.ownerid); 
                   // The email template ID used for the email
                   mail.setTemplateId(EmailTemplateID);
                   //mail.setWhatId(strOportunityId);   
                   mail.setBccSender(false);
                   mail.setUseSignature(false);  
                   mail.setReplyTo('noreply@emaar.com');
                   mail.setSenderDisplayName('Emaar Properties - Sales Team');
                   mail.setSaveAsActivity(false); 
                   mail.setToAddresses(new List<String>{OPPdata.Account.PersonEmail});
                   Savepoint sp = Database.setSavepoint();
                   Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                   Database.rollback(sp); // Email will not send as it is rolled Back
                   
                   Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                   emailToSend.setToAddresses(mail.getToAddresses());
                   emailToSend.setPlainTextBody(mail.getPlainTextBody()); 
                   emailToSend.setHTMLBody(mail.getHTMLBody());  
                   emailToSend.setSaveAsActivity(true); 
                   emailToSend.setSubject(mail.getSubject());
                   emailToSend.setFileAttachments(new List<Messaging.EmailFileAttachment>{attach});
                   lstEmails.add(emailToSend);
                }
            }
            if(lstEmails!=null && lstEmails.size() >0){
                Messaging.sendEmail(lstEmails);
            }
        //}catch(exception ex){
            
        //}
    }
    
     /*
        Method Name : createPaymentRecord
        Description : This methid is used to create Opportunity Payment record
        v1.2 : Added @Param: paymentPurpose
    */
    public static string createPaymentRecord(string dcash,list<Opportunity> lstOPPdata, String paymentPurpose){
        string strMessage = '';
        try{
            list<Opportunity_Payment__c> lstToinsert = new list<Opportunity_Payment__c>();
            for(Opportunity objOpportunity:lstOPPdata){
                Opportunity_Payment__c objPayment = new Opportunity_Payment__c();
                objPayment.Opportunity__c = objOpportunity.id;
                objPayment.Amount__c = decimal.valueof(dCash);
                objPayment.Contact__c = objOpportunity.cm_contact__c ;
                objPayment.Status__c = 'Email Sent to Customer';
                objPayment.Payment_Link_Expiry_Date__c = CM_PaymentUtils.GenerateExpiryDate();
                objPayment.Payment_Purpose__c = paymentPurpose;
                lstToinsert.add(objPayment);
            }
            if(lstToinsert!=null && lstToinsert.size() >0){
                insert lstToinsert;
                for(Opportunity_Payment__c objPay:lstToinsert){
                     string paymentURL = CM_PaymentUtils.GenerateSFLink(objPay.id);
                     objPay.URL__c = paymentURL;
                }
                update lstToinsert; 
                strMessage = 'success'; 
            }
        }catch(exception ex){
            strMessage = ex.getMessage();
        }
        return strMessage;
    }
      /*
        Name : Create POP up TASK

    */ 
    public static string CreatePOPTASK(list<id> setOppIds){
        string strMessage = '';
        try{
            list<Task> lstTocreate = new list<Task>();
            for(Id OppId:setOppIds){
             Task t = new Task(); 
             t.whatId = OppId;
             t.OwnerId = userinfo.getUserId();
             t.Subject = 'Collect POP';
             t.Priority = 'Normal';
             t.Status = 'Not Started';
             t.ActivityDate = system.today().addDays(2);
             t.Description  = 'Mode of payment is : Wire Transfer';
             lstTocreate.add(t);
            }
            insert lstTocreate;
             strMessage = 'success';
        }catch(exception ex){
            strMessage = ex.getMessage();
        }
        return strMessage;
    }
     public static string PackageBookingCheck(string strAccountId){
            string strMessage = '';
            set<string> setsuccessBundles = new set<string>();
            map<string,list<Opportunity>> mapBundleOpps = new map<string,list<Opportunity>>();
            list<Opportunity>lstOpporunity_pkg = new list<Opportunity>();
            list<Opportunity>lstOpporunity_MU = new list<Opportunity>();
            // Package units check
            lstOpporunity_pkg = [select id,stageName,Is_Package_Unit__c,Bundle_ID__c,cm_status__c from Opportunity where AccountId =:strAccountId and stagename = 'Generating Sales Offer' and Is_Package_Unit__c = true and cm_status__c!=''];
            if(lstOpporunity_pkg!=null && lstOpporunity_pkg.size() >0){
                for(Opportunity objOpportunity:lstOpporunity_pkg){
                    if(objOpportunity.Bundle_ID__c!=null){
                         if(mapBundleOpps.get(objOpportunity.Bundle_ID__c) == null){
                             list<opportunity> lstopps = new list<Opportunity>();
                             lstopps.add(objOpportunity);
                             mapBundleOpps.put(objOpportunity.Bundle_ID__c,lstopps);
                         }else{
                             list<opportunity> lstopps = mapBundleOpps.get(objOpportunity.Bundle_ID__c);
                             lstopps.add(objOpportunity);
                             mapBundleOpps.put(objOpportunity.Bundle_ID__c,lstopps);
                         }
                    }
                }
                list<Opportunity> lstToupdate = new list<Opportunity>();
                system.debug('***mapBundleOpps'+mapBundleOpps);
                for(string strkey:mapBundleOpps.keyset()){
                    system.debug('*******strkey'+strkey);
                    integer ItotalCount = mapBundleOpps.get(strkey).size();
                    integer iSuccessCount = 0;
                    for(Opportunity strOPP:mapBundleOpps.get(strkey)){
                        if(strOPP.cm_status__c == 'Booked - Payment Pending'){
                            iSuccessCount = iSuccessCount+1;
                        }
                    }
                    if(ItotalCount == iSuccessCount){ 
                       setsuccessBundles.add(strkey);
                    }
                }
                if(setsuccessBundles!=null && setsuccessBundles.size() >0){
                    strMessage = 'success';
                }else{
                    strMessage = 'All package units should be booked to procced to payment.';
                }
            }
            return strMessage;
     }
     public static string CreateSpecialApprovals(string dcash,list<Opportunity> lstOpp,string selChequeOption,string daystohold,string DepositMethod,string strSelCreditCardOption, String strExceptionComments){
        try{
            List<cm_Interim_Approvals__c> lstInterim = new List<cm_Interim_Approvals__c>();
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
            lstApprovalTypes.add('Referral Special Approval');
            
            list<cm_Interim_Approval_Type__c> lstApprovals = [select id,name from cm_Interim_Approval_Type__c where name IN :lstApprovalTypes];
            map<string,id> MapApprovalData = new Map<string,Id>();
            for(cm_Interim_Approval_Type__c objApptype:lstApprovals){
                MapApprovalData.put(objApptype.Name,objApptype.Id);
            }
            
             List<cm_Interim_Approvals__c> lstExisting = [Select id,Approval_Status__c,cm_Opportunity__c from cm_Interim_Approvals__c where cm_Interim_Approval_Type__c =: MapApprovalData.get('Referral Special Approval') 
                                                             and cm_Opportunity__c in: lstOpp];
             boolean createReferrer = false;
             Map<Id,integer> rejectedCount = new Map<Id,integer>();
             Map<Id,integer> actualCount = new Map<Id,integer>();
             
             if(!lstExisting.isEmpty()){
                 for(cm_Interim_Approvals__c app: lstExisting ){
                     if(app.Approval_Status__c.contains('Rejected')){
                         if(rejectedCount.containsKey(app.cm_Opportunity__c))
                            rejectedCount.put(app.cm_Opportunity__c,rejectedCount.get(app.cm_Opportunity__c)+1);
                         else
                            rejectedCount.put(app.cm_Opportunity__c,1);
                     }
                     
                     if(actualCount.containsKey(app.cm_Opportunity__c))
                        actualCount.put(app.cm_Opportunity__c,actualCount.get(app.cm_Opportunity__c)+1);
                     else
                        actualCount.put(app.cm_Opportunity__c,1);
                 }
             }
             
             Map<Id,boolean> mpCreateReferrer = new Map<Id,boolean>();
             for(id oppId: actualCount.keyset()){
                 if(actualCount.containsKey(oppId) && rejectedCount.containsKey(oppId)){
                     mpCreateReferrer.put(oppId,true);
                 }
                 else if(actualCount.containsKey(oppId) && !rejectedCount.containsKey(oppId)){
                     mpCreateReferrer.put(oppId,false);
                 }
                 else{
                     mpCreateReferrer.put(oppId,false);
                 }
                 
             }
             
             // Custom setting to verify deposit amount
             // and Raise desposit exception.
             
             set<id> setOPPids = new set<Id>();
             for(Opportunity objOpportunity :lstOpp ){
                 setOPPids.add(objOpportunity.Id);
             }
             system.debug('**********setOPPids'+setOPPids);
             
             Map<string,Opportunity_Property__c>MapBuildingData = new map<string,Opportunity_Property__c>();
             list<Opportunity_Property__c> lstoppProp = [Select id, Building__c,cm_Inventory_Location_Code__c,cm_Opportunity__c from Opportunity_Property__c where cm_Opportunity__c IN:setOPPids and Building__c!=null];
             for(Opportunity_Property__c obj:lstoppProp){
                MapBuildingData.put(obj.cm_Opportunity__c,obj);
             }
             // Custom settings to define project default amount settings.
             // Verify default amount in custom settings
             // If record exists then consider default amount from CS
             
             Map<string,decimal> mapCSdata = new map<string,decimal>();
             /* Adeel, commenting this one
             Map<String,Deposit_Amount_Settings__c> DepositSettings = Deposit_Amount_Settings__c.getAll();
             for(Deposit_Amount_Settings__c obj:DepositSettings.values()){
                 mapCSdata.put(obj.Building_Name__c,obj.Minimum_Approved_Deposit_Amount__c);
             }
             */
             system.debug('*******mapCSdata'+mapCSdata);
             
             
                 
            system.debug('strExceptionComments ' + strExceptionComments);
            for(Opportunity objOpportunity :lstOpp ){  
                system.debug('Create approvals ');
                string buildingName = '';
                if(MapBuildingData!=null && MapBuildingData.get(objOpportunity.id)!=null && MapBuildingData.get(objOpportunity.id).Building__c!=null){
                    buildingName = MapBuildingData.get(objOpportunity.id).Building__c;
                }
                
                if(strExceptionComments !=null && MapApprovalData.get('Others')!=null ){
                    lstInterim.add(new cm_Interim_Approvals__c(cm_Opportunity__c = objOpportunity.id, Submit_for_Approval__c = true,cm_Interim_Approval_Type__c = MapApprovalData.get('Others'),cm_Comments__c= strExceptionComments,Assign_To__c= objOpportunity.cm_Sales_Executive_Manager__c,cm_Selected_Units_New__c =objOpportunity.Name));    
                }
                
                if((DepositMethod== 'Deposit Waiver'  || DepositMethod =='No Deposit') && selChequeOption == 'Wire Transfer' && MapApprovalData.get('Wire Transfer Deposit Waiver')!=null){
                    lstInterim.add(new cm_Interim_Approvals__c(cm_Opportunity__c = objOpportunity.id, Submit_for_Approval__c = true,cm_Interim_Approval_Type__c = MapApprovalData.get('Wire Transfer Deposit Waiver'),cm_Comments__c= 'Waiving Full Wire Transfer Deposit',Assign_To__c= objOpportunity.cm_Sales_Executive_Manager__c,Payment_Option__c = strSelCreditCardOption,cm_Selected_Units_New__c =objOpportunity.Name ));    
                }
                
                else if( mapCSdata!=null && buildingName!='' && mapCSdata.get(buildingName) == null && DepositMethod== 'Credit card' && dcash != null && mapCSdata!=null && mapCSdata.get('Default')!=null && decimal.valueof(dcash) < mapCSdata.get('Default')  && MapApprovalData.get('Deposit Exception')!=null){
                    lstInterim.add(new cm_Interim_Approvals__c(cm_Opportunity__c = objOpportunity.id,Submit_for_Approval__c = true, cm_Interim_Approval_Type__c = MapApprovalData.get('Deposit Exception'),cm_Comments__c= 'Credit Card Deposit Amount is: '+dcash,Assign_To__c= objOpportunity.cm_Sales_Executive_Manager__c,Payment_Option__c = strSelCreditCardOption,cm_Selected_Units_New__c =objOpportunity.Name ));    
                }
                else if(mapCSdata!=null && buildingName!='' && mapCSdata.get(buildingName) == null && DepositMethod== 'Cash' && dcash != null &&  mapCSdata!=null && mapCSdata.get('Default')!=null && decimal.valueof(dcash) < mapCSdata.get('Default') && MapApprovalData.get('Deposit Exception')!=null){
                    lstInterim.add(new cm_Interim_Approvals__c(cm_Opportunity__c = objOpportunity.id, Submit_for_Approval__c = true,cm_Interim_Approval_Type__c = MapApprovalData.get('Deposit Exception'),cm_Comments__c= 'Cash Deposit Amount is: '+dcash,Assign_To__c= objOpportunity.cm_Sales_Executive_Manager__c,Payment_Option__c = strSelCreditCardOption,cm_Selected_Units_New__c =objOpportunity.Name ));    
                }
                else if(mapCSdata!=null && buildingName!='' && mapCSdata.get(buildingName) != null){
                    if((DepositMethod== 'Credit card' || DepositMethod== 'Cash') && dcash != null && decimal.valueof(dcash) < mapCSdata.get(buildingName)  && MapApprovalData.get('Deposit Exception')!=null){
                         lstInterim.add(new cm_Interim_Approvals__c(cm_Opportunity__c = objOpportunity.id,Submit_for_Approval__c = true, cm_Interim_Approval_Type__c = MapApprovalData.get('Deposit Exception'),cm_Comments__c= 'Deposit Amount is: '+dcash,Assign_To__c= objOpportunity.cm_Sales_Executive_Manager__c,Payment_Option__c = strSelCreditCardOption,cm_Selected_Units_New__c =objOpportunity.Name ));    
                    }
                }
                
                //added by Charan so that it works for multi booking even to raise referral special approval
                if(mpCreateReferrer.containsKey(objOpportunity.Id) && mpCreateReferrer.get(objOpportunity.Id) && MapApprovalData.get('Referral Special Approval') != null){
                    lstInterim.add(new cm_Interim_Approvals__c(cm_Opportunity__c = objOpportunity.id,Submit_for_Approval__c = true, cm_Interim_Approval_Type__c = MapApprovalData.get('Referral Special Approval'),Payment_Option__c = strSelCreditCardOption,cm_Selected_Units_New__c = objOpportunity.Name ));
                }
            }
            
            system.debug('****lstInterim'+lstInterim);
            if(lstInterim!=null && lstInterim.size() >0){
                insert lstInterim;
            for(Opportunity opp:lstOpp){
                list<Messaging.SingleEmailMessage> lstMails = sendEmail(opp,'submit');
                Messaging.sendEmail(lstMails);
            }
            return 'success';
            }
        }catch(exception ex){
            return ex.getMessage();
        }
        return '';
     }
     /*
        Method Name : sendEmail 
        Description : Interim Approvals to sales person Manager
    */  
    public static list<Messaging.SingleEmailMessage> sendEmail(Opportunity Opp,string type) {
    list<Messaging.SingleEmailMessage> lstMails = new list<Messaging.SingleEmailMessage>();
    try{
        
        User u =new user();
        if(opp.cm_Sales_Person__c!=null)
        u = [Select id,Email, ManagerId,Approving_Manager__c,Approving_Manager__r.Email, Manager.Email from user where id =: opp.cm_Sales_Person__c]; 
        //New instance of a single email message
        if(u.Approving_Manager__r.Email!= null){ 
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            // Who you are sending the email to
            mail.setTargetObjectId(userinfo.getUserId());
            // The email template ID used for the email
            mail.setWhatId(Opp.id);   
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setReplyTo('noreply@emaar.com');
            mail.setSaveAsActivity(false); 
            if(type == 'submit'){
            mail.setToAddresses(new List<String>{u.Approving_Manager__r.Email});
            mail.setSenderDisplayName('Emaar Properties - Special Approval');
            mail.setTemplateId( [select id from EmailTemplate where DeveloperName='Interim_Approval_Template_VF'].id );
            }else if(type == 'Approve'){
            mail.setToAddresses(new List<String>{u.Email});
            mail.setSenderDisplayName('Emaar Properties - Special Approval Status');
            mail.setTemplateId( [select id from EmailTemplate where DeveloperName='Interim_Approved_Template_VF'].id );
            }
            Savepoint sp = Database.setSavepoint();
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            Database.rollback(sp); // Email will not send as it is rolled Back
            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.setToAddresses(mail.getToAddresses());
            emailToSend.setPlainTextBody(mail.getPlainTextBody());
            emailToSend.setHTMLBody(mail.getHTMLBody());
            emailToSend.setSubject(mail.getSubject());
            lstMails.add(emailToSend);
        }
    }catch(exception ex){
    }
        return lstMails;
    }
     /*

        Method Name : paymentApproval

        Description : This method is used to update the Opportunity and send emails to finance Team and Update Inventory to Booked status

    */

    webservice static String paymentApproval_multiple (list<id> setOppIds,string selPaymentMode,string DepositMethod,string selChequeOption,string strSelCreditCardOption,string DaysTohold,string dCash) {

     string strmessage = '';

     try {

         system.debug('**************INSIDE PAYMENT APPROVAL******setOppIds**********'+setOppIds);
         system.debug('**************INSIDE PAYMENT APPROVAL******selPaymentMode**********'+selPaymentMode);
         system.debug('**************INSIDE PAYMENT APPROVAL******DepositMethod**********'+DepositMethod);
         system.debug('**************INSIDE PAYMENT APPROVAL******selChequeOption**********'+selChequeOption);
         system.debug('**************INSIDE PAYMENT APPROVAL******strSelCreditCardOption**********'+strSelCreditCardOption);
         system.debug('**************INSIDE PAYMENT APPROVAL******DaysTohold**********'+DaysTohold);

         system.debug('**************INSIDE PAYMENT APPROVAL******dCash**********'+dCash);

         list<Opportunity> LstOppToupdate = new list<Opportunity>();

         string advisorId = userinfo.getUserId();

          // Assign opportunity ro Admin Group.

         Map<String,Mobile_Configurations__c> mpConfigs = Mobile_Configurations__c.getAll();

         list<user> lstAdminUser = [select id,Name,Email from user where username=: mpConfigs.get('Configuration').cm_Sales_Admin_Username__c];

         string PAlocation ='';

         string AccountId ='';

         map<string,boolean> mapOppcamptype = new map<string,Boolean>();

         if(setOppIds!=null && setOppIds.size() >0){

            for(Opportunity_Property__c OPPProp: [ select id, Name, cm_Property_Inventory__r.cm_Related_Campaign__c,cm_Opportunity__r.Advisor_Location__c,cm_Opportunity__r.AccountId,

                                                           cm_Property_Inventory__r.cm_Related_Campaign__r.Is_release_launch_Campaign__c from Opportunity_Property__c

                                                           where cm_Opportunity__c IN:setOppIds and cm_Property_Inventory__c!=null and cm_Property_Inventory__r.cm_Related_Campaign__c!=null]){

                mapOppcamptype.put(OPPProp.cm_Opportunity__c,OPPProp.cm_Property_Inventory__r.cm_Related_Campaign__r.Is_release_launch_Campaign__c);

                PAlocation = OPPProp.cm_Opportunity__r.Advisor_Location__c;

                AccountId = OPPProp.cm_Opportunity__r.AccountId;

            }

            system.debug('*******mapOppcamptype'+mapOppcamptype);

            system.debug('*******PAlocation'+PAlocation);

            system.debug('*******AccountId'+AccountId);

           

             string NextOwnerId = '';
            //v1.1
            map<string,id> teamSalesAdmin = new map<string,id>(); 
            for(Configuration__c con : [select Sales_Admin__c,Team__c from Configuration__c where recordtype.developername='SE_to_Sales_Admin_Auto_Assignment' and Sales_Admin__c!=null and Team__c!=null]){
                teamSalesAdmin.put(con.team__c,con.Sales_Admin__c);
            }

             if(teamSalesAdmin.containsKey(PAlocation)){

                 NextOwnerId = teamSalesAdmin.get(PAlocation);

             }else{

                 NextOwnerId = SalesAdminAssignment.AssignDefaultAdmin(advisorId);

                 if(NextOwnerId == ''){

                    NextOwnerId = SalesAdminAssignment.Check_Last_7_Days(AccountId);

                 }

                 if(NextOwnerId == ''){

                     NextOwnerId = SalesAdminAssignment.GetNextOwnerId();

                 }

             }

            

             system.debug('*******NextOwnerId'+NextOwnerId);

             string salesAdminUserId = '';

             if(lstAdminUser!=null && lstAdminUser.size() >0){

                           salesAdminUserId = lstAdminUser[0].id;

              }

              system.debug('*******salesAdminUserId'+salesAdminUserId);

             

             for(string oppId:mapOppcamptype.keyset()){

                 Opportunity objOpportunity = new opportunity(id=oppId);

                  objOpportunity.cm_Payment_Mode__c = selPaymentMode;

                 if(DepositMethod!=null && DepositMethod!='')

                     objOpportunity.cm_Deposit_Method__c = DepositMethod;

                 if(selChequeOption!=null && selChequeOption!='')

                    objOpportunity.Payment_Options__c = selChequeOption;

                if(strSelCreditCardOption!=null && strSelCreditCardOption!='')

                     objOpportunity.cm_Credit_Card_Payment_Options__c = strSelCreditCardOption;

                 if(strSelCreditCardOption == 'Online Payment Link'){

                     //objOpportunity.credit_card_payment_status__c = 'Pending';

                 }

                 if(DaysTohold!=null && DaysTohold!='')   

                    objOpportunity.cm_Days_to_Hold_Cheque__c = decimal.valueof(DaysTohold);

                 if(dCash!=null && dCash!='')

                    objOpportunity.cm_Deposit_Amount__c = decimal.valueof(dCash);

                 if(mapOppcamptype!=null && mapOppcamptype.get(oppId)!=null){

                     if(mapOppcamptype.get(oppId) == true){

                         objOpportunity.ownerId = salesAdminUserId;

                     }else{

                         objOpportunity.ownerId = NextOwnerId;

                     }

                 }

                 objOpportunity.recordTypeId = CM_EmaarUtils.getRecordTypeId('Opportunity','Pending_Admin_Approval');

                 objOpportunity.cm_Approval_Status__c = 'Pending with Admin';

                 objOpportunity.stageName = 'Pending Approval';

                 objOpportunity.Cm_is_Payment_done__c = true;

                 LstOppToupdate.add(objOpportunity);

             }

             update LstOppToupdate;

            

             list<Opportunity_Property__c> lstOpportunityProperty = [select id,name,cm_Property_Inventory__c,cm_Opportunity__c from Opportunity_Property__c where cm_Opportunity__c IN:mapOppcamptype.keyset()];

             system.debug('****lstOpportunityProperty'+lstOpportunityProperty);

             set<id> setProInv = new set<id>();

             for(Opportunity_Property__c objProINV:lstOpportunityProperty){

                 setProInv.add(objProINV.cm_Property_Inventory__c);

             }

             list<Property_Inventory__c> lstProInv = [select id,Payment_Confirmation__c from Property_Inventory__c where ID IN:setProInv ];

             for(Property_Inventory__c objProInV:lstProInv){

                 objProInV.Payment_Confirmation__c = true;

             }

             system.debug('****lstProInv'+lstProInv);

            

             update lstProInv;

            

             strmessage =  'SUCCESS';

         }

     }

     catch (Exception e) {

         system.debug('**********exception***'+e.getMessage());

         strmessage =  e.getMessage();

     }   

     return strmessage;

    }
}