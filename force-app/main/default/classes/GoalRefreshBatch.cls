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

            for (GoalItem__c iGoalItem : mapSellerXGoalItems.get(iOrderItem.CreatedById)) {
                if (iGoalItem.NegotiatedValue__c == null) {
                    iGoalItem.NegotiatedValue__c = 0;
                }

                if (iGoalItem.RecordTypeId == Schema.SObjectType.GoalItem__c.getRecordTypeInfosByName().get('Performance').getRecordTypeId()) {
                    iGoalItem.NegotiatedValue__c += iOrderItem.TotalPrice;
                    continue;
                }

                if (iGoalItem.RecordTypeId == Schema.SObjectType.GoalItem__c.getRecordTypeInfosByName().get('Product').getRecordTypeId()
                        && iGoalItem.Product__c == iOrderItem.Product2Id) {
                    iGoalItem.NegotiatedValue__c += iOrderItem.TotalPrice;
                    continue;
                }

                if (iGoalItem.RecordTypeId == Schema.SObjectType.GoalItem__c.getRecordTypeInfosByName().get('ProductFamily').getRecordTypeId()
                        && iGoalItem.ProductFamily__c == iOrderItem.Product2.ProductFamily__c) {
                    iGoalItem.NegotiatedValue__c += iOrderItem.TotalPrice;
                    continue;
                }

                if (iGoalItem.RecordTypeId == Schema.SObjectType.GoalItem__c.getRecordTypeInfosByName().get('PaymentCondition').getRecordTypeId()
                        && iGoalItem.ProductFamily__c == iOrderItem.Order.PaymentCondition__c) {
                    iGoalItem.NegotiatedValue__c += iOrderItem.TotalPrice;
                    continue;
                }
            }
            
        }


        for (OrderItem iOrderItem : [SELECT Id, CreatedById, Order.PaymentCondition__c, Order.Status, Product2Id, Product2.ProductFamily__c, TotalPrice
                                        FROM OrderItem
                                        WHERE Order.CreatedById IN :mapSellerXGoals.keySet() AND Order.Status = 'Activated']) {

            for (GoalItem__c iGoalItem : mapSellerXGoalItems.get(iOrderItem.CreatedById)) {
                if (iGoalItem.AccomplishedValue__c == null) {
                    iGoalItem.AccomplishedValue__c = 0;
                }

                if (iGoalItem.RecordTypeId == Schema.SObjectType.GoalItem__c.getRecordTypeInfosByName().get('Performance').getRecordTypeId()) {
                    iGoalItem.AccomplishedValue__c += iOrderItem.TotalPrice;
                    continue;
                }

                if (iGoalItem.RecordTypeId == Schema.SObjectType.GoalItem__c.getRecordTypeInfosByName().get('Product').getRecordTypeId()
                        && iGoalItem.Product__c == iOrderItem.Product2Id) {
                    iGoalItem.AccomplishedValue__c += iOrderItem.TotalPrice;
                    continue;
                }

                if (iGoalItem.RecordTypeId == Schema.SObjectType.GoalItem__c.getRecordTypeInfosByName().get('ProductFamily').getRecordTypeId()
                        && iGoalItem.ProductFamily__c == iOrderItem.Product2.ProductFamily__c) {
                    iGoalItem.AccomplishedValue__c += iOrderItem.TotalPrice;
                    continue;
                }

                if (iGoalItem.RecordTypeId == Schema.SObjectType.GoalItem__c.getRecordTypeInfosByName().get('PaymentCondition').getRecordTypeId()
                        && iGoalItem.ProductFamily__c == iOrderItem.Order.PaymentCondition__c) {
                    iGoalItem.AccomplishedValue__c += iOrderItem.TotalPrice;
                    continue;
                }
            }

            for (Goal__c iGoal : mapSellerXGoals.get(iOrderItem.CreatedById)) {
                if (iGoal.SalesTotalValue__c == null) {
                    iGoal.SalesTotalValue__c = 0;
                }

                iGoal.SalesTotalValue__c += iOrderItem.TotalPrice;
            }
            
        }


    }

    public void finish(Database.BatchableContext context) {

    }

}