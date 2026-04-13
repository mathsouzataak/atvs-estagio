@IsTest
public with sharing class MargemTeste {
    
    @IsTest 
    static void testBulkDuplicityOnInsert() {
        Margem__c margin1 = TestDataFactory.createMargin(false); 
        Margem__c margin2 = margin1.clone();
        List<Margem__c> margins = new List<Margem__c>{margin1, margin2};

        List<Database.SaveResult> results = Database.insert(margins, false);

        Assert.isTrue(results[0].isSuccess(), 'Houve erro no primeiro registro');
        Assert.isFalse(results[1].isSuccess(), 'A duplicata foi inserida');
        Assert.isTrue(results[1].getErrors().size() > 0, 'Não houve erro no registro duplicado');
        Assert.areEqual('Esta margem é duplicata de outra nesta mesma inserção.', results[1].getErrors()[0].getMessage(), 'Mensagem de erro discrepante.');
    }


    @IsTest 
    static void testOrgDuplicityOnInsert() {
        Margem__c margin1 = TestDataFactory.createMargin(true); 
        Margem__c margin2 = margin1.clone();

        Database.SaveResult result = Database.insert(margin2, false);

        Assert.isFalse(result.isSuccess(), 'A duplicata foi inserida');
        Assert.isTrue(result.getErrors().size() > 0, 'Não houve erro no registro duplicado');
        Assert.areEqual('Já existe uma margem para esse produto/hierarquia e conta/grupo nessa localidade.', result.getErrors()[0].getMessage(), 'Mensagem de erro discrepante.');
    }

    @IsTest 
    static void testQuery() {
        Product2 product = TestDataFactory.createProduct(true);
        Account account = TestDataFactory.createAccount(true);
        Estado__c state = TestDataFactory.createState(true);
        DistributionCenter__c distCenter1 = TestDataFactory.createDistCenter(true);
        DistributionCenter__c distCenter2 = TestDataFactory.createDistCenter(true);

        Margem__c margin1 = TestDataFactory.createMargin(product.Id, account.Id, state.Id, distCenter1.Id, true);
        Margem__c margin2 = TestDataFactory.createMargin(product.Id, account.Id, state.Id, distCenter2.Id, true);

        List<Margem__c> margins = MargemHelper.queryMarginWithFields(new Set<Id>(), new Set<Id>{state.Id}, new Set<Id>(), new Set<Id>{product.Id}, new Set<Id>(), new Set<Id>{account.Id}, new Set<Id>(), new Set<Id>{distCenter1.Id});

        Assert.areEqual(1, margins.size(), 'A query não retornou apenas um registro');
        Assert.areEqual(margin1.Id, margins[0].Id, 'O registro retornado pela query não é o esperado');
    }

    @IsTest 
    static void testQueryApprovedWithBlockedRecord() {
        Margem__c margin2 = TestDataFactory.createMargin(false);
        Margem__c margin1 = TestDataFactory.createMargin(false);
        margin2.Status__c = 'Bloqueado';
        Database.insert(new List<Margem__c>{margin1, margin2});

        List<Margem__c> margins = MargemHelper.queryApprovedMarginWithFields(new Set<Id>{margin1.Cidade__c, margin2.Cidade__c}, new Set<Id>(), new Set<Id>(),new Set<Id>{margin1.Product__c, margin2.Product__c}, new Set<Id>(), new Set<Id>{margin1.Account__c, margin2.Account__c}, new Set<Id>(), new Set<Id>{margin1.CentroDistribuicao__c, margin2.CentroDistribuicao__c});

        Assert.areEqual(1, margins.size(), 'A query não retornou apenas um registro');
        Assert.areEqual(margin1.Id, margins[0].Id, 'O registro retornado pela query não é o esperado');
    }

    @IsTest 
    static void testGetStringKeyMap() {
        Margem__c margin1 = TestDataFactory.createMargin(false);
        Margem__c margin2 = TestDataFactory.createMargin(false);
        List<Margem__c> margins = new List<Margem__c>{margin1, margin2};

        Map<String, Margem__c> mapStringKeyXMargin = MargemHelper.getMapStringKeyXMargin(margins);

        Assert.areEqual(margin1, mapStringKeyXMargin.get(KeyStringGenerator.createStringKeyFromIds(margin1.Cidade__c, margin1.Product__c, margin1.Account__c, margin1.CentroDistribuicao__c)));
        Assert.areEqual(margin2, mapStringKeyXMargin.get(KeyStringGenerator.createStringKeyFromIds(margin2.Cidade__c, margin2.Product__c, margin2.Account__c, margin2.CentroDistribuicao__c)));
    }
}