@IsTest
public with sharing class emaarServicesComCreatesrbpelprocessVTest
{
  public static string CalloutType;
    public static string CalloutTypeNew;
    public class WebServiceMockImpl implements WebServiceMock
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {
          system.debug('request is : '+request);
            if(request instanceof emaarServicesComCreatesrbpelprocessV.LookUpValuesRequest_element)
                response.put('response_x', new emaarServicesComCreatesrbpelprocessV.LookUpValuesResponse_element ());
                
                if(request instanceof emaarServicesComCreatesrbpelprocessV.DisclosureStmtDetailsRequest_element )
                response.put('response_x', new emaarServicesComCreatesrbpelprocessV.DisclosureStmtDetailsResponse_element ());
                
                if(request instanceof emaarServicesComCreatesrbpelprocessV.PerformActionRequest_element ){
                  if(emaarServicesComCreatesrbpelprocessVTest.CalloutType != null){
                    if(emaarServicesComCreatesrbpelprocessVTest.CalloutType == 'ExecutePaymentTerms'){
                      emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresponse= new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
                      objresponse.Status = 'SUCCESS';
                      objresponse.ErrorMessage = 'Payment Terms sent sucessfully';
                      objresponse.ResultXML = '<XX_ORDER_INFO><XX_ORDER_DETAILS><ORDER><LOCATION_ID>302559</LOCATION_ID><ORDER_DATE>23-Feb-2017</ORDER_DATE><PURCHASE_DATE>23-Feb-2017</PURCHASE_DATE><SELLING_PRICE>2152888</SELLING_PRICE><DISCOUNT></DISCOUNT><OPTIONS_AMOUNT>0.00</OPTIONS_AMOUNT><NET_AMOUNT>2152888</NET_AMOUNT><ORDER_EVENT>Tempo Dubai</ORDER_EVENT><ORDER_SOURCE>Order Search</ORDER_SOURCE><RESOURCE_MAIL>neethu.koshy@nsigulf.com</RESOURCE_MAIL><SCHEDULE_HEADER_ID>2626</SCHEDULE_HEADER_ID><EXCHANGE_RATE>1.0000</EXCHANGE_RATE><EXCHANGE_RATE_TYPE></EXCHANGE_RATE_TYPE><VAT_AMOUNT></VAT_AMOUNT><VAT_RATE_CODE></VAT_RATE_CODE><VAT_RATE></VAT_RATE><UNIT_CURRENCY>AED</UNIT_CURRENCY><TRANSACTIONAL_CURRENCY>AED</TRANSACTIONAL_CURRENCY><PREFERRED_NET_AMOUNT>2152888</PREFERRED_NET_AMOUNT><TRANSACTIONAL_NET_AMOUNT></TRANSACTIONAL_NET_AMOUNT> <FUNCTIONAL_CURRENCY>AED</FUNCTIONAL_CURRENCY><UNIT_SELLING_PRICE>2152888</UNIT_SELLING_PRICE><UNIT_OPTION_MAP_ID>0</UNIT_OPTION_MAP_ID><CAMPAIGN_ID>7014E00000013J8</CAMPAIGN_ID><UNIT_CAMPAIGN_MAP_ID>0</UNIT_CAMPAIGN_MAP_ID><SALES_AGENT_NAME>Frontier Agencies</SALES_AGENT_NAME><SALES_AGENT_ID>101051857</SALES_AGENT_ID><SALES_ADMIN_EMAIL></SALES_ADMIN_EMAIL><CREATION_SOURCE>SALESFORCE_APP</CREATION_SOURCE><MODE_OF_PAYMENT></MODE_OF_PAYMENT><USER_NAME></USER_NAME><OPPORTUNITY>0064E000003oWzWQAU</OPPORTUNITY></ORDER></XX_ORDER_DETAILS></XX_ORDER_INFO>';
                      response.put('response_x', objresponse);
                    }
                    else if(emaarServicesComCreatesrbpelprocessVTest.CalloutType == 'ExecutePaymentTermsSalesDiscount'){
                      emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresponse= new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
                      objresponse.Status = 'S';
                      objresponse.ErrorMessage = 'Payment Terms sent sucessfully';
                      objresponse.ResultXML = '<?xml version="1.0" encoding="UTF-8"?> <P_RESULT_XML xmlns="http://xmlns.oracle.com/pcbpel/adapter/db/APPS/XX_MOBILE_INT_PKG/PERFORM_ACTION/"> <XX_SALES_LAUNCH xmlns=""> <XX_LOC_PAYMENT_TERMS_T> <XX_LOC_PAYMENT_TERMS_O> <LOCATION_ID>363217</LOCATION_ID> <ORG_ID>81</ORG_ID> <INST_NUMBER>1</INST_NUMBER> <ORDER_NUMBER>83459</ORDER_NUMBER> <NET_AMOUNT>429178</NET_AMOUNT> <NET_PERCENT>10</NET_PERCENT> <TERMDATE>2018-01-21</TERMDATE> <VAT_RATE>5</VAT_RATE> <VAT_AMOUNT>21458.9</VAT_AMOUNT> <VAT_NET_AMOUNT>450636.9</VAT_NET_AMOUNT> <LOCATION_CODE>BD Act One Act Two T2-37-3709</LOCATION_CODE> <MILESTONE>FIRST</MILESTONE> <SM_HEADER_ID>4868</SM_HEADER_ID> </XX_LOC_PAYMENT_TERMS_O> <XX_LOC_PAYMENT_TERMS_O> <LOCATION_ID>363217</LOCATION_ID> <ORG_ID>81</ORG_ID> <INST_NUMBER>2</INST_NUMBER> <ORDER_NUMBER>83459</ORDER_NUMBER> <NET_AMOUNT>429178</NET_AMOUNT> <NET_PERCENT>10</NET_PERCENT> <TERMDATE>2018-01-21</TERMDATE> <VAT_RATE>5</VAT_RATE> <VAT_AMOUNT>21458.9</VAT_AMOUNT> <VAT_NET_AMOUNT>450636.9</VAT_NET_AMOUNT> <LOCATION_CODE>BD Act One Act Two T2-37-3709</LOCATION_CODE> <MILESTONE>SECOND</MILESTONE> <SM_HEADER_ID>4868</SM_HEADER_ID> </XX_LOC_PAYMENT_TERMS_O> <XX_LOC_PAYMENT_TERMS_O> <LOCATION_ID>363217</LOCATION_ID> <ORG_ID>81</ORG_ID> <INST_NUMBER>3</INST_NUMBER> <ORDER_NUMBER>83459</ORDER_NUMBER> <NET_AMOUNT>429178</NET_AMOUNT> <NET_PERCENT>10</NET_PERCENT> <TERMDATE>2018-01-21</TERMDATE> <VAT_RATE>5</VAT_RATE> <VAT_AMOUNT>21458.9</VAT_AMOUNT> <VAT_NET_AMOUNT>450636.9</VAT_NET_AMOUNT> <LOCATION_CODE>BD Act One Act Two T2-37-3709</LOCATION_CODE> <MILESTONE>THIRD</MILESTONE> <SM_HEADER_ID>4868</SM_HEADER_ID> </XX_LOC_PAYMENT_TERMS_O> <XX_LOC_PAYMENT_TERMS_O> <LOCATION_ID>363217</LOCATION_ID> <ORG_ID>81</ORG_ID> <INST_NUMBER>4</INST_NUMBER> <ORDER_NUMBER>83459</ORDER_NUMBER> <NET_AMOUNT>429178</NET_AMOUNT> <NET_PERCENT>10</NET_PERCENT> <TERMDATE>2018-02-28</TERMDATE> <VAT_RATE>5</VAT_RATE> <VAT_AMOUNT>21458.9</VAT_AMOUNT> <VAT_NET_AMOUNT>450636.9</VAT_NET_AMOUNT> <LOCATION_CODE>BD Act One Act Two T2-37-3709</LOCATION_CODE> <MILESTONE>FOUR</MILESTONE> <SM_HEADER_ID>4868</SM_HEADER_ID> </XX_LOC_PAYMENT_TERMS_O> <XX_LOC_PAYMENT_TERMS_O> <LOCATION_ID>363217</LOCATION_ID> <ORG_ID>81</ORG_ID> <INST_NUMBER>5</INST_NUMBER> <ORDER_NUMBER>83459</ORDER_NUMBER> <NET_AMOUNT>429178</NET_AMOUNT> <NET_PERCENT>10</NET_PERCENT> <TERMDATE>2018-12-25</TERMDATE> <VAT_RATE>5</VAT_RATE> <VAT_AMOUNT>21458.9</VAT_AMOUNT> <VAT_NET_AMOUNT>450636.9</VAT_NET_AMOUNT> <LOCATION_CODE>BD Act One Act Two T2-37-3709</LOCATION_CODE> <MILESTONE>20</MILESTONE> <SM_HEADER_ID>4868</SM_HEADER_ID> </XX_LOC_PAYMENT_TERMS_O> <XX_LOC_PAYMENT_TERMS_O> <LOCATION_ID>363217</LOCATION_ID> <ORG_ID>81</ORG_ID> <INST_NUMBER>6</INST_NUMBER> <ORDER_NUMBER>83459</ORDER_NUMBER> <NET_AMOUNT>429178</NET_AMOUNT> <NET_PERCENT>10</NET_PERCENT> <TERMDATE>2019-11-25</TERMDATE> <VAT_RATE>5</VAT_RATE> <VAT_AMOUNT>21458.9</VAT_AMOUNT> <VAT_NET_AMOUNT>450636.9</VAT_NET_AMOUNT> <LOCATION_CODE>BD Act One Act Two T2-37-3709</LOCATION_CODE> <MILESTONE>60</MILESTONE> <SM_HEADER_ID>4868</SM_HEADER_ID> </XX_LOC_PAYMENT_TERMS_O> <XX_LOC_PAYMENT_TERMS_O> <LOCATION_ID>363217</LOCATION_ID> <ORG_ID>81</ORG_ID> <INST_NUMBER>7</INST_NUMBER> <ORDER_NUMBER>83459</ORDER_NUMBER> <NET_AMOUNT>1716714.4</NET_AMOUNT> <NET_PERCENT>40</NET_PERCENT> <TERMDATE>2020-11-30</TERMDATE> <VAT_RATE>5</VAT_RATE> <VAT_AMOUNT>85835.72</VAT_AMOUNT> <VAT_NET_AMOUNT>1802550.12</VAT_NET_AMOUNT> <LOCATION_CODE>BD Act One Act Two T2-37-3709</LOCATION_CODE> <MILESTONE>100</MILESTONE> <SM_HEADER_ID>4868</SM_HEADER_ID> </XX_LOC_PAYMENT_TERMS_O> </XX_LOC_PAYMENT_TERMS_T> <XX_LOC_HEADER_T> <XX_LOC_HEADER_O> <LOCATION_ID>363217</LOCATION_ID> <ORG_ID>81</ORG_ID> <ORDER_NUMBER>83459</ORDER_NUMBER> <HEADER_NET_AMOUNT>4291782.4</HEADER_NET_AMOUNT> <HEADER_TAX_RATE>5</HEADER_TAX_RATE> <HEADER_VAT_AMOUNT>214589.12</HEADER_VAT_AMOUNT> <HEADER_VAT_NET_AMOUNT>4506371.52</HEADER_VAT_NET_AMOUNT> <OLD_NET_AMOUNT>0</OLD_NET_AMOUNT> <OLD_VAT_NET_AMOUNT>0</OLD_VAT_NET_AMOUNT> </XX_LOC_HEADER_O> </XX_LOC_HEADER_T> </XX_SALES_LAUNCH> </P_RESULT_XML>';
                      response.put('response_x', objresponse);
                    }else if(emaarServicesComCreatesrbpelprocessVTest.CalloutType == 'Payment Terms Creation'){
                      emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresponse= new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
                      objresponse.Status = 'SUCCESS';
                      objresponse.ErrorMessage = 'Payment Terms sent sucessfully';
                      objresponse.ResultXML = '<?xml version="1.0" encoding="ISO-8859-1"?><HelpTextDetails><BaseURL>http://click-pledge.v-empower.com/web/HelpText/HelpTextXml</BaseURL><HelpTab TabName="C&P InvoicePayment" label="C&P InvoicePayment"><TabSection Name="C&P InvoicePayment"></TabSection></HelpTab></HelpTextDetails>';
                      response.put('response_x', objresponse);
                    }else if(emaarServicesComCreatesrbpelprocessVTest.CalloutType == 'executePerformAction'){
                      if(emaarServicesComCreatesrbpelprocessVTest.CalloutTypeNew != null && emaarServicesComCreatesrbpelprocessVTest.CalloutTypeNew == 'executePerformAction-printRes'){
                                emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresponse= new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
                                objresponse.Status = 'Error';
                                objresponse.ErrorMessage = 'Payment Terms sent sucessfully';
                                objresponse.ResultXML = '<?xml version="1.0" encoding="ISO-8859-1"?><HelpTextDetails><BaseURL>http://click-pledge.v-empower.com/web/HelpText/HelpTextXml</BaseURL><HelpTab TabName="C&P InvoicePayment" label="C&P InvoicePayment"><TabSection Name="C&P InvoicePayment"></TabSection></HelpTab></HelpTextDetails>';
                                response.put('response_x', objresponse);
                            }else{
                                emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresponse= new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
                            objresponse.Status = 'SUCCESS';
                          objresponse.ErrorMessage = 'Payment Terms sent sucessfully';
                          objresponse.ResultXML = '<?xml version="1.0" encoding="ISO-8859-1"?><HelpTextDetails><BaseURL>http://click-pledge.v-empower.com/web/HelpText/HelpTextXml</BaseURL><HelpTab TabName="C&P InvoicePayment" label="C&P InvoicePayment"><TabSection Name="C&P InvoicePayment"></TabSection></HelpTab></HelpTextDetails>';
                          response.put('response_x', objresponse);
                                if(emaarServicesComCreatesrbpelprocessVTest.CalloutTypeNew != null && emaarServicesComCreatesrbpelprocessVTest.CalloutTypeNew == 'printRes')
                  emaarServicesComCreatesrbpelprocessVTest.CalloutTypeNew = 'executePerformAction-printRes';
                        }
                        }else if(emaarServicesComCreatesrbpelprocessVTest.CalloutType == 'Sales Order Creation for Joint Owners'){
                          emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresponse= new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
                            objresponse.Status = 'SUCCESS';
                            objresponse.ErrorMessage = 'Sales Order Created for Joint Owners';
                            objresponse.ResultXML = '<P_RESULT_XML xmlns="http://xmlns.oracle.com/pcbpel/adapter/db/APPS/XX_MOBILE_INT_PKG/PERFORM_ACTION/">';
                 objresponse.ResultXML += '<PARTY_INFO xmlns="">';
                  objresponse.ResultXML += '<PARTY_NUMBER>569209</PARTY_NUMBER>';
                  objresponse.ResultXML += '<PARTY_ID>12884485</PARTY_ID>';
                  objresponse.ResultXML += '<JOINT_OWNER>';
                   objresponse.ResultXML += '<JOINT_OWNER_INFO/>';
                  objresponse.ResultXML += '</JOINT_OWNER>';
                 objresponse.ResultXML += '</PARTY_INFO>';
              objresponse.ResultXML += '</P_RESULT_XML>';
                            
                            response.put('response_x', objresponse);
                        }else{
                          emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresponse= new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
                            objresponse.Status = 'SUCCESS';
                            objresponse.ErrorMessage = 'Payment Terms sent sucessfully';
                            objresponse.ResultXML = '<?xml version="1.0" encoding="ISO-8859-1"?><HelpTextDetails><BaseURL>http://click-pledge.v-empower.com/web/HelpText/HelpTextXml</BaseURL><HelpTab TabName="C&P InvoicePayment" label="C&P InvoicePayment"><TabSection Name="C&P InvoicePayment"></TabSection></HelpTab></HelpTextDetails>';
                            response.put('response_x', objresponse);
                        }
                        
                }else{
                    emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresponse= new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
                objresponse.Status = 'SUCCESS';
                objresponse.ErrorMessage = 'Payment Terms sent sucessfully';
                objresponse.ResultXML = '<XX_ORDER_INFO><XX_ORDER_DETAILS><ORDER><LOCATION_ID>302559</LOCATION_ID><ORDER_DATE>23-Feb-2017</ORDER_DATE><PURCHASE_DATE>23-Feb-2017</PURCHASE_DATE><SELLING_PRICE>2152888</SELLING_PRICE><DISCOUNT></DISCOUNT><OPTIONS_AMOUNT>0.00</OPTIONS_AMOUNT><NET_AMOUNT>2152888</NET_AMOUNT><ORDER_EVENT>Tempo Dubai</ORDER_EVENT><ORDER_SOURCE>Order Search</ORDER_SOURCE><RESOURCE_MAIL>neethu.koshy@nsigulf.com</RESOURCE_MAIL><SCHEDULE_HEADER_ID>2626</SCHEDULE_HEADER_ID><EXCHANGE_RATE>1.0000</EXCHANGE_RATE><EXCHANGE_RATE_TYPE></EXCHANGE_RATE_TYPE><VAT_AMOUNT></VAT_AMOUNT><VAT_RATE_CODE></VAT_RATE_CODE><VAT_RATE></VAT_RATE><UNIT_CURRENCY>AED</UNIT_CURRENCY><TRANSACTIONAL_CURRENCY>AED</TRANSACTIONAL_CURRENCY><PREFERRED_NET_AMOUNT>2152888</PREFERRED_NET_AMOUNT><TRANSACTIONAL_NET_AMOUNT></TRANSACTIONAL_NET_AMOUNT> <FUNCTIONAL_CURRENCY>AED</FUNCTIONAL_CURRENCY><UNIT_SELLING_PRICE>2152888</UNIT_SELLING_PRICE><UNIT_OPTION_MAP_ID>0</UNIT_OPTION_MAP_ID><CAMPAIGN_ID>7014E00000013J8</CAMPAIGN_ID><UNIT_CAMPAIGN_MAP_ID>0</UNIT_CAMPAIGN_MAP_ID><SALES_AGENT_NAME>Frontier Agencies</SALES_AGENT_NAME><SALES_AGENT_ID>101051857</SALES_AGENT_ID><SALES_ADMIN_EMAIL></SALES_ADMIN_EMAIL><CREATION_SOURCE>SALESFORCE_APP</CREATION_SOURCE><MODE_OF_PAYMENT></MODE_OF_PAYMENT><USER_NAME></USER_NAME><OPPORTUNITY>0064E000003oWzWQAU</OPPORTUNITY></ORDER></XX_ORDER_DETAILS></XX_ORDER_INFO>';
                response.put('response_x', objresponse);
                  }
                }
                if(request instanceof emaarServicesComCreatesrbpelprocessV.PerformConcurrentActionRequest_element )
                response.put('response_x', new emaarServicesComCreatesrbpelprocessV.PerformConcurrentActionResponse_element ());
                
                
                //
                //if(request instanceof emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt)
                  //  response.put('response_x', new emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt().executeDisclosureStmtDetails('',''));
                if(request instanceof emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt){
                    //emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objRes = new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
                    emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element objresponse= new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
              objresponse.Status = 'SUCCESS';
              objresponse.ErrorMessage = 'Payment Terms sent sucessfully';
              objresponse.ResultXML = '<XX_ORDER_INFO><XX_ORDER_DETAILS><ORDER><LOCATION_ID>302559</LOCATION_ID><ORDER_DATE>23-Feb-2017</ORDER_DATE><PURCHASE_DATE>23-Feb-2017</PURCHASE_DATE><SELLING_PRICE>2152888</SELLING_PRICE><DISCOUNT></DISCOUNT><OPTIONS_AMOUNT>0.00</OPTIONS_AMOUNT><NET_AMOUNT>2152888</NET_AMOUNT><ORDER_EVENT>Tempo Dubai</ORDER_EVENT><ORDER_SOURCE>Order Search</ORDER_SOURCE><RESOURCE_MAIL>neethu.koshy@nsigulf.com</RESOURCE_MAIL><SCHEDULE_HEADER_ID>2626</SCHEDULE_HEADER_ID><EXCHANGE_RATE>1.0000</EXCHANGE_RATE><EXCHANGE_RATE_TYPE></EXCHANGE_RATE_TYPE><VAT_AMOUNT></VAT_AMOUNT><VAT_RATE_CODE></VAT_RATE_CODE><VAT_RATE></VAT_RATE><UNIT_CURRENCY>AED</UNIT_CURRENCY><TRANSACTIONAL_CURRENCY>AED</TRANSACTIONAL_CURRENCY><PREFERRED_NET_AMOUNT>2152888</PREFERRED_NET_AMOUNT><TRANSACTIONAL_NET_AMOUNT></TRANSACTIONAL_NET_AMOUNT> <FUNCTIONAL_CURRENCY>AED</FUNCTIONAL_CURRENCY><UNIT_SELLING_PRICE>2152888</UNIT_SELLING_PRICE><UNIT_OPTION_MAP_ID>0</UNIT_OPTION_MAP_ID><CAMPAIGN_ID>7014E00000013J8</CAMPAIGN_ID><UNIT_CAMPAIGN_MAP_ID>0</UNIT_CAMPAIGN_MAP_ID><SALES_AGENT_NAME>Frontier Agencies</SALES_AGENT_NAME><SALES_AGENT_ID>101051857</SALES_AGENT_ID><SALES_ADMIN_EMAIL></SALES_ADMIN_EMAIL><CREATION_SOURCE>SALESFORCE_APP</CREATION_SOURCE><MODE_OF_PAYMENT></MODE_OF_PAYMENT><USER_NAME></USER_NAME><OPPORTUNITY>0064E000003oWzWQAU</OPPORTUNITY></ORDER></XX_ORDER_DETAILS></XX_ORDER_INFO>';
              response.put('response_x', objresponse);
                    //response.put('response_x', new emaarServicesComIphonemobileintproces.IPhoneMobileIntProcess_pt().executePerformAction('','','','','','','','','','','','','','','','','','','','','','','','',''));
                
                  system.debug('objresponse is : '+objresponse);
                }
                
        }
    }
}