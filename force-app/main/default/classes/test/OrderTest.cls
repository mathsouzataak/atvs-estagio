@isTest
private class OrderTest {

    @isTest 
    static void testUpdateActivated() {
        TriggerHandler.bypass('ProductTriggerHandler');
        Product2 product = TestDataFactory.createProduct(true);
        TriggerHandler.bypass('ProductTriggerHandler');
        PricebookEntry pricebookEntry = TestDataFactory.createPricebookEntry(PricebookHelper.getStandardPricebook(), product, true);
        Order order = TestDataFactory.createOrder(true);

        TriggerHandler.bypass('OrderItemTriggerHandler');
        OrderItem orderItem = TestDataFactory.createOrderItem(product.Id, order.Id, pricebookEntry, true);


        order.Status = 'Activated';
        Database.SaveResult activateOrderResult= Database.update(order, false);

        order.CentroDistribuicao__c = TestDataFactory.createDistCenter(true).Id;
        Database.SaveResult updateOrderResult = Database.update(order, false);

        TriggerHandler.clearBypass('OrderItemTriggerHandler');

        Assert.isTrue(activateOrderResult.isSuccess(), 'Não foi possível ativar o pedido');
        Assert.isFalse(updateOrderResult.isSuccess(), 'O pedido ativado foi atualizado');
        Assert.areEqual('O pedido está ativo e não pode ser alterado.', updateOrderResult.getErrors()[0].getMessage(), 'O erro esperado não foi lançado no pedido');    
    }

    @isTest
    static void testChangeAccount() {
        Order order = TestDataFactory.createOrder(true);

        order.AccountId = TestDataFactory.createAccount(true).Id;
        Database.SaveResult updateOrderAccountResult = Database.update(order, false);


        Assert.isFalse(updateOrderAccountResult.isSuccess(), 'A conta do pedido foi atualizada');
        Assert.areEqual('A conta do pedido não pode ser alterada.', updateOrderAccountResult.getErrors()[0].getMessage(), 'O erro esperado não foi lançado no pedido');    
    }


    @isTest
    static void testUpdateParameters() {
        Test.startTest();

        Product2 product = TestDataFactory.createProduct(true);
        Estado__c state = TestDataFactory.createState(true);
        Cidade__c city = TestDataFactory.createCity(state.Id, true);
        Account account = TestDataFactory.createAccount(true);
        AccountAddress__c address = TestDataFactory.createAddress(account.Id, city.Id, true);
        DistributionCenter__c distCenter1 = TestDataFactory.createDistCenter(true);
        DistributionCenter__c distCenter2 = TestDataFactory.createDistCenter(true);

        List<Imposto__c> taxes = new List<Imposto__c>{
            TestDataFactory.createTax(product.Id, state.Id, distCenter1.Id, false),
            TestDataFactory.createTax(product.Id, state.Id, distCenter2.Id, false)
        };
        Database.insert(taxes);
        List<Frete__c> freights = new List<Frete__c>{
            TestDataFactory.createFreight(product.Id, state.Pais__c, distCenter1.Id, false),
            TestDataFactory.createFreight(product.Id, state.Pais__c, distCenter2.Id, false)
        };
        Database.insert(freights);
        List<Margem__c> margins = new List<Margem__c>{
            TestDataFactory.createMargin(product.Id, account.AccountGroup__c, state.Pais__c, distCenter1.Id, false),
            TestDataFactory.createMargin(product.Id, account.AccountGroup__c, state.Pais__c, distCenter2.Id, false)
        };
        Database.insert(margins);

        Pricebook2 pricebook = PricebookHelper.getTestPricebook();
        Order order = TestDataFactory.createOrder(account.Id, address.Id, distCenter1.Id, pricebook.Id, TestDataFactory.createPaymentCondition(true).Id, true);

        PricebookEntry pricebookEntry = TestDataFactory.createPricebookEntry(pricebook, product, true);

        OrderItem orderItem = TestDataFactory.createOrderItem(product.Id, order.Id, pricebookEntry, true);

        order.CentroDistribuicao__c = distCenter2.Id;
        Database.SaveResult result = Database.update(order, false);

        OrderItem insertedItem = [SELECT Id, ImpostoPercent__c, ValorFrete__c, MargemPercent__c, PrecoSemMargem__c FROM OrderItem WHERE Id = :orderItem.Id LIMIT 1];

        Test.stopTest();

        Assert.isTrue(result.isSuccess(), 'Houve erro na atribuição de parâmetros');
        Assert.areEqual(taxes[1].ValorPercentual__c, insertedItem.ImpostoPercent__c, 'O valor de imposto atribuído não é o esperado');
        Assert.areEqual(freights[1].Valor__c, insertedItem.ValorFrete__c, 'O valor de frete atribuído não é o esperado');
        Assert.areEqual(margins[1].Valor__c, (insertedItem.MargemPercent__c * insertedItem.PrecoSemMargem__c / 100).setScale(2), 'O valor de margem atribuído não é o esperado');   
    }

    @isTest
    static void testUpdateParametersFail() {
        Test.startTest();

        Product2 product1 = TestDataFactory.createProduct(true);
        Product2 product2 = TestDataFactory.createProduct(true);
        Estado__c state = TestDataFactory.createState(true);
        Cidade__c city = TestDataFactory.createCity(state.Id, true);
        Account account = TestDataFactory.createAccount(true);
        AccountAddress__c address = TestDataFactory.createAddress(account.Id, city.Id, true);
        DistributionCenter__c distCenter1 = TestDataFactory.createDistCenter(true);
        DistributionCenter__c distCenter2 = TestDataFactory.createDistCenter(true);

        List<Imposto__c> taxes = new List<Imposto__c>{
            TestDataFactory.createTax(product1.Id, state.Id, distCenter1.Id, false),
            TestDataFactory.createTax(product2.Id, state.Id, distCenter1.Id, false),
            TestDataFactory.createTax(product2.Id, state.Id, distCenter2.Id, false)
        };
        Database.insert(taxes);
        List<Frete__c> freights = new List<Frete__c>{
            TestDataFactory.createFreight(product1.Id, state.Pais__c, distCenter1.Id, false),
            TestDataFactory.createFreight(product1.Id, state.Pais__c, distCenter2.Id, false),
            TestDataFactory.createFreight(product2.Id, state.Pais__c, distCenter1.Id, false),
            TestDataFactory.createFreight(product2.Id, state.Pais__c, distCenter2.Id, false)
        };
        Database.insert(freights);
        List<Margem__c> margins = new List<Margem__c>{
            TestDataFactory.createMargin(product1.Id, account.AccountGroup__c, state.Pais__c, distCenter1.Id, false),
            TestDataFactory.createMargin(product1.Id, account.AccountGroup__c, state.Pais__c, distCenter2.Id, false),
            TestDataFactory.createMargin(product2.Id, account.AccountGroup__c, state.Pais__c, distCenter1.Id, false),
            TestDataFactory.createMargin(product2.Id, account.AccountGroup__c, state.Pais__c, distCenter2.Id, false)
        };
        Database.insert(margins);

        Pricebook2 pricebook = PricebookHelper.getTestPricebook();
        Order order = TestDataFactory.createOrder(account.Id, address.Id, distCenter1.Id, pricebook.Id, TestDataFactory.createPaymentCondition(true).Id, true);

        PricebookEntry pricebookEntry = TestDataFactory.createPricebookEntry(pricebook, product1, true);

        OrderItem orderItem2 = TestDataFactory.createOrderItem(product2.Id, order.Id, pricebookEntry, true);
        OrderItem orderItem3 = TestDataFactory.createOrderItem(product2.Id, order.Id, pricebookEntry, true);
        OrderItem orderItem4 = TestDataFactory.createOrderItem(product2.Id, order.Id, pricebookEntry, true);
        OrderItem orderItem1 = TestDataFactory.createOrderItem(product1.Id, order.Id, pricebookEntry, true);


        order.CentroDistribuicao__c = distCenter2.Id;
        Database.SaveResult result = Database.update(order, false);

        OrderItem insertedItem = [SELECT Id, ImpostoPercent__c, ValorFrete__c, MargemPercent__c, PrecoSemMargem__c FROM OrderItem WHERE Id = :orderItem2.Id LIMIT 1];

        Test.stopTest();

        Assert.isFalse(result.isSuccess(), 'A alteração ocorreu');
        Assert.areEqual('Esta alteração foi abortada, pois algum dos itens ficaria sem parâmetros de precificação.', result.getErrors()[0].getMessage());
        Assert.areEqual(taxes[0].ValorPercentual__c, insertedItem.ImpostoPercent__c, 'O valor de imposto foi alterado');
        Assert.areEqual(freights[0].Valor__c, insertedItem.ValorFrete__c, 'O valor de frete foi alterado');
        Assert.areEqual(margins[0].Valor__c, (insertedItem.MargemPercent__c * insertedItem.PrecoSemMargem__c / 100).setScale(2), 'O valor de margem foi alterado');   
    }

}