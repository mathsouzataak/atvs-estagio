public with sharing class ScheduledDeleteOldOrder implements Schedulable{

    public void execute(SchedulableContext context) {
        DevParameters__mdt parameter = [SELECT DeveloperName, Value__c 
                                        FROM DevParameters__mdt 
                                        WHERE DeveloperName = 'MaxNumberMonthsOrder' 
                                        LIMIT 1];
        Integer maxMonths = Integer.valueOf(parameter.Value__c);
        DeleteOldOrders deleteOldOrdersBatch = new DeleteOldOrders(maxMonths);
        Database.executeBatch(deleteOldOrdersBatch, 10);
    }

}