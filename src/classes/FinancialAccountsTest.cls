@isTest
private class FinancialAccountsTest {
    /**
     * Rollup Test
     */
    @isTest
    static void testRollupInsert() {
        TestUtils.insertIndividuals(3);
        Test.startTest();
            TestUtils.insertFinancialAccounts(false);
        Test.stopTest();
        Decimal balance = (Decimal) [
            SELECT SUM(FinServ__Balance__c) balance, Finserv__PrimaryOwner__r.Name name, Category__c category
            FROM FinServ__FinancialAccount__c
            WHERE Category__c = 'Retail' AND Finserv__PrimaryOwner__r.Name = 'testAccount0'
            GROUP BY Finserv__PrimaryOwner__r.Name, Category__c
        ][0].get('balance');
        Account acc = [SELECT RetailBalance__c FROM Account WHERE Name = 'testAccount0'];
        // Rounding necessary due to differences between SOQL float result and actual field decimal digits (only two)
        System.assertEquals(Math.round(balance), Math.round(acc.RetailBalance__c));
    }

    @isTest
    static void testRollUpUpdate() {
        TestUtils.insertIndividuals(3);
        TestUtils.insertFinancialAccounts(false);
        FinServ__FinancialAccount__c fa;
        try{
            fa = [SELECT FinServ__Balance__c FROM FinServ__FinancialAccount__c
                WHERE Category__c = 'Retail' LIMIT 1 FOR UPDATE];
        } catch (QueryException qe) {
            System.assert(false, 'Test data invalid: ' + qe.getMessage());
        }
        Test.startTest();
            fa.FinServ__Balance__c += 100.15;
            update fa;
        Test.stopTest();
        try{
            Decimal balance = (Decimal) [
                SELECT SUM(FinServ__Balance__c) balance, Finserv__PrimaryOwner__r.Name name, Category__c category
                FROM FinServ__FinancialAccount__c
                WHERE Category__c = 'Retail' AND Finserv__PrimaryOwner__r.Name = 'testAccount0'
                GROUP BY Finserv__PrimaryOwner__r.Name, Category__c
            ][0].get('balance');
            Account acc = [SELECT RetailBalance__c FROM Account WHERE Name = 'testAccount0'];
            // Rounding necessary due to differences between SOQL float result and actual field decimal digits (only two)
            System.assertEquals(Math.round(balance), Math.round(acc.RetailBalance__c));
        } catch (QueryException qe) {
            System.assert(false, 'Test data invalid: ' + qe.getMessage());
        }
    }

    @isTest
    static void testRollUpDelete()
    {
        TestUtils.insertIndividuals(3);
        TestUtils.insertFinancialAccounts(false);
        FinServ__FinancialAccount__c fa;
        try{
            fa = [SELECT Name, FinServ__Balance__c, Finserv__PrimaryOwner__c
                FROM FinServ__FinancialAccount__c
                WHERE Category__c = 'Retail' LIMIT 1];
        } catch (QueryException qe) {
            System.assert(false, 'Test data invalid: ' + qe.getMessage());
        }
        Account acc = [SELECT RetailBalance__c FROM Account WHERE Id =: fa.Finserv__PrimaryOwner__c];
        System.assertEquals(acc.Id, fa.Finserv__PrimaryOwner__c);
        System.assert(acc.RetailBalance__c > 0);
        Test.startTest();
            delete fa;
        Test.stopTest();
        acc = [SELECT RetailBalance__c FROM Account WHERE Name = 'testAccount0'];
        System.assertEquals(0.0, acc.RetailBalance__c);
    }
}