delete [SELECT Id FROM Account WHERE Mock__c = true];

DataGenerator dg = DataGenerator.getInstance();
dg.createIndividuals(200).
    commitWork();

