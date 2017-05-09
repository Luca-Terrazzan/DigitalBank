global class ReminderHandler implements Schedulable, Database.AllowsCallouts {
    private static final String jobName = 'PushNotificationReminder';
    private static Integer jobSuffix = 0;

    private Opportunity opp;
    private Contact socialContact;

    public ReminderHandler(Opportunity opp, Contact socialContact) {
        this.opp = opp;
        this.socialContact = socialContact;
    }

    global void execute(SchedulableContext sc) {
        System.enqueueJob(new PushNotificationHandler(opp, socialContact, '_2', sc.getTriggerId()));
    }

    public static String getTimeOut() {
        String[] temp = new String[]{'*', '*', '*', '*', '*', '*', '*'};
        DateTime now = System.now();
        DateTime timeout = now.addMinutes(2);
        temp[0] = String.valueOf(timeout.second());
        temp[1] = String.valueOf(timeout.minute());
        temp[2] = String.valueOf(timeout.hour());
        temp[3] = String.valueOf(timeout.day());
        temp[4] = String.valueOf(timeout.month());
        temp[5] = '?';
        temp[6] = String.valueOf(timeout.year());
        System.debug('scheduled time: ' + String.join(temp, ' '));
        return String.join(temp, ' ');
    }

    public static String getJobName() {
        return jobName + '_' + String.valueOf(jobSuffix++);
    }
}