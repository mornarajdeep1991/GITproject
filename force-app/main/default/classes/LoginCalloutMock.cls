@isTest
global class LoginCalloutMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HTTPResponse resp = new HTTPResponse();
        resp.setStatus('Success');
        resp.setBody('');
        return resp;
    }
}