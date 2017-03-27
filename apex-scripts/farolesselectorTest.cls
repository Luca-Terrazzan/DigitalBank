FinancialAccountRolesSelector fars = new FinancialAccountRolesSelector();
Account jack = [SELECT Id FROM Account WHERE Name = 'Jack London'];
System.debug('test: ' + fars.selectByAccount(new Set<Id>{jack.Id}));