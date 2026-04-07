public with sharing class OrderTriggerHandler extends TriggerHandler {

    public override void beforeUpdate() {
        if (Trigger.new == null || Trigger.new.isEmpty()) {
            return;
        }

        List<Order> newPedidos = (List<Order>)Trigger.new;
        List<Order> oldPedidos = (List<Order>)Trigger.old;

        Map<Id,Order> newAddrCdPedido = new Map<Id,Order>();
        for (Integer i = 0; i < newPedidos.size(); i++) {
            // Pedido estava ativo
            if (oldPedidos[i].Status == 'Activated') {
                newPedidos[i].addError('O pedido está ativo e não pode ser alterado.');
                continue;
            }

            // Conta do Pedido alterada
            if (newPedidos[i].AccountId != oldPedidos[i].AccountId) {
                newPedidos[i].addError('A conta do pedido não pode ser alterada.');
                continue;
            }


            // Centro dist. ou endereço alterados - necessário atualizar parâmetros dos itens
            if (!newPedidos[i].hasErrors() &&
                    (newPedidos[i].AccountAddress__c != oldPedidos[i].AccountAddress__c || 
                    newPedidos[i].CentroDistribuicao__c != oldPedidos[i].CentroDistribuicao__c)) {
                newAddrCdPedido.put(newPedidos[i].Id, newPedidos[i]);
                continue;
            }
        }

        OrderHelper.atribuirParametrosOnUpdateAccount(newAddrCdPedido);

    }
    
}