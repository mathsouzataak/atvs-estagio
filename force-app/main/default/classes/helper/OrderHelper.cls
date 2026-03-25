public with sharing class OrderHelper {
    
    // public static void atribuirImpostoItens(Map<Id, Order> pedidos) {
    //     List<OrderItem> itens = new List<OrderItem>();
    //     Map<Id,Id> mapPedidoEstado = new Map<Id,Id>();
    //     for (Order pedido : [SELECT Id, AccountAddress__c, OrderItems FROM Order WHERE Id IN :pedidos.keySet()]){
    //         itens.addAll(pedido.OrderItems);
    //         mapPedidoEstado.put(pedido.Id, pedido.AccountAddress__r.Cidade__r.Estado__c);
    //     }
        
    //     Set<Id> idsProdutos = new Set<Id>();
    //     for (OrderItem item : itens) {
    //         idsProdutos.add(item.Product2Id);
    //     }
        
    //     List<Imposto__c> impostos = [SELECT Id, Estado__c, Product__c, ValorPercentual__c 
    //                                     FROM Imposto__c 
    //                                     WHERE (Status__c = 'Aprovado' AND Estado__c IN :mapPedidoEstado.values() AND Product__c IN :idsProdutos)];
        
    //     for (OrderItem item : itens) {
    //         Imposto__c impostoAplicado;
    //         for (Imposto__c imposto : impostos) {
    //             if (imposto.Product__c == item.Product2Id && imposto.Estado__c == mapPedidoEstado.get(item.OrderId)) {
    //                 impostoAplicado = imposto;
    //                 break;
    //             }
    //         }
            
    //         if (impostoAplicado != null) {
    //             item.ImpostoPercent__c = impostoAplicado.ValorPercentual__c;
    //         } else {
    //             item.addError('O produto não possui imposto aplicável no estado do pedido.');
    //             pedidos.get(item.AccountAddress__c).addError('Não há imposto aplicável nesta localidade para o produto ' + item.Product2.Name + '.');
    //         }
    //     }
        
    //     update itens;
    // }
    
}