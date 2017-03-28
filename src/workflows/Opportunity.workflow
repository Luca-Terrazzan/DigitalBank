<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>New Opportunity</fullName>
        <actions>
            <name>New_Opportunity</name>
            <type>Task</type>
        </actions>
        <active>true</active>
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
