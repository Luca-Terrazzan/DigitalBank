/**
 * Static utilities method for record insertion while testing
 */
public with sharing class TestUtils {
    private static final String[] CATEGORIES = new String[]{
        'Retail',
        'Wealth',
        'Commercial'
    };

    public static void insertIndividuals(Integer accNumber)
    {
        if (accNumber < 1) return;
        // Get individual record type
        RecordType individualAccount = [SELECT Id FROM RecordType
            WHERE SObjectType = 'Account' AND DeveloperName = 'IndustriesIndividual'];
        Account[] testAccounts = new Account[]{
        };
        // Fill accounts
        for(Integer i = 0; i < accNumber; i++) {
            testAccounts.add(new Account(Name = 'testAccount' + i, RecordTypeId = individualAccount.Id));
        }
        // Insert test accounts
        insert testAccounts;
    }

    public static void insertFinancialAccounts()
    {
        Account[] testAccounts = [SELECT Id FROM Account
            WHERE RecordType.DeveloperName = 'IndustriesIndividual'
            AND Name LIKE 'testAccount%'];
        if (testAccounts.isEmpty()) return;
        FinServ__FinancialAccount__c[] testFinAccounts = new FinServ__FinancialAccount__c[]{};
        for(Integer i = 0; i < testAccounts.size(); i++) {
            for(Integer j = 0; j < CATEGORIES.size(); j++) {
                testFinAccounts.add(
                    new FinServ__FinancialAccount__c(
                        Name = 'Account' + i + 'FinancialAccount' + j,
                        FinServ__PrimaryOwner__c = testAccounts[i].Id,
                        FinServ__Balance__c = Math.random() * 1000,
                        Category__c = CATEGORIES[j]
                    )
                );
            }
        }
        insert testFinAccounts;
    }
}