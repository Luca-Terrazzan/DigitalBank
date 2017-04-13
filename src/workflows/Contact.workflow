<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Branch</fullName>
        <field>Branch__c</field>
        <formula>TEXT(Account.Branch__c)</formula>
        <name>Update Branch</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Created Individual</fullName>
        <actions>
            <name>Update_Branch</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>$RecordType.Name = &quot;Individual&quot;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
