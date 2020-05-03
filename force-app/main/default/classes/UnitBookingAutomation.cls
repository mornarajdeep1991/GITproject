public class UnitBookingAutomation {
    @invocablemethod(description = 'Schedule Unit Booking')
    public static void scheduleBooking(List<Id> recordIds){
        List<Property_Inventory__c> units = [select Id, cm_Blocked_By__r.Role_Name__c, Booking_Stage__c, Campaign_Type__c, Property_Status__c 
                                             from Property_Inventory__c where Id IN :recordIds
                                            ];
        List<Campaign_Unit__c> campaignUnits = [select Id, cm_Campaign__r.Type, cm_Property_Inventory__c from Campaign_Unit__c 
                                                where cm_Property_Inventory__c In :recordIds AND
                                                (cm_Campaign__r.Type = 'Tempo Sales' OR 
                                                 (cm_Campaign__r.Type = 'Launch Sales' AND cm_Campaign__r.StartDate <= :Date.today() AND cm_Campaign__r.EndDate >= :Date.today()))
                                               ];
        Map<Id, List<Campaign_Unit__c>> unitsToCampaigns = new Map<Id, List<Campaign_Unit__c>>();
        for(Campaign_Unit__c cu : campaignUnits){
            if(unitsToCampaigns.containsKey(cu.cm_Property_Inventory__c)){
                List<Campaign_Unit__c> temp = unitsToCampaigns.get(cu.cm_Property_Inventory__c);
                temp.add(cu);
                unitsToCampaigns.put(cu.cm_Property_Inventory__c, temp);
            }else{
                unitsToCampaigns.put(cu.cm_Property_Inventory__c, new List<Campaign_Unit__c>{cu});
            }
        }
        if(unitsToCampaigns.size() > 0){
            for(Property_Inventory__c unit : units){
                //determine if it's a Launch or Tempo Campaign
                String campaignType = '';
                List<Campaign_Unit__c> unitCampaigns = unitsToCampaigns.get(unit.Id);
                for(Campaign_Unit__c cx : unitCampaigns){
                    if(cx.cm_Campaign__r.Type == 'Launch Sales'){
                        campaignType = 'Launch';
                        break;
                    }
                    if(cx.cm_Campaign__r.Type == 'Tempo Sales'){
                        campaignType = 'Tempo';
                        break;
                    }
                }
                update new Property_Inventory__c(Id = unit.Id, Approve_Booking__c = false, Campaign_Type__c = campaignType);
                //determine unit Booking Stage
                decimal bookingStage = unit.Booking_Stage__c;
                if(unit.Property_Status__c == 'Blocked' && campaignType == 'Launch'){
                    if(bookingStage == 0){
                        //schedule the approval to be sent after 2 hours
                        Datetime twoHoursLater = datetime.now().addHours(Integer.valueOf(Label.Launch_Blocking_Step1_Waiting_in_Hours));
                        //Datetime twoHoursLater = datetime.now().addMinutes(2);
                        String nextFireTime = twoHoursLater.second() + ' ' + twoHoursLater.minute() + ' ' + twoHoursLater.hour() +
                            ' '+twoHoursLater.day() + ' ' +twoHoursLater.month() + ' ? ' + twoHoursLater.year();
                        UnitBookingScheduledJob scheduledJob = new UnitBookingScheduledJob(unit.Id, false);
                        System.schedule('Auto Release a booked launch sales unit ['+twoHoursLater.getTime()+'-'+unit.Id+']', nextFireTime, scheduledJob);
                        //Schedule the mandatory release after 4 hours
                        Datetime fourHoursLater = datetime.now().addHours(Integer.valueOf(Label.Launch_Blocking_Step1_Waiting_in_Hours)+Integer.valueOf(Label.Launch_Blocking_Step2_Waiting_in_Hours));
                        //Datetime fourHoursLater = datetime.now().addMinutes(4);
                        String releaseTime = fourHoursLater.second() + ' ' + fourHoursLater.minute() + ' ' + fourHoursLater.hour() +
                            ' '+fourHoursLater.day() + ' ' +fourHoursLater.month() + ' ? ' + fourHoursLater.year();
                        UnitBookingScheduledJob releaseJob = new UnitBookingScheduledJob(unit.Id, true);
                        System.schedule('Auto Release a blocked launch sales unit ['+fourHoursLater.getTime()+'-'+unit.Id+']', releaseTime, releaseJob);                    
                    }
                }
                if(unit.Property_Status__c == 'Booked' && campaignType == 'Tempo'){
                    if(bookingStage == 0){
                        //run a scheduler to auto release the unit after 4 days or 2 days if it's done by the Head of Sales
                        Datetime fourDaysFromNow = datetime.now().addHours(Integer.valueOf(Label.Tempo_Booking_Step1_Waiting_in_Hours));
                        //Datetime fourDaysFromNow = datetime.now().addMinutes(4);
                        
                        String nextFireTime = fourDaysFromNow.second() + ' ' + fourDaysFromNow.minute() + ' ' + fourDaysFromNow.hour() +
                            ' '+fourDaysFromNow.day() + ' ' +fourDaysFromNow.month() + ' ? ' + fourDaysFromNow.year();
                        UnitBookingScheduledJob scheduledJob = new UnitBookingScheduledJob(unit.Id, false);
                        System.schedule('Auto Release a booked tempo sales unit ['+fourDaysFromNow.getTime()+'-'+unit.Id+']', nextFireTime, scheduledJob);
                    }else if(bookingStage == 1){
                        //run a scheduler to auto release the unit after 2 days
                        Datetime twoDaysFromNow = datetime.now().addHours(Integer.valueOf(Label.Tempo_Booking_Step2_Waiting_in_Hours));
                        //Datetime twoDaysFromNow = datetime.now().addMinutes(2);
                        //parse to cron expression
                        String nextFireTime = twoDaysFromNow.second() + ' ' + twoDaysFromNow.minute() + ' ' + twoDaysFromNow.hour() +
                            ' '+twoDaysFromNow.day() + ' ' +twoDaysFromNow.month() + ' ? ' + twoDaysFromNow.year();
                        UnitBookingScheduledJob scheduledJob = new UnitBookingScheduledJob(unit.Id, false);
                        System.schedule('Auto Release a booked tempo sales unit ['+twoDaysFromNow.getTime()+'-'+unit.Id+']', nextFireTime, scheduledJob);
                    }else if(bookingStage == 2){
                        //run a scheduler to auto release the unit after 2 days
                        Datetime twoDaysFromNow = datetime.now().addHours(Integer.valueOf(Label.Tempo_Booking_Step3_Waiting_in_Hours));
                        //Datetime twoDaysFromNow = datetime.now().addMinutes(2);
                        String nextFireTime = twoDaysFromNow.second() + ' ' + twoDaysFromNow.minute() + ' ' + twoDaysFromNow.hour() +
                            ' '+twoDaysFromNow.day() + ' ' +twoDaysFromNow.month() + ' ? ' + twoDaysFromNow.year();
                        UnitBookingScheduledJob scheduledJob = new UnitBookingScheduledJob(unit.Id, false);
                        System.schedule('Auto Release a booked tempo sales unit ['+twoDaysFromNow.getTime()+'-'+unit.Id+']', nextFireTime, scheduledJob);
                    }
                }  
                if(unit.Property_Status__c == 'Blocked' && (campaignType == 'Tempo' || campaignType == '') && unit.cm_Blocked_By__r.Role_Name__c == 'CCO'){
                    Datetime twoDaysFromNow = datetime.now().addHours(Integer.valueOf(Label.HOD_Blocking_Waiting_in_Hours));
                    String releaseTime = twoDaysFromNow.second() + ' ' + twoDaysFromNow.minute() + ' ' + twoDaysFromNow.hour() +
                        ' '+twoDaysFromNow.day() + ' ' +twoDaysFromNow.month() + ' ? ' + twoDaysFromNow.year();
                    UnitBookingScheduledJob releaseJob = new UnitBookingScheduledJob(unit.Id, true);
                    System.schedule('Auto Release a blocked tempo sales unit by CCO ['+twoDaysFromNow.getTime()+'-'+unit.Id+']', releaseTime, releaseJob);
                }
            }
        }
    }
}