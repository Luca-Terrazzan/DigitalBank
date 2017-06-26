@isTest
private class FinancialAccountRolesSelectorTest {

    @testSetup
    private static void generateData() {
        DataGenerator dg = DataGenerator.getInstance();
        dg.createTestEnvironment();
    }

    @isTest
    private static void testInterface() {
        Test.startTest();
            // given
            FinancialAccountRolesSelector fars = new FinancialAccountRolesSelector();
            // when
            List<Schema.SObjectField> fieldList = fars.getSObjectFieldList();
            Schema.SObjectType accType = fars.getSObjectType();
            Map<Id, FinServ__FinancialAccountRole__c> accIds = new Map<Id, FinServ__FinancialAccountRole__c>(
                [SELECT Id FROM FinServ__FinancialAccountRole__c LIMIT 50000]
            );
            FinServ__FinancialAccountRole__c[] accs = fars.selectById(accIds.keySet());
        Test.stopTest();
        // then
        System.assert(!fieldList.isEmpty(), 'No fields provided to fflib interface.');
        System.assertEquals(accType, FinServ__FinancialAccountRole__c.SObjectType);
        System.assertEquals(accIds.size(), accs.size(), 'Query mismatch.');
    }

    @isTest
    private static void testSelection() {
        // given
        FinServ__FinancialAccountRole__c[] ctrlFinAcc = [SELECT Id, Name
            FROM FinServ__FinancialAccountRole__c
            WHERE FinServ__FinancialAccount__r.Category__c = 'Retail'
            LIMIT 50000];
        Map<Id, Account> ctrlAccount = new Map<Id, Account>([SELECT Id FROM Account LIMIT 50000]);
        System.assert(!ctrlFinAcc.isEmpty() && !ctrlAccount.isEmpty(), 'Data configuration error.');
        Test.startTest();
            FinancialAccountRolesSelector fars = new FinancialAccountRolesSelector();
            // when
            FinServ__FinancialAccountRole__c[] roles = fars.selectByAccount(ctrlAccount.keySet());
        Test.stopTest();
        // then
        System.assertEquals(roles.size(), ctrlFinAcc.size(), 'Query Mismatch.');
    }

    @isTest
    private static void testDefaultRecordType() {
        // given
        Id ctrlId = [SELECT Id
            FROM RecordType
            WHERE SObjectType = 'FinServ__FinancialAccountRole__c' AND DeveloperName = 'AccountRole'].Id;
        Test.startTest();
            // when
            Id rtId = FinancialAccountRolesSelector.getDefaultRecordType();
        Test.stopTest();
        // then
        System.assertEquals(ctrlId, rtId, 'Query Mismatch.');
    }
}