public with sharing class OrderHelper {
    
    public static void assignParametersToItemsOnUpdateOrder(Map<Id,Order> mapNewOrders) {

        Set<Id> addressIds = new Set<Id>();
        Set<Id> distCenterIds = new Set<Id>();
        for (Order pedido : mapNewOrders.values()) {
            addressIds.add(pedido.AccountAddress__c);
            distCenterIds.add(pedido.CentroDistribuicao__c);
        }

        // Busca dos endereços dos pedidos atualizados
        Map <Id, AccountAddress__c> mapAddress = new Map<Id,AccountAddress__c>();
        Set<Id> cityIds = new Set<Id>();
        Set<Id> stateIds = new Set<Id>();
        Set<Id> countryIds = new Set<Id>();
        for (AccountAddress__c address : [SELECT Id, Cidade__c, Cidade__r.Estado__c, Cidade__r.Estado__r.Pais__c
                                            FROM AccountAddress__c
                                            WHERE Id IN :addressIds]) {
            mapAddress.put(address.Id, address);
            cityIds.add(address.Cidade__c);
            stateIds.add(address.Cidade__r.Estado__c);
            countryIds.add(address.Cidade__r.Estado__r.Pais__c);
        }

        // Busca dos pedidos e seus atributos relevantes, trocando os atributos alterados nesta operação
        Map<Id, Order> mapOrder = new Map<Id,Order>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> accountGroupIds = new Set<Id>();
        for (Order order : queryOrdersWithIds(mapNewOrders.keySet())) {
            order.AccountAddress__c = mapNewOrders.get(order.Id).AccountAddress__c;
            order.AccountAddress__r = mapAddress.get(mapNewOrders.get(order.Id).AccountAddress__c);
            order.CentroDistribuicao__c = mapNewOrders.get(order.Id).CentroDistribuicao__c;
            mapOrder.put(order.Id, order);
            accountIds.add(order.AccountId);
            accountGroupIds.add(order.Account.AccountGroup__c);
        }

        // Busca dos itens de pedido e seus produtos para alteração
        Map<Id, OrderItem> mapOrderItem = new map<Id,OrderItem>();
        Map<Id,Product2> mapProduct = new Map<Id,Product2>();
        Set<Id> productIds = new Set<Id>();
        Set<Id> prodHierarchyIds = new Set<Id>();
        for (OrderItem item : OrderItemHelper.queryOrderItemsWithOrderIds(mapNewOrders.keySet())) {
            mapOrderItem.put(item.Id, item);
            mapProduct.put(item.Product2Id, item.Product2);
            productIds.add(item.Product2Id);
            prodHierarchyIds.add(item.Product2.HierarquiaProduto__c);
        }

        // Busca dos parâmetros de preço correspondentes aos atributos
        Map<String, Imposto__c> mapStringKeyXTax = ImpostoHelper.getMapStringKeyXTax(ImpostoHelper.queryImpostoAprovadoComParametros(stateIds, productIds, distCenterIds));
        Map<String, Frete__c> mapStringKeyXFreight = FreteHelper.getMapStringKeyXFreight(FreteHelper.queryApprovedFreightsWithFields(cityIds, stateIds, countryIds, productIds, prodHierarchyIds, distCenterIds));
        Map<String, Margem__c> mapStringKeyXMargin = MargemHelper.getMapStringKeyXMargin(MargemHelper.queryApprovedMarginWithFields(cityIds, stateIds, countryIds, productIds, prodHierarchyIds, accountIds, accountGroupIds, distCenterIds));

        // Atribuição dos parâmetros correspondentes aos fretes
        Set<OrderItem> itemsWithError = PricingHelper.assignParameters(mapOrderItem.values(), mapStringKeyXTax, mapStringKeyXFreight, mapStringKeyXMargin, mapOrder, mapProduct);

        // Filtragem dos Order e OrderItem com erros
        filterErrors(mapNewOrders, mapOrderItem, itemsWithError);
        
        // Fazer update dos itens dos pedidos atualizados, ignorando a trigger padrão do item
        TriggerHandler.bypass('OrderItemTriggerHandler');
        Database.update(mapOrderItem.values(), false);
        TriggerHandler.clearBypass('OrderItemTriggerHandler');
    }


    private static void filterErrors(Map<Id,Order> mapOrder, Map<Id,OrderItem> mapOrderItem, Set<OrderItem> itemsWithError) {
        for (OrderItem item : mapOrderItem.values()) {
            // Se o item tem erro, adicionar erro ao seu pedido
            if (itemsWithError.contains(item) && !mapOrder.get(item.OrderId).hasErrors()) {
                mapOrder.get(item.OrderId).addError('Esta alteração foi abortada, pois algum dos itens ficaria sem parâmetros de precificação.');
            }            
        }
        
        for (OrderItem item : mapOrderItem.values()) {
            // Se o pedido do item contém erro, adicionar item aos itens com erro
            if (mapOrder.get(item.OrderId).hasErrors() && !itemsWithError.contains(item)) {
                itemsWithError.add(item);
            }
        }

        // Remover itens com erro dentre os itens para update
        for (OrderItem item : itemsWithError) {
            mapOrderItem.remove(item.Id);
        }
    }


    public static List<Order> queryOrdersWithIds(Set<Id> ids) {
        return [SELECT Id, 
                AccountAddress__r.Cidade__c, AccountAddress__r.Cidade__r.Id, AccountAddress__r.Cidade__r.Estado__c, AccountAddress__r.Cidade__r.Estado__r.Pais__c, 
                AccountId, Account.AccountGroup__c, 
                CentroDistribuicao__c
                FROM Order 
                WHERE Id IN :ids];
    }
}