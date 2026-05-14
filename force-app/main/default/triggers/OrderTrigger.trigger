trigger OrderTrigger on Order (before insert, before update, after update, after insert) {
    new OrderTriggerHandler().run();
}