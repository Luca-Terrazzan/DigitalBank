global class TransactionPatternDetectorSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        TransactionPatternDetector tpd = new TransactionPatternDetector();
        database.executebatch(tpd, 100);
    }
}