/*==========================================================================
V.No    Date            By                  Description    
====================================================================================================================================================
v1.1  09/Jan/2018     Sandeep      Changing from user sales admin id field to configuration object settings.
v1.2  09/Jan/2018     Sandeep      Excluging Sales admins from next assignment
v1.3  11/Apr/2018     Sandeep      Changed Sales_Admin_Assignment_Days_Check = 3days and added Compliance_Process__c=false in query.EPESI-1353
==========================================================================
*/
public without sharing class SalesAdminAssignment {
    public static string Check_Last_7_Days(string AccountID){
        string OwnerId= '';
        string AdminUserId ='';
        Map<String,Mobile_Configurations__c> mpConfigs = Mobile_Configurations__c.getAll();
        list<user> lstAdminUser = [select id,Name,Email from user where username=:mpConfigs.get('Configuration').cm_Sales_Admin_Username__c];
        if(lstAdminUser!=null && lstAdminUser.size() >0)
           AdminUserId = lstAdminUser[0].id;
        
        integer iDays = integer.valueof(label.Sales_Admin_Assignment_Days_Check);//v1.3
        Date DTStart =  system.today().adddays(-(iDays));
        Date DTEnd =  system.today().addDays(1);
        list<Opportunity> lstOPP = [select id,Name,OwnerId from Opportunity where AccountId=:AccountID and createdDate >=:DTStart and createdDate <=:DTEnd and StageName='Pending Approval' and OwnerId!=:AdminUserId];
        if(lstOPP!=null && lstOPP.size() >0){
            OwnerId = lstOPP[0].OwnerId;
        }
        
        return OwnerId;
    }
    //v1.1
    public static string AssignDefaultAdmin(string propAdvId){
        string ownerId = '';
        map<string,id> seToSalesAdmin = new map<string,id>(); 
        for(Configuration__c con : [select Sales_Admin__c,Sales_Executive__c from Configuration__c where recordtype.developername='SE_to_Sales_Admin_Auto_Assignment' and Sales_Admin__c!=null and Sales_Executive__c!=null]){
            seToSalesAdmin.put(con.Sales_Executive__c,con.Sales_Admin__c);
        }
        //list<user> lstAdminUser = [select id,Name,Email,Sales_Admin_User_Id__c from user where id=:propAdvId and Sales_Admin_User_Id__c!=null];
        if(seToSalesAdmin.containsKey(propAdvId)){
            //ownerId = lstAdminUser[0].Sales_Admin_User_Id__c;
            ownerId = seToSalesAdmin.get(propAdvId);
        }
        return ownerId;
    }
    
    public static string TeamDefaultAssignment(string teamName){
        Set<Id> vacationUsers = new Set<Id>();
        string AdminUserId = '';
        Date currDate = System.Today();
        for(cm_User_Vacation__c uv: [Select id, cm_User__c from cm_User_Vacation__c where cm_Start_Date__c<=:currDate and cm_End_Date__c>=:currDate]){
            vacationUsers.add(uv.cm_User__c);
        }
        Map<String,Mobile_Configurations__c> mpConfigs = Mobile_Configurations__c.getAll();
        list<user> lstAdminUser = [select id,Name,Email from user where username=:mpConfigs.get('Configuration').cm_Sales_Admin_Username__c];
        if(lstAdminUser!=null && lstAdminUser.size() >0)
           AdminUserId = lstAdminUser[0].id;
           
        if(AdminUserId !=''){
            vacationUsers.add(AdminUserId);
        }
        string NEXT_OWNERID = '';
        map<Id,id> MapAdminUsers = new map<Id,id>();
        list<UserAssignmentCount> lstDetails = new list<UserAssignmentCount>();
        list<UserAssignmentCount> lstDetails_sorted = new list<UserAssignmentCount>();
        for(Configuration__c con : [select Sales_Admin__c,Team__c from Configuration__c where recordtype.developername='SE_to_Sales_Admin_Auto_Assignment' and 
                                   Sales_Admin__c!=null and Team__c!=null and Team__c=:teamName and  Sales_Admin__c NOT IN:vacationUsers]){
            MapAdminUsers.put(con.Sales_Admin__c,con.Sales_Admin__c);
        }
        if(MapAdminUsers!=null && MapAdminUsers.keyset().size() >0){
            AggregateResult[] groupedResults = [SELECT Count(Id)cnt,OwnerId owId FROM Opportunity where stageName='Pending Approval' and cm_Approval_Status__c='Pending with Admin' 
                                            and OwnerID IN:MapAdminUsers.keyset()  group by OwnerId ORDER BY Count(Id) ASC];
            Map<string,string> mapAdminAcount = new map<string,string>();
            for(AggregateResult ar:groupedResults){
                mapAdminAcount.put(string.valueof(ar.get('owId')),string.valueof(ar.get('cnt')));
            }
            system.debug('*********mapAdminAcount'+mapAdminAcount);
            for(id userId:MapAdminUsers.keyset()){
                if(mapAdminAcount!=null && mapAdminAcount.get(userId)!=null){
                    UserAssignmentCount obj = new UserAssignmentCount();
                    obj.userId = userId;
                    obj.Count = integer.valueof(mapAdminAcount.get(userId));
                    lstDetails.add(obj);
                }else{
                    UserAssignmentCount obj = new UserAssignmentCount();
                    obj.userId = userId;
                    obj.Count = 0;
                    lstDetails.add(obj);
                }
            }
            if(!lstDetails.isEmpty()){
                lstDetails_sorted = SortuserByAssignment(lstDetails);
                NEXT_OWNERID = lstDetails_sorted[0].userId;
            }else{
                for(string strUserId:MapAdminUsers.keyset()){
                     NEXT_OWNERID = strUserId;
                     break;
                }
            }
            system.debug('*********NEXT_OWNERID'+NEXT_OWNERID);
        }
        return NEXT_OWNERID;
    }
    
    public static string  GetNextOwnerId(){
        string NEXT_OWNERID = '';
        string AdminUserId = ''; // sales Admin User Id
    /********************Vaction rule*****************************/
        Set<Id> vacationUsers = new Set<Id>();
        Date currDate = System.Today();
        for(cm_User_Vacation__c uv: [Select id, cm_User__c from cm_User_Vacation__c where cm_Start_Date__c<=:currDate and cm_End_Date__c>=:currDate]){
            vacationUsers.add(uv.cm_User__c);
        }
        set<Id> setUserIds = new set<Id>();
         for(GroupMember g : [Select UserorGroupId From GroupMember WHERE group.developername = 'Sales_Admin_Assignment']){
            if(g.UserOrGroupID.getsObjectType() == Schema.User.sObjectType){
                setUserIds.add(g.UserOrGroupID);
            }
         }
         system.debug('************setUserIds'+setUserIds);
        Map<String,Mobile_Configurations__c> mpConfigs = Mobile_Configurations__c.getAll();
        list<user> lstAdminUser = [select id,Name,Email from user where username=:mpConfigs.get('Configuration').cm_Sales_Admin_Username__c];
        if(lstAdminUser!=null && lstAdminUser.size() >0)
           AdminUserId = lstAdminUser[0].id;
           
        if(AdminUserId !=''){
            vacationUsers.add(AdminUserId);
        }
        //v1.2
        set<id> excludeSalesAdmin = new set<id>(); 
        for(Configuration__c con : [select Sales_Admin__c from Configuration__c where recordtype.developername='SE_to_Sales_Admin_Auto_Assignment' and Sales_Admin__c!=null and team__c!=null]){
            excludeSalesAdmin.add(con.Sales_Admin__c);
        }
        map<Id,User> MapAdminUsers = new map<Id,User>([select id,Name from user where Id IN:setUserIds and isActive=true and Exclude_assignment__c = false and ID NOT IN:vacationUsers and ID NOT IN:excludeSalesAdmin order by Name]);
        
        /*********************************************************///v1.3
        AggregateResult[] groupedResults = [SELECT Count(Id)cnt,OwnerId owId FROM Opportunity where OwnerID IN:MapAdminUsers.keyset() and stageName='Pending Approval' and cm_Approval_Status__c='Pending with Admin' 
                                             and Compliance_Process__c=false group by OwnerId ORDER BY Count(Id) ASC];
        system.debug('*********8groupedResults'+groupedResults);
        list<UserAssignmentCount> lstDetails = new list<UserAssignmentCount>();
        list<UserAssignmentCount> lstDetails_sorted = new list<UserAssignmentCount>();
        Map<string,string> mapAdminAcount = new map<string,string>();
        for(AggregateResult ar:groupedResults){
            mapAdminAcount.put(string.valueof(ar.get('owId')),string.valueof(ar.get('cnt')));
        }
        system.debug('*********mapAdminAcount'+mapAdminAcount);
        for(id userId:MapAdminUsers.keyset()){
            if(mapAdminAcount!=null && mapAdminAcount.get(userId)!=null){
                UserAssignmentCount obj = new UserAssignmentCount();
                obj.userId = userId;
                obj.Count = integer.valueof(mapAdminAcount.get(userId));
                lstDetails.add(obj);
            }else{
                UserAssignmentCount obj = new UserAssignmentCount();
                obj.userId = userId;
                obj.Count = 0;
                lstDetails.add(obj);
            }
        }
        if(!lstDetails.isEmpty()){
            lstDetails_sorted = SortuserByAssignment(lstDetails);
            NEXT_OWNERID = lstDetails_sorted[0].userId;
        }else{
            for(string strUserId:MapAdminUsers.keyset()){
                 NEXT_OWNERID = strUserId;
                 break;
            }
        }
        system.debug('*********NEXT_OWNERID'+NEXT_OWNERID);
        return NEXT_OWNERID;
    }
    public static string  GetNextOwnerId_CustomerDirect(){
    string NEXT_OWNERID ;
    /*************************QUERY USERS FROM GROUP**************************/
     set<Id> setUserIds = new set<Id>();
     for(GroupMember g : [Select UserorGroupId From GroupMember WHERE group.developername = 'Customer_Direct_Admin_Group']){
        if(g.UserOrGroupID.getsObjectType() == Schema.User.sObjectType){
            setUserIds.add(g.UserOrGroupID);
        }
     }
     system.debug('************setUserIds'+setUserIds);
    /********************Vaction rule*****************************/
        Set<Id> vacationUsers = new Set<Id>();
        Date currDate = System.Today();
        for(cm_User_Vacation__c uv: [Select id, cm_User__c from cm_User_Vacation__c where cm_Start_Date__c<=:currDate and cm_End_Date__c>=:currDate and cm_User__c IN:setUserIds]){
            vacationUsers.add(uv.cm_User__c);
        } 
        /*********************************************************/
        AggregateResult[] groupedResults = [SELECT Count(Id)cnt,OwnerId owId FROM Opportunity where stageName='Pending Approval' and cm_Approval_Status__c='Pending with Admin' 
                                            and OwnerID IN:setUserIds and OwnerID NOT IN:vacationUsers and Compliance_Process__c=false group by OwnerId ORDER BY Count(Id) ASC];
        system.debug('*********8groupedResults'+groupedResults);
        list<UserAssignmentCount> lstDetails = new list<UserAssignmentCount>();
        list<UserAssignmentCount> lstDetails_sorted = new list<UserAssignmentCount>();
        if(!groupedResults.isEmpty()){
            Map<string,string> mapAdminAcount = new map<string,string>();
            for(AggregateResult ar:groupedResults){
                mapAdminAcount.put(string.valueof(ar.get('owId')),string.valueof(ar.get('cnt')));
            }
            for(id userId:setUserIds){
                if(mapAdminAcount!=null && mapAdminAcount.get(userId)!=null){
                    UserAssignmentCount obj = new UserAssignmentCount();
                    obj.userId = userId;
                    obj.Count = integer.valueof(mapAdminAcount.get(userId));
                    lstDetails.add(obj);
                }else{
                    UserAssignmentCount obj = new UserAssignmentCount();
                    obj.userId = userId;
                    obj.Count = 0;
                    lstDetails.add(obj);
                }
            }
            if(!lstDetails.isEmpty()){
                lstDetails_sorted = SortuserByAssignment(lstDetails);
                NEXT_OWNERID = lstDetails_sorted[0].userId;
            }
        }else{
            for(string strUserId:setUserIds){
                 NEXT_OWNERID = strUserId;
                 break;
            }
        }
        system.debug('*********NEXT_OWNERID'+NEXT_OWNERID);
        return NEXT_OWNERID;
    }
    public static string  GetNextOwnerId_BrokerDirect(){
      string NEXT_OWNERID ;
    /*************************QUERY USERS FROM GROUP**************************/
     set<Id> setUserIds = new set<Id>();
     for(GroupMember g : [Select UserorGroupId From GroupMember WHERE group.developername = 'Broker_Direct_Admin_Group']){
        if(g.UserOrGroupID.getsObjectType() == Schema.User.sObjectType){
            setUserIds.add(g.UserOrGroupID);
        }
     }
     system.debug('************setUserIds'+setUserIds);
    /********************Vaction rule*****************************/
        Set<Id> vacationUsers = new Set<Id>();
        Date currDate = System.Today();
        for(cm_User_Vacation__c uv: [Select id, cm_User__c from cm_User_Vacation__c where cm_Start_Date__c<=:currDate and cm_End_Date__c>=:currDate and cm_User__c IN:setUserIds]){
            vacationUsers.add(uv.cm_User__c);
        }
        /*********************************************************/
        AggregateResult[] groupedResults = [SELECT Count(Id)cnt,OwnerId owId FROM Opportunity where stageName='Pending Approval' and cm_Approval_Status__c='Pending with Admin' 
                                            and OwnerID IN:setUserIds and  OwnerID NOT IN:vacationUsers and Compliance_Process__c=false group by OwnerId ORDER BY Count(Id) ASC];
        system.debug('*********8groupedResults'+groupedResults);
        list<UserAssignmentCount> lstDetails = new list<UserAssignmentCount>();
        list<UserAssignmentCount> lstDetails_sorted = new list<UserAssignmentCount>();
        if(!groupedResults.isEmpty()){
            Map<string,string> mapAdminAcount = new map<string,string>();
            for(AggregateResult ar:groupedResults){
                mapAdminAcount.put(string.valueof(ar.get('owId')),string.valueof(ar.get('cnt')));
            }
            System.debug('log for mapAccount'+mapAdminAcount);
            for(id userId:setUserIds){
                if(mapAdminAcount!=null && mapAdminAcount.get(userId)!=null){
                    UserAssignmentCount obj = new UserAssignmentCount();
                    obj.userId = userId;
                    obj.Count = integer.valueof(mapAdminAcount.get(userId));
                    lstDetails.add(obj);
                }else{
                    UserAssignmentCount obj = new UserAssignmentCount();
                    obj.userId = userId;
                    obj.Count = 0;
                    lstDetails.add(obj);
                }
            }
            if(!lstDetails.isEmpty()){
                lstDetails_sorted = SortuserByAssignment(lstDetails);
                NEXT_OWNERID = lstDetails_sorted[0].userId;
            }
        }else{
            for(string strUserId:setUserIds){
                 NEXT_OWNERID = strUserId;
                 break;
            }
        }
        system.debug('*********NEXT_OWNERID'+NEXT_OWNERID);
        return NEXT_OWNERID;
    }
    public static List<UserAssignmentCount> SortuserByAssignment(List<UserAssignmentCount> ListToSort){
        system.debug('List Size****'+ListToSort.size());
        if(ListToSort == null || ListToSort.size() <= 1)        
            return ListToSort;          
        
        List<UserAssignmentCount> Less= new List<UserAssignmentCount>();
        List<UserAssignmentCount> Greater= new List<UserAssignmentCount>();
        List<UserAssignmentCount> Equal= new List<UserAssignmentCount>();
        List<UserAssignmentCount> returnList= new List<UserAssignmentCount>();     
        integer pivot = 0;              
        // save the pivot and remove it from the list        
        UserAssignmentCount pivotValue = ListToSort[pivot];        
        ListToSort.remove(pivot); 
        
       for(UserAssignmentCount x : ListToSort){       
            if(x.Count < pivotValue.Count)           
                 Less.add(x);            
            else if(x.Count > pivotValue.Count)
                 Greater.add(x);
            else
                 Equal.add(x);         
           
        }
        returnList.addAll(SortuserByAssignment(Less));        
        returnList.add(pivotValue);
        returnList.addAll(SortuserByAssignment(Equal));
        returnList.addAll(SortuserByAssignment(Greater));       
        system.debug('*** returnList***'+returnList);
        return returnList;  
    }
    public class UserAssignmentCount{
        public string userId{get;set;}
        public integer Count{get;set;}
    }
}