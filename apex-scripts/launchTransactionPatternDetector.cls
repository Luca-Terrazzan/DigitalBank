TransactionPatternDetector tpd = new TransactionPatternDetector();
        database.executebatch(tpd, 100);


// String cronExp = '0 0 * * * ?';
// System.schedule('BusinessIntelligenceEngineSimulator', cronExp, new TransactionPatternDetectorSchedule());
