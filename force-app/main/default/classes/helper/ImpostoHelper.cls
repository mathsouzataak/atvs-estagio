public with sharing class ImpostoHelper {
    
    public static void impedirDuplicidade(List<Imposto__c> newImpostos) {

        Set<Id> idsEstados = new Set<Id>();
        Set<Id> idsProdutos = new Set<Id>();

        for (Imposto__c imposto : newImpostos) {
            idsEstados.add(imposto.Estado__c);
            idsProdutos.add(imposto.Product__c);
        }

        List<Imposto__c> impostosOrg = [SELECT Id, Estado__c, Product__c 
                                        FROM Imposto__c 
                                        WHERE (Estado__c IN :idsEstados AND Product__c IN :idsProdutos)];

        for (Imposto__c newImposto : newImpostos) {
            for (Imposto__c impostoOrg : impostosOrg) {
                if (newImposto.Product__c == impostoOrg.Product__c && newImposto.Estado__c == impostoOrg.Estado__c) {
                    newImposto.addError('Já existe um imposto para esse produto nesse estado.');
                    break;
                }
            }
        }
    }

}