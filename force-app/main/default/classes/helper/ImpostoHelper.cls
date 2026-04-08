public with sharing class ImpostoHelper {
    
    public static void impedirDuplicidade(List<Imposto__c> newImpostos) {
        Set<Id> idsEstado = new Set<Id>();
        Set<Id> idsProduto = new Set<Id>();
        Set<Id> idsCentroDist = new Set<Id>();
        Set<String> impostoKeys = new Set<String>();

        // Buscar ids dos atributos e validando duplicatas na mesma carga
        for (Imposto__c imposto : newImpostos) {
            if (impostoKeys.add(KeyStringGenerator.createStringKeyFromIds(imposto.Estado__c, imposto.Product__c, imposto.CentroDistribuicao__c))) {
                idsEstado.add(imposto.Estado__c);
                idsProduto.add(imposto.Product__c);
                idsCentroDist.add(imposto.CentroDistribuicao__c);
            } else {
                imposto.addError('Este imposto é duplicata de outro nesta mesma inserção.');
            }
        }

        // Buscar registros com os mesmos atributos 
        Set<String> impostosOrgKeys = new Set<String>();
        for (Imposto__c impostosOrg : queryImpostoComParametros(idsEstado, idsProduto, idsCentroDist)) {
            impostosOrgKeys.add(KeyStringGenerator.createStringKeyFromIds(impostosOrg.Estado__c, impostosOrg.Product__c, impostosOrg.CentroDistribuicao__c));
        }

        // Comparar novos registros com os da org, barrando duplicatas
        for (Imposto__c newImposto : newImpostos) {
            if (impostosOrgKeys.contains(KeyStringGenerator.createStringKeyFromIds(newImposto.Estado__c, newImposto.Product__c, newImposto.CentroDistribuicao__c))) {
                newImposto.addError('Já existe um imposto para esse produto nesse estado.');
                continue;
            }
        }
    }

    public static List<Imposto__c> queryImpostoComParametros(Set<Id> idsEstado, Set<Id> idsProduto, Set<Id> idsCentroDist) {
        return [SELECT Id, Estado__c, Product__c, ValorPercentual__c, CentroDistribuicao__c 
                FROM Imposto__c 
                WHERE (Estado__c IN :idsEstado AND Product__c IN :idsProduto AND CentroDistribuicao__c IN :idsCentroDist)];
    }

    public static List<Imposto__c> queryImpostoAprovadoComParametros(Set<Id> idsEstado, Set<Id> idsProduto, Set<Id> idsCentroDist) {
        return [SELECT Id, Estado__c, Product__c, ValorPercentual__c, CentroDistribuicao__c
                FROM Imposto__c 
                WHERE (Status__c = 'Aprovado' AND Estado__c IN :idsEstado AND Product__c IN :idsProduto AND CentroDistribuicao__c IN :idsCentroDist)];
    }
    
    public static Map<String, Imposto__c> getMapKeyXImposto(List<Imposto__c> impostos) {
        Map<String, Imposto__c> mapLocPropXImposto = new Map<String,Imposto__c>();
        for (Imposto__c imposto : impostos) {
            mapLocPropXImposto.put(KeyStringGenerator.createStringKeyFromIds(imposto.Estado__c, imposto.Product__c, imposto.CentroDistribuicao__c), imposto);
        }

        return mapLocPropXImposto;
    }

}