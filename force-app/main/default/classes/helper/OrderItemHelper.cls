public with sharing class OrderItemHelper {
    
    public static void buscarEAtribuirParametros(List<OrderItem> itens) {

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
        Set<Id> idsCentroDist = new Set<Id>();
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
        Map<String, Frete__c> mapLocProdCdXFrete = FreteHelper.getMapLocProdCdXFrete(FreteHelper.queryFreteComLocProdCd(idsCidade, idsEstado, idsPais, idsProduto, idsHierarquia, idsCentroDist));
        Map<String, Margem__c> mapLocProdAccXMargem = MargemHelper.getMapLocProdAccXMargem(MargemHelper.queryMargemComLocProdAcc(idsCidade, idsEstado, idsPais, idsProduto, idsHierarquia, idsConta, idsGrupoConta));

        Set<OrderItem> itensComErro = PricingHelper.atribuirParametros(itens, mapLocPropXImposto, mapLocProdCdXFrete, mapLocProdAccXMargem, mapPedido, mapProduto);

        for (OrderItem item : itens) {
            if (itensComErro.contains(item)) {
                item.addError('Não está autorizada a venda deste produto devido à falta de parâmetros. Contate o time de Pricing');
            }
        }
    }


    public static List<OrderItem> queryOrderItemComOrderIds(Set<Id> idsOrder) {
        return [SELECT Id, OrderId, ListPrice, ValorFrete__c, Product2Id, Product2.HierarquiaProduto__c
                FROM OrderItem
                WHERE OrderId IN :idsOrder];
    }
    
}