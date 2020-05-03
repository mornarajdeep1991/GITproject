public class GenerateEmaarReciept {
    public string imageURL{get;set;}
    public string JointOwner_customerName{get;set;}
    public string inventoryId;
    public list<Receiptwrap> lstwrap{get;set;}
    public map<string,string> ProjectLogoMap {get;set;}
    public string strRECID{get;set;}    
    public string type {get; set;}
    public GenerateEmaarReciept(){
        JointOwner_customerName = '';
        inventoryId = apexpages.currentPage().getParameters().get('id');
        strRECID = apexpages.currentPage().getParameters().get('recid');
        type = ApexPages.currentPage().getParameters().get('type');
        prepareImageURL();
        if(inventoryId!=null && inventoryId!='')
          GetReciept();

    }
    
    public void prepareImageURL(){
        imageURL='/servlet/servlet.FileDownload?file=';
        ProjectLogoMap =  new map<string,string>();
        List<Document> lstDocument = new list<Document>([select Id,name,DeveloperName, Description from document where Folder.name ='Receipt Logo']);
        for(Document doc :lstDocument){
            ProjectLogoMap.put(doc.name, doc.id);
        }
    }
    
    public void GetReciept(){
      lstwrap = new list<Receiptwrap>();
      string strQuery = 'select id,Opportunity__c, Amount__c, Currency__c,Cheque_Number__c, Reciept_Payment_Mode__c, Drawn_on_Bank__c,Comments__c, Installment_Details__c, Cash_Receipt_Id__c ,Customer_Number__c, Document_Number__c, Amount_in_Words__c,Reciept_Number__c, Mode_Of_Payment__c, Company_Name__c, PO_Box__c, Country__c,Maturity_Date_display__c,Telephone__c, Fax__c, Reciept_Date__c, Maturity_Date__c,Received_by__r.Name,Financier_Name__c, Org_Name__c,cm_Opportunity_Property__r.cm_Opportunity__r.Account.Name,cm_Opportunity_Property__r.cm_Property_Inventory__r.cm_Building__c,cm_Opportunity_Property__r.cm_Property_Inventory__r.Property__r.Property_Name__c, Unit_No__c from Reciepts__c where id!=null ' ;
      if(inventoryId!=null && inventoryId!='' && type != 'EOI'){
            strQuery = strQuery + ' and  cm_Opportunity_Property__c = :inventoryId ';
      }
      if(type != null && type == 'EOI'){
          strQuery = strQuery + ' and  Opportunity__c = :inventoryId ';        
      }

      if(strRECID!=null && strRECID!=''){
          strQuery = strQuery + ' and  Id = :strRECID ';
      }
      string strRevStatus = 'Reversed';
      strQuery = strQuery+' and Receipt_STATUS__c !=:strRevStatus and Reversal_Date__c=null';
      List<Joint_Owner__c> lstJointOwners = new List<Joint_Owner__c>();
       
      list<Reciepts__c> RecList = database.query(strQuery);
      if(RecList!=null && RecList.size() >0 && RecList[0].Opportunity__c!=null){
          lstJointOwners = [Select id,cm_joint_owner__r.Name from Joint_Owner__c where cm_Related_Opportunity__c =: RecList[0].Opportunity__c];
          for(Joint_Owner__c objJO:lstJointOwners){
              if(JointOwner_customerName == ''){
                  JointOwner_customerName = objJO.cm_joint_owner__r.Name;
              }else{
                  JointOwner_customerName = JointOwner_customerName +' / '+objJO.cm_joint_owner__r.Name;
              }
          }
          system.debug('****JointOwner_customerName'+JointOwner_customerName) ;
      }
      for(Reciepts__c rec: RecList ){
               Receiptwrap objwrap = new Receiptwrap();
               objwrap.strCURRENCY = rec.Currency__c;
               objwrap.AMOUNT = rec.Amount__c;
               objwrap.strDRAWN_BANK = rec.Drawn_on_Bank__c;
               objwrap.DOCUMENTNUMBER =  rec.Document_Number__c;
               objwrap.RECEIPT_DATE = rec.Reciept_Date__c;
               objwrap.strCUSTOMER_ID = rec.Customer_Number__c;
               objwrap.strPRICE_IN_WORDS = rec.Amount_in_Words__c;
               objwrap.strPAYMENT_METHOD = rec.Mode_Of_Payment__c;
               objwrap.strMATURITY_DATE = rec.Maturity_Date__c;
               objwrap.Maturity_Date = rec.Maturity_Date_display__c;
               objwrap.strFINANCIER_NAME = rec.Financier_Name__c;
               objwrap.strCOMMENTS = rec.Comments__c;
               objwrap.COMPANY_NAME = rec.Company_Name__c;
               objwrap.PO_BOX = rec.PO_Box__c;
               objwrap.COUNTRY = rec.Country__c;
               objwrap.TELEPHONE = rec.Telephone__c;
               objwrap.FAX = rec.Fax__c;
               objwrap.Cash_ReceiptId = rec.Cash_Receipt_Id__c;
               objwrap.RECIPT_NUMBER = rec.Reciept_Number__c;
               objwrap.ORG_NAME = rec.Org_Name__c;
               objwrap.UNIT_NAME = rec.Unit_No__c;
               objwrap.CHEQUE_NUMBER = rec.Cheque_Number__c != null ? String.valueOf(rec.Cheque_Number__c) : '';
               if(JointOwner_customerName == ''){
                    objwrap.customerName = rec.cm_Opportunity_Property__r.cm_Opportunity__r.Account.Name;
               }else if(JointOwner_customerName!=''){
                   objwrap.customerName = rec.cm_Opportunity_Property__r.cm_Opportunity__r.Account.Name+' / '+JointOwner_customerName ;
               }
               objwrap.RecivedName = rec.Received_by__r.Name;
               
               objwrap.LayoutType ='Emaar';
               //Logo Logo selection
               //cm_Opportunity_Property__r.cm_Property_Inventory__r.cm_Building__c,
               //cm_Opportunity_Property__r.cm_Property_Inventory__r.Property__r.Property_Name__c
                try{
                    string Building = rec.cm_Opportunity_Property__r.cm_Property_Inventory__r.cm_Building__c;
                    
                    string propertyName = rec.cm_Opportunity_Property__r.cm_Property_Inventory__r.Property__r.Property_Name__c;
                }
                catch(exception ex){
                   system.debug('Error:-> '+ex.getMessage());
                   objwrap.LayoutType ='Emaar'; 
                }
               lstwrap.add(objwrap);
               system.debug('********lstwrap****'+lstwrap);
        }
      system.debug('********lstwrap'+lstwrap);
    }

    public class Receiptwrap{
        public string LayoutType {get;set;}
        public string strCURRENCY{get;set;}
        public Decimal AMOUNT{get;set;}
        public string DOCUMENTNUMBER{get;set;}
        public Date RECEIPT_DATE{get;set;}
        public string strCUSTOMER_ID{get;set;}
        public string strRECIEVED_FORM{get;set;}
        public string strPRICE_IN_WORDS{get;set;}
        public string strPAYMENT_METHOD{get;set;}
        public string strDRAWN_BANK{get;set;}
        public string strMATURITY_DATE{get;set;}
        public date Maturity_Date {get;set;}
        public string strFINANCIER_NAME{get;set;}
        public string strCOMMENTS{get;set;}
        public string COMPANY_NAME{get;set;}
        public string PO_BOX{get;set;}
        public string TELEPHONE{get;set;}
        public string FAX{get;set;}
        public string RECIPT_NUMBER{get;set;}
        public string Cash_ReceiptId{get;set;}
        public string COUNTRY{get;set;}
        public string ORG_NAME{get;set;}
        public string customerName{get;set;}
        public string RecivedName{get;set;}
        public string UNIT_NAME {get; set;}
        public String CHEQUE_NUMBER {get; set;}
    }
}