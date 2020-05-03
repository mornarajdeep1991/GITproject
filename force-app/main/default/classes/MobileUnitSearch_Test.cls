@isTest
public class MobileUnitSearch_Test {
    
    
    @isTest
    static void testMobileUnitSearch() {
        test.startTest();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/UnitSearch/filters';
        
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        MobileUnitSearch.httpGet();
        
        req.requestURI = '/services/apexrest/UnitSearch/search';
        req.addParameter('queryFields', 'Name, RecordTypeId');
        MobileUnitSearch.httpGet();
        
        test.stopTest();
    }
}