@isTest
private class TransactionPatternDetectorTest {

    @testSetup
    private static void generateData() {
        DataGenerator dg = DataGenerator.getInstance();
        dg.createTestEnvironment();
        // now insert some transactions to make a financial account looks like a salary deposit account
        FinServ__FinancialAccount__c[] finAcc = [
            SELECT Id
            FROM FinServ__FinancialAccount__c
            WHERE IsLoan__c = false AND Category__c = 'Retail'
            LIMIT 1];
        System.assert(!finAcc.isEmpty(), 'Data Generation Error!');
        Transaction__c t1 = new Transaction__c(
            Amount__c = 1,
            account_number__c = finAcc[0].Id,
            Status__c = true,
            transaction_date__c = Date.newInstance(2017, System.today().month(), 1),
            transaction_id__c = 'testTransaction1'
        );
        Transaction__c t2 = t1.clone(false, false, false, false);
        t2.transaction_date__c = Date.newInstance(2017, System.today().month() - 1, 1);
        t2.transaction_id__c = 'testTransaction2';
        Transaction__c t3 = t1.clone(false, false, false, false);
        t3.transaction_date__c = Date.newInstance(2017, System.today().month() - 2, 1);
        t3.transaction_id__c = 'testTransaction3';
        insert new Transaction__c[]{t1, t2, t3};
    }

    @isTest
    private static void testSalaryDetection() {
        Test.startTest();
            // given
            TransactionPatternDetector tpd = new TransactionPatternDetector();
            // when
            database.executebatch(tpd, 200);
        Test.stopTest();
        // then
        Account[] accountsWithSalary = [SELECT Id FROM Account WHERE Salary__c != null];
        System.assert(accountsWithSalary.size() >= 1, 'Transaction pattern detection failed!');
    }

}