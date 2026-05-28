public with sharing class ScheduledDeleteOldOrder implements Schedulable{

    public void execute(SchedulableContext context) {

        DevParameters__mdt parameter = [SELECT DeveloperName, Value__c 
                                        FROM DevParameters__mdt 
                                        WHERE DeveloperName = 'MaxNumberMonthsOrder' 
                                        LIMIT 1];

        Integer maxMonths = Test.isRunningTest() ? 5 : Integer.valueOf(parameter.Value__c);

        DeleteOldOrders deleteOldOrdersBatch = new DeleteOldOrders(maxMonths);
        Id batchJobId = Test.isRunningTest() ? Database.executeBatch(deleteOldOrdersBatch) : Database.executeBatch(deleteOldOrdersBatch, 10);
    }

}