/**
 * Static utilities method for record insertion while testing
 * ***DEPRECATED*** --> See DataGenerator.cls instead
 */
public with sharing class TestUtils {
    private static final String[] CATEGORIES = new String[]
    {
        'Retail',
        'Wealth',
        'Commercial'
    };
    private static final Map<Boolean, String> LOAN_TYPES = new Map<Boolean, String>
    {
        true  => 'Credit Card',
        false => 'Savings'
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
            testAccounts.add(
                new Account(
                    Name = 'testAccount' + i,
                    RecordTypeId = individualAccount.Id
                )
            );
        }
        // Insert test accounts
        insert testAccounts;
    }

    public static void insertFinancialAccounts(Boolean insertLoans)
    {
        insertFinancialAccounts(insertLoans, null);
    }

    public static void insertFinancialAccounts(Boolean insertLoans, Id coowner)
    {
        Account[] testAccounts = [SELECT Id FROM Account
            WHERE RecordType.DeveloperName = 'IndustriesIndividual'
            AND Name LIKE 'testAccount%' ORDER BY Name];
        if (testAccounts.isEmpty()) return;
        FinServ__FinancialAccount__c[] testFinAccounts = new FinServ__FinancialAccount__c[]{};
        for(Integer i = 0; i < testAccounts.size(); i++) {
            for(Integer j = 0; j < CATEGORIES.size(); j++) {
                testFinAccounts.add(
                    new FinServ__FinancialAccount__c(
                        Name = 'Acc:' + i + '_Cat:' + CATEGORIES[j] + '_IsLoan:' +insertLoans,
                        FinServ__PrimaryOwner__c = testAccounts[i].Id,
                        FinServ__JointOwner__c = coowner != null && coowner != testAccounts[i].Id ? coowner : null,
                        FinServ__Balance__c = Math.random() * 1000,
                        FinServ__FinancialAccountType__c = LOAN_TYPES.get(insertLoans),
                        Category__c = CATEGORIES[j]
                    )
                );
            }
        }
        insert testFinAccounts;
    }
}