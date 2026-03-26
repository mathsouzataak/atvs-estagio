public with sharing class OrderItemHelper {
    
    public static void atribuirParametros(List<OrderItem> itens) {
        atribuirImposto(itens);
        atribuirFrete(itens);
    }


    
    public static void atribuirImposto(List<OrderItem> itens) {
        
        // Sets com ids para query dos produtos e pedidos associados aos novos itens
        Set<Id> idsProdutos = new Set<Id>();
        Set<Id> idsPedidos = new Set<Id>();
        for (OrderItem item : itens) {
            idsProdutos.add(item.Product2Id);
            idsPedidos.add(item.OrderId);
        }
        
        // Map relacionando id dos pedidos com o id do estado do endereço de sua conta
        Map<Id,Order> mapPedido = new Map<Id,Order>();
        Set<Id> idsEstado = new Set<Id>();
        for (Order pedido : [SELECT Id, AccountAddress__c FROM Order WHERE Id IN :idsPedidos]) {
            mapPedido.put(pedido.Id, pedido);
            idsEstado.add(pedido.AccountAddress__r.Cidade__r.Estado__c);
        }
        
        Map<String, Imposto__c> mapLocPropImposto = new Map<String,Imposto__c>();
        for (Imposto__c imposto : queryImpostoFromEstadosProdutos(idsEstado, idsProdutos)) {
            mapLocPropImposto.put(KeyStringGenerator.createStringFromKeys(imposto.Estado__c, imposto.Product__c), imposto);
        }
        
        for (OrderItem item : itens) {
            Imposto__c impostoAplicado = mapLocPropImposto.get(KeyStringGenerator.createStringFromKeys(
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
    
    public static void atribuirFrete(List<OrderItem> itens) {
        // Sets com ids para query dos produtos e pedidos associados aos novos itens
        Set<Id> idsProdutos = new Set<Id>();
        Set<Id> idsPedidos = new Set<Id>();
        for (OrderItem item : itens) {
            idsProdutos.add(item.Product2Id);
            idsPedidos.add(item.OrderId);
        }
        
        // Map relacionando id dos pedidos com a cidade do endereço de sua conta
        Map<Id,Order> mapPedido = new Map<Id,Order>();
        Set<Id> idsCidade = new Set<Id>();
        Set<Id> idsEstado = new Set<Id>();
        Set<Id> idsPais = new Set<Id>();
        for (Order pedido : [SELECT Id, AccountAddress__c FROM Order WHERE Id IN :idsPedidos]) {
            mapPedido.put(pedido.Id, pedido);
            idsCidade.add(pedido.AccountAddress__r.Cidade__c);
            idsEstado.add(pedido.AccountAddress__r.Cidade__r.Estado__c);
            idsPais.add(pedido.AccountAddress__r.Cidade__r.Estado__r.Pais__c);
        }
        
        // Mapa de produtos relacionados aos itens
        Map<Id,Product2> mapProduto = new Map<Id,Product2>();
        Set<Id> idsHierarquias = new Set<Id>();
        for (Product2 produto : [SELECT Id, HierarquiaProduto__c
                                    FROM Product2
                                    WHERE Id IN :idsProdutos]) {
            mapProduto.put(produto.Id, produto);
            idsHierarquias.add(produto.HierarquiaProduto__c);
        }
        
        Map<String, Frete__c> mapLocProdFrete = new Map<String, Frete__c>();
        for (Frete__c frete : queryFreteFromLocalidadesProdutos(idsCidade, idsEstado, idsPais, idsProdutos, idsHierarquias)) {
            Id idLocalidade = FreteHelper.getLocalidadeId(frete);
            Id idProduto = FreteHelper.getProdutoId(frete);
            mapLocProdFrete.put(KeyStringGenerator.createStringFromKeys(idLocalidade, idProduto), frete);
        }
        
        for (OrderItem item : itens) {
            Frete__c freteAplicado = getFreteAplicavel(mapLocProdFrete, mapProduto.get(item.Product2Id), mapPedido.get(item.OrderId).AccountAddress__r.Cidade__r);

            if (freteAplicado != null) {
                item.ValorFrete__c = freteAplicado.Valor__c;
            } else {
                item.addError('O produto não possui frete aplicável para a localidade do pedido.');
            }
        }
    }





    
    private static List<Imposto__c> queryImpostoFromEstadosProdutos(Set<Id> idsEstado, Set<Id> idsProduto) {
        return [SELECT Id, Estado__c, Product__c, ValorPercentual__c 
                    FROM Imposto__c 
                    WHERE (Status__c = 'Aprovado' AND Estado__c IN :idsEstado AND Product__c IN :idsProduto)];
    }

    private static List<Frete__c> queryFreteFromLocalidadesProdutos(Set<Id> idsCidade, Set<Id> idsEstado, Set<Id> idsPais, Set<Id> idsProduto, Set<Id> idsHierarquia) {
        return [SELECT Id, Cidade__c, Estado__c, Pais__c, Product__c, HierarquiaProduto__c, Valor__c, CreatedDate 
                FROM Frete__c 
                WHERE (Status__c = 'Aprovado' AND 
                    (Cidade__c IN :idsCidade OR Estado__c IN :idsEstado OR Pais__c IN :idsPais) AND 
                    (Product__c IN :idsProduto OR HierarquiaProduto__c IN :idsHierarquia))];
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