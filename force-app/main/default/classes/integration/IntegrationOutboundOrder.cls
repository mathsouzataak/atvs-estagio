public with sharing class IntegrationOutboundOrder {
    
    public String postOrder(Id orderId) {
        Order order = [SELECT Id, ExternalId__c, Account.ExternalId__c, AccountAddress__r.Code__c, CentroDistribuicao__r.Code__c, 
                            DataEntrega__c, Observacao__c, EffectiveDate, Pricebook2.ExternalId__c, Status, TipoFrete__c, CondicaoPagamento__r.Codigo__c, 
                            (SELECT Id, ExternalId__c, Quantity, UnitPrice, Product2.ExternalId__c, PricebookEntry.ExternalId__c FROM OrderItems)
                        FROM Order
                        WHERE Id = :orderId
                        LIMIT 1];

        Http http = new Http();

        Map<String, Object> requestBody = new Map<String,Object>{
            'orderRequest' => new Map<String, Object>{
                'externalId' => order.ExternalId__c,
                'status' => order.Status,
                'effectiveDate' => order.EffectiveDate,
                'accountExternalId' => order.Account.ExternalId__c,
                'pricebook2ExternalId' => order.Pricebook2.ExternalId__c,
                'addressCode' => order.AccountAddress__r.Code__c,
                'distCenterCode' => order.CentroDistribuicao__r.Code__c,
                'paymentConditionCode' => order.CondicaoPagamento__r.Codigo__c,
                'deliveryDate' => order.DataEntrega__c,
                'observation' => order.Observacao__c,
                'freightType' => order.TipoFrete__c
            }
        };

        if (!order.OrderItems.isEmpty()) {
            List<Map<String,Object>> orderItemsJson = new List<Map<String,Object>>();

            for (OrderItem orderItem : order.OrderItems) {
                orderItemsJson.add(
                    new Map<String, Object>{
                        'externalId' => orderItem.ExternalId__c,
                        'quantity' => orderItem.Quantity,
                        'unitPrice' => orderItem.UnitPrice,
                        'productExternalId' => orderItem.Product2.ExternalId__c,
                        'pricebookEntryExternalId' => orderItem.PricebookEntry.ExternalId__c
                    }
                );
            }

            requestBody.put('orderItemList', orderItemsJson);
        }

        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:ExternalOrg/services/apexrest/upsertOneOrder');
        request.setMethod('POST');
        request.setBody(JSON.serialize(requestBody));


        HttpResponse response = http.send(request);

        return response.getBody();
    }

}