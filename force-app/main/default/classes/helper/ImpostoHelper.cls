public with sharing class ImpostoHelper {
    
    public static void impedirDuplicidade(List<Imposto__c> newImpostos) {
        Set<Id> idsEstado = new Set<Id>();
        Set<Id> idsProduto = new Set<Id>();
        Set<String> impostoKeys = new Set<String>();

        for (Imposto__c imposto : newImpostos) {
            if (impostoKeys.add(KeyStringGenerator.createStringKeyFromIds(imposto.Estado__c, imposto.Product__c))) {
                idsEstado.add(imposto.Estado__c);
                idsProduto.add(imposto.Product__c);
            } else {
                imposto.addError('Este imposto é duplicata de outro nesta mesma inserção.');
            }
        }

        Set<String> estadoProdutoPair = new Set<String>();
        for (Imposto__c impostosOrg : queryImpostoComEstadoProd(idsEstado, idsProduto)) {
            estadoProdutoPair.add(KeyStringGenerator.createStringKeyFromIds(impostosOrg.Estado__c, impostosOrg.Product__c));
        }

        for (Imposto__c newImposto : newImpostos) {
            if (estadoProdutoPair.contains(KeyStringGenerator.createStringKeyFromIds(newImposto.Estado__c, newImposto.Product__c))) {
                newImposto.addError('Já existe um imposto para esse produto nesse estado.');
                continue;
            }
        }
    }

    public static List<Imposto__c> queryImpostoComEstadoProd(Set<Id> idsEstado, Set<Id> idsProduto) {
        return [SELECT Id, Estado__c, Product__c, ValorPercentual__c 
                FROM Imposto__c 
                WHERE (Status__c = 'Aprovado' AND Estado__c IN :idsEstado AND Product__c IN :idsProduto)];
    }
    
    public static Map<String, Imposto__c> getMapLocProdXImposto(List<Imposto__c> impostos) {
        Map<String, Imposto__c> mapLocPropXImposto = new Map<String,Imposto__c>();
        for (Imposto__c imposto : impostos) {
            mapLocPropXImposto.put(KeyStringGenerator.createStringKeyFromIds(imposto.Estado__c, imposto.Product__c), imposto);
        }

        return mapLocPropXImposto;
    }

}