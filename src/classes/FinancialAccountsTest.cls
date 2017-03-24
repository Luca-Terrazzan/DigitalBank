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
        System.assertEquals(balance, acc.RetailBalance__c);
    }

    @isTest
    static void testRollUpUpdate() {
        TestUtils.insertIndividuals(3);
        TestUtils.insertFinancialAccounts(false);
        FinServ__FinancialAccount__c fa = [SELECT FinServ__Balance__c FROM FinServ__FinancialAccount__c
            WHERE Category__c = 'Retail' LIMIT 1];
        Test.startTest();
            fa.FinServ__Balance__c += 100.15;
            update fa;
        Test.stopTest();
        Decimal balance = (Decimal) [
            SELECT SUM(FinServ__Balance__c) balance, Finserv__PrimaryOwner__r.Name name, Category__c category
            FROM FinServ__FinancialAccount__c
            WHERE Category__c = 'Retail' AND Finserv__PrimaryOwner__r.Name = 'testAccount0'
            GROUP BY Finserv__PrimaryOwner__r.Name, Category__c
        ][0].get('balance');
        Account acc = [SELECT RetailBalance__c FROM Account WHERE Name = 'testAccount0'];
        System.assertEquals(Math.round(balance), Math.round(acc.RetailBalance__c));
    }

    @isTest
    static void testRollUpDelete()
    {
        TestUtils.insertIndividuals(3);
        TestUtils.insertFinancialAccounts(false);
        Account acc = [SELECT RetailBalance__c FROM Account WHERE Name = 'testAccount0'];
        FinServ__FinancialAccount__c fa = [SELECT Name, FinServ__Balance__c, Finserv__PrimaryOwner__r.Name FROM FinServ__FinancialAccount__c
            WHERE Name = 'Account0FinancialAccount0' LIMIT 1];
        System.assertEquals(acc.Id, fa.Finserv__PrimaryOwner__c);
        System.assert(acc.RetailBalance__c > 0);
        Test.startTest();
            delete fa;
        Test.stopTest();
        acc = [SELECT RetailBalance__c FROM Account WHERE Name = 'testAccount0'];
        System.assertEquals(0.0, acc.RetailBalance__c);
    }
}