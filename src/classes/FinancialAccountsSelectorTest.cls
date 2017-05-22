@isTest
private class FinancialAccountsSelectorTest {

    @testSetup
    public static void testDataSetup()
    {
        // Get record types
        RecordType individualAccount = [SELECT Id FROM RecordType
            WHERE SObjectType = 'Account' AND DeveloperName = 'IndustriesIndividual'];

        // Insert test accounts
        Account[] testAccounts = new Account[]{
            new Account(Name = 'testAccount1', RecordTypeId = individualAccount.Id),
            new Account(Name = 'testAccount2', RecordTypeId = individualAccount.Id),
            new Account(Name = 'testAccount3', RecordTypeId = individualAccount.Id)
        };
        insert testAccounts;

        // Insert test financial accounts + roles
        FinServ__FinancialAccount__c[] testFinAccounts = new FinServ__FinancialAccount__c[]{
            new FinServ__FinancialAccount__c(Name = 'testFinAccount1',
                FinServ__PrimaryOwner__c = testAccounts[0].Id,
                Category__c = 'Retail')
        };
        insert testFinAccounts;
    }

	@isTest
    static void testDML() {
        FinServ__FinancialAccount__c tempFinAcc = [SELECT Id, FinServ__PrimaryOwner__c FROM FinServ__FinancialAccount__c][0];
        Account tempOwner = [SELECT Id FROM Account WHERE Name = 'testAccount1'];
		System.assertEquals(tempFinAcc.FinServ__PrimaryOwner__c, tempOwner.Id);
	}

}
