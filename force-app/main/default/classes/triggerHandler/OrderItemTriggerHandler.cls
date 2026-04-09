public with sharing class OrderItemTriggerHandler extends TriggerHandler {

    public override void beforeInsert() {
        if (Trigger.new == null || Trigger.new.isEmpty()) {
            return;
        }

        OrderItemHelper.searchAndAssignParameters(Trigger.new);
    }

    public override void beforeUpdate() {
        if (Trigger.new == null || Trigger.new.isEmpty()) {
            return;
        }

        List<OrderItem> newItems = (List<OrderItem>)Trigger.new;
        List<OrderItem> oldItems = (List<OrderItem>)Trigger.old;

        List<OrderItem> newItemsWithUpdatedProduct = new List<OrderItem>();
        for (Integer i = 0; i < oldItems.size(); i++) {

            // Tentativa de alterar pedido do item
            if (newItems[i].OrderId != oldItems[i].OrderId) {
                newItems[i].addError('O pedido do item não pode ser alterado');
                continue;
            }

            // Alteração do produto do item - necessário atualizar parâmetros
            if (newItems[i].Product2Id != oldItems[i].Product2Id ||
                    newItems[i].ListPrice != oldItems[i].ListPrice ) {
                newItemsWithUpdatedProduct.add(newItems[i]);
            }
        }
        
        OrderItemHelper.searchAndAssignParameters(newItemsWithUpdatedProduct);

    }

}