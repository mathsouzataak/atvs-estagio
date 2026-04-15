@IsTest
private with sharing class PricingTest {
    
    @IsTest 
    static void testGetMostSpecificFreight() {
        Test.startTest();

        Product2 product = TestDataFactory.createProduct(true);
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

        Product2 product = TestDataFactory.createProduct(true);
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

        Product2 product = TestDataFactory.createProduct(true);
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

        Product2 product = TestDataFactory.createProduct(true);
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