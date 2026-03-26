public with sharing class MargemHelper {

    public static void impedirDuplicidade(List<Margem__c> newMargens) {
        Set<Id> idsLocalidade = new Set<Id>();
        Set<Id> idsProduto = new Set<Id>();
        Set<Id> idsConta = new Set<Id>();
        Set<String> margemLocProdAccString = new Set<String>();

        for (Margem__c margem : newMargens) {
            Id localidade = getLocalidadeId(margem);
            Id produto = getProdutoId(margem);
            Id conta = getContaId(margem);

            if (margemLocProdAccString.add(KeyStringGenerator.createStringFromKeys(localidade, produto, conta))) {
                idsLocalidade.add(localidade);
                idsProduto.add(produto);
                idsConta.add(conta);
            } else {
                margem.addError('Esta margem é duplicata de outra nesta mesma inserção.');
            }
        }

        Set<String> locProdutoPairOrg = new Set<String>();
        for (Margem__c margemOrg : queryMargemComLocProdAcc(idsLocalidade,idsLocalidade, idsLocalidade, idsProduto, idsProduto, idsConta, idsConta)) {
            locProdutoPairOrg.add(KeyStringGenerator.createStringFromKeys(getLocalidadeId(margemOrg), getProdutoId(margemOrg), getContaId(margemOrg)));
        }

        for (Margem__c newMargem : newMargens) {
            if (locProdutoPairOrg.contains(KeyStringGenerator.createStringFromKeys(getLocalidadeId(newMargem), getProdutoId(newMargem), getContaId(newMargem)))) {
                newMargem.addError('Já existe uma margem para esse produto/hierarquia e conta/grupo nesse estado.');
                continue;
            }
        }
    }

    public static Id getLocalidadeId(Margem__c margem) {
        return String.isNotBlank(margem.Cidade__c) ? 
                margem.Cidade__c : 
                String.isNotBlank(margem.Estado__c) ? 
                    margem.Estado__c : 
                    margem.Pais__c;
    }

    public static Id getProdutoId(Margem__c margem) {
        return String.isNotBlank(margem.Product__c) ? margem.Product__c : margem.HierarquiaProduto__c;
    }

    public static Id getContaId(Margem__c margem) {
        return String.isNotBlank(margem.Account__c) ? margem.Account__c : margem.AccountGroup__c;
    }

    public static List<Margem__c> queryMargemComLocProdAcc(Set<Id> idsCidade, Set<Id> idsEstado, Set<Id> idsPais, Set<Id> idsProduto, Set<Id> idsHierarquia, Set<Id> idsConta, Set<Id> idsGrupo) {
        return [SELECT Id, Cidade__c, Estado__c, Pais__c, Product__c, HierarquiaProduto__c, Account__c, AccountGroup__c 
                FROM Margem__c 
                WHERE ((Cidade__c IN :idsCidade OR Estado__c IN :idsEstado OR Pais__c IN :idsPais) AND 
                    (Product__c IN :idsProduto OR HierarquiaProduto__c IN :idsHierarquia) AND 
                    (Account__c IN :idsConta OR AccountGroup__c IN :idsGrupo))];
    }
}