trigger OrderItemTrigger on OrderItem (before insert, before update, after insert, after update, after delete) {
    new OrderItemTriggerHandler().run();
}