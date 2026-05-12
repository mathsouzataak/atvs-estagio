Set<String> ids = new Set<String>{'qwerty32535432789', 'qwerty3243566'};

List<Order> orders = [SELECT Id, ExternalId__c, Account.ExternalId__c, AccountAddress__r.Code__c, CentroDistribuicao__r.Code__c, 
                            DataEntrega__c, Observacao__c, EffectiveDate, Pricebook2.ExternalId__c, Status, TipoFrete__c, CondicaoPagamento__r.Codigo__c, 
                            (SELECT Id, ExternalId__c, Quantity, UnitPrice, Product2.ExternalId__c, PricebookEntry.ExternalId__c FROM OrderItems)
                        FROM Order
                        WHERE ExternalId__c IN :ids
                        LIMIT 2];

orders[0].Observacao__c = 'VERBUM CARO FACTUM EST';
orders[1].Observacao__c = 'ET HABITAVUNT IN NOBIS';

//String response = IntegrationOutboundOrder.postOrders(orders);

DataIntegrationFields.CalloutResponse response = CalloutOrder.executeCalloutOrder(new List<String>{orders[0].Id, orders[1].Id});

System.debug('Response: ' + response?.toString());