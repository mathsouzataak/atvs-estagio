public with sharing class GoalRefreshSchedule implements Schedulable {

    public void execute(SchedulableContext context) {
        GoalRefreshBatch goalRefresher = new GoalRefreshBatch();
        Id jobId = Database.executeBatch(goalRefresher);
        System.debug('Job ID: ' + jobId);
    }

}