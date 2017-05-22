global virtual class MarketingCloudHandler implements Social.InboundSocialPostHandler {

    final static Integer CONTENT_MAX_LENGTH = 32000;
    Boolean isNewCaseCreated = false;

    // Reopen case if it has not been closed for more than this number
    global virtual Integer getMaxNumberOfDaysClosedToReopenCase() {
        return 5;
    }

    // Create a case if one of these post tags are on the SocialPost, regardless of the skipCreateCase indicator.
    global virtual Set<String> getPostTagsThatCreateCase(){
        return new Set<String>();
    }

    global virtual String getDefaultAccountId() {
        return null;
    }

    global Social.InboundSocialPostResult handleInboundSocialPost(SocialPost post, SocialPersona persona, Map<String, Object> rawData) {
        Social.InboundSocialPostResult result = new Social.InboundSocialPostResult();
        result.setSuccess(true);
        matchPost(post);
        matchPersona(persona);

        if ((post.Content != null) && (post.Content.length() > CONTENT_MAX_LENGTH)) {
            post.Content = post.Content.abbreviate(CONTENT_MAX_LENGTH);
        }

        if (post.Id != null) {
            handleExistingPost(post, persona);
            return result;
        }

        setReplyTo(post, persona);
        buildPersona(persona);
        Case parentCase = buildParentCase(post, persona, rawData);
        setRelationshipsOnPost(post, persona, parentCase);
        setModeration(post, rawData);

        upsert post;

        if(isNewCaseCreated){
            updateCaseSource(post, parentCase);
        }

        // Create an opportunity and sends notification where needed
        setOpportunity(post, persona, rawData);

        return result;
    }

    private void setModeration(SocialPost post, Map<String, Object> rawData){
        //if we don't automatically create a case, we should flag the post as requiring moderator review.
        if(post.parentId == null && !isUnsentParent(rawData))
            post.reviewedStatus = 'Needed';
    }

    private void updateCaseSource(SocialPost post, Case parentCase){
        if(parentCase != null) {
            parentCase.SourceId = post.Id;
            //update as a new sobject to prevent undoing any changes done by insert triggers
            update new Case(Id = parentCase.Id, SourceId = parentCase.SourceId);
        }

    }

    private void handleExistingPost(SocialPost post, SocialPersona persona) {
        update post;
        if (persona.id != null)
            updatePersona(persona);
    }

    private void setReplyTo(SocialPost post, SocialPersona persona) {
        SocialPost replyTo = findReplyTo(post, persona);
        if(replyTo.id != null) {
            post.replyToId = replyTo.id;
            post.replyTo = replyTo;
        }
    }

    private SocialPersona buildPersona(SocialPersona persona) {
        if (persona.Id == null)
            createPersona(persona);
        else
            updatePersona(persona);

        return persona;
    }

    private void updatePersona(SocialPersona persona) {
        try{
            update persona;
        }catch(Exception e) {
            System.debug('Error updating social persona: ' + e.getMessage());
        }
    }

    private Case buildParentCase(SocialPost post, SocialPersona persona, Map<String, Object> rawData){
        if(!isUnsentParent(rawData)) {
            Case parentCase = findParentCase(post, persona);
            if (parentCase != null) {
                if (!parentCase.IsClosed) {
                    return parentCase;
                }
                else if (caseShouldBeReopened(parentCase)) {
                    reopenCase(parentCase);
                    return parentCase;
                }
            }
            if(shouldCreateCase(post, rawData)){
                isNewCaseCreated = true;
                return createCase(post, persona);
            }
        }

        return null;
    }

    private boolean caseShouldBeReopened(Case c){
        return c.id != null && c.isClosed && System.now() < c.closedDate.addDays(getMaxNumberOfDaysClosedToReopenCase());
    }

    private void setRelationshipsOnPost(SocialPost postToUpdate, SocialPersona persona, Case parentCase) {
        if (persona.Id != null) {
            postToUpdate.PersonaId = persona.Id;

            if(persona.ParentId.getSObjectType() != SocialPost.sObjectType) {
                postToUpdate.WhoId = persona.ParentId;
            }
        }
        if(parentCase != null) {
            postToUpdate.ParentId = parentCase.Id;
        }
    }

    private Case createCase(SocialPost post, SocialPersona persona) {
        Case newCase = new Case(subject = post.Name);
        if (persona != null && persona.ParentId != null) {
            if (persona.ParentId.getSObjectType() == Contact.sObjectType) {
                newCase.ContactId = persona.ParentId;
            } else if (persona.ParentId.getSObjectType() == Account.sObjectType) {
                newCase.AccountId = persona.ParentId;
            }
        }
        if (post != null && post.Provider != null) {
            newCase.Origin = post.Provider;
        }
        insert newCase;
        return newCase;
    }

    private Case findParentCase(SocialPost post, SocialPersona persona) {
        Case parentCase = null;
        if (post.ReplyTo != null && !isReplyingToAnotherCustomer(post, persona) && !isChat(post)) {
            parentCase = findParentCaseFromPostReply(post);
        }
        if (parentCase == null) {
            parentCase = findParentCaseFromPersona(post, persona);
        }
        return parentCase;
    }

    private boolean isReplyingToAnotherCustomer(SocialPost post, SocialPersona persona){
        return !post.ReplyTo.IsOutbound && post.ReplyTo.PersonaId != persona.Id;
    }

    private boolean isChat(SocialPost post){
        return post.messageType == 'Private' || post.messageType == 'Direct';
    }

    private Case findParentCaseFromPostReply(SocialPost post) {
        if (post.ReplyTo != null && String.isNotBlank(post.ReplyTo.ParentId)) {
            List<Case> cases = [SELECT Id, IsClosed, Status, ClosedDate FROM Case WHERE Id = :post.ReplyTo.ParentId LIMIT 1];
            if(!cases.isEmpty()) {
                return cases[0];
            }
        }
        return null;
    }

    private Case findParentCaseFromPersona(SocialPost post, SocialPersona persona) {
        SocialPost lastestInboundPostWithSamePersonaAndRecipient = findLatestInboundPostBasedOnPersonaAndRecipient(post, persona);
        if (lastestInboundPostWithSamePersonaAndRecipient != null) {
            List<Case> cases = [SELECT Id, IsClosed, Status, ClosedDate FROM Case WHERE id = :lastestInboundPostWithSamePersonaAndRecipient.parentId LIMIT 1];
            if(!cases.isEmpty()) {
                return cases[0];
            }
        }
        return null;
    }

    private void reopenCase(Case parentCase) {
        SObject[] status = [SELECT MasterLabel FROM CaseStatus WHERE IsClosed = false AND IsDefault = true];
        parentCase.Status = ((CaseStatus)status[0]).MasterLabel;
        update parentCase;
    }

    private void matchPost(SocialPost post) {
            if (post.Id != null) return;

        performR6PostIdCheck(post);

        if (post.Id == null){
            performExternalPostIdCheck(post);
        }
    }


    private void performR6PostIdCheck(SocialPost post){
        if(post.R6PostId == null) return;
        List<SocialPost> postList = [SELECT Id FROM SocialPost WHERE R6PostId = :post.R6PostId LIMIT 1];
        if (!postList.isEmpty()) {
            post.Id = postList[0].Id;
        }
    }


    private void performExternalPostIdCheck(SocialPost post) {
        if (post.provider == 'Facebook' && post.messageType == 'Private') return;
        if (post.provider == null || post.externalPostId == null) return;
        List<SocialPost> postList = [SELECT Id FROM SocialPost WHERE ExternalPostId = :post.ExternalPostId AND Provider = :post.provider LIMIT 1];
        if (!postList.isEmpty()) {
            post.Id = postList[0].Id;
        }
    }


    private SocialPost findReplyTo(SocialPost post, SocialPersona persona) {
        if(post.replyToId != null && post.replyTo == null)
            return findReplyToBasedOnReplyToId(post);
        if(post.responseContextExternalId != null){
            if((post.provider == 'Facebook' && post.messageType == 'Private') || (post.provider == 'Twitter' && post.messageType == 'Direct')){
                SocialPost replyTo = findReplyToBasedOnResponseContextExternalPostIdAndProvider(post);
                if(replyTo.id != null)
                    return replyTo;
            }
            return findReplyToBasedOnExternalPostIdAndProvider(post);
        }
        return new SocialPost();
    }

    private SocialPost findReplyToBasedOnReplyToId(SocialPost post){
        List<SocialPost> posts = [SELECT Id, ParentId, IsOutbound, PersonaId FROM SocialPost WHERE id = :post.replyToId LIMIT 1];
        if(posts.isEmpty())
            return new SocialPost();
        return posts[0];
    }

    private SocialPost findReplyToBasedOnExternalPostIdAndProvider(SocialPost post){
        List<SocialPost> posts = [SELECT Id, ParentId, IsOutbound, PersonaId FROM SocialPost WHERE Provider = :post.provider AND ExternalPostId = :post.responseContextExternalId LIMIT 1];
        if(posts.isEmpty())
            return new SocialPost();
        return posts[0];
    }

    private SocialPost findReplyToBasedOnResponseContextExternalPostIdAndProvider(SocialPost post){
        List<SocialPost> posts = [SELECT Id, ParentId, IsOutbound, PersonaId FROM SocialPost WHERE Provider = :post.provider AND responseContextExternalId = :post.responseContextExternalId ORDER BY posted DESC NULLS LAST LIMIT 1];
        if(posts.isEmpty())
            return new SocialPost();
        return posts[0];
    }

    private SocialPost findLatestInboundPostBasedOnPersonaAndRecipient(SocialPost post, SocialPersona persona) {
        if (persona != null && String.isNotBlank(persona.Id) && post != null && String.isNotBlank(post.Recipient)) {
            List<SocialPost> posts = [SELECT Id, ParentId FROM SocialPost WHERE Provider = :post.provider AND Recipient = :post.Recipient AND PersonaId = :persona.id AND IsOutbound = false ORDER BY CreatedDate DESC LIMIT 1];
            if (!posts.isEmpty()) {
                return posts[0];
            }
        }
        return null;
    }

    private void matchPersona(SocialPersona persona) {
        if (persona != null) {
            List<SocialPersona> personaList = new List<SocialPersona>();
            if(persona.Provider != 'Other' && String.isNotBlank(persona.ExternalId)) {
                personaList = [SELECT Id, ParentId FROM SocialPersona WHERE
                    Provider = :persona.Provider AND
                    ExternalId = :persona.ExternalId LIMIT 1];
            } else if(persona.Provider == 'Other' && String.isNotBlank(persona.ExternalId) && String.isNotBlank(persona.MediaProvider)) {
                personaList = [SELECT Id, ParentId FROM SocialPersona WHERE
                    MediaProvider = :persona.MediaProvider AND
                    ExternalId = :persona.ExternalId LIMIT 1];
            } else if(persona.Provider == 'Other' && String.isNotBlank(persona.Name) && String.isNotBlank(persona.MediaProvider)) {
                personaList = [SELECT Id, ParentId FROM SocialPersona WHERE
                    MediaProvider = :persona.MediaProvider AND
                    Name = :persona.Name LIMIT 1];
            }

            if (!personaList.isEmpty()) {
                persona.Id = personaList[0].Id;
                persona.ParentId = personaList[0].ParentId;
            }
        }
    }

    private void createPersona(SocialPersona persona) {
        if (persona == null || String.isNotBlank(persona.Id) || !isThereEnoughInformationToCreatePersona(persona))
            return;

        SObject parent = createPersonaParent(persona);
        persona.ParentId = parent.Id;
        insert persona;
    }

    private boolean isThereEnoughInformationToCreatePersona(SocialPersona persona) {
        return String.isNotBlank(persona.Name) &&
               String.isNotBlank(persona.Provider) &&
               String.isNotBlank(persona.MediaProvider);
    }

    private boolean shouldCreateCase(SocialPost post, Map<String, Object> rawData) {
        return !isUnsentParent(rawData) && (!hasSkipCreateCaseIndicator(rawData) || hasPostTagsThatCreateCase(post));
    }

    private boolean isUnsentParent(Map<String, Object> rawData) {
        Object unsentParent = rawData.get('unsentParent');
        return unsentParent != null && 'true'.equalsIgnoreCase(String.valueOf(unsentParent));
    }

    private boolean hasSkipCreateCaseIndicator(Map<String, Object> rawData) {
        Object skipCreateCase = rawData.get('skipCreateCase');
        return skipCreateCase != null && 'true'.equalsIgnoreCase(String.valueOf(skipCreateCase));
    }

    private boolean hasPostTagsThatCreateCase(SocialPost post){
        Set<String> postTags = getPostTags(post);
        postTags.retainAll(getPostTagsThatCreateCase());
        return !postTags.isEmpty();
    }

    private Set<String> getPostTags(SocialPost post){
        Set<String> postTags = new Set<String>();
        if(post.postTags != null)
            postTags.addAll(post.postTags.split(',', 0));
        return postTags;
    }

    global String getPersonaFirstName(SocialPersona persona) {
        String name = getPersonaName(persona);
        String firstName = '';
        if (name.contains(' ')) {
            firstName = name.substringBeforeLast(' ');
        }
        firstName = firstName.abbreviate(40);
        return firstName;
    }

    global String getPersonaLastName(SocialPersona persona) {
        String name = getPersonaName(persona);
        String lastName = name;
        if (name.contains(' ')) {
            lastName = name.substringAfterLast(' ');
        }
        lastName = lastName.abbreviate(80);
        return lastName;
    }

    private String getPersonaName(SocialPersona persona) {
        String name = persona.Name.trim();
        if (String.isNotBlank(persona.RealName)) {
            name = persona.RealName.trim();
        }
        return name;
    }

    global virtual SObject createPersonaParent(SocialPersona persona) {

        Contact[] existingParent = [SELECT Id FROM Contact WHERE Name =: persona.Name];
        if (existingParent.size() == 1) {
            System.debug('Existing contact found: ' + existingParent[0]);
            return existingParent[0];
        }

        String firstName = getPersonaFirstName(persona);
        String lastName = getPersonaLastName(persona);

        Contact contact = new Contact(LastName = lastName, FirstName = firstName);
        String defaultAccountId = getDefaultAccountId();
        if (defaultAccountId != null)
            contact.AccountId = defaultAccountId;
        insert contact;
        return contact;
    }

    /**
     * Sets the opportunity based on the social action, persona and post. Then sends a push notification immediately
     * and another one after two minutes
     * @param      post     The post
     * @param      persona  The persona
     * @param      rawData  The raw data
     * @return     Opportunity
     */
    private Opportunity setOpportunity(SocialPost post, SocialPersona persona, Map<String, Object> rawData) {
        if (shouldCreateOpportunity(rawData)) {
            Contact socialContact = [SELECT AccountId, Device_Id__c FROM Contact WHERE Id =: persona.parentId];
            Opportunity opp = new Opportunity(
                SocialAccountContact__c = socialContact.Id,
                AccountId = socialContact.AccountId,
                Name = 'Social Action for ' + persona.Name,
                Category__c = 'Retail',
                StageName = 'Prospecting',
                CloseDate = System.today() + 7,
                Description = 'Opportunity source: ' + rawData.get('postUrl')
            );
            insert opp;
            Integer notificationType = getNotificationType(rawData);
            sendPushNotification(opp, socialContact, notificationType);
            if (DGTB_Settings__c.getValues('DGTB_Settings__c').DGTB_DelayedNotification__c) {
                String schedId = System.schedule(ReminderHandler.getJobName(), ReminderHandler.getTimeOut(), new ReminderHandler(opp, socialContact, notificationType));
                System.debug('scheduled with id: ' + schedId);
            }
            return opp;
        } else {
            return null;
        }
    }

    /**
     * Check for raw data content in order to determine the creation of the opportunity or not
     * TODO
     */
    private Boolean shouldCreateOpportunity(Map<String, Object> rawData) {
        if (rawData.get('postPriority') == 'High') {
            return true;
        } else {
            return true; // always create an opportunity
        }
    }
    /**
     * Gets the notification type based on the raw data priority attribute:
     * 0 -> DOCUSIGN
     * 1 -> MORTGAGE
     * 2 -> BOOKING
     * @param      rawData  The raw data
     * @return     The notification type Integer.
     */
    private Integer getNotificationType(Map<String, Object> rawData) {
        if (rawData.get('postPriority') == 'High') {
            return 0;
        } else if (rawData.get('postPriority') == 'Medium') {
            return 1;
        } else if (rawData.get('postPriority') == 'Low'){
            return 2;
        } else {
            return 0;
        }
    }

    /**
     * Sends a push notification.
     * @param      opp               The opportunity
     * @param      socialContact     The social contact
     * @param      notificationType  The notification type code
     */
    private void sendPushNotification(Opportunity opp, Contact socialContact, Integer notificationType) {
        if (opp != null && opp.Id != null && String.isNotBlank(opp.Name)) {
            System.enqueueJob(new PushNotificationHandler(opp, socialContact, notificationType));
        } else {
            return;
        }
    }

    /**
     * Stub functions to just insert some demo stuff for the indian team demo. Might be removed when needed.
     */
     public static void demoPushNotification() {
         demoPushNotification(null, null, 0);
     }
    public static void demoPushNotification(String notificationText, String notificationId, Integer notificationType) {
        Contact socialContact = [SELECT AccountId, Device_Id__c, Name FROM Contact WHERE Id = '0034600000f31YY'];
        Opportunity opp = new Opportunity(
            SocialAccountContact__c = socialContact.Id,
            AccountId = socialContact.AccountId,
            Name = 'DEMO Social Action for ' + socialContact.Name,
            Category__c = 'Retail',
            StageName = 'Prospecting',
            CloseDate = System.today() + 7,
            Description = 'Opportunity source: ' + 'DEMO TEST'
        );
        insert opp;
        PushNotificationHandler pnh = new PushNotificationHandler(opp, socialContact, notificationType);
        pnh.customizeNotification(notificationText, notificationId);
        System.enqueueJob(pnh);
        ReminderHandler rh = new ReminderHandler(opp, socialContact, notificationType);
        rh.customizeNotification(notificationText, notificationId);
        if (DGTB_Settings__c.getValues('DGTB_Settings__c').DGTB_DelayedNotification__c) {
            String schedId = System.schedule(ReminderHandler.getJobName(), ReminderHandler.getTimeOut(), rh);
        }
    }
}