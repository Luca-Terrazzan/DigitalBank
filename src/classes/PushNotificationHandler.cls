public class PushNotificationHandler implements Queueable, Database.AllowsCallouts {
    private static final Boolean DEBUG = true;

    private Opportunity opp;
    private Contact socialContact;
    private String suffix = '';
    private String jobId;

    // customized parameters
    private String customText;
    private String customId;

    public PushNotificationHandler(Opportunity opp, Contact socialContact) {
        this.opp = opp;
        this.socialContact = socialContact;
    }
    public PushNotificationHandler(Opportunity opp, Contact socialContact, String suffix, String jobid) {
        this.opp = opp;
        this.socialContact = socialContact;
        this.suffix = suffix;
        this.jobId = jobid;
    }

    public void execute(QueueableContext context) {
        if (opp == null || socialContact == null) {
            return;
        }
        String deviceId = String.isNotBlank(socialContact.Device_Id__c) ?
            socialContact.Device_Id__c :
            'testId' + String.valueOf((Integer)(Math.random() * 1000));
        String notificationText = String.isNotBlank(customText) ? customText : opp.Name;
        String notificationId = String.isNotBlank(customId) ? customId : opp.Id + suffix;
        String payload = '[{"notification_Id": "' + notificationId + '", "device_Id": "' + deviceId +
            '", "notification_text": "' + notificationText + '"}]';
        HttpRequest req = new HttpRequest();
            req.setEndpoint('http://devesb.digitalbank.us:8101/notification-api/pushNotifications');
            req.setMethod('POST');
            req.setBody(payload);
            req.setHeader('api-cache-key', 'c672b8d1ef56ed28ab87c3622c5114069bdd3ad7b8f9737498d0c01ecef0967a');
            req.setHeader('api-country', 'us');
            req.setHeader('api-lang', 'en');
            req.setHeader('api-message-id', 'f47ac10b-58cc-4372-a567-0e02b2c3d479');
            req.setHeader('api-message-timestamp', String.valueOf(System.now()));
            req.setHeader('api-organisation', 'ddb');
            req.setHeader('api-related-id', 'f47ac10b-58cc-4372-a567-0e02b2c3d479');
            req.setHeader('api-transaction-id', 'f47ac10b-58cc-4372-a567-0e02b2c3d479');
            req.setHeader('api-transaction-timestamp', String.valueOf(System.now()));
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Cache-Control', 'no-cache');
        Http http = new Http();
        if (DEBUG) System.debug('DEBUG MODE -- push notification endpoint: ' + req);
        if (DEBUG) System.debug('DEBUG MODE -- push notification payload: ' + req.getBody());
        HTTPResponse res = http.send(req);
        if (res.getStatusCode() == 200) {
            opp.PushNotificationSent__c = true;
            update opp;
        }
        deleteCronJob();
    }

    public void customizeNotification(String notificationText, String notificationId) {
        this.customText = notificationText;
        this.customId = notificationId;
    }

    private void deleteCronJob() {
        if (String.isNotBlank(jobId)) {
            System.abortJob(jobId);
        }
    }
}
