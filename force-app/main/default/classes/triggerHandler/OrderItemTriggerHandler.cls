public with sharing class OrderItemTriggerHandler extends TriggerHandler {

    public override void beforeInsert() {
        if (Trigger.new == null || Trigger.new.isEmpty()) {
            return;
        }

        OrderItemHelper.buscarEAtribuirParametros(Trigger.new);
    }

    public override void beforeUpdate() {
        if (Trigger.new == null || Trigger.new.isEmpty()) {
            return;
        }

        List<OrderItem> newItens = (List<OrderItem>)Trigger.new;
        List<OrderItem> oldItens = (List<OrderItem>)Trigger.old;

        List<OrderItem> newProdPedidoItems = new List<OrderItem>();
        for (Integer i = 0; i < oldItens.size(); i++) {

            // Tentativa de alterar pedido do item
            if (newItens[i].OrderId != oldItens[i].OrderId) {
                newItens[i].addError('O pedido do item não pode ser alterado');
                continue;
            }

            // Alteração do produto do item - necessário atualizar parâmetros
            if (newItens[i].Product2Id != oldItens[i].Product2Id ||
                    newItens[i].ListPrice != oldItens[i].ListPrice ) {
                newProdPedidoItems.add(newItens[i]);
            }
        }
        
        OrderItemHelper.buscarEAtribuirParametros(newProdPedidoItems);

    }

}