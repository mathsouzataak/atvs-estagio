public with sharing class DevUserDataRetriever implements Database.Batchable<SObject>, Database.AllowsCallouts {

    Set<Id> devUserIds;

    public DevUserDataRetriever(Set<Id> devUserIds) {
        this.devUserIds = devUserIds;
    }

    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        String query = 'SELECT Id, Login__c FROM DevUser__c WHERE Id IN (';
        for (Id id : devUserIds) {
            query += '\'' + id + '\',';
        }
        query = query.removeEnd(',');
        query += ')';

        System.debug('Batch query: ' + query);

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext batchableContext, List<sObject> scope) {
        List<DevUser__c> devUsersWithData = DevUserHelper.getDevUsersGithubData(scope);

        System.debug('DevUsers with Data: ');
        System.debug(devUsersWithData);

        Database.update(devUsersWithData);
    }

    public void finish(Database.BatchableContext batchableContext) {

    }

}