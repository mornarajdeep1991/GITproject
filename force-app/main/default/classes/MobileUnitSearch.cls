@RestResource(urlMapping='/UnitSearch/*')
global class MobileUnitSearch {

    @HttpGet
    global static void httpGet() {
        system.debug('## MobileUnitSearch HTTP Get Started');
        
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        
        String requestType = request.requestURI.substring(request.requestURI.lastIndexOf('/') + 1);

		String returnString = '';
        if (requestType.equalsIgnoreCase('filters')) {
            String building = request.params.get('building');
            
            returnString = getSearchFilters(building);
        } else if (requestType.equalsIgnoreCase('search')) {
            String locationCode = request.params.get('locationCode');
            String buildingName = request.params.get('buildingName');
            String unitType = request.params.get('unitType');
            String unitModel = request.params.get('unitModel');
            String bedrooms = request.params.get('bedrooms');
            String oppId = request.params.get('oppId');
            String queryFields = request.params.get('queryFields');
            String propertyId = request.params.get('Project');
            String minPrice = request.params.get('minPrice');
            String maxPrice = request.params.get('maxPrice');
            String selectedCampaign = request.params.get('selectedCampaign');
            
            returnString = doSearchUnit(locationCode, buildingName, unitType, unitModel, bedrooms, propertyId, minPrice, maxPrice, oppId, selectedCampaign, queryFields);

        }
        
        response.responseBody = Blob.valueOf(returnString);
        response.addHeader('content-type', 'application/json');
        response.statusCode = 200;
        
        system.debug('## MobileUnitSearch HTTP Get Ended');
    }
    
    private static String getSearchFilters(String building) {
        system.debug('## MobileUnitSearch getSearchFilters Started');
        
        UnitSearchFilters filterDTO = new UnitSearchFilters();
        
        Set<Id> propertyInventoryIds = CM_EmaarUtils.getAccessableInventoryIds();

        filterDTO.buildingsFilterOption = CM_EmaarUtils.fieldsMapByQueryingFieldValue('buildingsFilterOption', building, propertyInventoryIds);
       	filterDTO.unitTypeFilterOption = CM_EmaarUtils.fieldsMapByQueryingFieldValue('unitTypeFilterOption', building, propertyInventoryIds);
        filterDTO.unitModelFilterOption = CM_EmaarUtils.fieldsMapByQueryingFieldValue('unitModelFilterOption', building, propertyInventoryIds);
        filterDTO.bedroomsFilterOption = CM_EmaarUtils.fieldsMapByQueryingFieldValue('bedroomsFilterOption', building, propertyInventoryIds);
        
        system.debug('## MobileUnitSearch getSearchFilters Ended');
        
        return JSON.serialize(filterDTO);
    }
    
    private static String doSearchUnit(String location_code, String buildingName, String unitType, String unitModel, String bedrooms, String propertyId, String minPriceStr, String maxPriceStr, String oppId, String selectedCampaign, String queryFields) {
        system.debug('## MobileUnitSearch doSearchUnit Started');
        
        Integer minPrice = null;
        Integer maxPrice = null;
        try {
            minPrice = Integer.valueOf(minPriceStr);
        } catch(Exception ex) {
            minPrice = null;
        }
        
        try {
            maxPrice = Integer.valueOf(maxPriceStr);
        } catch (Exception ex) {
            maxPrice = null;
        }
        
        LIST<Property_Inventory__c> unitResultList = EGY_AddPropertiesCtrl.doSearch(location_code, buildingName, unitType, unitModel, bedrooms, propertyId, minPrice, maxPrice, selectedCampaign, oppId, queryFields);
        
        
        system.debug('## MobileUnitSearch doSearchUnit Ended');
        
        return JSON.serialize(unitResultList);
        
    }
    
    public class UnitSearchFilters {
        public Map<String, String> buildingsFilterOption {get; set;}
        public Map<String, String> unitTypeFilterOption {get; set;}
        public Map<String, String> unitModelFilterOption {get; set;}
        public Map<String, String> bedroomsFilterOption {get; set;}
    }
}