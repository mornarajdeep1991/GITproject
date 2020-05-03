/* Class to generate floor plans for opportunity */
global class GenerateFloorPlans{
	public Id oppId {get; set;}

	public GenerateFloorPlans(ApexPages.StandardController sc){
		oppId = sc.getId();
	}

	@RemoteAction
    public static string CreateDOC(Id oppId){
      string strMessage = '';
      try{
         EmaarFloorPlans.ResponseHandler response = EmaarFloorPlans.getFloorPlans(String.valueOf(oppId), 'GETFLOORPLAN');
         if (response.success) {
           List<Attachment> floorplans = [select body, id, name, ParentId from attachment where id =: response.attachmentID];
           if (floorplans != null && floorplans.size() > 0) {
               Attachment floorplan = floorplans[0];
               strMessage = URL.getSalesforceBaseUrl().toExternalForm() +'/servlet/servlet.FileDownload?file='+floorplan.id;
               EmaarFloorPlans.getFloorPlans(String.valueOf(oppId), 'DELETE');
           }
         }
         else {
            strMessage = 'ERROR';
         }    
      }catch(exception ex){   
         strMessage = 'ERROR';      
      }
      return strMessage ;  
    } 
}