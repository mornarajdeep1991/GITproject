@isTest
global class TestHttpMockTestHelper implements HttpCalloutMock  {
  public static Integer statusCode;
  public static string Body;
    global HTTPResponse respond(HTTPRequest req) {
    // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('Content-Disposition', '"test"');
        res.setBody('{"foo":"bar"}');
        res.setStatusCode(200);
        if(TestHttpMockTestHelper.statusCode != null){
            res.setStatusCode(TestHttpMockTestHelper.statusCode);
        }
        if(TestHttpMockTestHelper.Body != null)
          res.setBody(TestHttpMockTestHelper.Body);
        return res;
    }
}