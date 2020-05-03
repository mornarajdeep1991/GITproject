@isTest
global class MockTestReceiptSerive implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"X_RETURN_STATUS": "SUCCESS||x_result_xml","X_ERROR_MESSAGE": {"@nil": "true"},"RECEIPT_DETAIL": {"RECEIPT_DOC_DETAIL": {"RECEIPT_DETAIL": {"ACCOUNT_NAME": "Expression of Interest C.G","RECEIPT_NUMBER": "cash","AMOUNT": "60000","STATE_DSP": "Remitted","DOCUMENT_NUMBER": "479379", "CREATION_DATE": "02/05/2020 14:55:34","COMMENTS": "EOI CG Ali Elshendidy 1APT","METHOD_NAME": "Emaar EG Cash In Safe & Visa", "RECEIPT_DATE": "2020-02-05","GL_DATE": "2020-02-05"}}}}');
        res.setStatusCode(200);
        return res;
    }
}