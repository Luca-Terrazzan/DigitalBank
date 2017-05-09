trigger BookingBugOpportunity on booking__BBBookings__c (after insert) {
    List<booking__BBBookings__c> bookings = Trigger.New;
    booking__Config__c cfg = booking.Util.getConfig();

    Opportunity o;
    List<Opportunity> opps = new List<Opportunity>();
    Id oppRecType;

    // gets the RecordTypeId for the Opportunity object, if specified in Config
    if (String.isNotBlank(cfg.booking__Opprtunity_Record_Type__c)) {
        Map<String, Id> oppRecTypes = booking.Util.GetRecordTypeIdsByDeveloperName(Schema.Account.SObjectType);
        oppRecType = oppRecTypes.get(cfg.booking__Opprtunity_Record_Type__c);
    }

    Set<Integer> bbIds = new Set<Integer>();
    for (booking__BBBookings__c b : bookings)
        bbIds.add(Integer.valueof(b.booking__Member_id__c));
    Map<Integer, Id> accountIds = booking.BookingsProcess.getBBAccounts(bbIds);
    Map<Integer, Id> contactIds = booking.BookingsProcess.getBBContacts(bbIds);
    system.debug('***opp contact and acc ids:' + accountIds + ' c:' + contactids);

    // get owner Ids for provided bookings
    Map<Integer, Id> ownerIds = booking.BookingsProcess.getBookingOwnerIdMap(bookings);

    // creating a new opportunity based on booking data and adding it to a list
    // some fields need to be completed with proper data - StageName, CloseDate, Probability etc
    for (booking__BBBookings__c b : bookings) {
        o = new Opportunity();
        o.Name = b.Name;
        o.OwnerId = ownerIds.get(Integer.valueof(b.booking__BookingBug_Id__c));
        o.booking__BookingBug_Id__c = b.booking__BookingBug_Id__c;
        o.StageName = 'New Opportunity!';
        system.debug('*** raw data ' + b.booking__Just_date__c);
        //system.debug('*** function ' + booking.Util.stringToDate(b.booking__Just_date__c).date());
        o.CloseDate = booking.Util.stringToDate(b.booking__Just_date__c + ' 00:00:00').date();
        o.Probability = 55;
        o.Category__c = 'Commercial';
        o.booking__Long_id__c = b.booking__Long_id__c;

        if (String.isNotBlank(oppRecType)) {
            o.RecordTypeId = oppRecType;
        }

        if (cfg.booking__Accounts_Integration__c) {
            o.AccountId = accountIds.get(integer.valueof(b.booking__Member_id__c));
        } else if (String.isNotBlank(cfg.booking__Account__c)) {
            o.AccountId = cfg.booking__Account__c;
        }

        opps.add(o);
    }

    // adds new opportunities or updates existing ones
    upsert opps booking__BookingBug_Id__c;


    // will start a self-terminating Apex Scheduler which adds the question list
    // comment this part if no questions are configured [JSON format]
    /*
    String objType = 'opportunity';
    Integer delay = 10; // adjustable. 10 seconds default.
    DateTime dt = DateTime.now().addSeconds(delay);
    String hour = String.valueOf(dt.hour()),
          min = String.valueOf(dt.minute()),
          sec = String.valueOf(dt.second()),
          day = String.valueOf(dt.day()),
          month = String.valueOf(dt.month()),
          year = String.valueOf(dt.year());

    String fireTime = sec + ' ' + min + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year;
    String jobName = 'BookingBug Question Opportunity';
    
    List<CronJobDetail> cj = [SELECT Name
                              FROM CronJobDetail
                              WHERE Name =: jobName];
    if (cj.size() == 0)
        System.schedule(jobName, fireTime, new booking.QuestionScheduler(new List<booking__BBMember__c>(), bookings, cfg, objType, jobName));
    // end of question Scheduler
    */

}