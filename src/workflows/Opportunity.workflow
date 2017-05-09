<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Mobile_Welcome</fullName>
        <ccEmails>digitalbank.deloitte@gmail.com</ccEmails>
        <description>Mobile Welcome</description>
        <protected>false</protected>
        <recipients>
            <field>SocialAccountContact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/MobileWelcome</template>
    </alerts>
    <alerts>
        <fullName>Mobile_Welcome_Educate_Me</fullName>
        <ccEmails>digitalbank.deloitte@gmail.com</ccEmails>
        <description>Mobile Welcome Educate Me</description>
        <protected>false</protected>
        <recipients>
            <field>SocialAccountContact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/MobileWelcomeEducateMe</template>
    </alerts>
    <rules>
        <fullName>Marloes Opportunity</fullName>
        <active>false</active>
        <formula>OwnerId = &apos;00546000000aF9d&apos;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>New Opportunity</fullName>
        <actions>
            <name>New_Opportunity</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <formula>OwnerId != null</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <tasks>
        <fullName>New_Opportunity</fullName>
        <assignedToType>owner</assignedToType>
        <description>Please call up to confim your metting</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Opportunity.CreatedDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Follow up on new opportunity!</subject>
    </tasks>
</Workflow>
