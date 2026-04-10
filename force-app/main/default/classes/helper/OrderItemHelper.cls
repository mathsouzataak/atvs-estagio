public with sharing class OrderItemHelper {
    
    public static void searchAndAssignParameters(List<OrderItem> items) {

        Set<Id> productIds = new Set<Id>();
        Set<Id> orderIds = new Set<Id>();
        for (OrderItem item : items) {
            productIds.add(item.Product2Id);
            orderIds.add(item.OrderId);
        }

        // Busca dos atributos relevantes dos pedidos relacionados
        Map<Id,Order> mapOrder = new Map<Id,Order>();
        Set<Id> cityIds = new Set<Id>();
        Set<Id> stateIds = new Set<Id>();
        Set<Id> countryIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> accountGroupIds = new Set<Id>();
        Set<Id> distCenterIds = new Set<Id>();
        for (Order order : OrderHelper.queryOrdersWithIds(orderIds)) {
            mapOrder.put(order.Id, order);
            cityIds.add(order.AccountAddress__r.Cidade__c);
            stateIds.add(order.AccountAddress__r.Cidade__r.Estado__c);
            countryIds.add(order.AccountAddress__r.Cidade__r.Estado__r.Pais__c);
            accountIds.add(order.AccountId);
            accountGroupIds.add(order.Account.AccountGroup__c);
            distCenterIds.add(order.CentroDistribuicao__c);
        }

        // Busca dos atributos relevantes dos produtos relacionados
        Map<Id,Product2> mapProduct = new Map<Id,Product2>();
        Set<Id> prodHierarchyIds = new Set<Id>();
        for (Product2 product : ProductHelper.queryProductsWithIds(productIds)) {
            mapProduct.put(product.Id, product);
            prodHierarchyIds.add(product.HierarquiaProduto__c);
        }

        // Busca dos parâmetros de preço correspondentes aos atributos
        Map<String, Imposto__c> mapStringKeyXTax = ImpostoHelper.getMapStringKeyXTax(ImpostoHelper.queryApprovedTaxesWithFields(cityIds, productIds, distCenterIds));
        Map<String, Frete__c> mapStringKeyXFreight = FreteHelper.getMapStringKeyXFreight(FreteHelper.queryApprovedFreightsWithFields(cityIds, stateIds, countryIds, productIds, prodHierarchyIds, distCenterIds));
        Map<String, Margem__c> mapStringKeyXMargin = MargemHelper.getMapStringKeyXMargin(MargemHelper.queryApprovedMarginWithFields(cityIds, stateIds, countryIds, productIds, prodHierarchyIds, accountIds, accountGroupIds, distCenterIds));

        // Atribuição dos parâmetros correspondentes aos fretes
        Set<OrderItem> itemsWithError = PricingHelper.assignParameters(items, mapStringKeyXTax, mapStringKeyXFreight, mapStringKeyXMargin, mapOrder, mapProduct);

        // Atribuição de erros de DML aos itens com erros
        for (OrderItem item : itemsWithError) {
            item.addError('Não está autorizada a venda deste produto devido à falta de parâmetros. Contate o time de Pricing');
        }
    }


    public static List<OrderItem> queryOrderItemsWithOrderIds(Set<Id> idsOrder) {
        return [SELECT Id, OrderId, ListPrice, ValorFrete__c, Product2Id, Product2.HierarquiaProduto__c
                FROM OrderItem
                WHERE OrderId IN :idsOrder];
    }
    
}