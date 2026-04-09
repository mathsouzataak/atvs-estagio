public with sharing class ImpostoHelper {
    
    public static void preventDuplicity(List<Imposto__c> newTaxes) {
        Set<Id> stateIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        Set<Id> distCenterIds = new Set<Id>();
        Set<String> newTaxesStringKeys = new Set<String>();

        // Buscar ids dos atributos e validando duplicatas na mesma carga
        for (Imposto__c tax : newTaxes) {
            if (newTaxesStringKeys.add(KeyStringGenerator.createStringKeyFromIds(tax.Estado__c, tax.Product__c, tax.CentroDistribuicao__c))) {
                stateIds.add(tax.Estado__c);
                productIds.add(tax.Product__c);
                distCenterIds.add(tax.CentroDistribuicao__c);
            } else {
                tax.addError('Este imposto é duplicata de outro nesta mesma inserção.');
            }
        }

        // Buscar registros com os mesmos atributos 
        Set<String> taxesFromOrgStringKeys = new Set<String>();
        for (Imposto__c taxesFromOrg : queryTaxesWithFields(stateIds, productIds, distCenterIds)) {
            taxesFromOrgStringKeys.add(KeyStringGenerator.createStringKeyFromIds(taxesFromOrg.Estado__c, taxesFromOrg.Product__c, taxesFromOrg.CentroDistribuicao__c));
        }

        // Comparar novos registros com os da org, barrando duplicatas
        for (Imposto__c newTax : newTaxes) {
            if (taxesFromOrgStringKeys.contains(KeyStringGenerator.createStringKeyFromIds(newTax.Estado__c, newTax.Product__c, newTax.CentroDistribuicao__c))) {
                newTax.addError('Já existe um imposto para esse produto nesse estado.');
                continue;
            }
        }
    }

    public static List<Imposto__c> queryTaxesWithFields(Set<Id> stateIds, Set<Id> productIds, Set<Id> distCenterIds) {
        return [SELECT Id, Estado__c, Product__c, ValorPercentual__c, CentroDistribuicao__c 
                FROM Imposto__c 
                WHERE (Estado__c IN :stateIds AND Product__c IN :productIds AND CentroDistribuicao__c IN :distCenterIds)];
    }

    public static List<Imposto__c> queryImpostoAprovadoComParametros(Set<Id> stateIds, Set<Id> productIds, Set<Id> distCenterIds) {
        return [SELECT Id, Estado__c, Product__c, ValorPercentual__c, CentroDistribuicao__c
                FROM Imposto__c 
                WHERE (Status__c = 'Aprovado' AND Estado__c IN :stateIds AND Product__c IN :productIds AND CentroDistribuicao__c IN :distCenterIds)];
    }
    
    public static Map<String, Imposto__c> getMapStringKeyXTax(List<Imposto__c> taxes) {
        Map<String, Imposto__c> mapStringKeyXTax = new Map<String,Imposto__c>();
        for (Imposto__c tax : taxes) {
            mapStringKeyXTax.put(KeyStringGenerator.createStringKeyFromIds(tax.Estado__c, tax.Product__c, tax.CentroDistribuicao__c), tax);
        }

        return mapStringKeyXTax;
    }

}