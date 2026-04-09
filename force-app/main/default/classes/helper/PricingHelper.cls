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
     * @param items Lista de OrderItem
     * @param mapStringKeyXTax Map de impostos com string de localidade + produto como key
     * @param mapStringKeyXFreight Map de fretes com string de localidade + produto + centro de dist. como key
     * @param mapStringKeyXMargin Map de margens com string de localidade + produto + conta como key
     * @param mapOrder Map de Order
     * @param mapProduct Map de Product2
     * @return Set de OrderItem sem parâmetros
     */
    public static Set<OrderItem> assignParameters(List<OrderItem> items, Map<String, Imposto__c> mapStringKeyXTax, Map<String, Frete__c> mapStringKeyXFreight, Map<String, Margem__c> mapStringKeyXMargin, Map<Id,Order> mapOrder, Map<Id,Product2> mapProduct) {
        Set<OrderItem> itemsWithError = new Set<OrderItem>();


        for (OrderItem item : items) {
            if (applyTax(item, mapStringKeyXTax, mapOrder) && 
                    applyFreight(item, mapStringKeyXFreight, mapOrder, mapProduct) && 
                    applyMargin(item, mapStringKeyXMargin, mapOrder, mapProduct)) {
                continue;
            }

            itemsWithError.add(item);
        }

        return itemsWithError;
    }

    /**
     * Atribui imposto a um OrderItem
     * @param item OrderItem para atribuição do imposto
     * @param mapStringKeyXTax Map de impostos com string de localidade + produto como key
     * @param mapOrder Map de Order com seus Ids como key
     * @return True se foi encontrado imposto aplicável; false caso contrário
     */
    public static Boolean applyTax(OrderItem item, Map<String, Imposto__c> mapStringKeyXTax, Map<Id,Order> mapOrder) {
        if (item.hasErrors()) {
            return false;
        }

        Imposto__c taxToBeApplied = mapStringKeyXTax.get(KeyStringGenerator.createStringKeyFromIds(
            mapOrder.get(item.OrderId).AccountAddress__r.Cidade__r.Estado__c, 
            item.Product2Id,
            mapOrder.get(item.OrderId).CentroDistribuicao__c
        ));

        System.debug('Imposto Aplicado: ' + taxToBeApplied?.toString());
        
        if (taxToBeApplied != null) {
            item.ImpostoPercent__c = taxToBeApplied.ValorPercentual__c;
            return true;
        } else {
            System.debug('Imposto nao encontrado');
            return false;
        }
    }

    /**
     * Atribui frete a um OrderItem
     * @param item OrderItem para atribuição do frete
     * @param mapStringKeyXFreight Map de fretes com string de localidade + produto + centro de dist. como key
     * @param mapOrder Map de Order com seus Ids como key 
     * @param mapProduct Map de Product2 com seus Ids como key
     * @return True se foi encontrado frete aplicável; false caso contrário
     */
    public static Boolean applyFreight(OrderItem item, Map<String, Frete__c> mapStringKeyXFreight, Map<Id,Order> mapOrder, Map<Id,Product2> mapProduct) {
        if (item.hasErrors()) {
            return false;
        }

        Frete__c freightToBeApplied = getApplicableFreight(mapStringKeyXFreight, mapProduct.get(item.Product2Id), mapOrder.get(item.OrderId).AccountAddress__r.Cidade__r, mapOrder.get(item.OrderId).CentroDistribuicao__c);

        System.debug('Frete aplicado: ' + freightToBeApplied?.toString());

        if (freightToBeApplied != null) {
            item.ValorFrete__c = freightToBeApplied.Valor__c;
            return true;
        } else {
            System.debug('Frete nao encontrado');
            return false;
        }
    }

    /**
     * Atribui margem a um OrderItem
     * @param item OrderItem para atribuição do frete
     * @param mapStringKeyXMargin Map de margens com string de localidade + produto + conta como key
     * @param mapOrder Map de Order com seus Ids como key
     * @param mapProduct Map de Product2 com seus Ids como key
     * @return True se foi encontrada margem aplicável; false caso contrário
     */
    public static Boolean applyMargin(OrderItem item, Map<String, Margem__c> mapStringKeyXMargin, Map<Id,Order> mapOrder, Map<Id,Product2> mapProduct) {
        if (item.hasErrors()) {
            return false;
        }

        Margem__c marginToBeApplied = getApplicableMargin(mapStringKeyXMargin, mapProduct.get(item.Product2Id), mapOrder.get(item.OrderId).AccountAddress__r.Cidade__r, mapOrder.get(item.OrderId).Account, mapOrder.get(item.OrderId).CentroDistribuicao__c);

        System.debug('Margem aplicada: ' + marginToBeApplied?.toString());

        if (marginToBeApplied != null) {
            if (item.ListPrice > 0 || item.ValorFrete__c > 0 || item.ImpostoPercent__c > 0) {
                item.MargemPercent__c = 100 * marginToBeApplied.Valor__c / ((item.ListPrice + item.ValorFrete__c )*(1+ item.ImpostoPercent__c / 100));
                return true;
            }
                System.debug('Margem nao encontrada');
                return false;
        } else {
            return false;
        }
    }


    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // Busca pelo componente de precificação que melhor corresponda aos
    // parâmetros fornecidos
    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    /**
     * Encontra um frete aplicável aos parâmetros, segundo o critério de especificidade
     * @param mapStringKeyXFreight Map de fretes com string de localidade + produto + centro de dist. como key
     * @param product Produto com hierarquia de produto
     * @param city Cidade com estado e país
     * @param distCenterId Id do centro de distribuição
     * @return Frete mais específico encontrado; null se não foi encontrado
     */
    private static Frete__c getApplicableFreight(Map<String,Frete__c> mapStringKeyXFreight, Product2 product, Cidade__c city, Id distCenterId) {
        Frete__c applicableFreight;

        // 6 iterações max
        for (Integer productGenerality = 0; productGenerality < 2; productGenerality++) {
            for (Integer locationGenerality = 0; locationGenerality < 3; locationGenerality++) {
                Id productId = productGenerality == 0 ? product.Id : product.HierarquiaProduto__c;
                Id locationId = locationGenerality == 0 ? city.Id : (locationGenerality == 1 ? city.Estado__c : city.Estado__r.Pais__c);

                applicableFreight = mapStringKeyXFreight.get(KeyStringGenerator.createStringKeyFromIds(locationId, productId, distCenterId));

                if (applicableFreight != null) {
                    return applicableFreight;
                }
            }
        }
        
        return null;
    }

    /**
     * Encontra uma margem aplicável aos parâmetros, segundo o critério de especificidade
     * @param mapStringKeyXMargin Map de margens com string de localidade + produto + conta como key
     * @param product Produto com hierarquia de produto
     * @param city Cidade com estado e país
     * @param account Conta com grupo de contas
     * @param distCenterId Id do centro de distribuição
     * @return Margem mais específica encontrada; null se não foi encontrada 
     */
    private static Margem__c getApplicableMargin(Map<String,Margem__c> mapStringKeyXMargin, Product2 product, Cidade__c city, Account account, Id distCenterId) {
        Margem__c applicableMargin;


        // 12 iterações max
        for (Integer productGenerality = 0; productGenerality < 2; productGenerality++) {
            for (Integer accountGenerality = 0; accountGenerality < 2; accountGenerality++) {
                for (Integer locationGenerality = 0; locationGenerality < 3; locationGenerality++) {
                    Id productId = productGenerality == 0 ? product.Id : product.HierarquiaProduto__c;
                    Id locationId = locationGenerality == 0 ? city.Id : locationGenerality == 1 ? city.Estado__c : city.Estado__r.Pais__c;
                    Id accountId = accountGenerality == 0 ? account.Id : account.AccountGroup__c;

                    applicableMargin = mapStringKeyXMargin.get(KeyStringGenerator.createStringKeyFromIds(locationId, productId, accountId, distCenterId));

                    if (applicableMargin != null) {
                        return applicableMargin;
                    }
                }
            }
        }
        
        return null;
    }


}