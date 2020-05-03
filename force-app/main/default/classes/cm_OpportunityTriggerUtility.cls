/*
   Author : Hari / Charan
   Description :
   Date : 
   Modification History :
// ADDED ON 15/01/2016  V1.0  Added to make null the default schedule type on Opportunity - NITESH Requested
v1.1    24-Apr-2017     Ravi        Added the logic to Submit the Claim SR for Referer
v1.2    16-May-2017     Pavithra    Modified Opportunity assignment logic to add Opportunity count 
v1.3    08-Jun-2017     Ravi        Added the logic to Generate the SPA for Opportunity created from Broker App
v1.4    03-Sep-2017     Sandeep     Invoking OpportunityDistribution_SE for Opportunity Distribution for SE.
v1.5    08-Oct-2017     Ravi        Added the logic to reassign the Special Approvals if they are assigned to 'Sales Admin'
v1.6    16/10/2017      Ravi        Added the logic to send the Primary Contact details separatly instead of sending in ORDER Creation
v1.7    19-Dec-2017     Vikram      Added the logic for KSA Team Member addition to Opp team member.
v1.8    31/Jan/2018     Ravi        Added the logic to reparent the Opprotunity if the Account got merged into another
v1.9    05/APR/2018     Ravi        Modified the logic to Send Primary Contact details to ORACLE when unit got reserved by sales admin as pet Nitesh
v2.0    14/Apr/2018     Ajaz        EPESI-1405 : Code changes to cancel all pending apporvals when an opportunity is lost.
v2.1    23/Apr/2018     Ravi        a. EPESI-1478 : Too many SOQL Queries - 101 : Prod Bug
                                    b. When Property Advisor Management user is creating the Opportunity, Sales person is not getting populated
v2.2  26/04/2018      Ravi        Added the logic to send the Secondary Contact details when Order closed lost
v2.3    29/04/2018      Vikramm     Changed the logic to reassign the LR Waiver to new Owner in case of Opportunity owner change.
*/ 
global without sharing class cm_OpportunityTriggerUtility{ 

    public static map<Id,User> mpOwners = new map<Id,User>([Select id, managerId,Approving_Manager__c,UserRole.Name,UserName,Restrict_Booking__c from User where isActive = true]); 
    public static map<Id,User> recUserMap = new map<Id,User>([Select id from User where Profile.Name LIKE '%Receptionist%' and isActive = true]);
    public static map<id,User> mpProps = new map<Id,User>([Select id,managerId,Approving_Manager__c,cm_user_code__c,cm_team_code__c from User where profile.name like '%Property%' and isActive=true and Exclude_assignment__c = false]);
    public static Profile propAdvisorProfile = [Select id, name from Profile where name = 'Property Advisor'];
    public static map<id,User> mpAdmins = new map<Id,User>([Select id,managerId,Approving_Manager__c,cm_user_code__c,cm_team_code__c from User where profile.name like '%Sales Admin%' and isActive = true]);
    
    //v1.6
    public static Boolean isSyncCall = false;
    public static Boolean isClosedAlready = false; // v1.6 - Sales Order Cancellation has been calling twice
    
    //added by ravi to avoid too many soql for multi booking
    static map<id,Account> mpAccounts = new map<Id,Account>(); //v2.1
    
    public static void beforeHandler(list<Opportunity> lstNew, map<Id,Opportunity> mpold, boolean isInsert, boolean isUpdate){
        list<Opportunity> lstToprocess = new list<Opportunity>();
        
        string strRoleName = '';
        List<string> ksaTeamUserNames = new List<string>();
        map<string, User> ksaTeamUsers = new map<string, User>();
        set<id> accountIds = new set<id>();
        map<id,User> MapUserData = new map<id,User>();
        set<Id> setOpporOwnerIds = new set<id>();
        set<Id> stCampaigns = new set<Id>();
        map<id,Campaign> mpCampaigns = new map<Id,Campaign>();
        map<String,cm_Administrator_Settings__c> mpSettings = cm_Administrator_Settings__c.getAll(); 
        map<String,Mobile_Configurations__c> mpConfigs = Mobile_Configurations__c.getAll();
        User currUsr;
        if (mpOwners != null)
            currUsr = mpOwners.get(UserInfo.getUserId());
        
        /* Adeel - Commenting this one to save class, TODO: will look again */
        /*
        map<String,cm_KSA_Team_Members__c> mpKSASettings = cm_KSA_Team_Members__c.getAll();     
        for(cm_KSA_Team_Members__c mem: mpKSASettings.values()) {
            ksaTeamUserNames.add(mem.KSA_Team_Member__c);
        }
        */
        if(currUsr != null && currUsr.Restrict_Booking__c == true)
            for(User usr: [SELECT id, UserName, managerId,Approving_Manager__c,UserRole.Name,Restrict_Booking__c FROM User WHERE isActive = true AND UserName IN :ksaTeamUserNames])  {
                ksaTeamUsers.put(usr.UserName, usr);
              }

          
        for(Opportunity opp: lstNew){
          if(opp.campaignId != null){
            stCampaigns.add(opp.CampaignId);
         }   
        }
        
        if(!stCampaigns.isEmpty()){
          
          for(Campaign camp : [Select id,cm_booking_timer__c,type from Campaign where id In: stCampaigns]){
            mpCampaigns.put(camp.Id,Camp);
          }
        }
        
        for(Opportunity opp: lstNew){
            setOpporOwnerIds.add(opp.OWnerId);
            //Fire Ownership Assignment
            if(isInsert && recUserMap.containsKey(UserInfo.getUserId())){
                  opp.OwnerId = UserInfo.getUserId();
                  opp.cm_status__c = 'Verified';
            }   
            
            if(isUpdate && opp.cm_approval_Status__c == 'Rejection approved by Sales Manager' && opp.cm_approval_Status__c != mpOld.get(opp.Id).cm_approval_Status__c){
                if(cm_OpportunityTriggerUtility.isClosedAlready == false) //v1.6
                    Cm_BookingUtils.ApproveAdminRejection(opp.id,'Approval Rejection'); 
            }   
                  
            if(opp.CampaignId != null && mpCampaigns.containsKey(opp.CampaignId)){
                  opp.cm_booking_timer__c = mpCampaigns.get(opp.campaignId).cm_booking_timer__c;
                  opp.cm_Campaign_Type__c = mpCampaigns.get(opp.campaignId).Type;
            }
            else if(mpSettings.containsKey('ADMIN'))
                  opp.cm_booking_timer__c = mpSettings.get('ADMIN').cm_Booking_Timer__c; 
            
            if(opp.cm_Approval_Status__c == 'Payment Processing' && opp.Property_Booked_Date__c != null && opp.cm_Booking_Cancellation_Time__c == null){
                  DateTime bookedtime = opp.Property_Booked_Date__c.addMinutes(integer.valueof(label.BookingCancellationTime));
                  date finalDT = date.newInstance(bookedtime.year(),bookedtime.month(),bookedtime.day());
                  time finalTime = Time.newInstance(bookedtime.hour(),bookedtime.minute(),0,0);
                  Datetime finalDatetime = Datetime.newInstance(finalDT,finalTime);        
                  opp.cm_Booking_Cancellation_Time__c = finalDatetime;
            }
            
            
            if(isInsert && currUsr != null && currUsr.Restrict_Booking__c){
            	/* Adeel - Commenting this one to save, TODO: will look again */
            	/*
                if(ksaTeamUsers != null && mpKSASettings != null && mpKSASettings.get(currUsr.UserName) != null && 
                    mpKSASettings.get(currUsr.UserName).KSA_Team_Member__c != null)
                opp.Ownerid = ksaTeamUsers.get(mpKSASettings.get(currUsr.UserName).KSA_Team_Member__c).Id;
                */
            }
            else if(isInsert && opp.cm_Sales_Person__c != null)
                opp.Ownerid = opp.cm_Sales_Person__c;
               
            boolean isReceptionist = recUserMap.containsKey(UserInfo.getUserId());
            boolean isPropertyAdvisor = mpProps.containsKey(UserInfo.getUserId());
            //if(isInsert && mpProps.containskey(opp.OwnerId) && (recUserMap.containsKey(UserInfo.getUserId()) || opp.Ownerid == UserInfo.getUserId()))           if(isInsert && mpProps.containskey(opp.OwnerId))
            if(isInsert && (mpProps.containskey(opp.OwnerId) || recUserMap.containsKey(UserInfo.getUserId()))){
                if(isReceptionist || isPropertyAdvisor){
                    opp.em_Contacted__c = true;
                }
            }
                  
                
            if(isUpdate){
                  if(!recUserMap.containsKey(mpOld.get(opp.id).ownerid) && opp.ownerid != mpOld.get(opp.id).ownerid){
                    lstToprocess.add(opp);
                  }
                  
                  if(mpConfigs.containsKey('Configuration') && opp.OwnerId != mpConfigs.get('Configuration').Sales_Admin_User_ID__c && mpOld.get(opp.Id).OwnerId == mpConfigs.get('Configuration').Sales_Admin_User_ID__c){
                    if(opp.Date_Assigned_to_Sales_Admin__c == null){
                    opp.Date_Assigned_to_Sales_Admin__c = System.Now();
                    opp.Last_Admin_Assignment_Date__c = System.Now();
                    } 
                    else
                    opp.Last_Admin_Assignment_Date__c = System.Now();
                  }
                  if(mpAdmins.containsKey(opp.ownerId) && opp.OwnerId != mpold.get(opp.Id).ownerId){
                    opp.Last_Admin_Assignment_Date__c = System.Now();
                    
                  }
            }
            system.debug('*******lstToprocess'+lstToprocess);
            if(mpAccounts.containsKey(opp.AccountId) == false) //v2.1
                accountIds.add(opp.AccountId);      
        }
            
        //map<id,Account> mpAccounts = new map<Id,Account>();
        if(!accountIds.isEmpty()){
            for(Account acc : [Select id, OwnerId, Owner.isActive from Account where Id in: accountIds]){
                  mpAccounts.put(acc.id,acc);
            }
        }
        
        list<AccountTeamMember> lstAccMembers = new list<AccountTeamMember>();
        list<AccountShare> sharingRules = new list<AccountShare>();
        MapUserData = new map<id,User>([Select id, managerId,Approving_Manager__c from User where isActive = true and ID IN:setOpporOwnerIds]); 
        for(Opportunity opp: lstNew){
            //v2.1.b - amended the condiftion for Property Advisor Management - 005580000010PfG

            /* Adeel - Commenting this one to save */
            /*
             if(isInsert && opp.cm_Site_lead__c == false && (mpProps.containsKey(opp.OwnerId) || UserInfo.getProfileId() == propAdvisorProfile.Id || UserInfo.getUserId() == Label.PropertyAdviserManagementUserId  )){
               opp.cm_Sales_Person__c =  opp.OwnerId;
            }
            */
         
             if(isUpdate && mpProps.containsKey(opp.OwnerId) && opp.OwnerId != mpOld.get(opp.Id).OwnerId){
                  opp.cm_Sales_Person__c =  opp.OwnerId;
                  if(opp.AccountId != null){
                    AccountTeamMember atm = new AccountTeamMember(AccountId = opp.AccountId,UserId=opp.OwnerId,TeamMemberRole='Sales Rep');
                    lstAccMembers.add(atm); 
                    
                    if(opp.OwnerId != null && mpAccounts.containsKey(opp.AccountId) && mpAccounts.get(opp.AccountId).ownerId != opp.OwnerId)
                        sharingRules.add(new AccountShare(AccountAccessLevel = 'Edit', OpportunityAccessLevel = 'Edit', CaseAccessLevel = 'Edit', UserOrGroupId = opp.Ownerid, AccountId = opp.AccountId));
                  }
             }
              
             if(opp.cm_Sales_Person__c != null && MapUserData.get(opp.cm_Sales_Person__c)!=null){
                   // Commented by VV - Manager Change
                   //System.debug('>>>>>>Update Manager>>>>>>>>>>>>'+MapUserData.get(opp.cm_Sales_Person__c).managerId);
                   //opp.cm_Sales_Executive_Manager__c = MapUserData.get(opp.cm_Sales_Person__c).managerId;
                   // Added by VV - Manager Change
                   opp.cm_Sales_Executive_Manager__c = MapUserData.get(opp.cm_Sales_Person__c).Approving_Manager__c;
             }
        }
        try{ 
        //      if(!sharingRules.isEmpty())
        //      insert sharingRules;
            if(!lstAccMembers.isEmpty())
                  insert lstAccMembers;
        
         }catch(exception ex){
            system.debug('**********exception'+ex.getMessage());
         }
        
        if(lstToprocess!=null && lstToprocess.size() >0){
            map<Id,Id> mpOTM = new map<Id,Id>();
            for(OpportunityTeamMember otm: [Select id,UserId,OpportunityId from OpportunityTeamMember where OpportunityId in: lstNew and TeamMemberRole='Property Advisor']){
                  mpOTM.put(otm.OpportunityId, otm.UserId);
            }
            for(Opportunity opp: lstNew){
                  system.debug('******mpOTM'+mpOTM);
                  if(opp.cm_Sales_Executive_Manager__c == null && mpOTM.containsKey(opp.Id) && mpOwners.containsKey(mpOTM.get(opp.Id))){
                    // Commented by VV - Manager Change
                    //opp.cm_Sales_Executive_Manager__c = mpOwners.get(mpOTM.get(opp.Id)).managerId;
                    // Added by VV - Manager Change
                    opp.cm_Sales_Executive_Manager__c = mpOwners.get(mpOTM.get(opp.Id)).Approving_Manager__c;
                  }
            }
        }
    }
    
    //v1.8 
    public static void beforeTriggerHandler(boolean isInsert, boolean isUpdate, list<Opportunity> lstNewOpps, map<Id,Opportunity> mapOldOpps){
        
        if(isUpdate)
            reParentMergedOpps(lstNewOpps,mapOldOpps);
    }
    
    public static void afterHandler(list<Opportunity> lstOpp, map<Id,Opportunity> mpold, boolean isInsert, boolean isUpdate){
        list<AccountTeamMember> lstAccMembers = new list<AccountTeamMember>();
        list<AccountShare> sharingRules = new list<AccountShare>();
        
        List<string> ksaTeamUserNames = new List<string>();
        map<string, User> ksaTeamUsers = new map<string, User>();
        // Adeel - Commenting this one 
        //map<String,cm_KSA_Team_Members__c> mpKSASettings = cm_KSA_Team_Members__c.getAll();
        User currUsr;
        if (mpOwners != null)
            currUsr = mpOwners.get(UserInfo.getUserId());
        
        /*
        Adeel - Commenting this one
        for(cm_KSA_Team_Members__c mem: mpKSASettings.values()) {
            ksaTeamUserNames.add(mem.KSA_Team_Member__c);
        }
        */
        if(currUsr != null && currUsr.Restrict_Booking__c == true)
            for(User usr: [SELECT id, UserName, managerId,Approving_Manager__c,UserRole.Name,Restrict_Booking__c FROM User WHERE isActive = true AND UserName IN :ksaTeamUserNames]){
                ksaTeamUsers.put(usr.UserName, usr);
            }

        list<Opportunity> lstProcess = new list<Opportunity>();
        string strRoleName='';
        
        //v1.3
        list<Id> lstOppIds = new list<Id>();
        
        system.debug('**User Info **'+Userinfo.getUserRoleId());
        if(mpOwners.get(Userinfo.getUserRoleId())!=null){
        strRoleName = mpOwners.get(Userinfo.getUserRoleId()).userRole.name;
        }
        
        system.debug('***strRoleName'+strRoleName);
         
        if (isInsert == true || isUpdate == true) {
            list<OpportunityTeamMember> oppTeam = new list<OpportunityTeamMember>();    //Define a list to hold all the updates 
            list<Id> ownerIds = new list<Id>();
            for (Opportunity opp : lstOpp) {                //Loop through all records in the trigger
                  ownerIds.add(opp.ownerId);
            }
            
            for (Opportunity opp : lstOpp) { //Loop through all records in the trigger
                  // VV Added - For online sales bookings a new opportunity team member will be added.
                  if(opp.Is_From_Online_Sales__c){
                    OpportunityTeamMember otm = new OpportunityTeamMember(
                    OpportunityID = opp.Id,
                    UserId = Label.EmaarOnlineSalesOpportunityTeamMembers,
                     TeamMemberRole = 'Sales Admin',OpportunityAccessLevel ='Edit');
                     oppTeam.add(otm);   
                  } 
                  if(isInsert && !recUserMap.containsKey(UserInfo.getUserid()) && opp.cm_Sales_Person__c == null && opp.Is_From_Broker_App__c==false && opp.cm_sales_Person__c == null && opp.cm_direct_conversion__c == false && opp.cm_Disable_Assignment__c == false && strRoleName!='Property Advisor'){
                    System.debug('>>>inside else>>>');  
                    lstProcess.add(opp);
                  }
                  //Site Opps
                  else if(isInsert && opp.cm_site_Lead__c && opp.cm_Direct_conversion__c && opp.cm_Sales_Person__c == null){
                    //System.debug('>>>inside else>>>');  
                    lstProcess.add(opp);
                  }
                  else{
                    if(mpOwners.Containskey(opp.ownerid)){
                        Boolean restrictBooking = currUsr.Restrict_Booking__c;
                        //v1.7 KSA Changes
                        if (restrictBooking == true) {
                            String teamMemberRole = 'Property Advisor';
                            OpportunityTeamMember otm = new OpportunityTeamMember(
                            OpportunityID = opp.Id,
                            // Adeel commenting this one, added hard coded id of admin
                            //UserId = ksaTeamUsers.get(mpKSASettings.get(currUsr.UserName).KSA_Team_Member__c).Id,
                            UserId = '0051r000007gKz7',
                            TeamMemberRole = teamMemberRole,OpportunityAccessLevel ='Edit');
                            oppTeam.add(otm);
                            OpportunityTeamMember otm2 = new OpportunityTeamMember(
                            OpportunityID = opp.Id,
                            UserId = UserInfo.getUserId(),
                            TeamMemberRole = teamMemberRole,OpportunityAccessLevel ='Edit');
                            oppTeam.add(otm2);     //Since users can manually added team members, I created a custom field to indicate team members added by the system 
                            
                            // Adeel Commenting this one
                            //AccountTeamMember atm = new AccountTeamMember(AccountId = opp.AccountId,UserId=ksaTeamUsers.get(mpKSASettings.get(currUsr.UserName).KSA_Team_Member__c).Id,TeamMemberRole=teamMemberRole);
                            //lstAccMembers.add(atm);
                            AccountTeamMember atm1 = new AccountTeamMember(AccountId = opp.AccountId,UserId=UserInfo.getUserId(),TeamMemberRole=teamMemberRole);
                            lstAccMembers.add(atm1);
                            //sharingRules.add(new AccountShare(AccountAccessLevel = 'Edit', OpportunityAccessLevel = 'Edit', UserOrGroupId = usr[0].Id, AccountId =opp.AccountId));
                        }else{
                            String userRole = mpOwners.get(opp.ownerid).UserRole.Name;
                            String teamMemberRole;
                            if (userRole != null && userRole != '') {
                            
                                if (userRole.contains('Property Advisor'))
                                    teamMemberRole = 'Property Advisor';
                                else if (userRole.contains('Finance'))
                                    teamMemberRole = 'Finance';
                                else if (userRole.contains('Sales Admin'))
                                    teamMemberRole = 'Sales Admin';
                                system.debug('>>>>>>> teamMemberRole: ' + teamMemberRole);    
                                if (teamMemberRole == 'Property Advisor' || teamMemberRole == 'Finance' || teamMemberRole == 'Sales Admin') {
                                    OpportunityTeamMember otm = new OpportunityTeamMember(
                                    OpportunityID = opp.Id,
                                    UserId=opp.OwnerId,
                                    TeamMemberRole = teamMemberRole,OpportunityAccessLevel ='None');     //Since users can manually added team members, I created a custom field to indicate team members added by the system 
                                    oppTeam.add(otm);
                                    
                                    //AccountTeamMember atm = new AccountTeamMember(AccountId = opp.AccountId,UserId=restrictBooking == true?UserInfo.getUserId():opp.OwnerId,TeamMemberRole=teamMemberRole);
                                    AccountTeamMember atm = new AccountTeamMember(AccountId = opp.AccountId,UserId = opp.OwnerId,TeamMemberRole=teamMemberRole);
                                    lstAccMembers.add(atm);
                                    
                                    sharingRules.add(new AccountShare(RowCause='Manual', AccountAccessLevel = 'Edit', OpportunityAccessLevel = 'None', UserOrGroupId = opp.OwnerId, AccountId =opp.AccountId));
            
                                }
                            }
                        }
                    }
                }
                  
                //v1.3
                if(isUpdate && mpold != null && opp.Generate_SPA__c && mpold.get(opp.Id).Generate_SPA__c == false){
                    lstOppIds.add(opp.Id);
                }
            }
            
            if(!lstOppIds.isEmpty())
                GenerateBrokerAppSPA(lstOppIds);
            
            try{
                if(isInsert && !lstProcess.isEmpty())
                  //v1.2
                  //TODO:Adeel commending this one, need to add class later (Line : 356)
                  //OpportunityAssignmentUtility.assignOpportunities(lstProcess);
                  
                  //cm_OpportunityTriggerUtility.assignOwnership(lstProcess);
                  //v1.4
                  //OpportunityDistribution_SE.AssignOpportunity_SE(lstProcess);
             insert oppTeam;
             if (sharingRules.size() > 0) {
                 system.debug('Inserting Sharing Rules '+ sharingRules);
                 insert sharingRules;
             
             }
             insert lstAccMembers;
                 
            }catch(exception ex){
                  system.debug(ex.getLineNumber()+'****Exception ex '+ex.getMessage());
            }
        }
    }
  
  //v1.1
  public static void updateReferrerTarget(map<Id,Opportunity> mapOpps){
  		/* Adeel - Commenting this one */
  		/*
        if(mapOpps != null && !mapOpps.isEmpty()){
            decimal dAmt;
            map<Id,decimal> mapRefTarget = new map<Id,decimal>();
            map<Id,Id> mapRefTargetIds = new map<Id,Id>();
            // Adeel Commenting this one
            //map<Id,cm_User_Targets__c> mapUserTargets = new map<Id,cm_User_Targets__c>();
            
            for(Account objRef : [select Id,Target__c,(select Id,Referral_Achieved__c from User_Targets__r) from Account where Id IN (select Referral__c from Opportunity where Id IN : mapOpps.keySet() AND Referral__c != null) ]){
                dAmt = 0;
                for(cm_User_Targets__c objUT : objRef.User_Targets__r){
                  dAmt += objUT.Referral_Achieved__c != null ? objUT.Referral_Achieved__c : 0;
                  mapRefTargetIds.put(objRef.Id,objUT.Id);
                }
                mapRefTarget.put(objRef.Id,dAmt);
            }
            
            if(!mapRefTargetIds.isEmpty()){
                dAmt = 0;
                for(Opportunity_Property__c objOP : [select id,cm_opportunity__c,cm_Selling_Price__c,cm_opportunity__r.Referral__c from Opportunity_Property__c where cm_Opportunity__c IN : mapOpps.keySet() AND cm_Selling_Price__c != null AND cm_opportunity__r.Referral__c != null]){
                  dAmt = mapRefTarget.containsKey(objOP.cm_opportunity__r.Referral__c) ? mapRefTarget.get(objOP.cm_opportunity__r.Referral__c)+objOP.cm_Selling_Price__c : objOP.cm_Selling_Price__c;
                  mapRefTarget.put(objOP.cm_opportunity__r.Referral__c,dAmt);
                }
                Id targetId;
                for(Id RefId : mapRefTarget.keySet()){
                  targetId = mapRefTargetIds.get(RefId);
                  if(targetId != null){
                mapUserTargets.put(targetId , new cm_User_Targets__c(Id=targetId,Referral_Achieved__c=mapRefTarget.get(RefId)) );
                  }
                }
                if(!mapUserTargets.isEmpty()){
                  update mapUserTargets.values();
                }
            }
        }
        */
  }
  
  //v1.3
  @future(callout=true)
  public static void GenerateBrokerAppSPA(list<Id> lstOppIds){
  	// Adeel - Commenting this one
  	/*
    for(Opportunity_Property__c obj : [select Id from Opportunity_Property__c where cm_Opportunity__c IN : lstOppIds])
        RestServiceToGenerateDDPUrl.ResponseHandler objDDPRes = RestServiceToGenerateDDPUrl.GenerateUrl(obj.Id, 'Opportunity Property', 'Opportunity_Property__c', 'SPA');
    */    
  }
  
    //v1.5
    public static void AfterUpdateTransactions(list<Opportunity> lstNewOpps, map<Id,Opportunity> mapOldOpps){
        updateSpecialApprovals(lstNewOpps, mapOldOpps);
        //v1.9
        pushPrimaryContactDetails(lstNewOpps, mapOldOpps); //Send the Primary Contact Details to ORACLE when Order became reservice
        
        // v2.0 code changes starts here
        Set<Id> opptyIdSet = new Set<Id>();
        for(Opportunity opp : lstNewOpps){
            if(opp.StageName =='Closed Lost' && mapOldOpps.get(opp.Id).StageName !='Closed Lost'){
                opptyIdSet.add(opp.id);
            }
        }
        if(opptyIdSet != null && !opptyIdSet.isEmpty())
            cancelPendingApprovals(opptyIdSet);
        // v2.0 code changes ends here
    }
    
    //v1.5 - added isolated method to update the special approvals
    public static void updateSpecialApprovals(list<Opportunity> lstNewOpps, map<Id,Opportunity> mapOldOpps){
        try{
            
            map<Id,Id> mapOwnerIds = new map<Id,Id>();
            map<string,Mobile_Configurations__c> mpConfigs = Mobile_Configurations__c.getAll();
            List<Id> oppIds = new List<Id>();
            
            String SaleAdminId;
            if(mpConfigs != null && mpConfigs.containsKey('Configuration')){
                    for( User objU : [select id,Name,Email from user where username=:mpConfigs.get('Configuration').cm_Sales_Admin_Username__c])
                  SaleAdminId = objU.Id;
            }
            
            for(Opportunity objOpp : lstNewOpps){
                oppIds.add(objOpp.Id);
                /*if(SaleAdminId != null && mapOldOpps != null && mapOldOpps.containsKey(objOpp.Id) && 
                  mapOldOpps.get(objOpp.Id).OwnerId == SaleAdminId && objOpp.OwnerId != mapOldOpps.get(objOpp.Id).OwnerId && cm_OpportunityTriggerUtility.mpAdmins.containsKey(objOpp.OwnerId) ){
                  mapOwnerIds.put(objOpp.Id,objOpp.OwnerId);
                }*/
              
                if(mapOldOpps != null && mapOldOpps.containsKey(objOpp.Id) && 
                  ((SaleAdminId != null && mapOldOpps.get(objOpp.Id).OwnerId == SaleAdminId) || cm_OpportunityTriggerUtility.mpAdmins.containsKey(mapOldOpps.get(objOpp.Id).OwnerId)) 
                  && objOpp.OwnerId != mapOldOpps.get(objOpp.Id).OwnerId && cm_OpportunityTriggerUtility.mpAdmins.containsKey(objOpp.OwnerId) ){
                    mapOwnerIds.put(objOpp.Id,objOpp.OwnerId);
                }
            }
            
            if(!mapOwnerIds.isEmpty()){
                map<Id,cm_Interim_Approvals__c> mapSpApprovals = new map<Id,cm_Interim_Approvals__c>();
                list<ProcessInstanceWorkItem> lstItems = new list<ProcessInstanceWorkItem>();
                list<cm_Interim_Approvals__c> lstApprovals = new list<cm_Interim_Approvals__c>();
                cm_Interim_Approvals__c objApproval;
                mapSpApprovals = new map<Id,cm_Interim_Approvals__c>([select Id,Special_Approval_Type__c,Approval_Status__c,cm_Opportunity__c,cm_Opportunity__r.ownerId,Next_Approver__c,Assign_To__c,First_Level_Approver__c,Second_Level_Approver__c,Third_Level_Approver__c,Opportunity_Owner__c from cm_Interim_Approvals__c where cm_Opportunity__c IN : mapOwnerIds.keySet() AND Approval_Status__c != 'Sales Manager Approved' AND Approval_Status__c != 'Sales Manager Rejected' AND Approval_Status__c != 'Sales Manager Rejected' ]);
                Id oppId;
                set<Id> reassignIds = new set<Id>();
                
                for(cm_Interim_Approvals__c objApp : mapSpApprovals.values()){
                  if(objApp.Next_Approver__c ==  SaleAdminId || objApp.Assign_To__c ==  SaleAdminId ||  objApp.First_Level_Approver__c ==  SaleAdminId || objApp.Second_Level_Approver__c ==  SaleAdminId ||  objApp.Third_Level_Approver__c ==  SaleAdminId || objApp.Opportunity_Owner__c ==  SaleAdminId ){
          
          objApproval = new cm_Interim_Approvals__c(Id = objApp.Id);
          
          if(objApp.Next_Approver__c ==  SaleAdminId)
              objApproval.Next_Approver__c = mapOwnerIds.get(objApp.cm_Opportunity__c);
          if(objApp.Assign_To__c ==  SaleAdminId)
              objApproval.Assign_To__c = mapOwnerIds.get(objApp.cm_Opportunity__c);
          if(objApp.First_Level_Approver__c ==  SaleAdminId)
              objApproval.First_Level_Approver__c = mapOwnerIds.get(objApp.cm_Opportunity__c);
          if(objApp.Second_Level_Approver__c ==  SaleAdminId)
              objApproval.Second_Level_Approver__c = mapOwnerIds.get(objApp.cm_Opportunity__c);
          if(objApp.Third_Level_Approver__c ==  SaleAdminId)
              objApproval.Third_Level_Approver__c = mapOwnerIds.get(objApp.cm_Opportunity__c);
          
          //Added by Vikram on Oct 19, 2017
          if(objApp.Opportunity_Owner__c ==  SaleAdminId)
              objApproval.Opportunity_Owner__c = mapOwnerIds.get(objApp.cm_Opportunity__c);
          
          lstApprovals.add(objApproval);
                  } else if(objApp.Special_Approval_Type__c == 'LR Waiver'){//v2.3
                    
          objApproval = new cm_Interim_Approvals__c(Id = objApp.Id);
          
          if(mapOwnerIds.containsKey(objApp.cm_Opportunity__c) && objApp.Second_Level_Approver__c !=  mapOwnerIds.get(objApp.cm_Opportunity__c)) {
            objApproval.Second_Level_Approver__c = mapOwnerIds.get(objApp.cm_Opportunity__c);
            objApproval.Opportunity_Owner__c = mapOwnerIds.get(objApp.cm_Opportunity__c);
            reassignIds.add(objApp.Second_Level_Approver__c);
            lstApprovals.add(objApproval);
          }
                  }
                  
                }
                for(ProcessInstanceWorkItem objItem : [select Id,ActorId,ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId IN : mapSpApprovals.keySet() AND ProcessInstance.Status = 'Pending'  AND (ActorId =: SaleAdminId OR ActorId IN : reassignIds)]){
                  oppId = mapSpApprovals.containsKey(objItem.ProcessInstance.TargetObjectId) ? mapSpApprovals.get(objItem.ProcessInstance.TargetObjectId).cm_Opportunity__c : null;
                  if(oppId != null && mapOwnerIds.containsKey(oppId)){
                  lstItems.add( new ProcessInstanceWorkItem(Id = objItem.Id, ActorId = mapOwnerIds.get(oppId)));
                  }
                }
                if(!lstApprovals.isEmpty())
                  update lstApprovals;
                
                if(!lstItems.isEmpty()){
                  UpdateProcessWorkItemsQueueable objQJob = new UpdateProcessWorkItemsQueueable(lstItems);
                  system.enqueueJob(objQJob);
                }
            }
        }catch(Exception ex){
            throw new CustomException(ex.getLineNumber()+' Exception is : '+ex.getMessage());
        }
    }
    
    //v1.9
    public static void pushPrimaryContactDetails(list<Opportunity> lstNewOpps, map<Id,Opportunity> mapOldOpps){
        try{
            if(lstNewOpps != null && mapOldOpps != null){
                set<id> setOppIds = new set<Id>();
                for(Opportunity objOpp : lstNewOpps){
                    if(objOpp.cm_Approval_Status__c == 'Approved by Admin' && mapOldOpps.containsKey(objOpp.Id) && mapOldOpps.get(objOpp.Id).cm_Approval_Status__c == 'Pending with Admin' ){
                        setOppIds.add(objOpp.Id);
                    }
                }
                if(!setOppIds.isEmpty() && cm_OpportunityTriggerUtility.isSyncCall == false){
                    cm_OpportunityTriggerUtility.isSyncCall = true;
                    syncPrimaryContactDetails(setOppIds);
                }   
            }
        }catch(Exception ex){
            throw new CustomException(ex.getLineNumber()+' Exception is : '+ex.getMessage());
            EmaarErrorLogger.UpsertLogs(EmaarErrorLogger.prepareExceptionLog(new list<Service_Logs__c>(), 'Primary Contact Details Sync to ORACLE - Reserved Status', 'cm_OpportunityTriggerUtility', 'pushPrimaryContactDetails','Error in sending the Primary Contact details to ORACLE', ex));
        }
    }//v1.9

    // v2.0 code changes starts here
    // Below method cancells all pending special approvals when an opportunity is closed lost.
    public static void cancelPendingApprovals(Set<Id> opptyIds){
        List<cm_Interim_Approvals__c> approvalsToUpdateList = new List<cm_Interim_Approvals__c>();
        List<Approval.ProcessWorkitemRequest> allReq = new List<Approval.ProcessWorkitemRequest>();
        Set<id> interimApprovalIds = (new Map<Id, cm_Interim_Approvals__c>([SELECT Id FROM cm_Interim_Approvals__c where cm_Opportunity__c in:opptyIds])).keySet();
        for(ProcessInstanceWorkitem piWorkItem : [Select Id, ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where ProcessInstanceid in (select id from ProcessInstance where Status='Pending' and TargetObjectId in: interimApprovalIds )]){
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments('Opportunity Lost');
            req2.setAction('Removed'); // Approve, Reject, or Removed
            req2.setWorkitemId(piWorkItem.id);
            allReq.add(req2);
            cm_Interim_Approvals__c iaObj = new cm_Interim_Approvals__c(id = piWorkItem.ProcessInstance.TargetObjectId, cm_Decision__c = 'Cancelled');
            approvalsToUpdateList.add(iaObj);
        }
        try{
            Approval.ProcessResult[] result2 =  Approval.process(allReq);
        }
        catch(Exception ex){}
        if(approvalsToUpdateList != null && !approvalsToUpdateList.isEmpty())
            update approvalsToUpdateList;
    }
    // v2.0 code changes ends here
    
  //v1.6
  //@future(callout=true)
  public static void syncPrimaryContactDetails(set<Id> sOppIds){
    Service_Logs__c objlog = new Service_Logs__c();
    objlog.Process_Name__c = 'Sync Primary Contact Details';
    try{
    map<Id,Account> mapAccounts = new map<Id,Account>();
    try{
        
        string syncXML = '';
        for(Opportunity objOpp : [select Id,Name,AccountId,Account.Party_Id__c,Account.em_party_number__c,Sales_Order_No__c,Party_Email_on_Booking__c,Party_Phone_on_Booking__c,
                  Account.ORACLE_Primary_Email__c,Account.ORACLE_Primary_Phone__c,Account.cm_Mobile_Number__pc,Account.PersonEmail,Account.isPersonAccount,
                  Account.PersonMobilePhone,cm_Contact__c,StageName,
                  cm_Contact__r.cm_mobile_number__c,cm_Contact__r.Email,cm_Contact__r.MobilePhone,cm_Contact__r.cm_Mobile_Country_Code__c,Closed_Lost_Order_Number__c,
                  (select Id,Sales_Order__c from Opportunity_Properties__r where Sales_Order__c != null)
                from Opportunity where Id IN : sOppIds AND Account.Party_Id__c != null]){
          //if(objOpp.Opportunity_Properties__r != null && !objOpp.Opportunity_Properties__r.isEmpty()){
            if( (objOpp.Account.isPersonAccount && (objOpp.Account.ORACLE_Primary_Email__c != objOpp.Account.PersonEmail || objOpp.Account.ORACLE_Primary_Phone__c != objOpp.Account.cm_Mobile_Number__pc)) ||
                (objOpp.Account.isPersonAccount == false && (objOpp.Account.ORACLE_Primary_Email__c != objOpp.cm_Contact__r.Email || objOpp.Account.ORACLE_Primary_Phone__c != objOpp.cm_Contact__r.cm_mobile_number__c)) ){
                
                objlog.Account__c = objOpp.AccountId;
                syncXML = '';
                syncXML += '<SECONDARY_CONTACT_DETAILS>';
                  syncXML += '<PARTY>';
                syncXML += '<PARTY_ID>'+objOpp.Account.Party_Id__c+'</PARTY_ID>';
                string salesOrder = (objOpp.Opportunity_Properties__r != null && objOpp.Opportunity_Properties__r.isEmpty() == false) ? (objOpp.Opportunity_Properties__r[0].Sales_Order__c) : objOpp.Sales_Order_No__c ;
                salesOrder = (salesOrder == null || salesOrder == '') ? objOpp.Closed_Lost_Order_Number__c : salesOrder ; //v2.2
                syncXML += '<ORDER_NUMBER>'+(salesOrder != null ? salesOrder : '')+'</ORDER_NUMBER>';
                    
                  syncXML += '</PARTY>';
                  syncXML += '<CONTACT_DETAILS>';
                syncXML += '<CONTACT_DETAIL>';
                    syncXML += '<P_CONTACT_POINT_TYPE>PHONE</P_CONTACT_POINT_TYPE>';
                    syncXML += '<P_PHONE_LINE_TYPE>GEN</P_PHONE_LINE_TYPE>';
                    
                    string cCode = '';
                    string areaCode = '';
                    string mobileNum = '';
                    string sEmail = '';
                    if(objOpp.Account.isPersonAccount){
                      sEmail = objOpp.Account.PersonEmail;
                      if(objOpp.Account.cm_Mobile_Number__pc != null && objOpp.Account.PersonMobilePhone != null){
                    cCode = objOpp.Account.cm_Mobile_Number__pc.replace(objOpp.Account.PersonMobilePhone,'');
                    areaCode = objOpp.Account.PersonMobilephone.substring(0,2);
                    mobileNum = objOpp.Account.PersonMobilephone.substring(2,objOpp.Account.PersonMobilephone.length());
                      }
                      if(objOpp.StageName == 'Closed Won')
                    mapAccounts.put(objOpp.AccountId,new Account(Id=objOpp.AccountId,ORACLE_Primary_Email__c=objOpp.Account.PersonEmail,ORACLE_Primary_Phone__c=objOpp.Account.cm_Mobile_Number__pc));
                    }else{
                      sEmail = objOpp.cm_Contact__r.Email;
                      if(objOpp.cm_Contact__r.cm_mobile_number__c != null && objOpp.Account.PersonMobilePhone != null){
                    cCode = objOpp.Account.cm_Mobile_Number__pc.replace(objOpp.Account.PersonMobilePhone,'');
                    areaCode = objOpp.Account.PersonMobilephone.substring(0,2);
                    mobileNum = objOpp.Account.PersonMobilephone.substring(2,objOpp.Account.PersonMobilephone.length());
                      }
                      if(objOpp.StageName == 'Closed Won')
                    mapAccounts.put(objOpp.AccountId,new Account(Id=objOpp.AccountId,ORACLE_Primary_Email__c=objOpp.cm_Contact__r.Email,ORACLE_Primary_Phone__c=objOpp.cm_Contact__r.cm_mobile_number__c));
                    }
                    
                    syncXML += '<P_PHONE_COUNTRY_CODE>'+(cCode != '' ? Integer.valueOf(cCode)+'' : '')+'</P_PHONE_COUNTRY_CODE>';
                    syncXML += '<P_PHONE_AREA_CODE>'+areaCode+'</P_PHONE_AREA_CODE>';
                    syncXML += '<P_PHONE_NUMBER>'+mobileNum+'</P_PHONE_NUMBER>';
                syncXML += '</CONTACT_DETAIL>';
                syncXML += '<CONTACT_DETAIL>';
                    syncXML += '<P_CONTACT_POINT_TYPE>EMAIL</P_CONTACT_POINT_TYPE>';
                    syncXML += '<P_EMAIL_ADDRESS>'+sEmail+'</P_EMAIL_ADDRESS>';
                syncXML += '</CONTACT_DETAIL>';
                  syncXML += '</CONTACT_DETAILS>';
                syncXML += '</SECONDARY_CONTACT_DETAILS>';
                
                objlog.Request__c = syncXML;
                system.debug('syncXML is : '+syncXML);
                
                emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresponse = new  emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
                objresponse = EmaarWebServiceUtils.syncPrimaryContactDetails(syncXML,'','' ,'','','','',null);
                
                if(objresponse.status != 'ERROR'){
                    objlog.Response__c = string.valueOf(objresponse);
                      objlog.Log_Type__c = 'SUCCESS';
                }else{
                    objlog.Response__c = string.valueOf(objresponse);
                      objlog.Log_Type__c = 'ERROR';
                      objlog.Error_message__c = objresponse.ErrorMessage;
                }
            }else{
                objlog.Request__c = 'No Properties to Send';
                objlog.Log_Type__c = 'Success'; 
            }
        
          //}else{
          //    objlog.Request__c = 'Conditions not meet to send the call to ORACLE';
          //    objlog.Log_Type__c = 'Success';
            //return;
          //}
        }
    }catch(Exception ex){
        objlog.Log_Type__c = 'ERROR';
        objlog.Error_message__c = (objlog.Error_message__c != null ? objlog.Error_message__c : '' )+'\nException is:'+ex.getMessage();
    }
    finally{
        if(!mapAccounts.isEmpty())
            update mapAccounts.values();
    }
    }catch(Exception ex){
    objlog.Log_Type__c = 'ERROR';
        objlog.Error_message__c = (objlog.Error_message__c != null ? objlog.Error_message__c : '' )+'\nException is:'+ex.getMessage();
    }
    insert objlog;
  }
  
    //v1.8
    public static void reParentMergedOpps(list<Opportunity> lstNewOpps, map<Id,Opportunity> mapOldOpps){
        try{
            
            map<Id,Account> mapAccounts = new map<Id,Account>();
            system.debug('Test ');
            for(Opportunity obj : lstNewOpps){
                if(obj.StageName == 'Closed Won' && mapOldOpps.containsKey(obj.Id) && obj.StageName != mapOldOpps.get(obj.Id).StageName ){
                    mapAccounts.put(obj.AccountId,null);
                }   
            }
            
            if(!mapAccounts.isEmpty()){
                mapAccounts = new map<Id,Account>([select Id,Name,Parent_Account__c from Account where Id IN : mapAccounts.keySet() AND Parent_Account__c != null]);
                
                if(!mapAccounts.isEmpty()){
                    map<Id,Id> mapParentContactIds = new map<Id,Id>();
                    for(Contact objC : [select Id,AccountId from Contact where AccountId IN (select Parent_Account__c from Account where Id IN : mapAccounts.keySet()) order by CreatedDate desc ]){
                        if(!mapParentContactIds.containsKey(objC.AccountId))
                            mapParentContactIds.put(objC.AccountId,objC.Id);
                    }
                    
                    for(Opportunity obj : lstNewOpps){
                        if(mapAccounts.containsKey(obj.AccountId) && mapAccounts.get(obj.AccountId).Parent_Account__c != null ){
                            obj.Old_Account__c = obj.AccountId;
                            obj.AccountId = mapAccounts.get(obj.AccountId).Parent_Account__c;
                            obj.cm_Contact__c = (mapParentContactIds.containsKey(obj.AccountId ) ? mapParentContactIds.get(obj.AccountId) : null);
                        }   
                    }
                }
            }   
        }catch(Exception ex){
            throw new CustomException(ex.getLineNumber()+' Exception is : '+ex.getMessage());
        }
    }
  
}