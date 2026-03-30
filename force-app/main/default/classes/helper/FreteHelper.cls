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
        for (Frete__c freteOrg : queryFreteComLocProd(idsLocalidade, idsLocalidade, idsLocalidade, idsProduto, idsProduto)) {
            locProdutoPairOrg.add(KeyStringGenerator.createStringFromKeys(getLocalidadeId(freteOrg), getProdutoId(freteOrg)));
        }

        for (Frete__c newFrete : newFretes) {
            if (locProdutoPairOrg.contains(KeyStringGenerator.createStringFromKeys(getLocalidadeId(newFrete), getProdutoId(newFrete)))) {
                newFrete.addError('Já existe um frete para esse produto/hierarquia nesse estado.');
                continue;
            }
        }
    }

    public static Id getLocalidadeId(Frete__c frete) {
        return String.isNotBlank(frete.Cidade__c) ? frete.Cidade__c :
                                (String.isNotBlank(frete.Estado__c) ? frete.Estado__c : 
                                    frete.Pais__c);
    }

    public static Id getProdutoId(Frete__c frete) {
        return String.isNotBlank(frete.Product__c) ? frete.Product__c : frete.HierarquiaProduto__c;
    }


    public static List<Frete__c> queryFreteComLocProd(Set<Id> idsCidade, Set<Id> idsEstado, Set<Id> idsPais, Set<Id> idsProduto, Set<Id> idsHierarquia) {
        return [SELECT Id, Cidade__c, Estado__c, Pais__c, Product__c, HierarquiaProduto__c, Valor__c, CreatedDate 
                FROM Frete__c 
                WHERE (Status__c = 'Aprovado' AND 
                    (Cidade__c IN :idsCidade OR Estado__c IN :idsEstado OR Pais__c IN :idsPais) AND 
                    (Product__c IN :idsProduto OR HierarquiaProduto__c IN :idsHierarquia))];
    }

    public static Map<String, Frete__c> getMapLocProdXFrete(List<Frete__c> fretes) {
        Map<String, Frete__c> mapLocProdXFrete = new Map<String, Frete__c>();
        for (Frete__c frete : fretes) {
            Id idLocalidade = FreteHelper.getLocalidadeId(frete);
            Id idProduto = FreteHelper.getProdutoId(frete);
            mapLocProdXFrete.put(KeyStringGenerator.createStringFromKeys(idLocalidade, idProduto), frete);
        }

        return mapLocProdXFrete;
    }


    public static Map<String, Imposto__c> getMapLocProdXImposto(List<Imposto__c> impostos) {
        Map<String, Imposto__c> mapLocPropXImposto = new Map<String,Imposto__c>();
        for (Imposto__c imposto : impostos) {
            mapLocPropXImposto.put(KeyStringGenerator.createStringFromKeys(imposto.Estado__c, imposto.Product__c), imposto);
        }

        return mapLocPropXImposto;
    }

}