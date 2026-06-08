public with sharing class GoalRefreshHelper {
    
    public static void setOrderItemValueToGoalItems(List<GoalItem__c> goalItemList, OrderItem orderItem, String valueFieldName) {

        for (GoalItem__c iGoalItem : goalItemList) {
            if (!iGoalItem.isSet(valueFieldName)) {
                iGoalItem.put(valueFieldName, 0);
            }

            System.debug(iGoalItem.RecordType);

            if (iGoalItem.RecordType.DeveloperName == 'Performance') {
                iGoalItem.put(valueFieldName, (Decimal) iGoalItem.get(valueFieldName) + orderItem.TotalPrice);
                continue;
            }

            if (iGoalItem.RecordType.DeveloperName == 'Product'
                    && iGoalItem.Product__c == orderItem.Product2Id) {
                iGoalItem.put(valueFieldName, (Decimal) iGoalItem.get(valueFieldName) + orderItem.TotalPrice);
                continue;
            }

            if (iGoalItem.RecordType.DeveloperName == 'ProductFamily'
                    && iGoalItem.ProductFamily__c == orderItem.Product2.ProductFamily__c) {
                iGoalItem.put(valueFieldName, (Decimal) iGoalItem.get(valueFieldName) + orderItem.TotalPrice);
                continue;
            }

            if (iGoalItem.RecordType.DeveloperName == 'PaymentCondition'
                    && iGoalItem.PaymentCondition__c == orderItem.Order.PaymentCondition__c) {
                iGoalItem.put(valueFieldName, (Decimal) iGoalItem.get(valueFieldName) + orderItem.TotalPrice);
                continue;
            }
        }

    }

    public static void setOppItemValueToGoalItems(List<GoalItem__c> goalItemList, OpportunityLineItem oppItem) {

        for (GoalItem__c iGoalItem : goalItemList) {
            if (!iGoalItem.isSet('ProjectedValue__c')) {
                iGoalItem.ProjectedValue__c = 0;
            }

            System.debug(iGoalItem.RecordType);

            if (iGoalItem.RecordType.DeveloperName == 'Performance') {
                iGoalItem.ProjectedValue__c += oppItem.TotalPrice;
                continue;
            }

            if (iGoalItem.RecordType.DeveloperName == 'Product'
                    && iGoalItem.Product__c == oppItem.Product2Id) {
                iGoalItem.ProjectedValue__c += oppItem.TotalPrice;
                continue;
            }

            if (iGoalItem.RecordType.DeveloperName == 'ProductFamily'
                    && iGoalItem.ProductFamily__c == oppItem.Product2.ProductFamily__c) {
                iGoalItem.ProjectedValue__c += oppItem.TotalPrice;
                continue;
            }

            if (iGoalItem.RecordType.DeveloperName == 'PaymentCondition'
                    && iGoalItem.PaymentCondition__c == oppItem.Opportunity.PaymentCondition__c) {
                iGoalItem.ProjectedValue__c += oppItem.TotalPrice;
                continue;
            }
        }

        System.debug(goalItemList);

    }

    public static void setOrderItemValueToGoals(List<Goal__c> goalList, OrderItem orderItem) {

        for (Goal__c iGoal : goalList) {
            if (!iGoal.isSet('SalesTotalValue__c')) {
                iGoal.SalesTotalValue__c = 0;
            }

            iGoal.SalesTotalValue__c += orderItem.TotalPrice;
        }

    }

}