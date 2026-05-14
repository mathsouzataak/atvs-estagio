Set<String> ids = new Set<String>{'qwerty32535432789', 'qwerty3243566'};

Order order = [SELECT Id, ExternalId__c, Account.ExternalId__c, AccountAddress__r.Code__c, CentroDistribuicao__r.Code__c, 
                    DataEntrega__c, Observacao__c, EffectiveDate, Pricebook2.ExternalId__c, Status, TipoFrete__c, CondicaoPagamento__r.Codigo__c, 
                    (SELECT Id, ExternalId__c, Quantity, UnitPrice, Product2.ExternalId__c, PricebookEntry.ExternalId__c FROM OrderItems)
                FROM Order
                WHERE Id = '801g700000JFAQjAAP'
                LIMIT 1];

System.debug(order);
System.debug(order.OrderItems);

//String response = IntegrationOutboundOrder.postOrders(orders);

DataIntegrationFields.CalloutResponse response = CalloutOrder.executeCalloutOrder(new List<String>{order.Id});

System.debug('Response: ' + response?.toString());