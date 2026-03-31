public with sharing class OrderHelper {
    
    


    public static List<Order> queryPedidoComIds(Set<Id> ids) {
        return [SELECT Id, AccountAddress__r.Cidade__c, AccountAddress__r.Cidade__r.Estado__c, AccountAddress__r.Cidade__r.Estado__r.Pais__c, AccountId, Account.AccountGroup__c, CentroDistribuicao__c
                FROM Order 
                WHERE Id IN :ids];
    }
}