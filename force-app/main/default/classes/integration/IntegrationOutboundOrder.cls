public with sharing class IntegrationOutboundOrder {

    public static String postOrder(Id orderId) {
        Order order = [SELECT Id, ExternalId__c, Account.ExternalId__c, AccountAddress__r.Code__c, CentroDistribuicao__r.Code__c, 
                            DataEntrega__c, Observacao__c, EffectiveDate, Pricebook2.ExternalId__c, Status, TipoFrete__c, CondicaoPagamento__r.Codigo__c, 
                            (SELECT Id, ExternalId__c, Quantity, UnitPrice, Product2.ExternalId__c, PricebookEntry.ExternalId__c FROM OrderItems)
                        FROM Order
                        WHERE Id = :orderId
                        LIMIT 1];

        return postOrder(order);
    }
    
    public static String postOrder(Order order) {

        System.debug('Order: ' + order?.toString());

        DataIntegrationFields.Request requestBody = new DataIntegrationFields.Request(
            new DataIntegrationFields.OrderParameters(order)
        );

        System.debug('Request Body: ');
        System.debug(JSON.serialize(requestBody));

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:ExternalOrg/services/apexrest/upsertOneOrder');
        request.setMethod('POST');
        request.setBody(JSON.serialize(requestBody));

        HttpResponse response = http.send(request);

        return response.getBody();
    }

    public static String postOrders(Set<Id> orderIds) {

        if (orderIds.isEmpty()) {

        }

        List<Order> orders = [SELECT Id, ExternalId__c, Account.ExternalId__c, AccountAddress__r.Code__c, CentroDistribuicao__r.Code__c, 
                                    DataEntrega__c, Observacao__c, EffectiveDate, Pricebook2.ExternalId__c, Status, TipoFrete__c, CondicaoPagamento__r.Codigo__c, 
                                    (SELECT Id, ExternalId__c, Quantity, UnitPrice, Product2.ExternalId__c, PricebookEntry.ExternalId__c FROM OrderItems)
                                FROM Order
                                WHERE Id IN :orderIds];

        return postOrders(orders);
    }

    public static String postOrders(List<Order> orders) {

        List<DataIntegrationFields.OrderParameters> orderParametersList = new List<DataIntegrationFields.OrderParameters>();
        for (Order order : orders) {
            orderParametersList.add(new DataIntegrationFields.OrderParameters(order));
        }

        DataIntegrationFields.RequestList requestBody = new DataIntegrationFields.RequestList(
            orderParametersList
        );

        System.debug('Request Body: ');
        System.debug(JSON.serialize(requestBody));

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:ExternalOrg/services/apexrest/upsertOrder');
        request.setMethod('POST');
        request.setBody(JSON.serialize(requestBody));


        HttpResponse response = http.send(request);

        return response.getBody();
    }

}