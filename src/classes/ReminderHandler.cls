global class ReminderHandler implements Schedulable, Database.AllowsCallouts {
    private static final String JOB_NAME = 'PushNotificationReminder';
    private static Integer jobSuffix = 0;

    private Opportunity opp;
    private Contact socialContact;
    private Integer notificationType;

    private String customText;
    private String customId;

    public ReminderHandler(Opportunity opp, Contact socialContact, Integer notificationType) {
        this.opp = opp;
        this.socialContact = socialContact;
        this.notificationType = notificationType;
    }

    global void execute(SchedulableContext sc) {
        PushNotificationHandler pnh = new PushNotificationHandler(opp, socialContact, notificationType, '_2', sc.getTriggerId());
        pnh.customizeNotification(customText, customId);
        System.enqueueJob(pnh);
    }

    public static String getTimeOut() {
        String[] temp    = new String[]{'*', '*', '*', '*', '*', '*', '*'};
        DateTime now     = System.now();
        DateTime timeout = now.addMinutes(2);
        temp[0] = String.valueOf(timeout.second());
        temp[1] = String.valueOf(timeout.minute());
        temp[2] = String.valueOf(timeout.hour());
        temp[3] = String.valueOf(timeout.day());
        temp[4] = String.valueOf(timeout.month());
        temp[5] = '?';
        temp[6] = String.valueOf(timeout.year());
        return String.join(temp, ' ');
    }

    public static String getJobName() {
        return JOB_NAME + '_' + String.valueOf(jobSuffix++);
    }

    public void customizeNotification(String notificationText, String notificationId) {
        this.customText = notificationText;
        this.customId   = notificationId;
    }
}
