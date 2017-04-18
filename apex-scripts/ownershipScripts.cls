SObject[] objs = new SObject[]{};
for(Opportunity opp: [SELECT Id, OwnerId FROM Opportunity WHERE Branch__c = 'Branch 1']) {
    opp.OwnerId = '00546000000aFlX';
    objs.add(opp);
}

for(Lead opp: [SELECT Id, OwnerId FROM Lead WHERE isConverted = false]) {
    opp.OwnerId = '00546000000aFlX';
    opp.Branch__c = 'Branch 1';
    objs.add(opp);
}

for(Case opp: [SELECT Id, OwnerId FROM Case WHERE ContactId != null]) {
    opp.OwnerId = '00546000000aFjq';
    opp.Branch__c = 'Branch 1';
    objs.add(opp);
}

update objs;
