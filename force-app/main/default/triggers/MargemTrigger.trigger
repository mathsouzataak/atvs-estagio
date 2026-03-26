trigger MargemTrigger on Margem__c (before insert) {
    new MargemTriggerHandler().run();
}