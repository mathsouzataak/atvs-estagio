public with sharing class MargemHelper {

    public static void preventDuplicity(List<Margem__c> newMargins) {
        Set<Id> locationIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        Set<Id> distCenterIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<String> newMarginsStringKeys = new Set<String>();

        // Buscar ids dos atributos e validando duplicatas na mesma carga
        for (Margem__c margin : newMargins) {
            Id locationId = getLocationId(margin);
            Id productId = getProductId(margin);
            Id accountId = getAccountId(margin);

            if (newMarginsStringKeys.add(KeyStringGenerator.createStringKeyFromIds(locationId, productId, accountId, margin.CentroDistribuicao__c))) {
                locationIds.add(locationId);
                productIds.add(productId);
                accountIds.add(accountId);
                distCenterIds.add(margin.CentroDistribuicao__c);
            } else {
                margin.addError('Esta margem é duplicata de outra nesta mesma inserção.');
            }
        }

        // Buscar registros com os mesmos atributos 
        Set<String> marginsFromOrgStringKeys = new Set<String>();
        for (Margem__c marginFromOrg : queryMarginWithFields(locationIds,locationIds, locationIds, productIds, productIds, accountIds, accountIds, distCenterIds)) {
            marginsFromOrgStringKeys.add(KeyStringGenerator.createStringKeyFromIds(getLocationId(marginFromOrg), getProductId(marginFromOrg), getAccountId(marginFromOrg), marginFromOrg.CentroDistribuicao__c));
        }

        // Comparar novos registros com os da org, barrando duplicatas
        for (Margem__c newMargin : newMargins) {
            if (marginsFromOrgStringKeys.contains(KeyStringGenerator.createStringKeyFromIds(getLocationId(newMargin), getProductId(newMargin), getAccountId(newMargin), newMargin.CentroDistribuicao__c))) {
                newMargin.addError('Já existe uma margem para esse produto/hierarquia e conta/grupo nessa localidade.');
                continue;
            }
        }
    }

    
    public static Id getLocationId(Margem__c margin) {
        return String.isNotBlank(margin.Cidade__c) ? 
                margin.Cidade__c : 
                String.isNotBlank(margin.Estado__c) ? 
                    margin.Estado__c : margin.Pais__c;
    }

    public static Id getProductId(Margem__c margin) {
        return String.isNotBlank(margin.Product__c) ? margin.Product__c : margin.HierarquiaProduto__c;
    }

    public static Id getAccountId(Margem__c margin) {
        return String.isNotBlank(margin.Account__c) ? margin.Account__c : margin.AccountGroup__c;
    }

    public static List<Margem__c> queryMarginWithFields(Set<Id> cityIds, Set<Id> stateIds, Set<Id> countryIds, Set<Id> productIds, Set<Id> prodHierarchyIds, Set<Id> accountIds, Set<Id> accountGroupIds, Set<Id> distCenterIds) {
        return [SELECT Id, 
                Cidade__c, Estado__c, Pais__c, 
                Product__c, HierarquiaProduto__c, 
                Account__c, AccountGroup__c,
                CentroDistribuicao__c,
                Valor__c 
                FROM Margem__c 
                WHERE ((Cidade__c IN :cityIds OR Estado__c IN :stateIds OR Pais__c IN :countryIds) AND 
                    (Product__c IN :productIds OR HierarquiaProduto__c IN :prodHierarchyIds) AND 
                    (Account__c IN :accountIds OR AccountGroup__c IN :accountGroupIds) AND
                    CentroDistribuicao__c IN :distCenterIds)];
    }

    public static List<Margem__c> queryApprovedMarginWithFields(Set<Id> cityIds, Set<Id> stateIds, Set<Id> countryIds, Set<Id> productIds, Set<Id> prodHierarchyIds, Set<Id> accountIds, Set<Id> accountGroupIds, Set<Id> distCenterIds) {
        return [SELECT Id, 
                Cidade__c, Estado__c, Pais__c, 
                Product__c, HierarquiaProduto__c, 
                Account__c, AccountGroup__c,
                CentroDistribuicao__c,
                Valor__c 
                FROM Margem__c 
                WHERE (Status__c = 'Aprovado' AND 
                    (Cidade__c IN :cityIds OR Estado__c IN :stateIds OR Pais__c IN :countryIds) AND 
                    (Product__c IN :productIds OR HierarquiaProduto__c IN :prodHierarchyIds) AND 
                    (Account__c IN :accountIds OR AccountGroup__c IN :accountGroupIds) AND
                    CentroDistribuicao__c IN :distCenterIds)];
    }

    public static Map<String, Margem__c> getMapStringKeyXMargin(List<Margem__c> margins) {
        Map<String, Margem__c> mapStringKeyXMargin = new Map<String, Margem__c>();
        for (Margem__c margin : margins) {
            Id locationId = getLocationId(margin);
            Id productId = getProductId(margin);
            Id accountId = getAccountId(margin);
            Id distCenterId = margin.CentroDistribuicao__c;
            mapStringKeyXMargin.put(KeyStringGenerator.createStringKeyFromIds(locationId, productId, accountId, distCenterId), margin);
        }

        return mapStringKeyXMargin;
    } 
}