public with sharing class OrderTriggerHandler extends TriggerHandler {

    public override void beforeInsert() {

        for (Order iNewOrder : (List<Order>)Trigger.new) {
            if (!iNewOrder.IntegratedIn__c) {
                iNewOrder.Status = 'New';
            }
        }

    }

    public override void beforeUpdate() {
        List<Order> newOrders = (List<Order>)Trigger.new;
        List<Order> oldOrders = (List<Order>)Trigger.old;

        Map<Id,Order> newOrdersWithUpdatedAddrOrDistCenter = new Map<Id,Order>();
        Map<Id,Order> ordersSubmittedToApproval = new Map<Id,Order>();
        for (Integer i = 0; i < newOrders.size(); i++) {
            // Pedido estava ativo
            if (oldOrders[i].Status == 'Activated') {
                newOrders[i].addError('O pedido está ativo e não pode ser alterado.');
                continue;
            }

            if (oldOrders[i].Status == 'External' && newOrders[i].Status != 'External') {
                newOrders[i].addError('Não é possível alterar o status de um pedido externo.');
                continue;
            }

            if (oldOrders[i].Status == 'New' && newOrders[i].Status != oldOrders[i].Status && newOrders[i].Status != 'InApproval') {
                newOrders[i].addError('Um pedido novo só pode ter seu status mudado para "em aprovação".');
                continue;
            }

            // Conta do Pedido alterada
            if (newOrders[i].AccountId != oldOrders[i].AccountId) {
                newOrders[i].addError('A conta do pedido não pode ser alterada.');
                continue;
            }

            if (newOrders[i].Status == 'InApproval' && oldOrders[i].Status == 'New') {
                ordersSubmittedToApproval.put(newOrders[i].Id, newOrders[i]);
            }

            // Centro dist. ou endereço alterados - necessário atualizar parâmetros dos itens
            if (!newOrders[i].hasErrors() &&
                    (newOrders[i].AccountAddress__c != oldOrders[i].AccountAddress__c || 
                    newOrders[i].CentroDistribuicao__c != oldOrders[i].CentroDistribuicao__c)) {
                newOrdersWithUpdatedAddrOrDistCenter.put(newOrders[i].Id, newOrders[i]);
                continue;
            }
        }

        OrderHelper.validateApprovalSubmission(ordersSubmittedToApproval);
        OrderHelper.assignParametersToItemsOnUpdateOrder(newOrdersWithUpdatedAddrOrDistCenter);

    }

    public override void afterUpdate() {
        List<Order> newOrders = (List<Order>)Trigger.new;
        List<Order> oldOrders = (List<Order>)Trigger.old;

        Set<Id> orderIdsForUpdateIntegrationStatus = new Set<Id>();

        for (Integer i = 0; i < newOrders.size(); i++) {
            if (newOrders[i].IntegrationLogOutbound__c != oldOrders[i].IntegrationLogOutbound__c) {
                orderIdsForUpdateIntegrationStatus.add(newOrders[i].Id);
            }
        }

        OrderHelper.updateIntegrationStatus(orderIdsForUpdateIntegrationStatus);
    }

    public override void afterInsert() {
    }
    
}