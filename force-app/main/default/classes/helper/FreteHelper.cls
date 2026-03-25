public with sharing class FreteHelper {
    
    public static void impedirDuplicidade(List<Frete__c> newFretes) {
        Set<Id> idsLocalidade = new Set<Id>();
        Set<Id> idsProduto = new Set<Id>();
        Set<String> freteLocProdPair = new Set<String>();

        for (Frete__c frete : newFretes) {
            Id localidade = getLocalidadeId(frete);
            Id produto = getProdutoId(frete);

            if (freteLocProdPair.add(KeyStringGenerator.createStringFromKeys(localidade, produto))) {
                idsLocalidade.add(localidade);
                idsProduto.add(produto);
            } else {
                frete.addError('Este frete é duplicata de outro nesta mesma inserção.');
            }
        }

        Set<String> locProdutoPairOrg = new Set<String>();
        for (Frete__c freteOrg : [SELECT Id, Cidade__c, Estado__c, Pais__c, Product__c, HierarquiaProduto__c
                                        FROM Frete__c 
                                        WHERE ((Cidade__c IN :idsLocalidade OR Estado__c IN :idsLocalidade OR Pais__c IN :idsLocalidade) 
                                            AND (Product__c IN :idsProduto OR HierarquiaProduto__c IN :idsProduto))]) {
            locProdutoPairOrg.add(KeyStringGenerator.createStringFromKeys(getLocalidadeId(freteOrg), getProdutoId(freteOrg)));
        }

        for (Frete__c newFrete : newFretes) {
            if (locProdutoPairOrg.contains(KeyStringGenerator.createStringFromKeys(getLocalidadeId(newFrete), getProdutoId(newFrete)))) {
                newFrete.addError('Já existe um frete para esse produto/hierarquia nesse estado.');
                continue;
            }
        }
    }

    private static Id getLocalidadeId(Frete__c frete) {
        return String.isNotBlank(frete.Cidade__c) ? frete.Cidade__c :
                                String.isNotBlank(frete.Estado__c) ? frete.Estado__c : 
                                    frete.Pais__c;
    }

    private static Id getProdutoId(Frete__c frete) {
        return String.isNotBlank(frete.Product__c) ? frete.Product__c : frete.HierarquiaProduto__c;
    }

}