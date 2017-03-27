TestUtils.insertIndividuals(2);
Account acc = [SELECT CommercialBalance__c, CommercialLoan__c FROM Account WHERE Name = 'testAccount0'];
TestUtils.insertFinancialAccounts(false, acc.Id);
TestUtils.insertFinancialAccounts(true);
acc = [SELECT CommercialBalance__c, CommercialLoan__c FROM Account WHERE Name = 'testAccount0'];
FinServ__FinancialAccount__c fa1 = [SELECT Category__c, IsLoan__c, FinServ__Balance__c, FinServ__PrimaryOwner__c, FinServ__JointOwner__c
    FROM FinServ__FinancialAccount__c WHERE Name = 'Acc:0_Cat:Commercial_IsLoan:false'];
FinServ__FinancialAccount__c fa2 = [SELECT Category__c, IsLoan__c, FinServ__Balance__c, FinServ__PrimaryOwner__c, FinServ__JointOwner__c
    FROM FinServ__FinancialAccount__c WHERE Name = 'Acc:1_Cat:Commercial_IsLoan:false'];
System.debug('acc: ' + acc);
System.debug('fa: ' + fa1);
System.debug('fa: ' + fa2);

System.assert(false); // termination