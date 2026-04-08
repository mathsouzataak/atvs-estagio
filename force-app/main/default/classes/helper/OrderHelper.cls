public with sharing class OrderHelper {
    
    public static void atribuirParametrosOnUpdateAccount(Map<Id,Order> mapNewPedidos) {

        Set<Id> idsEndereco = new Set<Id>();
        Set<Id> idsCentroDist = new Set<Id>();
        for (Order pedido : mapNewPedidos.values()) {
            idsEndereco.add(pedido.AccountAddress__c);
            idsCentroDist.add(pedido.CentroDistribuicao__c);
        }

        // Busca dos endereços dos pedidos atualizados
        Map <Id, AccountAddress__c> mapEndereco = new Map<Id,AccountAddress__c>();
        Set<Id> idsCidade = new Set<Id>();
        Set<Id> idsEstado = new Set<Id>();
        Set<Id> idsPais = new Set<Id>();
        for (AccountAddress__c endereco : [SELECT Id, Cidade__c, Cidade__r.Estado__c, Cidade__r.Estado__r.Pais__c
                                            FROM AccountAddress__c
                                            WHERE Id IN :idsEndereco]) {
            mapEndereco.put(endereco.Id, endereco);
            idsCidade.add(endereco.Cidade__c);
            idsEstado.add(endereco.Cidade__r.Estado__c);
            idsPais.add(endereco.Cidade__r.Estado__r.Pais__c);
        }

        // Busca dos pedidos e seus atributos relevantes, trocando os atributos alterados nesta operação
        Map<Id, Order> mapPedido = new Map<Id,Order>();
        Set<Id> idsConta = new Set<Id>();
        Set<Id> idsGrupoConta = new Set<Id>();
        for (Order pedido : queryPedidoComIds(mapNewPedidos.keySet())) {
            pedido.AccountAddress__c = mapNewPedidos.get(pedido.Id).AccountAddress__c;
            pedido.AccountAddress__r = mapEndereco.get(mapNewPedidos.get(pedido.Id).AccountAddress__c);
            pedido.CentroDistribuicao__c = mapNewPedidos.get(pedido.Id).CentroDistribuicao__c;
            mapPedido.put(pedido.Id, pedido);
            idsConta.add(pedido.AccountId);
            idsGrupoConta.add(pedido.Account.AccountGroup__c);
        }

        // Busca dos itens de pedido e seus produtos para alteração
        Map<Id, OrderItem> mapItem = new map<Id,OrderItem>();
        Map<Id,Product2> mapProduto = new Map<Id,Product2>();
        Set<Id> idsProduto = new Set<Id>();
        Set<Id> idsHierarquia = new Set<Id>();
        for (OrderItem item : OrderItemHelper.queryOrderItemComOrderIds(mapNewPedidos.keySet())) {
            mapItem.put(item.Id, item);
            mapProduto.put(item.Product2Id, item.Product2);
            idsProduto.add(item.Product2Id);
            idsHierarquia.add(item.Product2.HierarquiaProduto__c);
        }

        // Busca dos parâmetros de preço correspondentes aos atributos
        Map<String, Imposto__c> mapLocPropXImposto = ImpostoHelper.getMapKeyXImposto(ImpostoHelper.queryImpostoAprovadoComParametros(idsEstado, idsProduto, idsCentroDist));
        Map<String, Frete__c> mapLocProdCdXFrete = FreteHelper.getMapKeyXFrete(FreteHelper.queryFreteAprovadoComParametros(idsCidade, idsEstado, idsPais, idsProduto, idsHierarquia, idsCentroDist));
        Map<String, Margem__c> mapLocProdAccXMargem = MargemHelper.getMapKeyXMargem(MargemHelper.queryMargemAprovadaComParametros(idsCidade, idsEstado, idsPais, idsProduto, idsHierarquia, idsConta, idsGrupoConta, idsCentroDist));

        // Atribuição dos parâmetros correspondentes aos fretes
        Set<OrderItem> itensComErro = PricingHelper.atribuirParametros(mapItem.values(), mapLocPropXImposto, mapLocProdCdXFrete, mapLocProdAccXMargem, mapPedido, mapProduto);

        // Filtragem dos Order e OrderItem com erros
        filterErrors(mapNewPedidos, mapItem, itensComErro);
        
        // Fazer update dos itens dos pedidos atualizados, ignorando a trigger padrão do item
        TriggerHandler.bypass('OrderItemTriggerHandler');
        Database.update(mapItem.values(), false);
        TriggerHandler.clearBypass('OrderItemTriggerHandler');
    }


    private static void filterErrors(Map<Id,Order> mapPedido, Map<Id,OrderItem> mapItem, Set<OrderItem> itensComErro) {
        for (OrderItem item : mapItem.values()) {
            // Se o item tem erro, adicionar erro ao seu pedido
            if (itensComErro.contains(item) && !mapPedido.get(item.OrderId).hasErrors()) {
                mapPedido.get(item.OrderId).addError('Esta alteração foi abortada, pois algum dos itens ficaria sem parâmetros de precificação.');
            }

            // Se o pedido do item contém erro, adicionar item aos itens com erro
            if (mapPedido.get(item.OrderId).hasErrors() && !itensComErro.contains(item)) {
                itensComErro.add(item);
            }
        }

        // Remover itens com erro dentre os itens para update
        for (OrderItem item : itensComErro) {
            mapItem.remove(item.Id);
        }
    }


    public static List<Order> queryPedidoComIds(Set<Id> ids) {
        return [SELECT Id, 
                AccountAddress__r.Cidade__c, AccountAddress__r.Cidade__r.Id, AccountAddress__r.Cidade__r.Estado__c, AccountAddress__r.Cidade__r.Estado__r.Pais__c, 
                AccountId, Account.AccountGroup__c, 
                CentroDistribuicao__c
                FROM Order 
                WHERE Id IN :ids];
    }
}