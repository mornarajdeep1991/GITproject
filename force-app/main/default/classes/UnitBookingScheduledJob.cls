global class UnitBookingScheduledJob implements Schedulable{
    public Id unitId;
    public boolean release;
    public UnitBookingScheduledJob(Id uId, boolean r){
        this.unitId = uId;
        this.release = r;
    }
    
    global void execute(SchedulableContext ctx) {
        //get unit
        List<Property_Inventory__c> units = [select Id, Booking_Stage__c, Campaign_Type__c, Property_Status__c 
                                             from Property_Inventory__c where Id = :this.unitId
                                            ];
        if(units.size() > 0){
            Property_Inventory__c u = units[0];
            if((u.Property_Status__c == 'Booked' || u.Property_Status__c == 'Blocked') && this.release){
                //release unit
                if(u.Property_Status__c == 'Blocked')
                    EGY_ManageInventoryCtrl.unblockUnit(new List<Id>{this.unitId});
                u.Property_Status__c = 'Available';
                u.Booking_Stage__c = 0;
                u.Property_Type__c = 'Sale';
                u.Block_Remarks__c = '';
                u.Block_Reason__c = null;
                u.Blocked_Reason_Code__c = null;
                update u;
                List<ProcessInstanceWorkitem> steps = [Select p.Id from ProcessInstanceWorkitem p where p.ProcessInstance.TargetObjectId =: this.unitId];
                for(ProcessInstanceWorkitem workItem  : steps){
                    Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                    req2.setComments('Auto rejected by the system as the unit would have exceeded the SLA for Launches.');
                    req2.setAction('Reject');
                    req2.setWorkitemId(workItem.Id);
                    Approval.process(req2);
                }
            }else if((u.Property_Status__c == 'Booked' || u.Property_Status__c == 'Blocked') && ! this.release){
                //send for approval
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Please, approve or reject the booking extension for this unit.');
                req1.setObjectId(u.id);
                req1.setSkipEntryCriteria(true);
                req1.setProcessDefinitionNameOrId('Unit_Booking_SLA_Approvals');
                if(!Test.isRunningTest()) Approval.process(req1);
            }else{
                //do nothing as the unit doesn't fit criteria
            }
        }
    }
}