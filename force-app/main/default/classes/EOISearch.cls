public class EOISearch {
    @AuraEnabled
    public static List<ExpressofInterest__c> getEOIdetails(String campaignName,String EOItype,String Qtype){
        system.debug('campaignName'+campaignName);
         system.debug('EOItype'+EOItype);
         system.debug('Qtype'+Qtype);
        String EOIquery = 'select id,Name,Campaign__c,Campaign__r.Name,Lead__r.Name,Opportunity__r.Name,CreatedDate,Queue_Type__c,Property_Advisor__c,Payment_Confirmation__c,Payment_Method__c,Registration_Number__c from ExpressofInterest__c where Payment_Confirmation__c=:EOItype AND Queue_Type__c=:Qtype AND Campaign__c=:campaignName ORDER BY Queue_Type__c';
        String EOIquery1 = 'select id,Name,Campaign__c,Campaign__r.Name,Lead__r.Name,Opportunity__r.Name,CreatedDate,Queue_Type__c,Property_Advisor__c,Payment_Confirmation__c,Payment_Method__c,Registration_Number__c from ExpressofInterest__c where Payment_Confirmation__c=:EOItype AND Campaign__c=:campaignName ORDER BY Queue_Type__c';
        String EOIquery2 = 'select id,Name,Campaign__c,Campaign__r.Name,Lead__r.Name,Opportunity__r.Name,CreatedDate,Queue_Type__c,Property_Advisor__c,Payment_Confirmation__c,Payment_Method__c,Registration_Number__c from ExpressofInterest__c where Queue_Type__c=:Qtype AND Campaign__c=:campaignName ORDER BY Queue_Type__c';
        String EOIquery3 = 'select id,Name,Campaign__c,Campaign__r.Name,Lead__r.Name,Opportunity__r.Name,CreatedDate,Queue_Type__c,Property_Advisor__c,Payment_Confirmation__c,Payment_Method__c,Registration_Number__c from ExpressofInterest__c where Campaign__c=:campaignName';
        String EOIquery4 = 'select id,Name,Campaign__c,Campaign__r.Name,Lead__r.Name,Opportunity__r.Name,CreatedDate,Queue_Type__c,Property_Advisor__c,Payment_Confirmation__c,Payment_Method__c,Registration_Number__c from ExpressofInterest__c where Campaign__c=:campaignName AND Queue_Type__c=:Qtype AND Payment_Confirmation__c=:EOItype';
        if(String.isNotBlank(campaignName) && String.isBlank(EOItype) && String.isBlank(Qtype)){
            return database.query(EOIquery3);
        } if(String.isNotBlank(campaignName) && String.isNotBlank(EOItype) && String.isNotBlank(Qtype)){
            return database.query(EOIquery4);
        }else if(String.isNotBlank(EOItype) && String.isNotBlank(Qtype)){
            return database.query(EOIquery);
        }else if(String.isNotBlank(EOItype) && String.isBlank(Qtype)){
            return database.query(EOIquery1);
        }else if(String.isBlank(EOItype) && String.isNotBlank(Qtype)){
            return database.query(EOIquery2);    
        }
        return null;  
    }
    
    @AuraEnabled
    public static void callReceiptService(String ExofInterestId){
        system.debug('ExofInterestId 1'+ExofInterestId);
        List<ExpressofInterest__c> exiLst = [select Id,Name,Receipt_Number__c from ExpressofInterest__c where Id=:ExofInterestId LIMIT 1];
     system.debug('exiLst'+exiLst);
         if(!exiLst.isEmpty()) {
             // if(!exiLst.isEmpty()) ReceiptService.sendReceiptToOracle(exiLst[0].Document_Number__c,exiLst[0].Transfer_Number__c,exiLst[0].Receipt_Number__c,exiLst[0].Name);
           sendReceiptToOracle(exiLst[0].Receipt_Number__c,exiLst[0].Id);
        // sendReceiptToOracle('','384919',exiLst[0].Id);
        }
    }
    
    
     static void sendReceiptToOracle(String ReceiptNumber,String DocID){
        
        if(String.isNotBlank(ReceiptNumber) && String.isNotBlank(DocID)){
             List<ExpressofInterest__c> lstEoi = new List<ExpressofInterest__c>();
              List<Service_Logs__c> slogs = new List<Service_Logs__c>();
         Service_Logs__c slog= new Service_Logs__c();
            system.debug('ReceiptNumber 2'+ReceiptNumber);
            
          //  String Requestxml='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:rec="http://xmlns.oracle.com/SaleslaunchApplication/ReceptDetailProject/ReceptDetailsProcess">'
            //    +'<soapenv:Header/><soapenv:Body><rec:process><rec:P_RECEIPT_DOCUMENT_NUMBER>'+ReceiptNumber+'</rec:P_RECEIPT_DOCUMENT_NUMBER><rec:P_RECEIPT_NUMBER>'+''+'</rec:P_RECEIPT_NUMBER></rec:process></soapenv:Body></soapenv:Envelope>';
            
            JSONGenerator gen = JSON.createGenerator(true);
              gen.writeStartObject();     
             gen.writeStringField('P_RECEIPT_DOCUMENT_NUMBER',ReceiptNumber);
            gen.writeStringField('P_RECEIPT_NUMBER','null');
            gen.writeEndObject();
            system.debug('gen'+gen);
            String jsonData = gen.getAsString();
            system.debug('jsonData'+jsonData);
            
       HttpRequest request=new HttpRequest();
            Http http=new Http();
            request.setendpoint('callout:EgyptReceiptDetailsCallout');
            request.setHeader('x-apikey',Label.SOA_header_Key_egypt);
            request.setHeader('Content-Type', 'application/json');
            request.setmethod('POST');
            request.setBody(jsonData);
            request.setTimeout(120000);
            
            try{
                HttpResponse response = http.send(request);
                system.debug('response'+''+response);
                response.SetStatusCode(200);
                system.debug('status code'+''+response.getStatusCode());
                String ResponseJson=response.getbody();
                system.debug('res'+''+ResponseJson);
                if(String.isNotBlank(ResponseJson)){ 
                     ReceiptParser jp =  ReceiptParser.parse(ResponseJson);
                    system.debug('test jp'+jp);
                    String s = jp.RECEIPT_DETAIL.RECEIPT_DOC_DETAIL.RECEIPT_DETAIL.CREATION_DATE;
                                    String s2 = s.mid(6, 4);
                                     String s3 = s.mid(3, 2);
                                     String s4 = s.mid(0, 2);
                                     String s6 = s.mid(11,8);
                                  String   createdate = s2+'-'+s3+'-'+s4+' '+s6;

                     ExpressofInterest__c eoiobj = new ExpressofInterest__c();
                     eoiobj.Id=DocId;
                                eoiobj.Oracle_Account_Name__c = jp.RECEIPT_DETAIL.RECEIPT_DOC_DETAIL.RECEIPT_DETAIL.ACCOUNT_NAME;
                                eoiobj.Oracle_Receipt_Number__c= jp.RECEIPT_DETAIL.RECEIPT_DOC_DETAIL.RECEIPT_DETAIL.RECEIPT_NUMBER;
                                eoiobj.Amount__c= jp.RECEIPT_DETAIL.RECEIPT_DOC_DETAIL.RECEIPT_DETAIL.AMOUNT;
                                eoiobj.Oracle_STATE_DSP__c =  jp.RECEIPT_DETAIL.RECEIPT_DOC_DETAIL.RECEIPT_DETAIL.STATE_DSP;
                                eoiobj.Oracle_CREATION_DATE__c	= createdate;
                                eoiobj.Oracle_COMMENTS__c= jp.RECEIPT_DETAIL.RECEIPT_DOC_DETAIL.RECEIPT_DETAIL.COMMENTS;
                                eoiobj.Oracle_Payment_Method__c= jp.RECEIPT_DETAIL.RECEIPT_DOC_DETAIL.RECEIPT_DETAIL.METHOD_NAME;
                                eoiobj.Oracle_Receipt_Date__c = jp.RECEIPT_DETAIL.RECEIPT_DOC_DETAIL.RECEIPT_DETAIL.RECEIPT_DATE;
                                eoiobj.Oracle_GL_Date__c=jp.RECEIPT_DETAIL.RECEIPT_DOC_DETAIL.RECEIPT_DETAIL.GL_DATE;
                   
                   lstEoi.add(eoiobj);
                 if(!lstEoi.isEmpty())   update lstEoi;
        system.debug('lstEoi'+lstEoi);
        slog.Request__c=jsonData;
        slog.Response__c=ResponseJson;
        slog.ExpressofInterest__c=DocId;
        slog.Log_Type__c='SUCCESS'; 
        slogs.add(slog);
        insert slogs;
                }
            }catch(exception ex){
                
                String ExpMessage = ex.getMessage();
                system.debug('ExpMessage'+ExpMessage);
              
         slog.Request__c=jsonData;
        slog.ExpressofInterest__c=DocId;
        slog.Error_Message__c=ExpMessage;
        slog.Error_Class_Method_Name__c='Class :EOISearch'+' '+'Method :sendReceiptToOracle';
        slog.Log_Type__c='ERROR';        
        slogs.add(slog);
        insert slogs;
            }
       
        }
        
    }
    
  /*  static void parseXML(String ResponseXML,String DocId,String Requestxml){
        Map<String,String> myMap = new Map<String,String>();
         List<Service_Logs__c> slogs = new List<Service_Logs__c>();
         Service_Logs__c slog= new Service_Logs__c();
        List<ExpressofInterest__c> lstEoi = new List<ExpressofInterest__c>();
        String accname;
        String recpno;
        String amt;
        String state;
        String createdate;
        String comments;
        string paymethod;
        string receiptdate;
        string gldate;
        Dom.Document docx = new Dom.Document();
        
        docx.load(ResponseXML);
        dom.XmlNode xroot = docx.getrootelement();
        
        dom.XmlNode [] xrec = xroot.getchildelements() ; //Get all Record Elements
        
        
        for(Dom.XMLNode child : xrec){
            
            
            for(Dom.XMLNode awr : child.getchildelements()){
                
                for(Dom.XMLNode awr1 : awr.getchildelements()){
                    
                    
                    for(Dom.XMLNode awr2 : awr1.getchildelements()){
                        
                        
                        
                        for(Dom.XMLNode awr21 : awr2.getchildelements()){
                            
                            ExpressofInterest__c eoiobj = new ExpressofInterest__c();
                            
                            for(Dom.XMLNode awr3 : awr21.getchildelements()){
                                
                                
                                if(awr3.getname() == 'ACCOUNT_NAME'){
                                    
                                    accname = awr3.gettext();
                                    
                                    
                                }
                                if(awr3.getname() == 'RECEIPT_NUMBER'){
                                    
                                    
                                    recpno = awr3.gettext();
                                    
                                    
                                }
                                if(awr3.getname() == 'AMOUNT'){
                                    
                                    
                                    amt = awr3.gettext();
                                    
                                }
                                if(awr3.getname() == 'STATE_DSP'){
                                    
                                    
                                    state =  awr3.gettext();
                                    
                                    
                                }
                                
                                if(awr3.getname() == 'CREATION_DATE'){
                                    
                                    
                                    String s = awr3.gettext();
                                    String s2 = s.mid(6, 4);
                                     String s3 = s.mid(3, 2);
                                     String s4 = s.mid(0, 2);
                                     String s6 = s.mid(11,8);
                                     createdate = s2+'-'+s3+'-'+s4+' '+s6;
                                    
                                    
                                }
                                if(awr3.getname() == 'COMMENTS'){
                                    
                                    
                                    comments= awr3.gettext();
                                    
                                    
                                }
                                if(awr3.getname() == 'METHOD_NAME'){
                                    
                                    
                                    paymethod= awr3.gettext();
                                    
                                    
                                }
                                if(awr3.getname() == 'RECEIPT_DATE'){
                                    
                                    
                                    receiptdate= awr3.gettext();
                                    
                                    
                                }
                                if(awr3.getname() == 'GL_DATE'){
                                    
                                    
                                    gldate= awr3.gettext();
                                    
                                }
                                eoiobj.Oracle_Account_Name__c = accname;
                                eoiobj.Oracle_Receipt_Number__c= recpno;
                                eoiobj.Amount__c= amt;
                                eoiobj.Oracle_STATE_DSP__c =  state;
                                eoiobj.Oracle_CREATION_DATE__c	 = createdate;
                                eoiobj.Oracle_COMMENTS__c= comments;
                                eoiobj.Oracle_Payment_Method__c= paymethod;
                                eoiobj.Oracle_Receipt_Date__c = receiptdate;
                                eoiobj.Oracle_GL_Date__c=gldate;
                                eoiobj.CalltoOracle__c=true;
                            }
                            eoiobj.Id=DocId;
                            lstEoi.add(eoiobj);  
                            
                        }
                        
                        system.debug('lstEoi    SIZE  '+lstEoi.size());
                        
                        
                    }
                    
                }
            }
            
            
        }
        update lstEoi;
        system.debug('lstEoi'+lstEoi);
        slog.Request__c=Requestxml;
        slog.Response__c=ResponseXML;
        slog.ExpressofInterest__c=DocId;
        slog.Log_Type__c='SUCCESS'; 
        slogs.add(slog);
        insert slogs;
    } */

    
  
}