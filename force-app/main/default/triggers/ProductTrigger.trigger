trigger ProductTrigger on Product2 (before insert, after insert) {
    new ProductTriggerHandler().run();
}