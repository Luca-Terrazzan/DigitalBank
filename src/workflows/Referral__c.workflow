<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>New_Referral_email</fullName>
        <description>New Referral email</description>
        <protected>false</protected>
        <recipients>
            <field>User_Receiving_Referral__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Referral_New_assignment_notification_SAMPLE</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Record_Type_to_Closed_Retail</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Closed_Retail</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Record Type to Closed Retail</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>New Referral Assignment Email Notification</fullName>
        <actions>
            <name>New_Referral_email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Workflow for email notification to referral owner on new referral assignment</description>
        <formula>ISCHANGED( User_Receiving_Referral__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Retail Record to Closed Retail Record</fullName>
        <actions>
            <name>Update_Record_Type_to_Closed_Retail</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND 3</booleanFilter>
        <criteriaItems>
            <field>Referral__c.Referral_Status__c</field>
            <operation>equals</operation>
            <value>Create Opportunity</value>
        </criteriaItems>
        <criteriaItems>
            <field>Referral__c.Referral_Status__c</field>
            <operation>equals</operation>
            <value>No Opportunity</value>
        </criteriaItems>
        <criteriaItems>
            <field>Referral__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Retail</value>
        </criteriaItems>
        <description>When referral status is updated to &quot;Opportunity Create&quot; or &quot;No Opportunity&quot;, update the record type to Closed Retail</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
