trigger OrderItemTrigger on OrderItem (before insert) {
    new OrderItemTriggerHandler().run();
}