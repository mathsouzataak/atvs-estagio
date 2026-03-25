trigger FreteTrigger on Frete__c (before insert) {
    new FreteTriggerHandler().run();
}