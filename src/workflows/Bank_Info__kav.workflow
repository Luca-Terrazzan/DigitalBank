<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>send_mail</fullName>
        <description>send mail</description>
        <protected>false</protected>
        <recipients>
            <recipient>CEO</recipient>
            <type>roleSubordinates</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/New_article</template>
    </alerts>
    <rules>
        <fullName>AutoMail to customer community</fullName>
        <actions>
            <name>send_mail</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
