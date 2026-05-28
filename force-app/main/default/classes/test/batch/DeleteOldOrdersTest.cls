@isTest
private class DeleteOldOrdersTest {

    @TestSetup
    static void makeData(){
        Account account = TestDataFactory.createAccount(true);
        AccountAddress__c address = TestDataFactory.createAddress(account.Id, TestDataFactory.createCity(true).Id, true);
        DistributionCenter__c distCenter = TestDataFactory.createDistCenter(true);
        CondicaoPagamento__c paymentCondition = TestDataFactory.createPaymentCondition(true);

        List<Order> orders = new List<Order>();
        for (Integer i = 0; i < 90; i++) {
            orders.add(TestDataFactory.createOrder(account.Id, address.Id, distCenter.Id, Test.getStandardPricebookId(), paymentCondition.Id, false));
        }

        TriggerHandler.bypass('OrderTriggerHandler');
        Database.insert(orders);

        for (Integer i = 0; i < 45; i++) {
            Test.setCreatedDate(orders[i].Id, Datetime.now().addMonths(-6));
        }
        TriggerHandler.clearBypass('OrderTriggerHandler');
    }

    @isTest
    static void testDeleteOldOrdersBatch() {
        Test.startTest();
        DeleteOldOrders deletionBatch = new DeleteOldOrders(5);
        Id batchJobId = Database.executeBatch(deletionBatch);
        Test.stopTest();

        Assert.areEqual(0, [SELECT COUNT() FROM Order WHERE CreatedDate < :(Datetime.now().addMonths(-5))]);
        Assert.areEqual(45, [SELECT COUNT() FROM Order]);
    }

    @isTest
    static void testScheduledDeleteOldOrders() {
        Test.startTest();
        String cronExpression = '0 0 0 15 3 ? 2042';
        Id jobId = System.schedule('deleteOldOrdersTest', cronExpression, new ScheduledDeleteOldOrder());
        Test.stopTest();

        CronTrigger ct = [SELECT Id, CronExpression, State 
                            FROM CronTrigger 
                            WHERE Id = :jobId];
        Assert.areEqual(cronExpression, ct.CronExpression);
        Assert.areEqual('WAITING', ct.State);
    }
}