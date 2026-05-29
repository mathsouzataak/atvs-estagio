trigger DevUserTrigger on DevUser__c (after insert) {
    new DevUserTriggerHandler().run();
}