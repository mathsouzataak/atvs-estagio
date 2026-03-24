public with sharing class OrderItemHelper {

    public static void atribuirImposto(List<OrderItem> itens) {

        Set<Id> idsProdutos = new Set<Id>();
        Set<Id> idsPedidos = new Set<Id>();
        for (OrderItem item : itens) {
            idsProdutos.add(item.Product2Id);
            idsPedidos.add(item.OrderId);
        }

        Map<Id,Id> mapPedidoEstado = new Map<Id,Id>();
        for (Order pedido : [SELECT Id, AccountAddress__c FROM Order WHERE Id IN :idsPedidos]) {
            mapPedidoEstado.put(pedido.Id, pedido.AccountAddress__r.Cidade__r.Estado__c);
        }

        List<Imposto__c> impostos = [SELECT Id, Estado__c, Product__c, ValorPercentual__c 
                                        FROM Imposto__c 
                                        WHERE (Estado__c IN :mapPedidoEstado.values() AND Product__c IN :idsProdutos)];

        for (OrderItem item : itens) {
            Imposto__c impostoAplicado;
            for (Imposto__c imposto : impostos) {
                if (imposto.Product__c == item.Product2Id && imposto.Estado__c == mapPedidoEstado.get(item.OrderId)) {
                    impostoAplicado = imposto; 
                    break;
                }
            }

            if (impostoAplicado != null) {
                item.ImpostoPercent__c = impostoAplicado.ValorPercentual__c;
            } else {
                item.addError('O produto não possui imposto aplicável no estado do pedido.');
            }
        }
    }

}