public with sharing class OrderTriggerHandler extends TriggerHandler {

    public override void beforeUpdate() {
        if (Trigger.new == null || Trigger.new.isEmpty()) {
            return;
        }

        List<Order> newPedidos = (List<Order>)Trigger.new;
        List<Order> oldPedidos = (List<Order>)Trigger.old;

        Map<Id,Order> newEnderecoPedido = new Map<Id,Order>();
        for (Integer i = 0; i < newPedidos.size(); i++) {
            if (oldPedidos[i].Status == 'Activated') {
                newPedidos[i].addError('O pedido está ativo e não pode ser alterado.');
                continue;
            }

            if (newPedidos[i].AccountId != oldPedidos[i].AccountId) {
                newPedidos[i].addError('A conta do pedido não pode ser alterada.');
                continue;
            }
        }
    }
    
}