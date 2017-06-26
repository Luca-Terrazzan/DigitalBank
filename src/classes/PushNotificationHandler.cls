public class PushNotificationHandler implements Queueable, Database.AllowsCallouts {
    private static final Boolean DEBUG_MODE = false;
    private static final String[] DEFAULT_TEXT =
        new String[]{'New Product Offer: Travel Credit Card', 'Digital Bank: Are you interested in buying a new home?', 'Appoitment request'};
    private static final String[] NOTIFICATION_TYPES = new String[]{'DOCUSIGN', 'MORTGAGE', 'BOOKING'};

    private Opportunity opp;
    private Contact socialContact;
    private String suffix = '';
    private String jobId;
    private Integer notificationType = 0;

    // customized parameters
    private String customText;
    private String customId;

    public PushNotificationHandler(Opportunity opp, Contact socialContact, Integer notificationType) {
        this.opp = opp;
        this.socialContact = socialContact;
        this.notificationType = notificationType;
    }
    public PushNotificationHandler(Opportunity opp, Contact socialContact, Integer notificationType, String suffix, String jobid) {
        this.opp = opp;
        this.socialContact = socialContact;
        this.suffix = suffix;
        this.jobId = jobid;
        this.notificationType = notificationType != null ? notificationType : 0;
    }

    public void execute(QueueableContext context) {
        if (opp == null || socialContact == null) {
            return;
        }
        String deviceId = String.isNotBlank(socialContact.Device_Id__c) ?
            socialContact.Device_Id__c :
            '790f24f79512cc137a273c87af8e7b8a4275681dbbb7c89acda51936a4cf8028';
        String notificationText = String.isNotBlank(customText) ? customText : DEFAULT_TEXT[notificationType];
        String notificationId = String.isNotBlank(customId) ? customId : opp.Id + suffix;
        String payload = '[{"notification_Id": "' + notificationId + '", "device_Id": "' + deviceId +
            '", "notification_text": "' + notificationText +
            '", "notificationType": "' + NOTIFICATION_TYPES[notificationType] + '"}]';
        HttpRequest req = new HttpRequest();
            req.setEndpoint('http://notify.digitalbank.us/notification-api/pushNotifications');
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
        if (DEBUG_MODE) System.debug('DEBUG MODE -- push notification endpoint: ' + req);
        if (DEBUG_MODE) System.debug('DEBUG MODE -- push notification payload: ' + req.getBody());
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