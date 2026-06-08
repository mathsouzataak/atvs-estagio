public with sharing class GoalRefreshHelper {

    public static void setValuesToGoalItems(List<GoalItem__c> goalItemList, Id productId, Id productFamilyId, Id paymentConditionId, Decimal totalPrice, String valueFieldName) {

        for (GoalItem__c iGoalItem : goalItemList) {
            if (!iGoalItem.isSet(valueFieldName)) {
                iGoalItem.put(valueFieldName, 0);
            }

            System.debug(iGoalItem.RecordType);

            if (iGoalItem.RecordType.DeveloperName == 'Performance') {
                iGoalItem.put(valueFieldName, (Decimal) iGoalItem.get(valueFieldName) + totalPrice);
                continue;
            }

            if (iGoalItem.RecordType.DeveloperName == 'Product'
                    && iGoalItem.Product__c == productId) {
                iGoalItem.put(valueFieldName, (Decimal) iGoalItem.get(valueFieldName) + totalPrice);
                continue;
            }

            if (iGoalItem.RecordType.DeveloperName == 'ProductFamily'
                    && iGoalItem.ProductFamily__c == productFamilyId) {
                iGoalItem.put(valueFieldName, (Decimal) iGoalItem.get(valueFieldName) + totalPrice);
                continue;
            }

            if (iGoalItem.RecordType.DeveloperName == 'PaymentCondition'
                    && iGoalItem.PaymentCondition__c == paymentConditionId) {
                iGoalItem.put(valueFieldName, (Decimal) iGoalItem.get(valueFieldName) + totalPrice);
                continue;
            }
        }

    }

    public static void setValueToGoals(List<Goal__c> goalList, Decimal totalPrice) {

        for (Goal__c iGoal : goalList) {
            if (!iGoal.isSet('SalesTotalValue__c')) {
                iGoal.SalesTotalValue__c = 0;
            }

            iGoal.SalesTotalValue__c += totalPrice;
        }

    }

}