TestUtils.insertIndividuals(10);
TestUtils.insertFinancialAccounts();
System.debug('Accounts: ' + [SELECT Name FROM Account WHERE Name LIKE 'testAccount%']);
System.debug('Financial Accounts: ' + [SELECT Name, FinServ__Balance__c, FinServ__PrimaryOwner__r.Name FROM FinServ__FinancialAccount__c
    WHERE Name LIKE 'Account%']);
System.assert(false); //termination