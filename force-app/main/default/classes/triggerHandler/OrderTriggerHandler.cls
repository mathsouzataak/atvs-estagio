public with sharing class OrderTriggerHandler extends TriggerHandler {

    public override void beforeUpdate() {
        if (Trigger.new == null || Trigger.new.isEmpty()) {
            return;
        }

        List<Order> newOrders = (List<Order>)Trigger.new;
        List<Order> oldOrders = (List<Order>)Trigger.old;

        Map<Id,Order> newOrdersWithUpdatedAddrOrDistCenter = new Map<Id,Order>();
        for (Integer i = 0; i < newOrders.size(); i++) {
            // Pedido estava ativo
            if (oldOrders[i].Status == 'Activated') {
                newOrders[i].addError('O pedido está ativo e não pode ser alterado.');
                continue;
            }

            // Conta do Pedido alterada
            if (newOrders[i].AccountId != oldOrders[i].AccountId) {
                newOrders[i].addError('A conta do pedido não pode ser alterada.');
                continue;
            }


            // Centro dist. ou endereço alterados - necessário atualizar parâmetros dos itens
            if (!newOrders[i].hasErrors() &&
                    (newOrders[i].AccountAddress__c != oldOrders[i].AccountAddress__c || 
                    newOrders[i].CentroDistribuicao__c != oldOrders[i].CentroDistribuicao__c)) {
                newOrdersWithUpdatedAddrOrDistCenter.put(newOrders[i].Id, newOrders[i]);
                continue;
            }
        }

        OrderHelper.assignParametersToItemsOnUpdateOrder(newOrdersWithUpdatedAddrOrDistCenter);

    }
    
}