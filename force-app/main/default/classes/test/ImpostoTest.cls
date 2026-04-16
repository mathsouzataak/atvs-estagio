@IsTest
private with sharing class ImpostoTest {


    @IsTest
    static void testBulkDuplicityOnInsert() {
        Test.startTest();

        TriggerHandler.bypass('ProductTriggerHandler');
        Imposto__c tax1 = TestDataFactory.createTax(false);
        TriggerHandler.clearBypass('ProductTriggerHandler');
        Imposto__c tax2 = tax1.clone();
        List<Imposto__c> taxes = new List<Imposto__c>{tax1, tax2};

        List<Database.SaveResult> results = Database.insert(taxes, false);

        Test.stopTest();

        Assert.isTrue(results[0].isSuccess(), 'Houve erro no primeiro registro');
        Assert.isFalse(results[1].isSuccess(), 'A duplicata foi inserida');
        Assert.isTrue(results[1].getErrors().size() > 0, 'Não houve erro no registro duplicado');
        Assert.areEqual('Este imposto é duplicata de outro nesta mesma inserção.', results[1].getErrors()[0].getMessage(), 'Mensagem de erro discrepante.');
    }

    @IsTest 
    static void testOrgDuplicityOnInsert() {
        Test.startTest();

        TriggerHandler.bypass('ProductTriggerHandler');
        Imposto__c tax1 = TestDataFactory.createTax(true);
        TriggerHandler.clearBypass('ProductTriggerHandler');
        Imposto__c tax2 = tax1.clone();
        TriggerHandler.clearBypass('ProductTriggerHandler');

        Database.SaveResult result = Database.insert(tax2, false);

        Test.stopTest();

        Assert.isFalse(result.isSuccess(), 'A duplicata foi inserida');
        Assert.isTrue(result.getErrors().size() > 0, 'Não houve erro no registro duplicado');
        Assert.areEqual('Já existe um imposto para esse produto nesse estado.', result.getErrors()[0].getMessage(), 'Mensagem de erro discrepante.');
    }

    @IsTest 
    static void testQuery() {
        Test.startTest();

        TriggerHandler.bypass('ProductTriggerHandler');
        Product2 product = TestDataFactory.createProduct(true);
        TriggerHandler.clearBypass('ProductTriggerHandler');
        Estado__c state = TestDataFactory.createState(true);
        DistributionCenter__c distCenter1 = TestDataFactory.createDistCenter(true);
        DistributionCenter__c distCenter2 = TestDataFactory.createDistCenter(true);

        Imposto__c tax1 = TestDataFactory.createTax(product.Id, state.Id, distCenter1.Id, true);
        Imposto__c tax2 = TestDataFactory.createTax(product.Id, state.Id, distCenter2.Id, true);

        List<Imposto__c> taxes = ImpostoHelper.queryTaxesWithFields(new Set<Id>{state.Id}, new Set<Id>{product.Id}, new Set<Id>{distCenter1.Id});

        Test.stopTest();

        Assert.areEqual(1, taxes.size(), 'A query não retornou apenas um registro');
        Assert.areEqual(tax1.Id, taxes[0].Id, 'O registro retornado pela query não é o esperado');
    }

    @IsTest 
    static void testQueryApprovedWithBlockedRecord() {
        Test.startTest();

        TriggerHandler.bypass('ProductTriggerHandler');
        Imposto__c tax1 = TestDataFactory.createTax(false);
        Imposto__c tax2 = TestDataFactory.createTax(false);
        TriggerHandler.clearBypass('ProductTriggerHandler');
        tax2.Status__c = 'Bloqueado';
        Database.insert(new List<Imposto__c>{tax1, tax2});

        List<Imposto__c> taxes = ImpostoHelper.queryApprovedTaxesWithFields(new Set<Id>{tax1.Estado__c, tax2.Estado__c}, new Set<Id>{tax1.Product__c, tax2.Product__c}, new Set<Id>{tax1.CentroDistribuicao__c, tax2.CentroDistribuicao__c});

        Test.stopTest();

        Assert.areEqual(1, taxes.size(), 'A query não retornou apenas um registro');
        Assert.areEqual(tax1.Id, taxes[0].Id, 'O registro retornado pela query não é o esperado');
    }

    @IsTest 
    static void testGetStringKeyMap() {
        Test.startTest();

        TriggerHandler.bypass('ProductTriggerHandler');
        Imposto__c tax1 = TestDataFactory.createTax(false);
        Imposto__c tax2 = TestDataFactory.createTax(false);
        TriggerHandler.clearBypass('ProductTriggerHandler');
        List<Imposto__c> taxes = new List<Imposto__c>{tax1, tax2};

        Map<String, Imposto__c> mapStringKeyXTax = ImpostoHelper.getMapStringKeyXTax(taxes);

        Test.stopTest();

        Assert.areEqual(tax1, mapStringKeyXTax.get(KeyStringGenerator.createStringKeyFromIds(tax1.Estado__c, tax1.Product__c, tax1.CentroDistribuicao__c)));
        Assert.areEqual(tax2, mapStringKeyXTax.get(KeyStringGenerator.createStringKeyFromIds(tax2.Estado__c, tax2.Product__c, tax2.CentroDistribuicao__c)));
    }
    
}