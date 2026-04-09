public with sharing class FreteHelper {
    
    public static void preventDuplicity(List<Frete__c> newFreights) {
        Set<Id> locationIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        Set<Id> distCenterIds = new Set<Id>();
        Set<String> newFreightStringKeys = new Set<String>();

        // Buscar ids dos atributos e validando duplicatas na mesma carga
        for (Frete__c freight : newFreights) {
            Id locationId = getLocationId(freight);
            Id productId = getProductId(freight);
            Id distCenterId = freight.CentroDistribuicao__c;

            if (newFreightStringKeys.add(KeyStringGenerator.createStringKeyFromIds(locationId, productId, distCenterId))) {
                locationIds.add(locationId);
                productIds.add(productId);
                distCenterIds.add(distCenterId);
            } else {
                freight.addError('Este frete é duplicata de outro nesta mesma inserção.');
            }
        }

        // Buscar registros com os mesmos atributos 
        Set<String> freightsFromOrgStringKeys = new Set<String>();
        for (Frete__c freightFromOrg : queryFreightsWithFields(locationIds, locationIds, locationIds, productIds, productIds, distCenterIds)) {
            freightsFromOrgStringKeys.add(KeyStringGenerator.createStringKeyFromIds(getLocationId(freightFromOrg), getProductId(freightFromOrg), freightFromOrg.CentroDistribuicao__c));
        }

        // Comparar novos registros com os da org, barrando duplicatas
        for (Frete__c newFreight : newFreights) {
            if (freightsFromOrgStringKeys.contains(KeyStringGenerator.createStringKeyFromIds(getLocationId(newFreight), getProductId(newFreight), newFreight.CentroDistribuicao__c))) {
                newFreight.addError('Já existe um frete para esse produto/hierarquia e centro de dist. nesse estado.');
                continue;
            }
        }
    }

    public static Id getLocationId(Frete__c freight) {
        return String.isNotBlank(freight.Cidade__c) ? freight.Cidade__c :
                                (String.isNotBlank(freight.Estado__c) ? freight.Estado__c : 
                                    freight.Pais__c);
    }

    public static Id getProductId(Frete__c freight) {
        return String.isNotBlank(freight.Product__c) ? freight.Product__c : freight.HierarquiaProduto__c;
    }


    public static List<Frete__c> queryFreightsWithFields(Set<Id> cityIds, Set<Id> stateIds, Set<Id> countryIds, Set<Id> productIds, Set<Id> prodHierarchyIds, Set<Id> distCenterIds) {
        return [SELECT Id, 
                Cidade__c, Estado__c, Pais__c, 
                Product__c, HierarquiaProduto__c, 
                CentroDistribuicao__c, 
                Valor__c 
                FROM Frete__c 
                WHERE ((Cidade__c IN :cityIds OR Estado__c IN :stateIds OR Pais__c IN :countryIds) AND 
                    (Product__c IN :productIds OR HierarquiaProduto__c IN :prodHierarchyIds))
                    AND CentroDistribuicao__c IN :distCenterIds];
    }

    public static List<Frete__c> queryApprovedFreightsWithFields(Set<Id> cityIds, Set<Id> stateIds, Set<Id> countryIds, Set<Id> productIds, Set<Id> prodHierarchyIds, Set<Id> distCenterIds) {
        return [SELECT Id, 
                Cidade__c, Estado__c, Pais__c, 
                Product__c, HierarquiaProduto__c, 
                CentroDistribuicao__c, 
                Valor__c 
                FROM Frete__c 
                WHERE (Status__c = 'Aprovado' AND 
                    (Cidade__c IN :cityIds OR Estado__c IN :stateIds OR Pais__c IN :countryIds) AND 
                    (Product__c IN :productIds OR HierarquiaProduto__c IN :prodHierarchyIds))
                    AND CentroDistribuicao__c IN :distCenterIds];
    }

    public static Map<String, Frete__c> getMapStringKeyXFreight(List<Frete__c> freights) {
        Map<String, Frete__c> mapStringKeyXFreight = new Map<String, Frete__c>();
        for (Frete__c freight : freights) {
            Id locationId = FreteHelper.getLocationId(freight);
            Id productId = FreteHelper.getProductId(freight);
            Id distCenterId = freight.CentroDistribuicao__c;
            mapStringKeyXFreight.put(KeyStringGenerator.createStringKeyFromIds(locationId, productId, distCenterId), freight);
        }

        return mapStringKeyXFreight;
    }

}