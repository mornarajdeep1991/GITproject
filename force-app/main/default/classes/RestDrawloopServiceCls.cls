/*
Author : Haribabu Amudalapalli
Date : Feb 2nd , 2020.
Description :
Modification History :
*/
global class RestDrawloopServiceCls 
{   
    @future(callout=true)
    Public static void generateDocument(String objectID, String packageId, String documentName, String ddpDeliveryIds){ 
         GenerateDDP(objectID,packageId,documentName,ddpDeliveryIds);
    }
    webservice static void GenerateDDP(String objectID, String packageId, String documentName, String ddpDeliveryIds){
        system.debug('objectID'+objectID+'packageId'+packageId+'documentName'+documentName+'ddpDeliveryIds'+ddpDeliveryIds);
        string SesstionUserId = RestDrawloopServiceCls.GetSessionIDAndUserId();
        String[] sessId = SesstionUserId.split(',');
        System.debug('SESSION: '+sessId);
        string sessionid = sessId.size()>0? sessId[0] : '';
        string ORGid = test.isRunningTest() ? '123456' : sessionid.substring(0,15);
        string userId = test.isRunningTest() ? '123456' : SesstionUserId.split(',')[1];
        Drawloop_user_settings__mdt DrawloopUserSettings = [select id,Login_URL__c,Password__c,User_ID__c,User_Name__c,
                                                            Document_Count__c, Label, Language, MasterLabel, NamespacePrefix,
                                                            DeveloperName, QualifiedApiName,Loop_Service_URL__c
                                                            from Drawloop_user_settings__mdt order by Document_Count__c limit 1];
        
        string Origin = '';
        string Location = '';        
        Loop.loopMessage lm = new Loop.loopMessage();
        lm.sessionId = sessionid;            
        lm.requests.add(new Loop.loopMessage.loopMessageRequest(
            objectId, // MAIN RECORD ID - SAME OBJECT AS THE DDP RECORD TYPE SPECIFIES
            packageId,
            new Map<string, string>{
                'deploy' => ddpDeliveryIds,
                    'DeployType' => 'Download'
                    }
        ));
        string res = '';
        if(!Test.isRunningTest())
        {        
            res = lm.sendAllRequests(); 
            system.debug('*******response'+res);
            Service_Logs__c log = new Service_Logs__c();
            if(objectID.startswith('006')){
                log.Opportunity__c = objectID;
            }else{
            log.ExpressofInterest__c = objectID;
            }
            log.Process_Name__c = documentName+'Generation';
            log.Request__c = 'Generation of an '+documentName+' by user '+UserInfo.getFirstName()+' '+UserInfo.getLastName()+
                ' for the document ['+documentName+'] in the package '+packageId;
            log.Response__c = res;
            insert log;
            
        }              
    }
    
    public static string GetSessionIDAndUserId(){
        string bodyToSendLogin;
        string outCallResultLogin;
        string sessionID;
        string userName = ''; 
        string password = '';
        string loginURL ='';
        string UserId = '';
        
        list<Drawloop_user_settings__mdt> PGList = new list<Drawloop_user_settings__mdt> ([select id,Login_URL__c,Password__c,User_ID__c,User_Name__c,Document_Count__c 
                                                                                           from Drawloop_user_settings__mdt order by Document_Count__c limit 1]);
       system.debug('PGList'+PGList);
        if(PGList.size() > 0){
            loginURL = PGList[0].Login_URL__c;
            userName = PGList[0].User_Name__c; 
            password = PGList[0].Password__c;
            UserId = PGList[0].User_ID__c;
        }
        //This beginning piece of XML can be re-used for the subsequent calls
        string SOAP_START  = '<?xml version="1.0" encoding="utf-8"?><env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"><env:Body><n1:login xmlns:n1="urn:partner.soap.sforce.com"><n1:username>';
        bodyToSendLogin = SOAP_START + userName + '</n1:username><n1:password>' + password + '</n1:password></n1:login></env:Body></env:Envelope>';
        
        outCallResultLogin = makeHTTPCall(loginURL,bodyToSendLogin);
        system.debug('outCallResultLogin Output: ' + outCallResultLogin);   
        sessionID = getValueFromXMLString(outCallResultLogin, 'sessionId');
        system.debug('sessionID -> '+ sessionID);
        return sessionID + ','+ UserId;
 
    }
    
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
        System.debug('LOGIN RESPONSE: '+outCallResultLogin2);
        return outCallResultLogin2;
    }
    
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
}