trigger ImpostoTrigger on Imposto__c (before insert) {
    new ImpostoTriggerHandler().run();
}