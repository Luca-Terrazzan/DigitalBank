delete [SELECT Id FROM FinServ__FinancialAccount__c WHERE Mock__c = true];
delete [SELECT Id FROM Account WHERE Mock__c = true];
delete [SELECT Id FROM Opportunity WHERE Mock__c = true];

DataGenerator dg = DataGenerator.getInstance();
dg.createIndividuals(200)
    .createOpportunities(180)
    .commitWork().closeOpportunities(0.40);
    //randomizeFinancialAccounts(500, 50, 1000).
//dg.createOpportunities(500).commitWork().closeOpportunities(0.10);

