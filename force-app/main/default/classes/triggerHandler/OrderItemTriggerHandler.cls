public with sharing class OrderItemTriggerHandler extends TriggerHandler {

    public override void beforeInsert() {
        if (Trigger.new == null || Trigger.new.isEmpty()) {
            return;
        }

        OrderItemHelper.atribuirParametros(Trigger.new);
    }

    public override void beforeUpdate() {
        if (Trigger.new == null || Trigger.new.isEmpty()) {
            return;
        }

        List<OrderItem> newProdPedidoItems = new List<OrderItem>();
        for (Integer i = 0; i < Trigger.new.size(); i++) {
            if (((OrderItem)(Trigger.new[i])).Product2Id != ((OrderItem)(Trigger.old[i])).Product2Id ||
                    ((OrderItem)(Trigger.new[i])).OrderId != ((OrderItem)(Trigger.old[i])).OrderId ||
                    ((OrderItem)(Trigger.new[i])).ListPrice != ((OrderItem)(Trigger.old[i])).ListPrice ) {
                newProdPedidoItems.add((OrderItem)Trigger.new[i]);
            }
        }
        
        OrderItemHelper.atribuirParametros(newProdPedidoItems);

    }

}