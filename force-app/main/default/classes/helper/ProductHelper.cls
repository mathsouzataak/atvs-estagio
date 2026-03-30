public with sharing class ProductHelper {

    public static List<Product2> queryProdutoComIds(Set<Id> ids) {
        return [SELECT Id, HierarquiaProduto__c
                FROM Product2
                WHERE Id IN :ids];
    }

}