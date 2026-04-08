public with sharing class MargemHelper {

    public static void impedirDuplicidade(List<Margem__c> newMargens) {
        Set<Id> idsLocalidade = new Set<Id>();
        Set<Id> idsProduto = new Set<Id>();
        Set<Id> idsCentroDist = new Set<Id>();
        Set<Id> idsConta = new Set<Id>();
        Set<String> margemLocProdAccString = new Set<String>();

        // Buscar ids dos atributos e validando duplicatas na mesma carga
        for (Margem__c margem : newMargens) {
            Id localidade = getLocalidadeId(margem);
            Id produto = getProdutoId(margem);
            Id conta = getContaId(margem);

            if (margemLocProdAccString.add(KeyStringGenerator.createStringKeyFromIds(localidade, produto, conta, margem.CentroDistribuicao__c))) {
                idsLocalidade.add(localidade);
                idsProduto.add(produto);
                idsConta.add(conta);
                idsCentroDist.add(margem.CentroDistribuicao__c);
            } else {
                margem.addError('Esta margem é duplicata de outra nesta mesma inserção.');
            }
        }

        // Buscar registros com os mesmos atributos 
        Set<String> locProdutoPairOrg = new Set<String>();
        for (Margem__c margemOrg : queryMargemComParametros(idsLocalidade,idsLocalidade, idsLocalidade, idsProduto, idsProduto, idsConta, idsConta, idsCentroDist)) {
            locProdutoPairOrg.add(KeyStringGenerator.createStringKeyFromIds(getLocalidadeId(margemOrg), getProdutoId(margemOrg), getContaId(margemOrg), margemOrg.CentroDistribuicao__c));
        }

        // Comparar novos registros com os da org, barrando duplicatas
        for (Margem__c newMargem : newMargens) {
            if (locProdutoPairOrg.contains(KeyStringGenerator.createStringKeyFromIds(getLocalidadeId(newMargem), getProdutoId(newMargem), getContaId(newMargem), newMargem.CentroDistribuicao__c))) {
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

    public static List<Margem__c> queryMargemComParametros(Set<Id> idsCidade, Set<Id> idsEstado, Set<Id> idsPais, Set<Id> idsProduto, Set<Id> idsHierarquia, Set<Id> idsConta, Set<Id> idsGrupo, Set<Id> idsCentroDist) {
        return [SELECT Id, 
                Cidade__c, Estado__c, Pais__c, 
                Product__c, HierarquiaProduto__c, 
                Account__c, AccountGroup__c, 
                Valor__c 
                FROM Margem__c 
                WHERE ((Cidade__c IN :idsCidade OR Estado__c IN :idsEstado OR Pais__c IN :idsPais) AND 
                    (Product__c IN :idsProduto OR HierarquiaProduto__c IN :idsHierarquia) AND 
                    (Account__c IN :idsConta OR AccountGroup__c IN :idsGrupo) AND
                    CentroDistribuicao__c IN :idsCentroDist)];
    }

    public static List<Margem__c> queryMargemAprovadaComParametros(Set<Id> idsCidade, Set<Id> idsEstado, Set<Id> idsPais, Set<Id> idsProduto, Set<Id> idsHierarquia, Set<Id> idsConta, Set<Id> idsGrupo, Set<Id> idsCentroDist) {
        return [SELECT Id, 
                Cidade__c, Estado__c, Pais__c, 
                Product__c, HierarquiaProduto__c, 
                Account__c, AccountGroup__c,
                CentroDistribuicao__c,
                Valor__c 
                FROM Margem__c 
                WHERE (Status__c = 'Aprovado' AND 
                    (Cidade__c IN :idsCidade OR Estado__c IN :idsEstado OR Pais__c IN :idsPais) AND 
                    (Product__c IN :idsProduto OR HierarquiaProduto__c IN :idsHierarquia) AND 
                    (Account__c IN :idsConta OR AccountGroup__c IN :idsGrupo) AND
                    CentroDistribuicao__c IN :idsCentroDist)];
    }

    public static Map<String, Margem__c> getMapKeyXMargem(List<Margem__c> margens) {
        Map<String, Margem__c> mapLocProdAccXMargem = new Map<String, Margem__c>();
        for (Margem__c margem : margens) {
            Id idLocalidade = getLocalidadeId(margem);
            Id idProduto = getProdutoId(margem);
            Id idConta = getContaId(margem);
            Id idCentroDist = margem.CentroDistribuicao__c;
            mapLocProdAccXMargem.put(KeyStringGenerator.createStringKeyFromIds(idLocalidade, idProduto, idConta, idCentroDist), margem);
        }

        return mapLocProdAccXMargem;
    } 
}