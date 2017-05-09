delete [SELECT Id FROM FinServ__Revenue__c];
delete [SELECT Id FROM FinServ__FinancialAccount__c];
delete [SELECT Id FROM Opportunity WHERE Mock__c = true];
delete [SELECT Id FROM Account WHERE Mock__c = true];

DataGenerator dg = DataGenerator.getInstance();
dg.createIndividuals(200).commitWork().createOpportunities(500).commitWork();


//    randomizeFinancialAccounts(500, 50, 1000).
    //.createOpportunities(500)
    //.commitWork();

