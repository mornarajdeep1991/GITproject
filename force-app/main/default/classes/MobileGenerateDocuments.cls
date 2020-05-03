@RestResource(urlMapping='/GenerateDocuments/*')
global class MobileGenerateDocuments {

    @HttpPost
    global static void httpPost() {
        system.debug('## MobileGenerateDocuments HTTP POST Started');
        
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        
        String oppId = request.params.get('oppId');
        
        String requestType = request.requestURI.substring(request.requestURI.lastIndexOf('/') + 1);
        
        if (requestType.equalsIgnoreCase('salesoffer')) {
            generateSalesOffer(oppId, response);
        }
        
    }
    
    private static void generateSalesOffer(String oppId, RestResponse response) {
        String createContentResult = EGY_GenerateSalesOfferController.CreateContentAttachments(oppId);
        System.debug('createContentResult: ' + createContentResult);
        
        String generateOfferResult = '';
        
        if (createContentResult.contains('success')) {
            generateOfferResult = EGY_GenerateSalesOfferController.generateOffer(oppId);
            System.debug('generateOfferResult: ' + generateOfferResult);
        } else {
            returnFail(response, createContentResult);
            return;
        }
        
        String deleteContentResult = '';
        String fileId = '';
        if (generateOfferResult.contains('success')) {
            fileId = generateOfferResult.split('-').get(1);
            deleteContentResult = EGY_GenerateSalesOfferController.deleteContentAttachment(createContentResult);
            System.debug('deleteContentResult: ' + deleteContentResult);
        } else {
            returnFail(response, generateOfferResult);
            return;
        }
        
        returnSuccess(response, fileId);
    }
    
    private static void returnFail(RestResponse response, String result) {
        GenerateDocumentsResponseDTO responseDTO = new GenerateDocumentsResponseDTO();
        responseDTO.isSuccess = false;
        responseDTO.errorMessage = result;
        
        response.addHeader('content-type', 'application/json');        
        response.responseBody = Blob.valueOf(JSON.serialize(responseDTO));
        response.statusCode = 200;
    }
    
    private static void returnSuccess(RestResponse response, String fileId) {
        GenerateDocumentsResponseDTO responseDTO = new GenerateDocumentsResponseDTO();
        responseDTO.isSuccess = true;
        responseDTO.fileId = fileId;
        
        response.addHeader('content-type', 'application/json');        
        response.responseBody = Blob.valueOf(JSON.serialize(responseDTO));
        response.statusCode = 200;
    }
    
    public class GenerateDocumentsResponseDTO {
        public String fileId {get; set;}
        public Boolean isSuccess {get; set;}
        public String errorMessage {get; set;}
    }
}