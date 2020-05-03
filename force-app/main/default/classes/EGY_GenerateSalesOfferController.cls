/************************************************************************************
* Name              : EGY_GenerateSalesOfferController                                                
* Description       : Class to redirect to the pages to generate sales offer                                           
* Created Date      : 09/05/2018                                                     
* Created By        : Prachi Sinha  (4C)    
* Jira/Req By       :                                                                                                                                           
************************************************************************************/

public with sharing class EGY_GenerateSalesOfferController {
    private String opportunityId {get; set;}

    public EGY_GenerateSalesOfferController(ApexPages.StandardController sctrl){
        opportunityId = sctrl.getId();
    }

    /* Remote method to create attachments, generate sales offer, delete attachment */
    @RemoteAction
    public static string CreateContentAttachments(String opportunityId){
        String result = '';
        try{
            result = CM_EmaarUtils.CreateContentAttachments(opportunityId);            
        }catch(Exception e){
            result = e.getMessage();
        }

        return result;
    }

    @RemoteAction
    public static string generateOffer(String opportunityId){
        String result = '';
        try{
            result = CM_EmaarUtils.GenerateSalesOffer(opportunityId);            
        }catch(Exception e){
            result = e.getMessage();
        }
        return result;
    }

    @RemoteAction
    public static string deleteContentAttachment(String attachmentIds){
        String result = '';
        try{
            result = CM_EmaarUtils.DeleteContentAttachments(attachmentIds);
        }catch(Exception e){
            result = e.getMessage();
        }
        return result;
    }
    
}