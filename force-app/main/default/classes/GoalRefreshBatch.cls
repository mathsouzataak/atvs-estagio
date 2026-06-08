public with sharing class GoalRefreshBatch implements Database.Batchable<SObject> {
    
    public Database.QueryLocator start(Database.BatchableContext context) {

        return Database.getQueryLocator([
            SELECT Id, Seller__c, 
                (SELECT Id, Product__c, ProductFamily__c, PaymentCondition__c, RecordType.DeveloperName 
                    FROM GoalItems__r) 
            FROM Goal__c
        ]);
    }

    public void execute(Database.BatchableContext context, List<Goal__c> goals) {

        Map<Id, List<GoalItem__c>> mapSellerXGoalItems = new Map<Id, List<GoalItem__c>>();
        Map<Id, List<Goal__c>> mapSellerXGoals = new Map<Id, List<Goal__c>>();
        List<GoalItem__c> allGoalItems = new List<GoalItem__c>();

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

            allGoalItems.addAll(iGoal.GoalItems__r);
        }

        for (AggregateResult iResult : [SELECT CreatedById seller, 
                                            Order.PaymentCondition__c paymentCondition, 
                                            Order.Status status, 
                                            Product2Id product, 
                                            Product2.ProductFamily__c productFamily, 
                                            SUM(TotalPrice) totalPrice
                                        FROM OrderItem
                                        WHERE Order.CreatedById IN :mapSellerXGoals.keySet()
                                        GROUP BY CreatedById, Order.PaymentCondition__c, Order.Status, Product2Id, Product2.ProductFamily__c]) {
            
            switch on (String) iResult.get('Status') {
                when 'Draft' {
                    GoalRefreshHelper.setValuesToGoalItems(
                        mapSellerXGoalItems.get((Id)iResult.get('seller')),
                        (Id)iResult.get('product'),
                        (Id)iResult.get('productFamily'),
                        (Id)iResult.get('paymentCondition'),
                        (Decimal)iResult.get('totalPrice'),
                        'NegotiatedValue__c'
                    );
                }
                when 'Activated' {
                    GoalRefreshHelper.setValuesToGoalItems(
                        mapSellerXGoalItems.get((Id)iResult.get('seller')),
                        (Id)iResult.get('product'),
                        (Id)iResult.get('productFamily'),
                        (Id)iResult.get('paymentCondition'),
                        (Decimal)iResult.get('totalPrice'),
                        'AccomplishedValue__c'
                    );
                    GoalRefreshHelper.setValueToGoals(mapSellerXGoals.get((Id)iResult.get('seller')), (Decimal)iResult.get('totalPrice'));
                }
            }
        }

        for (AggregateResult iResult : [SELECT CreatedById seller, 
                                            Opportunity.PaymentCondition__c paymentCondition, 
                                            Product2Id product, 
                                            Product2.ProductFamily__c productFamily, 
                                            SUM(TotalPrice) totalPrice
                                        FROM OpportunityLineItem
                                        WHERE Opportunity.CreatedById IN :mapSellerXGoals.keySet()
                                        GROUP BY CreatedById, Opportunity.PaymentCondition__c, Product2Id, Product2.ProductFamily__c]) {
            GoalRefreshHelper.setValuesToGoalItems(
                mapSellerXGoalItems.get((Id)iResult.get('seller')),
                (Id)iResult.get('product'),
                (Id)iResult.get('productFamily'),
                (Id)iResult.get('paymentCondition'),
                (Decimal)iResult.get('totalPrice'),
                'ProjectedValue__c'
            );
        }

        Database.update(allGoalItems);
        Database.update(goals);
    }

    public void finish(Database.BatchableContext context) {

    }

}