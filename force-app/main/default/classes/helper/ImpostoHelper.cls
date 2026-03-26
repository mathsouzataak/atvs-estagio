public with sharing class ImpostoHelper {
    
    public static void impedirDuplicidade(List<Imposto__c> newImpostos) {
        Set<Id> idsEstado = new Set<Id>();
        Set<Id> idsProduto = new Set<Id>();
        Set<String> impostoPair = new Set<String>();

        for (Imposto__c imposto : newImpostos) {
            if (impostoPair.add(KeyStringGenerator.createStringFromKeys(imposto.Estado__c, imposto.Product__c))) {
                idsEstado.add(imposto.Estado__c);
                idsProduto.add(imposto.Product__c);
            } else {
                imposto.addError('Este imposto é duplicata de outro nesta mesma inserção.');
            }
        }

        Set<String> estadoProdutoPair = new Set<String>();
        for (Imposto__c impostosOrg : queryImpostoComEstadoProd(idsEstado, idsProduto)) {
            estadoProdutoPair.add(KeyStringGenerator.createStringFromKeys(impostosOrg.Estado__c, impostosOrg.Product__c));
        }

        for (Imposto__c newImposto : newImpostos) {
            if (estadoProdutoPair.contains(KeyStringGenerator.createStringFromKeys(newImposto.Estado__c, newImposto.Product__c))) {
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

}