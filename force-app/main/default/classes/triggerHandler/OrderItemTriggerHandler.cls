public with sharing class OrderItemTriggerHandler extends TriggerHandler {

    public override void beforeInsert() {
        if (Trigger.new == null || Trigger.new.isEmpty()) {
            return;
        }

        OrderItemHelper.atribuirImposto(Trigger.new);
    }

    public override void beforeUpdate() {
        if (Trigger.new == null || Trigger.new.isEmpty()) {
            return;
        }

        List<OrderItem> newProduto = new List<OrderItem>();
        for (Integer i = 0; i < Trigger.new.size(); i++) {
            if (((OrderItem)(Trigger.new[i])).Product2Id != ((OrderItem)(Trigger.old[i])).Product2Id) {
                newProduto.add((OrderItem)Trigger.new[i]);
            }
        }
        OrderItemHelper.atribuirImposto(newProduto);
    }

}