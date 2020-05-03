/**********************/
/**
    Who (Divya 4c)
    This is a mock class for EmaarWebServiceUtils 
**/
/**********************/
@isTest
global class WebServiceMockImpl implements WebServiceMock {
   global void doInvoke(Object stub,Object request,Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
       emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element respElement = 
           new emaarServicesComCreatesrbpelprocessV.PerformActionResponse_element();
       response.put('response_x', respElement); 
   }
}