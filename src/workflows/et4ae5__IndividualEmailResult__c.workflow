<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>et4ae5__TrackingAsOf</fullName>
        <field>et4ae5__Tracking_As_Of__c</field>
        <formula>LastModifiedDate</formula>
        <name>TrackingAsOf</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>true</protected>
    </fieldUpdates>
    <rules>
        <fullName>et4ae5__TrackingAsOfIER</fullName>
        <actions>
            <name>et4ae5__TrackingAsOf</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(et4ae5__DateBounced__c) ||  ISCHANGED(et4ae5__DateOpened__c) ||  ISCHANGED(et4ae5__DateSent__c) ||  ISCHANGED(et4ae5__DateUnsubscribed__c) ||  ISCHANGED(et4ae5__NumberOfTotalClicks__c) ||  ISCHANGED(et4ae5__NumberOfUniqueClicks__c) ||  ISCHANGED(et4ae5__Opened__c) ||  ISCHANGED(et4ae5__SoftBounce__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
