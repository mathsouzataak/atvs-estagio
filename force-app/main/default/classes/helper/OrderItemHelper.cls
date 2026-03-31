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
        set<Id> idsCentroDist = new Set<Id>();
        for (Order pedido : OrderHelper.queryPedidoComIds(idsPedido)) {
            mapPedido.put(pedido.Id, pedido);
            idsCidade.add(pedido.AccountAddress__r.Cidade__c);
            idsEstado.add(pedido.AccountAddress__r.Cidade__r.Estado__c);
            idsPais.add(pedido.AccountAddress__r.Cidade__r.Estado__r.Pais__c);
            idsConta.add(pedido.AccountId);
            idsGrupoConta.add(pedido.Account.AccountGroup__c);
            idsCentroDist.add(pedido.CentroDistribuicao__c);
        }

        Map<Id,Product2> mapProduto = new Map<Id,Product2>();
        Set<Id> idsHierarquia = new Set<Id>();
        for (Product2 produto : ProductHelper.queryProdutoComIds(idsProduto)) {
            mapProduto.put(produto.Id, produto);
            idsHierarquia.add(produto.HierarquiaProduto__c);
        }

        Map<String, Imposto__c> mapLocPropXImposto = ImpostoHelper.getMapLocProdXImposto(ImpostoHelper.queryImpostoComEstadoProd(idsEstado, idsProduto));
        atribuirImposto(itens, mapLocPropXImposto, mapPedido);

        Map<String, Frete__c> mapLocProdCdXFrete = FreteHelper.getmapLocProdCdXFrete(FreteHelper.queryFreteComLocProdCD(idsCidade, idsEstado, idsPais, idsProduto, idsHierarquia, idsCentroDist));
        atribuirFrete(itens, mapLocProdCdXFrete, mapPedido, mapProduto);

        Map<String, Margem__c> mapLocProdAccXMargem = MargemHelper.getMapLocProdAccXMargem(MargemHelper.queryMargemComLocProdAcc(idsCidade, idsEstado, idsPais, idsProduto, idsHierarquia, idsConta, idsGrupoConta));
        atribuirMargem(itens, mapLocProdAccXMargem, mapPedido, mapProduto);

    }


    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // Atribuição dos valores dos componentes de preço aos produtos do pedido
    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    public static void atribuirImposto(List<OrderItem> itens, Map<String, Imposto__c> mapLocPropXImposto, Map<Id,Order> mapPedido) {
        for (OrderItem item : itens) {
            if (item.hasErrors()) {
                continue;
            }

            Imposto__c impostoAplicado = mapLocPropXImposto.get(KeyStringGenerator.createStringKeyFromIds(
                mapPedido.get(item.OrderId).AccountAddress__r.Cidade__r.Estado__c, 
                item.Product2Id
            ));
            
            if (impostoAplicado != null) {
                item.ImpostoPercent__c = impostoAplicado.ValorPercentual__c;
            } else { // Não foi encontrado imposto correspondente
                item.addError('Não está autorizada a venda deste produto devido à falta de parâmetros. Contate o time de Pricing.');
            }
        }
    }
    
    public static void atribuirFrete(List<OrderItem> itens, Map<String, Frete__c> mapLocProdCdXFrete, Map<Id,Order> mapPedido, Map<Id,Product2> mapProduto) {
        for (OrderItem item : itens) {
            if (item.hasErrors()) {
                continue;
            }

            Frete__c freteAplicado = getFreteAplicavel(mapLocProdCdXFrete, mapProduto.get(item.Product2Id), mapPedido.get(item.OrderId).AccountAddress__r.Cidade__r, mapPedido.get(item.OrderId).CentroDistribuicao__c);

            if (freteAplicado != null) {
                item.ValorFrete__c = freteAplicado.Valor__c;
            } else {
                item.addError('Não está autorizada a venda deste produto devido à falta de parâmetros. Contate o time de Pricing.');
            }
        }
    }

    public static void atribuirMargem(List<OrderItem> itens, Map<String, Margem__c> mapLocProdAccXMargem, Map<Id,Order> mapPedido, Map<Id,Product2> mapProduto) {
        for (OrderItem item : itens) {
            if (item.hasErrors()) {
                continue;
            }

            Margem__c margemAplicada = getMargemAplicavel(mapLocProdAccXMargem, mapProduto.get(item.Product2Id), mapPedido.get(item.OrderId).AccountAddress__r.Cidade__r, mapPedido.get(item.OrderId).Account);

            if (margemAplicada != null) {
                if (item.ListPrice > 0 || item.ValorFrete__c > 0 || item.ImpostoPercent__c > 0) {
                    item.MargemPercent__c = 100 * margemAplicada.Valor__c / ((item.ListPrice + item.ValorFrete__c )*(1+ item.ImpostoPercent__c / 100));
                }
            } else {
                item.addError('Não está autorizada a venda deste produto devido à falta de parâmetros. Contate o time de Pricing.');
            }
        }
    }


    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // Busca pelo componente de precificação que mmelhor corresponda aos
    // paraâmetros fornecidos
    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    private static Frete__c getFreteAplicavel(Map<String,Frete__c> mapaFrete, Product2 produto, Cidade__c cidade, Id centroDist) {
        Frete__c freteAplicavel;

        for (Integer generalidadeProduto = 0; generalidadeProduto < 2; generalidadeProduto++) {
            for (Integer generalidadeLoc = 0; generalidadeLoc < 3; generalidadeLoc++) {
                Id prod = generalidadeProduto == 0 ? produto.Id : produto.HierarquiaProduto__c;
                Id loc = generalidadeLoc == 0 ? cidade.Id : (generalidadeLoc == 1 ? cidade.Estado__c : cidade.Estado__r.Pais__c);

                freteAplicavel = mapaFrete.get(KeyStringGenerator.createStringKeyFromIds(loc, prod, centroDist));

                if (freteAplicavel != null) {
                    return freteAplicavel;
                }
            }
        }
        
        return null;
    }

    private static Margem__c getMargemAplicavel(Map<String,Margem__c> mapaMargem, Product2 produto, Cidade__c cidade, Account conta) {
        Margem__c margemAplicavel;

        for (Integer generalidadeProduto = 0; generalidadeProduto < 2; generalidadeProduto++) {
            for (Integer generalidadeAcc = 0; generalidadeAcc < 2; generalidadeAcc++) {
                for (Integer generalidadeLoc = 0; generalidadeLoc < 3; generalidadeLoc++) {
                    Id prod = generalidadeProduto == 0 ? produto.Id : produto.HierarquiaProduto__c;
                    Id loc = generalidadeLoc == 0 ? cidade.Id : generalidadeLoc == 1 ? cidade.Estado__c : cidade.Estado__r.Pais__c;
                    Id acc = generalidadeAcc == 0 ? conta.Id : conta.AccountGroup__c;

                    margemAplicavel = mapaMargem.get(KeyStringGenerator.createStringKeyFromIds(loc, prod, acc));

                    if (margemAplicavel != null) {
                        return margemAplicavel;
                    }
                }
            }
        }
        
        return null;
    }
    
}