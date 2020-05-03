@isTest
global class ChangePaymentPlanCalloutMock implements WebServiceMock {
    global void doInvoke(Object stub,Object request,Map<String, Object> response,
                         String endpoint,
                         String soapAction,
                         String requestName,
                         String responseNS,
                         String responseName,
                         String responseType) {
                             emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element respElement = 
                                 new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
                             respElement.Status = 'SUCCESS';
                             respElement.ErrorMessage = '';
                             respElement.ResultVar1 = '132';
                             respElement.ResultXML = '<RESPONSE><DATA><DATASUB><SALESORDER_NUMBER>123</SALESORDER_NUMBER><HEADERID>456</HEADERID><STATUS>SUCCESS</STATUS><ERROR_MESSAGE></ERROR_MESSAGE><RESULT_PAYMENTTERMS><PAYMENTTERM><LOCATION_ID>147</LOCATION_ID><ORG_ID>2165</ORG_ID><LOCATION_CODE>SE213</LOCATION_CODE><INST_NUMBER>1</INST_NUMBER><NET_AMOUNT>1000</NET_AMOUNT><NET_PERCENT>100</NET_PERCENT><TERMDAYS>10</TERMDAYS><TERMDATE>25/12/2019</TERMDATE><MILESTONE_NAME>TEST</MILESTONE_NAME><MIL_PERCENTAGE>100</MIL_PERCENTAGE><SM_HEADER_ID>1356</SM_HEADER_ID><SCHEDULE_TYPE>INSTALLMENT 1</SCHEDULE_TYPE><MILESTONE_NAME_ARB>القسط الأول</MILESTONE_NAME_ARB><VAT_RATE>10</VAT_RATE><VAT_AMOUNT>100</VAT_AMOUNT></PAYMENTTERM></RESULT_PAYMENTTERMS></DATASUB></DATA></RESPONSE>';
                             response.put('response_x', respElement); 
                         }
}