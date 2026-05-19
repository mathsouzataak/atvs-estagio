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
        List<String> orderIdListForIntegration = new List<String>();

        List<Order> ordersToApprove = new List<Order>();

        for (Order iOrder : (List<Order>)Trigger.new) {
            if (iOrder.IntegratedOut__c) {
                orderIdListForIntegration.add(iOrder.Id);
            }

            if (iOrder.Status == 'InApproval') {
                Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
                request.setComments('Solicitação de aprovação automática.');
                request.setObjectId(iOrder.Id);
                request.setProcessDefinitionNameOrId('OrderApproval');

                Approval.process(request);

            }
        }

        Database.update(ordersToApprove);

        // if (!orderIdListForIntegration.isEmpty()){
        //     System.enqueueJob(new AsyncCalloutOrder(orderIdListForIntegration));
        // }
    }

    public override void afterInsert() {
        List<String> orderIdListForIntegration = new List<String>();
        for (Order order : (List<Order>)Trigger.new) {
            if (order.IntegratedOut__c) {
                orderIdListForIntegration.add(order.Id);
            }
        }

        // if (!orderIdListForIntegration.isEmpty()){
        //     System.enqueueJob(new AsyncCalloutOrder(orderIdListForIntegration));
        // }
    }
    
}