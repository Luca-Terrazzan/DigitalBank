global class TransactionPatternDetector implements Database.Batchable<SObject> {
    private static final String QUERY = 'SELECT id, name, finserv__primaryowner__c,' +
        '(SELECT name, transaction_date__c, created_date__c, amount__c FROM transactions__r WHERE category__c = \'retail\' '+
        'ORDER BY transaction_date__c desc) FROM finserv__financialaccount__c ' +
        'WHERE category__c = \'Retail\' AND isloan__c = false';

    /**
     * Standard Constructor
     * @type    !CONSTRUCT
     */
    global TransactionPatternDetector() {}

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(QUERY);
    }

    global void execute(Database.BatchableContext bc, List<FinServ__FinancialAccount__c> scope) {
        FinServ__FinancialAccount__c[] salaries = new FinServ__FinancialAccount__c[]{};
        Map<Id, Id> clientSalaryMap = new Map<Id, Id>();
        for (Integer i = 0; i < scope.size(); i++) {
            Boolean isSalary = true;
            Transaction__c[] transactions = scope[i].transactions__r;
            if (transactions.size() < 3) continue;
            for (Integer j = 0; j < transactions.size(); j++) {
                if (transactions[j].transaction_date__c == null || ( transactions[j].transaction_date__c.Month() != System.Today().Month() - j) ) {
                    isSalary = false;
                    i++;
                    break;
                }
            }
            if (isSalary) {
                clientSalaryMap.put(scope[i].Finserv__PrimaryOwner__c, scope[i].Id);
            }
        }

        Account[] clientsWithSalaryToAdd = [SELECT Id, Salary__c FROM Account WHERE Id IN: clientSalaryMap.keySet() AND Salary__c = null];
        FinServ__Alert__c[] salaryWarnings = new FinServ__Alert__c[]{};
        for (Account client: clientsWithSalaryToAdd) {
            client.Salary__c = clientSalaryMap.get(client.Id);
            salaryWarnings.add(new FinServ__Alert__c(
                FinServ__Message__c = 'New Salary detected for the current client! Please check the Account salary field.',
                FinServ__Account__c = client.Id,
                FinServ__FinancialAccount__c = clientSalaryMap.get(client.Id),
                FinServ__Active__c = true,
                FinServ__Severity__c = 'Info'
            ));
        }
        update clientsWithSalaryToAdd;
        insert salaryWarnings;
    }

    global void finish(Database.BatchableContext bc) {}

}