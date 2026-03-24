public with sharing class ImpostoHelper {
    
    public static void impedirDuplicidade(List<Imposto__c> newImpostos) {

        Set<Id> idsEstados = new Set<Id>();
        Set<Id> idsProdutos = new Set<Id>();
        Set<String> impostoPair = new Set<String>();

        for (Imposto__c imposto : newImpostos) {
            if (impostoPair.add(KeyStringGenerator.createStringFromKeys(imposto.Estado__c, imposto.Product__c))) {
                idsEstados.add(imposto.Estado__c);
                idsProdutos.add(imposto.Product__c);
            } else {
                imposto.addError('Este imposto é duplicado de outro nesta mesma inserção.');
            }
        }

        Set<String> estadoProdutoPair = new Set<String>();
        for (Imposto__c impostosOrg : [SELECT Id, Estado__c, Product__c 
                                        FROM Imposto__c 
                                        WHERE (Estado__c IN :idsEstados AND Product__c IN :idsProdutos)]) {
            estadoProdutoPair.add(KeyStringGenerator.createStringFromKeys(impostosOrg.Estado__c, impostosOrg.Product__c));
        }

        for (Imposto__c newImposto : newImpostos) {
            if (estadoProdutoPair.contains(KeyStringGenerator.createStringFromKeys(newImposto.Estado__c, newImposto.Product__c))) {
                newImposto.addError('Já existe um imposto para esse produto nesse estado.');
                continue;
            }
        }
    }

}