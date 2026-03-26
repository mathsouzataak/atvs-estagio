public with sharing class OrderItemHelper {
    
    public static void atribuirParametros(List<OrderItem> itens) {

        Set<Id> idsProduto = new Set<Id>();
        Set<Id> idsPedido = new Set<Id>();
        for (OrderItem item : itens) {
            idsProduto.add(item.Product2Id);
            idsPedido.add(item.OrderId);
        }

        Map<Id,Order> mapPedido = new Map<Id,Order>();
        Set<Id> idsCidade = new Set<Id>();
        Set<Id> idsEstado = new Set<Id>();
        Set<Id> idsPais = new Set<Id>();
        Set<Id> idsConta = new Set<Id>();
        Set<Id> idsGrupoConta = new Set<Id>();
        for (Order pedido : queryPedidoComIds(idsPedido)) {
            mapPedido.put(pedido.Id, pedido);
            idsCidade.add(pedido.AccountAddress__r.Cidade__c);
            idsEstado.add(pedido.AccountAddress__r.Cidade__r.Estado__c);
            idsPais.add(pedido.AccountAddress__r.Cidade__r.Estado__r.Pais__c);
            idsConta.add(pedido.AccountId);
            idsGrupoConta.add(pedido.Account.GrupoClientes__c);
        }

        Map<Id,Product2> mapProduto = new Map<Id,Product2>();
        Set<Id> idsHierarquia = new Set<Id>();
        for (Product2 produto : queryProdutoComIds(idsProduto)) {
            mapProduto.put(produto.Id, produto);
            idsHierarquia.add(produto.HierarquiaProduto__c);
        }

        Map<String, Imposto__c> mapLocPropXImposto = getMapLocProdXImposto(queryImpostoFromEstadosProdutos(idsEstado, idsProduto));
        Map<String, Frete__c> mapLocProdXFrete = getMapLocProdXFrete(queryFreteFromLocProd(idsCidade, idsEstado, idsPais, idsProduto, idsHierarquia));

        atribuirImposto(itens, mapLocPropXImposto, mapPedido);
        atribuirFrete(itens, mapLocProdXFrete, mapPedido, mapProduto);
    }


    
    public static void atribuirImposto(List<OrderItem> itens, Map<String, Imposto__c> mapLocPropXImposto, Map<Id,Order> mapPedido) {
        for (OrderItem item : itens) {
            Imposto__c impostoAplicado = mapLocPropXImposto.get(KeyStringGenerator.createStringFromKeys(
                mapPedido.get(item.OrderId).AccountAddress__r.Cidade__r.Estado__c, 
                item.Product2Id
            ));
            
            if (impostoAplicado != null) {
                item.ImpostoPercent__c = impostoAplicado.ValorPercentual__c;
            } else { // Não foi encontrado imposto correspondente
                item.addError('O produto não possui imposto aplicável no estado do pedido.');
            }
        }
    }
    
    public static void atribuirFrete(List<OrderItem> itens, Map<String, Frete__c> mapLocProdXFrete, Map<Id,Order> mapPedido, Map<Id,Product2> mapProduto) {
        for (OrderItem item : itens) {
            Frete__c freteAplicado = getFreteAplicavel(mapLocProdXFrete, mapProduto.get(item.Product2Id), mapPedido.get(item.OrderId).AccountAddress__r.Cidade__r);

            if (freteAplicado != null) {
                item.ValorFrete__c = freteAplicado.Valor__c;
            } else {
                item.addError('O produto não possui frete aplicável para a localidade do pedido.');
            }
        }
    }

    public static Map<String, Frete__c> getMapLocProdXFrete(List<Frete__c> fretes) {
        Map<String, Frete__c> mapLocProdXFrete = new Map<String, Frete__c>();
        for (Frete__c frete : fretes) {
            Id idLocalidade = FreteHelper.getLocalidadeId(frete);
            Id idProduto = FreteHelper.getProdutoId(frete);
            mapLocProdXFrete.put(KeyStringGenerator.createStringFromKeys(idLocalidade, idProduto), frete);
        }

        return mapLocProdXFrete;
    }

    public static Map<String, Imposto__c> getMapLocProdXImposto(List<Imposto__c> impostos) {
        Map<String, Imposto__c> mapLocPropXImposto = new Map<String,Imposto__c>();
        for (Imposto__c imposto : impostos) {
            mapLocPropXImposto.put(KeyStringGenerator.createStringFromKeys(imposto.Estado__c, imposto.Product__c), imposto);
        }

        return mapLocPropXImposto;
    }

    




    
    private static List<Imposto__c> queryImpostoFromEstadosProdutos(Set<Id> idsEstado, Set<Id> idsProduto) {
        return [SELECT Id, Estado__c, Product__c, ValorPercentual__c 
                    FROM Imposto__c 
                    WHERE (Status__c = 'Aprovado' AND Estado__c IN :idsEstado AND Product__c IN :idsProduto)];
    }

    private static List<Frete__c> queryFreteFromLocProd(Set<Id> idsCidade, Set<Id> idsEstado, Set<Id> idsPais, Set<Id> idsProduto, Set<Id> idsHierarquia) {
        return [SELECT Id, Cidade__c, Estado__c, Pais__c, Product__c, HierarquiaProduto__c, Valor__c, CreatedDate 
                FROM Frete__c 
                WHERE (Status__c = 'Aprovado' AND 
                    (Cidade__c IN :idsCidade OR Estado__c IN :idsEstado OR Pais__c IN :idsPais) AND 
                    (Product__c IN :idsProduto OR HierarquiaProduto__c IN :idsHierarquia))];
    }

    private static List<Order> queryPedidoComIds(Set<Id> ids) {
        return [SELECT Id, AccountAddress__c, AccountId 
                FROM Order 
                WHERE Id IN :ids];
    }

    private static List<Product2> queryProdutoComIds(Set<Id> ids) {
        return [SELECT Id, HierarquiaProduto__c
                FROM Product2
                WHERE Id IN :ids];
    }
    
    private static Frete__c getFreteAplicavel(Map<String,Frete__c> mapaFretes, Product2 produto, Cidade__c cidade) {
        Frete__c freteAplicavel;
        
        if (mapaFretes.containsKey(KeyStringGenerator.createStringFromKeys(produto.Id, cidade.Id))) {
            return mapaFretes.get(KeyStringGenerator.createStringFromKeys(produto.Id, cidade.Id));
        }
        
        if (mapaFretes.containsKey(KeyStringGenerator.createStringFromKeys(produto.Id, cidade.Estado__c))) {
            return mapaFretes.get(KeyStringGenerator.createStringFromKeys(produto.Id, cidade.Estado__c));
        }
        
        if (mapaFretes.containsKey(KeyStringGenerator.createStringFromKeys(produto.Id, cidade.Estado__r.Pais__c))) {
            return mapaFretes.get(KeyStringGenerator.createStringFromKeys(produto.Id, cidade.Estado__r.Pais__c));
        }
        
        if (mapaFretes.containsKey(KeyStringGenerator.createStringFromKeys(produto.HierarquiaProduto__c, cidade.Id))) {
            return mapaFretes.get(KeyStringGenerator.createStringFromKeys(produto.HierarquiaProduto__c, cidade.Id));
        }
        
        if (mapaFretes.containsKey(KeyStringGenerator.createStringFromKeys(produto.HierarquiaProduto__c, cidade.Estado__c))) {
            return mapaFretes.get(KeyStringGenerator.createStringFromKeys(produto.HierarquiaProduto__c, cidade.Estado__c));
        }
        
        if (mapaFretes.containsKey(KeyStringGenerator.createStringFromKeys(produto.HierarquiaProduto__c, cidade.Estado__r.Pais__c))) {
            return mapaFretes.get(KeyStringGenerator.createStringFromKeys(produto.HierarquiaProduto__c, cidade.Estado__r.Pais__c));
        }
        
        return null;
    }
    
}