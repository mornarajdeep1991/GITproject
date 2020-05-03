public without sharing class EGY_ModifyPaymentTerms_Ctrl {
    @AuraEnabled
    public static Opportunity_Property__c getOffer(String oppId){
        return [select Id, Campaign_Price__c, Max_Terms_Date__c, cm_Property_Inventory__c,
                cm_Property_Inventory__r.Finishing__c,
                cm_Property_Inventory__r.Selling_Price__c, Original_Campaign_Price__c
                FROM Opportunity_Property__c WHERE cm_Opportunity__c = :oppId LIMIT 1
               ];
    }
    @AuraEnabled
    public static List<EGY_PaymentTermWrapper> getPaymentTerms(String oppId){
        List<EGY_PaymentTermWrapper> terms = new List<EGY_PaymentTermWrapper>();
        for(Payment_Terms__c pt : [SELECT Name, Id, Installment_Amount__c, Maintnance_Price__c, cm_Term_Date__c,
                                   cm_Net_Percent__c, cm_Schedule_Type__c
                                   FROM Payment_Terms__c
                                   WHERE  Opportunity_Property__c IN (SELECT Id FROM Opportunity_Property__c WHERE cm_Opportunity__c =: oppId) 
                                   ORDER BY cm_Term_Date__c ASC ]){
             EGY_PaymentTermWrapper t = new EGY_PaymentTermWrapper(pt.Name, pt.cm_Schedule_Type__c, 
                                                                   decimal.valueOf(pt.cm_Net_Percent__c), 
                                                                   (pt.Maintnance_Price__c > 0)? pt.Maintnance_Price__c : pt.Installment_Amount__c, 
                                                                   Date.valueOf(pt.cm_Term_Date__c), 
                                                                   (pt.Maintnance_Price__c > 0)? true : false);
             terms.add(t);
        }
        return terms;        
    }
    @AuraEnabled
    public static String saveSpecialTerms(String terms, String oppId, String offerId, String scheduleType, String changePercentage,
                                          String discount, String totalAmount, String discountType, String unitId, Boolean finishing){
        List<Opportunity> opps = [select Id, cm_Sales_Executive_Manager__c from Opportunity where Id = :oppId];
        List<cm_Interim_Approval_Type__c> approvalTypes = [select id from cm_Interim_Approval_Type__c where name = :Label.Special_Terms_Approval_Type]; 
        cm_Interim_Approvals__c specialApproval = new cm_Interim_Approvals__c();
        SavePoint sp = database.setSavepoint();
        try{
            if(approvalTypes.size() > 0){
                delete [select Id from Payment_Terms__c where Opportunity_Property__c = :offerId];
                delete [select id from cm_Interim_Approvals__c where cm_Opportunity__c = :oppId
                        AND cm_Interim_Approval_Type__c = :approvalTypes[0].Id AND 
                        cm_decision__c = 'Decision Pending' AND Offer__c = :offerId
                ];
                specialApproval.cm_Opportunity__c = oppId;
                specialApproval.Schedule_Type__c = scheduleType;
                specialApproval.Loss_of_Interest__c = (changePercentage == null || changePercentage == '')? null : decimal.valueOf(changePercentage);
                specialApproval.Discount__c = (discount == null || discount == '')? null : decimal.valueOf(discount);
                specialApproval.Assign_To__c = opps[0].cm_Sales_Executive_Manager__c;
                specialApproval.Next_Approver__c = opps[0].cm_Sales_Executive_Manager__c;
                specialApproval.Offer__c = offerId;
                specialApproval.Discount_Type__c = discountType;
                specialApproval.Submit_for_Approval__c = false;
                specialApproval.cm_Interim_Approval_Type__c = approvalTypes[0].Id;
                insert specialApproval;
                //Create new terms
                List<EGY_PaymentTermWrapper> paymentTerms = (List<EGY_PaymentTermWrapper>) JSON.deserialize(terms, List<EGY_PaymentTermWrapper>.class);
                List<Payment_Terms__c> newTerms = new List<Payment_Terms__c>();
                Integer maintenanceTermsCount = 0;
                decimal maintenanceAmount = 0;
                for(EGY_PaymentTermWrapper wrapper : paymentTerms){
                    Payment_Terms__c term = new Payment_Terms__c();
                    term.Name = wrapper.InstallmentName;
                    term.Installment__c = wrapper.InstallmentNumber;
                    term.cm_Schedule_Type__c = wrapper.ScheduleType;
                    term.cm_Net_Percent__c = String.valueOf(wrapper.PercentagePayment);
                    term.cm_Term_Date__c = String.ValueOf(wrapper.TermDate);
                    if(wrapper.IsMaintenance){
                        maintenanceTermsCount++;
                        maintenanceAmount += wrapper.Amount;
                        term.Maintnance_Price__c = wrapper.Amount;
                        term.Installment_Amount__c = 0;
                    }
                    else{
                        term.Installment_Amount__c = wrapper.Amount;
                        term.Maintnance_Price__c = 0;
                    }
                    term.Opportunity_Property__c = offerId;
                    term.Special_Approval__c = specialApproval.Id;
                    newTerms.add(term);
                }
                insert newTerms;      
                system.debug(totalAmount+' '+maintenanceAmount+' '+maintenanceTermsCount);
                update new Opportunity_Property__c(Id = offerId, Current_Number_of_Terms__c = newTerms.size(),
                                                   Campaign_Price__c = Decimal.valueOf(totalAmount), 
                                                   Total_Maintenance_Fee__c = maintenanceAmount,
                                                   Number_of_Maintenance_Terms__c = maintenanceTermsCount);
                update new Property_Inventory__c(Id = unitId, Finishing__c = finishing);
            }else{
                throw new AuraHandledException('No Approval Types found with the name: '+Label.Special_Terms_Approval_Type);
            }
        }catch(Exception e){
            database.rollback(sp);
            System.debug('ERROR: '+e.getMessage()+' at line '+e.getLineNumber());
            throw new AuraHandledException('ERROR '+e.getLineNumber()+': '+e.getMessage());
        }
        return specialApproval.Id;
    }
    @AuraEnabled
    public static List<Opportunity_Property__c> getOpportunityUnits(String oppId){
        return [select Id, Name, cm_Opportunity__r.StageName 
                from Opportunity_Property__c where cm_Opportunity__c = :oppId LIMIT 1];
    }
}