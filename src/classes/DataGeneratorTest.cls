/**
 * Class for DataGenerator test.
 * TODO: finalize checks on opportunities generation, currently DataGenerator doesn't (and shouldn't) create
 * PricebookEntries and/or Pricebooks. These needs to be manually added in a testSetup here to allow a proper
 * opportunities testing.
 */
@isTest
private class DataGeneratorTest {

    /**
     * TODO:
     */
    @testSetup
    private static void createPricebookEntries() {}

    @isTest
    private static void testDataGeneration() {
        Test.startTest();
            DataGenerator dg = DataGenerator.getInstance();
            dg.createTestEnvironment();
        Test.stopTest();
        System.assertEquals(
            [SELECT Id FROM Account LIMIT 50000].size() >= CustomConstants.DEFAULT_ACCOUNTS,
            true,
            'Account generation failure!'
        );
        System.assertEquals(
            [SELECT Id FROM FinServ__FinancialAccount__c WHERE Category__c = 'Retail' LIMIT 50000].size()
                >= CustomConstants.DEFAULT_RETAIL_ACCOUNTS,
            true,
            'Financial Account Retail generation failure!'
        );
        System.assertEquals(
            [SELECT Id FROM FinServ__FinancialAccount__c WHERE Category__c = 'Wealth' LIMIT 50000].size()
                >= CustomConstants.DEFAULT_WEALTH_ACCOUNTS,
            true,
            'Financial Account Wealth generation failure!'
        );
        System.assertEquals(
            [SELECT Id FROM FinServ__FinancialAccount__c WHERE Category__c = 'Commercial' LIMIT 50000].size()
                >= CustomConstants.DEFAULT_COMMERCIAL_ACCOUNTS,
            true,
            'Financial Account Commercial generation failure!'
        );
    }
}
