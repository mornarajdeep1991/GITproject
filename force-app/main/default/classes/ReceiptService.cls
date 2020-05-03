public class ReceiptService {
    
    @AuraEnabled
    public static void updateDetails(sObject expLst){
        
        expLst.put('CalltoOracle__c',true);
     
      update expLst;
        
        system.debug('expLst'+expLst);
        
        
    }
    
      @AuraEnabled
    public static List<ExpressofInterest__c> callReceiptService(String ExofInterestId){
        system.debug('ExofInterestId 1'+ExofInterestId);
        List<ExpressofInterest__c> exiLst = [select Name,Document_Number__c,Transfer_Number__c,Receipt_Number__c from ExpressofInterest__c where Id=:ExofInterestId LIMIT 1];
     
         if(!exiLst.isEmpty()) {
             // if(!exiLst.isEmpty()) ReceiptService.sendReceiptToOracle(exiLst[0].Document_Number__c,exiLst[0].Transfer_Number__c,exiLst[0].Receipt_Number__c,exiLst[0].Name);
          List<ExpressofInterest__c> explst =   ReceiptService.sendReceiptToOracle('',exiLst[0].Receipt_Number__c,exiLst[0].Name);
             system.debug('explst'+explst);
            if(!explst.isEmpty()) return explst;
        }
        return null;
    }
    
    
    public static List<ExpressofInterest__c> sendReceiptToOracle(String TransferNumber,String ReceiptNumber,String DocID){
        
        if(String.isNotBlank(ReceiptNumber) && String.isNotBlank(DocID) && string.isBlank(TransferNumber)){
            
            system.debug('ReceiptNumber 2'+' '+ReceiptNumber);
            
            String Requestxml='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:rec="http://xmlns.oracle.com/SaleslaunchApplication/ReceptDetailProject/ReceptDetailsProcess">'
                +'<soapenv:Header/><soapenv:Body><rec:process><rec:P_RECEIPT_DOCUMENT_NUMBER>'+ReceiptNumber+'</rec:P_RECEIPT_DOCUMENT_NUMBER><rec:P_RECEIPT_NUMBER>'+ReceiptNumber+'</rec:P_RECEIPT_NUMBER></rec:process></soapenv:Body></soapenv:Envelope>';
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
            system.debug('label'+Label.SOA_header_Key_egypt);
            request.setHeader('x-apikey',Label.SOA_header_Key_egypt);
            request.setHeader('Content-Type', 'application/json');
            request.setmethod('POST');
            request.setBody(jsonData);
            request.setTimeout(120000);
            httpResponse response = http.send(request);
system.debug('response'+response);
system.debug('response'+response.getBody());
         /*   try{
                HttpResponse response = http.send(request);
                system.debug('response'+''+response);
                response.SetStatusCode(200);
                Integer success = response.getStatusCode();
                system.debug('status code'+''+success);
                String ResponseXML=response.getbody();
                system.debug('res'+''+ResponseXML);
                if(String.isNotBlank(ResponseXML)){
                    //service logs
                   // List<ExpressofInterest__c> expLst =   parseXML(ResponseXML,DocID);    
                    //return explst;
                    
                }
            }catch(exception ex){
                
                String ExpMessage = ex.getMessage();
                system.debug('ExpMessage'+ExpMessage);
                //service logs
            } */
            
            
            
        }/*else if(String.isNotBlank(DocumentNumber) && String.isBlank(ReceiptNumber) && string.isNotBlank(TransferNumber) && String.isNotBlank(DocID)){
            
            system.debug('DocumentNumber 2'+DocumentNumber);
            system.debug('TransferNumber 2'+TransferNumber);
            
            String Requestxml='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:rec="http://xmlns.oracle.com/SaleslaunchApplication/ReceptDetailProject/ReceptDetailsProcess">'
                +'<soapenv:Header/><soapenv:Body><rec:process><rec:P_RECEIPT_DOCUMENT_NUMBER>'+DocumentNumber+'</rec:P_RECEIPT_DOCUMENT_NUMBER><rec:P_RECEIPT_NUMBER>'+TransferNumber+'</rec:P_RECEIPT_NUMBER></rec:process></soapenv:Body></soapenv:Envelope>';
            
            
            HttpRequest request=new HttpRequest();
            Http http=new Http();
            request.setendpoint('callout:EgyptReceiptDetailsCallout');
            request.setHeader('Content-Type', 'text/xml; charset=utf8');
            // request.setHeader('SOAPaction','SendPushNotification');
            request.setmethod('POST');
            request.setBody(Requestxml);
            request.setTimeout(120000);
            
            
            try{
                HttpResponse response = http.send(request);
                system.debug('response'+''+response);
                response.SetStatusCode(200);
                Integer success = response.getStatusCode();
                system.debug('status code'+''+success);
                String ResponseXML=response.getbody();
                system.debug('res'+''+ResponseXML);
                if(String.isNotBlank(ResponseXML)){
                    // serivce logs
                    List<ExpressofInterest__c> expLst =  parseXML(ResponseXML,DocID); 
                    return explst;
                }
            }catch(exception ex){
                
                String ExpMessage = ex.getMessage();
                system.debug('ExpMessage'+ExpMessage);
                // serivce logs
            }
            
            
        }*/
        
        return null; 
        
    }
    
  /*  static List<ExpressofInterest__c> parseXML(String ResponseXML,String DocId){
        Map<String,String> myMap = new Map<String,String>();
        
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
                                    
                                    
                                    createdate	 = awr3.gettext();
                                    
                                    
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
                            }
                            eoiobj.Id=DocId;
                            lstEoi.add(eoiobj);  
                            
                        }
                        
                        system.debug('lstEoi    SIZE  '+lstEoi.size());
                        
                        
                    }
                    
                }
            }
            
            
        }
        if(!lstEoi.isEmpty())  return lstEoi;
        //  update lstEoi;
        
        else return null;
    } */
  // static List<ExpressofInterest__c> createJson();
    
}