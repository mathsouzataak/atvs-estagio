public with sharing class GoalRefreshBatch implements Database.Batchable<SObject> {
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id, Seller__c, (SELECT Id, Product__c, ProductFamily__c, PaymentCondition__c, RecordTypeId FROM GoalItems__r) FROM Goal__c';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<Goal__c> goals) {

        Map<Id, List<GoalItem__c>> mapSellerXGoalItems = new Map<Id, List<GoalItem__c>>();
        Map<Id, List<Goal__c>> mapSellerXGoals = new Map<Id, List<Goal__c>>();

        for (Goal__c iGoal : goals) {
            if (mapSellerXGoalItems.containsKey(iGoal.Seller__c)) {
                mapSellerXGoalItems.get(iGoal.Seller__c).addAll(iGoal.GoalItems__r);
            } else {
                mapSellerXGoalItems.put(iGoal.Seller__c, new List<GoalItem__c>(iGoal.GoalItems__r));
            }

            if (mapSellerXGoals.containsKey(iGoal.Seller__c)) {
                mapSellerXGoals.get(iGoal.Seller__c).add(iGoal);
            } else {
                mapSellerXGoals.put(iGoal.Seller__c, new List<Goal__c>{iGoal});
            }
        }

        for (OrderItem iOrderItem : [SELECT Id, CreatedById, Order.PaymentCondition__c, Order.Status, Product2Id, Product2.ProductFamily__c, TotalPrice
                                        FROM OrderItem
                                        WHERE Order.CreatedById IN :mapSellerXGoals.keySet() AND Order.Status = 'Draft']) {
            
        }

    }

    public void finish(Database.BatchableContext context) {

    }

}