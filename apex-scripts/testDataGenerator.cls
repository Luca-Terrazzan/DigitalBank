DataGenerator dg = DataGenerator.getInstance();
dg.createIndividuals(5000).
    commitWork();

//delete [SELECT Id FROM Account WHERE Mock__c = true];
