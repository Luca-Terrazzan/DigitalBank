/**
 * Static utilities method for record insertion while testing
 */
public with sharing class TestUtils {
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
            testAccounts.add(new Account(Name = 'testAccount' + accNumber, RecordTypeId = individualAccount.Id));
        }
        // Insert test accounts
        insert testAccounts;
    }

    public static void insertFinancialAccounts()
    {
        Account[] testAccounts = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'IndustriesIndividual'];
        if (testAccounts.isEmpty()) return;
        FinServ__FinancialAccount__c[] testFinAccounts = new FinServ__FinancialAccount__c[]{};
        for(Integer i = 0; i < testAccounts.size(); i++) {
            testFinAccounts.add(
                new FinServ__FinancialAccount__c(
                    Name = 'testFinAccount' + i, FinServ__PrimaryOwner__c = testAccounts[i].Id
                )
            );
        }
        insert testFinAccounts;
    }
}