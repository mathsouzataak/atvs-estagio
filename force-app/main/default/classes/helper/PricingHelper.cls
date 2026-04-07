/**
 * @description add your description here
 * @Date 5 April 2026
 */
public class PricingHelper {


    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // Atribuição dos valores dos componentes de preço aos produtos do pedido
    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        
    /**
     * Atribui os componentes de preço aos OrderItem de uma lista
     * @param itens Lista de OrderItem
     * @param mapLocProdXImposto Map de impostos com string de localidade + produto como key
     * @param mapLocProdCdXFrete Map de fretes com string de localidade + produto + centro de dist. como key
     * @param mapLocProdAccXMargem Map de margens com string de localidade + produto + conta como key
     * @param mapPedido Map de Order
     * @param mapProduto Map de Product2
     * @return Set de OrderItem sem parâmetros
     */
    public static Set<OrderItem> atribuirParametros(List<OrderItem> itens, Map<String, Imposto__c> mapLocProdXImposto, Map<String, Frete__c> mapLocProdCdXFrete, Map<String, Margem__c> mapLocProdAccXMargem, Map<Id,Order> mapPedido, Map<Id,Product2> mapProduto) {
        Set<OrderItem> itensComErro = new Set<OrderItem>();


        for (OrderItem item : itens) {
            if (atribuirImposto(item, mapLocProdXImposto, mapPedido) && 
                    atribuirFrete(item, mapLocProdCdXFrete, mapPedido, mapProduto) && 
                    atribuirMargem(item, mapLocProdAccXMargem, mapPedido, mapProduto)) {
                continue;
            }

            itensComErro.add(item);
        }

        return itensComErro;
    }

    /**
     * Atribui imposto a um OrderItem
     * @param item OrderItem para atribuição do imposto
     * @param mapLocPropXImposto Map de impostos com string de localidade + produto como key
     * @param mapPedido Map de Order com seus Ids como key 
     * @return True se foi encontrado imposto aplicável; false caso contrário
     */
    public static Boolean atribuirImposto(OrderItem item, Map<String, Imposto__c> mapLocPropXImposto, Map<Id,Order> mapPedido) {
        if (item.hasErrors()) {
            return false;
        }

        Imposto__c impostoAplicado = mapLocPropXImposto.get(KeyStringGenerator.createStringKeyFromIds(
            mapPedido.get(item.OrderId).AccountAddress__r.Cidade__r.Estado__c, 
            item.Product2Id,
            mapPedido.get(item.OrderId).CentroDistribuicao__c
        ));

        System.debug('Imposto Aplicado: ' + impostoAplicado?.toString());
        
        if (impostoAplicado != null) {
            item.ImpostoPercent__c = impostoAplicado.ValorPercentual__c;
            return true;
        } else {
            System.debug('Imposto nao encontrado');
            return false;
        }
    }

    /**
     * Atribui frete a um OrderItem
     * @param item OrderItem para atribuição do frete
     * @param mapLocProdCdXFrete Map de fretes com string de localidade + produto + centro de dist. como key
     * @param mapPedido Map de Order com seus Ids como key 
     * @param mapProduto Map de Product2 com seus Ids como key 
     * @return True se foi encontrado frete aplicável; false caso contrário
     */
    public static Boolean atribuirFrete(OrderItem item, Map<String, Frete__c> mapLocProdCdXFrete, Map<Id,Order> mapPedido, Map<Id,Product2> mapProduto) {
        if (item.hasErrors()) {
            return false;
        }

        Frete__c freteAplicado = getFreteAplicavel(mapLocProdCdXFrete, mapProduto.get(item.Product2Id), mapPedido.get(item.OrderId).AccountAddress__r.Cidade__r, mapPedido.get(item.OrderId).CentroDistribuicao__c);

        System.debug('Frete aplicado: ' + freteAplicado?.toString());

        if (freteAplicado != null) {
            item.ValorFrete__c = freteAplicado.Valor__c;
            return true;
        } else {
            System.debug('Frete nao encontrado');
            return false;
        }
    }

    /**
     * Atribui margem a um OrderItem
     * @param item OrderItem para atribuição do frete
     * @param mapLocProdAccXMargem Map de margens com string de localidade + produto + conta como key
     * @param mapPedido Map de Order com seus Ids como key 
     * @param mapProduto Map de Product2 com seus Ids como key 
     * @return True se foi encontrado margem aplicável; false caso contrário
     */
    public static Boolean atribuirMargem(OrderItem item, Map<String, Margem__c> mapLocProdAccXMargem, Map<Id,Order> mapPedido, Map<Id,Product2> mapProduto) {
        if (item.hasErrors()) {
            return false;
        }

        Margem__c margemAplicada = getMargemAplicavel(mapLocProdAccXMargem, mapProduto.get(item.Product2Id), mapPedido.get(item.OrderId).AccountAddress__r.Cidade__r, mapPedido.get(item.OrderId).Account, mapPedido.get(item.OrderId).CentroDistribuicao__c);

        System.debug('Margem aplicada: ' + margemAplicada?.toString());

        if (margemAplicada != null) {
            if (item.ListPrice > 0 || item.ValorFrete__c > 0 || item.ImpostoPercent__c > 0) {
                item.MargemPercent__c = 100 * margemAplicada.Valor__c / ((item.ListPrice + item.ValorFrete__c )*(1+ item.ImpostoPercent__c / 100));
                return true;
            }
                System.debug('Margem nao encontrada');
                return false;
        } else {
            return false;
        }
    }


    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // Busca pelo componente de precificação que mmelhor corresponda aos
    // parâmetros fornecidos
    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    /**
     * Encontra um frete aplicável aos parâmetros, segundo o critério de especificidade
     * @param mapaFrete Map de fretes com string de localidade + produto + centro de dist. como key
     * @param produto Produto com hierarquia de produto
     * @param cidade Cidade com estado e país
     * @param centroDist Id do centro de distribuição
     * @return Frete mais específico encontrado; null se não foi encontrado
     */
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

    /**
     * Encontra uma margem aplicável aos parâmetros, segundo o critério de especificidade
     * @param mapaMargem Map de margens com string de localidade + produto + conta como key
     * @param produto Produto com hierarquia de produto
     * @param cidade Cidade com estado e país
     * @param conta Conta com grupo de contas
     * @return Margem mais específica encontrada; null se não foi encontrada
     */
    private static Margem__c getMargemAplicavel(Map<String,Margem__c> mapaMargem, Product2 produto, Cidade__c cidade, Account conta, Id centroDist) {
        Margem__c margemAplicavel;

        for (Integer generalidadeProduto = 0; generalidadeProduto < 2; generalidadeProduto++) {
            for (Integer generalidadeAcc = 0; generalidadeAcc < 2; generalidadeAcc++) {
                for (Integer generalidadeLoc = 0; generalidadeLoc < 3; generalidadeLoc++) {
                    Id prod = generalidadeProduto == 0 ? produto.Id : produto.HierarquiaProduto__c;
                    Id loc = generalidadeLoc == 0 ? cidade.Id : generalidadeLoc == 1 ? cidade.Estado__c : cidade.Estado__r.Pais__c;
                    Id acc = generalidadeAcc == 0 ? conta.Id : conta.AccountGroup__c;

                    margemAplicavel = mapaMargem.get(KeyStringGenerator.createStringKeyFromIds(loc, prod, acc, centroDist));

                    if (margemAplicavel != null) {
                        return margemAplicavel;
                    }
                }
            }
        }
        
        return null;
    }


}