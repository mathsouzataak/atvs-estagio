public with sharing class OrderController {

    @AuraEnabled(cacheable=true) 
    public static List<CondicaoPagamento__c> getPaymentConditionList() {
        return [SELECT Id, Name FROM CondicaoPagamento__c];
    }
}