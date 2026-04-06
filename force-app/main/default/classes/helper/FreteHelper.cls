public with sharing class FreteHelper {
    
    public static void impedirDuplicidade(List<Frete__c> newFretes) {
        Set<Id> idsLocalidade = new Set<Id>();
        Set<Id> idsProduto = new Set<Id>();
        Set<Id> idsCentroDist = new Set<Id>();
        Set<String> newFreteKey = new Set<String>();

        for (Frete__c frete : newFretes) {
            Id localidade = getLocalidadeId(frete);
            Id produto = getProdutoId(frete);
            Id centroDist = frete.CentroDistribuicao__c;

            if (newFreteKey.add(KeyStringGenerator.createStringKeyFromIds(localidade, produto, centroDist))) {
                idsLocalidade.add(localidade);
                idsProduto.add(produto);
                idsCentroDist.add(centroDist);
            } else {
                frete.addError('Este frete é duplicata de outro nesta mesma inserção.');
            }
        }

        Set<String> locProdutoPairOrg = new Set<String>();
        for (Frete__c freteOrg : queryFreteComLocProdCd(idsLocalidade, idsLocalidade, idsLocalidade, idsProduto, idsProduto, idsCentroDist)) {
            locProdutoPairOrg.add(KeyStringGenerator.createStringKeyFromIds(getLocalidadeId(freteOrg), getProdutoId(freteOrg), freteOrg.CentroDistribuicao__c));
        }

        for (Frete__c newFrete : newFretes) {
            if (locProdutoPairOrg.contains(KeyStringGenerator.createStringKeyFromIds(getLocalidadeId(newFrete), getProdutoId(newFrete), newFrete.CentroDistribuicao__c))) {
                newFrete.addError('Já existe um frete para esse produto/hierarquia e centro de dist. nesse estado.');
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


    public static List<Frete__c> queryFreteComLocProdCd(Set<Id> idsCidade, Set<Id> idsEstado, Set<Id> idsPais, Set<Id> idsProduto, Set<Id> idsHierarquia, Set<Id> idsCentroDist) {
        return [SELECT Id, 
                Cidade__c, Estado__c, Pais__c, 
                Product__c, HierarquiaProduto__c, 
                CentroDistribuicao__c, 
                Valor__c 
                FROM Frete__c 
                WHERE (Status__c = 'Aprovado' AND 
                    (Cidade__c IN :idsCidade OR Estado__c IN :idsEstado OR Pais__c IN :idsPais) AND 
                    (Product__c IN :idsProduto OR HierarquiaProduto__c IN :idsHierarquia))
                    AND CentroDistribuicao__c IN :idsCentroDist];
    }

    public static Map<String, Frete__c> getMapLocProdCdXFrete(List<Frete__c> fretes) {
        Map<String, Frete__c> mapLocProdCdXFrete = new Map<String, Frete__c>();
        for (Frete__c frete : fretes) {
            Id idLocalidade = FreteHelper.getLocalidadeId(frete);
            Id idProduto = FreteHelper.getProdutoId(frete);
            Id idCentroDist = frete.CentroDistribuicao__c;
            mapLocProdCdXFrete.put(KeyStringGenerator.createStringKeyFromIds(idLocalidade, idProduto, idCentroDist), frete);
        }

        return mapLocProdCdXFrete;
    }

}