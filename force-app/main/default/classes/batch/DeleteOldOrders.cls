public with sharing class DeleteOldOrders implements Database.Batchable<SObject> {

    Integer monthsThreshold;

    public DeleteOldOrders(Integer monthsThreshold) {
        this.monthsThreshold = monthsThreshold;
    }

    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        Date dateThreshold = Date.today().addMonths(-monthsThreshold);
        String query = 'SELECT Id FROM Order WHERE CreatedDate < ' + String.valueOf(dateThreshold);

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext batchableContext, List<Order> orders) {
        Set<Id> orderIds = new Set<Id>();
        for (Order iOrder : orders) {
            orderIds.add(iOrder.Id);
        }

        Database.delete(orders);
    }

    public void finish(Database.BatchableContext batchableContext) {

    }

}