trigger OrderItemTrigger on SOBJECT (before insert) {
    new OrderItemTriggerHandler().run();
}