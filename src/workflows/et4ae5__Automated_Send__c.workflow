<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>et4ae5__PopulateTSBackupWorkflow</fullName>
        <field>et4ae5__BackupWorkflow__c</field>
        <formula>now()+(1/288)</formula>
        <name>PopulateTSBackupWorkflow</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>et4ae5__UnpopulateTSBackupWokflow</fullName>
        <field>et4ae5__BackupWorkflow__c</field>
        <name>UnpopulateTSBackupWokflow</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>et4ae5__PopulateTrigSendBackupWorkflow</fullName>
        <actions>
            <name>et4ae5__PopulateTSBackupWorkflow</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>et4ae5__hasDelayedSends__c &amp;&amp; ISBLANK( et4ae5__BackupWorkflow__c ) &amp;&amp; et4ae5__Active__c</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
