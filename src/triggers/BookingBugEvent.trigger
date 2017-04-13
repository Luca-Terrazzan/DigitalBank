trigger BookingBugEvent on booking__BBBookings__c (after insert, after update) {
    List<booking__BBBookings__c> bookings = Trigger.new;
    booking__Config__c cfg = booking.Util.getConfig();
    String objType = 'event';

    Id BBEventRecordTypeId, BBAppointmentRecordTypeId;  //record types
    List<Event> events = new List<Event>();
    Event ev;

    // gets the RecordTypeId for the Event object, if specified in Config
    if (String.isNotBlank(cfg.booking__Appointment_Custom_type__c) && String.isNotBlank(cfg.booking__Event_Custom_Type__c)) {
        BBEventRecordTypeId = booking.Util.GetRecordTypeIdsByDeveloperName(Schema.Event.SObjectType).get(cfg.booking__Event_Custom_Type__c);
        BBAppointmentRecordTypeId = booking.Util.GetRecordTypeIdsByDeveloperName(Schema.Event.SObjectType).get(cfg.booking__Appointment_Custom_type__c);
    }

    // provides event-contact, event-account and event-branch mappings
    Set<Integer> branchIds = new Set<Integer>();
    Set<Integer> customerIds = new Set<Integer>();
    for (booking__BBBookings__c b : bookings) {
        customerIds.add(Integer.valueOf(b.booking__Member_id__c));
        branchIds.add(Integer.valueOf(b.booking__Company_id__c));
    }
    Map<Integer, Id> branchIdsMap = booking.BookingsProcess.getBBBranches(branchIds);

    // this is just a trivial demo case
    // in a real world implementation we would know the integration type
    Map<Integer, Id> bbContacts = booking.BookingsProcess.getBBContacts(customerIds);
    Map<Integer, Id> bbAccounts = booking.BookingsProcess.getBBAccounts(customerIds);

    // get owner Ids for provided bookings
    Map<Integer, Id> ownerIds = booking.BookingsProcess.getBookingOwnerIdMap(bookings);

    for (booking__BBBookings__c b: bookings) {
        ev = new Event();
        ev.Subject = b.Name;
        ev.Description = b.Name;
        ev.ActivityDateTime = booking.Util.stringToDate(b.booking__Just_date__c + ' ' + b.booking__Just_time__c + ':00');
        ev.booking__BookingBug_Id__c = Integer.valueOf(b.booking__BookingBug_Id__c);
        ev.DurationInMinutes = Integer.valueOf(b.booking__Duration__c);
        ev.booking__Updated_Date_Time__c = b.LastModifiedDate;
        ev.booking__Created_Date_Time__c = booking.Util.stringToDate(b.booking__Created_at__c);
        ev.booking__Booking_Date_Time__c = booking.Util.stringToDate(b.booking__Just_date__c + ' ' + b.booking__Just_time__c + ':00');
        ev.OwnerId = ownerIds.get(Integer.valueof(b.booking__BookingBug_Id__c));
        ev.booking__Bookingbug_Purchase_Id__c = Integer.valueOf(b.booking__Purchase_ID__c);
        ev.booking__BookingBug_Branch_Id__c = branchIdsMap.get(Integer.valueOf(b.booking__Company_id__c));
        ev.booking__BookingBug_Session_Id__c = b.booking__Session_ID__c == null ? 0 : integer.valueOf(b.booking__Session_ID__c);    // if sessionId is null, this is an appointment
        ev.booking__Long_id__c = b.booking__long_id__c;

        if (String.isNotBlank(BBEventRecordTypeId) && b.booking__Session_ID__c != 0) {
            ev.RecordTypeId = BBEventRecordTypeId;
        }
        else if (String.isNotBlank(BBAppointmentRecordTypeId)) {
            ev.RecordTypeId = BBAppointmentRecordTypeId;
        }

        ev.WhoId = bbContacts.get(integer.ValueOf(b.booking__Member_id__c));
        ev.WhatId = bbAccounts.get(integer.valueOf(b.booking__Member_id__c));

        events.add(ev);
    }

    upsert events booking__BookingBug_Id__c;

    // will start a self-terminating Apex Scheduler which adds the question list
    // comment this part if no questions are configured [JSON format]
    Integer delay = 10; // adjustable. 10 seconds default.
    DateTime dt = DateTime.now().addSeconds(delay);
    String hour = String.valueOf(dt.hour()),
          min = String.valueOf(dt.minute()),
          sec = String.valueOf(dt.second()),
          day = String.valueOf(dt.day()),
          month = String.valueOf(dt.month()),
          year = String.valueOf(dt.year());

    String fireTime = sec + ' ' + min + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year;
    String jobName = 'BookingBug Question Event';
    
    
    //List<CronTrigger> ct = [SELECT CronJobDetail.Name FROM CronTrigger];
        
        /*[SELECT NextFireTime
                      FROM CronTrigger
                      WHERE NextFireTime > :DateTime.Now()];*/
    
    //System.debug('**** cronTrigger: ' + ct);
    
    List<CronJobDetail> cj = [SELECT Name
                              FROM CronJobDetail
                              WHERE Name =: jobName];
    //System.debug('**** cronJob Event: ' + cj);
    
    if (cj.size() == 0)
        System.schedule(jobName, fireTime, new booking.QuestionScheduler(new List<booking__BBMember__c>(), bookings, cfg, objType, jobName));
    // end of question Scheduler
}