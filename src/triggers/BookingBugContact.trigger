trigger BookingBugContact on booking__BBMember__c (after insert, after update) {
    List<booking__BBMember__c> members = Trigger.New;
    booking__Config__c cfg = booking.Util.getConfig();
    String objType = 'contact';

    Id contactRecordTypeId;
    List<Contact> contactsById = new List<Contact>();   // contacts that already exist, will only be updated
    Map<String, Contact> contactsMap = new Map<String, Contact>();   // used for eliminating duplicate contacts, by email
    List<Contact> contacts = new List<Contact>();       // contacts with no duplicates
    Contact ct;

    // gets the RecordTypeId for the Contact object, if specified in Config
    if (String.isNotBlank(cfg.booking__Contact_Record_Type__c)) {
        Map<String, Id> contactRecTypes = booking.Util.GetRecordTypeIdsByDeveloperName(Schema.Contact.SObjectType);
        contactRecordTypeId = contactRecTypes.get(cfg.booking__Contact_Record_Type__c);
    }

    for (booking__BBMember__c m : members) {
        ct = new Contact();
        ct.booking__BookingBug_Id__c = m.booking__BookingBug_Id__c;
        ct.FirstName = m.booking__First_Name__c;
        ct.LastName = m.booking__Last_Name__c;
        ct.MailingStreet = m.booking__Address1__c;
        ct.MailingCity = m.booking__Address3__c;
        ct.MailingState = m.booking__Address4__c;
        ct.MailingPostalCode = m.booking__Postcode__c;
        ct.MailingCountry = m.booking__Country__c;
        ct.Phone = m.booking__Phone__c;
        ct.MobilePhone = m.booking__Mobile_phone__c;
        ct.Email = m.booking__Email__c;
        ct.OwnerId = UserInfo.getUserId();

        if (String.isNotBlank(contactRecordTypeId)) {
            ct.RecordTypeId = contactRecordTypeId;
        }

        if (String.IsNotBlank(cfg.booking__Account__c)) {
            //accountid is the account entered at setup
            ct.AccountId = cfg.booking__Account__c;
        }

        String reference = m.booking__SF_reference__c;
        if (String.isNotBlank(reference) && reference.substring(0,3) == '003' && reference.length() == 18) {
            ct.Id = reference;
            contactsById.add(ct);
        } else {
            contactsMap.put(ct.email, ct);
        }
    }

    //System.debug('*** contact Map' + contactsMap);
    // will make sure the contacts which will be upserted are unique by email address
    try {
        if (contactsMap.size() > 0) {
            // returns duplicate contacts, which will be updated
            contacts = (List<Contact>) booking.CustomersProcess.CheckDupeEmails(contactsMap, objType);
        }
    } catch (QueryException e) {
        //if function returns nothing it will throw 'List has no rows for assignment...' - no need to stop execution
    }

    update contactsById;
    update contacts;
    upsert contactsMap.values() booking__BookingBug_Id__c;


    // will start a self-terminating Apex Scheduler which adds the question list
    // comment this part if no questions are configured [JSON format]
    /*Integer delay = 10; // adjustable. 10 seconds default.
    DateTime dt = DateTime.now().addSeconds(delay);
    String hour = String.valueOf(dt.hour()),
          min = String.valueOf(dt.minute()),
          sec = String.valueOf(dt.second()),
          day = String.valueOf(dt.day()),
          month = String.valueOf(dt.month()),
          year = String.valueOf(dt.year());

    String fireTime = sec + ' ' + min + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year;
    String jobName = 'BookingBug Question Contact';
    
    List<CronJobDetail> cj = [SELECT Name
                              FROM CronJobDetail
                              WHERE Name =: jobName];
    
    if (cj.size() == 0)
        System.schedule(jobName, fireTime, new booking.QuestionScheduler(members, new List<booking__BBBookings__c>(), cfg, objType, jobName));
	*/
    // end of question Scheduler
}