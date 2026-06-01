public with sharing class DevUserTriggerHandler extends TriggerHandler {
    
    public override void afterInsert() {
        Map<Id,DevUser__c> newDevUserMap = (Map<Id,DevUser__c>) Trigger.newMap; 
        DevUserDataRetriever dataRetrieverBatch = new DevUserDataRetriever(newDevUserMap.keySet());
        Id jobId = Database.executeBatch(dataRetrieverBatch, 100);
        System.debug('Batch job Id: ' + jobId);
    }

}