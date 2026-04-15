@IsTest
private with sharing class FreteTest {
    
    @IsTest 
    static void testBulkDuplicityOnInsert() {
        Test.startTest();

        Frete__c freight1 = TestDataFactory.createFreight(false); 
        Frete__c freight2 = freight1.clone();
        List<Frete__c> freights = new List<Frete__c>{freight1, freight2};

        List<Database.SaveResult> results = Database.insert(freights, false);

        Test.stopTest();

        Assert.isTrue(results[0].isSuccess(), 'Houve erro no primeiro registro');
        Assert.isFalse(results[1].isSuccess(), 'A duplicata foi inserida');
        Assert.isTrue(results[1].getErrors().size() > 0, 'Não houve erro no registro duplicado');
        Assert.areEqual('Este frete é duplicata de outro nesta mesma inserção.', results[1].getErrors()[0].getMessage(), 'Mensagem de erro discrepante.');
    }


    @IsTest 
    static void testOrgDuplicityOnInsert() {
        Test.startTest();

        Frete__c freight1 = TestDataFactory.createFreight(true); 
        Frete__c freight2 = freight1.clone();

        Database.SaveResult result = Database.insert(freight2, false);

        Test.stopTest();

        Assert.isFalse(result.isSuccess(), 'A duplicata foi inserida');
        Assert.isTrue(result.getErrors().size() > 0, 'Não houve erro no registro duplicado');
        Assert.areEqual('Já existe um frete para esse produto/hierarquia e centro de dist. nessa localidade.', result.getErrors()[0].getMessage(), 'Mensagem de erro discrepante.');
    }

    @IsTest 
    static void testQuery() {
        Test.startTest();

        Product2 product = TestDataFactory.createProduct(true);
        Estado__c state = TestDataFactory.createState(true);
        DistributionCenter__c distCenter1 = TestDataFactory.createDistCenter(true);
        DistributionCenter__c distCenter2 = TestDataFactory.createDistCenter(true);

        Frete__c freight1 = TestDataFactory.createFreight(product.Id, state.Id, distCenter1.Id, true);
        Frete__c freight2 = TestDataFactory.createFreight(product.Id, state.Id, distCenter2.Id, true);

        List<Frete__c> freights = FreteHelper.queryFreightsWithFields(new Set<Id>(), new Set<Id>{state.Id}, new Set<Id>(), new Set<Id>{product.Id}, new Set<Id>(), new Set<Id>{distCenter1.Id});

        Test.stopTest();

        Assert.areEqual(1, freights.size(), 'A query não retornou apenas um registro');
        Assert.areEqual(freight1.Id, freights[0].Id, 'O registro retornado pela query não é o esperado');
    }

    @IsTest 
    static void testQueryApprovedWithBlockedRecord() {
        Test.startTest();

        Frete__c freight2 = TestDataFactory.createFreight(false);
        Frete__c freight1 = TestDataFactory.createFreight(false);
        freight2.Status__c = 'Bloqueado';
        Database.insert(new List<Frete__c>{freight1, freight2});

        List<Frete__c> freights = FreteHelper.queryApprovedFreightsWithFields(new Set<Id>{freight1.Cidade__c, freight2.Cidade__c}, new Set<Id>(), new Set<Id>(),new Set<Id>{freight1.Product__c, freight2.Product__c}, new Set<Id>(),new Set<Id>{freight1.CentroDistribuicao__c, freight2.CentroDistribuicao__c});

        Test.stopTest();

        Assert.areEqual(1, freights.size(), 'A query não retornou apenas um registro');
        Assert.areEqual(freight1.Id, freights[0].Id, 'O registro retornado pela query não é o esperado');
    }

    @IsTest 
    static void testGetStringKeyMap() {
        Test.startTest();

        Frete__c freight1 = TestDataFactory.createFreight(false);
        Frete__c freight2 = TestDataFactory.createFreight(false);
        List<Frete__c> freights = new List<Frete__c>{freight1, freight2};

        Map<String, Frete__c> mapStringKeyXFreight = FreteHelper.getMapStringKeyXFreight(freights);

        Test.stopTest();

        Assert.areEqual(freight1, mapStringKeyXFreight.get(KeyStringGenerator.createStringKeyFromIds(freight1.Cidade__c, freight1.Product__c, freight1.CentroDistribuicao__c)));
        Assert.areEqual(freight2, mapStringKeyXFreight.get(KeyStringGenerator.createStringKeyFromIds(freight2.Cidade__c, freight2.Product__c, freight2.CentroDistribuicao__c)));
    }
}