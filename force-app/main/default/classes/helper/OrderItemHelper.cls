public with sharing class OrderItemHelper {

    public static void atribuirImposto(List<OrderItem> itens) {

        Set<Id> idsProdutos = new Set<Id>();
        Set<Id> idsEstados = new Set<Id>();
        Set<Id> idsPedidos = new Set<Id>();
        for (OrderItem item : itens) {
            idsProdutos.add(item.Product2Id);
            idsPedidos.add(item.OrderId);
        }

        List<Imposto__c> impostos = [SELECT Id, ValorPercentual__c, Product__c, Estado__c 
                                        FROM Imposto__c 
                                        WHERE (Product__c IN :idsProdutos AND Estado__c IN :idsEstados)];


    }

}