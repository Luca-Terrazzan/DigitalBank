<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>Welcome For Mortgages</fullName>
        <active>false</active>
        <criteriaItems>
            <field>FinServ__FinancialAccount__c.FinServ__FinancialAccountType__c</field>
            <operation>contains</operation>
            <value>Mortgage: 10 years,Mortgage: 15 years,Mortgage: 30 years</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
