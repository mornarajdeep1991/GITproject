public class EGY_PaymentTermWrapper {
    @AuraEnabled public string InstallmentName {get;set;}
    @AuraEnabled public string ScheduleType {get;set;}
    @AuraEnabled public integer InstallmentNumber {get;set;}
    @AuraEnabled public decimal PercentagePayment {get;set;}
    @AuraEnabled public decimal Amount {get;set;}
    @AuraEnabled public date TermDate {get;set;}
    @AuraEnabled public boolean IsMaintenance {get;set;}
    public EGY_PaymentTermWrapper(string name, string scheduleType, decimal percentage, decimal amount, date termDate, boolean isMaintenance){
        this.InstallmentName = name;
        this.ScheduleType = scheduleType;
        this.InstallmentNumber = 0;
        this.PercentagePayment = percentage;
        this.Amount = amount;
        this.TermDate = termDate;
        this.IsMaintenance = isMaintenance;
    }
}