@isTest
private class AccountsSelectorTest {

    @testSetup
    private static void generateData() {
        DataGenerator dg = DataGenerator.getInstance();
        dg.createTestEnvironment();
    }

    @isTest static void testInterface() {
        Test.startTest();
            // given
            AccountsSelector accSelector = new AccountsSelector();
            // when
            List<Schema.SObjectField> fieldList = accSelector.getSObjectFieldList();
            Schema.SObjectType accType = accSelector.getSObjectType();
            Map<Id, Account> accIds = new Map<Id, Account>([SELECT Id FROM Account LIMIT 50000]);
            Account[] accs = accSelector.selectById(accIds.keySet());
        Test.stopTest();
        // then
        System.assert(!fieldList.isEmpty(), 'No fields provided to fflib interface.');
        System.assertEquals(accType, Account.SObjectType);
        System.assertEquals(accIds.size(), accs.size(), 'Query mismatch.');
    }

    @isTest static void testSelection() {
        // given
        Account[] ctrlAccount = [SELECT Id, Name FROM Account LIMIT 1];
        System.assert(!ctrlAccount.isEmpty(), 'Data Generation Error!');
        String lowerId;
        String lowerName;
        lowerId = String.valueOf(ctrlAccount[0].Id).toLowerCase();
        lowerName = String.valueOf(ctrlAccount[0].Name).toLowerCase();
        String ctrlResult = '{"attributes":'+
            '{"type":"account",'+
                '"url":"/services/data/v39.0/sobjects/account/' + lowerId + '"},'+
            '"Account ID":"' + lowerId + '",'+
            '"Account Name":"' + lowerName + '"}';
        Test.startTest();
            AccountsSelector accSelector = new AccountsSelector();
            // when
            String stringAccount = accSelector.getAccountFields(ctrlAccount[0].Id, 'Id, Name');
        Test.stopTest();
        // then
        System.assertEquals(stringAccount, ctrlResult, 'Unexpected query results.');
    }

}
