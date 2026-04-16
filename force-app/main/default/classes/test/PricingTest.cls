@IsTest
private with sharing class PricingTest {
    
    @IsTest 
    static void testGetMostSpecificFreight() {
        Test.startTest();

        TriggerHandler.bypass('ProductTriggerHandler');
        Product2 product = TestDataFactory.createProduct(true);
        TriggerHandler.clearBypass('ProductTriggerHandler');
        Estado__c state = TestDataFactory.createState(true);
        Cidade__c city = TestDataFactory.createCity(state.Id, true);
        city.Estado__r = state;
        DistributionCenter__c distCenter= TestDataFactory.createDistCenter(true);

        List<Frete__c> freights = new List<Frete__c>{
            TestDataFactory.createFreight(product.HierarquiaProduto__c, state.Pais__c, distCenter.Id, false),
            TestDataFactory.createFreight(product.HierarquiaProduto__c, state.Id, distCenter.Id, false),
            TestDataFactory.createFreight(product.HierarquiaProduto__c, city.Id, distCenter.Id, false),
            TestDataFactory.createFreight(product.Id, state.Pais__c, distCenter.Id, false),
            TestDataFactory.createFreight(product.Id, state.Id, distCenter.Id, false),
            TestDataFactory.createFreight(product.Id, city.Id, distCenter.Id, false)
        };

        Map<String, Frete__c> mapStringKeyXFrete = FreteHelper.getMapStringKeyXFreight(freights);

        Frete__c selectedFreight = PricingHelper.getApplicableFreight(mapStringKeyXFrete, product, city, distCenter.Id);

        Test.stopTest();

        Assert.areEqual(freights[5], selectedFreight, 'Não foi selecionado o frete mais específico.');
    }

    @IsTest 
    static void testGetMostSpecificMargin() {
        Test.startTest();

        TriggerHandler.bypass('ProductTriggerHandler');
        Product2 product = TestDataFactory.createProduct(true);
        TriggerHandler.clearBypass('ProductTriggerHandler');
        Estado__c state = TestDataFactory.createState(true);
        Cidade__c city = TestDataFactory.createCity(state.Id, true);
        city.Estado__r = state;
        Account account = TestDataFactory.createAccount(true);
        DistributionCenter__c distCenter= TestDataFactory.createDistCenter(true);

        List<Margem__c> margins = new List<Margem__c>{
            TestDataFactory.createMargin(product.HierarquiaProduto__c, account.AccountGroup__c, state.Pais__c, distCenter.Id, false),
            TestDataFactory.createMargin(product.HierarquiaProduto__c, account.AccountGroup__c, state.Id, distCenter.Id, false),
            TestDataFactory.createMargin(product.HierarquiaProduto__c, account.AccountGroup__c,city.Id, distCenter.Id, false),
            TestDataFactory.createMargin(product.HierarquiaProduto__c, account.Id, state.Pais__c, distCenter.Id, false),
            TestDataFactory.createMargin(product.HierarquiaProduto__c, account.Id, state.Id, distCenter.Id, false),
            TestDataFactory.createMargin(product.HierarquiaProduto__c, account.Id, city.Id, distCenter.Id, false),
            TestDataFactory.createMargin(product.Id, account.AccountGroup__c, state.Pais__c, distCenter.Id, false),
            TestDataFactory.createMargin(product.Id, account.AccountGroup__c, state.Id, distCenter.Id, false),
            TestDataFactory.createMargin(product.Id, account.AccountGroup__c,city.Id, distCenter.Id, false),
            TestDataFactory.createMargin(product.Id, account.Id, state.Pais__c, distCenter.Id, false),
            TestDataFactory.createMargin(product.Id, account.Id, state.Id, distCenter.Id, false),
            TestDataFactory.createMargin(product.Id, account.Id,city.Id, distCenter.Id, false)
        };

        Map<String, Margem__c> mapStringKeyXMargin = MargemHelper.getMapStringKeyXMargin(margins);

        Margem__c selectedMargin = PricingHelper.getApplicableMargin(mapStringKeyXMargin, product, city, account, distCenter.Id);

        Test.stopTest();

        Assert.areEqual(margins[11], selectedMargin, 'Não foi selecionada a margem mais específica.');
    }

    @IsTest 
    static void testGetLeastSpecificFreight() {
        Test.startTest();

        TriggerHandler.bypass('ProductTriggerHandler');
        Product2 product = TestDataFactory.createProduct(true);
        TriggerHandler.clearBypass('ProductTriggerHandler');
        Estado__c state = TestDataFactory.createState(true);
        Cidade__c city = TestDataFactory.createCity(state.Id, true);
        city.Estado__r = state;
        DistributionCenter__c distCenter= TestDataFactory.createDistCenter(true);

        List<Frete__c> freights = new List<Frete__c>{
            TestDataFactory.createFreight(product.HierarquiaProduto__c, state.Pais__c, distCenter.Id, false)
        };

        Map<String, Frete__c> mapStringKeyXFrete = FreteHelper.getMapStringKeyXFreight(freights);

        Frete__c selectedFreight = PricingHelper.getApplicableFreight(mapStringKeyXFrete, product, city, distCenter.Id);

        Test.stopTest();

        Assert.areEqual(freights[0], selectedFreight, 'Não foi selecionado frete.');
    }

    @IsTest 
    static void testGetLeastSpecificMargin() {
        Test.startTest();

        TriggerHandler.bypass('ProductTriggerHandler');
        Product2 product = TestDataFactory.createProduct(true);
        TriggerHandler.clearBypass('ProductTriggerHandler');
        Estado__c state = TestDataFactory.createState(true);
        Cidade__c city = TestDataFactory.createCity(state.Id, true);
        city.Estado__r = state;
        Account account = TestDataFactory.createAccount(true);
        DistributionCenter__c distCenter= TestDataFactory.createDistCenter(true);

        List<Margem__c> margins = new List<Margem__c>{
            TestDataFactory.createMargin(product.HierarquiaProduto__c, account.AccountGroup__c, state.Pais__c, distCenter.Id, false)
        };

        Map<String, Margem__c> mapStringKeyXMargin = MargemHelper.getMapStringKeyXMargin(margins);

        Margem__c selectedMargin = PricingHelper.getApplicableMargin(mapStringKeyXMargin, product, city, account, distCenter.Id);

        Test.stopTest();

        Assert.areEqual(margins[0], selectedMargin, 'Não foi selecionada a margem mais específica.');
    }

    @IsTest
    static void testAssignParameters() {
        Test.startTest();

        Product2 product = TestDataFactory.createProduct(true);
        Estado__c state = TestDataFactory.createState(true);
        Cidade__c city = TestDataFactory.createCity(state.Id, true);
        city.Estado__r = state;
        Account account = TestDataFactory.createAccount(true);
        AccountAddress__c address = TestDataFactory.createAddress(account.Id, city.Id, true);
        address.Cidade__r = city;
        DistributionCenter__c distCenter = TestDataFactory.createDistCenter(true);

        List<Imposto__c> taxes = new List<Imposto__c>{
            TestDataFactory.createTax(product.Id, state.Id, distCenter.Id, false)
        };

        List<Margem__c> margins = new List<Margem__c>{
            TestDataFactory.createMargin(product.Id, account.AccountGroup__c, state.Pais__c, distCenter.Id, false)
        };

        List<Frete__c> freights = new List<Frete__c>{
            TestDataFactory.createFreight(product.Id, state.Pais__c, distCenter.Id, false)
        };

        Pricebook2 pricebook = PricebookHelper.getTestPricebook();
        Order order = TestDataFactory.createOrder(account.Id, address.Id, distCenter.Id, pricebook.Id, TestDataFactory.createPaymentCondition(true).Id, true);
        Order.Account = account;
        Order.AccountAddress__r = address;

        PricebookEntry pricebookEntry = TestDataFactory.createPricebookEntry(pricebook, product, true);

        TriggerHandler.bypass('OrderItemTriggerHandler');
        OrderItem orderItem = TestDataFactory.createOrderItem(product.Id, order.Id, pricebookEntry, false);
        TriggerHandler.clearBypass('OrderItemTriggerHandler');

        orderItem.ListPrice = pricebookEntry.UnitPrice;

        Map<Id,Order> mapOrder = new Map<Id,Order>{order.Id => order};
        Map<Id,Product2> mapProduct = new Map<Id,Product2>{product.Id => product};
        List<OrderItem> items = new List<OrderItem>{orderItem};
        
        Set<OrderItem> errors = PricingHelper.assignParameters(items, ImpostoHelper.getMapStringKeyXTax(taxes), FreteHelper.getMapStringKeyXFreight(freights), MargemHelper.getMapStringKeyXMargin(margins), mapOrder, mapProduct);

        Test.stopTest();

        Assert.areEqual(0, errors.size(), 'A atribuição de parâmetros retornou erros.');
        Assert.areEqual(taxes[0].ValorPercentual__c, orderItem.ImpostoPercent__c, 'O valor de imposto atribuído não é o esperado');
        Assert.areEqual(freights[0].Valor__c, orderItem.ValorFrete__c, 'O valor de frete atribuído não é o esperado');
        Assert.areEqual(100 * margins[0].Valor__c / ((orderItem.ListPrice + orderItem.ValorFrete__c )*(1+ orderItem.ImpostoPercent__c / 100)), orderItem.MargemPercent__c, 'O valor de frete atribuído não é o esperado');
    }

    @IsTest
    static void testOrderCreation() {
        Order order = TestDataFactory.createOrder(true);
    }

    @IsTest(SeeAllData=true)
    static void testOrderItemCreation() {
        TriggerHandler.bypass('OrderItemTriggerHandler');
        OrderItem orderItem = TestDataFactory.createOrderItem(true);
        TriggerHandler.clearBypass('OrderItemTriggerHandler');
    }



}