@isTest
private class OrderItemTest {

    @isTest
    static void testSearchAndAssignParameters() {
        Test.startTest();

        Product2 product = TestDataFactory.createProduct(true);
        Estado__c state = TestDataFactory.createState(true);
        Cidade__c city = TestDataFactory.createCity(state.Id, true);
        Account account = TestDataFactory.createAccount(true);
        AccountAddress__c address = TestDataFactory.createAddress(account.Id, city.Id, true);
        DistributionCenter__c distCenter = TestDataFactory.createDistCenter(true);

        Imposto__c tax = TestDataFactory.createTax(product.Id, state.Id, distCenter.Id, true);
        Margem__c margin = TestDataFactory.createMargin(product.Id, account.AccountGroup__c, state.Pais__c, distCenter.Id, true);
        Frete__c freight = TestDataFactory.createFreight(product.Id, state.Pais__c, distCenter.Id, true);

        System.debug('Tax: ' + tax);

        Pricebook2 pricebook = PricebookHelper.getTestPricebook();
        Order order = TestDataFactory.createOrder(account.Id, address.Id, distCenter.Id, pricebook.Id, TestDataFactory.createPaymentCondition(true).Id, true);

        PricebookEntry pricebookEntry = TestDataFactory.createPricebookEntry(pricebook, product, true);

        OrderItem orderItem = TestDataFactory.createOrderItem(product.Id, order.Id, pricebookEntry, false);
        
        Database.SaveResult result = Database.insert(orderItem);

        OrderItem insertedItem = [SELECT Id, ImpostoPercent__c, ValorFrete__c, MargemPercent__c, PrecoSemMargem__c FROM OrderItem WHERE Id = :orderItem.Id LIMIT 1];

        Test.stopTest();

        Assert.isTrue(result.isSuccess(), 'Houve erro na atribuição de parâmetros');
        Assert.areEqual(tax.ValorPercentual__c, insertedItem.ImpostoPercent__c, 'O valor de imposto atribuído não é o esperado');
        Assert.areEqual(freight.Valor__c, insertedItem.ValorFrete__c, 'O valor de frete atribuído não é o esperado');
        Assert.areEqual(margin.Valor__c, (insertedItem.MargemPercent__c * insertedItem.PrecoSemMargem__c / 100).setScale(2), 'O valor de frete atribuído não é o esperado');
    }

    @isTest
    static void testSearchAndAssignParameterFail() {
        Test.startTest();

        Product2 product = TestDataFactory.createProduct(true);
        Estado__c state = TestDataFactory.createState(true);
        Cidade__c city = TestDataFactory.createCity(state.Id, true);
        Account account = TestDataFactory.createAccount(true);
        AccountAddress__c address = TestDataFactory.createAddress(account.Id, city.Id, true);
        DistributionCenter__c distCenter = TestDataFactory.createDistCenter(true);

        Imposto__c tax = TestDataFactory.createTax(product.Id, state.Id, distCenter.Id, true);
        // Margem faltante
        Frete__c freight = TestDataFactory.createFreight(product.Id, state.Pais__c, distCenter.Id, true);

        System.debug('Tax: ' + tax);

        Pricebook2 pricebook = PricebookHelper.getTestPricebook();
        Order order = TestDataFactory.createOrder(account.Id, address.Id, distCenter.Id, pricebook.Id, TestDataFactory.createPaymentCondition(true).Id, true);

        PricebookEntry pricebookEntry = TestDataFactory.createPricebookEntry(pricebook, product, true);

        OrderItem orderItem = TestDataFactory.createOrderItem(product.Id, order.Id, pricebookEntry, false);
        
        Database.SaveResult result = Database.insert(orderItem, false);

        Test.stopTest();

        Assert.isFalse(result.isSuccess(), 'O item não deveria ter sido inserido, pois não possui um dos parâmetros');
    }

}