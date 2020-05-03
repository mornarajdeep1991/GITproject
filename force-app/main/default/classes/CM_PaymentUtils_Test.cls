/*****************************************/
/**
*  @Who     
*  @When    06/04/2018
*  @What    Test Class for cover CM_PaymentUtils
*/
/****************************************/
@isTest
public class CM_PaymentUtils_Test {

      public static testMethod void PositiveTest1()
        {
            Account acc=TestDataFactory.createBAccount();
            insert acc;
            
            Opportunity opp=TestDataFactory.CreateOpportunity();
            opp.accountId=acc.id;
            opp.Is_Pending_Email__c=true;
            opp.Is_From_Broker_App__c=true;
            insert opp;
                
                
            Location__c loc=TestDataFactory.CreateLocation('Sale');
            loc.Location_Code__c='123';
            insert loc;
            
            Property_Inventory__c inv=TestDataFactory.CreatePropertyInventory(loc.id);
            inv.Instance__c='123';
            inv.Building_Location__c=loc.id;
            inv.Location__c = loc.id;
            insert inv;
            
            Opportunity_Property__c prop= TestDataFactory.CreateOpportunityProperty(opp.id, inv.id);
           // prop.cm_Inventory_Location_Code__c='1234';
            prop.Location_Code__c=loc.id;
            prop.cm_Property_Inventory__c=inv.id;
            insert prop;
             
            Opportunity_Payment__c oppPay=new Opportunity_Payment__c();
            oppPay.Opportunity__c=opp.id;
            oppPay.Status__c='New';
            oppPay.Is_Read_Only__c=false;
            insert oppPay;
            //TestDataFactory.cre
            CM_PaymentUtils.GeneratePaymentLink('oppPay.id','asd','1000');       
          //  CM_PaymentUtils.GeneratePaymentLink('','','1000');
            CM_PaymentUtils.GenerateSFLink(oppPay.id);
            CM_PaymentUtils.ResendPaymentLink(oppPay.id);
           string data= encodingUtil.URLEncode(CM_PaymentUtils.CreateEncryptedData(string.valueOf(system.now())),'UTF-8');
          
            CM_PaymentUtils.ValidateSFLink(data);
            
            CM_PaymentUtils.createReciept(oppPay.id);
            
            //ValidatePaymentLink 
            CM_PaymentUtils.CreateMD5Signature(data);
            oppPay.Status__c='Gateway Payment Approved';
            update oppPay;
            CM_PaymentUtils.createReciept(oppPay.id);
            string xml='<?xml version="1.0"?><catalog>  <book id="CASH_RECEIPT_ID"></book></catalog>';
            CM_PaymentUtils.ParseRecieptXML(xml,new Reciepts__c());
            CM_PaymentUtils.GetElapsedTime(system.now(),system.now().addSeconds(45));
           // datetime.addSeconds(seconds)
            CM_PaymentUtils.GetHoursElapsed(system.today(),system.today());
            CM_PaymentUtils.GetSecondsElapsed(system.now().time(),system.now().time());
            Map<String,String> params=new Map<String,String>();
            params.put('vpc_First1', 'Unit test');
            CM_PaymentUtils.ValidatePaymentLink(params);
            CM_PaymentUtils.getPaymentSettings();
            CM_PaymentUtils.GenerateExpiryDate();
        }
}