/*****************************************/
/**
*  @Who     Rajnish Kumar <rajnishkumar393@gmail.com>
*  @When    07/06/2018
*  @What    Test Class for : EGY_GenerateSalesOfferController
*/
/****************************************/
@isTest 
public class EGY_GenerateSalesOfferController_Test {
    static testMethod void doTest() {
        test.starttest();
        
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonEmail ='test@gmail.com';
        objAccount.PersonMobilePhone ='5678903456';
        insert objAccount;
        
        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount.id;
        insert objOppor;
       
        
        ApexPages.StandardController sc = new ApexPages.StandardController(objOppor);
        EGY_GenerateSalesOfferController objController = new EGY_GenerateSalesOfferController(sc);
        //objController.generateSalesOffer();
        EGY_GenerateSalesOfferController.CreateContentAttachments('Test'); 
        EGY_GenerateSalesOfferController.generateOffer('Test');
        EGY_GenerateSalesOfferController.deleteContentAttachment('Test');
        test.stopTest();
    }
    /*
    static testMethod void doTest1() {
        
        Account objAccount = TestDataFactory.createPAccount();
        objAccount.PersonEmail ='test@gmail.com';
        objAccount.PersonMobilePhone ='5678903456';
        insert objAccount;
        
        Opportunity objOppor = TestDataFactory.createOpportunity();
        objOppor.AccountId = objAccount.id;
        insert objOppor;
       
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objOppor);
        EGY_GenerateSalesOfferController objController = new EGY_GenerateSalesOfferController(sc);
        //objController.generateSalesOffer();
        EGY_GenerateSalesOfferController.CreateContentAttachments(objOppor.id); 
        EGY_GenerateSalesOfferController.generateOffer(objOppor.id);
        EGY_GenerateSalesOfferController.deleteContentAttachment('test-');
        test.stopTest();
    }
    */
}