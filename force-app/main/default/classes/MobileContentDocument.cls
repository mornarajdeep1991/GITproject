@RestResource(urlMapping='/MobileContentDocument')
global class MobileContentDocument {
	@HttpGet
    global static void httpGet() {
        system.debug('## MobileContentDocument HTTP Get Started');
        
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        
        //Get Related ID from the Request URI
        String relatedId = request.params.get('relatedId');
        
        List<ContentDocumentLink> documentLinkList = 
            new List<ContentDocumentLink>([SELECT ContentDocumentID, ContentDocument.Title, LinkedEntity.type, LinkedEntityId 
                                           FROM ContentDocumentLink 
                                           WHERE LinkedEntityId = :relatedId]);
        
        Map<String, EmaarDocumentDTO> emaarDocumentDTOMap = new Map<String, EmaarDocumentDTO>();
        for (ContentDocumentLink docLink : documentLinkList) {
            EmaarDocumentDTO docDTO = new EmaarDocumentDTO();
            docDTO.contentDocumentId = docLink.ContentDocumentID;
            docDTO.contentDocumentTitle = docLink.ContentDocument.Title;
            
            emaarDocumentDTOMap.put(docLink.ContentDocumentID, docDTO);
        }
        
        for (ContentVersion version : [SELECT Id, ContentDocumentId, VersionData 
                                       FROM ContentVersion 
                                       WHERE ContentDocumentId IN :emaarDocumentDTOMap.keySet()
                                       AND IsLatest = true])
        {
            if (!emaarDocumentDTOMap.containsKey(version.ContentDocumentID)) {
                continue;
            }
            EmaarDocumentDTO docDTO = emaarDocumentDTOMap.get(version.ContentDocumentID);
            //docDTO.contentDocumentVersionData = version.VersionData;
            docDTO.contentDocumentVersionId = version.Id;
        }
        
        System.debug(emaarDocumentDTOMap.values());
        response.addHeader('content-type', 'application/json');        
        response.responseBody = Blob.valueOf(JSON.serialize(emaarDocumentDTOMap.values()));
        response.statusCode = 200;
    }
    
    public class EmaarDocumentDTO {
        public String contentDocumentId {get; set;}
        public String contentDocumentTitle {get; set;}
        public String contentDocumentVersionId {get; set;}
        //public Blob contentDocumentVersionData {get; set;}
    }
}