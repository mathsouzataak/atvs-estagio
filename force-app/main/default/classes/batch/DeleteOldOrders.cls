public with sharing class DeleteOldOrders implements Database.Batchable<SObject> {

    Integer monthsThreshold;

    public DeleteOldOrders(Integer monthsThreshold) {
        this.monthsThreshold = monthsThreshold;
    }

    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        Datetime dateThreshold = Datetime.now().addMonths(-monthsThreshold);
        System.debug(dateThreshold.format('yyyy-MM-dd\'T\'HH:mm:ssZ'));
        String query = 'SELECT Id FROM Order WHERE CreatedDate < ' + dateThreshold.format('yyyy-MM-dd\'T\'HH:mm:ssZ');

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext batchableContext, List<Order> orders) {
        Set<Id> orderIds = new Set<Id>();
        for (Order iOrder : orders) {
            orderIds.add(iOrder.Id);
        }

        Database.delete([SELECT Id FROM OrderLogAssociation__c WHERE Order__c IN :orderIds], false);
        Database.delete([SELECT Id FROM OrderItem WHERE OrderId IN :orderIds], false);
        Database.delete(orders, false);
    }

    public void finish(Database.BatchableContext batchableContext) {

    }

}