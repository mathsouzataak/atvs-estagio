@IsTest
public with sharing class IntegrationInboundOneOrderTest {
	@TestSetup
	public static void makeData() {
		TestFactorySObject sobjectFactory = TestFactorySObject.getInstance();

		Account newAccount = TestDataFactory.createAccount(true);

		TriggerHandler.bypass('ProductTriggerHandler');
		Product2 newProduct = TestDataFactory.createProduct(true);
		TriggerHandler.clearBypass('ProductTriggerHandler');

		PricebookEntry newPricebookEntry = (PricebookEntry)sobjectFactory.createSObject(
			new PricebookEntry(product2Id = newProduct.Id, Pricebook2Id = Test.getStandardPricebookId())
		);
		insert newPricebookEntry;

		AccountAddress__c address = TestDataFactory.createAddress(newAccount.Id, TestDataFactory.createCity(true).Id, true);
		CondicaoPagamento__c paymentCondition = TestDataFactory.createPaymentCondition(true);
		DistributionCenter__c distCenter = TestDataFactory.createDistCenter(true);

		Order newOrder = (Order)sobjectFactory.createSObject(
			new Order(AccountId = newAccount.Id, AccountAddress__c = address.Id, Pricebook2Id = Test.getStandardPricebookId(), ExternalId__c = 'CalloutOrder', CondicaoPagamento__c = paymentCondition.Id, CentroDistribuicao__c = distCenter.Id)
		);
		Order newOrderError = (Order)sobjectFactory.createSObject(
			new Order(AccountId = newAccount.Id, AccountAddress__c = address.Id, Pricebook2Id = Test.getStandardPricebookId(), ExternalId__c = 'CalloutOrderError', CondicaoPagamento__c = paymentCondition.Id, CentroDistribuicao__c = distCenter.Id)
		);
		insert (new List<Order>{ newOrder, newOrderError });

		TriggerHandler.bypass('OrderItemTriggerHandler');
		TriggerHandler.bypass('OrderTriggerHandler');

		OrderItem newOrderItem = (OrderItem)sobjectFactory.createSObject(
			new OrderItem(OrderId = newOrder.Id, Product2Id = newProduct.Id, PricebookEntryId = newPricebookEntry.Id)
		);
		OrderItem newOrderItem2 = (OrderItem)sobjectFactory.createSObject(
			new OrderItem(OrderId = newOrder.Id, Product2Id = newProduct.Id, PricebookEntryId = newPricebookEntry.Id)
		);
		insert (new List<OrderItem>{ newOrderItem, newOrderItem2 });

		OrderItem newOrderItemError = (OrderItem)sobjectFactory.createSObject(
			new OrderItem(OrderId = newOrderError.Id, Product2Id = newProduct.Id, PricebookEntryId = newPricebookEntry.Id)
		);
		OrderItem newOrderItemError2 = (OrderItem)sobjectFactory.createSObject(
			new OrderItem(OrderId = newOrderError.Id, Product2Id = newProduct.Id, PricebookEntryId = newPricebookEntry.Id)
		);
		insert (new List<OrderItem>{ newOrderItemError, newOrderItemError2 });
		TriggerHandler.clearBypass('OrderTriggerHandler');
		TriggerHandler.clearBypass('OrderItemTriggerHandler');

	}

	@IsTest
	public static void upsertOrderTest() {
		DataIntegrationFields.OrderINData orderRequest = fillOrderINData();
		System.debug('orderRequest => ' + orderRequest);

		Test.startTest();
			IntegrationInboundOneOrder.doPost(orderRequest);
		Test.stopTest();
	}


	public static DataIntegrationFields.OrderINData fillOrderINData() {
        Order order = [SELECT Id, ExternalId__c, EffectiveDate, Status, Account.ExternalId__c, Pricebook2.ExternalId__c FROM Order LIMIT 1];

		DataIntegrationFields.OrderINData orderINData = new DataIntegrationFields.OrderINData();

		orderINData.externalId = order.ExternalId__c;
		orderINData.status = order.Status;
		orderINData.effectiveDate = order.EffectiveDate;
		orderINData.accountExternalId = order.Account.ExternalId__c;
		orderINData.pricebook2ExternalId = order.Pricebook2.ExternalId__c;
		orderINData.orderItemList = fillOrderItemINDataList(order.Id);

		return orderINData;
	}

	public static List<DataIntegrationFields.OrderItemINData> fillOrderItemINDataList(String orderId) {
		OrderItem orderItem = 	[
									SELECT Id, ExternalId__c, Quantity, UnitPrice, Order.ExternalId__c, Product2.ExternalId__c, PricebookEntry.ExternalId__c
									FROM OrderItem
									WHERE OrderId =: orderId
									LIMIT 1
								];

		return new List<DataIntegrationFields.OrderItemINData>{ fillOrderItemINData(orderItem) };
	}

	public static DataIntegrationFields.OrderItemINData fillOrderItemINData(OrderItem orderItem) {
		DataIntegrationFields.OrderItemINData orderItemINData = new DataIntegrationFields.OrderItemINData();

		orderItemINData.externalId = orderItem.ExternalId__c;
		orderItemINData.quantity = orderItem.Quantity;
		orderItemINData.unitPrice = orderItem.UnitPrice;
		orderItemINData.orderExternalId = orderItem.Order.ExternalId__c;
		orderItemINData.productExternalId = orderItem.Product2.ExternalId__c;
		orderItemINData.pricebookEntryExternalId = orderItem.PricebookEntry.ExternalId__c;

		return orderItemINData;
	}
}
