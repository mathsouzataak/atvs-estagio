public with sharing class GoalRefreshBatch implements Database.Batchable<SObject> {
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id, Seller__c FROM Goal__c';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<Goal__c> goals) {

    }

    public void finish(Database.BatchableContext context) {

    }

}