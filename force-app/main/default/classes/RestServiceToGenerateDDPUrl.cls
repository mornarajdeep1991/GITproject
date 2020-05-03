/*
* Company : Hari
* Modification History :
==========================================================================
Vesion      Author          Date            Description 
*/
@RestResource(urlMapping='/RestServiceToGenerateDDPUrl/*')
global class RestServiceToGenerateDDPUrl {
    @Httpget
    global static ResponseHandler GenerateUrl(){
        string objectId ='0064E00000GUoGc';
        string objectName = 'Opportunity';
        string objectApiName = 'Opportunity';
        string documentType = 'SPAForm';
        ResponseHandler response = new ResponseHandler();
        /*
        *
        *
        */
        try {
            boolean IsSandBox = true;
            string SesstionUserId = RestDrawloopServiceCls.GetSessionIDAndUserId();
            string sessionid = SesstionUserId.split(',')[0];
            string ORGid = sessionid.substring(0,15);
            string userId = SesstionUserId.split(',')[1];
            /*
             * 
             * select id,(select id from Loop__Custom_Integration_Options__r where RecordType.developername = 'Download') 
             * from Loop__DDP__c where Loop__Filter__c = 'OTP'
             * 
             */
            
            list<Loop__DDP__c> ddps = new list<Loop__DDP__c>([select id,(select id from Loop__Custom_Integration_Options__r where RecordType.developername = 'Download') 
                                                              from Loop__DDP__c where Loop__Filter__c = :documentType  ]);
                                                              
            list<Drawloop_user_settings__mdt> ddpSettingList = new list<Drawloop_user_settings__mdt> ([select id,Loop_Service_URL__c  from Drawloop_user_settings__mdt limit 1]);
             
            string ddpId = ddps[0].id;
            string ddpDeliveryIds = ddps[0].Loop__Custom_Integration_Options__r[0].id;
            //https://emaar--Dev.cs83.my.salesforce.com
            string location = ddpSettingList[0].Loop_Service_URL__c + ORGid;
            string next = '/ddps/42?objname'+ objectName+'&objtype='+objectApiName.toLowerCase()
                +'&auto=false&header=false&sessiondata=SFuser:'+userId + ';SForganization:'+ORGid 
                +';OptDocs:;SF'+objectApiName.toLowerCase()+':'+ objectId+';DDPId:'+ddpId+';Deploy:'+ddpDeliveryIds+';DeployType:Download';
            
            String reqBody = 'sessionid='+sessionid +'&location='+ EncodingUtil.urlEncode(location,'UTF-8')+'&auto=true&next='+EncodingUtil.urlEncode(next,'UTF-8')+'&attachments=&sandbox='+ (IsSandBox? 'test': 'login');
            
            response.Success = true;
            response.DDpUrl = reqBody;
            system.debug(System.URL.getSalesforceBaseURL());
            //system.debug(System.URL.get);
            system.debug('DDpUrl -->');
            system.debug(response.DDpUrl);
            response.status = 'success';
            response.message = 's';
            
            //v1.1
            if((UserInfo.getUserType() != 'Standard' || test.isRunningTest()) && response.DDpUrl != null && response.DDpUrl != ''){
                /*Http httpObj = new Http();
                HttpRequest req = new HttpRequest();
                req.setTimeout(60000);
                req.setEndpoint(response.DDpUrl);  
                req.setMethod('POST');
                req.setHeader('Connection', 'keep-alive');
                req.setHeader('Cache-Control','max-age=0'); */
                
                // uncomment this line req.setHeader('Accept','text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8');  
                /*req.setHeader('Content-type','application/x-www-form-urlencoded');    
                req.setHeader('Accept-Encoding','gzip, deflate');
                req.setHeader('Accept-Language','en-GB,en;q=0.8,en-US;q=0.6,ar;q=0.4');
                        
                req.setBody('');
                    
                HttpResponse reqResponse = httpObj.send(req);
                system.debug('response is : '+reqResponse);
                */
                /*if(!DDP_Config__c.getAll().isEmpty() && DDP_Config__c.getAll().containsKey('OTP')){
                    map<string,string> variables = new map<string,string>();
                    variables.put('deploy',DDP_Config__c.getAll().get('OTP').DDP_Id__c);
                    Loop.loopMessage.send(objectId,DDP_Config__c.getAll().get('OTP').Delivery_Option_Id__c,variables, DDP_Config__c.getAll().get('OTP').SFDC_Instance__c);
                }*/
                
                Loop.loopMessage lm = new Loop.loopMessage();
                lm.sessionId = sessionId;
                
                system.debug('documentType is : '+documentType);
                
                lm.requests.add(new Loop.loopMessage.loopMessageRequest(
                    objectId, // MAIN RECORD ID - SAME OBJECT AS THE DDP RECORD TYPE SPECIFIES
                    DDP_Config__c.getAll().get(documentType).DDP_Id__c,
                    new Map<string, string>{
                        'deploy' => DDP_Config__c.getAll().get(documentType).Delivery_Option_Id__c//,
                        //'SFAccount' => mySObject.Account.Id
                        // THESE PARAMETERS ARE THE SAME AS THOSE FOUND IN OUR OUTBOUND MESSAGE DOCUMENTATION
                        // PLEASE REFERENCE THAT DOCUMENTATION FOR ADDITIONAL OPTIONS
                    }
                ));
                lm.sendAllRequests();
            }
        
        }
        catch(exception e){ 
            
            response.Success = false;
            response.status = 'Error';
            response.message = e.getMessage();
        }
        
        return response;
    }
 
    global class ResponseHandler {
        public Boolean Success {get; set;}
        public String DDpUrl {get;set;}
        public String Status {get; set;}
        public String Message {get;set;}
    }
}